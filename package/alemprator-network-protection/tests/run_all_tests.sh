#!/bin/sh

echo "=========================================="
echo "  Alemprator Network Protection Test Suite"
echo "=========================================="
echo ""

# Load configuration from default config
CFG_FILE="/etc/config/alemprator-network-protection"
if [ ! -f "$CFG_FILE" ]; then
	echo "WARNING: Config file not found at $CFG_FILE"
	echo "Using test defaults for config"
	export UCI_CONFIG_DIR="/tmp/np_test_uci"
	mkdir -p "$UCI_CONFIG_DIR"
	cp /etc/config/alemprator-network-protection "$UCI_CONFIG_DIR/" 2>/dev/null || true
fi

TESTS="test_loop test_broadcast test_mac_flapping test_dhcp_rogue test_actions"

PASSED=0
FAILED=0
TOTAL=0

SCRIPT_DIR="$(dirname "$0")"

for test in $TESTS; do
	TOTAL=$((TOTAL + 1))
	TEST_SCRIPT="$SCRIPT_DIR/${test}.sh"

	if [ ! -f "$TEST_SCRIPT" ]; then
		echo "[SKIP] $test - test script not found"
		continue
	fi

	echo "--- Running $test ---"
	if sh "$TEST_SCRIPT" 2>&1; then
		echo "[PASS] $test"
		PASSED=$((PASSED + 1))
	else
		RESULT=$?
		echo "[FAIL] $test (exit code $RESULT)"
		FAILED=$((FAILED + 1))
	fi
	echo ""
done

echo "=========================================="
echo "  Results: $PASSED/$TOTAL passed, $FAILED failed"
echo "=========================================="

[ "$FAILED" -gt 0 ] && exit 1
exit 0
