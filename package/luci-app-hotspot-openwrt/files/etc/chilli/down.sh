#!/bin/sh
# CoovaChilli TUN-down hook — nft only (no iptables)
# Called by chilli as ipdown when tun0 is torn down.

# Flush hotspot MAC sets on teardown
nft "flush set inet fw4 hotspot_blocked_mac" 2>/dev/null || true
nft "flush set inet fw4 hotspot_bypass_mac"  2>/dev/null || true

exit 0
