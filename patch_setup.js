const fs = require('fs');
let code = fs.readFileSync('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', 'utf8');

// Ensure we don't apply twice
if (code.includes('var managedSids = {}')) {
    console.log('Already applied');
    process.exit(0);
}

// 1. Add variable definition
code = code.replace(
    /(applyRadioHtmode\(radio2g[^;]+;\s*)/,
    "var managedSids = {};\n\t\t$1"
);

// 2. Track Hotspot Quick interfaces
// ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);
code = code.replace(
    /(ensureNamedWifiIface\(HOTSPOT_QUICK_IFACE_PRIMARY\);)/g,
    "$1\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_PRIMARY] = true;"
);
code = code.replace(
    /(ensureNamedWifiIface\(HOTSPOT_QUICK_IFACE_SECONDARY\);)/g,
    "$1\n\t\t\t\tmanagedSids[HOTSPOT_QUICK_IFACE_SECONDARY] = true;"
);

// 3. Track Uplink AP
// uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');
code = code.replace(
    /(uplinkLanApIface\s*=\s*ensureNamedWifiIface\('wizard_uplink_ap'\);)/g,
    "$1\n\t\t\t\t\tmanagedSids[uplinkLanApIface] = true;"
);

// 4. Track Mesh
// meshIface = ensureNamedWifiIface('wizard_mesh');
code = code.replace(
    /(meshIface\s*=\s*ensureNamedWifiIface\('wizard_mesh'\);)/g,
    "$1\n\t\t\t\t\tmanagedSids[meshIface] = true;"
);
// meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;
code = code.replace(
    /(meshApIface\s*=\s*meshRadio\s*\?\s*findWifiIface[^;]+;)/g,
    "$1\n\t\t\t\t\t\tif (meshApIface) managedSids[meshApIface] = true;"
);

// 5. Track 2g LAN
// iface = ensureWifiIface(radio2g['.name']);
code = code.replace(
    /(iface\s*=\s*ensureWifiIface\(radio2g\['\.name'\]\);)/g,
    "$1\n\t\t\t\t\t\tmanagedSids[iface] = true;"
);
// Track 2g VLAN
// ensureNamedWifiIface(secondaryIface2g);
code = code.replace(
    /(ensureNamedWifiIface\(secondaryIface2g\);)/g,
    "$1\n\t\t\t\t\t\t\tmanagedSids[secondaryIface2g] = true;"
);

// 6. Track 5g LAN
// iface = ensureWifiIface(radio5g['.name']);
code = code.replace(
    /(iface\s*=\s*ensureWifiIface\(radio5g\['\.name'\]\);)/g,
    "$1\n\t\t\t\t\t\tmanagedSids[iface] = true;"
);
// Track 5g VLAN
// ensureNamedWifiIface(secondaryIface5g);
code = code.replace(
    /(ensureNamedWifiIface\(secondaryIface5g\);)/g,
    "$1\n\t\t\t\t\t\t\tmanagedSids[secondaryIface5g] = true;"
);

// 7. Modifying the loop
const loopRegex = /uci\.sections\('wireless',\s*'wifi-iface'\)\.forEach\([\s\S]*?\}\);/;
const replaceLoop = `uci.sections('wireless', 'wifi-iface').forEach(function(section) {
\t\t\tvar sid = section['.name'];
\t\t\tvar sectionNetworks = normalizeList(section.network);
\t\t\tvar isLocalRadio = localRadios.some(function(radio) {
\t\t\t\treturn section.device == radio['.name'];
\t\t\t});

\t\t\tif (section.mode == null || section.mode == 'ap')
\t\t\t\tuci.set('wireless', sid, 'disassoc_low_ack', '0');

\t\t\tif (!isLocalRadio)
\t\t\t\treturn;

\t\t\tif (section.mode != null && section.mode != 'ap')
\t\t\t\treturn;

\t\t\tif (!managedSids[sid]) {
\t\t\t\tuci.remove('wireless', sid);
\t\t\t\treturn;
\t\t\t}

\t\t\tif (sectionNetworks.indexOf('lan') > -1) {
\t\t\t\tif (vlanOnlyAp) {
\t\t\t\t\tuci.remove('wireless', sid);
\t\t\t\t\treturn;
\t\t\t\t}

\t\t\t\tif (lanPolicy.enableWds)
\t\t\t\t\tuci.set('wireless', sid, 'wds', '1');
\t\t\t\telse
\t\t\t\t\tuci.unset('wireless', sid, 'wds');

\t\t\t\tapplyWifiIfaceFlag('wireless', sid, 'hidden', lanPolicy.hidden);
\t\t\t\tapplyWifiIfaceFlag('wireless', sid, 'isolate', lanPolicy.isolate);
\t\t\t}
\t\t\telse if (sectionNetworks.indexOf('wizardvlan') > -1) {
\t\t\t\tif (vlanPolicy.enableWds)
\t\t\t\t\tuci.set('wireless', sid, 'wds', '1');
\t\t\t\telse
\t\t\t\t\tuci.unset('wireless', sid, 'wds');

\t\t\t\tapplyWifiIfaceFlag('wireless', sid, 'hidden', vlanPolicy.hidden);
\t\t\t\tapplyWifiIfaceFlag('wireless', sid, 'isolate', vlanPolicy.isolate);
\t\t\t}
\t\t});`;

code = code.replace(loopRegex, replaceLoop);

fs.writeFileSync('package/luci-app-setup/files/www/luci-static/resources/view/setup/setup.js', code);
console.log('Update successful');
