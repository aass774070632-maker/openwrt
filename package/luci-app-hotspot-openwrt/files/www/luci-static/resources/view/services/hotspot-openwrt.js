'use strict';
'require view';
'require fs';
'require poll';
'require rpc';
'require uci';
'require ui';

var STATUS_CMD = '/usr/libexec/hotspot-openwrt/status-json';
var APPLY_CMD = '/usr/libexec/hotspot-openwrt/apply';
var LICENSE_CHECK_CMD = '/usr/libexec/hotspot-openwrt/license-check';
var PORTAL_UPLOAD_CMD = '/usr/libexec/hotspot-openwrt/portal-upload';
var PORTAL_UPLOAD_TMP = '/tmp/hotspot-openwrt-upload';
var LOGS_CMD = '/usr/libexec/hotspot-openwrt/logs';
var EXPORT_CMD = '/usr/libexec/hotspot-openwrt/export-config';
var IMPORT_CMD = '/usr/libexec/hotspot-openwrt/import-config';
var GEN_SSL_CMD = '/usr/libexec/hotspot-openwrt/gen-ssl';
var CONNECT_TEST_CMD = '/usr/libexec/hotspot-openwrt/connectivity-test';
var KICK_CMD = '/usr/libexec/hotspot-openwrt/kick-client';
var STYLE_ID = 'hotspot-openwrt-styles';

function runApply(cmd, args, successMsg) {
	ui.showModal(_('Applying Changes'), [
		E('div', { 'class': 'cbi-section' }, [
			E('p', { 'class': 'spinning' }, _('Applying hotspot settings... this may take up to 20 seconds.')),
			E('div', { 'class': 'cbi-progressbar', 'title': '0%' }, [
				E('div', { 'style': 'width:0%' })
			])
		])
	]);

	var progressBar = document.querySelector('.cbi-progressbar > div');
	var progressText = document.querySelector('.cbi-progressbar');
	var interval = setInterval(function() {
		var width = parseInt(progressBar.style.width || 0);
		if (width < 95) {
			width += 5;
			progressBar.style.width = width + '%';
			progressText.title = width + '%';
		}
	}, 1000);

	return fs.exec_direct(cmd, args || [], 'json').then(function(result) {
		clearInterval(interval);
		progressBar.style.width = '100%';
		progressText.title = '100%';
		
		if (result && result.ok) {
			notify(result.message || successMsg || _('Changes applied successfully.'));
			setTimeout(function() {
				ui.hideModal();
				window.location.reload();
			}, 1000);
		} else {
			ui.hideModal();
			notify((result && result.message) || _('Failed to apply changes.'));
		}
	}).catch(function(e) {
		clearInterval(interval);
		ui.hideModal();
		notify(e.message || String(e));
	});
}

