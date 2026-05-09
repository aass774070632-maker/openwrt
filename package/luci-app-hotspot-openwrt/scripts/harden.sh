#!/bin/bash
# Alemprator Guard - Hardening Script
# Protects sensitive scripts using custom Python hardener (Alemprator Protector)

# The first argument was SHC_BIN, we keep the signature but ignore it.
SHC_BIN="$1"
CC_BIN="$2"
TARGET_DIR="$3"

# Get the directory of this script to locate the Python tool
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PYTHON_HARDENER="$SCRIPT_DIR/alemp_harden.py"
TEMPLATE_FILE="$SCRIPT_DIR/protector_template.c"

echo "Alemprator Guard (v2): Starting hardening process using custom Python protector..."
echo "Target Directory: $TARGET_DIR"
echo "Compiler: $CC_BIN"

if [ ! -f "$PYTHON_HARDENER" ] || [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Python hardener or C template not found!"
    exit 1
fi

# List of sensitive scripts to harden
SCRIPTS=(
    "/usr/libexec/hotspot-openwrt/apply"
    "/usr/libexec/hotspot-openwrt/license-check"
    "/usr/libexec/hotspot-openwrt/mac-cookies"
    "/usr/libexec/hotspot-openwrt/mac-cookie-watchdog"
    "/usr/libexec/hotspot-openwrt/presence-watchdog"
    "/usr/libexec/hotspot-openwrt/userman-info"
    "/usr/libexec/hotspot-openwrt/validate"
    "/usr/libexec/hotspot-openwrt/kick-client"
    "/usr/libexec/hotspot-openwrt/portal-upload"
    "/www/cgi-bin/hotspot-login"
    "/www/cgi-bin/hotspot-logout"
    "/www/cgi-bin/hotspot-card-info"
    "/www/cgi-bin/hotspot-speedtest"
    "/usr/libexec/hotspot-openwrt/status-json"
)

for script_path in "${SCRIPTS[@]}"; do
    full_path="${TARGET_DIR}${script_path}"
    
    if [ -f "$full_path" ]; then
        echo "Hardening: $script_path"
        
        # Rename original script
        mv "$full_path" "${full_path}.orig"
        
        # Run Alemprator Hardener
        # Usage: alemp_harden.py <script> <output> <cc> <template>
        python3 "$PYTHON_HARDENER" "${full_path}.orig" "$full_path" "$CC_BIN" "$TEMPLATE_FILE"
        
        if [ $? -eq 0 ] && [ -f "$full_path" ]; then
            chmod +x "$full_path"
            rm -f "${full_path}.orig"
            echo "Success: $script_path is now a protected binary."
        else
            echo "Warning: Failed to harden $script_path, restoring original script."
            mv "${full_path}.orig" "$full_path"
            chmod +x "$full_path"
        fi
    fi
done

echo "Alemprator Guard: Hardening process finished."
