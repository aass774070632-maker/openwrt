import sys

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    content = f.read()

content = content.replace(
    "                applyRadioHtmode(radio2g, '2g', state);",
    "                var managedSids = {};\n\t\tapplyRadioHtmode(radio2g, '2g', state);"
)
content = content.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_PRIMARY] = true;"
)
content = content.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_SECONDARY] = true;"
)
content = content.replace(
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');",
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');\n\t\t\t\t\tmanagedSids[uplinkLanApIface] = true;"
)
content = content.replace(
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');",
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');\n\t\t\t\t\t\tmanagedSids[meshIface] = true;"
)
content = content.replace(
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;",
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;\n\t\t\t\t\t\tif (meshApIface) managedSids[meshApIface] = true;"
)
content = content.replace(
    "                        iface = ensureWifiIface(radio2g['.name']);",
    "                        iface = ensureWifiIface(radio2g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)
content = content.replace(
    "                                ensureNamedWifiIface(secondaryIface2g);",
    "                                ensureNamedWifiIface(secondaryIface2g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface2g] = true;"
)
content = content.replace(
    "                        iface = ensureWifiIface(radio5g['.name']);",
    "                        iface = ensureWifiIface(radio5g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)
content = content.replace(
    "                                ensureNamedWifiIface(secondaryIface5g);",
    "                                ensureNamedWifiIface(secondaryIface5g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface5g] = true;"
)

with open('/tmp/loop.txt', 'r') as f:
    loop_to_replace = f.read()

new_loop = """                uci.sections('wireless', 'wifi-iface').forEach(function(section) {
                        var sid = section['.name'];
                        var sectionNetworks = normalizeList(section.network);
                        var isLocalRadio = localRadios.some(function(radio) {
                                return section.device == radio['.name'];
                        });

                        if (section.mode == null || section.mode == 'ap')
                                uci.set('wireless', sid, 'disassoc_low_ack', '0');

                        if (!isLocalRadio)
                                return;

                        if (section.mode != null && section.mode != 'ap')
                                return;

                        if (sid === 'wizard_hotspot') {
                                return; // let cleanupHotspotWizardState or applyHotspotSettings handle it
                        }

                        if (!managedSids[sid]) {
                                uci.remove('wireless', sid);
                                return;
                        }

                        if (sectionNetworks.indexOf('lan') > -1) {
                                if (vlanOnlyAp) {
                                        uci.remove('wireless', sid);
                                        return;
                                }

                                if (lanPolicy.enableWds)
                                        uci.set('wireless', sid, 'wds', '1');
                                else
                                        uci.unset('wireless', sid, 'wds');

                                applyWifiIfaceFlag('wireless', sid, 'hidden', lanPolicy.hidden);
                                applyWifiIfaceFlag('wireless', sid, 'isolate', lanPolicy.isolate);
                        }
                        else if (sectionNetworks.indexOf('wizardvlan') > -1) {
                                if (vlanPolicy.enableWds)
                                        uci.set('wireless', sid, 'wds', '1');
                                else
                                        uci.unset('wireless', sid, 'wds');

                                applyWifiIfaceFlag('wireless', sid, 'hidden', vlanPolicy.hidden);
                                applyWifiIfaceFlag('wireless', sid, 'isolate', vlanPolicy.isolate);
                        }
                });"""

if loop_to_replace not in content:
    print("Exact original loop not found! Exiting.")
    sys.exit(1)

content = content.replace(loop_to_replace, new_loop)
with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(content)
print("Saved cleanly via file read match.")
