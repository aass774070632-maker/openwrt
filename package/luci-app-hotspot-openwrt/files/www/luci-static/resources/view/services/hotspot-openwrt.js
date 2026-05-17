'use strict';
'require view';
'require fs';
'require poll';
'require rpc';
'require uci';
'require ui';

var STATUS_CMD = '/usr/libexec/hotspot-openwrt/status-json';
var APPLY_CMD = '/usr/libexec/hotspot-openwrt/apply';
var PORTAL_UPLOAD_CMD = '/usr/libexec/hotspot-openwrt/portal-upload';
var PORTAL_UPLOAD_TMP = '/tmp/hotspot-openwrt-upload';
var LOGS_CMD = '/usr/libexec/hotspot-openwrt/logs';
var EXPORT_CMD = '/usr/libexec/hotspot-openwrt/export-config';
var IMPORT_CMD = '/usr/libexec/hotspot-openwrt/import-config';
var GEN_SSL_CMD = '/usr/libexec/hotspot-openwrt/gen-ssl';
var STYLE_ID = 'hotspot-openwrt-styles';

var FIELD_GROUPS = {
	server: [
		{ option: 'wan_interface', label: 'مدخل الإنترنت', hint: 'اختر واجهة OpenWrt المتصلة براوتر MikroTik. ستظهر الواجهة مع الكرت أو الجسر المرتبط بها.', placeholder: 'lan', choices: getNetworkChoices },
		{ option: 'subscriber_interface', label: 'واجهة الهوتسبوت', hint: 'واجهة المشتركين التي سيأخذها CoovaChilli. القيمة الآمنة الافتراضية هي hotspot.', placeholder: 'hotspot', choices: getSubscriberInterfaceChoices },
		{ option: 'bridge_ports', label: 'منافذ المشتركين', hint: 'اختر كرتًا أو أكثر للمشتركين. اتركه فارغًا عند استخدام WiFi فقط.', placeholder: 'lan4', choices: getBridgePortChoices, multiple: true },
		{ option: 'wifi_iface', label: 'واجهة WiFi', hint: 'اختر قسم WiFi الذي سيبث شبكة الهوتسبوت.', placeholder: 'hotspot_openwrt_radio0_ap', choices: getWifiChoices }
	],
	profile: [
		{ option: 'hotspot_ip', label: 'عنوان الهوتسبوت', hint: 'يمتلكه tun0 فقط، وليس br-hotspot', placeholder: '192.168.10.1' },
		{ option: 'hotspot_cidr', label: 'قناع الشبكة CIDR', hint: 'غالبًا 24', placeholder: '24' },
		{ option: 'pool_start', label: 'بداية عناوين العملاء', hint: 'مثل Address Pool في MikroTik', placeholder: '192.168.10.10' },
		{ option: 'pool_end', label: 'نهاية عناوين العملاء', hint: 'آخر IP يوزعه CoovaChilli', placeholder: '192.168.10.254' },
		{ option: 'domain', label: 'DNS Name', hint: 'اسم داخلي للبوابة', placeholder: 'hotspot.local' },
		{ option: 'session_timeout', label: 'Session Timeout', hint: 'none أو مدة مثل 01:00:00. يطبق كـ CoovaChilli defsessiontimeout عند تحديد مدة.', placeholder: 'none' },
		{ option: 'idle_timeout', label: 'Idle Timeout', hint: 'none أو مدة مثل 00:10:00. يطبق كـ CoovaChilli defidletimeout عند تحديد مدة.', placeholder: 'none' },
		{ option: 'status_autorefresh', label: 'Status Autorefresh', hint: 'فترة تحديث صفحة الحالة، مثل 00:01:00.', placeholder: '00:01:00' },
		{ option: 'shared_users', label: 'Shared Users', hint: 'عدد الجلسات لنفس المستخدم. يفضل ضبط enforcement النهائي من MikroTik User Manager.', placeholder: '3' },
		{ option: 'rate_limit_rx_tx', label: 'Rate Limit (rx/tx)', hint: 'اختياري مثل 2M/5M. يطبق كحد افتراضي upload/download إذا لم يرجعه RADIUS.', placeholder: '2M/5M' },
		{ option: 'mac_cookie_enabled', label: 'Add MAC Cookie', hint: 'يحفظ MAC وIP واسم الكرت بعد نجاح الدخول، ثم يسمح بالدخول التلقائي لنفس الجهاز لاحقًا مثل MikroTik Cookies.', type: 'checkbox' },
		{ option: 'open_status_page', label: 'Open Status Page', hint: 'اختيار طريقة فتح صفحة الحالة بعد الدخول.', placeholder: 'always', choices: getOpenStatusPageChoices },
		{ option: 'terms_enabled', label: 'صفحة الشروط', hint: 'اعرض الشروط قبل تسجيل الدخول', type: 'checkbox' }
	],
	portal: [
		{ option: 'portal_path', label: 'رابط صفحة الهوتسبوت', hint: 'المسار الذي يفتحه العميل داخل المتصفح', placeholder: '/hotspot' },
		{ option: 'portal_storage_path', label: 'مكان حفظ الصفحة', hint: 'المجلد على الراوتر. يجب أن يكون داخل /www حتى يخدمه uhttpd', placeholder: '/www/hotspot' },
		{ option: 'network_name', label: 'اسم الشبكة', hint: 'يظهر في أعلى صفحة الدخول', placeholder: 'Hotspot OpenWrt' },
		{ option: 'available_speeds', label: 'قائمة السرعات المتاحة للمشتركين', hint: 'أدخل خيارات السرعة، سطر لكل خيار. الصيغة: (السرعة الاسم). مثال: 1M/2M باقة_عادية', multiline: true, placeholder: '1M/2M Standard\n2M/4M Fast' },
		{ option: 'support_phone', label: 'رقم الدعم الفني', hint: 'يظهر كزر تواصل في أسفل الصفحة', placeholder: '777000000' },
		{ option: 'logo_url', label: 'رابط الشعار', hint: 'رابط صورة تظهر في الأعلى (يمكن تركه فارغاً)', placeholder: '/hotspot/logo.png' },
		{ option: 'notice_text', label: 'تنبيه للمشتركين', hint: 'نص يظهر بشكل بارز للتنبيهات', placeholder: 'أهلاً بكم في شبكتنا' },
		{ option: 'speedtest_enabled', label: 'تفعيل فحص السرعة في صفحة الحالة', hint: 'يظهر زر للمشترك لقياس سرعة اتصاله الحقيقية بالراوتر', type: 'checkbox' },
		{ option: 'login_mode', label: 'طريقة تسجيل الدخول', hint: 'اختر ما إذا كان المشترك يحتاج لإدخال رقم الكرت فقط أو مع كلمة سر.', placeholder: 'both', choices: getLoginModeChoices },
		{ option: 'captive_notify', label: 'إظهار نافذة الدخول تلقائيًا', hint: 'يضيف DHCP option 114 وapi.json لتتعرف الهواتف على الكابتف بورتال', type: 'checkbox' },
		{ option: 'browser_cookie_enabled', label: 'Browser Cookie', hint: 'يتذكر المتصفح رقم الكرت محليًا عند فتح صفحة الدخول', type: 'checkbox' },
		{ option: 'browser_cookie_days', label: 'مدة كوكي المتصفح بالأيام', hint: 'من 1 إلى 365 يومًا', placeholder: '7' }
	],
	radius: [
		{ option: 'radius_server', label: 'MikroTik User Manager', hint: 'عنوان RADIUS server', placeholder: '192.168.1.2' },
		{ option: 'radius_server2', label: 'RADIUS Fallback Server', hint: 'خادم RADIUS احتياطي (اختياري). اتركه فارغاً لاستخدام نفس الخادم.', placeholder: '' },
		{ option: 'radius_secret', label: 'RADIUS Secret', hint: 'يجب أن يطابق secret في MikroTik', placeholder: '123456', password: true },
		{ option: 'radius_auth_port', label: 'Auth Port UDP', hint: 'ثابت 1812', placeholder: '1812' },
		{ option: 'radius_acct_port', label: 'Accounting Port UDP', hint: 'ثابت 1813', placeholder: '1813' },
		{ option: 'radius_nas_ip', label: 'NAS IP', hint: 'عنوان هذا الراوتر كما يراه MikroTik User Manager. غالبًا 192.168.1.20.', placeholder: '192.168.1.20', choices: getLocalIpChoices },
		{ option: 'radius_nas_id', label: 'NAS ID', hint: 'اسم هذا الهوتسبوت عند MikroTik', placeholder: 'KT-KM14-102H-HOTSPOT' },
		{ option: 'acct_interim', label: 'Accounting Interim (ثانية)', hint: 'مدة إرسال Interim-Update لـ RADIUS بالثواني. القيمة الافتراضية 60.', placeholder: '60' },
		{ option: 'coa_enabled', label: 'CoA / Disconnect (RFC 3576)', hint: 'يفعّل استقبال أوامر قطع الجلسة من RADIUS على UDP 3799. يجب أن يدعمها خادم RADIUS.', type: 'checkbox' },
		{ option: 'userman_rest_enabled', label: 'قراءة رصيد User Manager', hint: 'يفعل جسر RouterOS REST لعرض الرصيد والبروفايل ووقت الانتهاء في صفحة المشترك.', type: 'checkbox' },
		{ option: 'userman_rest_scheme', label: 'RouterOS REST Scheme', hint: 'استخدم https مع www-ssl. يمكن استخدام http للاختبار فقط.', placeholder: 'https', choices: getRouterOsSchemeChoices },
		{ option: 'userman_rest_host', label: 'RouterOS REST Host', hint: 'غالبًا نفس MikroTik User Manager.', placeholder: '192.168.1.2' },
		{ option: 'userman_rest_port', label: 'RouterOS REST Port', hint: '443 لـ www-ssl أو 80 لـ www.', placeholder: '443' },
		{ option: 'userman_rest_username', label: 'RouterOS API User', hint: 'مستخدم قراءة فقط على MikroTik بصلاحيات User Manager.', placeholder: 'hotspot-read' },
		{ option: 'userman_rest_password', label: 'RouterOS API Password', hint: 'تحفظ على الراوتر فقط ولا ترسل للمتصفح.', placeholder: '', password: true },
		{ option: 'userman_rest_insecure_ssl', label: 'قبول شهادة HTTPS ذاتية', hint: 'مفيد مع شهادة MikroTik ذاتية التوقيع.', type: 'checkbox' },
		{ option: 'userman_rest_cacert', label: 'CA Certificate Path', hint: 'مسار ملف شهادة CA على الراوتر لتحقق HTTPS بدون تعطيل التحقق. مثال: /etc/ssl/certs/mikrotik-ca.crt', placeholder: '' },
		{ option: 'userman_rest_user_field', label: 'حقل البحث عن الكرت', hint: 'غالبًا name، ويمكن تغييره إلى username حسب إصدار User Manager.', placeholder: 'name' },
		{ option: 'userman_rest_timeout', label: 'مهلة REST بالثواني', hint: 'مهلة قصيرة حتى لا تتأخر صفحة المشترك.', placeholder: '5' }
	],
	dns: [
		{ option: 'dns1', label: 'DNS Server 1', hint: 'يستخدمه الراوتر خلف البوابة', placeholder: '8.8.8.8' },
		{ option: 'dns2', label: 'DNS Server 2', hint: 'اختياري', placeholder: '82.114.163.31' },
		{ option: 'walled_garden', label: 'Walled Garden Domains', hint: 'نطاقات مسموحة قبل الدخول، سطر لكل نطاق', multiline: true, placeholder: 'neverssl.com\nconnectivitycheck.gstatic.com' },
		{ option: 'walled_garden_ip', label: 'Walled Garden IPs/CIDRs', hint: 'عناوين IP أو CIDR مسموحة قبل الدخول (للوصول عبر HTTPS أيضاً). سطر لكل عنوان.', multiline: true, placeholder: '1.2.3.4\n5.6.7.0/24' }
	],
	security: [
		{ option: 'uamssl_enabled', label: 'UAM SSL (HTTPS Portal)', hint: 'يفعّل صفحة الدخول عبر HTTPS على المنفذ 3991. كلمة المرور تُرسل مشفرة.', type: 'checkbox' },
		{ option: 'uamssl_cert', label: 'SSL Certificate Path', hint: 'مسار ملف الشهادة (.crt) على الراوتر.', placeholder: '/etc/chilli/hotspot.crt' },
		{ option: 'uamssl_key', label: 'SSL Key Path', hint: 'مسار ملف المفتاح الخاص (.key) على الراوتر.', placeholder: '/etc/chilli/hotspot.key' }
	],
	advanced: [
		{ option: 'trial_enabled', label: 'Trial Users (تجربة مجانية)', hint: 'يسمح لأي جهاز بالدخول المجاني المحدود بدون كرت. يتم إعادة التوجيه للبورتال بعد انتهاء الفترة.', type: 'checkbox' },
		{ option: 'trial_duration', label: 'مدة التجربة (دقائق)', hint: 'الفترة الزمنية بين جلسات التجربة المجانية (دقائق).', placeholder: '30' },
		{ option: 'trial_uptime_limit', label: 'حد وقت التجربة (دقائق)', hint: 'إجمالي وقت التجربة المسموح به لكل جهاز.', placeholder: '30' },
		{ option: 'mac_auth_enabled', label: 'MAC Authentication', hint: 'يسمح لأجهزة مسجلة في User Manager بـ MAC address كـ username بالدخول التلقائي بدون بورتال.', type: 'checkbox' },
		{ option: 'mac_auth_suffix', label: 'MAC Auth Suffix', hint: 'يُضاف لـ MAC عند إرساله لـ RADIUS. مثال: @mac', placeholder: '@mac' },
		{ option: 'mac_auth_password', label: 'MAC Auth Password', hint: 'كلمة مرور ثابتة لجلسات MAC Auth.', placeholder: 'mac', password: true }
	],
	bindings: [
		{ option: 'ip_binding', label: 'IP Bindings', hint: 'صيغة مبسطة: type mac address comment. النوع blocked يمنع تسجيل دخول الجهاز، والنوع bypassed يمرر الجهاز للإنترنت مباشرة دون صفحة الدخول.', multiline: true, placeholder: 'blocked 00:11:22:33:44:55 192.168.10.11 phone\nbypassed 36:5D:F3:EF:19:25 - manager' }
	],
	active: [
		{ option: 'keepalive_timeout', label: 'مدة طرد المنفصلين من Active / Hosts', hint: 'إذا اختفى الجهاز من شبكة الهوتسبوت، يتم إخراجه من Active أو حذفه من Hosts بعد هذه المدة. اكتب مدة مثل 00:02:00 أو none لتعطيله.', placeholder: '00:02:00' }
	]
};

