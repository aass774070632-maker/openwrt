#!/bin/sh
# This script is called by fw4 to inject custom NFT rules
# Uses nft only — no iptables required.

# ── MAC Sets ────────────────────────────────────────────────────────────────
# hotspot_blocked_mac : MACs that must be denied all access (IP Binding type=blocked)
# hotspot_bypass_mac  : MACs that bypass the captive portal entirely (type=bypassed)

nft "add set inet fw4 hotspot_blocked_mac { type ether_addr; flags interval; }" 2>/dev/null || true
nft "add set inet fw4 hotspot_bypass_mac  { type ether_addr; flags interval; }" 2>/dev/null || true

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
# Allow UDP 3799 from the RADIUS server so CoA-Disconnect messages reach Chilli.
RADIUS_SERVER="$(uci -q get hotspot_openwrt.main.radius_server)"
COA_ENABLED="$(uci -q get hotspot_openwrt.main.coa_enabled)"
if [ "$COA_ENABLED" = '1' ] && [ -n "$RADIUS_SERVER" ]; then
	nft "add chain inet fw4 hotspot_coa_input { type filter hook input priority 0; policy accept; }" 2>/dev/null || true
	nft "flush chain inet fw4 hotspot_coa_input" 2>/dev/null || true
	nft "add rule inet fw4 hotspot_coa_input ip saddr $RADIUS_SERVER udp dport 3799 counter accept" 2>/dev/null || true
fi

exit 0
