'use strict';
'require view';
'require fs';
'require ui';
'require rpc';
'require uci';
'require form';

return view.extend({
        load: function() {
                return Promise.all([
                        uci.load('dhcp'),
                        fs.read_direct('/tmp/dhcp.leases', 'text').catch(function(){ return ''; }),
                        fs.exec_direct('/usr/sbin/chilli_query', ['dhcp-list']).catch(function(){ return ''; }),
                        fs.exec_direct('/sbin/ip', ['neigh']).catch(function(){ return ''; })
                ]);
        },

        render: function(data) {
                var dhcpLeasesObj = data[1] || '';
                var chilliLeasesObj = data[2] || '';
                var ipNeighObj = data[3] || '';

                var m = new form.Map('dhcp', _('Alemprator DHCP Server'), _('Advanced network lease control. Manages allocations across regular LAN and Hotspot Networks in real-time.'));
                
                // Section 1: Live Dynamic Leases (Read Only View)
                var live = m.section(form.TypedSection, '_live_leases', _('Live Dynamic Leases'));
                live.anonymous = true;
                live.render = function() {
                        var leases = [];

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
                                        E('th', { class: 'th cbi-section-actions' }, _('Action'))
                                ])
                        ]);

                        if (leases.length === 0) {
                                table.appendChild(E('tr', { class: 'tr placeholder' }, [
                                        E('td', { class: 'td', colspan: 5 }, E('em', {}, _('No active leases found.')))
                                ]));
                        } else {
                                for (var k = 0; k < leases.length; k++) {
                                        var l = leases[k];
                                        
                                        var makeStaticBtn = E('button', {
                                                class: 'btn cbi-button cbi-button-action',
                                                click: ui.createHandlerFn(this, function(mac, ip, name) {
                                                    var section = uci.add('dhcp', 'host');
                                                    uci.set('dhcp', section, 'mac', mac);
                                                    uci.set('dhcp', section, 'ip', ip);
                                                    uci.set('dhcp', section, 'name', name.replace(/[^a-zA-Z0-9_-]/g, ''));
                                                    uci.save().then(function() {
                                                        ui.addNotification(null, E('p', _('Lease marked as static. Please save & apply to take effect.')), 'info');
                                                        m.render();
                                                    });
                                                }, l.mac, l.ip, l.name)
                                        }, _('Make Static'));

                                        table.appendChild(E('tr', { class: 'tr' }, [
                                                E('td', { class: 'td', 'data-title': _('Source') }, l.source),
                                                E('td', { class: 'td', 'data-title': _('MAC') }, l.mac),
                                                E('td', { class: 'td', 'data-title': _('IP') }, l.ip),
                                                E('td', { class: 'td', 'data-title': _('Name') }, l.name),
                                                E('td', { class: 'td cbi-section-actions' }, makeStaticBtn)
                                        ]));
                                }
                        }

                        return E('div', { class: 'cbi-section' }, [
                                E('h3', {}, _('Live Dynamic Leases')),
                                table
                        ]);
                };

                // Section 2: Static Leases Configuration
                var s = m.section(form.GridSection, 'host', _('Static Leases'));
                s.anonymous = true;
                s.addremove = true;
                s.sortable  = true;
                s.nodescription = true;

                s.option(form.Value, 'name', _('Hostname'));
                s.option(form.Value, 'mac', _('MAC-Address'));
                s.option(form.Value, 'ip', _('IPv4-Address'));

                var t = s.option(form.Value, 'leasetime', _('Lease time'), _('e.g. 12h, 3d, 1w...'));
                t.rmempty = true;

                return m.render();
        }
});