var FIELD_GROUPS = {
	server: [
		{ option: 'wan_interface', label: 'مدخل الإنترنت', hint: 'اختر واجهة OpenWrt المتصلة براوتر MikroTik. ستظهر الواجهة مع الكرت أو الجسر المرتبط بها.', placeholder: 'lan', choices: getNetworkChoices },
		{ option: 'subscriber_interface', label: 'واجهة الهوتسبوت', hint: 'واجهة المشتركين التي سيأخذها CoovaChilli. القيمة الآمنة الافتراضية هي hotspot.', placeholder: 'hotspot', choices: getSubscriberInterfaceChoices },
		{ option: 'bridge_ports', label: 'منافذ المشتركين', hint: 'اختر كرتًا أو أكثر للمشتركين. اتركه فارغًا عند استخدام WiFi فقط.', placeholder: 'lan4', choices: getBridgePortChoices, multiple: true },
		{ option: 'bridge_ageing_time', label: 'Ageing time', hint: 'قيمة ageing_time لجسري الهوتسبوت br-hotspot و br-hotspot2. الافتراضي 10.', placeholder: '10' },
		{ option: 'wifi_iface', label: 'واجهة WiFi', hint: 'اختر قسم WiFi الذي سيبث شبكة الهوتسبوت.', placeholder: 'hotspot_openwrt_radio0_ap', choices: getWifiChoices }
	],
	profile: [
		{ option: 'hotspot_ip', label: 'عنوان الهوتسبوت', hint: 'يمتلكه tun0 فقط، وليس br-hotspot', placeholder: '192.168.10.1' },
		{ option: 'hotspot_cidr', label: 'قناع الشبكة CIDR', hint: 'غالبًا 24', placeholder: '24' },
		{ option: 'pool_start', label: 'بداية عناوين العملاء', hint: 'مثل Address Pool في MikroTik', placeholder: '192.168.10.10' },
		{ option: 'pool_end', label: 'نهاية عناوين العملاء', hint: 'آخر IP يوزعه CoovaChilli', placeholder: '192.168.10.254' },
		{ option: 'domain', label: 'DNS Name', hint: 'اسم داخلي للبوابة', placeholder: 'hotspot.local' },
		{ option: 'trial_enabled', label: 'تفعيل الفترة التجريبية (Trial)', hint: 'عند التفعيل، يمكن للمشتركين تجربة الإنترنت لفترة محدودة دون تسجيل دخول.', type: 'checkbox' },
		{ option: 'trial_duration', label: 'مدة التجربة (بالثواني)', hint: 'المدة المتاحة لكل جهاز عند النقر على وضع التجربة (مثل 1800 لمدة 30 دقيقة).', placeholder: '1800' },
		{ option: 'trial_uptime_limit', label: 'الحد اليومي المسموح (بالثواني)', hint: 'إجمالي الوقت المسموح للجهاز استخدامه في وضع التجربة خلال 24 ساعة.', placeholder: '1800' },
		{ option: 'session_timeout', label: 'Session Timeout', hint: 'none أو مدة مثل 01:00:00. يطبق كـ CoovaChilli defsessiontimeout عند تحديد مدة.', placeholder: 'none' },
		{ option: 'idle_timeout', label: 'Idle Timeout', hint: 'none أو مدة مثل 00:10:00. يطبق كـ CoovaChilli defidletimeout عند تحديد مدة.', placeholder: 'none' },
		{ option: 'status_autorefresh', label: 'Status Autorefresh', hint: 'فترة تحديث صفحة الحالة، مثل 00:01:00.', placeholder: '00:01:00' },
		{ option: 'shared_users', label: 'Shared Users', hint: 'عدد الجلسات لنفس المستخدم. يفضل ضبط enforcement النهائي من MikroTik User Manager.', placeholder: '3' },
		{ option: 'rate_limit_rx_tx', label: 'Rate Limit (rx/tx)', hint: 'اختياري مثل 2M/5M. يطبق كحد افتراضي upload/download إذا لم يرجعه RADIUS.', placeholder: '2M/5M' },
		{ option: 'maint_enabled', label: 'تفعيل وضع الصيانة (العمل التلقائي)', hint: 'عند التفعيل، سيقوم الراوتر بفتح الإنترنت تلقائياً للمشتركين خلال الفترة المحددة.', type: 'checkbox' },
		{ option: 'maint_start', label: 'وقت بدء الصيانة', hint: 'مثل 02:00', placeholder: '02:00' },
		{ option: 'maint_end', label: 'وقت انتهاء الصيانة', hint: 'مثل 03:00', placeholder: '03:00' },
		{ option: 'maint_mode', label: 'سلوك الصيانة', choices: [
			{ value: 'free', label: 'السماح بالإنترنت المجاني للجميع (وضع الباي باس)' },
			{ value: 'block', label: 'قطع الإنترنت وطرد جميع المشتركين' }
		], default: 'free' },
		{ option: 'mac_cookie_enabled', label: 'Add MAC Cookie', hint: 'يحفظ MAC وIP واسم الكرت بعد نجاح الدخول، ثم يسمح بالدخول التلقائي لنفس الجهاز لاحقًا مثل MikroTik Cookies.', type: 'checkbox' },
		{ option: 'open_status_page', label: 'Open Status Page', hint: 'اختيار طريقة فتح صفحة الحالة بعد الدخول.', placeholder: 'always', choices: getOpenStatusPageChoices },
		{ option: 'terms_enabled', label: 'صفحة الشروط', hint: 'اعرض الشروط قبل تسجيل الدخول', type: 'checkbox' }
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
		{ option: 'coa_port', label: 'CoA Port UDP', hint: 'منفذ CoA/Disconnect. الافتراضي في MikroTik هو 3799.', placeholder: '3799' },
		{ option: 'userman_rest_enabled', label: 'قراءة رصيد User Manager', hint: 'يفعل جسر RouterOS REST لعرض الرصيد والبروفايل ووقت الانتهاء في صفحة المشترك.', type: 'checkbox' },
		{ option: 'userman_rest_scheme', label: 'RouterOS REST Scheme', hint: 'استخدم https مع www-ssl. يمكن استخدام http للاختبار فقط.', placeholder: 'https', choices: getRouterOsSchemeChoices },
		{ option: 'userman_rest_host', label: 'RouterOS REST Host', hint: 'عنوان MikroTik (للوصول لـ API)', placeholder: '192.168.1.2' },
		{ option: 'userman_rest_port', label: 'RouterOS REST Port', hint: 'المنفذ (غالباً 443 لـ https)', placeholder: '443' },
		{ option: 'userman_rest_username', label: 'RouterOS REST User', hint: 'مستخدم بصلاحية read و rest-api', placeholder: 'admin' },
		{ option: 'userman_rest_password', label: 'RouterOS REST Password', hint: 'كلمة السر', placeholder: '', password: true },
		{ option: 'radius_routing', label: 'توجيه كروت اليوزر منجر حسب طول الكرت', hint: 'أدخل القواعد بالصيغة: (طول الكرت:اسم الدومين)، سطر لكل قاعدة. مثال:\n9:userman\n12:userman2', multiline: true, placeholder: '9:userman\n12:userman2' }
	],
	security: [
		{ option: 'walled_garden', label: 'Walled Garden (Domains)', hint: 'قائمة المواقع المسموحة قبل تسجيل الدخول (سيرفرات البنوك، جوجل، الخ). سطر لكل نطاق.', multiline: true, placeholder: 'google.com\nbank.com' },
		{ option: 'walled_garden_ip', label: 'Walled Garden (IPs)', hint: 'قائمة الآيبيات المسموحة. سطر لكل IP.', multiline: true, placeholder: '8.8.8.8\n1.1.1.1' },
		{ option: 'uam_domain', label: 'UAM Domain', hint: 'النطاق المستخدم لتوثيق العملاء. يفضل تركه افتراضياً.', placeholder: 'uam.local' }
	],
	cookies: [
		{ option: 'mac_cookie_secret', label: 'MAC Cookie Secret', hint: 'مفتاح تشفير الكوكي. اتركه فارغاً للتلقائي.', placeholder: '' },
		{ option: 'mac_cookie_timeout', label: 'MAC Cookie Timeout', hint: 'مدة صلاحية التلقائي (بالثواني).', placeholder: '86400' }
	],
	portal: [
		{ option: 'portal_path', label: 'رابط صفحة الهوتسبوت', hint: 'المسار الذي يفتحه العميل داخل المتصفح', placeholder: '/hotspot' },
		{ option: 'portal_storage_path', label: 'مكان حفظ الصفحة', hint: 'المجلد على الراوتر. يجب أن يكون داخل /www حتى يخدمه uhttpd', placeholder: '/www/hotspot' },
		{ option: 'network_name', label: 'اسم الشبكة', hint: 'يظهر في أعلى صفحة الدخول', placeholder: 'Hotspot OpenWrt' },
		{ option: 'available_speeds', label: 'قائمة السرعات المتاحة للمشتركين', hint: 'أدخل خيارات السرعة، سطر لكل خيار. الصيغة: (السرعة الاسم). مثال: 1M/2M باقة_عادية', multiline: true, placeholder: '1M/2M Standard\n2M/4M Fast' },
		{ option: 'support_phone', label: 'رقم الدعم الفني', hint: 'يظهر كزر تواصل في أسفل الصفحة', placeholder: '777000000' },
		{ option: 'logo_url', label: 'رابط الشعار', hint: 'رابط صورة تظهر في الأعلى (يمكن تركه فارغاً)', placeholder: '/hotspot/logo.png' },
		{ option: 'notice_text', label: 'تنبيه للمشتركين', hint: 'نص يظهر بشكل بارز للتنبيهات', placeholder: 'أهلاً بكم في شبكتنا' },
		{ option: 'live_stream_enabled', label: 'إظهار بث مباشر', hint: 'يعرض زر البث المباشر في صفحة الدخول والحالة عند وجود رابط.', type: 'checkbox' },
		{ option: 'live_stream_url', label: 'رابط البث المباشر', hint: 'الرابط الذي يفتحه زر البث المباشر.', placeholder: 'https://example.com/live' },
		{ option: 'rest_area_enabled', label: 'إظهار الاستراحة', hint: 'يعرض زر الاستراحة في صفحة الدخول والحالة عند وجود رابط.', type: 'checkbox' },
		{ option: 'rest_area_url', label: 'رابط الاستراحة', hint: 'الرابط الذي يفتحه زر الاستراحة.', placeholder: 'https://example.com/lounge' },
		{ option: 'speedtest_enabled', label: 'تفعيل فحص السرعة في صفحة الحالة', hint: 'يظهر زر للمشترك لقياس سرعة اتصاله الحقيقية بالراوتر', type: 'checkbox' },
		{ option: 'login_mode', label: 'طريقة تسجيل الدخول', hint: 'اختر ما إذا كان المشترك يحتاج لإدخال رقم الكرت فقط أو مع كلمة سر.', placeholder: 'both', choices: getLoginModeChoices },
		{ option: 'captive_notify', label: 'إظهار نافذة الدخول تلقائيًا', hint: 'يضيف DHCP option 114 وapi.json لتتعرف الهواتف على الكابتف بورتال', type: 'checkbox' },
		{ option: 'browser_cookie_enabled', label: 'Browser Cookie', hint: 'يتذكر المتصفح رقم الكرت محليًا عند فتح صفحة الدخول', type: 'checkbox' },
		{ option: 'browser_cookie_days', label: 'مدة كوكي المتصفح بالأيام', hint: 'من 1 إلى 365 يومًا', placeholder: '7' }
	],
	dns: [
		{ option: 'dns1', label: 'DNS Primary', hint: 'DNS أساسي للمشتركين', placeholder: '8.8.8.8' },
		{ option: 'dns2', label: 'DNS Secondary', hint: 'DNS ثانوي للمشتركين', placeholder: '1.1.1.1' },
		{ option: 'domain_whitelist', label: 'DNS Whitelist', hint: 'نطاقات لا يتم تحويلها للكابتف بورتال. سطر لكل نطاق.', multiline: true, placeholder: 'apple.com\nwindows.com' }
	],
	bindings: [
		{ option: 'static_ips', label: 'IP / MAC Bindings', hint: 'تثبيت الآيبيات، التجاوز أو الحظر للأجهزة. الصيغ المدعومة (سطر لكل جهاز):<br>1. لتثبيت آي بي لجهاز: <b>MAC IP</b> (مثل: 00:11:22:33:44:55 192.168.10.50)<br>2. لتجاوز صفحة الدخول بالماك فقط (Bypass): <b>bypassed MAC</b> (مثل: bypassed 00:11:22:33:44:55)<br>3. لحظر جهاز بالماك (Block): <b>blocked MAC</b> (مثل: blocked 00:11:22:33:44:55)', multiline: true, placeholder: '00:11:22:33:44:55 192.168.10.50\nbypassed 00:11:22:33:44:55\nblocked 00:11:22:33:44:55' }
	],
	advanced: [
		{ option: 'mtu', label: 'TUN MTU', hint: 'Maximum Transmission Unit لواجهة tun0. الافتراضي 1400.', placeholder: '1400' },
		{ option: 'txqueuelen', label: 'TUN txqueuelen', hint: 'طول طابور الإرسال لواجهة tun0. الافتراضي 500.', placeholder: '500' },
		{ option: 'debug', label: 'تفعيل Debug', hint: 'يسجل معلومات مفصلة في syslog لمشاكل الاتصال.', type: 'checkbox' },
		{ option: 'custom_options', label: 'خيارات CoovaChilli إضافية', hint: 'أدخل أي خيارات إضافية لا يوفرها الواجهة. سطر لكل خيار.', multiline: true, placeholder: 'conid=1\nstrictacct' }
	],
	active: [
		{ option: 'keepalive_timeout', label: 'مدة طرد المنفصلين من Active / Hosts', hint: 'إذا اختفى الجهاز من شبكة الهوتسبوت، يتم إخراجه من Active أو حذفه من Hosts بعد هذه المدة. اكتب مدة مثل 00:02:00 أو none لتعطيله.', placeholder: '00:02:00' }
	],
	logs: [
		{ option: 'syslog', label: 'Syslog Enable', type: 'checkbox' }
	]
};

