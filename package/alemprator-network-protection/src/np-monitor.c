#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <linux/if_bridge.h>
#include <net/if.h>
#include <time.h>

#define BUF_SIZE 32768
#define MAX_EVENTS 128

static volatile int running = 1;

static void handle_signal(int sig) {
	(void)sig;
	running = 0;
}

static void print_json_event(const char *type, const char *subtype,
			     const char *ifname, const char *mac,
			     const char *info)
{
	time_t now;
	time(&now);
	struct tm *tm = localtime(&now);
	char ts[64];
	strftime(ts, sizeof(ts), "%Y-%m-%dT%H:%M:%S", tm);

	printf("{\"ts\":\"%s\",\"type\":\"%s\",\"subtype\":\"%s\""
	       ",\"iface\":\"%s\",\"mac\":\"%s\",\"info\":\"%s\"}\n",
	       ts, type, subtype,
	       ifname ? ifname : "",
	       mac ? mac : "",
	       info ? info : "");
	fflush(stdout);
}

static void parse_fdb_event(struct nlmsghdr *nh)
{
	struct ndmsg *ndm = NLMSG_DATA(nh);
	struct rtattr *rta;
	int len = nh->nlmsg_len - NLMSG_LENGTH(sizeof(*ndm));
	char ifname[IFNAMSIZ] = "";
	char mac[18] = "";
	int bridge = 0;

	for (rta = RTM_RTA(ndm); RTA_OK(rta, len); rta = RTA_NEXT(rta, len)) {
		switch (rta->rta_type) {
		case NDA_LLADDR: {
			unsigned char *m = RTA_DATA(rta);
			snprintf(mac, sizeof(mac),
				 "%02x:%02x:%02x:%02x:%02x:%02x",
				 m[0], m[1], m[2], m[3], m[4], m[5]);
			break;
		}
		case NDA_IFINDEX: {
			int ifindex = *(int *)RTA_DATA(rta);
			if (if_indextoname(ifindex, ifname) == NULL)
				snprintf(ifname, sizeof(ifname), "if%d", ifindex);
			break;
		}
		case NDA_MASTER: {
			int master = *(int *)RTA_DATA(rta);
			char master_name[IFNAMSIZ];
			if (if_indextoname(master, master_name))
				bridge = master;
			break;
		}
		}
	}

	/* Check if this is a bridge FDB entry (NDA_MASTER set) */
	if (bridge && strlen(mac) > 0) {
		const char *subtype = "fdb";
		if (nh->nlmsg_type == RTM_NEWNEIGH)
			subtype = "fdb_add";
		else if (nh->nlmsg_type == RTM_DELNEIGH)
			subtype = "fdb_del";

		char info[64];
		snprintf(info, sizeof(info), "bridge=%s", if_indextoname(bridge, (char[IFNAMSIZ]){0}) ?: "?");

		print_json_event("bridge", subtype, ifname, mac, info);

		/* Detect MAC flapping by tracking last port per MAC */
		static struct {
			char mac[18];
			char port[IFNAMSIZ];
			time_t time;
		} mac_cache[256];
		static int cache_count = 0;

		int found = -1;
		for (int i = 0; i < cache_count; i++) {
			if (strcmp(mac_cache[i].mac, mac) == 0) {
				found = i;
				break;
			}
		}

		if (found >= 0) {
			if (strcmp(mac_cache[found].port, ifname) != 0) {
				char info2[128];
				snprintf(info2, sizeof(info2),
					 "flap from %s to %s",
					 mac_cache[found].port, ifname);
				print_json_event("bridge", "mac_flap",
						 ifname, mac, info2);
				memcpy(mac_cache[found].port, ifname,
				       IFNAMSIZ);
			}
			mac_cache[found].time = time(NULL);
		} else if (cache_count < 256) {
			strncpy(mac_cache[cache_count].mac, mac, 17);
			strncpy(mac_cache[cache_count].port, ifname,
				IFNAMSIZ - 1);
			mac_cache[cache_count].time = time(NULL);
			cache_count++;
		}
	}
}

static void parse_link_event(struct nlmsghdr *nh)
{
	struct ifinfomsg *ifi = NLMSG_DATA(nh);
	struct rtattr *rta;
	int len = nh->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
	char ifname[IFNAMSIZ] = "";

	if (if_indextoname(ifi->ifi_index, ifname) == NULL)
		snprintf(ifname, sizeof(ifname), "if%d", ifi->ifi_index);

	int is_bridge = 0;
	for (rta = IFLA_RTA(ifi); RTA_OK(rta, len); rta = RTA_NEXT(rta, len)) {
		if (rta->rta_type == IFLA_MASTER)
			is_bridge = 1;
	}

	if (is_bridge) {
		const char *subtype = "link_change";
		if (nh->nlmsg_type == RTM_NEWLINK)
			subtype = (ifi->ifi_flags & IFF_UP) ? "link_up" :
				  "link_down";

		char info[32];
		snprintf(info, sizeof(info), "flags=0x%x", ifi->ifi_flags);
		print_json_event("link", subtype, ifname, "", info);
	}
}

