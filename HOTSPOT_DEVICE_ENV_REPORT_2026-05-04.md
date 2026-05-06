# Hotspot Device Environment Report - 2026-05-04

## Current Post-Reset/Cleanup Status

After the router format/reset and temporary hotspot cleanup, the current reachable router is `192.168.1.20`.

```text
Router: KT KM14-102H / OpenWrt 24.10.4
br-lan: 192.168.1.20/24
Chilli: disabled and not running
tun0: absent
Temporary SSID ALemprator-KT-KM14-102H: absent
Default open SSID OpenWrt: removed
Temporary portal files: absent
Backup: hotspot-backups/20260504-231807-before-temp-hotspot-delete
```

Earlier sections in this report include pre-reset data from the `192.168.1.21` attempt and are retained for troubleshooting history.

## Hotspot OpenWrt Package Install - 2026-05-05

Target router: `192.168.1.20`

Installed and validated package:

```text
luci-app-hotspot-openwrt: installed
coova-chilli: installed with --nodeps because /dev/net/tun and tun.ko already exist, but opkg did not have a matching kmod-tun package record
iptables-nft / xtables-nft: installed with forced dependency handling because kmod-nft-compat is unavailable in this kernel config
```

Runtime result after `Apply`:

```text
Hotspot OpenWrt enabled: yes
SSID created: Hotspot-OpenWrt
SSID interface: phy0-ap1
Hotspot network: 192.168.10.1/24
CoovaChilli process: running
Chilli UAM: 192.168.10.1:3990
tun0: present, 192.168.10.1/24
br-lan management: still reachable at 192.168.1.20/24
RADIUS server: 192.168.1.2
RADIUS transport: UDP only, ports 1812/1813
Config backup from apply: /etc/hotspot-openwrt/backups/20260505-003039
Pre-install backup: /root/hotspot-openwrt-preinstall-20260505-002442
```

Current user test path:

```text
1. Connect a phone/laptop to SSID: Hotspot-OpenWrt
2. Client should receive an address from 192.168.10.10-192.168.10.254
3. Open any HTTP site or browse to http://192.168.10.1/hotspot/terms.html
4. Continue to login page and enter MikroTik User Manager card credentials
5. MikroTik User Manager must contain NAS/client 192.168.1.20 with secret 123456, or the configured secret in LuCI
```

Known runtime note:

```text
Chilli starts and creates tun0 successfully, but logread shows iptables compatibility warnings because kmod-nft-compat is unavailable. firewall4 rules for br-hotspot/tun0 are present; final proof still requires a real WiFi client login through MikroTik User Manager.
```

Portal access fix applied after phone test:

```text
Symptom: client received 192.168.10.10 but http://192.168.10.1/hotspot/terms.html did not open.
Cause: Chilli allowed UAM ports 3990/3991 but dropped local TCP/80 to 192.168.10.1 from unauthenticated clients.
Fix: /etc/chilli/config now contains HS_TCP_PORTS="80".
Package update: luci-app-hotspot-openwrt apply engine now manages the same setting automatically.
Verification: nft rules now include accept for ip daddr 192.168.10.1 iifname tun0 tcp dport 80 before the drop rule.
```

Login form fix applied after card submission test:

```text
Symptom: after entering a card, browser opened 192.168.10.1:3990/log... and returned ERR_EMPTY_RESPONSE.
Router log: No username found in login request.
Cause: portal form used /logon with POST and UserName/Password fields; this Chilli build expects /login query parameters username/password.
Fix: /www/hotspot/login.html now submits GET to http://192.168.10.1:3990/login with lowercase username/password.
Chilli fix: option nochallenge '1' is now set so plain PAP credentials are sent to MikroTik User Manager over RADIUS UDP.
Package update: luci-app-hotspot-openwrt apply engine now sets nochallenge automatically.
```

Final authenticated-client internet fix after phone test:

```text
Symptom: phone authenticated successfully and Chilli showed pass state, but internet pages still failed or looped.
Root cause: both br-hotspot and tun0 owned 192.168.10.1/24. Return traffic to the client routed to br-hotspot instead of tun0, then Chilli dropped it.
Live fix: remove 192.168.10.1/24 from br-hotspot and make network.hotspot proto none.
Persistent package fix: apply now configures br-hotspot as layer-2 only and deletes ipaddr/netmask/delegate/ip6assign from the hotspot interface.
Correct runtime state: br-hotspot has no IPv4 address; tun0 owns 192.168.10.1/24; 192.168.10.0/24 routes via tun0.
Phone verification: Android Chrome opened http://hverse.neverssl.com and displayed the NeverSSL page.
```

