#!/bin/sh
# CoovaChilli session-down hook — remove per-session tc rate limiting
# Called by chilli as condown when a client session ends.

TUNDEV="${HS_TUNDEV:-tun0}"
CLIENT_IP="${SESSION_DHCPIP}"

[ -n "$CLIENT_IP" ] || exit 0

# Determine the bridge interface for this chilli instance
case "$TUNDEV" in
	tun0) BRIDGE="br-hotspot" ;;
	tun1) BRIDGE="br-hotspot2" ;;
	*)    BRIDGE="" ;;
esac

# Remove iptables ACCEPT rules for this client
if [ -n "$BRIDGE" ]; then
	iptables -D FORWARD -i "$BRIDGE" -s "$CLIENT_IP" -j ACCEPT 2>/dev/null || true
	iptables -D FORWARD -o "$BRIDGE" -d "$CLIENT_IP" -j ACCEPT 2>/dev/null || true
fi

# Remove from nftables authorized set (best-effort, may have expired)
nft delete element inet fw4 hotspot_authorized { $CLIENT_IP } 2>/dev/null || true

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
