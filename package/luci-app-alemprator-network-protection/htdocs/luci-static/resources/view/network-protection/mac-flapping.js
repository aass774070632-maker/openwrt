'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('حركة الماك المتكررة (MAC Flapping)'),
			_('تتبع وفحص تنقل عنوان الـ MAC بين منافذ الجهاز المختلفة خلال فترة زمنية قصيرة.'));

		s = m.section(form.NamedSection, 'mac_flapping', 'mac_flapping', _('إعدادات الكشف'));

		o = s.option(form.Flag, 'enabled', _('تفعيل كشف تنقل الماك المتكرر'));
		o.default = o.enabled;

		o = s.option(form.ListValue, 'action', _('الإجراء عند الكشف'));
		o.value('warn', _('تحذير فقط (Warning)'));
		o.value('log', _('تسجيل في السجل (Log)'));
		o.value('disable', _('تعطيل المنفذ (Disable Port)'));
		o.default = 'warn';

		o = s.option(form.Value, 'max_flaps', _('أقصى عدد للتنقلات المسموحة'));
		o.datatype = 'uinteger';
		o.default = '10';

		o = s.option(form.Value, 'window_seconds', _('نافذة المراقبة (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '30';

		o = s.option(form.Flag, 'auto_recover', _('الاستعادة التلقائية للمنفذ'));
		o.default = o.enabled;

		o = s.option(form.Value, 'recovery_delay', _('تأخير الاستعادة (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '120';

		return m.render();
	}
});
