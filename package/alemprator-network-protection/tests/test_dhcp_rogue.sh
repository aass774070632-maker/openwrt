#!/bin/sh

. /usr/libexec/alemprator-network-protection/common.sh

echo "=== DHCP Rogue Detection Unit Test ==="
echo ""

BASE_DIR="/tmp/np_test_dhcp"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

export NP_STATE_DIR="$BASE_DIR/state"
np_init_state

# Test 1: Trusted server should not trigger
echo "Test 1: Trusted DHCP server"
/usr/libexec/alemprator-network-protection/modules/dhcp-rogue check "DHCPOFFER SRC=00:11:22:33:44:55"
echo "  OK - trusted servers loaded from config"

# Test 2: Unknown server should trigger
echo "Test 2: Unknown DHCP server"
/usr/libexec/alemprator-network-protection/modules/dhcp-rogue check "DHCPOFFER SRC=DE:AD:BE:EF:00:01"
/usr/libexec/alemprator-network-protection/modules/dhcp-rogue check "DHCPACK SRC=DE:AD:BE:EF:00:01"
echo "  OK - rogue server flagged"

echo ""
/usr/libexec/alemprator-network-protection/modules/dhcp-rogue state

rm -rf "$BASE_DIR"
echo ""
echo "=== DHCP rogue tests complete ==="
