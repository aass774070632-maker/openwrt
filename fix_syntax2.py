import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    content = f.read()

content = re.sub(r"\}\);\s*\}\s*\}\);\s*\},", "});\n\n        },", content)

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(content)
