#!/usr/bin/env python3
import json
import sys
import os

def main():
    # Find the path to alemprator-models.json
    # It should be located at the top level of the openwrt directory
    script_dir = os.path.dirname(os.path.realpath(__file__))
    top_dir = os.path.dirname(script_dir)
    json_path = os.path.join(top_dir, 'alemprator-models.json')
    
    if not os.path.exists(json_path):
        # Fallback empty string if not found so make doesn't break
        print("")
        sys.exit(0)
        
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
            shared_pkgs = data.get('sharedPackages', [])
            if shared_pkgs:
                # Print as space-separated string for the Makefile
                print(" ".join(shared_pkgs))
            else:
                print("")
    except Exception as e:
        print("")

if __name__ == "__main__":
    main()
