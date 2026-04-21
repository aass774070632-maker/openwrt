'use strict';
'require view';
'require dom';
'require poll';
'require rpc';
'require uci';
'require ui';

var callBoard = rpc.declare({
	object: 'system',
	method: 'board',
	expect: { '': {} }
});

var callLanStatus = rpc.declare({
	object: 'network.interface.lan',
	method: 'status',
	expect: { '': {} }
});

var callWirelessStatus = rpc.declare({
	object: 'network.wireless',
	method: 'status',
	expect: { '': {} }
});

var callFrequencyList = rpc.declare({
	object: 'iwinfo',
	method: 'freqlist',
	params: [ 'device' ],
	expect: { results: [] }
});

var callSetPassword = rpc.declare({
	object: 'luci',
	method: 'setPassword',
	params: [ 'username', 'password' ],
	expect: { result: false }
});

var WATCHCAT_SID = 'alemprator_periodic_reboot';
var STEP_KEYS = [ 'lan', 'mode', 'wifi', 'vlan', 'channel' ];
var WIZARD_BUILD_TAG = 'r84';
var WIZARD_ROUTE = '/cgi-bin/luci/admin/applications/alemprator';
var VIDEO_EXPLAIN_URL = 'https://www.facebook.com/people/%D8%AC%D9%84%D8%A7%D9%84-%D8%A7%D8%AD%D9%85%D8%AF-%D8%A7%D9%84%D9%82%D8%AD%D9%85/100010720113363/';
var FIRSTBOOT_DEFAULT_NETWORK = 'alemprator_setup';
var FIRSTBOOT_DEFAULT_WIRELESS = 'alemprator_firstboot';

function notify(message) {
	ui.addNotification(null, E('p', message));
}

function buildWizardUrl(lanIpaddr) {
	var protocol = /^https?:$/.test(window.location.protocol || '') ? window.location.protocol : 'http:';
	var host = String(lanIpaddr || '').trim() || window.location.hostname;

	return protocol + '//' + host + WIZARD_ROUTE + '?v=' + encodeURIComponent(WIZARD_BUILD_TAG);
}

function scheduleWizardRedirect(lanIpaddr, delayMs) {
	window.setTimeout(function() {
		window.location.replace(buildWizardUrl(lanIpaddr));
	}, delayMs || 0);
}

function isIPv4(value) {
	return /^(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])){3}$/.test(value || '');
}

function strip5GSuffix(value) {
	return String(value || '')
		.replace(/[ _-]?vlan[ _-]?5g(?:hz)?$/i, '')
		.replace(/[ _-]?vlan$/i, '')
		.replace(/[ _-]?5g(?:hz)?$/i, '');
}

function normalizeMode(value) {
	if (value == 'ap' || value == 'ap_wds' || value == 'sta_wds' || value == 'mesh')
		return value;

	return 'ap';
}

function modeNeedsDeferredApply(value) {
	return false;
}

function deriveVlanGateway(baseIp, vlanId) {
	var octets = String(baseIp || '').split('.');
	var derivedId = Math.min(Math.max(parseInt(vlanId, 10) || 10, 1), 254);

	if (octets.length == 4)
		return [ octets[0], octets[1], String(derivedId), '1' ].join('.');

	return [ '192', '168', String(derivedId), '1' ].join('.');
}

function describeSecondaryVlanBinding(vlanId) {
	var normalizedId = Math.min(Math.max(parseInt(vlanId, 10) || 10, 1), 4094);

	return 'wizardvlan -> vlan_' + normalizedId + ' (' + _('غير مُدار') + ')';
}

function normalizeList(value) {
	if (Array.isArray(value))
		return value.slice();

	if (value == null || value === '')
		return [];

	return [ value ];
}

function ensureListContains(conf, sid, opt, value) {
	var list = normalizeList(uci.get(conf, sid, opt));

	if (list.indexOf(value) == -1) {
		list.push(value);
		uci.set(conf, sid, opt, list);
	}
}

function removeListValue(conf, sid, opt, value) {
	var list = normalizeList(uci.get(conf, sid, opt)).filter(function(entry) {
		return entry != value;
	});

	if (list.length)
		uci.set(conf, sid, opt, list);
	else
		uci.unset(conf, sid, opt);
}

function findFirewallZone(name) {
	var zones = uci.sections('firewall', 'zone');
	var i;

	for (i = 0; i < zones.length; i++) {
		if (zones[i].name == name)
			return zones[i]['.name'];
	}

	return null;
}

function findWifiIface(deviceName) {
	var sections = uci.sections('wireless', 'wifi-iface');
	var fallback = null;
	var i;

	for (i = 0; i < sections.length; i++) {
		var section = sections[i];

		if (section.device != deviceName)
			continue;

		if (fallback == null)
			fallback = section['.name'];

		if (section.mode == null || section.mode == 'ap')
			return section['.name'];
	}

	return fallback;
}

function findLanApIface(deviceName) {
	var sections = uci.sections('wireless', 'wifi-iface');
	var i;

	for (i = 0; i < sections.length; i++) {
		var section = sections[i];

		if (section.device != deviceName)
			continue;

		if ((section.mode == null || section.mode == 'ap') && section.network == 'lan')
			return section['.name'];
	}

	return null;
}

function ensureWifiIface(deviceName) {
	var ifaceName = findLanApIface(deviceName);
	var networks;

	if (ifaceName != null)
		return ifaceName;

	ifaceName = findWifiIface(deviceName);

	if (ifaceName != null) {
		networks = normalizeList(uci.get('wireless', ifaceName, 'network'));

		// Do not reuse a pure wizardvlan iface as the primary LAN AP section.
		if (networks.indexOf('lan') > -1 || networks.indexOf('wizardvlan') == -1)
			return ifaceName;
	}

	ifaceName = uci.add('wireless', 'wifi-iface');
	uci.set('wireless', ifaceName, 'device', deviceName);
	uci.set('wireless', ifaceName, 'mode', 'ap');
	uci.set('wireless', ifaceName, 'network', 'lan');
	uci.set('wireless', ifaceName, 'encryption', 'none');
	uci.set('wireless', ifaceName, 'ssid', 'OpenWrt');

	return ifaceName;
}

function secondaryApSectionName(deviceName) {
	return 'wizard_vlan_' + String(deviceName || 'radio').replace(/[^A-Za-z0-9_]/g, '_') + '_ap';
}

function secondarySsid(baseSsid, band) {
	var state = (baseSsid != null && typeof baseSsid == 'object') ? baseSsid : null;
	var normalizedBase = String(state ? state.wifiSsid : baseSsid || 'OpenWrt').trim() || 'OpenWrt';

	if (band == '5g')
		return normalizedBase + '_VLAN_5G';

	return normalizedBase + '_VLAN';
}

function previewSecondaryBaseSsid(state) {
	var manualBase = String(state ? state.wifiSsidVlan : '').trim();

	if (manualBase)
		return manualBase;

	return '';
}

function previewSecondarySsid(state, band) {
	var manualBase = previewSecondaryBaseSsid(state);

	if (!manualBase)
		return secondarySsid(state, band);

	if (band == '5g')
		return manualBase + '_5G';

	return manualBase;
}

function primarySsid(baseSsid, band) {
	var state = (baseSsid != null && typeof baseSsid == 'object') ? baseSsid : null;
	var normalizedBase = String(state ? state.wifiSsid : baseSsid || 'OpenWrt').trim() || 'OpenWrt';
	var custom5g = String(state ? state.wifiSsid5g : '').trim();
	var custom5gEnabled = !!(state && state.wifiSsid5gMode == 'custom' && custom5g);

	if (band == '5g')
		if (custom5gEnabled)
			return custom5g;

	if (band == '5g')
		return normalizedBase + '_5G';

	return normalizedBase;
}

function applyWifiIfaceFlag(conf, sid, optionName, enabled) {
	if (enabled == null)
		return;

	if (enabled)
		uci.set(conf, sid, optionName, '1');
	else
		uci.unset(conf, sid, optionName);
}

function getLocalApPolicy(state, networkName) {
	var requestedMode = normalizeMode(state && state.mode);
	var hideLocalAp = (requestedMode == 'ap_wds' && state && state.isVlan);
	var enableWds = (requestedMode == 'ap_wds' || requestedMode == 'sta_wds');

	if (requestedMode == 'sta_wds')
		hideLocalAp = true;

	if (requestedMode == 'mesh' && state && !state.isVlan) {
		enableWds = true;
		hideLocalAp = true;
	}

	if (networkName == 'wizardvlan') {
		return {
			network: 'wizardvlan',
			enableWds: false,
			hidden: false,
			isolate: true
		};
	}

	return {
		network: networkName || 'lan',
		enableWds: enableWds,
		hidden: hideLocalAp,
		isolate: false
	};
}

function sortBands(bands) {
	var order = {
		'2g': 0,
		'5g': 1
	};

	return (bands || []).slice().sort(function(a, b) {
		return (order[a] != null ? order[a] : 99) - (order[b] != null ? order[b] : 99);
	});
}

function getRemainingLocalBands(radios, state) {
	var requestedMode = normalizeMode(state.mode);
	var blockedRadioName = null;
	var bands = [];
	var selectedRadio;

	if (requestedMode == 'sta_wds') {
		selectedRadio = getRadioByBand(radios, state.uplinkBand);

		if (selectedRadio == null)
			selectedRadio = getRadioByBand(radios, '2g') || getRadioByBand(radios, '5g');

		blockedRadioName = selectedRadio ? selectedRadio['.name'] : null;
	}
	else if (requestedMode == 'mesh') {
		selectedRadio = getRadioByBand(radios, state.meshBand);

		if (selectedRadio == null)
			selectedRadio = getRadioByBand(radios, '2g') || getRadioByBand(radios, '5g');

		blockedRadioName = selectedRadio ? selectedRadio['.name'] : null;
	}

	(radios || []).forEach(function(radio) {
		if (blockedRadioName && radio['.name'] == blockedRadioName)
			return;

		if (radio.band == '2g' || radio.band == '5g')
			bands.push(radio.band);
	});

	return sortBands(bands);
}

function describeAppliedSecondaryNetworkResult(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var remainingCount = remainingBands.length;
	var onlyBand = remainingCount ? remainingBands[0] : null;

	if (!state.isVlan)
		return null;

	if (!remainingCount)
		return _('تم حفظ إعداد جسر VLAN الثانوي غير المُدار، لكن لا يوجد راديو متبقٍ متاح لنقطة وصول محلية في الوضع المحدد، لذا لم يتم إنشاء SSID واي فاي ثانوي. تبقى الشبكة الأساسية LAN والربط الصاعد على LAN.');

	if (remainingCount == 1)
		return _('الجسر الثانوي غير المُدار نشط. تبقى شبكة الواي فاي الأساسية على LAN، ونقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' تخدم SSID ثانوي معزول مدعوم بـ VLAN.');

	return _('الجسر الثانوي غير المُدار نشط. تبقى شبكة الواي فاي الأساسية على LAN، وتُخدم SSIDs الثانوية المعزولة المدعومة بـ VLAN الآن على راديوهات نقاط الوصول المحلية المتبقية.');
}

function describeAppliedModeResult(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var radio2g = getRadioByBand(radios || [], '2g');
	var uplinkBand = getRadioByBand(radios || [], state.uplinkBand) ? state.uplinkBand : (radio2g ? '2g' : '5g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');

	if (state.mode == 'ap_wds') {
		if (!remainingBands.length)
			return _('تم حفظ وضع نقطة الوصول + WDS، لكن لا يوجد حاليًا راديو محلي متاح لتقديم خدمة الواي فاي.');

		if (remainingBands.length == 1)
			return _('تم تطبيق وضع نقطة الوصول + WDS على نقطة الوصول المحلية على ') + bandLabel(onlyBand) + _('.');

		return _('تم تطبيق وضع نقطة الوصول + WDS على راديوي نقطة الوصول المحليين.');
	}

	if (state.mode == 'sta_wds') {
		if (!remainingBands.length)
			return _('وضع عميل + WDS يستخدم ') + bandLabel(uplinkBand) + _(' كربط صاعد، لذلك لا تبقى أي نقطة وصول محلية نشطة على الواي فاي. ويظل الوصول عبر LAN متاحًا.');

		if (remainingBands.length == 1)
			return _('تم تطبيق وضع عميل + WDS باستخدام ') + bandLabel(uplinkBand) + _(' للربط الصاعد، بينما تبقى نقطة الوصول المحلية على ') + bandLabel(onlyBand) + _(' نشطة.');

		return _('تم تطبيق وضع عميل + WDS باستخدام ') + bandLabel(uplinkBand) + _(' للربط الصاعد، بينما تبقى الراديوهات المحلية الأخرى نشطة كنقاط وصول.');
	}

	if (state.mode == 'mesh') {
		if (!remainingBands.length)
			return _('وضع الميش يستخدم ') + bandLabel(meshBand) + _(' كراديو backhaul، لذلك لا تبقى أي نقطة وصول محلية نشطة على الواي فاي. ويظل الوصول عبر LAN متاحًا.');

		if (remainingBands.length == 1)
			return _('تم تطبيق وضع الميش باستخدام ') + bandLabel(meshBand) + _(' كراديو backhaul، بينما تبقى نقطة الوصول المحلية على ') + bandLabel(onlyBand) + _(' نشطة.');

		return _('تم تطبيق وضع الميش باستخدام ') + bandLabel(meshBand) + _(' كراديو backhaul، بينما تبقى الراديوهات المحلية الأخرى نشطة كنقاط وصول.');
	}

	if (modeNeedsDeferredApply(state.mode))
		return _('تم حفظ وضع التشغيل المحدد، لكن سلوكه الشبكي المتخصص سيُضاف في مرحلة لاحقة. ويبقى الواي فاي حاليًا على سلوك نقطة الوصول.');

	return null;
}

function describeReconnectHint(state, radios, oldBaseSsid) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var newBaseSsid = String(state.wifiSsid || '').trim();
	var oldNormalizedBaseSsid = String(oldBaseSsid || '').trim();
	var activeSsids;

	if (!newBaseSsid || newBaseSsid == oldNormalizedBaseSsid || !remainingBands.length)
		return null;

	activeSsids = remainingBands.map(function(band) {
		return primarySsid(state, band);
	});

	if (activeSsids.length == 1)
		return _('أعد الاتصال يدويًا بشبكة SSID المحلية النشطة: ') + activeSsids[0] + _('.');

	return _('أعد الاتصال يدويًا بإحدى شبكات SSID المحلية النشطة: ') + activeSsids.join(', ') + _('.');
}

