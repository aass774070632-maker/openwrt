. /lib/functions.sh

NP_CFG="alemprator-network-protection"
NP_LIBEXEC="/usr/libexec/alemprator-network-protection"
NP_STATE_DIR="/tmp/alemprator-network-protection"
NP_LOG_DIR="/var/log/alemprator-network-protection"
NP_RUN_DIR="/var/run/alemprator-network-protection"
NP_VERSION="1.0.0"

np_init_state() {
	mkdir -p "$NP_STATE_DIR" "$NP_LOG_DIR" "$NP_RUN_DIR" 2>/dev/null || true
}

np_log() {
	local level="$1"
	local msg="$2"
	local timestamp
	timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
	local tag="alemprator-network-protection"
	mkdir -p "$NP_LOG_DIR" 2>/dev/null || true
	echo "$timestamp $level $tag: $msg" >> "$NP_LOG_DIR/events.log"
	
	local syslog_level="$level"
	[ "$syslog_level" = "critical" ] && syslog_level="crit"
	logger -t "$tag" -p "${syslog_level}" "$msg"
}

np_debug() {
	local msg="$1"
	local debug
	config_get debug main debug 0
	[ "$debug" = "1" ] && np_log "debug" "$msg"
}

np_get_bridges() {
	local bridges
	config_get bridges main bridges "br-lan"
	echo "$bridges"
}

np_bridge_exists() {
	local br="$1"
	[ -d "/sys/class/net/$br/bridge" ] && return 0
	return 1
}

np_get_bridge_ports() {
	local br="$1"
	ls "/sys/class/net/$br/brif/" 2>/dev/null || echo ""
}

np_port_is_bridge_member() {
	local port="$1"
	local br
	for br in $(np_get_bridges); do
		[ -d "/sys/class/net/$br/brif/$port" ] && return 0
	done
	return 1
}

np_get_port_state() {
	local port="$1"
	local state
	state="$(cat "/sys/class/net/$port/operstate" 2>/dev/null)"
	echo "${state:-unknown}"
}

np_set_port_state() {
	local port="$1"
	local state="$2"
	if [ "$state" = "down" ]; then
		ip link set dev "$port" down 2>/dev/null && np_log "info" "Disabled port $port"
	elif [ "$state" = "up" ]; then
		ip link set dev "$port" up 2>/dev/null && np_log "info" "Enabled port $port"
	fi
}

np_get_fdb_entries() {
	local br="$1"
	bridge fdb show br "$br" 2>/dev/null
}

np_get_mac_learning_state() {
	local br="$1"
	local port="$2"
	bridge fdb show br "$br" brport "$port" 2>/dev/null
}

np_is_local_mac() {
	local mac="$1"
	local iface
	for iface in /sys/class/net/*/address; do
		[ -f "$iface" ] || continue
		[ "$(cat "$iface" 2>/dev/null)" = "$mac" ] && return 0
	done
	return 1
}

np_load_config() {
	config_load "$NP_CFG"
}

np_get_option() {
	local section="$1"
	local option="$2"
	local default="$3"
	local val
	config_get val "$section" "$option" "$default"
	echo "$val"
}

np_get_section() {
	local name="$1"
	local type="$2"
	config_foreach np_section_cb "$type" "$name"
}

np_rate_limit_port() {
	local port="$1"
	local kbps="$2"
	local ifb

	ifb="ifb4np-$port"
	ip link add "$ifb" type ifb 2>/dev/null || true
	ip link set dev "$ifb" up 2>/dev/null || true

	tc qdisc replace dev "$port" ingress 2>/dev/null || true
	tc filter replace dev "$port" parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev "$ifb" 2>/dev/null || true

	tc qdisc replace dev "$ifb" root tbf rate "${kbps}kbit" burst 32kbit latency 50ms 2>/dev/null || true

	np_log "info" "Rate limited port $port to ${kbps}kbps"
}

np_remove_rate_limit() {
	local port="$1"
	local ifb="ifb4np-$port"

	tc qdisc del dev "$port" ingress 2>/dev/null || true
	ip link delete "$ifb" 2>/dev/null || true

	np_log "info" "Removed rate limit from port $port"
}

np_get_bridge_fdb_count() {
	local br="$1"
	bridge fdb show br "$br" 2>/dev/null | wc -l
}

np_cleanup_ifb() {
	for ifb in /sys/class/net/ifb4np-*/ifindex; do
		local iface
		iface=$(basename "$(dirname "$ifb")" 2>/dev/null)
		[ -n "$iface" ] && ip link delete "$iface" 2>/dev/null || true
	done

	for port in /sys/class/net/*/ifindex; do
		local iface
		iface=$(basename "$(dirname "$port")" 2>/dev/null)
		[ -n "$iface" ] && tc qdisc del dev "$iface" ingress 2>/dev/null || true
	done
}

np_check_ebpf_support() {
	if [ -f /sys/fs/bpf ] && command -v bpftool >/dev/null 2>&1; then
		echo "1"
	else
		echo "0"
	fi
}

np_get_uptime() {
	cat /proc/uptime 2>/dev/null | awk '{print $1}'
}

# Set up ARP monitoring via nftables on bridge ports
setup_arp_monitor() {
	local bridges
	bridges="$(np_get_bridges)"
	for br in $bridges; do
		np_bridge_exists "$br" || continue
		local ports
		ports="$(np_get_bridge_ports "$br")"
		for port in $ports; do
			nft add rule inet fw4 alemprator_arp ip protocol arp meta iifname "$port" counter name arp_${port} 2>/dev/null || true
		done
	done
}

# Read ARP packet counter for a specific port
read_arp_counter() {
	local port="$1"
	nft list counter inet fw4 arp_${port} 2>/dev/null | grep -o 'packets [0-9]*' | awk '{print $2}' || echo 0
}
