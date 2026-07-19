'use strict';

'require rpc';

var callGetLogs = rpc.declare({
	object: 'alemprator-network-protection',
	method: 'getLogs',
	params: [ 'lines', 'level' ],
	expect: { '': {} }
});

return L.view.extend({
	load: function() {
		return callGetLogs(100, 'all').catch(function() { return { entries: [] }; });
	},

	render: function(initialLogs) {
		function formatLogEntries(r) {
			var text = '';
			var entries = (r && r.entries) ? r.entries : [];
			for (var i = 0; i < entries.length; i++) {
				try {
					var e = typeof entries[i] === 'string' ? JSON.parse(entries[i]) : entries[i];
					text += '[' + e.timestamp + '] [' + e.level + '] [' + e.module + '] ' + e.reason + ' -> ' + e.action + '\n';
				} catch(e2) {
					text += entries[i] + '\n';
				}
			}
			return text || 'لا توجد سجلات مسجلة بعد';
		}

		var initialText = formatLogEntries(initialLogs);

		var content = E('div', { 'class': 'network-protection' }, [
			E('h2', {}, 'سجلات الحماية الأمنيّة'),
			E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, 'سجل الأحداث اليومية'),
				E('div', { 'class': 'cbi-value' }, [
					E('label', { 'class': 'cbi-value-title' }, 'تصفية حسب المستوى'),
					E('div', { 'class': 'cbi-value-field' }, [
						E('select', { 'id': 'log-level', 'change': refreshLogs }, [
							E('option', { 'value': 'all' }, 'الكل (All)'),
							E('option', { 'value': 'critical' }, 'حرج (Critical)'),
							E('option', { 'value': 'warning' }, 'تحذير (Warning)'),
							E('option', { 'value': 'info' }, 'معلومات (Info)'),
							E('option', { 'value': 'debug' }, 'تنقيح (Debug)')
						]),
						E('button', {
							'class': 'btn cbi-button cbi-button-apply',
							'style': 'margin-right: 10px;',
							'click': refreshLogs
						}, 'تحديث السجل')
					])
				]),
				E('pre', {
					'id': 'log-content',
					'style': 'max-height: 600px; overflow-y: auto; background: #1e1e1e; color: #00ff66; padding: 12px; border-radius: 4px; font-family: monospace; font-size: 12px;'
				}, initialText)
			])
		]);

		function refreshLogs() {
			var el = document.getElementById('log-content');
			if (!el) return;
			el.textContent = 'جاري التحميل...';
			var levelSelect = document.getElementById('log-level');
			var level = levelSelect ? levelSelect.value : 'all';
			callGetLogs(100, level).then(function(r) {
				el.textContent = formatLogEntries(r);
			}).catch(function(err) {
				el.textContent = 'خطأ أثناء تحميل السجلات: ' + err;
			});
		}

		return content;
	}
});
