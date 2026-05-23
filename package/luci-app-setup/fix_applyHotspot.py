import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

# Replace the bailout in applyHotspotSettings
# Original:
#                 if (state.hotspotQuickEnabled)
#                         return;
#                 ensureNamedSection('hotspot_openwrt', 'main', 'main');

replacement = r"""
                if (state.hotspotQuickEnabled) {
                        uci.remove('wireless', hotspotIface);
                        uci.set('setup', 'default', 'hotspot_enabled_from_wizard', '0');
                        uci.remove('hotspot_openwrt', 'main');
                        return;
                }
                ensureNamedSection('hotspot_openwrt', 'main', 'main');
"""

old_pattern = r"if\s*\(\s*state\.hotspotQuickEnabled\s*\)\s*return;\s*ensureNamedSection\('hotspot_openwrt',\s*'main',\s*'main'\);"

modified = re.sub(old_pattern, replacement, code)

if modified != code:
    with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
        f.write(modified)
    print("Patched applyHotspotSettings")
else:
    print("Pattern not found in applyHotspotSettings")