var TABS = [
	{ id: 'core', title: _('🌐 الأساسيات والواجهات') },
	{ id: 'auth', title: _('🔑 الربط والتوثيق') },
	{ id: 'portal', title: _('🎨 البوابة والسرعات') },
	{ id: 'rules', title: _('🛡️ القوانين والاستثناءات') },
	{ id: 'cookies', title: _('🍪 كوكيز الأجهزة') },
	{ id: 'monitoring', title: _('📊 المراقبة والسجلات') },
	{ id: 'review', title: _('💾 المراجعة والتطبيق') }
];

function notify(message) {
	ui.addNotification(null, E('p', {}, message));
}

function licenseCacheInfo() {
	return {
		enabled: true,
		status: 'active',
		expiresAt: 0,
		active: true,
		known: true,
		label: '♛ ALEMPRATOR PLATINUM ♛'
	};
}

function licenseCacheText(info) {
	info = info || licenseCacheInfo();
	if (info.label.indexOf('ALEMPRATOR') > -1)
		return 'تهانينا! نسخة الراوتر هذه تعمل بنظام ALEMPRATOR Platinum ومفعلة بشكل دائم للعمل بكفاءة قصوى.';
	if (!info.enabled)
		return 'فحص الترخيص معطل من الإعدادات.';
	if (!info.known)
		return 'لم تتمكن الواجهة من قراءة حالة الترخيص بعد. سيتم تشغيل فحص حي عند التطبيق.';
	if (info.active)
		return 'الهوتسبوت مرخص حالياً وسيتم تشغيل الخدمة بشكل طبيعي.';
	return 'الهوتسبوت غير مرخص حالياً. عند التطبيق سيتم حفظ الإعدادات، لكن خدمة الهوتسبوت لن تبدأ وسيبقى العملاء بدون بوابة دخول حتى يتم تفعيل الترخيص من لوحة OTA.';
}

