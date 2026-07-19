'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('عاصفة الـ ARP (ARP Storm)'),
			_('إدارة كشف ومكافحة حزم ARP الضارة وعواصف الـ ARP في الشبكة.'));

		s = m.section(form.NamedSection, 'arp', 'arp_storm', _('إعدادات الكشف'));

		o = s.option(form.Flag, 'enabled', _('تفعيل كشف عاصفة الـ ARP'));
		o.default = o.enabled;

		o = s.option(form.ListValue, 'action', _('الإجراء عند الكشف'));
		o.value('warn', _('تحذير فقط (Warning)'));
		o.value('rate_limit', _('تقييد المعدل (Rate Limit)'));
		o.value('disable', _('تعطيل المنفذ (Disable Port)'));
		o.default = 'warn';

		o = s.option(form.Value, 'max_arp_pps', _('أقصى معدل حزم ARP/ثانية'));
		o.datatype = 'uinteger';
		o.default = '100';

		o = s.option(form.Flag, 'exclude_gateway', _('استثناء البوابة الافتراضية (Gateway)'));
		o.default = o.enabled;

		return m.render();
	}
});
