import re

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

match = re.search(r"uci\.sections\('wireless', 'wifi-iface'\)\.forEach\(function\(section\) \{.*?^\s*\}\);\s*\},", code, re.MULTILINE | re.DOTALL)
if match:
    old_loop = match.group(0)
    print("Found loop, size:", len(old_loop))
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
                        }
                        else {
                                // Enable strictly managed interfaces that aren't lan/vlan (like hotspot) instead of disabling
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                });

        },"""
    code = code.replace(old_loop, new_loop)
    with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
        f.write(code)
    print("Replaced.")
else:
    print("Not found.")