Verified router output after the successful phone page load:

```text
36-5D-F3-EF-19-25 192.168.10.11 pass ... temporary-test 160/3600 5/0 384899/0 261425/0 ...
192.168.10.0/24 dev tun0 scope link src 192.168.10.1
192.168.10.11 from 8.8.8.8 dev tun0 iif br-lan
iifname "tun0" oifname "br-lan" counter packets 2326 bytes 463235 accept
iifname "br-lan" oifname "tun0" counter packets 707 bytes 381426 accept
ip saddr 192.168.10.0/24 oifname "br-lan" counter packets 401 bytes 55878 snat ip to 192.168.1.20
```

MikroTik-style LuCI redesign applied:

```text
Design goal: make luci-app-hotspot-openwrt behave like a small, simplified MikroTik HotSpot page without adding heavy dependencies or duplicate logic.
Reference model: MikroTik HotSpot tabs/concepts: Server, Server Profile, RADIUS, Walled Garden, Active, Hosts.
Implemented LuCI tabs: Server, Server Profile, RADIUS, Active / Hosts, IP Bindings, Walled Garden, Cookies, Review.
Kept out intentionally: local HotSpot Users/User Profiles management, because MikroTik User Manager remains the card/user database.
Runtime sidebar: service state, tun0, route health, bridge IP safety, Active count, Host count, and RADIUS UDP endpoint.
Backend change: status-json now returns lightweight Active/Hosts counters from chilli_query and checks the br-hotspot no-IP route safety.
Walled Garden change: default allowed domains are stored as UCI list hotspot_openwrt.main.walled_garden and mapped to CoovaChilli uamdomain.
Package size after redesign: luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk = 13297 bytes.
Router verification: LuCI page opened successfully, tabs switched successfully, Review showed hotspot/tun0/RADIUS values, and status-json reported one active client.
IP Bindings note: tab is present and stores a lightweight UCI list for planned MikroTik-like binding entries. It is not yet mapped to runtime enforcement to avoid unsafe side effects from partial CoovaChilli/MikroTik semantic mismatch.
Cookies note: tab is present as read-only runtime context. MikroTik RouterOS has an independent HotSpot cookie table, while this CoovaChilli setup exposes live sessions through Active / Hosts and does not maintain an equivalent RouterOS cookie table.
```

Target router used: `192.168.1.20`

Note: `192.168.1.21` was tested first and returned: `ssh: connect to host 192.168.1.21 port 22: No route to host`

## Update After Internet Was Restored

The router is now reachable at `192.168.1.21`, not `192.168.1.20`.

`192.168.1.20` now returns:

```text
ssh: connect to host 192.168.1.20 port 22: No route to host
```

`192.168.1.21` is the OpenWrt router:

```text
OPENWRT_192_168_1_21_OK
{
        "kernel": "6.6.110",
        "hostname": "KT-KM14-102H",
        "system": "MediaTek MT7621 ver:1 eco:3",
        "model": "KT KM14-102H",
        "board_name": "kt,km14-102h",
        "rootfs_type": "squashfs",
        "release": {
                "distribution": "OpenWrt",
                "version": "24.10.4",
                "revision": "r28959-29397011cc",
                "target": "ramips/mt7621",
                "description": "OpenWrt 24.10.4 r28959-29397011cc",
                "builddate": "1760891865"
        }
}
```

Current direct answers after the update:

- OpenWrt router IP: `192.168.1.21`
- MikroTik / gateway IP detected from default route: `192.168.1.2`
- Internet currently working: Yes. `8.8.8.8`, DNS, `ota.kartnet.org`, and Alemprator internet-check are working.
- `1.1.1.1` still does not reply to ping from the router.
- TCP `1812/1813` to MikroTik from the host is refused.
- UDP `1812/1813` to MikroTik from the host succeeds, which matches normal RADIUS transport.
- BusyBox `nc` inside the router still does not support `-zv`, and `timeout` is not installed on the router.

### refreshed ip a

```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1504 qdisc mq state UP qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
    inet6 fe80::e96:cdff:fe65:bebf/64 scope link 
       valid_lft forever preferred_lft forever
3: wan@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
4: lan@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
6: phy0-ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:c0 brd ff:ff:ff:ff:ff:ff
8: phy1-ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:c1 brd ff:ff:ff:ff:ff:ff
11: br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP qlen 1000
    link/ether 0c:96:cd:65:be:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.21/24 brd 192.168.1.255 scope global br-lan
       valid_lft forever preferred_lft forever
```

