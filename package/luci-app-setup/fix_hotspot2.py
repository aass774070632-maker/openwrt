import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

pattern = re.compile(r"els\s*e\s*if\s*\(self\.refs\.hotspotEnabled\)\s*\{\s*self\.refs\.hotspotEnabled\.checked\s*=\s*false;\s*self\.updateState\(\);")
replacement = """else if (self.refs.hotspotEnabled) {
                                        self.refs.hotspotEnabled.checked = false;
                                        self.collectState();"""

code = pattern.sub(replacement, code)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

