'use strict';

'require rpc';

var callGetStats = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getStats',
	expect: { '': {} }
});

var callGetStatus = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getStatus',
	expect: { '': {} }
});

var callGetActionState = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getActionState',
	expect: { '': {} }
});

return L.view.extend({
	load: function() {
		return Promise.all([
			callGetStats().catch(function() { return {}; }),
			callGetStatus().catch(function() { return {}; }),
			callGetActionState().catch(function() { return {}; })
		]);
	},

	render: function(data) {
		var stats = data[0] || {};
		var status = data[1] || {};
		var actions = data[2] || {};

		var content = E('div', { 'class': 'network-protection', 'style': 'direction: rtl; text-align: right;' }, [
			E('h2', {}, 'إحصائيات الحماية والأداء'),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, 'ملخص الإحصائيات العامة'),
				E('table', { 'class': 'table' }, [
					E('tr', {}, [ E('th', {}, 'المؤشر'), E('th', {}, 'القيمة') ]),
					E('tr', {}, [ E('td', {}, 'حالة الخدمة'), E('td', {}, status.running ? E('span', { 'class': 'label label-success' }, 'قيد التشغيل') : E('span', { 'class': 'label label-danger' }, 'متوقفة')) ]),
					E('tr', {}, [ E('td', {}, 'إجمالي الأحداث المسجلة'), E('td', {}, '' + (stats.total_events || 0)) ]),
					E('tr', {}, [ E('td', {}, 'مدة التشغيل الحالية'), E('td', {}, '' + (stats.uptime || 0) + ' ثانية') ]),
					E('tr', {}, [ E('td', {}, 'حجم ملف السجل'), E('td', {}, '' + (stats.log_size || 0) + ' بايت') ])
				])
			]),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, 'سجل الإجراءات والتنفيذ الفوري'),
				E('pre', { 'style': 'background: #1e1e1e; color: #00ff66; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px;' }, actions.state || 'لا توجد إجراءات حظر نشطة حالياً')
			])
		]);

		return content;
	}
});
