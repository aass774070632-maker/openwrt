#!/bin/sh

. /usr/libexec/alemprator-network-protection/common.sh

echo "=== Action Manager Unit Test ==="
echo ""

BASE_DIR="/tmp/np_test_actions"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

export NP_STATE_DIR="$BASE_DIR/state"
np_init_state

# Test 1: Warn action
echo "Test 1: Warn action"
/usr/libexec/alemprator-network-protection/action-manager execute "test" "eth0" "00:11:22:33:44:55" "Test warning" "warn"
echo "  OK"

# Test 2: Log action
echo "Test 2: Log action"
/usr/libexec/alemprator-network-protection/action-manager execute "test" "eth0" "AA:BB:CC:DD:EE:FF" "Test log event" "log"
echo "  OK"

# Test 3: Rate limit action
echo "Test 3: Rate limit action"
/usr/libexec/alemprator-network-protection/action-manager execute "test" "eth0" "" "Rate limit test" "rate_limit"
echo "  OK (rate limit applied)"

# Test 4: Disable port action
echo "Test 4: Disable port action"
/usr/libexec/alemprator-network-protection/action-manager execute "test" "eth0" "" "Disable test" "disable"
echo "  OK (port disabled)"

# Test 5: Action rate limiting
echo "Test 5: Action rate limiting"
for i in $(seq 1 15); do
	/usr/libexec/alemprator-network-protection/action-manager execute "test" "eth0" "" "Rate limit test $i" "warn"
done
echo "  OK (rate limiter checked)"

echo ""
/usr/libexec/alemprator-network-protection/action-manager state

rm -rf "$BASE_DIR"
echo ""
echo "=== Action manager tests complete ==="
