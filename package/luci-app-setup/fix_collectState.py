import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

replacement = r"""
           this.state.hotspotEnabled = this.refs.hotspotEnabled ? this.refs.hotspotEnabled.checked : false;
           
           // FAILSAFE: Mutually exclusive, Quick Hotspot wins.
           if (this.state.hotspotQuickEnabled) {
               this.state.hotspotEnabled = false;
               if (this.refs.hotspotEnabled) this.refs.hotspotEnabled.checked = false;
           }
"""

old_pattern = r"this\.state\.hotspotEnabled\s*=\s*this\.refs\.hotspotEnabled\s*\?\s*this\.refs\.hotspotEnabled\.checked\s*:\s*false;"

modified = re.sub(old_pattern, replacement, code)

if modified != code:
    with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
        f.write(modified)
    print("Patched collectState")
else:
    print("Pattern not found in collectState")