var TABS = [
	{ key: 'server', label: 'Server' },
	{ key: 'profile', label: 'Server Profile' },
	{ key: 'portal', label: 'Login Page' },
	{ key: 'radius', label: 'RADIUS' },
	{ key: 'active', label: 'Active / Hosts / الطرد' },
	{ key: 'bindings', label: 'IP Bindings' },
	{ key: 'dns', label: 'Walled Garden' },
	{ key: 'security', label: 'Security' },
	{ key: 'advanced', label: 'Advanced' },
	{ key: 'cookies', label: 'Cookies' },
	{ key: 'stats', label: 'Statistics' },
	{ key: 'logs', label: 'السجل' },
	{ key: 'apply', label: 'Review' }
];

function notify(message) {
	ui.addNotification(null, E('p', {}, message));
}

function addChoice(choices, value, label) {
	if (!value)
		return;

	for (var i = 0; i < choices.length; i++) {
		if (choices[i].value == value)
			return;
	}

	choices.push({ value: value, label: label || value });
}

function sectionName(section) {
	return section && section['.name'] ? section['.name'] : '';
}

function networkLabel(section) {
	var name = sectionName(section);
	var device = section.device || section.ifname || '';
	var proto = section.proto || '';
	var parts = [ name ];

	if (device)
		parts.push('(' + device + ')');
	if (proto)
		parts.push('- ' + proto);

	return parts.join(' ');
}

