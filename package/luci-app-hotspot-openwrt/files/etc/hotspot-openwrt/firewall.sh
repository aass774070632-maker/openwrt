#!/bin/sh
# This script is called by fw4 to inject custom NFT rules
# Uses nft only — no iptables required.

# ── MAC Sets ────────────────────────────────────────────────────────────────
# hotspot_blocked_mac : MACs that must be denied all access (IP Binding type=blocked)
# hotspot_bypass_mac  : MACs that bypass the captive portal entirely (type=bypassed)

nft "add set inet fw4 hotspot_blocked_mac { type ether_addr; flags interval; }" 2>/dev/null || true
nft "add set inet fw4 hotspot_bypass_mac  { type ether_addr; flags interval; }" 2>/dev/null || true

# ── Input validators (prevent nft rule injection via raw UCI values) ────────
valid_ipv4() {
	case "$1" in ''|*[!0-9.]*) return 1 ;; esac
	printf '%s' "$1" | awk -F. 'NF == 4 { for (i = 1; i <= 4; i++) if ($i == "" || $i < 0 || $i > 255) exit 1; exit 0 } { exit 1 }'
}

valid_cidr() {
	case "$1" in ''|*[!0-9]*) return 1 ;; esac
	[ "$1" -ge 0 ] 2>/dev/null && [ "$1" -le 32 ] 2>/dev/null
}

# Parse NETWORK from ipcalc.sh output without eval (prevents command injection).
ipcalc_network() {
	/bin/ipcalc.sh "$1/$2" 2>/dev/null | awk -F= '$1 == "NETWORK" { print $2 }'
}

# Chilli clients leave through tun0/tun1, not br-hotspot/br-hotspot2. Put the
# allow and NAT rules inside fw4's own chains so later fw4 base chains cannot
# reject traffic after our custom hook accepted it.
HOTSPOT_IP="$(uci -q get hotspot_openwrt.main.hotspot_ip)"
HOTSPOT_CIDR="$(uci -q get hotspot_openwrt.main.hotspot_cidr)"
SECONDARY_HOTSPOT_IP="$(uci -q get hotspot_openwrt.main.quick_gateway_secondary)"
QUICK_SETUP_ENABLED="$(uci -q get hotspot_openwrt.main.quick_setup_enabled)"
if [ "$QUICK_SETUP_ENABLED" = '1' ]; then
	WAN_INTERFACE="$(uci -q get hotspot_openwrt.main.quick_wan_interface)"
else
	WAN_INTERFACE="$(uci -q get hotspot_openwrt.main.wan_interface)"
fi
[ -n "$HOTSPOT_IP" ] || HOTSPOT_IP='192.168.10.1'
[ -n "$HOTSPOT_CIDR" ] || HOTSPOT_CIDR='24'
[ -n "$SECONDARY_HOTSPOT_IP" ] || SECONDARY_HOTSPOT_IP='192.168.20.1'
[ -n "$WAN_INTERFACE" ] || WAN_INTERFACE='lan'
# Validate before injecting into nft rules; fall back to safe defaults.
valid_ipv4 "$HOTSPOT_IP" || HOTSPOT_IP='192.168.10.1'
valid_cidr "$HOTSPOT_CIDR" || HOTSPOT_CIDR='24'
valid_ipv4 "$SECONDARY_HOTSPOT_IP" || SECONDARY_HOTSPOT_IP='192.168.20.1'
EGRESS_DEVICE="$(uci -q get network.$WAN_INTERFACE.device)"
[ -n "$EGRESS_DEVICE" ] || EGRESS_DEVICE="br-$WAN_INTERFACE"
HOTSPOT_NET="$(ipcalc_network "$HOTSPOT_IP" "$HOTSPOT_CIDR")"
SECONDARY_HOTSPOT_NET="$(ipcalc_network "$SECONDARY_HOTSPOT_IP" "$HOTSPOT_CIDR")"
[ -n "$HOTSPOT_NET" ] || HOTSPOT_NET='192.168.10.0'
[ -n "$SECONDARY_HOTSPOT_NET" ] || SECONDARY_HOTSPOT_NET='192.168.20.0'

nft "add chain inet fw4 hotspot_openwrt_tun_forward" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_openwrt_tun_forward" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"tun0\" oifname \"$EGRESS_DEVICE\" counter accept" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"$EGRESS_DEVICE\" oifname \"tun0\" counter accept" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"tun1\" oifname \"$EGRESS_DEVICE\" counter accept" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"$EGRESS_DEVICE\" oifname \"tun1\" counter accept" 2>/dev/null || true

