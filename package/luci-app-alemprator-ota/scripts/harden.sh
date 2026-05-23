#!/bin/bash
# Alemprator OTA Guard - Hardening Script
# Protects sensitive central system scripts using custom Python hardener

MODE="$1"
CC_BIN="$2"
TARGET_DIR="$3"

# إذا كان الوضع "ignore" أو "skip" نتخطى التشفير بالكامل
# السبب: common.sh مكتبة مشتركة، تشفيرها يكسر جميع السكربتات الأخرى
if [ "$MODE" = "ignore" ] || [ "$MODE" = "skip" ] || [ "$MODE" = "none" ]; then
    echo "Alemprator OTA Guard: Hardening skipped (mode=$MODE)."
    exit 0
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PYTHON_HARDENER="$SCRIPT_DIR/alemp_harden.py"
TEMPLATE_FILE="$SCRIPT_DIR/protector_template.c"

echo "Alemprator OTA Guard: Starting hardening process..."

if [ ! -f "$PYTHON_HARDENER" ] || [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Python hardener or C template not found!"
    exit 1
fi

# List of sensitive OTA scripts to harden
# NOTE: common.sh MUST NOT be included here — it is a shared library sourced at
# runtime. SHC-compiling it breaks all scripts that try to `. /tmp/common.sh`.
SCRIPTS=(
    "/usr/libexec/alemprator-ota/agent.sh"
    "/usr/libexec/alemprator-ota/internet-check"
    "/usr/libexec/alemprator-ota/manual-clear"
    "/usr/libexec/alemprator-ota/manual-info"
    "/usr/libexec/alemprator-ota/manual-update"
    "/usr/libexec/alemprator-ota/start-check"
    "/usr/libexec/alemprator-ota/start-manual-update"
    "/usr/libexec/alemprator-ota/start-update"
    "/usr/libexec/alemprator-ota/status-json"
)

for script_path in "${SCRIPTS[@]}"; do
    full_path="${TARGET_DIR}${script_path}"
    
    if [ -f "$full_path" ]; then
        echo "Hardening OTA: $script_path"
        mv "$full_path" "${full_path}.orig"
        
        python3 "$PYTHON_HARDENER" "${full_path}.orig" "$full_path" "$CC_BIN" "$TEMPLATE_FILE"
        
        if [ $? -eq 0 ] && [ -f "$full_path" ]; then
            chmod +x "$full_path"
            rm -f "${full_path}.orig"
        else
            echo "Warning: Failed to harden $script_path, restoring original."
            mv "${full_path}.orig" "$full_path"
            chmod +x "$full_path"
        fi
    fi
done

echo "Alemprator OTA Guard: Finished."
