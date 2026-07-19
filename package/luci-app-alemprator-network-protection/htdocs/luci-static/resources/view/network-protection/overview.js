'use strict';

'require rpc';
'require ui';
'require uci';

var callGetStatus = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getStatus',
	expect: { '': {} }
});

var callGetStats = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getStats',
	expect: { '': {} }
});

var callRecover = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'recover',
	expect: { '': {} }
});

var callGetLogs = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getLogs',
	params: [ 'lines', 'level' ],
	expect: { '': {} }
});

var callGetBridgeStatus = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getBridgeStatus',
	expect: { '': {} }
});

function moduleLabel(key, enabled) {
	var titles = {
		loop: 'حماية اللوب (Loop)',
		broadcast: 'عاصفة البث (Broadcast)',
		arp: 'عاصفة الـ ARP',
		dhcp_rogue: 'خادم DHCP وهمي',
		mac_flapping: 'حركة الماك (Flapping)',
		port_isolation: 'عزل المنافذ',
		rstp: 'بروتوكول RSTP'
	};

	var isChecked = enabled ? 'checked' : null;
	var checkbox = E('input', {
		'type': 'checkbox',
		'id': 'toggle_' + key,
		'checked': isChecked,
		'change': function(ev) {
			var checked = ev.target.checked;
			ui.showModal('تطبيق التغييرات', [
				E('p', { 'class': 'spinning' }, 'جاري تطبيق الإعدادات لموديول ' + (titles[key] || key) + '...')
			]);
			uci.load('alemprator-network-protection').then(function() {
				uci.set('alemprator-network-protection', key, 'enabled', checked ? '1' : '0');
				return uci.save();
			}).then(function() {
				return uci.commit();
			}).then(function() {
				setTimeout(function() {
					ui.hideModal();
					location.reload();
				}, 1000);
			}).catch(function(err) {
				ui.hideModal();
				ui.addNotification(null, E('p', {}, 'خطأ أثناء حفظ الإعدادات: ' + err));
			});
		}
	});

	var status = enabled ? E('span', { 'class': 'label label-success' }, 'نشط') : E('span', { 'class': 'label label-danger' }, 'معطّل');
	var desc = {
		loop: 'كشف حلقات إيثرنت وحركة الماك (Loop)',
		broadcast: 'مراقبة معدل حزم البث وعواصف البث',
		arp: 'كشف حركة مرور ARP غير الطبيعية',
		dhcp_rogue: 'كشف خوادم DHCP غير المصرح بها في الشبكة',
		mac_flapping: 'تتبع وفحص حركة الماك المتكررة (Flapping)',
		port_isolation: 'إدارة إعدادات عزل المنافذ',
		rstp: 'مراقبة وإدارة بروتوكول الـ RSTP'
	};
	var title = titles[key] || key;

	return E('div', { 'class': 'module-card', 'style': 'border: 1px solid #ddd; padding: 15px; border-radius: 4px; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: flex; flex-direction: column; justify-content: space-between;' }, [
		E('div', {}, [
			E('div', { 'style': 'display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;' }, [
				E('h3', { 'style': 'margin: 0; font-size: 16px;' }, title),
				E('label', { 'class': 'switch' }, [
					checkbox,
					E('span', { 'class': 'slider round' })
				])
			]),
			E('p', { 'style': 'font-size: 13px; color: #666; margin-bottom: 15px; min-height: 36px;' }, desc[key] || '')
		]),
		E('div', { 'style': 'display: flex; justify-content: space-between; align-items: center;' }, [
			status,
			E('a', { 'href': L.url('admin/network/network-protection/' + key.replace(/_/g, '-')), 'class': 'btn btn-link', 'style': 'font-size: 13px; padding: 0;' }, 'تهيئة الإعدادات ←')
		])
	]);
}

function handleError(err) {
	console.error('ubus error:', err);
	return {};
}