function getNetworkChoices() {
	var choices = [];
	var current = getValue('wan_interface');

	uci.sections('network', 'interface').forEach(function(section) {
		var name = sectionName(section);

		if (name == 'loopback')
			return;

		addChoice(choices, name, networkLabel(section));
	});

	addChoice(choices, current, current + ' (الحالي)');
	return choices;
}

function getSubscriberInterfaceChoices() {
	var choices = [];
	var current = getValue('subscriber_interface') || 'hotspot';

	addChoice(choices, 'hotspot', 'hotspot (واجهة مشتركين جديدة وآمنة)');

	uci.sections('network', 'interface').forEach(function(section) {
		var name = sectionName(section);

		if (name == 'loopback' || name == 'lan' || name == 'wan' || name == 'wan6')
			return;

		addChoice(choices, name, networkLabel(section));
	});

	addChoice(choices, current, current + ' (الحالي)');
	return choices;
}

function getBridgePortChoices() {
	var choices = [];
	var current = readList('bridge_ports');
	var blocked = { 'lan': true, 'br-lan': true, 'hotspot': true, 'br-hotspot': true, 'lo': true };

	uci.sections('network', 'device').forEach(function(section) {
		var name = section.name || sectionName(section);
		var type = section.type || 'device';

		if (blocked[name])
			return;

		addChoice(choices, name, name + ' (' + type + ')');
	});

	uci.sections('network', 'interface').forEach(function(section) {
		var device = section.device || section.ifname || '';

		String(device).split(/[\s,]+/).forEach(function(name) {
			if (!name || blocked[name])
				return;
			addChoice(choices, name, name + ' (من ' + sectionName(section) + ')');
		});
	});

	current.forEach(function(name) {
		addChoice(choices, name, name + ' (الحالي)');
	});

	return choices;
}

function getLoginModeChoices() {
	return [
		{ value: 'username', label: 'رقم الكرت فقط (Voucher)' },
		{ value: 'both', label: 'اسم مستخدم وكلمة سر' }
	];
}

function getWifiChoices() {
	var choices = [];
	var current = getValue('wifi_iface');

	addChoice(choices, '', 'بدون WiFi مخصص');

	uci.sections('wireless', 'wifi-iface').forEach(function(section) {
		var name = sectionName(section);
		var ssid = section.ssid || 'بدون SSID';
		var device = section.device || '';
		var network = section.network || '';
		var disabled = section.disabled == '1' ? ' - معطل' : '';

		addChoice(choices, name, name + ' - ' + ssid + (device ? ' (' + device + ')' : '') + (network ? ' -> ' + network : '') + disabled);
	});

	addChoice(choices, current, current + ' (الحالي)');
	return choices;
}

function getLocalIpChoices() {
	var choices = [];
	var current = getValue('radius_nas_ip');

	uci.sections('network', 'interface').forEach(function(section) {
		var name = sectionName(section);
		var ipaddr = section.ipaddr;

		if (Array.isArray(ipaddr)) {
			ipaddr.forEach(function(ip) {
				addChoice(choices, ip, ip + ' (' + name + ')');
			});
		}
		else if (ipaddr) {
			addChoice(choices, ipaddr, ipaddr + ' (' + name + ')');
		}
	});

	addChoice(choices, current || '192.168.1.20', (current || '192.168.1.20') + ' (الحالي/المقترح)');
	return choices;
}

function getOpenStatusPageChoices() {
	return [
		{ value: 'always', label: 'always - افتح صفحة الحالة دائمًا' },
		{ value: 'http-login', label: 'http-login - بعد دخول المتصفح' },
		{ value: 'none', label: 'none - لا تفتح تلقائيًا' }
	];
}

function getRouterOsSchemeChoices() {
	return [
		{ value: 'https', label: 'https - www-ssl' },
		{ value: 'http', label: 'http - اختبار فقط' }
	];
}

function readList(option) {
	var value = uci.get('hotspot_openwrt', 'main', option);

	if (Array.isArray(value))
		return value;

	if (!value)
		return [];

	return String(value).split(/[\s,]+/).filter(Boolean);
}

function readLineList(option) {
	var value = uci.get('hotspot_openwrt', 'main', option);

	if (Array.isArray(value))
		return value.filter(function(item) { return String(item || '').trim(); });

	if (!value)
		return [];

	return String(value).split(/\n+/).map(function(item) { return item.trim(); }).filter(Boolean);
}

function firstDns(index) {
	var dns = readList('dns');
	return dns[index] || '';
}

function getValue(option) {
	if (option == 'dns1')
		return firstDns(0);
	if (option == 'dns2')
		return firstDns(1);
	if (option == 'walled_garden')
		return readList('walled_garden').join('\n');
	if (option == 'walled_garden_ip')
		return readList('walled_garden_ip').join('\n');
	if (option == 'ip_binding')
		return readLineList('ip_binding').join('\n');
	if (option == 'terms_enabled' || option == 'captive_notify' || option == 'browser_cookie_enabled' || option == 'mac_cookie_enabled' || option == 'userman_rest_enabled' || option == 'userman_rest_insecure_ssl' || option == 'uamssl_enabled' || option == 'coa_enabled' || option == 'trial_enabled' || option == 'mac_auth_enabled' || option == 'speedtest_enabled')
		return uci.get('hotspot_openwrt', 'main', option) == '1';

	return uci.get('hotspot_openwrt', 'main', option) || '';
}

function fieldId(option) {
	return 'hotspot-openwrt-' + option.replace(/_/g, '-');
}

function collectValue(option) {
	var node = document.getElementById(fieldId(option));

	if (!node)
		return '';

	if (node.type == 'checkbox')
		return node.checked ? '1' : '0';

	if (node.tagName == 'SELECT' && node.multiple) {
		return Array.prototype.map.call(node.selectedOptions, function(option) {
			return option.value;
		}).filter(Boolean).join(' ');
	}

	return node.value.trim();
}

