#!/bin/bash
# Alemprator Guard - Hardening Script
# Protects sensitive scripts using SHC

SHC_BIN="$1"
CC_BIN="$2"
TARGET_DIR="$3"

echo "Alemprator Guard: Starting hardening process..."
echo "Target Directory: $TARGET_DIR"

if [ ! -x "$SHC_BIN" ]; then
    echo "Error: SHC binary not found at $SHC_BIN"
    exit 0 # We don't want to break the whole build if SHC is missing
fi

# List of sensitive scripts to harden
SCRIPTS=(
    "/usr/libexec/hotspot-openwrt/apply"
    "/www/cgi-bin/hotspot-login"
    "/www/cgi-bin/hotspot-logout"
    "/www/cgi-bin/hotspot-card-info"
    "/www/cgi-bin/hotspot-speedtest"
)

for script_path in "${SCRIPTS[@]}"; do
    full_path="${TARGET_DIR}${script_path}"
    
    if [ -f "$full_path" ]; then
        echo "Hardening: $script_path"
        
        # Create a temporary source file for SHC
        cp "$full_path" "${full_path}.sh"
        
        # Run SHC
        # -r: Relax security to allow execution on other machines (required for distribution)
        # -f: input script
        # -o: output binary
        "$SHC_BIN" -r -f "${full_path}.sh" -o "${full_path}.bin"
        
        if [ -f "${full_path}.bin" ]; then
            mv "${full_path}.bin" "$full_path"
            chmod +x "$full_path"
            rm -f "${full_path}.sh" "${full_path}.sh.x.c"
            echo "Success: $script_path is now a protected binary."
        else
            echo "Warning: Failed to harden $script_path, keeping original script."
            rm -f "${full_path}.sh"
        fi
    fi
done

echo "Alemprator Guard: Hardening process finished."
