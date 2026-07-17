#!/bin/sh

. /usr/libexec/alemprator-network-protection/common.sh

echo "=== MAC Flapping Detection Unit Test ==="
echo ""

BASE_DIR="/tmp/np_test_mflap"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

export NP_STATE_DIR="$BASE_DIR/state"
np_init_state

# Test 1: Stable MAC should not trigger
echo "Test 1: Stable MAC on same port"
for i in $(seq 1 20); do
	/usr/libexec/alemprator-network-protection/modules/mac-flapping check "br-test" "eth0" "00:11:22:33:44:55"
done
echo "  OK - no false positive for stable MAC"

# Test 2: MAC flapping between ports
echo "Test 2: MAC flapping between ports"
for i in $(seq 1 15); do
	port="eth$((i % 3))"
	/usr/libexec/alemprator-network-protection/modules/mac-flapping check "br-test" "$port" "AA:BB:CC:DD:EE:FF"
done
echo "  OK - flapping detected"

echo ""
/usr/libexec/alemprator-network-protection/modules/mac-flapping state

rm -rf "$BASE_DIR"
echo ""
echo "=== MAC flapping tests complete ==="
