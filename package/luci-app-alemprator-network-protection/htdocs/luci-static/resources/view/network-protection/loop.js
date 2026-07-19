'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('حماية اللوب (Loop Protection)'),
			_('إدارة كشف وحماية حلقيات الإيثرنت وحركة الماك المتكررة بين المنافذ.'));

		s = m.section(form.NamedSection, 'loop', 'loop_protection', _('إعدادات الموديول'));

		o = s.option(form.Flag, 'enabled', _('تفعيل كشف اللوب'));
		o.default = o.enabled;

		o = s.option(form.ListValue, 'action', _('الإجراء عند الكشف'));
		o.value('warn', _('تحذير فقط (Warning)'));
		o.value('log', _('تسجيل في السجل (Log)'));
		o.value('disable', _('تعطيل المنفذ (Disable Port)'));
		o.value('isolate', _('عزل المنفذ (Isolate Port)'));
		o.default = 'warn';

		o = s.option(form.Value, 'max_mac_moves', _('أقصى عدد لحركات الماك'));
		o.datatype = 'uinteger';
		o.default = '5';

		o = s.option(form.Value, 'window_seconds', _('نافذة المراقبة (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '10';

		o = s.option(form.Flag, 'auto_recover', _('الاستعادة التلقائية للمنفذ'));
		o.default = o.enabled;

		o = s.option(form.Value, 'recovery_delay', _('تأخير الاستعادة (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '60';

		return m.render();
	}
});
