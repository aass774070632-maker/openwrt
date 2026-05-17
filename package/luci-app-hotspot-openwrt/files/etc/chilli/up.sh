#!/bin/sh
# CoovaChilli TUN-up hook — nft only (no iptables)
# Called by chilli as ipup when tun0 is brought up.

# Ensure the hotspot nft sets exist (fw4 include may not have run yet)
nft add table inet fw4 2>/dev/null || true
nft "add set inet fw4 hotspot_blocked_mac { type ether_addr; flags interval; }" 2>/dev/null || true
nft "add set inet fw4 hotspot_bypass_mac  { type ether_addr; flags interval; }" 2>/dev/null || true

# Flush and re-populate blocked/bypass sets from UCI
nft "flush set inet fw4 hotspot_blocked_mac" 2>/dev/null || true
nft "flush set inet fw4 hotspot_bypass_mac"  2>/dev/null || true

for entry in $(uci -q get hotspot_openwrt.main.ip_binding 2>/dev/null); do
	type="$(printf '%s' "$entry" | awk '{print tolower($1)}')"
	mac="$(printf '%s' "$entry" | awk '{print tolower($2)}' | tr '-' ':')"
	case "$type" in
		blocked)  nft "add element inet fw4 hotspot_blocked_mac { $mac }" 2>/dev/null || true ;;
		bypassed) nft "add element inet fw4 hotspot_bypass_mac  { $mac }" 2>/dev/null || true ;;
	esac
done

exit 0
