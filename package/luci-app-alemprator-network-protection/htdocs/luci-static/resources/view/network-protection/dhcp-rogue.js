'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('خادم DHCP غير مصرح به (Rogue DHCP)'),
			_('كشف وحجب خوادم DHCP الوهمية أو غير المصرح بها داخل شبكة الـ LAN.'));

		s = m.section(form.NamedSection, 'dhcp_rogue', 'dhcp_rogue', _('إعدادات الكشف'));

		o = s.option(form.Flag, 'enabled', _('تفعيل كشف خوادم DHCP الوهمية'));
		o.default = o.enabled;

		o = s.option(form.ListValue, 'action', _('الإجراء عند الكشف'));
		o.value('warn', _('تحذير فقط (Warning)'));
		o.value('block', _('حظر الخادم الوهمي (Block Rogue Server)'));
		o.default = 'warn';

		o = s.option(form.Flag, 'auto_block', _('الحظر التلقائي عند الاكتشاف'));
		o.default = o.disabled;

		return m.render();
	}
});
