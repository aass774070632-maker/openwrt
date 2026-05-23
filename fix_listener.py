import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

replacement = r"""
           if (this.refs.hotspotQuickSecondaryEnabled) {
                   this.refs.hotspotQuickSecondaryEnabled.addEventListener('change', function() {
                           self.updateStepUi();
                   });
           }

           if (this.refs.hotspotQuickEnabled) {
"""

old_pattern = r"if\s*\(\s*this\.refs\.hotspotQuickEnabled\s*\)\s*\{"

modified = re.sub(old_pattern, replacement, code, count=1)

if modified != code:
    with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
        f.write(modified)
    print("Patched listeners")
else:
    print("Pattern not found for listeners")