### refreshed cat /etc/config/network

```text
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd82:5161:f958::/48'
        option packet_steering '1'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'lan1'
        list ports 'lan2'
        list ports 'lan3'
        list ports 'lan4'
        list ports 'wan'
        option ageing_time '10'
        option ipv6 '0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.1.21'
        option netmask '255.255.255.0'
        option gateway '192.168.1.2'
        list dns '8.8.8.8'
        list dns '82.114.163.31'
        option delegate '0'
        option ageing_time '10'
```

### refreshed brctl show

```text
bridge name     bridge id               STP enabled     interfaces
br-lan          7fff.0c96cd65bec0       no              wan
                                                        phy0-ap0
                                                        phy1-ap0
```

### refreshed ip route

```text
default via 192.168.1.2 dev br-lan 
192.168.1.0/24 dev br-lan scope link  src 192.168.1.21 
```

### detected IP_MIKROTIK from default route

```text
192.168.1.2
```

### ping IP_MIKROTIK

```text
PING 192.168.1.2 (192.168.1.2): 56 data bytes
64 bytes from 192.168.1.2: seq=0 ttl=64 time=0.792 ms
64 bytes from 192.168.1.2: seq=1 ttl=64 time=0.561 ms
64 bytes from 192.168.1.2: seq=2 ttl=64 time=0.561 ms
64 bytes from 192.168.1.2: seq=3 ttl=64 time=0.591 ms

--- 192.168.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.561/0.626/0.792 ms
```

### ping 1.1.1.1

```text
PING 1.1.1.1 (1.1.1.1): 56 data bytes

--- 1.1.1.1 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

### ping 8.8.8.8

```text
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=118 time=79.321 ms
64 bytes from 8.8.8.8: seq=1 ttl=118 time=79.962 ms
64 bytes from 8.8.8.8: seq=2 ttl=118 time=79.580 ms
64 bytes from 8.8.8.8: seq=3 ttl=118 time=79.378 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 79.321/79.560/79.962 ms
```

### ping ota.kartnet.org

```text
PING ota.kartnet.org (172.67.197.197): 56 data bytes
64 bytes from 172.67.197.197: seq=0 ttl=57 time=46.229 ms
64 bytes from 172.67.197.197: seq=1 ttl=57 time=46.268 ms
64 bytes from 172.67.197.197: seq=2 ttl=57 time=47.139 ms
64 bytes from 172.67.197.197: seq=3 ttl=57 time=46.211 ms

--- ota.kartnet.org ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 46.211/46.461/47.139 ms
```

### /usr/libexec/alemprator-ota/internet-check

```text
{"status":"online","internet_ok":true,"server_ok":true,"message":"الإنترنت وخادم التحديثات يعملان.","lan_ip":"192.168.1.21","gateway":"192.168.1.2","server_url":"https://ota.kartnet.org","server_host":"ota.kartnet.org","mikrotik_command":"/ip firewall nat add chain=srcnat src-address=192.168.1.21 action=masquerade comment=\"Alemprator updater internet access\""}
```

### nc -zv IP_MIKROTIK 1812 inside router

```text
BusyBox v1.36.1 (2025-10-19 16:37:45 UTC) multi-call binary.

Usage: nc [IPADDR PORT]

Open a pipe to IP:PORT
```

### nc -zv IP_MIKROTIK 1813 inside router

```text
BusyBox v1.36.1 (2025-10-19 16:37:45 UTC) multi-call binary.

Usage: nc [IPADDR PORT]

Open a pipe to IP:PORT
```

### busybox nc fallback: timeout 5 nc IP_MIKROTIK 1812

```text
ash: timeout: not found
exit=127
```

### busybox nc fallback: timeout 5 nc IP_MIKROTIK 1813

```text
ash: timeout: not found
exit=127
```

### host nc -zv 192.168.1.2 1812

```text
nc: connect to 192.168.1.2 port 1812 (tcp) failed: Connection refused
exit=1
```

### host nc -zv 192.168.1.2 1813

```text
nc: connect to 192.168.1.2 port 1813 (tcp) failed: Connection refused
exit=1
```

### host nc -uzv 192.168.1.2 1812

```text
Connection to 192.168.1.2 1812 port [udp/radius] succeeded!
exit=0
```

### host nc -uzv 192.168.1.2 1813

```text
Connection to 192.168.1.2 1813 port [udp/radius-acct] succeeded!
exit=0
```

## Direct Answers

- Port connected to MikroTik / upstream according to current runtime bridge: `wan` is enslaved to `br-lan`; default route is via `192.168.1.1 dev br-lan`.
- Internet currently working: No. Pings to `192.168.1.1`, `1.1.1.1`, and `8.8.8.8` failed; DNS lookup for `ota.kartnet.org` failed.
- NAT: firewall config has `wan` zone with `option masq '1'`, and nft ruleset contains IPv4 masquerade for wan traffic.
- PPPoE: no PPP/PPPoE interface is configured or active in the checked outputs.
- CoovaChilli: not installed.
- Python3: not found by `which python3`.
- Lua: not found by `which lua`.
- LuCI custom: old Lua controller/view directories do not exist, but modern LuCI custom files exist for setup and Alemprator OTA under `/usr/share/luci/menu.d/`, `/www/luci-static/resources/view/`, and `/usr/share/rpcd/acl.d/`.

## 1. ip a

```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1504 qdisc mq state UP qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
    inet6 fe80::e96:cdff:fe65:bebf/64 scope link 
       valid_lft forever preferred_lft forever