static int setup_netlink_socket(int group1, int group2)
{
	int sock = socket(AF_NETLINK, SOCK_RAW | SOCK_CLOEXEC,
			  NETLINK_ROUTE);
	if (sock < 0) {
		fprintf(stderr, "Failed to create netlink socket: %s\n",
			strerror(errno));
		return -1;
	}

	struct sockaddr_nl sa = {
		.nl_family = AF_NETLINK,
		.nl_groups = group1 | group2,
		.nl_pid = 0
	};

	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
		fprintf(stderr, "Failed to bind netlink socket: %s\n",
			strerror(errno));
		close(sock);
		return -1;
	}

	return sock;
}

static int setup_netlink_socket_groups(int *groups, int count)
{
	int sock = socket(AF_NETLINK, SOCK_RAW | SOCK_CLOEXEC,
			  NETLINK_ROUTE);

	if (sock < 0) {
		fprintf(stderr, "Failed to create netlink socket: %s\n",
			strerror(errno));
		return -1;
	}

	unsigned int group_mask = 0;
	for (int i = 0; i < count; i++)
		group_mask |= (1 << (groups[i] - 1));

	struct sockaddr_nl sa = {
		.nl_family = AF_NETLINK,
		.nl_groups = group_mask,
		.nl_pid = 0
	};

	if (bind(sock, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
		fprintf(stderr, "Failed to bind netlink socket: %s\n",
			strerror(errno));
		close(sock);
		return -1;
	}

	return sock;
}

static void process_netlink_messages(int sock)
{
	char buf[BUF_SIZE];
	struct sockaddr_nl nladdr;
	struct iovec iov = { .iov_base = buf, .iov_len = sizeof(buf) };
	struct msghdr msg = {
		.msg_name = &nladdr,
		.msg_namelen = sizeof(nladdr),
		.msg_iov = &iov,
		.msg_iovlen = 1,
	};

	int ret = recvmsg(sock, &msg, 0);
	if (ret < 0) {
		if (errno != EINTR)
			fprintf(stderr, "Netlink recv error: %s\n",
				strerror(errno));
		return;
	}

	if (msg.msg_namelen != sizeof(nladdr)) {
		fprintf(stderr, "Invalid netlink address length\n");
		return;
	}

	if (nladdr.nl_pid != 0) {
		/* Kernel message only */
		return;
	}

	struct nlmsghdr *nh;
	for (nh = (struct nlmsghdr *)buf;
	     NLMSG_OK(nh, (size_t)ret);
	     nh = NLMSG_NEXT(nh, ret)) {

		if (nh->nlmsg_type == NLMSG_DONE)
			break;

		if (nh->nlmsg_type == NLMSG_ERROR) {
			struct nlmsgerr *err = NLMSG_DATA(nh);
			fprintf(stderr, "Netlink error: %s (code=%d)\n",
				strerror(-err->error), err->error);
			continue;
		}

		switch (nh->nlmsg_type) {
		case RTM_NEWNEIGH:
		case RTM_DELNEIGH:
			parse_fdb_event(nh);
			break;
		case RTM_NEWLINK:
		case RTM_DELLINK:
			parse_link_event(nh);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	(void)argc;
	(void)argv;

	signal(SIGINT, handle_signal);
	signal(SIGTERM, handle_signal);
	signal(SIGQUIT, handle_signal);

	/* Subscribe to:
	 *   RTNLGRP_NEIGH (FDB/neighbor events)
	 *   RTNLGRP_LINK (link events)
	 */
	int neigh_groups[] = { RTNLGRP_NEIGH };
	int link_groups[] = { RTNLGRP_LINK };

	int neigh_sock = setup_netlink_socket_groups(neigh_groups, 1);
	int link_sock = setup_netlink_socket_groups(link_groups, 1);

	if (neigh_sock < 0 && link_sock < 0) {
		fprintf(stderr, "Failed to create any netlink sockets\n");
		return 1;
	}

	print_json_event("system", "start", "", "", "np-monitor initialized");

	while (running) {
		fd_set rfds;
		int max_fd = -1;

		FD_ZERO(&rfds);
		if (neigh_sock >= 0) {
			FD_SET(neigh_sock, &rfds);
			if (neigh_sock > max_fd)
				max_fd = neigh_sock;
		}
		if (link_sock >= 0) {
			FD_SET(link_sock, &rfds);
			if (link_sock > max_fd)
				max_fd = link_sock;
		}

		struct timeval tv = { .tv_sec = 1, .tv_usec = 0 };
		int ret = select(max_fd + 1, &rfds, NULL, NULL, &tv);

		if (ret < 0) {
			if (errno == EINTR)
				continue;
			break;
		}

		if (ret == 0)
			continue;

		if (neigh_sock >= 0 && FD_ISSET(neigh_sock, &rfds))
			process_netlink_messages(neigh_sock);

		if (link_sock >= 0 && FD_ISSET(link_sock, &rfds))
			process_netlink_messages(link_sock);
	}

	print_json_event("system", "stop", "", "", "np-monitor shutting down");

	if (neigh_sock >= 0)
		close(neigh_sock);
	if (link_sock >= 0)
		close(link_sock);

	return 0;
}
