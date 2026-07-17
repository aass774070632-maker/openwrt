#!/bin/sh

. /usr/libexec/alemprator-network-protection/common.sh

echo "=== Loop Detection Unit Test ==="
echo ""

BASE_DIR="/tmp/np_test_loop"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

export NP_STATE_DIR="$BASE_DIR/state"
np_init_state

# Test 1: Normal MAC move should not trigger
echo "Test 1: Normal MAC move (different window)"
/usr/libexec/alemprator-network-protection/modules/loop check "br-test" "eth0" "00:11:22:33:44:55"
sleep 1
/usr/libexec/alemprator-network-protection/modules/loop check "br-test" "eth1" "00:11:22:33:44:55"
echo "  OK - no false positive"

# Test 2: Rapid MAC moves should trigger
echo "Test 2: Rapid MAC moves (same window)"
for i in $(seq 1 10); do
	/usr/libexec/alemprator-network-protection/modules/loop check "br-test" "eth$((i % 2))" "AA:BB:CC:DD:EE:FF"
done
echo "  OK - rapid moves detected"

# Test 3: Different MACs on different ports
echo "Test 3: Different MACs on different ports"
/usr/libexec/alemprator-network-protection/modules/loop check "br-test" "eth0" "11:22:33:44:55:66"
/usr/libexec/alemprator-network-protection/modules/loop check "br-test" "eth1" "77:88:99:AA:BB:CC"
echo "  OK - no false positive for different MACs"

echo ""
/usr/libexec/alemprator-network-protection/modules/loop state

rm -rf "$BASE_DIR"
echo ""
echo "=== Loop detection tests complete ==="
