'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('عزل المنافذ (Port Isolation)'),
			_('إدارة إعدادات عزل المنافذ والفصل الآمن للشبكات الوهمية (VLAN).'));

		s = m.section(form.NamedSection, 'port_isolation', 'port_isolation', _('إعدادات العزل'));

		o = s.option(form.Flag, 'enabled', _('تفعيل عزل المنافذ'));
		o.default = o.disabled;

		o = s.option(form.Value, 'guest_vlan', _('معرف VLAN الزوار (Guest VLAN ID)'));
		o.datatype = 'uinteger';
		o.default = '100';

		o = s.option(form.Value, 'quarantine_bridge', _('جسر الحجر (Quarantine Bridge)'));
		o.default = 'br-lan';

		return m.render();
	}
});
