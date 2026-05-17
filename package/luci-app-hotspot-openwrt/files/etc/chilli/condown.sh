#!/bin/sh
# CoovaChilli session-down hook — remove per-session tc rate limiting
# Called by chilli as condown when a client session ends.

TUNDEV="${HS_TUNDEV:-tun0}"
CLIENT_IP="${SESSION_DHCPIP}"

[ -n "$CLIENT_IP" ] || exit 0

HANDLE="$(printf '%s' "$CLIENT_IP" | awk -F. '{v=(($1+0)*($2+0+1)*($3+0+1)*($4+0+1))%4094+1; print v}')"

# Remove egress filter and class
tc filter del dev "$TUNDEV" parent 1:0 prio "$HANDLE" 2>/dev/null || true
tc class del dev "$TUNDEV" classid "1:$HANDLE" 2>/dev/null || true

# Remove ingress filter and class from IFB
IFB="ifb0"
if ip link show "$IFB" >/dev/null 2>&1; then
	tc filter del dev "$IFB" parent 1:0 prio "$HANDLE" 2>/dev/null || true
	tc class del dev "$IFB" classid "1:$HANDLE" 2>/dev/null || true
fi

exit 0
