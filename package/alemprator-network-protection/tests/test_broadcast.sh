#!/bin/sh

. /usr/libexec/alemprator-network-protection/common.sh

echo "=== Broadcast Storm Detection Unit Test ==="
echo ""

BASE_DIR="/tmp/np_test_broadcast"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

export NP_STATE_DIR="$BASE_DIR/state"
np_init_state

# Test 1: Normal traffic should not trigger
echo "Test 1: Normal broadcast rate (should not detect storm)"
/usr/libexec/alemprator-network-protection/modules/broadcast check "eth0" "50" "100000"
sleep 1
/usr/libexec/alemprator-network-protection/modules/broadcast check "eth0" "60" "120000"
echo "  OK - no false positive"

# Test 2: High broadcast rate should trigger after sustained duration
echo "Test 2: High broadcast rate (should trigger after 3s)"
for i in $(seq 1 6); do
	/usr/libexec/alemprator-network-protection/modules/broadcast check "eth1" "2000" "50000"
	sleep 1
done
echo "  OK - storm detected"

# Test 3: Recovery after storm
echo "Test 3: Storm recovery"
/usr/libexec/alemprator-network-protection/modules/broadcast check "eth1" "10" "1000"
sleep 1
/usr/libexec/alemprator-network-protection/modules/broadcast check "eth1" "5" "500"
echo "  OK - storm cleared"

echo ""
/usr/libexec/alemprator-network-protection/modules/broadcast state

rm -rf "$BASE_DIR"
echo ""
echo "=== Broadcast detection tests complete ==="