3: wan@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
4: lan@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN qlen 1000
    link/ether 0c:96:cd:65:be:bf brd ff:ff:ff:ff:ff:ff
6: phy0-ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:c0 brd ff:ff:ff:ff:ff:ff
8: phy1-ap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-lan state UP qlen 1000
    link/ether 0c:96:cd:65:be:c1 brd ff:ff:ff:ff:ff:ff
9: br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP qlen 1000
    link/ether 0c:96:cd:65:be:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.20/24 brd 192.168.1.255 scope global br-lan
       valid_lft forever preferred_lft forever
```

## 2. cat /etc/config/network

```text
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd82:5161:f958::/48'
        option packet_steering '1'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'lan1'
        list ports 'lan2'
        list ports 'lan3'
        list ports 'lan4'
        list ports 'wan'
        option ageing_time '10'
        option ipv6 '0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.1.20'
        option netmask '255.255.255.0'
        option gateway '192.168.1.1'
        list dns '8.8.8.8'
        list dns '82.114.163.31'
        option delegate '0'
        option defaultroute '1'
        option ageing_time '10'
```

## 3. cat /etc/config/dhcp

```text
config dnsmasq
        option domainneeded '1'
        option boguspriv '1'
        option filterwin2k '0'
        option localise_queries '1'
        option rebind_protection '1'
        option rebind_localhost '1'
        option local '/lan/'
        option domain 'lan'
        option expandhosts '1'
        option nonegcache '0'
        option cachesize '1000'
        option authoritative '1'
        option readethers '1'
        option leasefile '/tmp/dhcp.leases'
        option resolvfile '/tmp/resolv.conf.d/resolv.conf.auto'
        option nonwildcard '1'
        option localservice '1'
        option ednspacket_max '1232'
        option filter_aaaa '0'
        option filter_a '0'

config dhcp 'lan'
        option interface 'lan'
        option start '100'
        option limit '150'
        option leasetime '12h'
        option dhcpv4 'server'
        option dynamicdhcp '0'

config odhcpd 'odhcpd'
        option maindhcp '0'
        option leasefile '/tmp/hosts/odhcpd'
        option leasetrigger '/usr/sbin/odhcpd-update'
        option loglevel '4'
        option piofolder '/tmp/odhcpd-piofolder'
```

## 4. brctl show

```text
bridge name     bridge id               STP enabled     interfaces
br-lan          7fff.0c96cd65bec0       no              wan
                                                        phy0-ap0
                                                        phy1-ap0
```

## Internet: detected IP_MIKROTIK from default route

```text
192.168.1.1
```

## ip route

```text
default via 192.168.1.1 dev br-lan 
192.168.1.0/24 dev br-lan scope link  src 192.168.1.20 
```

## cat /etc/config/firewall

```text
config defaults
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'

config zone
        option name 'lan'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'

config zone
        option name 'wan'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'
        option masq '1'
        option mtu_fix '1'

config forwarding
        option src 'lan'
        option dest 'wan'

config rule
        option name 'Allow-DHCP-Renew'
        option src 'wan'
        option proto 'udp'
        option dest_port '68'
        option target 'ACCEPT'
        option family 'ipv4'

config rule
        option name 'Allow-Ping'
        option src 'wan'
        option proto 'icmp'
        option icmp_type 'echo-request'
        option family 'ipv4'
        option target 'ACCEPT'

config rule
        option name 'Allow-IGMP'
        option src 'wan'
        option proto 'igmp'
        option family 'ipv4'
        option target 'ACCEPT'