function describePrimaryWifiPlan(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!remainingBands.length)
		return _('في وضع التشغيل المحدد لن تبقى أي شبكة واي فاي أساسية محلية نشطة، وسيظل الوصول متاحا عبر LAN.');

	if (remainingBands.length == 1)
		return _('اسم الشبكة الأساسية المحلية النشطة سيكون ') + primarySsid(state, firstBand) + _(' على ') + bandLabel(firstBand) + _('.');

	return _('أسماء الشبكات الأساسية المحلية ستكون ') + primarySsid(state, firstBand) + _(' على ') + bandLabel(firstBand) + _(' و ') + primarySsid(state, secondBand) + _(' على ') + bandLabel(secondBand) + _('.');
}

function describePrimaryWifiNamingHelp(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var automatic5gName = primarySsid({
		wifiSsid: state ? state.wifiSsid : '',
		wifiSsid5gMode: 'derived',
		wifiSsid5g: ''
	}, '5g');

	if (!remainingBands.length)
		return _('في هذا الوضع لن تبقى أي شبكة واي فاي أساسية محلية نشطة. مع ذلك سيبقى الاسم الأساسي محفوظا، وسيظل الوصول متاحا عبر LAN.');

	if (remainingBands.length == 1) {
		if (remainingBands[0] == '5g')
			return (state && state.wifiSsid5gMode == 'custom')
				? _('في هذا الوضع سيبقى فقط راديو 5GHz متاحا كنقطة وصول محلية، لذلك سيكون الاسم الأساسي الفعلي هو الاسم المخصص الذي تدخله هنا.')
				: _('في هذا الوضع سيبقى فقط راديو 5GHz متاحا كنقطة وصول محلية، لذلك سيُنشأ الاسم الأساسي الفعلي تلقائيا بهذا الشكل: ') + automatic5gName + _(' .');

		return _('في هذا الوضع سيبقى فقط راديو 2.4GHz متاحا كنقطة وصول محلية، لذلك سيُستخدم الاسم الأساسي كما هو.');
	}

	if (state && state.wifiSsid5gMode == 'custom')
		return _('سيستخدم راديو 2.4GHz الاسم الأساسي، بينما سيستخدم راديو 5GHz الاسم المخصص الذي تدخله هنا.');

	return _('سيستخدم راديو 2.4GHz الاسم الأساسي، وسيُنشأ اسم 5GHz تلقائيا بإضافة اللاحقة المناسبة. الاسم المتوقع حاليا هو: ') + automatic5gName + _(' .');
}

function describeSecondaryNetworkNotice(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!state.isVlan)
		return '';

	if (!remainingBands.length)
		return _('في هذا الوضع لن يبقى أي راديو لنقطة وصول محلية متاحًا لإضافة SSID ثانوي. ما زال يمكن إعداد جسر VLAN الثانوي غير المُدار، لكن لن يتم بث أي شبكة واي فاي ثانوية ما لم يبقَ راديو محلي متاح.');

	if (remainingBands.length == 1) {
		return _('فقط نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' يمكنها استضافة SSID الثانوي المعزول ') + previewSecondarySsid(state, onlyBand) + _(' المرتبط بـ VLAN على جسر wizardvlan غير المُدار في هذا الوضع. أما الراديوهات المحجوزة للربط الصاعد أو Mesh backhaul فتبقى بدون تغيير.');
	}

	return _('يمكن للراديوهات المحلية المتبقية لنقاط الوصول استضافة شبكات SSID الثانوية المعزولة المرتبطة بـ VLAN: ') + previewSecondarySsid(state, firstBand) + _(' على ') + bandLabel(firstBand) + _(' و ') + previewSecondarySsid(state, secondBand) + _(' على ') + bandLabel(secondBand) + _(' فوق جسر wizardvlan غير المُدار في هذا الوضع، مع بقاء خدمة LAN الأساسية وأي ربط صاعد أو Mesh backhaul بدون تغيير.');
}

function describeSecondarySubnetHelp(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!state.isVlan)
		return _('عند التفعيل، سترتبط شبكات SSID الثانوية بهذا الجسر غير المُدار لـ VLAN بينما تبقى الشبكة الرئيسية LAN بدون تغيير على شبكات SSID الأساسية.');

	if (!remainingBands.length)
		return _('سيُجهز هذا الجسر غير المُدار لـ VLAN من أجل إعداد الشبكة الثانوية، لكن لن تتمكن أي شبكة واي فاي ثانوية من استخدامه ما لم يبقَ راديو محلي لنقطة وصول متاحًا في الوضع المحدد.');

	if (remainingBands.length == 1)
		return _('سيتم ربط العملاء الذين ينضمون إلى شبكة SSID الثانوية ') + previewSecondarySsid(state, onlyBand) + _(' على ') + bandLabel(onlyBand) + _(' بهذا الجسر غير المُدار لـ VLAN، بينما تبقى الشبكة الرئيسية LAN بدون تغيير على شبكات SSID الأساسية.');

	return _('سيتم ربط العملاء الذين ينضمون إلى شبكتي SSID الثانويتين ') + previewSecondarySsid(state, firstBand) + _(' على ') + bandLabel(firstBand) + _(' و ') + previewSecondarySsid(state, secondBand) + _(' على ') + bandLabel(secondBand) + _(' بهذا الجسر غير المُدار لـ VLAN، بينما تبقى الشبكة الرئيسية LAN بدون تغيير على شبكات SSID الأساسية.');
}

function describeSecondaryNetworkIntro(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!remainingBands.length)
		return _('ستبقى الشبكة الرئيسية LAN وأي backhaul خاص بالوضع المحدد على LAN. في هذا الوضع يمكن لهذه الخطوة تجهيز جسر VLAN إضافي غير مُدار، لكن لن يتم بث أي SSID ثانوي لأن أي راديو محلي لنقطة وصول لم يعد متاحًا.');

	if (remainingBands.length == 1)
		return _('ستبقى الشبكة الرئيسية LAN وأي backhaul خاص بالوضع المحدد على LAN. في هذا الوضع تضيف هذه الخطوة ربط واي فاي إضافيًا غير مُدار ومدعومًا بـ VLAN باستخدام SSID الثانوي ') + previewSecondarySsid(state, onlyBand) + _(' على نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _('.');

	return _('ستبقى الشبكة الرئيسية LAN وأي backhaul خاص بالوضع المحدد على LAN. تضيف هذه الخطوة ربط واي فاي إضافيًا غير مُدار ومدعومًا بـ VLAN باستخدام شبكتي SSID الثانويتين ') + previewSecondarySsid(state, firstBand) + _(' على ') + bandLabel(firstBand) + _(' و ') + previewSecondarySsid(state, secondBand) + _(' على ') + bandLabel(secondBand) + _(' بدون نقل الواي فاي الرئيسي بعيدًا عن LAN.');
}

function describeUplinkSettingsHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var uplinkBand = getRadioByBand(radios || [], state.uplinkBand) ? state.uplinkBand : (radio2g ? '2g' : '5g');
	var remainingBands = getRemainingLocalBands(radios || [], state);
	var onlyBand = remainingBands[0];

	if (!remainingBands.length)
		return _('تتحكم هذه القيم في الربط الصاعد الفعلي المستخدم في وضع Client + WDS. سيصبح الراديو المحدد على ') + bandLabel(uplinkBand) + _(' هو ربط الجسر العميل، ولن تبقى أي نقطة وصول محلية نشطة على الواي فاي في هذا التكوين.');

	if (remainingBands.length == 1)
		return _('تتحكم هذه القيم في الربط الصاعد الفعلي المستخدم في وضع Client + WDS. سيصبح الراديو المحدد على ') + bandLabel(uplinkBand) + _(' هو ربط الجسر العميل، بينما ستبقى نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' متاحة لشبكة الواي فاي المحلية.');

	return _('تتحكم هذه القيم في الربط الصاعد الفعلي المستخدم في وضع Client + WDS. سيصبح الراديو المحدد هو ربط الجسر العميل، بينما يبقى أي راديو متبقٍ متاحًا لنقطة الوصول المحلية.');
}

function describeMeshSettingsHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');
	var remainingBands = getRemainingLocalBands(radios || [], state);
	var onlyBand = remainingBands[0];

	if (!remainingBands.length)
		return _('سينضم راديو Mesh المحدد على ') + bandLabel(meshBand) + _(' إلى شبكة الـ Mesh أو ينشئها، ولن تبقى أي نقطة وصول محلية نشطة على الواي فاي في هذا التكوين.');

	if (remainingBands.length == 1)
		return _('سينضم راديو Mesh المحدد على ') + bandLabel(meshBand) + _(' إلى شبكة الـ Mesh أو ينشئها، بينما تبقى نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' متاحة لشبكة الواي فاي المحلية.');

	return _('سينضم راديو Mesh المحدد إلى شبكة Mesh أو ينشئها على النطاق المختار، بينما يبقى أي راديو متبقٍ متاحًا لنقطة الوصول المحلية.');
}

function describeMeshChannelHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');
	var meshChannel = meshBand == '5g' ? state.channel5g : state.channel2g;

	if (meshChannel && meshChannel != 'auto')
		return _('ستستخدم شبكة Mesh القناة الثابتة ') + meshChannel + _(' على ') + bandLabel(meshBand) + _('.');

	return _('تتطلب شبكة Mesh قناة ثابتة على ') + bandLabel(meshBand) + _('، ولا يمكن استخدام Auto لهذا النطاق.');
}

function configureApIface(sid, deviceName, networkName, ssid, key, enableWds) {
	var policy = (enableWds != null && typeof enableWds == 'object') ? enableWds : {
		enableWds: !!enableWds,
		hidden: null,
		isolate: null
	};

	uci.set('wireless', sid, 'device', deviceName);
	uci.set('wireless', sid, 'mode', 'ap');
	uci.set('wireless', sid, 'network', networkName);
	uci.set('wireless', sid, 'disabled', '0');
	uci.set('wireless', sid, 'ssid', ssid);
	uci.unset('wireless', sid, 'mesh_id');
	uci.set('wireless', sid, 'disassoc_low_ack', '0');
	setWifiSecurity('wireless', sid, key);

	if (policy.enableWds)
		uci.set('wireless', sid, 'wds', '1');
	else
		uci.unset('wireless', sid, 'wds');

	applyWifiIfaceFlag('wireless', sid, 'hidden', policy.hidden);
	applyWifiIfaceFlag('wireless', sid, 'isolate', policy.isolate);
}

function wifiDeviceName(device) {
	return device ? device['.name'] : null;
}

