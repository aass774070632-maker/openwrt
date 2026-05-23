import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

replacement = """
                        if (!self.state.hotspotQuickEnabled && !self.state.hotspotEnabled) {
                                console.log("CALLING cleanupHotspotWizardState!");
                                cleanupHotspotWizardState();
                        } else {
                                console.log("SKIPPING cleanupHotspotWizardState! quick=", self.state.hotspotQuickEnabled, " hot=", self.state.hotspotEnabled);
                        }
"""

code = re.sub(r"if \(!self\.state\.hotspotQuickEnabled && !self\.state\.hotspotEnabled\)\s*cleanupHotspotWizardState\(\);", replacement, code)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