# MSS Clamping to prevent fragmentation issues on tuned MTU
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"tun0\" tcp flags syn tcp option maxseg size set rt mtu counter" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_forward iifname \"tun1\" tcp flags syn tcp option maxseg size set rt mtu counter" 2>/dev/null || true

nft -a list chain inet fw4 forward 2>/dev/null | grep -q 'jump hotspot_openwrt_tun_forward' || \
	nft "insert rule inet fw4 forward jump hotspot_openwrt_tun_forward comment \"hotspot-openwrt tun forward\"" 2>/dev/null || true

nft "add chain inet fw4 hotspot_openwrt_tun_srcnat" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_openwrt_tun_srcnat" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_srcnat ip saddr $HOTSPOT_NET/$HOTSPOT_CIDR counter masquerade" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_srcnat ip saddr $SECONDARY_HOTSPOT_NET/$HOTSPOT_CIDR counter masquerade" 2>/dev/null || true
nft -a list chain inet fw4 srcnat 2>/dev/null | grep -q 'jump hotspot_openwrt_tun_srcnat' || \
	nft "insert rule inet fw4 srcnat jump hotspot_openwrt_tun_srcnat comment \"hotspot-openwrt tun srcnat\"" 2>/dev/null || true

nft "add chain inet fw4 hotspot_openwrt_tun_input" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_openwrt_tun_input" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_input iifname \"tun0\" counter accept" 2>/dev/null || true
nft "add rule inet fw4 hotspot_openwrt_tun_input iifname \"tun1\" counter accept" 2>/dev/null || true
nft -a list chain inet fw4 input 2>/dev/null | grep -q 'jump hotspot_openwrt_tun_input' || \
        nft "insert rule inet fw4 input jump hotspot_openwrt_tun_input comment \"hotspot-openwrt tun input\"" 2>/dev/null || true

# ── Blocked-MAC enforcement chain ───────────────────────────────────────────
nft "add chain inet fw4 hotspot_mac_acl" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_mac_acl" 2>/dev/null || true
# Drop packets from blocked MACs before they even reach Chilli
nft "add rule inet fw4 hotspot_mac_acl ether saddr @hotspot_blocked_mac counter drop" 2>/dev/null || true

# Hook the MAC ACL chain into the forward hook (priority -200 so it runs first)
nft "add chain inet fw4 hotspot_mac_acl_hook { type filter hook forward priority -200; policy accept; }" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_mac_acl_hook" 2>/dev/null || true
nft "add rule inet fw4 hotspot_mac_acl_hook ether saddr @hotspot_blocked_mac counter drop" 2>/dev/null || true

# ── CoA / Disconnect-Message (RFC 3576) ─────────────────────────────────────
# Allow CoA UDP from the RADIUS server so CoA-Disconnect messages reach Chilli.
RADIUS_SERVER="$(uci -q get hotspot_openwrt.main.radius_server)"
COA_ENABLED="$(uci -q get hotspot_openwrt.main.coa_enabled)"
COA_PORT="$(uci -q get hotspot_openwrt.main.coa_port)"
[ -n "$COA_PORT" ] || COA_PORT='3799'
case "$COA_PORT" in ''|*[!0-9]*) COA_PORT='3799' ;; esac
[ "$COA_PORT" -ge 1 ] 2>/dev/null && [ "$COA_PORT" -le 65535 ] 2>/dev/null || COA_PORT='3799'
if [ "$COA_ENABLED" = '1' ] && [ -n "$RADIUS_SERVER" ] && valid_ipv4 "$RADIUS_SERVER"; then
	nft "add chain inet fw4 hotspot_coa_input { type filter hook input priority 0; policy accept; }" 2>/dev/null || true
	nft "flush chain inet fw4 hotspot_coa_input" 2>/dev/null || true
	nft "add rule inet fw4 hotspot_coa_input ip saddr $RADIUS_SERVER udp dport $COA_PORT counter accept" 2>/dev/null || true
fi

# ── Performance: MSS Clamping for Tun0/Tun1 ──────────────────────────────────
# Prevents fragmentation issues over the tunnel MTU.
nft "add chain inet fw4 hotspot_postrouting { type filter hook postrouting priority 300; policy accept; }" 2>/dev/null || true
nft "flush chain inet fw4 hotspot_postrouting" 2>/dev/null || true
nft "add rule inet fw4 hotspot_postrouting oifname \"tun*\" tcp flags syn tcp option maxseg size set rt mtu" 2>/dev/null || true

exit 0