function inferUplinkBand(radio2g, radio5g) {
	var configuredBand = uci.get('setup', 'default', 'uplink_band');
	var uplinkDevice = uci.get('wireless', 'wizard_uplink', 'device');

	if (radio2g && uplinkDevice == radio2g['.name'])
		return '2g';

	if (radio5g && uplinkDevice == radio5g['.name'])
		return '5g';

	if (configuredBand == '2g' || configuredBand == '5g')
		return configuredBand;

	return radio2g ? '2g' : '5g';
}

function inferMeshBand(radio2g, radio5g) {
	var configuredBand = uci.get('setup', 'default', 'mesh_band');
	var meshDevice = uci.get('wireless', 'wizard_mesh', 'device');

	if (radio2g && meshDevice == radio2g['.name'])
		return '2g';

	if (radio5g && meshDevice == radio5g['.name'])
		return '5g';

	if (configuredBand == '2g' || configuredBand == '5g')
		return configuredBand;

	return radio2g ? '2g' : '5g';
}

function ensureNamedWifiIface(sid) {
	ensureNamedSection('wireless', sid, 'wifi-iface');
	return sid;
}

function setWifiSecurity(conf, sid, key) {
	if (key) {
		uci.set(conf, sid, 'encryption', 'psk2');
		uci.set(conf, sid, 'key', key);
	}
	else {
		uci.set(conf, sid, 'encryption', 'none');
		uci.unset(conf, sid, 'key');
	}
}

function ensureNamedSection(conf, sid, type) {
	if (!uci.get(conf, sid))
		uci.add(conf, type, sid);
}

function getPeriodicRebootSection() {
	var section = uci.get('watchcat', WATCHCAT_SID);

	if (section && section['.type'] == 'watchcat')
		return section;

	return null;
}

function parseHours(value) {
	var normalized = String(value || '').trim().toLowerCase();
	var amount;

	if (!normalized)
		return null;

	if (/^[1-9][0-9]*$/.test(normalized))
		return normalized;

	if ((amount = normalized.match(/^([1-9][0-9]*)h$/)))
		return amount[1];

	if ((amount = normalized.match(/^([1-9][0-9]*)d$/)))
		return String(parseInt(amount[1], 10) * 24);

	if ((amount = normalized.match(/^([1-9][0-9]*)m$/)))
		return String(Math.max(Math.round(parseInt(amount[1], 10) / 60), 1));

	if ((amount = normalized.match(/^([1-9][0-9]*)s$/)))
		return String(Math.max(Math.round(parseInt(amount[1], 10) / 3600), 1));

	return null;
}

function formatRebootPeriod(hours) {
	return String(parseInt(hours, 10)) + 'h';
}

function radioLabel(device) {
	var label = _('الراديو') + ' ' + device['.name'];

	if (device.band)
		label += ' (' + String(device.band).toUpperCase() + ')';

	return label;
}

function bandLabel(band) {
	if (band == '5g')
		return _('راديو 5GHz');

	return _('راديو 2.4GHz');
}

function getRadioByBand(radios, band) {
	var i;

	for (i = 0; i < radios.length; i++) {
		if (radios[i].band == band)
			return radios[i];
	}

	if (band == '2g')
		return radios[0] || null;

	if (band == '5g')
		return radios[1] || radios[0] || null;

	return null;
}

function wifiModeChoices(band) {
	if (band == '2g') {
		return [
			{ value: 'ax', label: 'AX' },
			{ value: 'n', label: 'N' }
		];
	}

	return [
		{ value: 'ax', label: 'AX' },
		{ value: 'ac', label: 'AC' },
		{ value: 'n', label: 'N' }
	];
}

function defaultWifiWidth(band, mode) {
	if (band == '2g')
		return '20';

	if (mode == 'n')
		return '40';

	return '80';
}

function wifiWidthChoices(band, mode) {
	var values = (band == '2g' || mode == 'n')
		? [ '20', '40' ]
		: [ '20', '40', '80' ];

	return values.map(function(value) {
		return { value: value, label: value + ' MHz' };
	});
}

function normalizeWifiModeForBand(band, value) {
	var normalized = String(value || '').toLowerCase();
	var allowed = wifiModeChoices(band).map(function(choice) { return choice.value; });

	if (allowed.indexOf(normalized) > -1)
		return normalized;

	return 'ax';
}

function normalizeWifiWidthForBand(band, mode, value) {
	var normalized = String(value || '');
	var allowed = wifiWidthChoices(band, mode).map(function(choice) { return choice.value; });

	if (allowed.indexOf(normalized) > -1)
		return normalized;

	return defaultWifiWidth(band, mode);
}

function inferWifiModeFromHtmode(band, htmode) {
	var normalized = String(htmode || '').toUpperCase();

	if (normalized.indexOf('HE') === 0 || normalized.indexOf('EHT') === 0)
		return 'ax';

	if (normalized.indexOf('VHT') === 0)
		return (band == '5g') ? 'ac' : 'n';

	if (normalized.indexOf('HT') === 0)
		return 'n';

	return 'ax';
}

function inferWifiWidthFromHtmode(band, htmode) {
	var normalized = String(htmode || '').toUpperCase();
	var inferredMode = inferWifiModeFromHtmode(band, htmode);

	if (normalized.indexOf('160') > -1 || normalized.indexOf('80') > -1)
		return normalizeWifiWidthForBand(band, inferredMode, '80');

	if (normalized.indexOf('40') > -1)
		return normalizeWifiWidthForBand(band, inferredMode, '40');

	if (normalized.indexOf('20') > -1)
		return normalizeWifiWidthForBand(band, inferredMode, '20');

	return defaultWifiWidth(band, inferredMode);
}

function wifiHtmodeFromSelection(band, mode, width) {
	var normalizedMode = normalizeWifiModeForBand(band, mode);
	var normalizedWidth = normalizeWifiWidthForBand(band, normalizedMode, width);

	if (band == '2g') {
		if (normalizedMode == 'n')
			return normalizedWidth == '40' ? 'HT40' : 'HT20';

		return normalizedWidth == '40' ? 'HE40' : 'HE20';
	}

	if (normalizedMode == 'n')
		return normalizedWidth == '40' ? 'HT40' : 'HT20';

	if (normalizedMode == 'ac') {
		if (normalizedWidth == '80')
			return 'VHT80';

		return normalizedWidth == '40' ? 'VHT40' : 'VHT20';
	}

	if (normalizedWidth == '80')
		return 'HE80';

	return normalizedWidth == '40' ? 'HE40' : 'HE20';
}

function applyRadioHtmode(radio, band, state) {
	var radioName = radio && radio['.name'];
	var modeKey = band == '5g' ? 'wifiMode5g' : 'wifiMode2g';
	var widthKey = band == '5g' ? 'wifiWidth5g' : 'wifiWidth2g';

	if (!radioName)
		return;

	uci.set('wireless', radioName, 'htmode', wifiHtmodeFromSelection(band, state[modeKey], state[widthKey]));
}

