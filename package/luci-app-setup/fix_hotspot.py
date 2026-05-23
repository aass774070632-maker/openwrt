import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

pattern = re.compile(r"if \(self\.refs\.hotspotQuickEnabled\.checked\)\s+showHotspotLicenseSelectionMessage\(_\('الهوتسبوت السريع'\)\);")
replacement = """if (self.refs.hotspotQuickEnabled.checked) {
                                        showHotspotLicenseSelectionMessage(_('الهوتسبوت السريع'));
                                } else if (self.refs.hotspotEnabled) {
                                        self.refs.hotspotEnabled.checked = false;
                                        self.updateState();
                                }"""

code = pattern.sub(replacement, code)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)
print("SUCCESS")
