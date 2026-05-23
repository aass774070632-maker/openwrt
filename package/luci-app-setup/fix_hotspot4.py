import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

replacement = """
                this.collectState();
                enforceHotspotNoVlan(this.state);

                if (this.state.hotspotQuickEnabled) {
                        this.state.mode = 'ap';
                } else if (this.state.mode !== 'ap') {
                        // FORCE KILL HOTSPOT if Mode is NOT AP
                        this.state.hotspotEnabled = false;
                        if (this.refs.hotspotEnabled) this.refs.hotspotEnabled.checked = false;
                        if (this.refs.hotspotQuickEnabled) this.refs.hotspotQuickEnabled.checked = false;
                }
"""

code = re.sub(r"this\.collectState\(\);\s*enforceHotspotNoVlan\(this\.state\);\s*if\s*\(this\.state\.hotspotQuickEnabled\)\s*this\.state\.mode\s*=\s*'ap';", replacement, code)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

