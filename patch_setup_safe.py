with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

import re

# Insert managedSids tracking
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


# Target loop exact replace using regex
pattern = r"uci\.sections\('wireless', 'wifi-iface'\)\.forEach\(function\(section\) \{\s*var sid = section\['\.name'\];.*?uci\.set\('wireless', sid, 'disabled', '1'\);\s*\}\s*\}\);"

new_loop = """uci.sections('wireless', 'wifi-iface').forEach(function(section) {
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
                                return; // managed by applyHotspotSettings
                        }

                        // Remove AP interfaces that are unmanaged (ghost SSIDs)
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
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                        else if (sectionNetworks.indexOf('wizardvlan') > -1) {
                                if (vlanPolicy.enableWds)
                                        uci.set('wireless', sid, 'wds', '1');
                                else
                                        uci.unset('wireless', sid, 'wds');

                                applyWifiIfaceFlag('wireless', sid, 'hidden', vlanPolicy.hidden);
                                applyWifiIfaceFlag('wireless', sid, 'isolate', vlanPolicy.isolate);
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                        else {
                                // Enable strictly managed interfaces that aren't lan/vlan (like hotspot) instead of disabling
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                });"""

if re.search(pattern, code, re.DOTALL):
    code = re.sub(pattern, new_loop, code, flags=re.DOTALL)
    print("Loop replaced cleanly!")
else:
    print("Regex old_loop NOT FOUND.")

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)
