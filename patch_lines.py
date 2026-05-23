with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    lines = f.readlines()

new_loop_lines = """                uci.sections('wireless', 'wifi-iface').forEach(function(section) {
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
                });
"""

import sys

# Validate loop
if not (lines[4445].strip().startswith("uci.sections('wireless', 'wifi-iface').forEach(function(section) {") and lines[4486].strip() == "});"):
    print("Line numbers mismatch in patch_lines.py!")
    sys.exit(1)

# Apply replacement of lines 4446 to 4487 (index 4445 to 4487)
lines[4445:4487] = [new_loop_lines]

with open('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.writelines(lines)

print("Exact lines replaced!")
