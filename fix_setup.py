import sys, re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    content = f.read()

# 1. Add variable definition
content = content.replace(
    "                applyRadioHtmode(radio2g, '2g', state);",
    "                var managedSids = {};\n\t\tapplyRadioHtmode(radio2g, '2g', state);"
)

# 2. Track Hotspot Quick interfaces
content = content.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_PRIMARY] = true;"
)
content = content.replace(
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);",
    "                                ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_SECONDARY] = true;"
)

# 3. Track Uplink AP
content = content.replace(
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');",
    "                                uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');\n\t\t\t\t\tmanagedSids[uplinkLanApIface] = true;"
)

# 4. Track Mesh
content = content.replace(
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');",
    "                        meshIface = ensureNamedWifiIface('wizard_mesh');\n\t\t\t\t\t\tmanagedSids[meshIface] = true;"
)
content = content.replace(
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;",
    "                        meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;\n\t\t\t\t\t\tif (meshApIface) managedSids[meshApIface] = true;"
)

# 5. Track 2g LAN
content = content.replace(
    "                        iface = ensureWifiIface(radio2g['.name']);",
    "                        iface = ensureWifiIface(radio2g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)
# Track 2g VLAN
content = content.replace(
    "                                ensureNamedWifiIface(secondaryIface2g);",
    "                                ensureNamedWifiIface(secondaryIface2g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface2g] = true;"
)

# 6. Track 5g LAN
content = content.replace(
    "                        iface = ensureWifiIface(radio5g['.name']);",
    "                        iface = ensureWifiIface(radio5g['.name']);\n\t\t\t\t\t\tmanagedSids[iface] = true;"
)
# Track 5g VLAN
content = content.replace(
    "                                ensureNamedWifiIface(secondaryIface5g);",
    "                                ensureNamedWifiIface(secondaryIface5g);\n\t\t\t\t\t\t\tmanagedSids[secondaryIface5g] = true;"
)

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
                                return; // LET THE CLEANUP SCRIPT HANDLE IT LATER
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

# Smart Regex replace using applyVlanSettings boundary
start_idx = content.find("applyWifiSettings: function(state, radios) {")
if start_idx == -1: 
    print("Could not find applyWifiSettings!")
    sys.exit(1)

str_to_search = content[start_idx:]
m = re.search(r"(uci\.sections\('wireless',\s*'wifi-iface'\)\.forEach\(function\(section\) \{[^\}]+\}\);)", str_to_search, re.DOTALL)
if m:
    the_loop = m.group(1)
    content = content.replace(the_loop, new_loop)
    with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
        f.write(content)
    print("Saved cleanly via regex.")
else:
    print("Loop not found")

