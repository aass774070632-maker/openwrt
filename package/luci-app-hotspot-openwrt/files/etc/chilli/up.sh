#!/bin/sh
# CoovaChilli TUN-up hook — nft only (no iptables)
# Called by chilli as ipup when tun0 is brought up.

valid_mac() {
	case "$1" in
		*[!0-9a-fA-F:]*) return 1 ;;
	esac
	printf '%s' "$1" | awk -F: 'NF == 6 { for (i = 1; i <= 6; i++) if (length($i) != 2) exit 1; exit 0 } { exit 1 }'
}

# Ensure the hotspot nft sets exist (fw4 include may not have run yet)
nft add table inet fw4 2>/dev/null || true
nft "add set inet fw4 hotspot_blocked_mac { type ether_addr; flags interval; }" 2>/dev/null || true
nft "add set inet fw4 hotspot_bypass_mac  { type ether_addr; flags interval; }" 2>/dev/null || true

# Flush and re-populate blocked/bypass sets from UCI
nft "flush set inet fw4 hotspot_blocked_mac" 2>/dev/null || true
nft "flush set inet fw4 hotspot_bypass_mac"  2>/dev/null || true

# uci show produces indexed lines: hotspot_openwrt.main.ip_binding[N]='type mac comment'
# Strip the key prefix and quotes, leaving one entry per line.
uci -q show hotspot_openwrt.main.ip_binding 2>/dev/null | \
	sed "s/^.*='//;s/'$//" | \
	while IFS= read -r entry; do
	[ -n "$entry" ] || continue
	type="$(printf '%s' "$entry" | awk '{print tolower($1)}')"
	mac="$(printf '%s' "$entry" | awk '{print tolower($2)}' | tr '-' ':')"
	[ -n "$mac" ] || continue
	valid_mac "$mac" || continue
	case "$type" in
		blocked)  nft "add element inet fw4 hotspot_blocked_mac { $mac }" 2>/dev/null || true ;;
		bypassed) nft "add element inet fw4 hotspot_bypass_mac  { $mac }" 2>/dev/null || true ;;
	esac
done

exit 0
