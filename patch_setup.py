import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    content = f.read()

# I will add `var managedSids = {};` right before `applyRadioHtmode`
if "var managedSids = {" not in content:
    content = content.replace(
        "                applyRadioHtmode(radio2g, '2g', state);",
        "                var managedSids = { 'wizard_hotspot': true };\n\n                applyRadioHtmode(radio2g, '2g', state);"
    )

    # Record Hotspot Quick
    content = content.replace(
        "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);",
        "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);\n                                managedSids[HOTSPOT_QUICK_IFACE_PRIMARY] = true;"
    )
    content = content.replace(
        "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);",
        "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);\n                                managedSids[HOTSPOT_QUICK_IFACE_SECONDARY] = true;"
    )

    # Record Uplink AP
    content = content.replace(
        "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');",
        "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');\n                                managedSids[uplinkLanApIface] = true;"
    )

    # Record Mesh
    content = content.replace(
        "                        meshIface = ensureNamedWifiIface('wizard_mesh');",
        "                        meshIface = ensureNamedWifiIface('wizard_mesh');\n                        managedSids[meshIface] = true;"
    )
    content = content.replace(
        "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;",
        "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;\n                        if (meshApIface) managedSids[meshApIface] = true;"
    )

    # Record 2g LAN
    content = content.replace(
        "                        iface = ensureWifiIface(radio2g['.name']);",
        "                        iface = ensureWifiIface(radio2g['.name']);\n                        managedSids[iface] = true;"
    )
    # Record 2g VLAN
    content = content.replace(
        "                                ensureNamedWifiIface(secondaryIface2g);",
        "                                ensureNamedWifiIface(secondaryIface2g);\n                                managedSids[secondaryIface2g] = true;"
    )

    # Record 5g LAN
    content = content.replace(
        "                        iface = ensureWifiIface(radio5g['.name']);",
        "                        iface = ensureWifiIface(radio5g['.name']);\n                        managedSids[iface] = true;"
    )
    # Record 5g VLAN
    content = content.replace(
        "                                ensureNamedWifiIface(secondaryIface5g);",
        "                                ensureNamedWifiIface(secondaryIface5g);\n                                managedSids[secondaryIface5g] = true;"
    )

with open('/tmp/loop_to_replace.txt', 'r') as f:
    search_loop = f.read()

replace_loop = """                uci.sections('wireless', 'wifi-iface').forEach(function(section) {
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

content = content.replace(search_loop, replace_loop)

print("Replaced:", search_loop in content, replace_loop in content)
with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(content)
