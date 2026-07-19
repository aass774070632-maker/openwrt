'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('الإعدادات المتقدمة (Advanced Settings)'),
			_('تهيئة الإعدادات العامة لخدمة الحماية ومراقبة الجسور.'));

		s = m.section(form.NamedSection, 'main', 'globals', _('الإعدادات العامة'));

		o = s.option(form.Flag, 'enabled', _('تفعيل خدمة الحماية العامة'));
		o.default = o.enabled;

		o = s.option(form.Value, 'bridges', _('الجسور الخاضعة للمراقبة (Bridges)'));
		o.default = 'br-lan';

		o = s.option(form.Flag, 'auto_recover', _('الاستعادة التلقائية الشاملة'));
		o.default = o.enabled;

		o = s.option(form.Value, 'recovery_delay', _('تأخير الاستعادة الافتراضي (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '60';

		o = s.option(form.Value, 'max_actions_per_minute', _('أقصى حد للإجراءات في الدقيقة'));
		o.datatype = 'uinteger';
		o.default = '10';

		return m.render();
	}
});