config rule
        option name 'Allow-DHCPv6'
        option src 'wan'
        option proto 'udp'
        option dest_port '546'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-MLD'
        option src 'wan'
        option proto 'icmp'
        option src_ip 'fe80::/10'
        list icmp_type '130/0'
        list icmp_type '131/0'
        list icmp_type '132/0'
        list icmp_type '143/0'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-ICMPv6-Input'
        option src 'wan'
        option proto 'icmp'
        list icmp_type 'echo-request'
        list icmp_type 'echo-reply'
        list icmp_type 'destination-unreachable'
        list icmp_type 'packet-too-big'
        list icmp_type 'time-exceeded'
        list icmp_type 'bad-header'
        list icmp_type 'unknown-header-type'
        list icmp_type 'router-solicitation'
        list icmp_type 'neighbour-solicitation'
        list icmp_type 'router-advertisement'
        list icmp_type 'neighbour-advertisement'
        option limit '1000/sec'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-ICMPv6-Forward'
        option src 'wan'
        option dest '*'
        option proto 'icmp'
        list icmp_type 'echo-request'
        list icmp_type 'echo-reply'
        list icmp_type 'destination-unreachable'
        list icmp_type 'packet-too-big'
        list icmp_type 'time-exceeded'
        list icmp_type 'bad-header'
        list icmp_type 'unknown-header-type'
        option limit '1000/sec'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-IPSec-ESP'
        option src 'wan'
        option dest 'lan'
        option proto 'esp'
        option target 'ACCEPT'

config rule
        option name 'Allow-ISAKMP'
        option src 'wan'
        option dest 'lan'
        option dest_port '500'
        option proto 'udp'
        option target 'ACCEPT'