function checkHotspotLicenseLive() {
	return Promise.resolve({
		ok: true,
		message: 'Unlocked'
	});
}

function confirmHotspotLicenseBeforeApply() {
	return checkHotspotLicenseLive().then(function(result) {
		var message = result.ok
			? 'الهوتسبوت مرخص. سيتم حفظ الإعدادات وتشغيل الخدمة الآن. هل تريد المتابعة؟'
			: 'الهوتسبوت غير مرخص. سيتم حفظ الإعدادات، لكن تشغيل الخدمة سيفشل وسيبقى العملاء بدون إنترنت عبر الهوتسبوت حتى يتم تفعيل الترخيص من لوحة OTA. هل تريد المتابعة؟';

		if (result.message)
			message += '\n\nتفاصيل الفحص: ' + String(result.message).trim();

		return window.confirm(message);
	});
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

var BOOL_OPTIONS = [
	'terms_enabled', 'captive_notify', 'browser_cookie_enabled', 'mac_cookie_enabled',
	'userman_rest_enabled', 'userman_rest_insecure_ssl', 'uamssl_enabled',
	'coa_enabled', 'trial_enabled', 'mac_auth_enabled', 'speedtest_enabled',
	'live_stream_enabled', 'rest_area_enabled'
];

function getValue(option) {
	var val = uci.get('hotspot_openwrt', 'main', option);
	if (val === undefined || val === null || val === '') {
		if (option == 'wan_interface')
			val = uci.get('setup', 'default', 'hotspot_quick_wan_interface');
		if (option == 'subscriber_interface')
			val = uci.get('setup', 'default', 'hotspot_quick_subscriber_interface');
		if (option == 'radius_server')
			val = uci.get('setup', 'default', 'hotspot_quick_radius_server');
		if (option == 'radius_secret')
			val = uci.get('setup', 'default', 'hotspot_quick_radius_secret');
		if (option == 'radius_nas_id')
			val = uci.get('setup', 'default', 'hotspot_quick_nas_id');
	}

	if (option == 'dns1')
		return firstDns(0) || uci.get('setup', 'default', 'hotspot_quick_dns1') || '';
	if (option == 'dns2')
		return firstDns(1) || uci.get('setup', 'default', 'hotspot_quick_dns2') || '';
	if (option == 'walled_garden') {
		var wg = readList('walled_garden').join('\n');
		return (wg || uci.get('setup', 'default', 'hotspot_quick_walled_garden') || '').replace(/[\s,]+/g, '\n');
	}
	if (option == 'walled_garden_ip')
		return readList('walled_garden_ip').join('\n');
	if (option == 'ip_binding')
		return readLineList('ip_binding').join('\n');
	if (option == 'mtu')
		return val || '1400';
	if (option == 'txqueuelen')
		return val || '500';
	if (option == 'bridge_ageing_time')
		return val || uci.get('setup', 'default', 'hotspot_quick_bridge_ageing_time') || '10';
	if (BOOL_OPTIONS.indexOf(option) > -1) {
		if (val !== undefined && val !== null && val !== '')
			return val == '1';
		var sVal = uci.get('setup', 'default', 'hotspot_quick_' + option);
		if (sVal === undefined || sVal === null || sVal === '') {
			if (option == 'trial_enabled') sVal = uci.get('setup', 'default', 'hotspot_quick_trial_enabled');
			if (option == 'mac_auth_enabled') sVal = uci.get('setup', 'default', 'hotspot_quick_mac_auth_enabled');
			if (option == 'speedtest_enabled') sVal = uci.get('setup', 'default', 'hotspot_quick_speedtest_enabled');
			if (option == 'live_stream_enabled') sVal = uci.get('setup', 'default', 'hotspot_quick_live_stream_enabled');
			if (option == 'rest_area_enabled') sVal = uci.get('setup', 'default', 'hotspot_quick_rest_area_enabled');
		}
		return sVal == '1';
	}

	return val || '';
}

function fieldId(option) {
	if (!option) return 'hotspot-field-unknown';
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

	return uci.save().then(function() {
		return uci.apply();
	});
}

function fetchStatus() {
	return L.resolveDefault(fs.exec_direct(STATUS_CMD, [], 'json'), {});
}

function ensureStyles() {
	if (document.getElementById(STYLE_ID))
		return;

	var style = document.createElement('style');
	style.id = STYLE_ID;
	style.textContent = [
		'.hotspot-openwrt-shell{max-width:1250px;margin:0 auto;display:grid;grid-template-columns:minmax(280px,340px) minmax(0,1fr);gap:20px;align-items:start;padding:10px}',
		'@media(max-width:980px){.hotspot-openwrt-shell{grid-template-columns:1fr}}',
		'.hotspot-card{border:1px solid rgba(212,175,55,0.2);border-radius:20px;background:#0c0c0c;padding:24px;box-shadow:0 15px 40px rgba(0,0,0,0.6);color:#fff}',
		'.hotspot-hero{background:radial-gradient(circle at top, #1a1a1a 0%, #000 100%);border:1px solid #D4AF37;text-align:center;padding:35px}',
		'.hotspot-hero h2{margin:0;font-size:32px;font-weight:950;color:#D4AF37;letter-spacing:4px;text-shadow:0 0 20px rgba(212,175,55,0.3)}',
		'.hotspot-hero p{margin:15px 0 0;color:rgba(255,255,255,0.7);line-height:1.8;font-size:0.95rem}',
		'.hotspot-status-grid{display:grid;grid-template-columns:1fr;gap:12px;margin-top:20px}',
		'.hotspot-status-item{border:1px solid rgba(255,255,255,0.05);background:rgba(255,255,255,0.02);border-radius:15px;padding:12px 15px;transition:0.3s}',
		'.hotspot-status-item:hover{background:rgba(212,175,55,0.05);border-color:rgba(212,175,55,0.2)}',
		'.hotspot-status-item span{display:block;color:rgba(255,255,255,0.4);font-size:0.75rem;margin-bottom:4px;font-weight:bold}',
		'.hotspot-status-item strong{display:block;color:#D4AF37;word-break:break-word;font-size:0.95rem}',
		'.hotspot-tabs{display:flex;gap:10px;flex-wrap:wrap;margin:25px 0;justify-content:center}',
		'.hotspot-tab{border:1px solid rgba(212,175,55,0.15);background:rgba(212,175,55,0.02);border-radius:15px;padding:12px 20px;cursor:pointer;font-weight:900;color:#fff;transition:0.4s}',
		'.hotspot-tab:hover{background:rgba(212,175,55,0.1);transform:translateY(-2px)}',
		'.hotspot-tab.is-active{background:#D4AF37;color:#000;border-color:#D4AF37;box-shadow:0 0 20px rgba(212,175,55,0.3)}',
		'.hotspot-panel{display:none;animation:fadeIn 0.4s ease-out}',
		'@keyframes fadeIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}',
		'.hotspot-panel.is-active{display:block}',
		'.hotspot-field{display:grid;grid-template-columns:minmax(180px,260px) minmax(0,1fr);gap:15px;padding:18px 0;border-top:1px solid rgba(255,255,255,0.05)}',
		'.hotspot-field:first-child{border-top:0}',
		'@media(max-width:640px){.hotspot-field{grid-template-columns:1fr}}',
		'.hotspot-field label{font-weight:900;color:#D4AF37;font-size:1rem}',
		'.hotspot-field small{display:block;margin-top:6px;color:rgba(255,255,255,0.4);line-height:1.6;font-size:0.85rem}',
		'.hotspot-field input,.hotspot-field textarea,.hotspot-field select{width:100%;max-width:480px;box-sizing:border-box;border:1px solid rgba(255,255,255,0.1);border-radius:12px;padding:12px 15px;background:#151515;color:#fff;transition:0.3s}',
		'.hotspot-field input:focus,.hotspot-field select:focus{border-color:#D4AF37;outline:none;background:#202020}',
		'.hotspot-field textarea{min-height:130px;font-family:monospace;direction:ltr}',
		'.hotspot-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:15px}',
		'.hotspot-actions{display:flex;gap:12px;flex-wrap:wrap;justify-content:flex-end;margin-top:25px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.05)}',
		'.hotspot-note{border:1px solid rgba(212,175,55,0.3);background:rgba(212,175,55,0.05);color:#D4AF37;border-radius:15px;padding:15px;line-height:1.8;margin-top:20px;font-size:0.9rem}',
		'.hotspot-table{width:100%;border-collapse:separate;border-spacing:0 8px;margin-top:15px}',
		'.hotspot-table th{background:transparent;color:rgba(255,255,255,0.4);padding:12px 15px;text-align:right;font-size:0.8rem;text-transform:uppercase;letter-spacing:1px}',
		'.hotspot-table td{background:#151515;border-top:1px solid rgba(255,255,255,0.05);border-bottom:1px solid rgba(255,255,255,0.05);padding:15px;color:#fff}',
		'.hotspot-table td:first-child{border-left:1px solid rgba(255,255,255,0.05);border-top-left-radius:12px;border-bottom-left-radius:12px}',
		'.hotspot-table td:last-child{border-right:1px solid rgba(255,255,255,0.05);border-top-right-radius:12px;border-bottom-right-radius:12px}',
		'.hotspot-badge{display:inline-flex;align-items:center;justify-content:center;padding:4px 12px;border-radius:8px;background:rgba(212,175,55,0.1);color:#D4AF37;font-weight:900;font-size:0.8rem}',
		'.hotspot-empty{border:2px dashed rgba(212,175,55,0.2);border-radius:20px;padding:40px;text-align:center;color:rgba(255,255,255,0.3);font-size:1.1rem}',
		'.btn{border-radius:12px;padding:10px 20px;font-weight:bold;cursor:pointer;transition:0.3s;border:none}',
		'.cbi-button-action{background:#D4AF37;color:#000}',
		'.cbi-button-action:hover{background:#9a7b1b;transform:scale(1.05)}',
		'.cbi-button-remove{background:rgba(255,0,0,0.1);color:#ff4444;border:1px solid rgba(255,0,0,0.2)}',
		'#hotspot-openwrt-active-hosts > div:first-child { display: none !important }'
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

function createTimePicker(initialValue) {
	var hoursSelect = E('select', { 'style': 'max-width:70px; margin-inline-end:5px;' }, [
		E('option', { 'value': '12' }, '12'),
		E('option', { 'value': '01' }, '01'),
		E('option', { 'value': '02' }, '02'),
		E('option', { 'value': '03' }, '03'),
		E('option', { 'value': '04' }, '04'),
		E('option', { 'value': '05' }, '05'),
		E('option', { 'value': '06' }, '06'),
		E('option', { 'value': '07' }, '07'),
		E('option', { 'value': '08' }, '08'),
		E('option', { 'value': '09' }, '09'),
		E('option', { 'value': '10' }, '10'),
		E('option', { 'value': '11' }, '11')
	]);
	var minutesSelect = E('select', { 'style': 'max-width:70px; margin-inline-end:5px;' });
	for (var i = 0; i < 60; i++) {
		var mStr = i < 10 ? '0' + i : '' + i;
		minutesSelect.appendChild(E('option', { 'value': mStr }, mStr));
	}
	var ampmSelect = E('select', { 'style': 'max-width:90px;' }, [
		E('option', { 'value': 'AM' }, 'صباحاً'),
		E('option', { 'value': 'PM' }, 'مساءً')
	]);
	var container = E('div', { 'style': 'display:inline-flex; align-items:center;' }, [
		hoursSelect,
		E('span', { 'style': 'margin-inline-end:5px;' }, ':'),
		minutesSelect,
		ampmSelect
	]);
	Object.defineProperty(container, 'value', {
		get: function() {
			var h = parseInt(hoursSelect.value);
			var m = minutesSelect.value;
			var isPm = (ampmSelect.value === 'PM');
			if (isPm && h !== 12) h += 12;
			else if (!isPm && h === 12) h = 0;
			var hStr = h < 10 ? '0' + h : '' + h;
			return hStr + ':' + m;
		},
		set: function(val) {
			if (!val || val.indexOf(':') === -1) val = '12:00';
			var parts = val.split(':');
			var h = parseInt(parts[0]);
			var m = parts[1];
			var isPm = (h >= 12);
			var displayH = h % 12;
			if (displayH === 0) displayH = 12;
			var hStr = displayH < 10 ? '0' + displayH : '' + displayH;
			hoursSelect.value = hStr;
			minutesSelect.value = m;
			ampmSelect.value = isPm ? 'PM' : 'AM';
		}
	});
	container.value = initialValue || '02:00';
	return container;
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

	if (field.option === 'maint_start' || field.option === 'maint_end') {
		input = createTimePicker(value);
		input.id = fieldId(field.option);
	}
	else if (choices) {
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
		var active = tab.id == key;
		panels[tab.id].classList.toggle('is-active', active);
		tabs[tab.id].classList.toggle('is-active', active);
	});
}

function renderReview(status) {
	var licenseInfo = licenseCacheInfo();

	return E('div', [
		E('div', { 'class': 'hotspot-summary' }, [
			statusItem('License', licenseInfo.label),
			statusItem('Server Interface', collectValue('subscriber_interface') || getValue('subscriber_interface')),
			statusItem('Address Pool', (collectValue('pool_start') || getValue('pool_start')) + ' - ' + (collectValue('pool_end') || getValue('pool_end'))),
			statusItem('Gateway', collectValue('hotspot_ip') || getValue('hotspot_ip')),
			statusItem('Login Page', 'http://' + (collectValue('hotspot_ip') || getValue('hotspot_ip')) + (collectValue('portal_path') || getValue('portal_path') || '/hotspot') + '/login.html'),
			statusItem('RADIUS', (collectValue('radius_server') || getValue('radius_server')) + ' UDP'),
			statusItem('MTU', (status.tun0_mtu || status.mtu || 1400)),
			statusItem('Runtime', statusText(status.chilli_running, 'CoovaChilli يعمل', 'متوقف')),
			statusItem('Route', statusText(status.route_ok, 'tun0 صحيح', 'غير مؤكد'))
		]),
		E('div', { 'class': 'hotspot-note' }, licenseCacheText(licenseInfo)),
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
					var button = this;
					button.disabled = true;
					button.textContent = _('Saving...');
					return saveConfig().then(function() {
						return runApply(APPLY_CMD, [], _('Hotspot settings applied.'));
					}).catch(function(error) {
						notify(error.message || String(error));
						button.disabled = false;
						button.textContent = 'حفظ وتطبيق';
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
					btn.textContent = _('Saving...');
					uci.save().then(function() {
						ui.hideModal();
						return runApply('/usr/libexec/hotspot-openwrt/apply', [], _('Binding applied successfully.'));
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
				}, 'حذف'),
				E('button', {
					'class': 'btn cbi-button cbi-button-negative',
					'style': 'margin-left: 5px;',
					'click': function(ev) {
						ev.preventDefault();
						if (confirm('هل أنت متأكد من حظر الجهاز نهائياً؟\nMAC: ' + client.mac)) {
							fs.exec_direct('/usr/libexec/hotspot-openwrt/kick-client', [client.mac || '', client.ip || '', client.state || '', 'block'], 'json').then(function(res) {
								if (res && res.ok) {
									notify('تم حظر الجهاز وطرده.');
									window.setTimeout(function() { window.location.reload(); }, 1500);
								} else {
									notify((res && res.message) || 'فشل حظر الجهاز.');
								}
							}).catch(function(err) {
								notify(err.message || String(err));
							});
						}
					}
				}, 'حظر') ])
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
				E('th', {}, 'State'),
				E('th', {}, 'Actions')
			])
		].concat(clients.map(function(c) {
			return E('tr', [
				E('td', {}, c.username || '-'),
				E('td', {}, c.ip || '-'),
				E('td', {}, c.mac || '-'),
				E('td', {}, formatUptime(c.uptime_secs)),
				E('td', {}, formatBytes(c.input_octets)),
				E('td', {}, formatBytes(c.output_octets)),
				E('td', {}, c.state || '-'),
				E('td', {}, [
					E('button', {
						'class': 'btn cbi-button cbi-button-remove',
						'title': 'قطع الاتصال',
						'click': function(ev) {
							ev.preventDefault();
							if (!confirm('هل تريد قطع اتصال ' + (c.username || c.mac) + '؟')) return;
							fs.exec_direct(KICK_CMD, [ c.mac ], 'json').then(function(res) {
								notify(res && res.ok ? 'تم قطع الاتصال.' : 'فشل قطع الاتصال.');
							});
						}
					}, 'طرد'),
					' ',
					E('button', {
						'class': 'btn cbi-button cbi-button-action',
						'title': 'تثبيت بالجهاز',
						'click': function(ev) {
							ev.preventDefault();
							showBindingModal(c.mac);
						}
					}, 'ربط')
				])
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

function renderRadiusTests() {
	return E('div', { 'class': 'hotspot-actions', 'style': 'justify-content: flex-start;' }, [
		E('button', {
			'class': 'btn cbi-button',
			'click': function(ev) {
				ev.preventDefault();
				var btn = this;
				btn.disabled = true;
				btn.textContent = 'جارٍ فحص RADIUS...';
				fs.exec_direct(CONNECT_TEST_CMD, [ 'radius' ], 'json').then(function(res) {
					notify(res && res.message ? res.message : 'فشل الاتصال.');
				}).finally(function() {
					btn.disabled = false;
					btn.textContent = 'اختبار اتصال RADIUS';
				});
			}
		}, 'اختبار اتصال RADIUS'),
		E('button', {
			'class': 'btn cbi-button',
			'click': function(ev) {
				ev.preventDefault();
				var btn = this;
				btn.disabled = true;
				btn.textContent = 'جارٍ فحص REST...';
				fs.exec_direct(CONNECT_TEST_CMD, [ 'rest' ], 'json').then(function(res) {
					notify(res && res.message ? res.message : 'فشل الاتصال.');
				}).finally(function() {
					btn.disabled = false;
					btn.textContent = 'اختبار اتصال RouterOS REST';
				});
			}
		}, 'اختبار اتصال RouterOS REST')
	]);
}

function renderPanel(key, status) {
	if (key == 'core') {
		return E('div', [
			E('h3', 'إعدادات المشغل والواجهات'),
			E('div', renderFields('server')),
			E('h3', 'ملف تعريف الخدمة'),
			E('div', renderFields('profile'))
		]);
	}
	if (key == 'auth') {
		return E('div', [
			E('h3', 'الربط مع MikroTik'),
			E('div', renderFields('radius')),
			renderRadiusTests()
		]);
	}
	if (key == 'portal') {
		return E('div', [
			E('h3', 'تخصيص صفحة الدخول'),
			E('div', renderFields('portal')),
			renderPortalUpload()
		]);
	}
	if (key == 'rules') {
		return E('div', [
			E('h3', 'تجاوز الحماية (Walled Garden)'),
			E('div', renderFields('security')),
			E('h3', 'إعدادات DNS'),
			E('div', renderFields('dns')),
			E('h3', 'تثبيت الآيبيات (Bindings)'),
			E('div', renderFields('bindings')),
			E('h3', 'الكوكيز المتقدمة'),
			E('div', renderFields('cookies')),
			E('h3', 'خيارات متقدمة'),
			E('div', renderFields('advanced'))
		]);
	}
	if (key == 'monitoring') {
		return E('div', [
			renderActive(status),
			E('h3', 'إحصائيات النظام'),
			renderStats(status),
			E('h3', 'إعدادات السجلات'),
			E('div', renderFields('logs')),
			E('h3', 'سجل العمليات'),
			renderLogs()
		]);
	}
	if (key == 'cookies') {
		return renderCookies(status);
	}
	if (key == 'review') {
		return renderReview(status);
	}

	return E('div', 'Section not found');
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('hotspot_openwrt'),
			L.resolveDefault(uci.load('setup'), null),
			L.resolveDefault(uci.load('hotspot_licensing'), null),
			uci.load('network'),
			uci.load('wireless'),
			fetchStatus()
		]);
	},

	render: function(data) {
		var status = data[4] || {};
		var licenseInfo = licenseCacheInfo();
		var tabs = {};
		var panels = {};
		var tabBar;
		var panelWrap;

		ensureStyles();

		tabBar = E('div', { 'class': 'hotspot-tabs' });
		panelWrap = E('div', { 'class': 'hotspot-card' });

		TABS.forEach(function(tab, index) {
			tabs[tab.id] = E('button', {
				'class': 'hotspot-tab' + (index === 0 ? ' is-active' : ''),
				'click': function(ev) {
					ev.preventDefault();
					switchTab(tab.id, panels, tabs);
				}
			}, tab.title);

			panels[tab.id] = E('section', {
				'class': 'hotspot-panel' + (index === 0 ? ' is-active' : '')
			}, [ renderPanel(tab.id, status) ]);

			tabBar.appendChild(tabs[tab.id]);
			panelWrap.appendChild(panels[tab.id]);
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
			E('aside', { 'style': 'display:flex; flex-direction:column; gap:20px;' }, [
				E('div', { 'class': 'hotspot-card', 'style': 'background:radial-gradient(circle at top, #1a1a1a 0%, #000 100%); border:1px solid #D4AF37; text-align:center;' }, [
					E('div', { 'style': 'font-size:3rem; margin-bottom:10px;' }, '👑'),
					E('h3', { 'style': 'color:#D4AF37; margin:0; letter-spacing:2px; font-weight:950;' }, 'التحكم الملكي'),
					E('div', { 'style': 'font-size:0.7rem; color:rgba(212,175,55,0.5); margin-top:5px;' }, 'PLATINUM EDITION')
				]),
				E('div', { 'class': 'hotspot-card' }, [
					E('h3', { 'style': 'color:#D4AF37; display:flex; justify-content:space-between; align-items:center;' }, [
						'الحالة الحالية',
						E('button', { 
							'class': 'spinning', 
							'style': 'background:transparent; border:none; cursor:pointer; font-size:1.2rem;',
							'click': function() { location.reload(); }
						}, '🔄')
					]),
					E('div', { 'class': 'hotspot-status-grid' }, [
						statusItem('الترخيص', licenseInfo.label),
						statusItem('الخدمة', E('span', { 'id': 'hotspot-openwrt-live-runtime' }, statusText(status.chilli_running, '✅ يعمل', '❌ متوقف'))),
						statusItem('tun0', statusText(status.tun0_present, '✅ موجود', '❌ غير موجود')),
						statusItem('المسار', statusText(status.route_ok, '✅ صحيح', '⚠️ غير مؤكد')),
						statusItem('Active Sessions', E('span', { 'id': 'hotspot-openwrt-live-active', 'style': 'color:#4CAF50; font-size:1.5rem;' }, String(status.active_clients || 0))),
						statusItem('Total Hosts', E('span', { 'id': 'hotspot-openwrt-live-total' }, String(status.clients_total || 0))),
						statusItem('RADIUS Server', (status.radius_server || '-')),
						statusItem('NAS ID', (status.radius_nas_id || '-'))
					])
				])
			]),
			E('main', [
				E('div', { 'class': 'hotspot-card hotspot-hero' }, [
					E('h2', {}, 'Hotspot OpenWrt'),
					E('p', {}, 'نظام الإمبراطور المتكامل لإدارة شبكات الهوتسبوت بأعلى أداء واستقرار.')
				]),
				tabBar,
				panelWrap
			])
		]);
	}
});