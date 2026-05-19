'use strict';
'require view';
'require fs';
'require ui';
'require rpc';
'require uci';

return view.extend({
        load: function() {
                return Promise.all([
                        uci.load('setup').catch(function(){ return null; }),
                        fs.read_direct('/tmp/dhcp.leases', 'text').catch(function(){ return ''; }),
                        fs.exec_direct('/usr/sbin/chilli_query', ['dhcp-list']).catch(function(){ return ''; })
                ]);
        },

        render: function(data) {
                var dnsmasqLeases = data[1] || '';
                var chilliLeases = data[2] || '';

                var leases = [];

                // Parse dnsmasq leases (epoch mac ip name clientid)
                var lines = dnsmasqLeases.trim().split(/\n/);
                for (var i = 0; i < lines.length; i++) {
                        var p = lines[i].split(/\s+/);
                        if (p.length >= 4) {
                                leases.push({
                                        source: 'LAN (dnsmasq)',
                                        mac: p[1].toUpperCase(),
                                        ip: p[2],
                                        name: (p[3] !== '*') ? p[3] : 'Unknown'
                                });
                        }
                }

                // Parse chilli leases (mac ip hostname ...)
                var clines = chilliLeases.trim().split(/\n/);
                for (var j = 0; j < clines.length; j++) {
                        var p = clines[j].split(/\s+/);
                        if (p.length >= 2 && p[0].match(/^[0-9a-fA-F-]{17}$/)) {
                                leases.push({
                                        source: 'Hotspot (Chilli)',
                                        mac: p[0].replace(/-/g, ':').toUpperCase(),
                                        ip: p[1],
                                        name: 'Hotspot Client'
                                });
                        }
                }

                var table = E('table', { class: 'table cbi-section-table' }, [
                        E('tr', { class: 'tr table-titles' }, [
                                E('th', { class: 'th' }, 'Source Network'),
                                E('th', { class: 'th' }, 'MAC Address'),
                                E('th', { class: 'th' }, 'IP Address'),
                                E('th', { class: 'th' }, 'Hostname'),
                                E('th', { class: 'th cbi-section-actions' }, 'Action')
                        ])
                ]);

                if (leases.length === 0) {
                        table.appendChild(E('tr', { class: 'tr placeholder' }, [
                                E('td', { class: 'td', colspan: 5 }, 'No active leases found.')
                        ]));
                } else {
                        for (var k = 0; k < leases.length; k++) {
                                var l = leases[k];
                                table.appendChild(E('tr', { class: 'tr' }, [
                                        E('td', { class: 'td', 'data-title': 'Source' }, l.source),
                                        E('td', { class: 'td', 'data-title': 'MAC' }, l.mac),
                                        E('td', { class: 'td', 'data-title': 'IP' }, l.ip),
                                        E('td', { class: 'td', 'data-title': 'Name' }, l.name),
                                        E('td', { class: 'td cbi-section-actions', 'data-title': 'Action' }, 
                                                E('button', {
                                                        class: 'cbi-button cbi-button-action',
                                                        click: ui.createHandlerFn(this, function() {
                                                                ui.addNotification(null, E('p', 'Static IP binding will be available in the next UI release.'));
                                                        })
                                                }, 'Make Static')
                                        )
                                ]));
                        }
                }

                return E('div', { class: 'cbi-map' }, [
                        E('h2', {}, 'Alemprator DHCP Server'),
                        E('p', { class: 'cbi-map-descr' }, 'Advanced network lease control. Manages allocations across regular LAN and Hotspot Networks in real-time.'),
                        E('div', { class: 'cbi-section' }, [
                                E('h3', {}, 'Live Leases'),
                                table
                        ])
                ]);
        },
        handleSaveApply: null,
        handleSave: null,
        handleReset: null
});