```

## opkg list-installed

```text
alemprator-firstboot - 1.0-r10
base-files - 1666~29397011cc
busybox - 1.36.1-r2
ca-bundle - 20250419-r1
cgi-io - 2022.08.10~901b0f04-r21
coreutils - 9.7-r1
coreutils-sha256sum - 9.7-r1
dnsmasq - 2.90-r4
dropbear - 2024.86-r1
firewall4 - 2024.12.18~18fc0ead-r1
fstools - 2024.07.14~408c2cc4-r1
fwtool - 2019.11.12~8f7fe925-r1
getrandom - 2024.04.26~85f10530-r1
hostapd-common - 2024.09.15~5ace39b0-r2
hostapd-utils - 2024.09.15~5ace39b0-r2
iperf3 - 3.17.1-r4
iw - 6.9-r1
iwinfo - 2024.10.20~b94f066e-r1
jansson4 - 2.14-r3
jshn - 2025.07.23~49056d17-r1
jsonfilter - 2025.04.18~8a86fb78-r1
kernel - 6.6.110~30e35110c4cb7b4020c9cb9834e5e618-r1
kmod-cfg80211 - 6.6.110.6.12.52-r1
kmod-crypto-aead - 6.6.110-r1
kmod-crypto-authenc - 6.6.110-r1
kmod-crypto-ccm - 6.6.110-r1
kmod-crypto-cmac - 6.6.110-r1
kmod-crypto-crc32c - 6.6.110-r1
kmod-crypto-ctr - 6.6.110-r1
kmod-crypto-des - 6.6.110-r1
kmod-crypto-gcm - 6.6.110-r1
kmod-crypto-geniv - 6.6.110-r1
kmod-crypto-gf128 - 6.6.110-r1
kmod-crypto-ghash - 6.6.110-r1
kmod-crypto-hash - 6.6.110-r1
kmod-crypto-hmac - 6.6.110-r1
kmod-crypto-hw-eip93 - 6.6.110-r1
kmod-crypto-manager - 6.6.110-r1
kmod-crypto-md5 - 6.6.110-r1
kmod-crypto-null - 6.6.110-r1
kmod-crypto-rng - 6.6.110-r1
kmod-crypto-seqiv - 6.6.110-r1
kmod-crypto-sha1 - 6.6.110-r1
kmod-crypto-sha256 - 6.6.110-r1
kmod-crypto-sha3 - 6.6.110-r1
kmod-crypto-sha512 - 6.6.110-r1
kmod-gpio-button-hotplug - 6.6.110-r5
kmod-hwmon-core - 6.6.110-r1
kmod-ifb - 6.6.110-r1
kmod-input-core - 6.6.110-r1
kmod-input-leds - 6.6.110-r1
kmod-ipt-conntrack - 6.6.110-r1
kmod-ipt-core - 6.6.110-r1
kmod-leds-gpio - 6.6.110-r1
kmod-lib-crc-ccitt - 6.6.110-r1
kmod-lib-crc32c - 6.6.110-r1
kmod-mac80211 - 6.6.110.6.12.52-r1
kmod-mt76-connac - 6.6.110.2025.09.15~6467af3b-r1
kmod-mt76-core - 6.6.110.2025.09.15~6467af3b-r1
kmod-mt7915-firmware - 6.6.110.2025.09.15~6467af3b-r1
kmod-mt7915e - 6.6.110.2025.09.15~6467af3b-r1
kmod-mtd-rw - 6.6.110.2021.02.28~e8776739-r1
kmod-nf-conntrack - 6.6.110-r1
kmod-nf-conntrack6 - 6.6.110-r1
kmod-nf-flow - 6.6.110-r1
kmod-nf-ipt - 6.6.110-r1
kmod-nf-log - 6.6.110-r1
kmod-nf-log6 - 6.6.110-r1
kmod-nf-nat - 6.6.110-r1
kmod-nf-reject - 6.6.110-r1
kmod-nf-reject6 - 6.6.110-r1
kmod-nfnetlink - 6.6.110-r1
kmod-nft-core - 6.6.110-r1
kmod-nft-fib - 6.6.110-r1
kmod-nft-nat - 6.6.110-r1
kmod-nft-offload - 6.6.110-r1
kmod-nls-base - 6.6.110-r1
kmod-ppp - 6.6.110-r1
kmod-pppoe - 6.6.110-r1
kmod-pppox - 6.6.110-r1
kmod-slhc - 6.6.110-r1
kmod-thermal - 6.6.110-r1
libatomic1 - 13.3.0-r4
libblobmsg-json20240329 - 2025.07.23~49056d17-r1
libc - 1.2.5-r4
libcap - 2.69-r1
libevent2-7 - 2.1.12-r2
libgcc1 - 13.3.0-r4
libiperf3 - 3.17.1-r4
libiwinfo-data - 2024.10.20~b94f066e-r1
libiwinfo20230701 - 2024.10.20~b94f066e-r1
libjson-c5 - 0.18-r1
libjson-script20240329 - 2025.07.23~49056d17-r1
liblucihttp-ucode - 2023.03.15~9b5b683f-r1
liblucihttp0 - 2023.03.15~9b5b683f-r1
libmbedtls21 - 3.6.5-r1
libmnl0 - 1.0.5-r1
libnftnl11 - 1.2.8-r1
libnl-tiny1 - 2025.03.19~c0df580a-r1
libopenssl-conf - 3.0.18-r1
libopenssl3 - 3.0.18-r1
libpthread - 1.2.5-r4
librt - 1.2.5-r4
libubox20240329 - 2025.07.23~49056d17-r1
libubus20250102 - 2025.10.17~60e04048-r1
libuci20250120 - 2025.01.20~16ff0bad-r1
libuclient20201210 - 2024.10.22~88ae8f20-r1
libucode20230711 - 2025.07.18~3f64c808-r1
libudebug - 2025.08.24~edeb4d6d
libustream-mbedtls20201210 - 2024.07.28~99bd3d2b-r1
libuv1 - 1.48.0-r1
libwebsockets-full - 4.3.3-r1
lldpd - 1.0.18-r2
logd - 2024.04.26~85f10530-r1
luci - 25.292.66247~75e41cb
luci-app-alemprator-ota - 1.0-r28
luci-app-firewall - 25.292.66247~75e41cb
luci-app-lldpd - 25.292.66247~75e41cb
luci-app-package-manager - 25.292.66247~75e41cb
luci-app-setup - 1.0-r94
luci-app-ttyd - 25.292.66247~75e41cb
luci-app-watchcat - 25.292.66247~75e41cb
luci-base - 25.292.66247~75e41cb
luci-light - 25.292.66247~75e41cb
luci-mod-admin-full - 25.292.66247~75e41cb
luci-mod-network - 25.292.66247~75e41cb
luci-mod-status - 25.292.66247~75e41cb
luci-mod-system - 25.292.66247~75e41cb
luci-proto-ipv6 - 25.292.66247~75e41cb
luci-proto-ppp - 25.292.66247~75e41cb
luci-theme-bootstrap - 25.292.66247~75e41cb
mikrotik-btest - 0.5.1-r1
mtd - 26
nand-utils - 2.2.1-r1
netifd - 2025.05.23~7901e66c-r1
nftables-json - 1.1.1-r1
odhcp6c - 2024.09.25~b6ae9ffa-r1
odhcpd-ipv6only - 2025.10.02~b14cf98c-r1
openssl-util - 3.0.18-r1
openwrt-keyring - 2024.11.01~fbae29d7-r2
opkg - 2024.10.16~38eccbb1-r1
ppp - 2.5.1-r1
ppp-mod-pppoe - 2.5.1-r1
procd - 2024.12.22~42d39376-r1
procd-seccomp - 2024.12.22~42d39376-r1
procd-ujail - 2024.12.22~42d39376-r1
rpcd - 2025.09.01~bba95191-r1
rpcd-mod-file - 2025.09.01~bba95191-r1
rpcd-mod-iwinfo - 2025.09.01~bba95191-r1
rpcd-mod-luci - 20240305-r1
rpcd-mod-rrdns - 20170710
rpcd-mod-ucode - 2025.09.01~bba95191-r1
ttyd - 1.7.3-r1
ubi-utils - 2.2.1-r1
ubox - 2024.04.26~85f10530-r1
ubus - 2025.10.17~60e04048-r1
ubusd - 2025.10.17~60e04048-r1
uci - 2025.01.20~16ff0bad-r1
uclient-fetch - 2024.10.22~88ae8f20-r1
ucode - 2025.07.18~3f64c808-r1
ucode-mod-fs - 2025.07.18~3f64c808-r1
ucode-mod-html - 1
ucode-mod-math - 2025.07.18~3f64c808-r1
ucode-mod-nl80211 - 2025.07.18~3f64c808-r1
ucode-mod-rtnl - 2025.07.18~3f64c808-r1
ucode-mod-ubus - 2025.07.18~3f64c808-r1
ucode-mod-uci - 2025.07.18~3f64c808-r1
ucode-mod-uloop - 2025.07.18~3f64c808-r1
uhttpd - 2025.07.06~7e64e8ba-r4
uhttpd-mod-ubus - 2025.07.06~7e64e8ba-r4
urandom-seed - 3
urngd - 2023.11.01~44365eb1-r1
usign - 2020.05.23~f1f65026-r1
watchcat - 1-r17
wifi-scripts - 1.0-r1
wireless-regdb - 2025.07.10-r1
wpa-cli - 2024.09.15~5ace39b0-r2
wpad-basic-mbedtls - 2024.09.15~5ace39b0-r2
zlib - 1.3.1-r1
```

## CoovaChilli check

```text
CoovaChilli غير مثبت
```

## ping IP_MIKROTIK

```text
PING 192.168.1.1 (192.168.1.1): 56 data bytes

