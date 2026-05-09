#!/usr/bin/env python3
import sys
import os
import subprocess
import gzip

def harden(script_path, output_bin, cc_bin, template_path):
    with open(script_path, 'rb') as f:
        data = f.read()
    
    compressed = gzip.compress(data)
    hex_data = ', '.join([f'0x{b:02x}' for b in compressed])
    
    with open(template_path, 'r') as f:
        template = f.read()
    
    c_code = template.replace('{{COMPRESSED_DATA}}', hex_data).replace('{{COMPRESSED_LEN}}', str(len(compressed)))
    
    c_file = output_bin + '.c'
    with open(c_file, 'w') as f:
        f.write(c_code)
    
    # Compile
    env = os.environ.copy()
    if 'staging_dir' in cc_bin:
        # Try to find staging_dir root
        parts = cc_bin.split('/')
        if 'staging_dir' in parts:
            idx = parts.index('staging_dir')
            env['STAGING_DIR'] = '/'.join(parts[:idx+2])

    cmd = [cc_bin, c_file, '-o', output_bin, '-O2']
    # Use -static for even better compatibility
    cmd.append('-static')
    
    result = subprocess.run(cmd, env=env)
    if result.returncode == 0:
        print(f"Successfully hardened {script_path} -> {output_bin}")
        os.remove(c_file)
        return True
    else:
        print(f"Failed to harden {script_path}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: alemp_harden.py <script> <output> <cc> <template>")
        sys.exit(1)
    harden(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
