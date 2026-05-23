with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    lines = f.readlines()

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    skip = False
    for line in lines:
        if "if (sid === 'wizard_hotspot') {" in line:
            skip = True
            continue
        if skip and "return; // let cleanupHotspotWizardState or applyHotspotSettings handle it" in line:
            continue
        if skip and "}" in line:
            skip = False
            continue
        f.write(line)
