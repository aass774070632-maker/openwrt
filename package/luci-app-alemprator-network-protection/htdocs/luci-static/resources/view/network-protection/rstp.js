'use strict';

'require form';

return L.view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('alemprator-network-protection', _('بروتوكول RSTP (RSTP Protocol)'),
			_('مراقبة وإدارة إعدادات بروتوكول الشجرة الممتدة السريع (Rapid Spanning Tree Protocol).'));

		s = m.section(form.NamedSection, 'rstp', 'rstp', _('إعدادات RSTP/STP'));

		o = s.option(form.Flag, 'enabled', _('تفعيل بروتوكول STP/RSTP'));
		o.default = o.disabled;

		o = s.option(form.ListValue, 'bridge_priority', _('أولوية الجسر (Bridge Priority)'));
		o.value('32768', '32768 (افتراضي)');
		o.value('0', '0 (أعلى أولوية)');
		o.value('4096', '4096');
		o.value('8192', '8192');
		o.value('12288', '12288');
		o.value('16384', '16384');
		o.value('20480', '20480');
		o.value('24576', '24576');
		o.value('28672', '28672');
		o.default = '32768';

		o = s.option(form.Value, 'forward_delay', _('تأخير التمرير (Forward Delay) بالثواني'));
		o.datatype = 'range(4, 30)';
		o.default = '15';

		o = s.option(form.Value, 'hello_time', _('زمن الترحيب (Hello Time) بالثواني'));
		o.datatype = 'range(1, 10)';
		o.default = '2';

		o = s.option(form.Value, 'max_age', _('الحد الأقصى للعمر (Max Age) بالثواني'));
		o.datatype = 'range(6, 40)';
		o.default = '20';

		return m.render();
	}
});
