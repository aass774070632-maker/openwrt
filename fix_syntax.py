import sys

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    content = f.read()

content = content.replace(
    "                });                     }\n                });\n\n        },",
    "                });\n\n        },"
)
with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(content)
