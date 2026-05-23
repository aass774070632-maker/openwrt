import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

pattern = re.compile(r"this\.refs\.mode\.addEventListener\('change',\s*function\(\)\s*\{\s*self\.updateStepUi\(\);\s*\}\);")
replacement = """this.refs.mode.addEventListener('change', function() {
                        self.updateStepUi();
                        if (self.refs.mode.value !== 'ap') {
                                if (self.refs.hotspotQuickEnabled) self.refs.hotspotQuickEnabled.checked = false;
                                if (self.refs.hotspotEnabled) self.refs.hotspotEnabled.checked = false;
                                self.collectState();
                        }
                });"""

code = pattern.sub(replacement, code)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

