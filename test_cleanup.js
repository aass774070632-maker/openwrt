const fs = require('fs');
const uci = {
    removed: [],
    remove: function(conf, section) {
        this.removed.push(conf + '.' + section);
    },
    sections: function() { return []; },
    get: function() { return true; },
    set: function() {},
    unset: function() {}
};

function cleanupHotspotWizardState() {
        var firewallLanZone = null;
        var hotspotNetworks = [ 'hotspot', 'hotspot2' ];
        var hotspotNetworkMap = {};
        var hotspotTunnels = { tun0: true, tun1: true };

        hotspotNetworks.forEach(function(networkName) {
                hotspotNetworkMap[networkName] = true;
        });

        var HOTSPOT_QUICK_IFACE_PRIMARY = 'wizard_hotspot_quick_primary';
        var HOTSPOT_QUICK_IFACE_SECONDARY = 'wizard_hotspot_quick_secondary';

        uci.remove('wireless', 'wizard_hotspot');
        uci.remove('wireless', HOTSPOT_QUICK_IFACE_PRIMARY);
        uci.remove('wireless', HOTSPOT_QUICK_IFACE_SECONDARY);

        console.log(uci.removed);
}

cleanupHotspotWizardState();
