import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

# Patch 1: collectState Failsafe
replacement1 = r"""
           this.state.hotspotEnabled = this.refs.hotspotEnabled ? this.refs.hotspotEnabled.checked : false;
           
           // FAILSAFE: Mutually exclusive, Quick Hotspot wins.
           if (this.state.hotspotQuickEnabled) {
               this.state.hotspotEnabled = false;
               if (this.refs.hotspotEnabled) this.refs.hotspotEnabled.checked = false;
           }
"""
code = re.sub(r"this\.state\.hotspotEnabled\s*=\s*this\.refs\.hotspotEnabled\s*\?\s*this\.refs\.hotspotEnabled\.checked\s*:\s*false;", replacement1, code)

# Patch 2: mode dropdown listener
replacement2 = r"""
                        \1
                        \2
                        self.collectState();
"""
code = re.sub(r"if\s*\(self\.refs\.mode\.value\s*!==\s*'ap'\)\s*\{\s*(if\s*\(self\.refs\.hotspotQuickEnabled\).*?;)\s*(if\s*\(self\.refs\.hotspotEnabled\).*?;)\s*self\.collectState\(\);\s*\}", replacement2, code)
# Actually wait, in setup_r93.js, does it have `if (self.refs.mode.value !== 'ap')`?
# Let's check wait, I didn't verify if setup_r93.js has that string in the mode dropdown.