function ensureMainSection() {
	if (!uci.get('hotspot_openwrt', 'main'))
		uci.add('hotspot_openwrt', 'hotspot', 'main');
}

function saveConfig() {
	var dns = [];
	var walledGarden = [];
	var walledGardenIp = [];
	var ipBindings = [];
	var groups = Object.keys(FIELD_GROUPS);
	var i;

	ensureMainSection();

	for (i = 0; i < groups.length; i++) {
		FIELD_GROUPS[groups[i]].forEach(function(field) {
			var value;

			if (field.option == 'dns1' || field.option == 'dns2' || field.option == 'walled_garden' || field.option == 'walled_garden_ip' || field.option == 'ip_binding')
				return;

			value = collectValue(field.option);
			uci.set('hotspot_openwrt', 'main', field.option, value);
		});
	}

	[ collectValue('dns1'), collectValue('dns2') ].forEach(function(value) {
		if (value)
			dns.push(value);
	});

	collectValue('walled_garden').split(/[\n,\s]+/).forEach(function(value) {
		if (value)
			walledGarden.push(value);
	});

	collectValue('walled_garden_ip').split(/[\n,\s]+/).forEach(function(value) {
		if (value)
			walledGardenIp.push(value);
	});

	collectValue('ip_binding').split(/\n+/).forEach(function(value) {
		value = value.trim();
		if (value)
			ipBindings.push(value);
	});

	if (dns.length)
		uci.set('hotspot_openwrt', 'main', 'dns', dns);
	else
		uci.unset('hotspot_openwrt', 'main', 'dns');

	if (walledGarden.length)
		uci.set('hotspot_openwrt', 'main', 'walled_garden', walledGarden);
	else
		uci.unset('hotspot_openwrt', 'main', 'walled_garden');

	if (walledGardenIp.length)
		uci.set('hotspot_openwrt', 'main', 'walled_garden_ip', walledGardenIp);
	else
		uci.unset('hotspot_openwrt', 'main', 'walled_garden_ip');

	if (ipBindings.length)
		uci.set('hotspot_openwrt', 'main', 'ip_binding', ipBindings);
	else
		uci.unset('hotspot_openwrt', 'main', 'ip_binding');

	uci.set('hotspot_openwrt', 'main', 'enabled', '0');

	return uci.save().then(function() {
		return uci.apply();
	});
}

function fetchStatus() {
	return L.resolveDefault(fs.exec_direct(STATUS_CMD, [], 'json'), {});
}

function ensureStyles() {
	var style;

	if (document.getElementById(STYLE_ID))
		return;

	style = document.createElement('style');
	style.id = STYLE_ID;
	style.textContent = [
		'.hotspot-openwrt-shell{max-width:1180px;margin:0 auto;display:grid;grid-template-columns:minmax(260px,320px) minmax(0,1fr);gap:18px;align-items:start}',
		'@media(max-width:980px){.hotspot-openwrt-shell{grid-template-columns:1fr}}',
		'.hotspot-card{border:1px solid #d7e3ea;border-radius:8px;background:#fff;padding:16px;box-shadow:0 8px 24px rgba(15,23,42,.05)}',
		'.hotspot-hero{background:linear-gradient(135deg,#073b4c,#0f766e 62%,#c97a12);color:#fff}',
		'.hotspot-hero h2{margin:0;font-size:26px;line-height:1.25;color:#fff}',
		'.hotspot-hero p{margin:8px 0 0;color:rgba(255,255,255,.88);line-height:1.7}',
		'.hotspot-status-grid{display:grid;grid-template-columns:1fr;gap:9px;margin-top:12px}',
		'.hotspot-status-item{border:1px solid #e0ebf1;background:#f8fbfc;border-radius:8px;padding:10px 12px}',
		'.hotspot-status-item span{display:block;color:#637282;font-size:12px}',
		'.hotspot-status-item strong{display:block;margin-top:4px;color:#102a43;word-break:break-word}',
		'.hotspot-tabs{display:flex;gap:6px;flex-wrap:wrap;margin:14px 0}',
		'.hotspot-tab{border:1px solid #d6e2ef;background:#fff;border-radius:999px;padding:8px 12px;cursor:pointer;font-weight:700;color:#25364a}',
		'.hotspot-tab.is-active{background:#0f766e;color:#fff;border-color:#0f766e}',
		'.hotspot-panel{display:none}',
		'.hotspot-panel.is-active{display:block}',
		'.hotspot-field{display:grid;grid-template-columns:minmax(150px,220px) minmax(0,1fr);gap:12px;padding:11px 0;border-top:1px solid #edf2f7}',
		'.hotspot-field:first-child{border-top:0}',
		'@media(max-width:640px){.hotspot-field{grid-template-columns:1fr}}',
		'.hotspot-field label{font-weight:700;color:#12344d}',
		'.hotspot-field small{display:block;margin-top:4px;color:#6b7a8b;line-height:1.5}',
		'.hotspot-field input,.hotspot-field textarea,.hotspot-field select{width:100%;max-width:420px;box-sizing:border-box;border:1px solid #cbd8e6;border-radius:6px;padding:8px 10px;background:#fff}',
		'.hotspot-field textarea{min-height:116px;font-family:monospace;direction:ltr;text-align:left}',
		'.hotspot-field select[multiple]{min-height:118px}',
		'.hotspot-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:10px}',
		'.hotspot-summary .hotspot-status-item{background:#fbfdff}',
		'.hotspot-actions{display:flex;gap:10px;flex-wrap:wrap;justify-content:flex-end;margin-top:16px;padding-top:14px;border-top:1px solid #e4edf3}',
		'.hotspot-note{border:1px solid #f1c27d;background:#fff7eb;color:#7c3f00;border-radius:8px;padding:10px 12px;line-height:1.7;margin-top:12px}',
		'.hotspot-table{width:100%;border-collapse:collapse;margin-top:10px}',
		'.hotspot-table th,.hotspot-table td{border:1px solid #e2ebf1;padding:8px 10px;text-align:right}',
		'.hotspot-table th{background:#f7fafb;color:#12344d}',
		'.hotspot-table td{word-break:break-word}',
		'.hotspot-list-title{display:flex;align-items:center;justify-content:space-between;gap:10px;margin:16px 0 4px}',
		'.hotspot-list-title h3{margin:0;color:#12344d;font-size:18px}',
		'.hotspot-badge{display:inline-flex;align-items:center;justify-content:center;min-width:24px;height:24px;border-radius:999px;background:#e8f5f2;color:#0f766e;font-weight:800}',
		'.hotspot-badge.is-host{background:#fff3df;color:#9a5b00}',
		'.hotspot-empty{border:1px dashed #cbd8e6;border-radius:8px;padding:12px;margin-top:10px;color:#64748b;background:#fbfdff}',
		'.hotspot-upload{margin-top:14px;border-top:1px solid #edf2f7;padding-top:14px}',
		'.hotspot-upload-row{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-top:8px}',
		'.hotspot-upload-row input[type="text"]{width:100%;max-width:280px;box-sizing:border-box;border:1px solid #cbd8e6;border-radius:6px;padding:8px 10px}',
		'.hotspot-upload-progress{color:#475569;font-weight:700}'
	].join('\n');

	document.head.appendChild(style);
}

function statusText(value, yes, no) {
	return value ? yes : no;
}

