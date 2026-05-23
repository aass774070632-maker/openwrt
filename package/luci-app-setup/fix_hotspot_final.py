import re

with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

# Modify the mode dropdown listener to ALWAYS clear hotspots when the mode is actively changed by the user.
pattern = re.compile(r"if\s*\(self\.refs\.mode\.value\s*!==\s*'ap'\)\s*\{\s*(if\s*\(self\.refs\.hotspotQuickEnabled\).*?;)\s*(if\s*\(self\.refs\.hotspotEnabled\).*?;)\s*self\.collectState\(\);\s*\}")

replacement = r"""
                        \1
                        \2
                        self.collectState();
"""

modified = pattern.sub(replacement, code)

if modified == code:
    print("Pattern not found for dropdown!")

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(modified)
