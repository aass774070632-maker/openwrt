'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('عاصفة البث (Broadcast Storm)'),
			_('إدارة مراقبة وكشف عواصف البث وتقييد المعدل لحماية أداء الشبكة.'));

		s = m.section(form.NamedSection, 'broadcast', 'broadcast_storm', _('إعدادات الكشف'));

		o = s.option(form.Flag, 'enabled', _('تفعيل كشف عاصفة البث'));
		o.default = o.enabled;

		o = s.option(form.ListValue, 'action', _('الإجراء عند الكشف'));
		o.value('warn', _('تحذير فقط (Warning)'));
		o.value('rate_limit', _('تقييد المعدل (Rate Limit)'));
		o.value('disable', _('تعطيل المنفذ (Disable Port)'));
		o.default = 'rate_limit';

		o = s.option(form.Value, 'max_pps', _('أقصى معدل حزم/ثانية (Max PPS)'));
		o.datatype = 'uinteger';
		o.default = '500';

		o = s.option(form.Value, 'max_ratio', _('أقصى نسبة بث مئوية (%)'));
		o.datatype = 'range(1, 100)';
		o.default = '30';

		o = s.option(form.Value, 'storm_duration_seconds', _('مدة العاصفة بالثواني'));
		o.datatype = 'uinteger';
		o.default = '3';

		o = s.option(form.Value, 'rate_limit_kbps', _('حد تقييد السرعة (Kbps)'));
		o.datatype = 'uinteger';
		o.default = '1000';

		o = s.option(form.Flag, 'auto_recover', _('الاستعادة التلقائية للمنفذ'));
		o.default = o.enabled;

		o = s.option(form.Value, 'recovery_delay', _('تأخير الاستعادة (بالثواني)'));
		o.datatype = 'uinteger';
		o.default = '30';

		return m.render();
	}
});