return L.view.extend({
	load: function() {
		return Promise.all([
			callGetStatus().catch(handleError),
			callGetStats().catch(handleError),
			callGetLogs({ lines: 5, level: 'all' }).catch(handleError),
			callGetBridgeStatus().catch(handleError)
		]);
	},

	render: function(data) {
		var status = data[0] || {};
		var stats = data[1] || {};
		var logs = data[2] || {};
		var portsData = data[3] || { ports: [], blockedMacs: [] };

		var styles = E('style', {}, 
			'.modules-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 15px; margin-top: 20px; }\n' +
			'.module-card { transition: all 0.2s ease-in-out; }\n' +
			'.module-card:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.15); }\n' +
			'.switch { position: relative; display: inline-block; width: 40px; height: 22px; margin: 0; }\n' +
			'.switch input { opacity: 0; width: 0; height: 0; }\n' +
			'.slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px; }\n' +
			'.slider:before { position: absolute; content: ""; height: 16px; width: 16px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }\n' +
			'input:checked + .slider { background-color: #2ea25f; }\n' +
			'input:focus + .slider { box-shadow: 0 0 1px #2ea25f; }\n' +
			'input:checked + .slider:before { transform: translateX(18px); }\n' +
			'.event-table, .port-table { width: 100%; border-collapse: collapse; margin-top: 10px; }\n' +
			'.event-table th, .event-table td, .port-table th, .port-table td { padding: 8px 12px; text-align: right; border-bottom: 1px solid #eee; }\n' +
			'.event-table th, .port-table th { background-color: #f7f7f7; font-weight: bold; }\n' +
			'.event-table tr:hover, .port-table tr:hover { background-color: #fafafa; }\n' +
			'.status-box table th { width: 30%; }\n' +
			'.network-protection { direction: rtl; text-align: right; }'
		);

		var content = E('div', { 'class': 'network-protection' }, [
			styles,
			E('h2', {}, 'حماية الشبكة - نظرة عامة')
		]);

		var statusBox = E('div', { 'class': 'status-box cbi-section', 'id': 'np-status' });
		var overall = E('h3', {}, 'حالة النظام');
		statusBox.appendChild(overall);

		var mainCheckbox = E('input', {
			'type': 'checkbox',
			'id': 'toggle_main',
			'checked': status.enabled ? 'checked' : null,
			'change': function(ev) {
				var checked = ev.target.checked;
				ui.showModal('تطبيق التغييرات', [
					E('p', { 'class': 'spinning' }, checked ? 'جاري تفعيل حماية الشبكة وتشغيل الخدمة...' : 'جاري إيقاف حماية الشبكة وتعطيل الخدمة...')
				]);
				uci.load('alemprator-network-protection').then(function() {
					uci.set('alemprator-network-protection', 'main', 'enabled', checked ? '1' : '0');
					return uci.save();
				}).then(function() {
					return uci.commit();
				}).then(function() {
					setTimeout(function() {
						ui.hideModal();
						location.reload();
					}, 1000);
				}).catch(function(err) {
					ui.hideModal();
					ui.addNotification(null, E('p', {}, 'خطأ أثناء تفعيل الخدمة: ' + err));
				});
			}
		});

		var tbl = E('table', { 'class': 'table' });
		
		var trStatus = E('tr', {}, [
			E('th', {}, 'تفعيل الحماية العامة'),
			E('td', {}, [
				E('label', { 'class': 'switch' }, [
					mainCheckbox,
					E('span', { 'class': 'slider round' })
				]),
				E('span', { 'style': 'margin-right: 10px; font-weight: bold; color: ' + (status.enabled ? '#2ea25f' : '#d9534f') }, status.enabled ? ' مفعّلة' : ' معطّلة')
			])
		]);
		tbl.appendChild(trStatus);

		var trRunning = E('tr');
		trRunning.innerHTML = '<th>قيد التشغيل</th><td>' + (status.running ? '<span class="label label-success">نعم</span>' : '<span class="label label-warning">لا</span>') + '</td>';
		tbl.appendChild(trRunning);

		var trEbpf = E('tr');
		trEbpf.innerHTML = '<th>محرك eBPF</th><td>' + (status.ebpf ? '<span class="label label-info">متوفر</span>' : '<span class="label label-warning">غير متوفر</span>') + '</td>';
		tbl.appendChild(trEbpf);

		var trEvents = E('tr');
		trEvents.innerHTML = '<th>عدد الأحداث</th><td>' + (stats.total_events || 0) + '</td>';
		tbl.appendChild(trEvents);

		var trUptime = E('tr');
		trUptime.innerHTML = '<th>مدة التشغيل</th><td>' + ((stats.uptime || 0) + ' ثانية') + '</td>';
		tbl.appendChild(trUptime);

		statusBox.appendChild(tbl);
		content.appendChild(statusBox);

		var actions = E('div', { 'class': 'actions', 'style': 'margin-bottom: 25px;' }, [
			E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				'click': function() { location.reload(); }
			}, 'تحديث الصفحة'),
			E('button', {
				'class': 'btn cbi-button cbi-button-reset',
				'style': 'margin-right: 10px;',
				'click': function() {
					var btn = this;
					btn.disabled = true;
					btn.textContent = 'جاري فك الحظر...';
					callRecover().then(function() {
						btn.textContent = 'تم فك الحظر';
						setTimeout(function() { btn.disabled = false; btn.textContent = 'فك حظر جميع المنافذ'; location.reload(); }, 2000);
					}).catch(function() {
						btn.textContent = 'خطأ';
						setTimeout(function() { btn.disabled = false; btn.textContent = 'فك حظر جميع المنافذ'; }, 3000);
					});
				}
			}, 'فك حظر جميع المنافذ')
		]);
		content.appendChild(actions);

		var modulesTitle = E('h3', {}, 'موديولات الحماية التفاعلية');
		content.appendChild(modulesTitle);

		var modules = E('div', { 'class': 'modules-grid' });
		if (status.modules) {
			for (var key in status.modules) {
				modules.appendChild(moduleLabel(key, status.modules[key]));
			}
		}
		content.appendChild(modules);

		var portsBox = E('div', { 'class': 'cbi-section', 'style': 'margin-top: 25px;' }, [
			E('h3', {}, 'حالة منافذ الجسر (Bridge)')
		]);

		var portTbl = E('table', { 'class': 'port-table' }, [
			E('thead', {}, [
				E('tr', {}, [
					E('th', {}, 'المنفذ'),
					E('th', {}, 'حالة الاتصال'),
					E('th', {}, 'السرعة'),
					E('th', {}, 'الحالة الأمنية'),
					E('th', {}, 'الإجراء')
				])
			])
		]);

		var portTbody = E('tbody');
		var ports = portsData.ports || [];
		if (ports.length === 0) {
			portTbody.appendChild(E('tr', {}, [
				E('td', { 'colspan': 5, 'style': 'text-align: center; color: #999;' }, 'لا توجد منافذ نشطة في الجسر br-lan.')
			]));
		} else {
			for (var i = 0; i < ports.length; i++) {
				var port = ports[i];
				var stateClass = port.state === 'up' ? 'label-success' : 'label-danger';
				var stateLabel = E('span', { 'class': 'label ' + stateClass }, port.state === 'up' ? 'متصل' : 'مفصول');

				var speedLabel = '-';
				if (port.state === 'up') {
					speedLabel = (port.speed && port.speed !== '0' && port.speed !== '-1') ? port.speed + ' Mbps' : '-';
				}

				var secClass = port.disabled ? 'label-danger' : 'label-success';
				var secText = port.disabled ? 'محظور 🔴' : 'طبيعي';
				var secLabel = E('span', { 'class': 'label ' + secClass }, secText);

				var recoverBtn = '-';
				if (port.disabled) {
					recoverBtn = E('button', {
						'class': 'btn cbi-button cbi-button-reset',
						'click': function(ev) {
							var btn = ev.target;
							btn.disabled = true;
							btn.textContent = 'فك الحظر...';
							callRecover().then(function() {
								btn.textContent = 'تم فك الحظر';
								setTimeout(function() { location.reload(); }, 1000);
							}).catch(function() {
								btn.textContent = 'خطأ';
								setTimeout(function() { btn.disabled = false; btn.textContent = 'فك الحظر'; }, 2000);
							});
						}
					}, 'فك الحظر');
				}

				portTbody.appendChild(E('tr', {}, [
					E('td', { 'style': 'font-weight: bold;' }, port.name),
					E('td', {}, stateLabel),
					E('td', {}, speedLabel),
					E('td', {}, secLabel),
					E('td', {}, recoverBtn)
				]));
			}
		}
		portTbl.appendChild(portTbody);
		portsBox.appendChild(portTbl);
		content.appendChild(portsBox);

		var blockedMacs = portsData.blockedMacs || [];
		if (blockedMacs.length > 0) {
			var blockedBox = E('div', { 'class': 'cbi-section', 'style': 'margin-top: 25px;' }, [
				E('h3', {}, 'عناوين MAC المحظورة حالياً 🔴')
			]);

			var blockedTbl = E('table', { 'class': 'port-table' }, [
				E('thead', {}, [
					E('tr', {}, [
						E('th', {}, 'عنوان MAC'),
						E('th', {}, 'وقت الحظر'),
						E('th', {}, 'الإجراء')
					])
				])
			]);

			var blockedTbody = E('tbody');
			for (var i = 0; i < blockedMacs.length; i++) {
				var bm = blockedMacs[i];
				var dateStr = '-';
				if (bm.since) {
					var date = new Date(parseInt(bm.since) * 1000);
					dateStr = date.toLocaleString('ar-EG');
				}

				var unblockBtn = E('button', {
					'class': 'btn cbi-button cbi-button-reset',
					'click': function(ev) {
						var btn = ev.target;
						btn.disabled = true;
						btn.textContent = 'جاري إلغاء الحظر...';
						callRecover().then(function() {
							btn.textContent = 'تم إلغاء الحظر';
							setTimeout(function() { location.reload(); }, 1000);
						}).catch(function() {
							btn.textContent = 'خطأ';
							setTimeout(function() { btn.disabled = false; btn.textContent = 'إلغاء الحظر'; }, 2000);
						});
					}
				}, 'إلغاء الحظر');

				blockedTbody.appendChild(E('tr', {}, [
					E('td', { 'style': 'font-family: monospace; font-weight: bold; color: #d9534f;' }, bm.mac),
					E('td', {}, dateStr),
					E('td', {}, unblockBtn)
				]));
			}
			blockedTbl.appendChild(blockedTbody);
			blockedBox.appendChild(blockedTbl);
			content.appendChild(blockedBox);
		}

		var logsBox = E('div', { 'class': 'cbi-section', 'style': 'margin-top: 25px;' }, [
			E('h3', {}, 'سجل الأحداث الأخيرة (الأمنية)')
		]);

		var logTbl = E('table', { 'class': 'event-table' }, [
			E('thead', {}, [
				E('tr', {}, [
					E('th', {}, 'الوقت'),
					E('th', {}, 'الموديول'),
					E('th', {}, 'المنفذ'),
					E('th', {}, 'عنوان MAC'),
					E('th', {}, 'السبب'),
					E('th', {}, 'مستوى الخطورة')
				])
			])
		]);

		var logTbody = E('tbody');
		var entries = logs.entries || [];
		if (entries.length === 0) {
			logTbody.appendChild(E('tr', {}, [
				E('td', { 'colspan': 6, 'style': 'text-align: center; color: #999;' }, 'لم يتم تسجيل أي أحداث أمنية بعد.')
			]));
		} else {
			for (var i = entries.length - 1; i >= 0; i--) {
				var entry = entries[i];
				try {
					var parsed = JSON.parse(entry);
					var lvlClass = 'label-default';
					var lvlText = 'معلومة';
					if (parsed.level === 'critical') {
						lvlClass = 'label-danger';
						lvlText = 'خطير 🔴';
					} else if (parsed.level === 'warning') {
						lvlClass = 'label-warning';
						lvlText = 'تحذير 🟡';
					} else if (parsed.level === 'info') {
						lvlClass = 'label-info';
						lvlText = 'إشعار 🔵';
					}

					var lvlBadge = E('span', { 'class': 'label ' + lvlClass }, lvlText);

					logTbody.appendChild(E('tr', {}, [
						E('td', {}, parsed.timestamp || '-'),
						E('td', {}, parsed.module || '-'),
						E('td', {}, parsed.port || '-'),
						E('td', {}, parsed.mac || '-'),
						E('td', {}, parsed.reason || '-'),
						E('td', {}, lvlBadge)
					]));
				} catch(e) {
					logTbody.appendChild(E('tr', {}, [
						E('td', { 'colspan': 6 }, entry)
					]));
				}
			}
		}
		logTbl.appendChild(logTbody);
		logsBox.appendChild(logTbl);
		content.appendChild(logsBox);

		return content;
	}
});
