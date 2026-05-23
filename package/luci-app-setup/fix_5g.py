with open('files/www/luci-static/resources/view/setup/setup.js', 'r') as f:
    code = f.read()

# 1. Remove the explicit disabling of AP for WDS
code = code.replace(
    """                        if (uplinkLanApIface && uplinkLanApIface != uplinkStaIface) {
                                uci.set('wireless', uplinkLanApIface, 'disassoc_low_ack', '0');
                                uci.set('wireless', uplinkLanApIface, 'disabled', '1');
                        }""",
    """                        if (uplinkLanApIface && uplinkLanApIface != uplinkStaIface) {
                                uci.set('wireless', uplinkLanApIface, 'disassoc_low_ack', '0');
                                // uci.set('wireless', uplinkLanApIface, 'disabled', '1');
                        }"""
)

# 2. Remove the explicit disabling of AP for Mesh
code = code.replace(
    """                        if (meshApIface && meshApIface != meshIface) {
                                uci.set('wireless', meshApIface, 'disassoc_low_ack', '0');
                                uci.set('wireless', meshApIface, 'disabled', '1');
                        }""",
    """                        if (meshApIface && meshApIface != meshIface) {
                                uci.set('wireless', meshApIface, 'disassoc_low_ack', '0');
                                // uci.set('wireless', meshApIface, 'disabled', '1');
                        }"""
)

# 3. DO NOT exclude mesh/uplink radios from localRadios so they get correctly updated with SSID and Passwords!
code = code.replace(
    """                localRadios = radios.filter(function(radio) {
                        return (!uplinkRadio || radio['.name'] != uplinkRadio['.name']) && (!meshRadio || radio['.name'] != meshRadio['.name']);
                });""",
    """                localRadios = radios.filter(function(radio) {
                        return true; // ALways update SSID and Passwords for all APs even if used for mesh/wds
                });"""
)

# 4. Remove the conditions that skip updating 2g and 5g APs
code = code.replace(
    """                if (radio2g && (!uplinkRadio || radio2g['.name'] != uplinkRadio['.name']) && (!meshRadio || radio2g['.name'] != meshRadio['.name'])) {""",
    """                if (radio2g) {"""
)
code = code.replace(
    """                if (radio5g && (!uplinkRadio || radio5g['.name'] != uplinkRadio['.name']) && (!meshRadio || radio5g['.name'] != meshRadio['.name'])) {""",
    """                if (radio5g) {"""
)

with open('files/www/luci-static/resources/view/setup/setup.js', 'w') as f:
    f.write(code)

