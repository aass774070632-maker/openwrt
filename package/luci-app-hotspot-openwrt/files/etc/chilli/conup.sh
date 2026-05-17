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
[ "$BW_UP" -gt 0 ] || [ "$BW_DOWN" -gt 0 ] || exit 0

# Map IP last octet to a unique handle (1-254)
HANDLE="$(printf '%s' "$CLIENT_IP" | awk -F. '{v=$4+0; if(v<1)v=1; if(v>254)v=254; print v}')"

# Egress (upload) shaping on tun0 — limit packets FROM client going out
if [ "$BW_UP" -gt 0 ]; then
	tc class add dev "$TUNDEV" parent 1:0 classid "1:$HANDLE" htb rate "${BW_UP}bit" burst 10k 2>/dev/null || \
	tc class change dev "$TUNDEV" parent 1:0 classid "1:$HANDLE" htb rate "${BW_UP}bit" burst 10k 2>/dev/null || true
	tc filter add dev "$TUNDEV" parent 1:0 protocol ip prio "$HANDLE" u32 match ip src "$CLIENT_IP/32" flowid "1:$HANDLE" 2>/dev/null || true
fi

# Ingress (download) shaping via IFB — limit packets TO client coming in
IFB="ifb0"
if ip link show "$IFB" >/dev/null 2>&1 && [ "$BW_DOWN" -gt 0 ]; then
	tc class add dev "$IFB" parent 1:0 classid "1:$HANDLE" htb rate "${BW_DOWN}bit" burst 10k 2>/dev/null || \
	tc class change dev "$IFB" parent 1:0 classid "1:$HANDLE" htb rate "${BW_DOWN}bit" burst 10k 2>/dev/null || true
	tc filter add dev "$IFB" parent 1:0 protocol ip prio "$HANDLE" u32 match ip dst "$CLIENT_IP/32" flowid "1:$HANDLE" 2>/dev/null || true
fi

exit 0
