#!/bin/sh

# Namespace and interface names
NS1="hs1"
NS2="hs2"
VETH1_H="veth1_h"
VETH1_N="eth0"
VETH2_H="veth2_h"
VETH2_N="eth0"
BR1="br-hotspot"
BR2="br-hotspot2"

# Result variables
ns1_dhcp_ok=0; ns1_ip=""; ns1_gw=""; ns1_http_code=0
ns2_dhcp_ok=0; ns2_ip=""; ns2_gw=""; ns2_http_code=0
chilli_primary_clients=0; chilli_secondary_clients=0
overall_ok=0

cleanup() {
    ip netns exec $NS1 ip link delete $VETH1_N 2>/dev/null
    ip netns exec $NS2 ip link delete $VETH2_N 2>/dev/null
    ip netns del $NS1 2>/dev/null
    ip netns del $NS2 2>/dev/null
    ip link delete $VETH1_H 2>/dev/null
    ip link delete $VETH2_H 2>/dev/null
}

cleanup
ip netns add $NS1
ip netns add $NS2

ip link add $VETH1_H type veth peer name $VETH1_N
ip link set $VETH1_N netns $NS1
ip link set $VETH1_H master $BR1
ip link set $VETH1_H up
ip netns exec $NS1 ip link set lo up
ip netns exec $NS1 ip link set $VETH1_N up

ip link add $VETH2_H type veth peer name $VETH2_N
ip link set $VETH2_N netns $NS2
ip link set $VETH2_H master $BR2
ip link set $VETH2_H up
ip netns exec $NS2 ip link set lo up
ip netns exec $NS2 ip link set $VETH2_N up

# DHCP for NS1
ip netns exec $NS1 udhcpc -i eth0 -n -q -t 5 -T 2 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ns1_dhcp_ok=1
    ns1_ip=$(ip netns exec $NS1 ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    ns1_gw=$(ip netns exec $NS1 ip route show dev eth0 | grep default | awk '{print $3}')
    ns1_http_code=$(ip netns exec $NS1 curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://neverssl.com)
fi

# DHCP for NS2
ip netns exec $NS2 udhcpc -i eth0 -n -q -t 5 -T 2 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ns2_dhcp_ok=1
    ns2_ip=$(ip netns exec $NS2 ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    ns2_gw=$(ip netns exec $NS2 ip route show dev eth0 | grep default | awk '{print $3}')
    ns2_http_code=$(ip netns exec $NS2 curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://neverssl.com)
fi

# Query Chilli
if [ -e /var/run/chilli_hotspot_openwrt.sock ]; then
    chilli_primary_clients=$(chilli_query -s /var/run/chilli_hotspot_openwrt.sock list | wc -l)
fi
if [ -e /var/run/chilli_hotspot_openwrt_secondary.sock ]; then
    chilli_secondary_clients=$(chilli_query -s /var/run/chilli_hotspot_openwrt_secondary.sock list | wc -l)
fi

if [ "$ns1_dhcp_ok" -eq 1 ] && [ "$ns2_dhcp_ok" -eq 1 ]; then
    overall_ok=1
fi

echo "ns1_dhcp_ok=$ns1_dhcp_ok"
echo "ns1_ip=$ns1_ip"
echo "ns1_gw=$ns1_gw"
echo "ns1_http_code=$ns1_http_code"
echo "ns2_dhcp_ok=$ns2_dhcp_ok"
echo "ns2_ip=$ns2_ip"
echo "ns2_gw=$ns2_gw"
echo "ns2_http_code=$ns2_http_code"
echo "chilli_primary_clients=$chilli_primary_clients"
echo "chilli_secondary_clients=$chilli_secondary_clients"
echo "overall_ok=$overall_ok"

cleanup
