#!/bin/sh
# CoovaChilli session-up hook — apply per-session tc rate limiting
# Called by chilli as conup when a client is authenticated (state: pass).
#
# Environment variables provided by CoovaChilli:
#   SESSION_DHCPIP          — client IP address
#   SESSION_DHCPMAC         — client MAC address (colon-separated)
#   SESSION_BANDWIDTHMAXUP  — max upload bps (from WISPr-Bandwidth-Max-Up)
#   SESSION_BANDWIDTHMAXDOWN— max download bps (from WISPr-Bandwidth-Max-Down)
#   HS_TUNDEV               — TUN device name (default tun0)

TUNDEV="${HS_TUNDEV:-tun0}"
CLIENT_IP="${SESSION_DHCPIP}"
BW_UP="${SESSION_BANDWIDTHMAXUP:-0}"
BW_DOWN="${SESSION_BANDWIDTHMAXDOWN:-0}"

[ -n "$CLIENT_IP" ] || exit 0

# Determine the bridge interface for this chilli instance
case "$TUNDEV" in
	tun0) BRIDGE="br-hotspot" ;;
	tun1) BRIDGE="br-hotspot2" ;;
	*)    BRIDGE="" ;;
esac

# Add iptables ACCEPT rules for this authorized client to bypass
# chilli's blanket DROP on the bridge interface.
if [ -n "$BRIDGE" ]; then
	# Insert at position 1 (before DROP rules)
	iptables -I FORWARD 1 -i "$BRIDGE" -s "$CLIENT_IP" -j ACCEPT 2>/dev/null || true
	iptables -I FORWARD 1 -o "$BRIDGE" -d "$CLIENT_IP" -j ACCEPT 2>/dev/null || true
fi

# Also add to nftables authorized set (bypasses NAT redirect hotspot_nat_redirect)
nft add element inet fw4 hotspot_authorized { $CLIENT_IP timeout 8h } 2>/dev/null || true

# ----------------------------------------------------------------------
# One-time setup (idempotent) — create root HTB qdisc on tun0 and ifb0
# ----------------------------------------------------------------------

[ "$BW_UP" -gt 0 ] || [ "$BW_DOWN" -gt 0 ] || exit 0

# Root qdisc for egress shaping on tun0
tc qdisc add dev "$TUNDEV" root handle 1: htb default 30 2>/dev/null || true

# Ingress redirect — mirror tunnel ingress to ifb0 for download shaping
IFB="ifb0"
if ! ip link show "$IFB" >/dev/null 2>&1; then
	modprobe ifb 2>/dev/null || true
	ip link add "$IFB" type ifb 2>/dev/null || true
fi
if ip link show "$IFB" >/dev/null 2>&1; then
	ip link set dev "$IFB" up 2>/dev/null || true
	tc qdisc add dev "$IFB" root handle 1: htb default 30 2>/dev/null || true
	# Redirect ingress traffic from tun0 to ifb0
	tc qdisc add dev "$TUNDEV" ingress 2>/dev/null || true
	tc filter add dev "$TUNDEV" parent ffff: protocol ip u32 match u32 0 0 \
		action mirred egress redirect dev "$IFB" 2>/dev/null || true
fi

# ----------------------------------------------------------------------
# Derive a unique tc handle from all 4 octets (XOR fold into 1-4094 range).
# This avoids collisions when clients share the same last octet across subnets.
# ----------------------------------------------------------------------
HANDLE="$(printf '%s' "$CLIENT_IP" | awk -F. '{v=(($1+0)*($2+0+1)*($3+0+1)*($4+0+1))%4094+1; print v}')"

# Egress (upload) shaping on tun0 — limit packets FROM client going out
if [ "$BW_UP" -gt 0 ]; then
	tc class add dev "$TUNDEV" parent 1:0 classid "1:$HANDLE" htb rate "${BW_UP}bit" burst 10k 2>/dev/null || \
	tc class change dev "$TUNDEV" parent 1:0 classid "1:$HANDLE" htb rate "${BW_UP}bit" burst 10k 2>/dev/null || true
	tc filter add dev "$TUNDEV" parent 1:0 protocol ip prio "$HANDLE" u32 match ip src "$CLIENT_IP/32" flowid "1:$HANDLE" 2>/dev/null || true
fi

# Ingress (download) shaping via IFB — limit packets TO client coming in
if ip link show "$IFB" >/dev/null 2>&1 && [ "$BW_DOWN" -gt 0 ]; then
	tc class add dev "$IFB" parent 1:0 classid "1:$HANDLE" htb rate "${BW_DOWN}bit" burst 10k 2>/dev/null || \
	tc class change dev "$IFB" parent 1:0 classid "1:$HANDLE" htb rate "${BW_DOWN}bit" burst 10k 2>/dev/null || true
	tc filter add dev "$IFB" parent 1:0 protocol ip prio "$HANDLE" u32 match ip dst "$CLIENT_IP/32" flowid "1:$HANDLE" 2>/dev/null || true
fi

exit 0