function statusItem(label, value) {
	var content = value == null || value === '' ? '-' : value;

	return E('div', { 'class': 'hotspot-status-item' }, [
		E('span', {}, label),
		E('strong', {}, Array.isArray(content) || (content && content.nodeType) ? content : String(content))
	]);
}

function renderField(field) {
	var input;
	var value = getValue(field.option);
	var choices = null;
	if (typeof field.choices === 'function') {
		choices = field.choices();
	} else if (Array.isArray(field.choices)) {
		choices = field.choices;
	}

	if (choices) {
		var selected = field.multiple ? readList(field.option) : [ String(value || '') ];

		input = E('select', {
			'id': fieldId(field.option),
			'multiple': field.multiple ? 'multiple' : null
		}, choices.map(function(choice) {
			return E('option', {
				'value': choice.value,
				'selected': selected.indexOf(choice.value) > -1 ? 'selected' : null
			}, choice.label || choice.value);
		}));
	}
	else if (field.multiline) {
		input = E('textarea', {
			'id': fieldId(field.option),
			'placeholder': field.placeholder || ''
		}, value);
	}
	else if (field.type == 'checkbox') {
		input = E('input', {
			'id': fieldId(field.option),
			'type': 'checkbox',
			'checked': value ? 'checked' : null
		});
	}
	else {
		input = E('input', {
			'id': fieldId(field.option),
			'type': field.password ? 'password' : 'text',
			'value': value,
			'placeholder': field.placeholder || ''
		});
	}

	return E('div', { 'class': 'hotspot-field' }, [
		E('div', [ E('label', { 'for': fieldId(field.option) }, field.label), E('small', {}, field.hint || '') ]),
		E('div', [
			field.option === 'ip_binding' ? E('button', {
				'class': 'btn cbi-button cbi-button-add',
				'style': 'margin-bottom: 10px;',
				'click': function(ev) {
					ev.preventDefault();
					showBindingModal('', function(newLine) {
						var textarea = document.getElementById(fieldId('ip_binding'));
						if (textarea) {
							var val = textarea.value.trim();
							textarea.value = val ? val + '\n' + newLine : newLine;
						}
					});
				}
			}, 'إضافة جديد (+)') : '',
			input
		])
	]);
}

function renderFields(group) {
	return FIELD_GROUPS[group].map(renderField);
}

function cleanPortalFilename(name) {
	return String(name || '').replace(/\\/g, '/').replace(/^.*\//, '').replace(/[^A-Za-z0-9._-]/g, '_');
}

function uploadPortalFile(filename, filedata, onProgress) {
	return new Promise(function(resolve, reject) {
		var formData = new FormData();
		var xhr = new XMLHttpRequest();

		formData.append('sessionid', rpc.getSessionID());
		formData.append('filename', PORTAL_UPLOAD_TMP);
		formData.append('filedata', filedata);

		xhr.open('POST', L.env.cgi_base + '/cgi-upload', true);
		xhr.upload.onprogress = function(event) {
			if (event.lengthComputable && onProgress)
				onProgress(Math.round((event.loaded / event.total) * 100));
		};
		xhr.onload = function() {
			if (xhr.status === 200)
				resolve(xhr.responseText);
			else
				reject(new Error(xhr.statusText || ('HTTP ' + xhr.status)));
		};
		xhr.onerror = function() {
			reject(new Error('Network error'));
		};
		xhr.send(formData);
	});
}

function renderPortalUpload() {
	var fileInput = E('input', { 'type': 'file' });
	var filenameInput = E('input', { 'type': 'text', 'placeholder': 'login.html' });
	var progress = E('span', { 'class': 'hotspot-upload-progress' }, '-');
	var uploadButton = E('button', { 'class': 'btn cbi-button cbi-button-action' }, 'رفع الملف');

	fileInput.addEventListener('change', function() {
		if (fileInput.files && fileInput.files[0] && !filenameInput.value)
			filenameInput.value = cleanPortalFilename(fileInput.files[0].name);
	});

	uploadButton.addEventListener('click', function(ev) {
		var file = fileInput.files && fileInput.files[0];
		var filename = filenameInput.value.trim();
		var storagePath = collectValue('portal_storage_path') || getValue('portal_storage_path') || '/www/hotspot';

		ev.preventDefault();

		if (!file) {
			notify('اختر ملفًا أولًا.');
			return;
		}

		if (!filename) {
			filename = cleanPortalFilename(file.name);
			filenameInput.value = filename;
		}

		uploadButton.disabled = true;
		progress.textContent = '0%';

		uploadPortalFile(filename, file, function(percent) {
			progress.textContent = percent + '%';
		}).then(function() {
			return fs.exec_direct(PORTAL_UPLOAD_CMD, [ filename, storagePath ], 'json');
		}).then(function(result) {
			if (result && result.ok) {
				progress.textContent = 'تم';
				notify('تم رفع الملف إلى ' + result.path);
			}
			else {
				progress.textContent = 'فشل';
				notify((result && result.message) || 'فشل رفع الملف.');
			}
		}).catch(function(error) {
			progress.textContent = 'فشل';
			notify(error.message || String(error));
		}).finally(function() {
			uploadButton.disabled = false;
		});
	});

	return E('div', { 'class': 'hotspot-upload' }, [
		E('label', {}, 'رفع ملفات صفحة الهوتسبوت'),
		E('small', {}, 'يرفع الملف إلى مكان الحفظ الحالي داخل /www. يمكن استبدال login.html أو style.css أو إضافة صور وملفات للصفحة.'),
		E('div', { 'class': 'hotspot-upload-row' }, [ fileInput ]),
		E('div', { 'class': 'hotspot-upload-row' }, [
			filenameInput,
			uploadButton,
			progress
		])
	]);
}

function switchTab(key, panels, tabs) {
	TABS.forEach(function(tab) {
		var active = tab.key == key;
		panels[tab.key].classList.toggle('is-active', active);
		tabs[tab.key].classList.toggle('is-active', active);
	});
}

function renderReview(status) {
	return E('div', [
		E('div', { 'class': 'hotspot-summary' }, [
			statusItem('Server Interface', collectValue('subscriber_interface') || getValue('subscriber_interface')),
			statusItem('Address Pool', (collectValue('pool_start') || getValue('pool_start')) + ' - ' + (collectValue('pool_end') || getValue('pool_end'))),
			statusItem('Gateway', collectValue('hotspot_ip') || getValue('hotspot_ip')),
			statusItem('Login Page', 'http://' + (collectValue('hotspot_ip') || getValue('hotspot_ip')) + (collectValue('portal_path') || getValue('portal_path') || '/hotspot') + '/login.html'),
			statusItem('RADIUS', (collectValue('radius_server') || getValue('radius_server')) + ' UDP'),
			statusItem('Runtime', statusText(status.chilli_running, 'CoovaChilli يعمل', 'متوقف')),
			statusItem('Route', statusText(status.route_ok, 'tun0 صحيح', 'غير مؤكد'))
		]),
		E('div', { 'class': 'hotspot-note' }, 'سيتم ضبط br-hotspot كجسر Layer 2 بدون IP، وسيملك tun0 عنوان الهوتسبوت. هذا يمنع تعارض المسارات الذي سبب انقطاع الإنترنت سابقًا.'),
		E('div', { 'class': 'hotspot-actions' }, [
			E('button', {
				'class': 'btn cbi-button cbi-button-action',
				'click': function(ev) {
					ev.preventDefault();
					return fetchStatus().then(function(nextStatus) {
						notify('الحالة: ' + (nextStatus.chilli_running ? 'CoovaChilli يعمل' : 'CoovaChilli متوقف'));
					});
				}
			}, 'فحص الحالة'),
			E('button', {
				'class': 'btn cbi-button',
				'click': function(ev) {
					ev.preventDefault();
					this.disabled = true;
					this.textContent = 'جارٍ التوليد...';
					var self = this;
					fs.exec_direct(GEN_SSL_CMD, [], 'json').then(function(result) {
						if (result && result.ok)
							notify('تم توليد شهادة SSL: ' + (result.cert || '') + ' ✓');
						else
							notify((result && result.message) || 'فشل توليد الشهادة.');
					}).catch(function(e) {
						notify(e.message || String(e));
					}).finally(function() {
						self.disabled = false;
						self.textContent = 'توليد شهادة SSL';
					});
				}
			}, 'توليد شهادة SSL'),
			E('button', {
				'class': 'btn cbi-button',
				'click': function(ev) {
					ev.preventDefault();
					this.disabled = true;
					var self = this;
					fs.exec_direct(EXPORT_CMD, [], 'json').then(function(result) {
						if (result && result.ok) {
							notify('تم تصدير الإعدادات إلى ' + result.path + ' (' + result.size + ' byte).');
						} else {
							notify((result && result.message) || 'فشل التصدير.');
						}
					}).catch(function(e) {
						notify(e.message || String(e));
					}).finally(function() {
						self.disabled = false;
					});
				}
			}, 'تصدير الإعدادات'),
			E('button', {
				'class': 'btn cbi-button',
				'click': function(ev) {
					ev.preventDefault();
					var fileInput = document.createElement('input');
					fileInput.type = 'file';
					fileInput.accept = '.tar.gz,.tgz';
					fileInput.onchange = function() {
						var file = fileInput.files && fileInput.files[0];
						if (!file) return;
						var formData = new FormData();
						formData.append('sessionid', rpc.getSessionID());
						formData.append('filename', PORTAL_UPLOAD_TMP);
						formData.append('filedata', file);
						var xhr = new XMLHttpRequest();
						xhr.open('POST', L.env.cgi_base + '/cgi-upload', true);
						xhr.onload = function() {
							if (xhr.status === 200) {
								fs.exec_direct(IMPORT_CMD, [PORTAL_UPLOAD_TMP], 'json').then(function(result) {
									if (result && result.ok)
										notify(result.message || 'تم الاستيراد بنجاح.');
									else
										notify((result && result.message) || 'فشل الاستيراد.');
								}).catch(function(e) {
									notify(e.message || String(e));
								});
							} else {
								notify('فشل رفع الملف.');
							}
						};
						xhr.send(formData);
					};
					fileInput.click();
				}
			}, 'استيراد الإعدادات'),
			E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				'click': function(ev) {
					ev.preventDefault();
					this.disabled = true;
					this.textContent = 'جارٍ التطبيق...';
					return saveConfig().then(function() {
						return fs.exec_direct(APPLY_CMD, [], 'json');
					}).then(function(result) {
						if (result && result.ok)
							notify(result.message || 'تم تطبيق إعداد الهوتسبوت.');
						else
							notify((result && result.message) || 'فشل تطبيق إعداد الهوتسبوت.');
					}).catch(function(error) {
						notify(error.message || String(error));
					}).finally(function() {
						window.setTimeout(function() { window.location.reload(); }, 1200);
					});
				}
			}, 'حفظ وتطبيق')
		])
	]);
}

