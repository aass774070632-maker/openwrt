'use strict';
'require view';
'require fs';
'require ui';
'require rpc';
'require uci';
'require form';

return view.extend({
        load: function() {
                return fs.exec_direct('/bin/sh', ['-c', 'touch /etc/config/alemprator_rules']).then(function() {
                    return Promise.all([
                            uci.load('dhcp'),
                            uci.load('alemprator_rules').catch(function(){ return null; }),
                            fs.read_direct('/tmp/dhcp.leases', 'text').catch(function(){ return ''; }),
                            fs.exec_direct('/usr/sbin/chilli_query', ['dhcp-list']).catch(function(){ return ''; }),
                            fs.exec_direct('/sbin/ip', ['neigh']).catch(function(){ return ''; })
                    ]);
                });
        },

        render: function(data) {
                var dhcpLeasesObj = data[2] || '';
                var chilliLeasesObj = data[3] || '';

                var m = new form.Map('dhcp', _('Alemprator DHCP Server'), _('Advanced network lease control. Manages allocations across regular LAN and Hotspot Networks in real-time. Same features as Mikrotik (Static, Bypass, Block, Limit).'));
                
                // --- SECTION 1: LIVE LEASES ---
                var live = m.section(form.TypedSection, '_live_leases', _('Live Dynamic Leases'));
                live.anonymous = true;
                live.render = function() {
                        var leases = [];

                        // Parse dnsmasq leases
                        var lines = dhcpLeasesObj.trim().split(/\n/);
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

                        // Parse chilli leases
                        var clines = chilliLeasesObj.trim().split(/\n/);
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
                                        E('th', { class: 'th' }, _('Source Network')),
                                        E('th', { class: 'th' }, _('MAC Address')),
                                        E('th', { class: 'th' }, _('IP Address')),
                                        E('th', { class: 'th' }, _('Hostname')),
                                        E('th', { class: 'th cbi-section-actions' }, _('Actions'))
                                ])
                        ]);

                        if (leases.length === 0) {
                                table.appendChild(E('tr', { class: 'tr placeholder' }, [
                                        E('td', { class: 'td', colspan: 5 }, E('em', {}, _('No active leases found.')))
                                ]));
                        } else {
                                for (var k = 0; k < leases.length; k++) {
                                        var l = leases[k];
                                        
                                        var btnGroup = E('div', { class: 'cbi-section-actions' }, [
                                            // Make Static
                                            E('button', {
                                                    class: 'btn cbi-button cbi-button-action',
                                                    style: 'margin-right:5px;',
                                                    click: ui.createHandlerFn(this, function(mac, ip, name) {
                                                        var section = uci.add('dhcp', 'host');
                                                        uci.set('dhcp', section, 'mac', mac);
                                                        uci.set('dhcp', section, 'ip', ip);
                                                        uci.set('dhcp', section, 'name', name.replace(/[^a-zA-Z0-9_-]/g, ''));
                                                        uci.save().then(function() {
                                                            ui.addNotification(null, E('p', _('Lease marked as static. Please save & apply.')), 'info');
                                                            m.render();
                                                        });
                                                    }, l.mac, l.ip, l.name)
                                            }, _('Make Static')),
                                            
                                            // Bypass (Walled Garden)
                                            E('button', {
                                                class: 'btn cbi-button cbi-button-save',
                                                style: 'margin-right:5px;',
                                                click: ui.createHandlerFn(this, function(mac, ip, name) {
                                                    var section = uci.add('alemprator_rules', 'bypass');
                                                    uci.set('alemprator_rules', section, 'mac', mac);
                                                    uci.set('alemprator_rules', section, 'comment', name);
                                                    uci.save().then(function() { ui.addNotification(null, E('p', _('Added to Bypass list.')), 'info'); m.render(); });
                                                }, l.mac, l.ip, l.name)
                                            }, _('Bypass Hotspot')),

                                            // Block (Drop)
                                            E('button', {
                                                class: 'btn cbi-button cbi-button-remove',
                                                style: 'margin-right:5px;',
                                                click: ui.createHandlerFn(this, function(mac, ip, name) {
                                                    var section = uci.add('alemprator_rules', 'block');
                                                    uci.set('alemprator_rules', section, 'mac', mac);
                                                    uci.set('alemprator_rules', section, 'comment', name);
                                                    uci.save().then(function() { ui.addNotification(null, E('p', _('Added to Block list.')), 'info'); m.render(); });
                                                }, l.mac, l.ip, l.name)
                                            }, _('Block Device')),

                                            // Rate Limit
                                            E('button', {
                                                class: 'btn cbi-button cbi-button-neutral',
                                                click: ui.createHandlerFn(this, function(mac, ip, name) {
                                                    var section = uci.add('alemprator_rules', 'limit');
                                                    uci.set('alemprator_rules', section, 'mac', mac);
                                                    uci.set('alemprator_rules', section, 'rx_rate', '2048'); // 2M
                                                    uci.set('alemprator_rules', section, 'tx_rate', '2048'); // 2M
                                                    uci.set('alemprator_rules', section, 'comment', name);
                                                    uci.save().then(function() { ui.addNotification(null, E('p', _('Added to Speed Limit list. Adjust values below.')), 'info'); m.render(); });
                                                }, l.mac, l.ip, l.name)
                                            }, _('Add Speed Limit'))
                                        ]);

                                        table.appendChild(E('tr', { class: 'tr' }, [
                                                E('td', { class: 'td', 'data-title': _('Source') }, l.source),
                                                E('td', { class: 'td', 'data-title': _('MAC') }, l.mac),
                                                E('td', { class: 'td', 'data-title': _('IP') }, l.ip),
                                                E('td', { class: 'td', 'data-title': _('Name') }, l.name),
                                                E('td', { class: 'td cbi-section-actions' }, btnGroup)
                                        ]));
                                }
                        }

                        return E('div', { class: 'cbi-section' }, [
                                E('h3', {}, _('Live Dynamic Leases')),
                                table
                        ]);
                };

                // --- SECTION 2: STATIC LEASES (from DHCP) ---
                var s = m.section(form.GridSection, 'host', _('Static IP Addresses'));
                s.anonymous = true;  s.addremove = true;  s.sortable  = true;
                s.option(form.Value, 'name', _('Hostname'));
                s.option(form.Value, 'mac', _('MAC-Address'));
                s.option(form.Value, 'ip', _('IPv4-Address'));
                var t = s.option(form.Value, 'leasetime', _('Lease time'), _('e.g. 12h, 3d, 1w...'));
                t.rmempty = true;

                // --- NEW MAP FOR CUSTOM RULES (Block, Bypass, Limit) ---
                var mRules = new form.Map('alemprator_rules', _('Advanced Client Rules (Mikrotik IP Bindings & Queues)'), _('Manage devices that are bypassed, blocked, or speed-limited.'));

                // Bypass Section
                var sBypass = mRules.section(form.GridSection, 'bypass', _('Bypassed MACs (IP Bindings - Bypassed)'));
                sBypass.anonymous = true; sBypass.addremove = true; sBypass.sortable = true;
                sBypass.option(form.Value, 'mac', _('Client MAC'));
                sBypass.option(form.Value, 'comment', _('Comment'));

                // Block Section
                var sBlock = mRules.section(form.GridSection, 'block', _('Blocked MACs (IP Bindings - Blocked)'));
                sBlock.anonymous = true; sBlock.addremove = true; sBlock.sortable = true;
                sBlock.option(form.Value, 'mac', _('Client MAC'));
                sBlock.option(form.Value, 'comment', _('Comment'));

                // Speed Limit Section
                var sLimit = mRules.section(form.GridSection, 'limit', _('Speed Limits (Simple Queues)'));
                sLimit.anonymous = true; sLimit.addremove = true; sLimit.sortable = true;
                sLimit.option(form.Value, 'mac', _('Client MAC'));
                var rxObj = sLimit.option(form.Value, 'rx_rate', _('Download (Kbps)'));
                rxObj.default = '2048';
                var txObj = sLimit.option(form.Value, 'tx_rate', _('Upload (Kbps)'));
                txObj.default = '2048';
                sLimit.option(form.Value, 'comment', _('Comment'));

                return Promise.all([m.render(), mRules.render()]).then(function(nodes) {
                        var container = E('div', {}, nodes);
                        return container;
                });
        }
});
