#!/bin/sh
# This script is called by fw4 to inject custom NFT rules

# 1. Access Control (Blocking/Allowing)
# Create the set if it doesn't exist
nft "add set inet fw4 hotspot_allowed { type ipv4_addr; flags timeout; }" 2>/dev/null

# Create and clear the auth chain
nft "add chain inet fw4 hotspot_auth" 2>/dev/null
nft "flush chain inet fw4 hotspot_auth" 2>/dev/null

# Add rules to the auth chain
nft "add rule inet fw4 hotspot_auth ip saddr @hotspot_allowed counter accept" 2>/dev/null
nft "add rule inet fw4 hotspot_auth ip saddr 20.20.20.0/24 counter reject" 2>/dev/null

# Jump to our auth chain from forward
nft "delete rule inet fw4 forward ip saddr 20.20.20.0/24 jump hotspot_auth" 2>/dev/null
nft "insert rule inet fw4 forward ip saddr 20.20.20.0/24 jump hotspot_auth" 2>/dev/null

# 2. Redirection (Captive Portal Redirect)
# Create a redirection chain in the nat table if it doesn't exist
nft "add chain inet fw4 hotspot_redirect { type nat hook prerouting priority dstnat; policy accept; }" 2>/dev/null
nft "flush chain inet fw4 hotspot_redirect" 2>/dev/null

# Redirect port 80 to the local portal for unauthenticated users
# We skip redirecting if the user is already in the allowed set
nft "add rule inet fw4 hotspot_redirect ip saddr 20.20.20.0/24 ip saddr != @hotspot_allowed tcp dport 80 counter redirect to :80" 2>/dev/null

exit 0