function formatBytes(value) {
	value = Number(value || 0);

	if (value >= 1073741824)
		return (value / 1073741824).toFixed(2) + ' GB';
	if (value >= 1048576)
		return (value / 1048576).toFixed(2) + ' MB';
	if (value >= 1024)
		return (value / 1024).toFixed(1) + ' KB';

	return String(value) + ' B';
}

function showBindingModal(mac, onSaveCallback) {
	ui.showModal('Make Binding', [
		E('div', { 'class': 'cbi-section' }, [
			E('div', { 'class': 'cbi-value' }, [
				E('label', { 'class': 'cbi-value-title' }, 'MAC Address'),
				E('div', { 'class': 'cbi-value-field' }, [
					E('input', { 'type': 'text', 'class': 'cbi-input-text', 'id': 'binding-mac', 'value': mac || '', 'placeholder': '00:11:22:33:44:55', 'readonly': mac ? 'readonly' : null })
				])
			]),
			E('div', { 'class': 'cbi-value' }, [
				E('label', { 'class': 'cbi-value-title' }, 'Type'),
				E('div', { 'class': 'cbi-value-field' }, [
					E('select', { 'class': 'cbi-input-select', 'id': 'binding-type' }, [
						E('option', { 'value': 'blocked' }, 'Blocked (حظر)'),
						E('option', { 'value': 'bypassed' }, 'Bypassed (سماح مباشر)'),
						E('option', { 'value': 'regular' }, 'Regular (عادي)')
					])
				])
			]),
			E('div', { 'class': 'cbi-value' }, [
				E('label', { 'class': 'cbi-value-title' }, 'Comment'),
				E('div', { 'class': 'cbi-value-field' }, [
					E('input', { 'type': 'text', 'class': 'cbi-input-text', 'id': 'binding-comment', 'placeholder': 'Optional comment' })
				])
			])
		]),
		E('div', { 'class': 'right' }, [
			E('button', {
				'class': 'btn',
				'click': ui.hideModal
			}, 'إلغاء'),
			' ',
			E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				'click': function(ev) {
					ev.preventDefault();
					var inputMac = document.getElementById('binding-mac').value.trim();
					if (!inputMac) return;
					var type = document.getElementById('binding-type').value;
					var comment = document.getElementById('binding-comment').value || '-';
					var newLine = type + ' ' + inputMac + ' ' + comment;

					if (typeof onSaveCallback === 'function') {
						onSaveCallback(newLine);
						ui.hideModal();
						return;
					}

					var currentList = uci.get('hotspot_openwrt', 'main', 'ip_binding') || [];
					if (typeof currentList === 'string') {
						currentList = currentList.split(/\n+/).filter(function(x) { return x.trim(); });
					}
					var newList = [];
					for (var i = 0; i < currentList.length; i++) {
						if (currentList[i].toLowerCase().indexOf(inputMac.toLowerCase()) === -1) {
							newList.push(currentList[i]);
						}
					}
					newList.push(newLine);
					uci.set('hotspot_openwrt', 'main', 'ip_binding', newList);
					var btn = this;
					btn.disabled = true;
					btn.textContent = 'جارٍ الحفظ...';
					uci.save().then(function() {
						return fs.exec_direct('/usr/libexec/hotspot-openwrt/apply', [], 'json');
					}).then(function(res) {
						if (res && res.ok) notify('تم تطبيق الـ Binding بنجاح.');
						else notify((res && res.message) || 'فشل التطبيق.');
						ui.hideModal();
						window.setTimeout(function() { window.location.reload(); }, 1200);
					}).catch(function(e) {
						notify(e.message || String(e));
						btn.disabled = false;
						btn.textContent = 'حفظ وتطبيق';
					});
				}
			}, typeof onSaveCallback === 'function' ? 'إضافة للجدول' : 'حفظ وتطبيق')
		])
	]);
}

