#!/bin/sh
# This script is called by fw4 to inject custom NFT rules
# Uses nft only — no iptables required.

# ── MAC Sets ────────────────────────────────────────────────────────────────
# hotspot_blocked_mac : MACs that must be denied all access (IP Binding type=blocked)
# hotspot_bypass_mac  : MACs that bypass the captive portal entirely (type=bypassed)

nft "add set inet fw4 hotspot_blocked_mac { type ether_addr; flags interval; }" 2>/dev/null || true
nft "add set inet fw4 hotspot_bypass_mac  { type ether_addr; flags interval; }" 2>/dev/null || true

# Chilli clients leave through tun0/tun1, not br-hotspot/br-hotspot2. Put the
# allow and NAT rules inside fw4's own chains so later fw4 base chains cannot
# reject traffic after our custom hook accepted it.
HOTSPOT_IP="$(uci -q get hotspot_openwrt.main.hotspot_ip)"
HOTSPOT_CIDR="$(uci -q get hotspot_openwrt.main.hotspot_cidr)"
SECONDARY_HOTSPOT_IP="$(uci -q get hotspot_openwrt.main.quick_gateway_secondary)"
WAN_INTERFACE="$(uci -q get hotspot_openwrt.main.wan_interface)"
[ -n "$HOTSPOT_IP" ] || HOTSPOT_IP='192.168.10.1'
[ -n "$HOTSPOT_CIDR" ] || HOTSPOT_CIDR='24'
[ -n "$SECONDARY_HOTSPOT_IP" ] || SECONDARY_HOTSPOT_IP='192.168.20.1'
[ -n "$WAN_INTERFACE" ] || WAN_INTERFACE='lan'
EGRESS_DEVICE="$(uci -q get network.$WAN_INTERFACE.device)"
[ -n "$EGRESS_DEVICE" ] || EGRESS_DEVICE="br-$WAN_INTERFACE"
HOTSPOT_NET=''
SECONDARY_HOTSPOT_NET=''
if CALC_OUTPUT="$(/bin/ipcalc.sh "$HOTSPOT_IP/$HOTSPOT_CIDR" 2>/dev/null)"; then
	eval "$CALC_OUTPUT"
	HOTSPOT_NET="$NETWORK"
fi
if CALC_OUTPUT="$(/bin/ipcalc.sh "$SECONDARY_HOTSPOT_IP/$HOTSPOT_CIDR" 2>/dev/null)"; then
	eval "$CALC_OUTPUT"
	SECONDARY_HOTSPOT_NET="$NETWORK"
fi
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
if [ "$COA_ENABLED" = '1' ] && [ -n "$RADIUS_SERVER" ]; then
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