--- 192.168.1.1 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

## nc -zv IP_MIKROTIK 1812

```text
BusyBox v1.36.1 (2025-10-19 16:37:45 UTC) multi-call binary.

Usage: nc [IPADDR PORT]

Open a pipe to IP:PORT
```

## nc -zv IP_MIKROTIK 1813

```text
BusyBox v1.36.1 (2025-10-19 16:37:45 UTC) multi-call binary.

Usage: nc [IPADDR PORT]

Open a pipe to IP:PORT
```

## cat /etc/config/wireless

```text
config wifi-device 'radio0'
        option type 'mac80211'
        option path '1e140000.pcie/pci0000:00/0000:00:01.0/0000:02:00.0'
        option band '2g'
        option channel 'auto'
        option htmode 'HE20'
        option disabled '0'
        option country 'PA'
        option cell_density '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'KT-KM14-102H-2.4GHz_BEC0'
        option encryption 'none'
        option disassoc_low_ack '0'
        option disabled '0'
        option wds '1'

config wifi-device 'radio1'
        option type 'mac80211'
        option path '1e140000.pcie/pci0000:00/0000:00:01.0/0000:02:00.0+1'
        option band '5g'
        option channel '36'
        option htmode 'HE80'
        option disabled '0'
        option country 'PA'
        option cell_density '0'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'KT-KM14-102H-5GHz_BEC1'
        option encryption 'none'
        option disassoc_low_ack '0'
        option disabled '0'
        option wds '1'
```

## which python3

```text

```

## which lua

```text

```

## ubus call system board

```text
{
        "kernel": "6.6.110",
        "hostname": "KT-KM14-102H",
        "system": "MediaTek MT7621 ver:1 eco:3",
        "model": "KT KM14-102H",
        "board_name": "kt,km14-102h",
        "rootfs_type": "squashfs",
        "release": {
                "distribution": "OpenWrt",
                "version": "24.10.4",
                "revision": "r28959-29397011cc",
                "target": "ramips/mt7621",
                "description": "OpenWrt 24.10.4 r28959-29397011cc",
                "builddate": "1760891865"
        }
}
```