function clientTable(title, count, clients, hostMode) {
	clients = Array.isArray(clients) ? clients : [];

	return E('div', [
		E('div', { 'class': 'hotspot-list-title' }, [
			E('h3', {}, title),
			E('span', { 'class': 'hotspot-badge' + (hostMode ? ' is-host' : '') }, String(count || clients.length || 0))
		]),
		clients.length ? E('table', { 'class': 'hotspot-table' }, [
			E('tr', [
				E('th', {}, hostMode ? 'H' : 'A'),
				E('th', {}, 'IP'),
				E('th', {}, 'MAC'),
				E('th', {}, 'User'),
				E('th', {}, 'State'),
				E('th', {}, 'In'),
				E('th', {}, 'Out'),
				E('th', {}, 'Action')
			])
		].concat(clients.map(function(client) {
			return E('tr', [
				E('td', {}, E('span', { 'class': 'hotspot-badge' + (hostMode ? ' is-host' : '') }, client.flag || (hostMode ? 'H' : 'A'))),
				E('td', {}, client.ip || '-'),
				E('td', {
					'class': 'hotspot-mac-cell',
					'style': 'cursor: context-menu; color: #0066cc; text-decoration: underline;',
					'title': 'انقر بالزر الأيمن لعمل Make Binding',
					'contextmenu': function(ev) {
						ev.preventDefault();
						if (client.mac) showBindingModal(client.mac);
					}
				}, client.mac || '-'),
				E('td', {}, client.username || '-'),
				E('td', {}, client.state || '-'),
				E('td', {}, formatBytes(client.input_octets)),
				E('td', {}, formatBytes(client.output_octets)),
				E('td', {}, [
					E('button', {
						'class': 'btn cbi-button cbi-button-add',
						'style': 'margin-left: 5px;',
						'title': 'Make Binding (+)',
						'click': function(ev) {
							ev.preventDefault();
							if (client.mac) showBindingModal(client.mac);
						}
					}, '+'),
					E('button', {
						'class': 'btn cbi-button cbi-button-remove',
						'click': function(ev) {
						ev.preventDefault();
						if (confirm('هل أنت متأكد من طرد/حذف الجهاز؟\nMAC: ' + client.mac)) {
							fs.exec_direct('/usr/libexec/hotspot-openwrt/kick-client', [client.mac || '', client.ip || '', client.state || ''], 'json').then(function(res) {
								if (res && res.ok) {
									notify(res.message);
									window.setTimeout(function() { window.location.reload(); }, 1500);
								} else {
									notify((res && res.message) || 'فشل تنفيذ أمر الطرد.');
								}
							}).catch(function(err) {
								notify(err.message || String(err));
							});
						}
					}
				}, 'حذف') ])
			]);
		}))) : E('div', { 'class': 'hotspot-empty' }, hostMode ? 'لا توجد أجهزة في Hosts الآن.' : 'لا توجد جلسات Active الآن.')
	]);
}

function renderActiveContent(status) {
	return [
		E('div', { 'class': 'hotspot-summary' }, [
			statusItem('Active', String(status.active_clients || 0)),
			statusItem('Hosts', String(status.waiting_clients || 0)),
			statusItem('Total', String(status.clients_total || 0)),
			statusItem('مهلة الطرد', status.keepalive_timeout || getValue('keepalive_timeout') || '-'),
			statusItem('Last Client', status.last_client || '-')
		]),
		clientTable('Active', status.active_clients, status.active_list, false),
		clientTable('Hosts', status.waiting_clients, status.hosts_list, true),
		E('div', { 'class': 'hotspot-note' }, 'في هذا النظام Active هي جلسات CoovaChilli بحالة pass، وHosts هي الأجهزة الموجودة بحالة dnat أو انتظار. عند تسجيل الخروج ينتقل الجهاز من Active إلى Hosts، وعند تسجيل الدخول يعود إلى Active.')
	];
}

function renderActive(status) {
	return E('div', [
		E('div', renderFields('active')),
		E('div', { 'class': 'hotspot-note' }, 'هذا الخيار هو وقت الانتظار بعد اختفاء الجهاز فعليًا من WiFi. بعد انتهاء المدة يتم إخراج جلسة Active أو حذف الجهاز من Hosts.'),
		E('div', { 'id': 'hotspot-openwrt-active-hosts' }, renderActiveContent(status))
	]);
}

function formatUptime(secs) {
	secs = Number(secs || 0);
	if (!secs) return '-';
	var h = Math.floor(secs / 3600);
	var m = Math.floor((secs % 3600) / 60);
	var s = secs % 60;
	return (h ? h + 'h ' : '') + (m ? m + 'm ' : '') + s + 's';
}

function renderStats(status) {
	var clients = Array.isArray(status.active_list) ? status.active_list : [];

	return E('div', [
		E('div', { 'class': 'hotspot-summary' }, [
			statusItem('Active Sessions', String(status.active_clients || 0)),
			statusItem('Hosts', String(status.waiting_clients || 0)),
			statusItem('Total', String(status.clients_total || 0)),
			statusItem('RADIUS', (status.radius_server || '-') + ' UDP')
		]),
		clients.length ? E('table', { 'class': 'hotspot-table', 'id': 'hotspot-stats-table' }, [
			E('tr', [
				E('th', {}, 'User'),
				E('th', {}, 'IP'),
				E('th', {}, 'MAC'),
				E('th', {}, 'Uptime'),
				E('th', {}, 'Bytes In'),
				E('th', {}, 'Bytes Out'),
				E('th', {}, 'State')
			])
		].concat(clients.map(function(c) {
			return E('tr', [
				E('td', {}, c.username || '-'),
				E('td', {}, c.ip || '-'),
				E('td', {}, c.mac || '-'),
				E('td', {}, formatUptime(c.uptime_secs)),
				E('td', {}, formatBytes(c.input_octets)),
				E('td', {}, formatBytes(c.output_octets)),
				E('td', {}, c.state || '-')
			]);
		}))) : E('div', { 'class': 'hotspot-empty' }, 'لا توجد جلسات نشطة الآن.'),
		E('div', { 'class': 'hotspot-note' }, 'يتحدث كل 8 ثواني. يعرض كل المشتركين بحالة pass مع وقت الجلسة والبيانات المنقولة.')
	]);
}

function renderLogs() {
	var container = E('div', { 'class': 'hotspot-empty' }, 'جارٍ تحميل السجل...');
	var linesSelect = E('select', { 'class': '' }, [
		E('option', { 'value': '50' }, '50 سطر'),
		E('option', { 'value': '100', 'selected': 'selected' }, '100 سطر'),
		E('option', { 'value': '200' }, '200 سطر'),
		E('option', { 'value': '500' }, '500 سطر')
	]);
	var refreshBtn = E('button', { 'class': 'btn cbi-button cbi-button-action' }, 'تحديث');

	function loadLogs() {
		var lines = linesSelect.value || '100';
		refreshBtn.disabled = true;
		container.textContent = 'جارٍ التحميل...';
		L.resolveDefault(fs.exec_direct(LOGS_CMD, [lines], 'json'), {}).then(function(result) {
			if (result && result.ok && Array.isArray(result.lines)) {
				if (result.lines.length === 0) {
					container.textContent = 'لا توجد رسائل متعلقة بالهوتسبوت في السجل.';
				} else {
					container.textContent = '';
					var pre = document.createElement('pre');
					pre.style.cssText = 'font-size:12px;max-height:400px;overflow:auto;direction:ltr;text-align:left;background:#f5f7fa;padding:8px;border-radius:4px;';
					pre.textContent = result.lines.join('\n');
					container.appendChild(pre);
				}
			} else {
				container.textContent = 'تعذر تحميل السجل.';
			}
		}).finally(function() {
			refreshBtn.disabled = false;
		});
	}

	refreshBtn.addEventListener('click', loadLogs);
	setTimeout(loadLogs, 100);

	return E('div', [
		E('div', { 'style': 'display:flex;gap:8px;align-items:center;margin-bottom:10px;' }, [
			E('span', {}, 'عدد الأسطر:'),
			linesSelect,
			refreshBtn
		]),
		container,
		E('div', { 'class': 'hotspot-note' }, 'يعرض رسائل logread المتعلقة بـ chilli/coova/radius/hotspot/tun0. لا يتحدث تلقائياً — اضغط تحديث.')
	]);
}