function channelChoices(band, freqlist) {
	var choices = [ { value: 'auto', label: _('تلقائي') } ];
	var seen = { auto: true };
	var fallback;

	if (Array.isArray(freqlist) && freqlist.length) {
		freqlist.forEach(function(freq) {
			var restricted = !!freq.restricted && (freq.no_ir || (Array.isArray(freq.flags) && freq.flags.indexOf('no_ir') > -1));
			var channel = String(freq.channel || '');

			if (!channel || restricted || seen[channel])
				return;

			seen[channel] = true;
			choices.push({
				value: channel,
				label: channel + ' (' + String(freq.mhz || '?') + ' MHz)'
			});
		});
	}

	if (choices.length > 1)
		return choices;

	fallback = (band == '2g')
		? [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13' ]
		: [ '36', '40', '44', '48', '52', '56', '60', '64', '100', '104', '108', '112', '116', '120', '124', '128', '132', '136', '140', '144', '149', '153', '157', '161', '165' ];

	fallback.forEach(function(channel) {
		choices.push({ value: channel, label: channel });
	});

	return choices;
}

function populateSelectOptions(select, choices, currentValue) {
	var hasCurrentValue = false;

	select.textContent = '';

	choices.forEach(function(choice) {
		if (String(choice.value) == String(currentValue))
			hasCurrentValue = true;

		select.appendChild(E('option', { 'value': choice.value }, choice.label));
	});

	if (!hasCurrentValue && currentValue)
		select.appendChild(E('option', { 'value': currentValue }, String(currentValue)));

	select.value = currentValue || 'auto';
}

function renderWirelessSummary(status) {
	var entries = [];
	var keys = Object.keys(status || {}).sort();
	var i;

	if (!keys.length)
		return E('p', _('لا تتوفر حاليًا معلومات تشغيل مباشرة عن الواي فاي.'));

	for (i = 0; i < keys.length; i++) {
		var radioName = keys[i];
		var radio = status[radioName] || {};
		var ifaceSummary = [];
		var interfaces = Array.isArray(radio.interfaces) ? radio.interfaces : [];
		var j;

		for (j = 0; j < interfaces.length; j++) {
			var iface = interfaces[j] || {};
			var ssid = iface.ssid || (iface.config && iface.config.ssid) || '?';
			var mode = iface.mode || (iface.config && iface.config.mode) || '?';
			var state = iface.up ? _('نشط') : _('متوقف');

			ifaceSummary.push(ssid + ' [' + mode + ', ' + state + ']');
		}

		if (!ifaceSummary.length)
			ifaceSummary.push(radio.up ? _('نشط') : _('متوقف'));

		entries.push(E('li', radioLabel({ '.name': radioName, band: radio.config && radio.config.band }) + ': ' + ifaceSummary.join(', ')));
	}

	return E('ul', { 'style': 'margin:0; padding-left:1.2em' }, entries);
}

function renderStatusPanel(board, lanStatus, wirelessStatus) {
	var ipv4 = '-';
	var addresses = lanStatus && lanStatus['ipv4-address'];

	if (Array.isArray(addresses) && addresses.length) {
		ipv4 = addresses[0].address || '-';

		if (addresses[0].mask != null)
			ipv4 += '/' + addresses[0].mask;
	}

	return E('div', { 'class': 'cbi-section' }, [
		E('h3', _('الحالة الحالية')),
		E('div', { 'class': 'cbi-section-node' }, [
			E('p', [
				E('strong', _('الموديل') + ': '),
				(board && board.model) || (board && board.system) || '-'
			]),
			E('p', [
				E('strong', _('المنصة') + ': '),
				(board && board.release && board.release.target) || '-'
			]),
			E('p', [
				E('strong', _('عنوان LAN') + ': '),
				ipv4
			]),
			E('div', [
				E('strong', _('الواي فاي') + ': '),
				renderWirelessSummary(wirelessStatus)
			])
		])
	]);
}

function renderWizardCard(title, description, children) {
	var headerChildren = [ E('h4', { 'style': 'margin:0; color:#102a43;' }, title) ];
	var bodyChildren = Array.isArray(children) ? children.filter(function(child) { return child != null; }) : [];

	if (description)
		headerChildren.push(E('p', { 'style': 'margin:6px 0 0 0; color:#52606d;' }, description));

	return E('div', {
		'style': 'margin-top:14px; padding:14px 16px; border:1px solid #d8dee9; border-radius:12px; background:linear-gradient(180deg, #ffffff 0%, #f7f9fc 100%); box-shadow:0 1px 2px rgba(15,23,42,0.04);'
	}, [
		E('div', { 'style': 'margin-bottom:12px; padding-bottom:10px; border-bottom:1px solid #e5e7eb;' }, headerChildren),
		E('div', bodyChildren)
	]);
}

function disableFirstbootProvisioning() {
	var enabled = uci.get('alemprator_firstboot', 'main', 'enabled');
	var networkSection = uci.get('alemprator_firstboot', 'main', 'network_section') || FIRSTBOOT_DEFAULT_NETWORK;
	var wirelessSection = uci.get('alemprator_firstboot', 'main', 'wireless_section') || FIRSTBOOT_DEFAULT_WIRELESS;
	var dhcpSection = uci.get('alemprator_firstboot', 'main', 'dhcp_section') || networkSection;
	var firewallSection = uci.get('alemprator_firstboot', 'main', 'firewall_section') || networkSection;

	if (enabled != '1')
		return false;

	uci.remove('dhcp', dhcpSection);
	uci.remove('network', networkSection);
	uci.remove('wireless', wirelessSection);
	uci.remove('firewall', firewallSection);
	uci.set('network', 'lan', 'proto', 'static');
	uci.unset('dhcp', 'lan', 'ignore');
	uci.set('alemprator_firstboot', 'main', 'enabled', '0');

	return true;
}

return view.extend({
	load: function() {
		return Promise.all([
			L.resolveDefault(callBoard(), {}),
			L.resolveDefault(callLanStatus(), {}),
			L.resolveDefault(callWirelessStatus(), {}),
			L.resolveDefault(uci.load('alemprator_firstboot'), null),
			uci.load('setup'),
			L.resolveDefault(uci.load('watchcat'), null),
			uci.load('network'),
			uci.load('wireless'),
			uci.load('dhcp'),
			uci.load('firewall')
		]).then(function(results) {
			var radios = uci.sections('wireless', 'wifi-device');

			return Promise.all(radios.map(function(radio) {
				return L.resolveDefault(callFrequencyList(radio['.name']), []);
			})).then(function(freqLists) {
				var frequencyMap = {};

				radios.forEach(function(radio, index) {
					frequencyMap[radio['.name']] = freqLists[index] || [];
				});

				results.push(frequencyMap);
				return results;
			});
		});
	},

	renderStatus: function(container) {
		return Promise.all([
			L.resolveDefault(callBoard(), {}),
			L.resolveDefault(callLanStatus(), {}),
			L.resolveDefault(callWirelessStatus(), {})
		]).then(function(results) {
			dom.content(container, renderStatusPanel(results[0], results[1], results[2]));
		});
	},

	readState: function(radios) {
		var radio2g = getRadioByBand(radios, '2g');
		var radio5g = getRadioByBand(radios, '5g');
		var htmode2g = radio2g ? (uci.get('wireless', radio2g['.name'], 'htmode') || '') : '';
		var htmode5g = radio5g ? (uci.get('wireless', radio5g['.name'], 'htmode') || '') : '';
		var firstbootEnabled = uci.get('alemprator_firstboot', 'main', 'enabled') == '1';
		var firstbootLanIpaddr = uci.get('alemprator_firstboot', 'main', 'lan_ipaddr') || '';
		var firstbootLanNetmask = uci.get('alemprator_firstboot', 'main', 'lan_netmask') || '';
		var iface2g = radio2g ? (findLanApIface(radio2g['.name']) || findWifiIface(radio2g['.name'])) : null;
		var iface5g = radio5g ? (findLanApIface(radio5g['.name']) || findWifiIface(radio5g['.name'])) : null;
		var mode = normalizeMode(uci.get('setup', 'default', 'mode'));
		var baseSsid = uci.get('setup', 'default', 'wifi_ssid') || '';
		var key = uci.get('setup', 'default', 'wifi_key') || '';
		var rebootSection = getPeriodicRebootSection();
		var rebootHours = rebootSection ? parseHours(rebootSection.period) : null;

		if (!baseSsid && iface2g)
			baseSsid = strip5GSuffix(uci.get('wireless', iface2g, 'ssid') || '');
		else if (!baseSsid && iface5g)
			baseSsid = strip5GSuffix(uci.get('wireless', iface5g, 'ssid') || '');

		if (!baseSsid)
			baseSsid = 'OpenWrt';

		if (!key && iface2g)
			key = uci.get('wireless', iface2g, 'key') || '';
		else if (!key && iface5g)
			key = uci.get('wireless', iface5g, 'key') || '';

		return {
			lanIpaddr: (firstbootEnabled ? firstbootLanIpaddr : '') || uci.get('network', 'lan', 'ipaddr') || uci.get('setup', 'default', 'lan_ipaddr') || '192.168.1.1',
			lanNetmask: (firstbootEnabled ? firstbootLanNetmask : '') || uci.get('network', 'lan', 'netmask') || uci.get('setup', 'default', 'lan_netmask') || '255.255.255.0',
			mode: mode,
			wifiSsid: baseSsid,
			wifiSsid5gMode: uci.get('setup', 'default', 'wifi_ssid_5g_mode') == 'custom' ? 'custom' : 'derived',
			wifiSsid5g: uci.get('setup', 'default', 'wifi_ssid_5g') || '',
			wifiSsidVlan: uci.get('setup', 'default', 'wifi_ssid_vlan') || '',
			wifiKey: key,
			uplinkSsid: uci.get('setup', 'default', 'uplink_ssid') || '',
			uplinkKey: uci.get('setup', 'default', 'uplink_key') || '',
			uplinkBand: inferUplinkBand(radio2g, radio5g),
			meshId: uci.get('setup', 'default', 'mesh_id') || '',
			meshKey: uci.get('setup', 'default', 'mesh_key') || '',
			meshBand: inferMeshBand(radio2g, radio5g),
			isVlan: uci.get('setup', 'default', 'is_vlan') == '1',
			vlanId: uci.get('setup', 'default', 'vlan_id') || '10',
			channel2g: (radio2g && uci.get('wireless', radio2g['.name'], 'channel')) || uci.get('setup', 'default', 'channel_2g') || 'auto',
			channel5g: (radio5g && uci.get('wireless', radio5g['.name'], 'channel')) || uci.get('setup', 'default', 'channel_5g') || 'auto',
			wifiMode2g: normalizeWifiModeForBand('2g', uci.get('setup', 'default', 'wifi_mode_2g') || inferWifiModeFromHtmode('2g', htmode2g)),
			wifiWidth2g: normalizeWifiWidthForBand('2g', uci.get('setup', 'default', 'wifi_mode_2g') || inferWifiModeFromHtmode('2g', htmode2g), uci.get('setup', 'default', 'wifi_width_2g') || inferWifiWidthFromHtmode('2g', htmode2g)),
			wifiMode5g: normalizeWifiModeForBand('5g', uci.get('setup', 'default', 'wifi_mode_5g') || inferWifiModeFromHtmode('5g', htmode5g)),
			wifiWidth5g: normalizeWifiWidthForBand('5g', uci.get('setup', 'default', 'wifi_mode_5g') || inferWifiModeFromHtmode('5g', htmode5g), uci.get('setup', 'default', 'wifi_width_5g') || inferWifiWidthFromHtmode('5g', htmode5g)),
			resetDisabled: uci.get('setup', 'default', 'reset_button_disabled') == '1',
			resetHoldSeconds: uci.get('setup', 'default', 'reset_hold_seconds') || '5',
			wpsDisabled: uci.get('setup', 'default', 'wps_button_disabled') == '1',
			rebootEnabled: rebootSection ? rebootSection.mode == 'periodic_reboot' : false,
			rebootHours: rebootHours || '24',
			adminPassword: '',
			adminPasswordConfirm: ''
		};
	},

	collectState: function() {
		this.state.lanIpaddr = this.refs.lanIpaddr.value.trim();
		this.state.lanNetmask = this.refs.lanNetmask.value.trim();
		this.state.mode = this.refs.mode.value;
		this.state.wifiSsid = this.refs.wifiSsid.value.trim();
		this.state.wifiSsid5gMode = this.refs.wifiSsid5gMode ? this.refs.wifiSsid5gMode.value : (this.state.wifiSsid5gMode || 'derived');
		this.state.wifiSsid5g = this.refs.wifiSsid5g ? this.refs.wifiSsid5g.value.trim() : (this.state.wifiSsid5g || '');
		this.state.wifiSsidVlan = this.refs.wifiSsidVlan ? this.refs.wifiSsidVlan.value.trim() : (this.state.wifiSsidVlan || '');
		this.state.wifiKey = this.refs.wifiKey.value;
		this.state.uplinkSsid = this.refs.uplinkSsid ? this.refs.uplinkSsid.value.trim() : '';
		this.state.uplinkKey = this.refs.uplinkKey ? this.refs.uplinkKey.value : '';
		this.state.uplinkBand = this.refs.uplinkBand ? this.refs.uplinkBand.value : '2g';
		this.state.meshId = this.refs.meshId ? this.refs.meshId.value.trim() : '';
		this.state.meshKey = this.refs.meshKey ? this.refs.meshKey.value : '';
		this.state.meshBand = this.refs.meshBand ? this.refs.meshBand.value : '2g';
		this.state.isVlan = this.refs.isVlan.checked;
		this.state.vlanId = this.refs.vlanId.value.trim();
		this.state.channel2g = this.refs.channel2g ? this.refs.channel2g.value : 'auto';
		this.state.channel5g = this.refs.channel5g ? this.refs.channel5g.value : 'auto';
		this.state.wifiMode2g = this.refs.wifiMode2g ? this.refs.wifiMode2g.value : (this.state.wifiMode2g || 'ax');
		this.state.wifiWidth2g = this.refs.wifiWidth2g ? this.refs.wifiWidth2g.value : (this.state.wifiWidth2g || '20');
		this.state.wifiMode5g = this.refs.wifiMode5g ? this.refs.wifiMode5g.value : (this.state.wifiMode5g || 'ax');
		this.state.wifiWidth5g = this.refs.wifiWidth5g ? this.refs.wifiWidth5g.value : (this.state.wifiWidth5g || '80');
		this.state.resetDisabled = this.refs.resetDisabled.checked;
		this.state.resetHoldSeconds = this.refs.resetHoldSeconds.value;
		this.state.wpsDisabled = this.refs.wpsDisabled.checked;
		this.state.rebootEnabled = this.refs.rebootEnabled ? this.refs.rebootEnabled.checked : false;
		this.state.rebootHours = this.refs.rebootHours ? this.refs.rebootHours.value.trim() : '24';
		this.state.adminPassword = this.refs.adminPassword ? this.refs.adminPassword.value : '';
		this.state.adminPasswordConfirm = this.refs.adminPasswordConfirm ? this.refs.adminPasswordConfirm.value : '';
	},

	describeModePlan: function() {
		var radio2g = getRadioByBand(this.radios || [], '2g');
		var remainingBands = getRemainingLocalBands(this.radios || [], this.state);
		var onlyBand = remainingBands[0];
		var uplinkBand = getRadioByBand(this.radios || [], this.state.uplinkBand) ? this.state.uplinkBand : (radio2g ? '2g' : '5g');
		var meshBand = getRadioByBand(this.radios || [], this.state.meshBand) ? this.state.meshBand : (radio2g ? '2g' : '5g');

		if (this.state.mode == 'ap_wds') {
			if (!remainingBands.length)
				return _('لا يوجد حاليًا راديو محلي متاح لاستضافة وضع نقطة الوصول + WDS.');

			if (remainingBands.length == 1)
				return _('سيبقى وضع نقطة الوصول + WDS نشطًا على نقطة الوصول المحلية على ') + bandLabel(onlyBand) + _('، وسيُفعَّل WDS على هذه الواجهة.');

			return _('سيبقى وضع نقطة الوصول + WDS نشطًا على راديوي نقطة الوصول المحليين، وسيُفعَّل WDS على الواجهتين.');
		}

		if (this.state.mode == 'sta_wds') {
			if (!remainingBands.length)
				return _('سيستخدم وضع عميل + WDS ') + bandLabel(uplinkBand) + _(' للربط الصاعد. لن تبقى أي نقطة وصول محلية نشطة على الواي فاي، لكن يبقى الوصول عبر LAN متاحًا.');

			if (remainingBands.length == 1)
				return _('سيستخدم وضع عميل + WDS ') + bandLabel(uplinkBand) + _(' للربط الصاعد، بينما تبقى نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' متاحة.');

			return _('سيستخدم وضع عميل + WDS ') + bandLabel(uplinkBand) + _(' للربط الصاعد، بينما تبقى الراديوهات المحلية الأخرى متاحة.');
		}

		if (this.state.mode == 'mesh') {
			if (!remainingBands.length)
				return _('سيستخدم وضع الميش ') + bandLabel(meshBand) + _(' كراديو backhaul. لن تبقى أي نقطة وصول محلية نشطة على الواي فاي، لكن يبقى الوصول عبر LAN متاحًا.');

			if (remainingBands.length == 1)
				return _('سيستخدم وضع الميش ') + bandLabel(meshBand) + _(' كراديو backhaul، بينما تبقى نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' متاحة.');

			return _('سيستخدم وضع الميش ') + bandLabel(meshBand) + _(' كراديو backhaul، بينما تبقى الراديوهات المحلية الأخرى متاحة.');
		}

		if (!remainingBands.length)
			return _('لا يوجد حاليًا راديو محلي متاح لوضع نقطة الوصول.');

		if (remainingBands.length == 1)
			return _('سيبقى وضع نقطة الوصول نشطًا على نقطة الوصول المحلية على ') + bandLabel(onlyBand) + _('.');

		return _('سيبقى وضع نقطة الوصول نشطًا على راديوي نقطة الوصول المحليين.');
	},

	describeSecondaryNetworkPlan: function() {
		var vlanId = this.state.vlanId || '10';
		var vlanBinding = describeSecondaryVlanBinding(vlanId);
		
			var secondary2g = previewSecondarySsid(this.state, '2g');
			var secondary5g = previewSecondarySsid(this.state, '5g');
		var remainingBands = getRemainingLocalBands(this.radios || [], this.state);
		var remainingCount = remainingBands.length;
		var onlyBand = remainingCount ? remainingBands[0] : null;
		var isolateSummary = _(' تبقى واجهات نقاط الوصول المحلية الثانوية على wizardvlan مرئية ومعزولة عن بعضها وبدون WDS.');

		if (!this.state.isVlan)
			return _('معطل. تبقى الشبكة الرئيسية LAN ووضع التشغيل المحدد على الشبكة الرئيسية فقط.');

		if (!remainingCount)
			return _('مفعّل، لكن لن يبقى أي راديو متاحًا لنقطة وصول محلية في الوضع المحدد. ستبقى الشبكة الرئيسية LAN وأي WDS أو uplink أو Mesh backhaul على LAN، وسيتم تجهيز ') + vlanBinding + _(' بدون شبكة واي فاي ثانوية.');

		if (remainingCount == 1)
			return _('مفعّل. تبقى الشبكة الرئيسية LAN وأي WDS أو uplink أو Mesh backhaul على LAN. فقط نقطة الوصول المحلية المتبقية على ') + bandLabel(onlyBand) + _(' ستستضيف SSID الثانوي ') + previewSecondarySsid(this.state, onlyBand) + _(' المرتبط بـ ') + vlanBinding + _('.') + isolateSummary;

		return _('مفعّل. تبقى الشبكة الرئيسية LAN وأي WDS أو uplink أو Mesh backhaul على LAN. سيتم ربط شبكات SSID المحلية الإضافية ') + secondary2g + _(' و ') + secondary5g + _(' بـ ') + vlanBinding + _(' على الراديوهات التي تبقى متاحة لخدمة نقطة الوصول المحلية.') + isolateSummary;
	},

	syncRadioModeWidthUi: function() {
		if (this.refs.wifiMode2g && this.refs.wifiWidth2g) {
			this.state.wifiMode2g = normalizeWifiModeForBand('2g', this.state.wifiMode2g);
			populateSelectOptions(this.refs.wifiMode2g, wifiModeChoices('2g'), this.state.wifiMode2g);
			this.state.wifiWidth2g = normalizeWifiWidthForBand('2g', this.state.wifiMode2g, this.state.wifiWidth2g);
			populateSelectOptions(this.refs.wifiWidth2g, wifiWidthChoices('2g', this.state.wifiMode2g), this.state.wifiWidth2g);
		}

		if (this.refs.wifiMode5g && this.refs.wifiWidth5g) {
			this.state.wifiMode5g = normalizeWifiModeForBand('5g', this.state.wifiMode5g);
			populateSelectOptions(this.refs.wifiMode5g, wifiModeChoices('5g'), this.state.wifiMode5g);
			this.state.wifiWidth5g = normalizeWifiWidthForBand('5g', this.state.wifiMode5g, this.state.wifiWidth5g);
			populateSelectOptions(this.refs.wifiWidth5g, wifiWidthChoices('5g', this.state.wifiMode5g), this.state.wifiWidth5g);
		}
	},

	updateStepUi: function() {
		var i;
		var lastStep = this.stepPanels.length - 1;
		var vlanBinding;
		var meshBandIs5g;
		var meshChannel;

		this.collectState();
		this.syncRadioModeWidthUi();
		vlanBinding = describeSecondaryVlanBinding(this.state.vlanId);
		meshBandIs5g = (this.state.meshBand == '5g');
		meshChannel = meshBandIs5g ? this.state.channel5g : this.state.channel2g;

		for (i = 0; i < this.stepPanels.length; i++) {
			this.stepPanels[i].style.display = (i == this.stepIndex) ? '' : 'none';
			this.stepBadges[i].style.background = (i == this.stepIndex) ? '#0b5ed7' : '#d0d7de';
			this.stepBadges[i].style.color = (i == this.stepIndex) ? '#fff' : '#222';
		}

		this.refs.backButton.disabled = (this.stepIndex === 0);
		this.refs.nextButton.style.display = (this.stepIndex === lastStep) ? 'none' : '';
		this.refs.saveButton.style.display = (this.stepIndex === lastStep) ? '' : 'none';
		this.refs.uplinkSettingsWrapper.style.display = (this.state.mode == 'sta_wds') ? '' : 'none';
		this.refs.meshSettingsWrapper.style.display = (this.state.mode == 'mesh') ? '' : 'none';
		this.refs.vlanIdWrapper.style.display = this.refs.isVlan.checked ? '' : 'none';
		if (this.refs.vlanSsidRow)
			this.refs.vlanSsidRow.style.display = this.refs.isVlan.checked ? '' : 'none';
		this.refs.vlanPreviewWrapper.style.display = this.refs.isVlan.checked ? '' : 'none';
		this.refs.resetHoldWrapper.style.display = this.refs.resetDisabled.checked ? 'none' : '';
		this.refs.rebootHoursWrapper.style.display = this.refs.rebootEnabled.checked ? '' : 'none';
		var hasLocal5g = (getRemainingLocalBands(this.radios || [], this.state).indexOf('5g') != -1);
		if (this.refs.ssid5gModeRow)
			this.refs.ssid5gModeRow.style.display = hasLocal5g ? '' : 'none';
		if (this.refs.ssid5gCustomRow)
			this.refs.ssid5gCustomRow.style.display = (hasLocal5g && this.state.wifiSsid5gMode == 'custom') ? '' : 'none';
		if (this.refs.ssidPreviewRow)
			this.refs.ssidPreviewRow.style.display = hasLocal5g ? '' : 'none';
		this.refs.ssidPreview.textContent = primarySsid(this.state, '5g');
		if (this.refs.wifiNameHelp)
			this.refs.wifiNameHelp.textContent = describePrimaryWifiNamingHelp(this.state, this.radios || []);
		this.refs.vlanPreview.textContent = vlanBinding;
		if (this.refs.secondaryNetworkIntro)
			this.refs.secondaryNetworkIntro.textContent = describeSecondaryNetworkIntro(this.state, this.radios || []);
		if (this.refs.secondarySubnetHelp)
			this.refs.secondarySubnetHelp.textContent = describeSecondarySubnetHelp(this.state, this.radios || []);
		if (this.refs.uplinkHelp)
			this.refs.uplinkHelp.textContent = describeUplinkSettingsHelp(this.state, this.radios || []);
		if (this.refs.meshHelp)
			this.refs.meshHelp.textContent = describeMeshSettingsHelp(this.state, this.radios || []);

		if (this.refs.channel2gRow) {
			this.refs.channel2gRow.style.border = (this.state.mode == 'mesh' && !meshBandIs5g) ? '1px solid #0b5ed7' : '1px solid transparent';
			this.refs.channel2gRow.style.background = (this.state.mode == 'mesh' && !meshBandIs5g) ? '#eef4ff' : 'transparent';
			this.refs.channel2gRow.style.borderRadius = '8px';
			this.refs.channel2gRow.style.padding = '8px 10px';
		}

		if (this.refs.channel5gRow) {
			this.refs.channel5gRow.style.border = (this.state.mode == 'mesh' && meshBandIs5g) ? '1px solid #0b5ed7' : '1px solid transparent';
			this.refs.channel5gRow.style.background = (this.state.mode == 'mesh' && meshBandIs5g) ? '#eef4ff' : 'transparent';
			this.refs.channel5gRow.style.borderRadius = '8px';
			this.refs.channel5gRow.style.padding = '8px 10px';
		}

		if (this.refs.meshChannelHelp) {
			if (this.state.mode == 'mesh') {
				this.refs.meshChannelHelp.style.display = '';
				this.refs.meshChannelHelp.textContent = describeMeshChannelHelp(this.state, this.radios || []);
			}
			else {
				this.refs.meshChannelHelp.style.display = 'none';
				this.refs.meshChannelHelp.textContent = '';
			}
		}

		if (this.refs.modePlan)
			this.refs.modePlan.textContent = this.describeModePlan();

		if (this.refs.primaryWifiPlan)
			this.refs.primaryWifiPlan.textContent = describePrimaryWifiPlan(this.state, this.radios || []);

		if (this.refs.secondaryNetworkPlan)
			this.refs.secondaryNetworkPlan.textContent = this.describeSecondaryNetworkPlan();

		if (this.refs.secondaryNetworkNotice) {
			this.refs.secondaryNetworkNotice.textContent = describeSecondaryNetworkNotice(this.state, this.radios || []);
			this.refs.secondaryNetworkNotice.style.display = this.state.isVlan ? '' : 'none';
		}
	},

	validateStep: function(index) {
		this.collectState();

		if (STEP_KEYS[index] == 'lan') {
			if (!isIPv4(this.state.lanIpaddr)) {
				notify(_('أدخل عنوان LAN IPv4 صالحًا.'));
				return false;
			}

			if (!isIPv4(this.state.lanNetmask)) {
				notify(_('أدخل قناع شبكة LAN صالحًا.'));
				return false;
			}
		}

		if (STEP_KEYS[index] == 'mode') {
			if (normalizeMode(this.state.mode) != this.state.mode) {
				notify(_('اختر وضع تشغيل صالحًا.'));
				return false;
			}
		}

		if (STEP_KEYS[index] == 'wifi') {
			var uplinkRadio = getRadioByBand(this.radios || [], this.state.uplinkBand);
			var meshRadio = getRadioByBand(this.radios || [], this.state.meshBand);
			var hasLocal5g = (getRemainingLocalBands(this.radios || [], this.state).indexOf('5g') != -1);

			if (!this.state.wifiSsid) {
				notify(_('أدخل اسم الشبكة اللاسلكية الأساسي.'));
				return false;
			}

			if (hasLocal5g && this.state.wifiSsid5gMode == 'custom' && !this.state.wifiSsid5g) {
				notify(_('أدخل اسما مخصصا لشبكة 5GHz أو اختر التسمية التلقائية.'));
				return false;
			}

			if (this.state.wifiKey && this.state.wifiKey.length < 8) {
				notify(_('يجب أن تتكون كلمة مرور الواي فاي من 8 أحرف على الأقل، أو اتركها فارغة إذا كنت تريد شبكة مفتوحة.'));
				return false;
			}

			if (this.state.mode == 'sta_wds') {
				if (!this.state.uplinkSsid) {
					notify(_('أدخل اسم شبكة الربط الصاعد لوضع Client + WDS.'));
					return false;
				}

				if (this.state.uplinkBand != '2g' && this.state.uplinkBand != '5g') {
					notify(_('اختر نطاق راديو الربط الصاعد.'));
					return false;
				}

				if (!uplinkRadio) {
					notify(_('نطاق الربط الصاعد المحدد غير متوفر على هذا الجهاز.'));
					return false;
				}

				if (this.state.uplinkKey && this.state.uplinkKey.length < 8) {
					notify(_('يجب أن تتكون كلمة مرور الربط الصاعد من 8 أحرف على الأقل، أو اتركها فارغة إذا كانت الشبكة مفتوحة.'));
					return false;
				}
			}

			if (this.state.mode == 'mesh') {
				if (!this.state.meshId) {
					notify(_('أدخل معرف Mesh.'));
					return false;
				}

				if (this.state.meshBand != '2g' && this.state.meshBand != '5g') {
					notify(_('اختر نطاق راديو Mesh.'));
					return false;
				}

				if (!meshRadio) {
					notify(_('نطاق Mesh المحدد غير متوفر على هذا الجهاز.'));
					return false;
				}

				if (this.state.meshKey && this.state.meshKey.length < 8) {
					notify(_('يجب أن تتكون كلمة مرور Mesh من 8 أحرف على الأقل، أو اتركها فارغة إذا كنت تريد شبكة Mesh مفتوحة.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'vlan' && this.state.isVlan) {
			var vlanId = +this.state.vlanId;
			var manualSecondaryBase = previewSecondaryBaseSsid(this.state);
			var activeBands = getRemainingLocalBands(this.radios || [], this.state);
			var manualSecondary2g = previewSecondarySsid(this.state, '2g');
			var manualSecondary5g = previewSecondarySsid(this.state, '5g');
			var primary2g = primarySsid(this.state, '2g');
			var primary5g = primarySsid(this.state, '5g');

			if (!(vlanId >= 1 && vlanId <= 4094)) {
				notify(_('اختر قيمة VLAN ID بين 1 و4094.'));
				return false;
			}

			if (manualSecondaryBase) {
				if (manualSecondary2g == primary2g || manualSecondary2g == primary5g) {
					notify(_('اسم الشبكة يتعارض مع اسم شبكة أساسية موجودة. اختر اسمًا مختلفًا.'));
					return false;
				}

				if (activeBands.indexOf('5g') != -1 && (manualSecondary5g == primary2g || manualSecondary5g == primary5g)) {
					notify(_('اسم الشبكة على 5GHz سيتعارض مع اسم شبكة أساسية موجودة. اختر اسمًا مختلفًا.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'channel') {
			if (this.refs.wifiMode2g)
				this.state.wifiMode2g = normalizeWifiModeForBand('2g', this.state.wifiMode2g);

			if (this.refs.wifiMode5g)
				this.state.wifiMode5g = normalizeWifiModeForBand('5g', this.state.wifiMode5g);

			if (this.refs.wifiWidth2g)
				this.state.wifiWidth2g = normalizeWifiWidthForBand('2g', this.state.wifiMode2g, this.state.wifiWidth2g);

			if (this.refs.wifiWidth5g)
				this.state.wifiWidth5g = normalizeWifiWidthForBand('5g', this.state.wifiMode5g, this.state.wifiWidth5g);

			if (this.state.mode == 'mesh') {
				var meshChannel = (this.state.meshBand == '5g') ? this.state.channel5g : this.state.channel2g;

				if (!meshChannel || meshChannel == 'auto') {
					notify(_('اختر قناة ثابتة للنطاق المحدد للميش.'));
					return false;
				}
			}

			if (this.state.rebootEnabled && !/^[1-9][0-9]*$/.test(this.state.rebootHours)) {
				notify(_('أدخل مدة إعادة التشغيل الدوري بعدد ساعات صحيح أكبر من صفر.'));
				return false;
			}

			if ((this.state.adminPassword || this.state.adminPasswordConfirm) &&
			    (!this.state.adminPassword || !this.state.adminPasswordConfirm)) {
				notify(_('أدخل كلمة مرور الجهاز الجديدة ثم أكدها.'));
				return false;
			}

			if (this.state.adminPassword != this.state.adminPasswordConfirm) {
				notify(_('تأكيد كلمة مرور الجهاز غير مطابق.'));
				return false;
			}
		}
		return true;
	},

	nextStep: function() {
		if (!this.validateStep(this.stepIndex))
			return;

		if (this.stepIndex < this.stepPanels.length - 1) {
			this.stepIndex++;
			this.updateStepUi();
		}
	},

	prevStep: function() {
		this.collectState();

		if (this.stepIndex > 0) {
			this.stepIndex--;
			this.updateStepUi();
		}
	},

	applyWifiSettings: function(state, radios) {
		var radio2g = getRadioByBand(radios, '2g');
		var radio5g = getRadioByBand(radios, '5g');
		var requestedMode = normalizeMode(state.mode);
		var vlanOnlyAp = ((requestedMode == 'ap' || requestedMode == 'mesh') && state.isVlan);
		var lanPolicy = getLocalApPolicy(state, 'lan');
		var vlanPolicy = getLocalApPolicy(state, 'wizardvlan');
		var uplinkRadio = null;
		var uplinkApIface = null;
		var uplinkStaIface = null;
		var meshRadio = null;
		var meshApIface = null;
		var meshIface = null;
		var secondaryIface2g = radio2g ? secondaryApSectionName(radio2g['.name']) : null;
		var secondaryIface5g = radio5g ? secondaryApSectionName(radio5g['.name']) : null;
		var iface;
		var localRadios;

		applyRadioHtmode(radio2g, '2g', state);
		applyRadioHtmode(radio5g, '5g', state);

		if (requestedMode == 'sta_wds') {
			uplinkRadio = getRadioByBand(radios, state.uplinkBand);

			if (uplinkRadio == null)
				uplinkRadio = radio2g || radio5g;

			uplinkStaIface = ensureNamedWifiIface('wizard_uplink');
			uci.set('wireless', uplinkStaIface, 'device', wifiDeviceName(uplinkRadio));
			uci.set('wireless', uplinkStaIface, 'mode', 'sta');
			uci.set('wireless', uplinkStaIface, 'network', 'lan');
			uci.set('wireless', uplinkStaIface, 'disabled', '0');
			uci.set('wireless', uplinkStaIface, 'ssid', state.uplinkSsid);
			uci.set('wireless', uplinkStaIface, 'wds', '1');
			uci.unset('wireless', uplinkStaIface, 'mesh_id');
			setWifiSecurity('wireless', uplinkStaIface, state.uplinkKey);

			uplinkApIface = uplinkRadio ? findWifiIface(uplinkRadio['.name']) : null;

			if (uplinkApIface && uplinkApIface != uplinkStaIface) {
				uci.set('wireless', uplinkApIface, 'disassoc_low_ack', '0');
				uci.set('wireless', uplinkApIface, 'disabled', '1');
			}

			if (uplinkRadio)
				uci.set('wireless', uplinkRadio['.name'], 'channel', 'auto');
		}
		else {
			uci.remove('wireless', 'wizard_uplink');
		}

		if (requestedMode == 'mesh') {
			meshRadio = getRadioByBand(radios, state.meshBand);

			if (meshRadio == null)
				meshRadio = radio2g || radio5g;

			meshIface = ensureNamedWifiIface('wizard_mesh');
			uci.set('wireless', meshIface, 'device', wifiDeviceName(meshRadio));
			uci.set('wireless', meshIface, 'mode', 'mesh');
			uci.set('wireless', meshIface, 'network', 'lan');
			uci.set('wireless', meshIface, 'disabled', '0');
			uci.set('wireless', meshIface, 'mesh_id', state.meshId);
			uci.unset('wireless', meshIface, 'ssid');
			uci.unset('wireless', meshIface, 'wds');

			if (state.meshKey) {
				uci.set('wireless', meshIface, 'encryption', 'sae');
				uci.set('wireless', meshIface, 'key', state.meshKey);
			}
			else {
				uci.set('wireless', meshIface, 'encryption', 'none');
				uci.unset('wireless', meshIface, 'key');
			}

			meshApIface = meshRadio ? findWifiIface(meshRadio['.name']) : null;

			if (meshApIface && meshApIface != meshIface) {
				uci.set('wireless', meshApIface, 'disassoc_low_ack', '0');
				uci.set('wireless', meshApIface, 'disabled', '1');
			}

			if (meshRadio) {
				uci.set('wireless', meshRadio['.name'], 'channel', state.meshBand == '5g' ? (state.channel5g || 'auto') : (state.channel2g || 'auto'));
			}
		}
		else {
			uci.remove('wireless', 'wizard_mesh');
		}

		localRadios = radios.filter(function(radio) {
			return (!uplinkRadio || radio['.name'] != uplinkRadio['.name']) && (!meshRadio || radio['.name'] != meshRadio['.name']);
		});

		if (radio2g && (!uplinkRadio || radio2g['.name'] != uplinkRadio['.name']) && (!meshRadio || radio2g['.name'] != meshRadio['.name'])) {
			iface = ensureWifiIface(radio2g['.name']);

			if (vlanOnlyAp)
				uci.remove('wireless', iface);
			else
				configureApIface(iface, radio2g['.name'], 'lan', primarySsid(state, '2g'), state.wifiKey, lanPolicy);

			uci.set('wireless', radio2g['.name'], 'channel', state.channel2g || 'auto');

			if (state.isVlan) {
				ensureNamedWifiIface(secondaryIface2g);
				configureApIface(secondaryIface2g, radio2g['.name'], 'wizardvlan', previewSecondarySsid(state, '2g'), state.wifiKey, vlanPolicy);
			}
			else {
				uci.remove('wireless', secondaryIface2g);
			}
		}
		else if (secondaryIface2g) {
			uci.remove('wireless', secondaryIface2g);
		}

		if (radio5g && (!uplinkRadio || radio5g['.name'] != uplinkRadio['.name']) && (!meshRadio || radio5g['.name'] != meshRadio['.name'])) {
			iface = ensureWifiIface(radio5g['.name']);

			if (vlanOnlyAp)
				uci.remove('wireless', iface);
			else
				configureApIface(iface, radio5g['.name'], 'lan', primarySsid(state, '5g'), state.wifiKey, lanPolicy);

			uci.set('wireless', radio5g['.name'], 'channel', state.channel5g || 'auto');

			if (state.isVlan) {
				ensureNamedWifiIface(secondaryIface5g);
				configureApIface(secondaryIface5g, radio5g['.name'], 'wizardvlan', previewSecondarySsid(state, '5g'), state.wifiKey, vlanPolicy);
			}
			else {
				uci.remove('wireless', secondaryIface5g);
			}
		}
		else if (secondaryIface5g) {
			uci.remove('wireless', secondaryIface5g);
		}

		uci.sections('wireless', 'wifi-iface').forEach(function(section) {
			var sid = section['.name'];
			var sectionNetworks = normalizeList(section.network);
			var isLocalRadio = localRadios.some(function(radio) {
				return section.device == radio['.name'];
			});

			if (!isLocalRadio)
				return;

			if (section.mode != null && section.mode != 'ap')
				return;

			if (vlanOnlyAp && sectionNetworks.indexOf('lan') > -1) {
				uci.remove('wireless', sid);
				return;
			}

			if (sectionNetworks.indexOf('lan') > -1) {
				if (lanPolicy.enableWds)
					uci.set('wireless', sid, 'wds', '1');
				else
					uci.unset('wireless', sid, 'wds');

				applyWifiIfaceFlag('wireless', sid, 'hidden', lanPolicy.hidden);
				applyWifiIfaceFlag('wireless', sid, 'isolate', lanPolicy.isolate);
			}
			else if (sectionNetworks.indexOf('wizardvlan') > -1) {
				if (vlanPolicy.enableWds)
					uci.set('wireless', sid, 'wds', '1');
				else
					uci.unset('wireless', sid, 'wds');

				applyWifiIfaceFlag('wireless', sid, 'hidden', vlanPolicy.hidden);
				applyWifiIfaceFlag('wireless', sid, 'isolate', vlanPolicy.isolate);
			}
		});

	},

	applyVlanSettings: function(state) {
		var firewallLanZone = findFirewallZone('lan');

		if (state.isVlan) {
			ensureNamedSection('network', 'wizard_vlan_dev', 'device');
			ensureNamedSection('network', 'wizard_vlan_bridge', 'device');
			ensureNamedSection('network', 'wizardvlan', 'interface');
			uci.set('network', 'wizard_vlan_dev', 'type', '8021q');
			uci.set('network', 'wizard_vlan_dev', 'ifname', 'br-lan');
			uci.set('network', 'wizard_vlan_dev', 'vid', state.vlanId);
			uci.set('network', 'wizard_vlan_dev', 'name', 'br-lan.' + state.vlanId);

			uci.set('network', 'wizard_vlan_bridge', 'type', 'bridge');
			uci.set('network', 'wizard_vlan_bridge', 'name', 'vlan_' + state.vlanId);
			uci.set('network', 'wizard_vlan_bridge', 'bridge_empty', '1');
			uci.set('network', 'wizard_vlan_bridge', 'ipv6', '0');
			uci.set('network', 'wizard_vlan_bridge', 'ports', [ 'br-lan.' + state.vlanId ]);

			uci.set('network', 'wizardvlan', 'proto', 'none');
			uci.set('network', 'wizardvlan', 'device', 'vlan_' + state.vlanId);
			uci.unset('network', 'wizardvlan', 'ipaddr');
			uci.unset('network', 'wizardvlan', 'netmask');
			uci.unset('network', 'wizardvlan', 'gateway');
			uci.unset('network', 'wizardvlan', 'ip6addr');
			uci.unset('network', 'wizardvlan', 'ip6gw');
			uci.unset('network', 'wizardvlan', 'ip6assign');
			uci.unset('network', 'wizardvlan', 'ip6hint');
			uci.unset('network', 'wizardvlan', 'ip6class');
			uci.unset('network', 'wizardvlan', 'delegate');
			uci.unset('network', 'wizardvlan', 'dns');
			uci.unset('network', 'wizardvlan', 'defaultroute');

			uci.remove('dhcp', 'wizardvlan');

			if (firewallLanZone)
				removeListValue('firewall', firewallLanZone, 'network', 'wizardvlan');
		}
		else {
			uci.remove('network', 'wizard_vlan_dev');
			uci.remove('network', 'wizard_vlan_bridge');
			uci.remove('network', 'wizardvlan');
			uci.remove('dhcp', 'wizardvlan');

			if (firewallLanZone)
				removeListValue('firewall', firewallLanZone, 'network', 'wizardvlan');
		}
	},

	applyPeriodicRebootSettings: function(state) {
		if (state.rebootEnabled) {
			ensureNamedSection('watchcat', WATCHCAT_SID, 'watchcat');
			uci.set('watchcat', WATCHCAT_SID, 'mode', 'periodic_reboot');
			uci.set('watchcat', WATCHCAT_SID, 'period', formatRebootPeriod(state.rebootHours));
			uci.set('watchcat', WATCHCAT_SID, 'forcedelay', '1m');
			uci.unset('watchcat', WATCHCAT_SID, 'pinghosts');
			uci.unset('watchcat', WATCHCAT_SID, 'pingperiod');
			uci.unset('watchcat', WATCHCAT_SID, 'pingsize');
			uci.unset('watchcat', WATCHCAT_SID, 'interface');
			uci.unset('watchcat', WATCHCAT_SID, 'mmifacename');
			uci.unset('watchcat', WATCHCAT_SID, 'unlockbands');
			uci.unset('watchcat', WATCHCAT_SID, 'addressfamily');
			uci.unset('watchcat', WATCHCAT_SID, 'script');
		}
		else {
			uci.remove('watchcat', WATCHCAT_SID);
		}
	},

	saveAndApply: function() {
		var self = this;
		var oldLanIpaddr = uci.get('network', 'lan', 'ipaddr') || this.state.lanIpaddr;
		var oldSsid = this.state.wifiSsid;

		if (!this.validateStep(this.stepIndex))
			return;

		this.collectState();

		ensureNamedSection('setup', 'default', 'setup');

		uci.set('setup', 'default', 'lan_ipaddr', this.state.lanIpaddr);
		uci.set('setup', 'default', 'lan_netmask', this.state.lanNetmask);
		uci.set('setup', 'default', 'initial_setup_complete', '1');
		uci.set('setup', 'default', 'mode', this.state.mode);
		uci.set('setup', 'default', 'wifi_ssid', this.state.wifiSsid);
		uci.set('setup', 'default', 'wifi_ssid_5g_mode', this.state.wifiSsid5gMode || 'derived');
		uci.set('setup', 'default', 'wifi_ssid_5g', this.state.wifiSsid5g || '');
		uci.set('setup', 'default', 'wifi_ssid_vlan', this.state.wifiSsidVlan || '');
		uci.set('setup', 'default', 'wifi_key', this.state.wifiKey);
		uci.set('setup', 'default', 'uplink_ssid', this.state.uplinkSsid);
		uci.set('setup', 'default', 'uplink_key', this.state.uplinkKey);
		uci.set('setup', 'default', 'uplink_band', this.state.uplinkBand);
		uci.set('setup', 'default', 'mesh_id', this.state.meshId);
		uci.set('setup', 'default', 'mesh_key', this.state.meshKey);
		uci.set('setup', 'default', 'mesh_band', this.state.meshBand);
		uci.set('setup', 'default', 'is_vlan', this.state.isVlan ? '1' : '0');
		uci.set('setup', 'default', 'vlan_id', this.state.vlanId || '10');
		uci.set('setup', 'default', 'channel_2g', this.state.channel2g || 'auto');
		uci.set('setup', 'default', 'channel_5g', this.state.channel5g || 'auto');
		uci.set('setup', 'default', 'wifi_mode_2g', normalizeWifiModeForBand('2g', this.state.wifiMode2g));
		uci.set('setup', 'default', 'wifi_width_2g', normalizeWifiWidthForBand('2g', this.state.wifiMode2g, this.state.wifiWidth2g));
		uci.set('setup', 'default', 'wifi_mode_5g', normalizeWifiModeForBand('5g', this.state.wifiMode5g));
		uci.set('setup', 'default', 'wifi_width_5g', normalizeWifiWidthForBand('5g', this.state.wifiMode5g, this.state.wifiWidth5g));
		uci.set('setup', 'default', 'reset_button_disabled', this.state.resetDisabled ? '1' : '0');
		uci.set('setup', 'default', 'reset_hold_seconds', this.state.resetHoldSeconds || '5');
		uci.set('setup', 'default', 'wps_button_disabled', this.state.wpsDisabled ? '1' : '0');

		uci.set('network', 'lan', 'proto', 'static');
		uci.set('network', 'lan', 'ipaddr', this.state.lanIpaddr);
		uci.set('network', 'lan', 'netmask', this.state.lanNetmask);
		disableFirstbootProvisioning();
		this.applyVlanSettings(this.state);
		this.applyWifiSettings(this.state, this.radios);
		this.applyPeriodicRebootSettings(this.state);

		this.refs.saveButton.disabled = true;
		this.refs.saveButton.textContent = _('جارٍ التطبيق...');

		uci.save().then(function() {
			return ui.changes.apply();
		}).then(function() {
			var changedIp = self.state.lanIpaddr != oldLanIpaddr;

			if (!self.state.adminPassword) {
				return {
					changedIp: changedIp,
					passwordChanged: null
				};
			}

			return L.resolveDefault(callSetPassword('root', self.state.adminPassword), false).then(function(success) {
				return {
					changedIp: changedIp,
					passwordChanged: !!success
				};
			});
		}).then(function(result) {
			var modeMessage = describeAppliedModeResult(self.state, self.radios || []);
			var secondaryNetworkMessage = describeAppliedSecondaryNetworkResult(self.state, self.radios || []);
			var reconnectMessage = describeReconnectHint(self.state, self.radios || [], oldSsid);

			self.refs.saveButton.disabled = false;
			self.refs.saveButton.textContent = _('حفظ وتطبيق');
			self.refs.adminPassword.value = '';
			self.refs.adminPasswordConfirm.value = '';
			self.state.adminPassword = '';
			self.state.adminPasswordConfirm = '';

			if (result.passwordChanged === true)
				notify(_('تم تغيير كلمة مرور الجهاز بنجاح.'));
			else if (result.passwordChanged === false)
				notify(_('تم تطبيق الإعدادات، لكن تعذر تغيير كلمة مرور الجهاز.'));

			if (modeMessage)
				notify(modeMessage);

			if (secondaryNetworkMessage)
				notify(secondaryNetworkMessage);

			if (result.changedIp) {
				notify(_('تم تطبيق الإعدادات. تغيّر عنوان LAN إلى ') + self.state.lanIpaddr + _('، وستُعاد فتح الصفحة على العنوان الجديد خلال بضع ثوانٍ.'));
				scheduleWizardRedirect(self.state.lanIpaddr, 8000);
			}
			else {
				notify(_('تم تطبيق الإعدادات بنجاح. سيتم تحديث الصفحة تلقائيًا لتحميل أحدث نسخة من المعالج.'));
				scheduleWizardRedirect(self.state.lanIpaddr, 2500);
			}

			if (reconnectMessage)
				notify(reconnectMessage);
		}).catch(function(err) {
			self.refs.saveButton.disabled = false;
			self.refs.saveButton.textContent = _('حفظ وتطبيق');
			notify(_('تعذر تطبيق إعدادات المعالج.') + ' ' + (err || ''));
		});
	},

	render: function(data) {
		var self = this;
		var statusContainer = E('div');
		var wizardContainer = E('div', { 'class': 'cbi-section' });
		var radios = uci.sections('wireless', 'wifi-device');
		var frequencyMap = Array.isArray(data) ? (data[data.length - 1] || {}) : {};
		var radio2g = getRadioByBand(radios, '2g');
		var radio5g = getRadioByBand(radios, '5g');
		var stepNav = E('div', { 'style': 'display:flex; gap:10px; flex-wrap:wrap; margin:0 0 16px 0;' });
		var stepsWrap = E('div', { 'class': 'cbi-section-node' });
		var actions = E('div', { 'style': 'display:flex; gap:10px; justify-content:flex-end; margin-top:18px;' });
		var panel = E('div');
		var wizardIntro;
		var stepTitles = [ _('الخطوة 1: الشبكة المحلية'), _('الخطوة 2: وضع التشغيل'), _('الخطوة 3: الواي فاي'), _('الخطوة 4: اعداد الشبكة VLAN'), _('الخطوة 5: الاعدادات المتقدمه') ];
		var stepPanels = [];
		var stepBadges = [];
		var i;

		this.radios = radios;
		this.frequencyMap = frequencyMap;
		this.state = this.readState(radios);
		this.stepIndex = 0;
		this.refs = {};
		this.stepPanels = stepPanels;
		this.stepBadges = stepBadges;

		panel.appendChild(statusContainer);

		wizardIntro = E('div', { 'class': 'cbi-section-node', 'style': 'margin-bottom:14px;' }, [
			E('h3', { 'style': 'margin-bottom:8px;' }, _('برمجة سريعه')),
			E('p', { 'style': 'margin:0; color:#52606d;' }, _('واجهة مختصرة ومنظمة لإعداد الشبكة المحلية، ووضع التشغيل، والواي فاي، وشبكة VLAN الثانوية، ثم الاعدادات المتقدمه بخطوات واضحة.')),
			E('div', { 'style': 'display:flex; gap:12px; flex-wrap:wrap; align-items:center; margin-top:14px;' }, [
				E('a', {
					'href': VIDEO_EXPLAIN_URL,
					'target': '_blank',
					'rel': 'noopener noreferrer',
					'style': 'display:inline-flex; align-items:center; justify-content:center; padding:9px 16px; border-radius:10px; background:linear-gradient(180deg, #0f766e 0%, #0d9488 100%); color:#fff; text-decoration:none; font-weight:600; box-shadow:0 1px 2px rgba(15,118,110,0.25);'
				}, _('صفحة الشرح')),
				E('span', { 'style': 'color:#52606d;' }, _('سيتم تنزيل الشرح في الصفحة قريبًا.'))
			])
		]);

		wizardContainer.appendChild(wizardIntro);

		for (i = 0; i < stepTitles.length; i++) {
			var badge = E('div', {
				'style': 'display:flex; align-items:center; gap:8px; padding:8px 12px; border:1px solid #d0d7de; border-radius:999px; background:#fff;'
			}, [
				E('span', {
					'style': 'display:inline-flex; align-items:center; justify-content:center; width:24px; height:24px; border-radius:50%; font-weight:bold; background:#d0d7de; color:#222;'
				}, String(i + 1)),
				E('span', stepTitles[i])
			]);

			stepBadges.push(badge.firstChild);
			stepNav.appendChild(badge);
		}

		wizardContainer.appendChild(stepNav);

		this.refs.lanIpaddr = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.lanIpaddr, 'style': 'max-width:280px;' });
		this.refs.lanNetmask = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.lanNetmask, 'style': 'max-width:280px;' });
		this.refs.mode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:280px;' }, [
			E('option', { 'value': 'ap' }, _('نقطة وصول')),
			E('option', { 'value': 'ap_wds' }, _('نقطة وصول + WDS')),
			E('option', { 'value': 'sta_wds' }, _('عميل + WDS')),
			E('option', { 'value': 'mesh' }, _('ميش'))
		]);
		this.refs.mode.value = this.state.mode;
		this.refs.wifiSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.wifiSsid, 'style': 'max-width:280px;' });
		this.refs.wifiSsid5gMode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, [
			E('option', { 'value': 'derived' }, _('تلقائي من الاسم الأساسي')),
			E('option', { 'value': 'custom' }, _('اسم مخصص'))
		]);
		this.refs.wifiSsid5gMode.value = this.state.wifiSsid5gMode || 'derived';
		this.refs.wifiSsid5g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.wifiSsid5g, 'style': 'max-width:280px;' });
		this.refs.wifiSsidVlan = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.wifiSsidVlan, 'style': 'max-width:280px;' });
		this.refs.wifiKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.wifiKey, 'style': 'max-width:280px;' });
		this.refs.uplinkSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.uplinkSsid, 'style': 'max-width:280px;' });
		this.refs.uplinkKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.uplinkKey, 'style': 'max-width:280px;' });
		this.refs.meshId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.meshId, 'style': 'max-width:280px;' });
		this.refs.meshKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.meshKey, 'style': 'max-width:280px;' });
		this.refs.uplinkBand = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			radio2g ? E('option', { 'value': '2g' }, _('راديو 2.4GHz')) : null,
			radio5g ? E('option', { 'value': '5g' }, _('راديو 5GHz')) : null
		]);
		this.refs.meshBand = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			radio2g ? E('option', { 'value': '2g' }, _('راديو 2.4GHz')) : null,
			radio5g ? E('option', { 'value': '5g' }, _('راديو 5GHz')) : null
		]);

		if ((this.state.uplinkBand == '5g' && !radio5g) || (this.state.uplinkBand == '2g' && !radio2g))
			this.state.uplinkBand = radio2g ? '2g' : '5g';

		if ((this.state.meshBand == '5g' && !radio5g) || (this.state.meshBand == '2g' && !radio2g))
			this.state.meshBand = radio2g ? '2g' : '5g';

		this.refs.uplinkBand.value = this.state.uplinkBand;
		this.refs.meshBand.value = this.state.meshBand;
		this.refs.ssidPreview = E('strong', primarySsid(this.state, '5g'));
		this.refs.primaryWifiPlan = E('span');
		this.refs.isVlan = E('input', { 'type': 'checkbox' });
		this.refs.isVlan.checked = this.state.isVlan;
		this.refs.vlanId = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '4094', 'value': this.state.vlanId, 'style': 'max-width:140px;' });
		this.refs.vlanPreview = E('strong', describeSecondaryVlanBinding(this.state.vlanId));
		this.refs.secondaryNetworkPlan = E('span');
		this.refs.secondaryNetworkNotice = E('div', {
			'style': 'display:none; margin-top:12px; padding:10px 12px; border:1px solid #8fb3ff; border-radius:8px; background:#eef4ff; color:#1f3b6d;'
		}, describeSecondaryNetworkNotice(this.state, this.radios || []));
		this.refs.channel2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.channel5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.wifiMode2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.wifiWidth2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.wifiMode5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.wifiWidth5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		this.refs.resetDisabled = E('input', { 'type': 'checkbox' });
		this.refs.resetDisabled.checked = this.state.resetDisabled;
		this.refs.resetHoldSeconds = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			E('option', { 'value': '5' }, _('5 ثوان')),
			E('option', { 'value': '10' }, _('10 ثوان')),
			E('option', { 'value': '20' }, _('20 ثانية')),
			E('option', { 'value': '30' }, _('30 ثانية')),
			E('option', { 'value': '40' }, _('40 ثانية')),
			E('option', { 'value': '60' }, _('60 ثانية'))
		]);
		this.refs.resetHoldSeconds.value = this.state.resetHoldSeconds;
		this.refs.wpsDisabled = E('input', { 'type': 'checkbox' });
		this.refs.wpsDisabled.checked = this.state.wpsDisabled;
		this.refs.rebootEnabled = E('input', { 'type': 'checkbox' });
		this.refs.rebootEnabled.checked = this.state.rebootEnabled;
		this.refs.rebootHours = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'step': '1', 'value': this.state.rebootHours, 'style': 'max-width:140px;' });
		this.refs.adminPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });
		this.refs.adminPasswordConfirm = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });

		if (this.refs.channel2g) {
			populateSelectOptions(
				this.refs.channel2g,
				channelChoices('2g', radio2g ? frequencyMap[radio2g['.name']] : null),
				this.state.channel2g
			);
		}

		if (this.refs.channel5g) {
			populateSelectOptions(
				this.refs.channel5g,
				channelChoices('5g', radio5g ? frequencyMap[radio5g['.name']] : null),
				this.state.channel5g
			);
		}

		this.syncRadioModeWidthUi();

		stepPanels.push(E('div', { 'class': 'cbi-section-node' }, [
			E('h4', _('تحديد عنوان الشبكة المحلية')),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عنوان LAN IPv4')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.lanIpaddr ]) ]),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('قناع الشبكة LAN')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.lanNetmask ]) ])
		]));

		stepPanels.push(E('div', { 'class': 'cbi-section-node', 'style': 'display:none;' }, [
			E('h4', _('اختر وضع التشغيل')),
			E('p', _('يمكن تطبيق جميع أوضاع التشغيل التالية مباشرة من هذا المعالج.')),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('وضع التشغيل')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.mode ]) ]),
			E('div', { 'style': 'margin-top:12px; padding:10px 12px; border:1px solid #d0d7de; border-radius:8px; background:#f6f8fa; color:#333;' }, [
				E('strong', _('معاينة الوضع') + ': '),
				(this.refs.modePlan = E('span'))
			])
		]));

		stepPanels.push(E('div', { 'class': 'cbi-section-node', 'style': 'display:none;' }, [
			E('h4', _('اختر اسم الشبكة اللاسلكية')),
			(this.refs.wifiNameHelp = E('p', describePrimaryWifiNamingHelp(this.state, this.radios || []))),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم SSID الأساسي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid ]) ]),
			(this.refs.ssid5gModeRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('طريقة تعيين اسم 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid5gMode ]) ])),
			(this.refs.ssid5gCustomRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم المخصص لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid5g ]) ])),
			(this.refs.ssidPreviewRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم النهائي لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.ssidPreview ]) ])),
			E('div', { 'style': 'margin-top:12px; padding:10px 12px; border:1px solid #d0d7de; border-radius:8px; background:#f6f8fa; color:#333;' }, [
				E('strong', _('معاينة الواي فاي الأساسي') + ': '),
				this.refs.primaryWifiPlan
			]),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الواي فاي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اترك هذا الحقل فارغا إذا كنت تريد شبكة واي فاي مفتوحة.')) ]) ]),
			(this.refs.uplinkSettingsWrapper = E('div', { 'style': 'display:none;' }, [
				E('h4', { 'style': 'margin-top:18px;' }, _('إعدادات الربط الصاعد للعميل + WDS')),
				(this.refs.uplinkHelp = E('p', describeUplinkSettingsHelp(this.state, this.radios || []))),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkBand ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم شبكة الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkSsid ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اترك هذا الحقل فارغا إذا كانت شبكة الربط الصاعد مفتوحة.')) ]) ])
			])),
			(this.refs.meshSettingsWrapper = E('div', { 'style': 'display:none;' }, [
				E('h4', { 'style': 'margin-top:18px;' }, _('إعدادات الميش')),
				(this.refs.meshHelp = E('p', describeMeshSettingsHelp(this.state, this.radios || []))),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshBand ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('معرف الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshId ]) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اترك هذا الحقل فارغا إذا كنت تريد شبكة ميش مفتوحة.')) ]) ])
			]))
		]));

		this.refs.vlanIdWrapper = E('div', { 'class': 'cbi-value-field' }, [ this.refs.vlanId ]);
		stepPanels.push(E('div', { 'class': 'cbi-section-node', 'style': 'display:none;' }, [
			E('h4', _('اعداد الشبكة VLAN')),
			(this.refs.secondaryNetworkIntro = E('p', describeSecondaryNetworkIntro(this.state, this.radios || []))),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل شبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.isVlan ]) ]),
			E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('VLAN ID')), this.refs.vlanIdWrapper ]),
			(this.refs.vlanSsidRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم الشبكة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsidVlan, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اترك الحقل فارغًا إذا أردت الاستمرار باسم الشبكة الثانوية التلقائي الحالي.')) ]) ])),
			(this.refs.vlanPreviewWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('جسر VLAN الثانوي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.vlanPreview, (this.refs.secondarySubnetHelp = E('div', { 'style': 'margin-top:6px; color:#666;' }, describeSecondarySubnetHelp(this.state, this.radios || []))) ]) ])),
			E('div', { 'style': 'margin-top:12px; padding:10px 12px; border:1px solid #d0d7de; border-radius:8px; background:#f6f8fa; color:#333;' }, [
				E('strong', _('معاينة شبكة VLAN') + ': '),
				this.refs.secondaryNetworkPlan
			]),
			this.refs.secondaryNetworkNotice
		]));

		this.refs.resetHoldWrapper = E('div', { 'class': 'cbi-value-field' }, [ this.refs.resetHoldSeconds ]);
		stepPanels.push(E('div', { 'class': 'cbi-section-node', 'style': 'display:none;' }, [
			E('h4', _('الاعدادات المتقدمه')),
			E('p', _('من هنا تضبط القنوات وعرض النطاق وسياسات الأزرار وخيارات إعادة التشغيل وكلمة مرور الجهاز من صفحة واحدة.')),
			renderWizardCard(
				_('القنوات وإعدادات الراديو'),
				_('اختر القناة والنمط وعرض القناة لكل راديو. وعند استخدام وضع الميش يجب تثبيت قناة النطاق المختار وعدم تركها على تلقائي.'),
				[
					(this.refs.meshChannelHelp = E('p', { 'style': 'display:none; margin:0 0 12px 0; color:#52606d;' })),
					radio2g ? (this.refs.channel2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio2g)), E('div', { 'class': 'cbi-value-field' }, [ this.refs.channel2g ]) ])) : E('p', _('لم يتم اكتشاف راديو 2.4GHz.')),
					radio2g ? (this.refs.mode2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiMode2g ]) ])) : null,
					radio2g ? (this.refs.width2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiWidth2g ]) ])) : null,
					radio5g ? (this.refs.channel5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio5g)), E('div', { 'class': 'cbi-value-field' }, [ this.refs.channel5g ]) ])) : E('p', _('لم يتم اكتشاف راديو 5GHz.')),
					radio5g ? (this.refs.mode5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiMode5g ]) ])) : null,
					radio5g ? (this.refs.width5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiWidth5g ]) ])) : null
				]
			),
			renderWizardCard(
				_('سياسات الأزرار'),
				_('تحكم في استجابة أزرار الجهاز لتقليل التغييرات غير المقصودة أو ضبط سلوكها بما يناسب بيئتك.'),
				[
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر إعادة الضبط')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.resetDisabled ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مدة الضغط لإعادة ضبط المصنع')), this.refs.resetHoldWrapper ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر WPS/ميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wpsDisabled ]) ])
				]
			),
			renderWizardCard(
				_('اعادة تشغيل الجهاز'),
				_('ينشئ هذا القسم قاعدة إعادة تشغيل دورية خاصة بـ ALemprator فقط من دون تعديل أي قواعد Watchcat أخرى موجودة مسبقًا.'),
				[
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل إعادة التشغيل التلقائية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.rebootEnabled ]) ]),
					(this.refs.rebootHoursWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إعادة التشغيل كل كم ساعة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.rebootHours, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يقوم هذا الزر بتوقيت اعادة تشغيل الجهاز مع إنشاء قاعدة دورية خاصة بـ ALemprator فقط، من دون تعديل أي قواعد Watchcat أخرى.')) ]) ]))
				]
			),
			renderWizardCard(
				_('كلمة مرور الجهاز'),
				_('يمكنك ترك الحقلين فارغين إذا كنت تريد الإبقاء على كلمة مرور الجهاز الحالية من دون تغيير.'),
				[
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة المرور الجديدة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.adminPassword ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تأكيد كلمة المرور')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.adminPasswordConfirm ]) ])
				]
			)
		]));

		stepPanels.forEach(function(stepPanel) {
			stepsWrap.appendChild(stepPanel);
		});

		wizardContainer.appendChild(stepsWrap);

		this.refs.backButton = E('button', { 'class': 'cbi-button cbi-button-neutral' }, _('السابق'));
		this.refs.nextButton = E('button', { 'class': 'cbi-button cbi-button-action important' }, _('التالي'));
		this.refs.saveButton = E('button', { 'class': 'cbi-button cbi-button-save important', 'style': 'display:none;' }, _('حفظ وتطبيق'));

		this.refs.backButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.prevStep();
		});

		this.refs.nextButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.nextStep();
		});

		this.refs.saveButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.saveAndApply();
		});

		this.refs.wifiSsid.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.wifiSsid5gMode.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.wifiSsid5g.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.lanIpaddr.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.mode.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.uplinkSsid.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.uplinkKey.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.uplinkBand.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.meshId.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.meshKey.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.meshBand.addEventListener('change', function() {
			self.updateStepUi();
		});

		if (this.refs.channel2g) {
			this.refs.channel2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.channel5g) {
			this.refs.channel5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.wifiMode2g) {
			this.refs.wifiMode2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.wifiWidth2g) {
			this.refs.wifiWidth2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.wifiMode5g) {
			this.refs.wifiMode5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.wifiWidth5g) {
			this.refs.wifiWidth5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		this.refs.isVlan.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.vlanId.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.wifiSsidVlan.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.rebootEnabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.rebootHours.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.adminPassword.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.adminPasswordConfirm.addEventListener('input', function() {
			self.collectState();
		});

		this.refs.resetDisabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		actions.appendChild(this.refs.backButton);
		actions.appendChild(this.refs.nextButton);
		actions.appendChild(this.refs.saveButton);
		wizardContainer.appendChild(actions);
		panel.appendChild(wizardContainer);

		this.updateStepUi();

		return this.renderStatus(statusContainer).then(function() {
			poll.add(function() {
				return self.renderStatus(statusContainer);
			});

			return panel;
		});
	}
});