## ls /usr/lib/lua/luci/controller/

```text
ls: /usr/lib/lua/luci/controller/: No such file or directory
```

## ls /usr/lib/lua/luci/view/

```text
ls: /usr/lib/lua/luci/view/: No such file or directory
```

## Extra internet/NAT/PPPoE verification

### ping 1.1.1.1

```text
PING 1.1.1.1 (1.1.1.1): 56 data bytes

--- 1.1.1.1 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

### ping 8.8.8.8

```text
PING 8.8.8.8 (8.8.8.8): 56 data bytes

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

### ping ota.kartnet.org

```text
ping: bad address 'ota.kartnet.org'
```

### uci show network | grep -i ppp

```text

```

### ip link show | grep -i ppp

```text

```

### nft list ruleset | grep -Ei 'masquerade|snat|pppoe'

```text
                meta nfproto ipv4 masquerade comment "!fw4: Masquerade IPv4 wan traffic"
```

### uci show firewall | grep -Ei 'masq|network|zone|forwarding'

```text
firewall.@zone[0]=zone
firewall.@zone[0].name='lan'
firewall.@zone[0].input='ACCEPT'
firewall.@zone[0].output='ACCEPT'
firewall.@zone[0].forward='ACCEPT'
firewall.@zone[1]=zone
firewall.@zone[1].name='wan'
firewall.@zone[1].input='ACCEPT'
firewall.@zone[1].output='ACCEPT'
firewall.@zone[1].forward='ACCEPT'
firewall.@zone[1].masq='1'
firewall.@zone[1].mtu_fix='1'
firewall.@forwarding[0]=forwarding
firewall.@forwarding[0].src='lan'
firewall.@forwarding[0].dest='wan'
```

## Extra LuCI custom verification

### ls /usr/share/luci/menu.d/

```text
luci-app-alemprator-ota.json
luci-app-firewall.json
luci-app-lldpd.json
luci-app-package-manager.json
luci-app-ttyd.json
luci-app-watchcat.json
luci-base.json
luci-mod-network.json
luci-mod-status.json
luci-mod-system.json
zzz-luci-app-setup.json
```

### find /www/luci-static/resources/view -maxdepth 4 -type f | grep -Ei 'setup|ota|alemprator'

```text
/www/luci-static/resources/view/setup/landing.js
/www/luci-static/resources/view/setup/landing_r2.js
/www/luci-static/resources/view/setup/setup.js
/www/luci-static/resources/view/setup/setup_r93.js
/www/luci-static/resources/view/system/ota.js
/www/luci-static/resources/view/system/ota_v2.js
```

### find /usr/share/rpcd/acl.d -maxdepth 1 -type f | grep -Ei 'setup|ota|alemprator'

```text
/usr/share/rpcd/acl.d/luci-app-alemprator-ota.json
/usr/share/rpcd/acl.d/luci-app-setup.json
```

## 2026-05-05 Hotspot post-login NAT and portal flow fix

- RADIUS was not the failure point: CoovaChilli logged `Successful UAM login from username=101202735 IP=192.168.10.10`, and `chilli_query` showed client `36-5D-F3-EF-19-25` / `192.168.10.10` in `pass` state.
- The browser loop happened because the authenticated session had `userurl` set to `http://192.168.10.1/`, returning the client to the router/portal after login.
- `/www/hotspot/terms.html` and the package source now preserve `location.search` when continuing to `login.html`.
- `/www/hotspot/login.html` and the package source now use `http://connectivitycheck.gstatic.com/generate_204` as the fallback `userurl` instead of `http://192.168.10.1/`.
- Client internet forwarding was missing NAT for hotspot traffic exiting through `br-lan`. `firewall lan` is now bound to network `lan` and has `masq='1'` / `mtu_fix='1'`, producing `srcnat_lan` masquerade in firewall4.
- The live router was updated directly, the current client was logged out for a clean retest, and `luci-app-hotspot-openwrt_1.0-r1_mipsel_24kc.ipk` was rebuilt successfully.
- A later mobile test showed `DNS_PROBE_FINISHED_NO_INTERNET` on `neverssl.com` while the client was still in Chilli `dnat` state. Chilli had been handing out external DNS servers (`8.8.8.8`, `82.114.163.31`) even though pre-auth DNS to the local gateway is the reliable path.
- Chilli now hands out and forces DNS through `192.168.10.1`: `dns1`, `dns2`, `forcedns1`, and `forcedns2` are all set to the hotspot gateway with port `53`. Router-side `nslookup neverssl.com 192.168.10.1` succeeds.