function renderCookies(status) {
	var cookies = Array.isArray(status.cookies_list) ? status.cookies_list : [];

	return E('div', [
		E('table', { 'class': 'hotspot-table' }, [
			E('tr', [ E('th', 'العنصر'), E('th', 'القيمة') ]),
			E('tr', [ E('td', 'Cookies'), E('td', String(status.cookies_total || 0)) ]),
			E('tr', [ E('td', 'Active sessions'), E('td', String(status.active_clients || 0)) ]),
			E('tr', [ E('td', 'Last client'), E('td', status.last_client || '-') ])
		]),
		cookies.length ? E('table', { 'class': 'hotspot-table' }, [
			E('tr', [
				E('th', {}, 'MAC'),
				E('th', {}, 'IP'),
				E('th', {}, 'User'),
				E('th', {}, 'Card'),
				E('th', {}, 'Last Seen')
			])
		].concat(cookies.map(function(cookie) {
			var lastSeen = Number(cookie.last_seen || 0);
			return E('tr', [
				E('td', {}, cookie.mac || '-'),
				E('td', {}, cookie.ip || '-'),
				E('td', {}, cookie.username || '-'),
				E('td', {}, cookie.card || '-'),
				E('td', {}, lastSeen ? new Date(lastSeen * 1000).toLocaleString() : '-')
			]);
		}))) : E('div', { 'class': 'hotspot-empty' }, 'لا توجد MAC Cookies محفوظة حتى الآن.'),
		E('div', { 'class': 'hotspot-note' }, 'عند تفعيل Add MAC Cookie ونجاح تسجيل الدخول، يحفظ الراوتر MAC وIP واسم الكرت. عند رجوع نفس الجهاز يحاول النظام إدخاله تلقائيًا بنفس الكرت بدون فتح صفحة تسجيل الدخول.')
	]);
}

function renderPanel(key, status) {
	if (key == 'active')
		return renderActive(status);
	if (key == 'cookies')
		return renderCookies(status);
	if (key == 'stats')
		return renderStats(status);
	if (key == 'logs')
		return renderLogs();
	if (key == 'apply')
		return renderReview(status);
	if (key == 'portal')
		return E('div', renderFields(key).concat([ renderPortalUpload() ]));

	return E('div', renderFields(key));
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('hotspot_openwrt'),
			uci.load('network'),
			uci.load('wireless'),
			fetchStatus()
		]);
	},

	render: function(data) {
		var status = data[3] || {};
		var tabs = {};
		var panels = {};
		var tabBar;
		var panelWrap;

		ensureStyles();

		tabBar = E('div', { 'class': 'hotspot-tabs' });
		panelWrap = E('div', { 'class': 'hotspot-card' });

		TABS.forEach(function(tab, index) {
			tabs[tab.key] = E('button', {
				'class': 'hotspot-tab' + (index === 0 ? ' is-active' : ''),
				'click': function(ev) {
					ev.preventDefault();
					switchTab(tab.key, panels, tabs);
				}
			}, tab.label);

			panels[tab.key] = E('section', {
				'class': 'hotspot-panel' + (index === 0 ? ' is-active' : '')
			}, [ renderPanel(tab.key, status) ]);

			tabBar.appendChild(tabs[tab.key]);
			panelWrap.appendChild(panels[tab.key]);
		});

		poll.add(function() {
			return fetchStatus().then(function(nextStatus) {
				var total = document.getElementById('hotspot-openwrt-live-total');
				var active = document.getElementById('hotspot-openwrt-live-active');
				var runtime = document.getElementById('hotspot-openwrt-live-runtime');
				var activeHosts = document.getElementById('hotspot-openwrt-active-hosts');
				var statsTable = document.getElementById('hotspot-stats-table');

				if (total)
					total.textContent = String(nextStatus.clients_total || 0);
				if (active)
					active.textContent = String(nextStatus.active_clients || 0);
				if (runtime)
					runtime.textContent = nextStatus.chilli_running ? 'يعمل' : 'متوقف';
				if (activeHosts)
					activeHosts.replaceChildren.apply(activeHosts, renderActiveContent(nextStatus));
				if (statsTable) {
					var newStats = renderStats(nextStatus);
					var newTable = newStats.querySelector && newStats.querySelector('table');
					if (newTable)
						statsTable.parentNode.replaceChild(newTable, statsTable);
				}
			});
		}, 8);

		return E('div', { 'class': 'hotspot-openwrt-shell' }, [
			E('aside', { 'class': 'hotspot-card' }, [
				E('h3', {}, 'الحالة الحالية'),
				E('div', { 'class': 'hotspot-status-grid' }, [
					statusItem('الخدمة', E('span', { 'id': 'hotspot-openwrt-live-runtime' }, statusText(status.chilli_running, 'يعمل', 'متوقف'))),
					statusItem('tun0', statusText(status.tun0_present, 'موجود', 'غير موجود')),
					statusItem('المسار', statusText(status.route_ok, 'صحيح إلى tun0', 'غير مؤكد')),
					statusItem('Bridge IP', statusText(!status.bridge_has_ip, 'بدون IP', 'يوجد IP')),
					statusItem('Active', E('span', { 'id': 'hotspot-openwrt-live-active' }, String(status.active_clients || 0))),
					statusItem('Hosts', E('span', { 'id': 'hotspot-openwrt-live-total' }, String(status.clients_total || 0))),
					statusItem('مهلة الطرد', status.keepalive_timeout || getValue('keepalive_timeout') || '-'),
					statusItem('Bindings', String(status.ip_bindings_total || 0)),
					statusItem('Blocked Bindings', String(status.ip_bindings_blocked_total || 0)),
					statusItem('Cookies', String(status.cookies_total || 0)),
					statusItem('Login Page', (status.portal_path || '/hotspot')),
					statusItem('Captive Notify', statusText(status.captive_notify, 'مفعّل', 'متوقف')),
					statusItem('RADIUS', (status.radius_server || '-') + ' UDP ' + (status.radius_auth_port || '1812') + '/' + (status.radius_acct_port || '1813'))
				])
			]),
			E('main', [
				E('div', { 'class': 'hotspot-card hotspot-hero' }, [
					E('h2', {}, 'Hotspot OpenWrt'),
					E('p', {}, 'إعداد HotSpot مبسط بنفس منطق MikroTik: Server، Profile، RADIUS، Active/Hosts، IP Bindings، Walled Garden، وCookies. المستخدمون والكروت تبقى في MikroTik User Manager.')
				]),
				tabBar,
				panelWrap
			])
		]);
	}
});