with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

code = code.replace(
    "                applyRadioHtmode(radio2g, '2g', state);",
    "                var managedSids = {};\n\t\tapplyRadioHtmode(radio2g, '2g', state);"
)

code = code.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_PRIMARY] = true;"
)
code = code.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_SECONDARY] = true;"
)

code = code.replace(
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');",
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');\n\t\t\t\t\tmanagedSids[uplinkLanApIface] = true;"
)

code = code.replace(
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');",
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');\n\t\t\t\t\t\tmanagedSids[meshIface] = true;"
)
code = code.replace(
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;",
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;\n\t\t\t\t\t\tif (meshApIface) managedSids[meshApIface] = true;"
)

code = code.replace(
    "                        iface = ensureWifiIface(radio2g['.name']);",
    "                        iface = ensureWifiIface(radio2g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)

code = code.replace(
    "                                ensureNamedWifiIface(secondaryIface2g);",
    "                                ensureNamedWifiIface(secondaryIface2g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface2g] = true;"
)

code = code.replace(
    "                        iface = ensureWifiIface(radio5g['.name']);",
    "                        iface = ensureWifiIface(radio5g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)

code = code.replace(
    "                                ensureNamedWifiIface(secondaryIface5g);",
    "                                ensureNamedWifiIface(secondaryIface5g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface5g] = true;"
)

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

print("managedSids arrays injected!")
