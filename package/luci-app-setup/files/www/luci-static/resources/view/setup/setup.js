'use strict';
'require view';
'require dom';
'require poll';
'require rpc';
'require fs';
'require uci';
'require ui';


var callNetworkStatus = rpc.declare({
    object: 'network.interface.wan',
    method: 'status'
});

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

var SETUP_STYLE_ID = 'alemprator-setup-styles';
var WATCHCAT_SID = 'alemprator_periodic_reboot';
var STEP_KEYS = [ 'network', 'wireless', 'hotspot_net', 'hotspot_auth', 'maintenance' ];
var WIZARD_BUILD_TAG = 'r47';
var WIZARD_ROUTE = '/cgi-bin/luci/admin/applications/alemprator';
var DEFAULT_ADMIN_ROUTE = '/cgi-bin/luci/admin/status/overview';
var VIDEO_EXPLAIN_URL = 'https://www.facebook.com/people/%D8%AC%D9%84%D8%A7%D9%84-%D8%A7%D8%AD%D9%85%D8%AF-%D8%A7%D9%84%D9%82%D8%AD%D9%85/100010720113363/';
var FIRSTBOOT_DEFAULT_NETWORK = 'alemprator_setup';
var FIRSTBOOT_DEFAULT_WIRELESS = 'alemprator_firstboot';
var SAFE_RESTORE_BACKUP_PATH = '/tmp/backup.tar.gz';
var HOTSPOT_APPLY_CMD = '/usr/libexec/hotspot-openwrt/apply';
var HOTSPOT_INIT_CMD = '/etc/init.d/hotspot-openwrt';
var HOTSPOT_CLEANUP_CMD = '/usr/libexec/alemprator-setup/cleanup-hotspot';
var HOTSPOT_LICENSE_CHECK_CMD = '/usr/libexec/hotspot-openwrt/license-check';
var HOTSPOT_TEST_RADIUS_CMD = '/usr/libexec/hotspot-openwrt/test-radius';
var HOTSPOT_TEST_REST_CMD = '/usr/libexec/hotspot-openwrt/test-rest';
var HOTSPOT_QUICK_IFACE_PRIMARY = 'wizard_hotspot_quick_primary';
var HOTSPOT_QUICK_IFACE_SECONDARY = 'wizard_hotspot_quick_secondary';

function notify(message) {
	ui.addNotification(null, E('p', message));
}

function runApply(cmd, args, successMsg, noReload) {
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

	var isDirect = (cmd.indexOf('exec_direct') === -1); // Simple check or just use one

	return fs.exec_direct(cmd, args || [], 'json').then(function(result) {
		clearInterval(interval);
		progressBar.style.width = '100%';
		progressText.title = '100%';
		
		if (result && result.ok) {
			notify(result.message || successMsg || _('Changes applied successfully.'));
			if (!noReload) {
				setTimeout(function() {
					ui.hideModal();
					window.location.reload();
				}, 1000);
			} else {
				ui.hideModal();
			}
			return result;
		} else {
			ui.hideModal();
			notify((result && result.message) || _('Failed to apply changes.'));
			return result;
		}
	}).catch(function(e) {
		clearInterval(interval);
		ui.hideModal();
		notify(e.message || String(e));
		throw e;
	});
}

function hotspotLicenseCacheInfo() {
	return {
		enabled: false,
		status: 'active',
		expiresAt: 0,
		active: true,
		known: true,
		label: _('مرخص (حماية معطلة)')
	};
}

function hotspotLicenseCacheMessage(info) {
	info = info || hotspotLicenseCacheInfo();

	if (!info.enabled)
		return _('فحص ترخيص الهوتسبوت معطل من الإعدادات.');

	if (!info.known)
		return _('لم تتمكن الواجهة من قراءة حالة الترخيص بعد. سيتم تشغيل فحص حي عند اختيار التفعيل أو عند الحفظ والتطبيق.');

	if (info.active)
		return _('الهوتسبوت مرخص حالياً، وسيتم تشغيل الخدمة بشكل طبيعي عند الحفظ والتطبيق.');

	return _('الهوتسبوت غير مرخص حالياً. يمكن حفظ الإعدادات، لكن الخدمة لن تعمل وسيبقى العملاء بدون بوابة دخول حتى يتم تفعيل الترخيص من لوحة OTA.');
}

function checkHotspotLicenseLive() {
	return Promise.resolve({
		ok: true,
		message: 'Unlocked'
	});
}

function showHotspotLicenseSelectionMessage(contextLabel) {
	return checkHotspotLicenseLive().then(function(result) {
		var message = result.ok
			? _('الهوتسبوت مرخص. اختيار ') + contextLabel + _(' سيشغل الخدمة بشكل طبيعي بعد الحفظ والتطبيق.')
			: _('الهوتسبوت غير مرخص. اختيار ') + contextLabel + _(' سيحفظ الإعدادات فقط، لكن تشغيل الخدمة سيفشل وسيبقى العملاء بدون بوابة دخول حتى يتم تفعيل الترخيص من لوحة OTA.');

		if (result.message)
			message += '\n\n' + _('تفاصيل الفحص: ') + String(result.message).trim();

		window.alert(message);
	});
}

function confirmHotspotLicenseBeforeSetupApply(state) {
	return Promise.resolve(true);
}




function ensureSetupStyles() {
    if (document.getElementById(SETUP_STYLE_ID)) return;

    var style = document.createElement('style');
    style.id = SETUP_STYLE_ID;
    style.textContent = [
        'body.alemprator-setup-body { background: #050505 !important; color: #fff !important; font-family: "Segoe UI", "Cairo", sans-serif !important; }',
        '.alemprator-setup-body #maincontent { background: #050505 !important; min-height: 100vh; padding-top: 10px !important; }',
        '.alemprator-setup-body header { background: #000 !important; border-bottom: 3px solid #D4AF37 !important; padding: 15px 0 !important; display: block !important; box-shadow: 0 5px 20px rgba(212,175,55,0.4) !important; }',
        '.alemprator-setup-body #topmenu { background: #0a0a0a !important; border-bottom: 1px solid rgba(212,175,55,0.2) !important; display: flex !important; visibility: visible !important; }',
        '.alemprator-setup-body #topmenu .nav > li > a { color: #fff !important; font-weight: bold !important; text-transform: uppercase; letter-spacing: 1px; }',
        '.alemprator-setup-body #topmenu .nav > li.active > a, .alemprator-setup-body #topmenu .nav > li > a:hover { color: #D4AF37 !important; background: rgba(212,175,55,0.15) !important; text-shadow: 0 0 10px rgba(212,175,55,0.5); }',
        '.alemprator-setup-body .nav { background: #050505 !important; display: flex !important; }',
        '.alemprator-setup-body .nav .side-nav { background: #050505 !important; border-right: 1px solid rgba(212,175,55,0.15) !important; display: block !important; }',
        '.alemprator-setup-body .cbi-map { background: transparent !important; border:none !important; }',
        '.alemprator-progress-container { position: absolute; top: 0; left: 0; width: 100%; height: 6px; background: rgba(212,175,55,0.1); overflow: hidden; border-radius: 30px 30px 0 0; z-index: 100; }',
        '.alemprator-progress-fill { height: 100%; background: linear-gradient(90deg, #D4AF37, #ffd700, #D4AF37); background-size: 200% 100%; animation: gold-flow 3s linear infinite; box-shadow: 0 0 20px #D4AF37; transition: width 0.8s cubic-bezier(0.34, 1.56, 0.64, 1); width: 0%; }',
        '@keyframes gold-flow { 0% { background-position: 0% 50%; } 100% { background-position: 200% 50%; } }',
        '.alemprator-setup-wizard { position: relative; max-width: 1050px !important; margin: 50px auto !important; background: #0c0c0c !important; border: 2px solid rgba(212,175,55,0.3) !important; border-radius: 40px !important; box-shadow: 0 50px 150px rgba(0,0,0,1) !important; padding: 80px 60px 60px 60px !important; overflow: hidden; transition: 0.5s; background-image: radial-gradient(circle at top right, rgba(212,175,55,0.05), transparent 400px); }',
        '.alemprator-step-title { color: #D4AF37 !important; font-size: 2.2rem !important; font-weight: 950 !important; margin-bottom: 50px !important; border-inline-start: 12px solid #D4AF37 !important; padding-inline-start: 30px !important; letter-spacing: 3px !important; display: block !important; text-shadow: 0 0 30px rgba(212,175,55,0.4) !important; text-transform: uppercase; }',
        '.alemprator-step-nav { display: flex; justify-content: center; gap: 15px; margin-bottom: 60px; perspective: 1000px; flex-wrap: wrap; }',
        '.alemprator-step-chip { background: #111; border: 1px solid rgba(212,175,55,0.2); border-radius: 50px; padding: 10px 25px; display: flex; align-items: center; gap: 12px; cursor: pointer; transition: 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); }',
        '.alemprator-step-chip.is-active { background: #D4AF37; border-color: #ffd700; transform: scale(1.1) translateZ(20px); box-shadow: 0 10px 30px rgba(212,175,55,0.4); }',
        '.alemprator-step-chip.is-active .alemprator-step-label { color: #000; }',
        '.alemprator-step-chip.is-active .alemprator-step-index { background: #000; color: #D4AF37; }',
        '.alemprator-step-chip.is-complete { border-color: #D4AF37; background: rgba(212,175,55,0.05); }',
        '.alemprator-step-chip.is-skipped { opacity: 0.4; pointer-events: none; transform: scale(0.9); filter: grayscale(1); }',
        '.alemprator-step-index { width: 32px; height: 32px; background: #222; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 900; color: #D4AF37; font-size: 0.9rem; border: 1px solid rgba(212,175,55,0.3); }',
        '.alemprator-step-label { color: #aaa; font-weight: 700; font-size: 0.9rem; }',
        '.alemprator-luxury-logo { position: absolute; transform: rotate(-45deg); top: 30px; left: -80px; background: linear-gradient(90deg, transparent, #D4AF37, transparent); width: 350px; text-align: center; padding: 10px 0; box-shadow: 0 0 30px rgba(0,0,0,0.5); z-index: 500; pointer-events: none; border-top: 1px solid rgba(255,255,255,0.3); border-bottom: 1px solid rgba(255,255,255,0.3); }',
        '.luxury-text { color: #000; font-weight: 950; letter-spacing: 5px; font-size: 1.1rem; }',
        '.luxury-subtext { color: #000; font-size: 0.6rem; font-weight: 900; margin-top: -3px; letter-spacing: 2px; }',
        '.alemprator-mode-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 25px; margin: 40px 0; }',
        '.alemprator-mode-card { background: linear-gradient(145deg, #1a1a1a, #0d0d0d); border: 1px solid rgba(212,175,55,0.1); border-radius: 25px; padding: 35px 25px; cursor: pointer; transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); text-align: center; position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 180px; }',
        '.alemprator-mode-card:hover { background: rgba(212,175,55,0.12); border-color: rgba(212,175,55,0.6); transform: translateY(-12px); box-shadow: 0 25px 50px rgba(0,0,0,0.6), 0 0 20px rgba(212,175,55,0.2); }',
        '.alemprator-mode-card:focus { outline: 3px solid #D4AF37 !important; outline-offset: 5px; }',
        '.alemprator-mode-card.is-active { background: linear-gradient(145deg, rgba(212,175,55,0.2), rgba(0,0,0,0.8)); border-color: #D4AF37; box-shadow: 0 0 40px rgba(212,175,55,0.35); border-width: 3px; }',
        '.alemprator-mode-card__icon { display: block !important; line-height: 1 !important; font-size: 3.5rem; margin-bottom: 15px; transition: 0.4s; filter: drop-shadow(0 0 15px rgba(0,0,0,0.8)); }',
        '.alemprator-mode-card:hover .alemprator-mode-card__icon { transform: scale(1.15) rotate(5deg); filter: drop-shadow(0 0 20px rgba(212,175,55,0.5)); }',
        '.alemprator-mode-card__title { color: #fff; font-weight: 900; font-size: 1.2rem; letter-spacing: 1px; }',
        '.alemprator-mode-card__desc { color: #888; font-size: 0.85rem; margin-top: 10px; line-height: 1.4; transition: 0.3s; }',
        '.alemprator-mode-card.is-active .alemprator-mode-card__title { color: #D4AF37; text-shadow: 0 0 10px rgba(212,175,55,0.4); }',
        '.alemprator-mode-card.is-active .alemprator-mode-card__desc { color: rgba(212,175,55,0.8); }',
        '.alemprator-setup-body .cbi-value-title { color: #aaa !important; font-weight: 700 !important; font-size: 1.1rem !important; margin-bottom: 8px !important; }',
        '.alemprator-setup-body .cbi-input-text, .alemprator-setup-body .cbi-input-select { background: #151515 !important; border: 1px solid #333 !important; border-radius: 12px !important; color: #fff !important; padding: 10px 15px !important; font-size: 1rem !important; transition: 0.3s !important; min-width: 200px !important; height: auto !important; }',
        '.alemprator-setup-body .cbi-input-select option { background: #151515; color: #fff; }',
        '.alemprator-setup-body .cbi-input-text:focus, .alemprator-setup-body .cbi-input-select:focus { border-color: #D4AF37 !important; box-shadow: 0 0 15px rgba(212,175,55,0.2) !important; outline: none !important; }',
        '.alemprator-review-card { background: #080808; border: 1px solid rgba(212,175,55,0.25); border-radius: 30px; padding: 45px; margin-top: 35px; box-shadow: inset 0 0 30px rgba(0,0,0,0.7); }',
        '.alemprator-review-item { display: flex; justify-content: space-between; padding: 20px 0; border-bottom: 1px solid rgba(212,175,55,0.1); align-items: center; transition: 0.3s; }',
        '.alemprator-review-item:hover { background: rgba(212,175,55,0.03); padding-left: 10px; padding-right: 10px; border-radius: 10px; }',
        '.alemprator-review-label { color: #888; font-size: 1.05rem; font-weight: 500; }',
        '.alemprator-review-value { color: #D4AF37; font-weight: 950; font-size: 1.3rem; text-shadow: 0 0 15px rgba(212,175,55,0.3); }',
        '.cbi-button-save.is-luxury { height: 75px !important; width: 100%; border-radius: 25px !important; font-size: 1.5rem !important; font-weight: 950 !important; background: linear-gradient(135deg, #D4AF37 0%, #8c7314 100%) !important; color: #000 !important; border: none !important; margin-top: 40px !important; letter-spacing: 5px !important; text-shadow: none !important; cursor: pointer; transition: 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275); box-shadow: 0 20px 50px rgba(212,175,55,0.3) !important; text-transform: uppercase; }',
        '.cbi-button-save.is-luxury:hover { transform: translateY(-7px) scale(1.02); background: linear-gradient(135deg, #ffd700 0%, #D4AF37 100%) !important; box-shadow: 0 30px 70px rgba(212,175,55,0.5) !important; }',
        '.cbi-button-save.is-luxury:active { transform: translateY(-2px); }',
        '.cbi-button-neutral { border-radius: 18px !important; padding: 12px 35px !important; background: #222 !important; color: #888 !important; border: 1px solid #444 !important; font-weight: 700 !important; transition: 0.3s !important; }',
        '.cbi-button-neutral:hover { color: #fff; border-color: #666 !important; background: #333 !important; }',
        '.alemprator-setup-actions { display: flex; justify-content: space-between; gap: 30px; margin-top: 50px; padding: 30px; background: rgba(212,175,55,0.05); border-radius: 30px; border: 1px solid rgba(212,175,55,0.15); box-shadow: 0 10px 30px rgba(0,0,0,0.3); }',
        '.alemprator-setup-body footer, .alemprator-setup-body .alert-message, .alemprator-setup-body .cbi-page-actions { display: none !important; }',
        '@media (max-width: 992px) {',
        '    .alemprator-setup-wizard { padding: 40px 30px 40px 30px !important; margin: 20px auto !important; border-radius: 30px !important; }',
        '    .alemprator-step-title { font-size: 1.8rem !important; margin-bottom: 30px !important; }',
        '}',
        '@media (max-width: 576px) {',
        '    .alemprator-setup-wizard { padding: 25px 15px 25px 15px !important; margin: 10px auto !important; border-radius: 20px !important; }',
        '    .alemprator-step-title { font-size: 1.4rem !important; padding-inline-start: 15px !important; border-inline-start-width: 8px !important; margin-bottom: 20px !important; }',
        '    .alemprator-step-nav { gap: 8px; margin-bottom: 30px; }',
        '    .alemprator-step-chip { padding: 6px 15px; font-size: 0.8rem; }',
        '    .alemprator-step-index { width: 24px; height: 24px; font-size: 0.8rem; }',
        '    .alemprator-mode-grid { gap: 15px; margin: 20px 0; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); }',
        '    .alemprator-mode-card { min-height: 140px; padding: 20px 10px; border-radius: 18px; }',
        '    .alemprator-mode-card__icon { font-size: 2.5rem; margin-bottom: 8px; }',
        '    .alemprator-mode-card__title { font-size: 1rem; }',
        '    .alemprator-mode-card__desc { font-size: 0.75rem; margin-top: 5px; }',
        '    .cbi-button-save.is-luxury { height: 55px !important; font-size: 1.1rem !important; border-radius: 15px !important; }',
        '}'
    ].join('\n');
    document.head.appendChild(style);

    document.body.classList.add('alemprator-setup-body');
}

function setClassState(element, className, active) {
	if (!element || !element.classList)
		return;

	if (active)
		element.classList.add(className);
	else
		element.classList.remove(className);
}

function setElementVisible(element, visible, displayValue) {
	if (!element)
		return;

	element.style.display = visible ? (displayValue || '') : 'none';
}

function setTextContent(node, value) {
	if (node)
		node.textContent = (value == null) ? '' : value;
}

function modeTitle(value) {
	switch (normalizeMode(value)) {
	case 'ap_wds':
		return _('نقطة وصول + WDS');

	case 'sta_wds':
		return _('عميل + WDS');

	case 'mesh':
		return _('ميش');

	case 'hotspot':
		return _('بوابة الهوتسبوت (الإمبراطور)');

	default:
		return _('نقطة وصول');
	}
}

function describeHeroSecondarySummary(state, radios) {
	var remainingBands;

	if (!state || !state.isVlan)
		return _('معطلة');

	remainingBands = getRemainingLocalBands(radios || [], state);

	if (!remainingBands.length)
		return _('مفعلة بدون بث محلي');

	if (remainingBands.length == 1)
		return previewSecondarySsid(state, remainingBands[0]);

	return previewSecondarySsid(state, '2g') + ' / ' + previewSecondarySsid(state, '5g');
}

function renderSummaryFact(label, valueNode) {
	return E('div', { 'class': 'alemprator-summary-fact' }, [
		E('span', { 'class': 'alemprator-summary-fact__label' }, label),
		E('div', { 'class': 'alemprator-summary-fact__value' }, [ valueNode ])
	]);
}

function renderStatusItem(label, valueNode, wide) {
	return E('div', { 'class': 'alemprator-status-item' + (wide ? ' is-wide' : '') }, [
		E('span', { 'class': 'alemprator-status-item__label' }, label),
		E('div', { 'class': 'alemprator-status-item__value' }, [ valueNode ])
	]);
}

function renderNoticeBox(kind, title, content) {
	var children = [];

	if (title)
		children.push(E('strong', title + ': '));

	if (Array.isArray(content))
		children = children.concat(content);
	else if (content != null)
		children.push(content);

	return E('div', { 'class': 'alemprator-notice alemprator-notice--' + kind }, children);
}

function renderCardLiveSummary(valueNode) {
	return E('div', { 'class': 'alemprator-inline-summary' }, [
		E('span', { 'class': 'alemprator-inline-summary__value' }, [ valueNode ])
	]);
}

function buildAdminUrl(lanIpaddr, route, buildTag) {
	var protocol = /^https?:$/.test(window.location.protocol || '') ? window.location.protocol : 'http:';
	var currentPort = String(window.location.port || '').trim();
	var host = String(lanIpaddr || '').trim();
	var url;

	if (!host)
		host = window.location.host || window.location.hostname;
	else if (currentPort)
		host = host + ':' + currentPort;

	url = protocol + '//' + host + route;

	if (buildTag)
		url += '?v=' + encodeURIComponent(buildTag);

	return url;
}

function buildWizardUrl(lanIpaddr) {
	return buildAdminUrl(lanIpaddr, WIZARD_ROUTE, WIZARD_BUILD_TAG);
	}

function buildDefaultAdminUrl(lanIpaddr) {
	return buildAdminUrl(lanIpaddr, DEFAULT_ADMIN_ROUTE);
}

function scheduleWizardRedirect(lanIpaddr, delayMs) {
	window.setTimeout(function() {
		window.location.replace(buildWizardUrl(lanIpaddr));
	}, delayMs || 0);
}

function scheduleDefaultAdminRedirect(lanIpaddr, delayMs) {
	window.setTimeout(function() {
		window.location.replace(buildDefaultAdminUrl(lanIpaddr));
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
	if (value == 'ap' || value == 'ap_wds' || value == 'sta_wds' || value == 'mesh' || value == 'hotspot')
		return value;

	return 'ap';
}

function modeNeedsDeferredApply(value) {
	return false;
}

function normalizeInterfaceName(value, fallback) {
	var normalized = String(value || '').trim();

	if (!/^[A-Za-z0-9_][A-Za-z0-9_.-]*$/.test(normalized))
		normalized = '';

	if (!normalized)
		normalized = fallback || 'hotspot';

	return normalized;
}

function deriveHotspotQuickSecondaryInterface(primaryInterface) {
	var primary = normalizeInterfaceName(primaryInterface, 'hotspot');
	var candidate = primary + '2';

	if (!/^[A-Za-z0-9_][A-Za-z0-9_.-]*$/.test(candidate))
		candidate = 'hotspot2';

	if (candidate == primary)
		candidate = primary + '_2';

	return normalizeInterfaceName(candidate, 'hotspot2');
}

function normalizeHotspotPolicy(value, fallback) {
	var normalized = String(value || '').trim();
	var allowed = [ 'standard', 'premium', 'guest', 'staff', 'trial' ];

	if (!normalized)
		return fallback || 'standard';

	if (allowed.indexOf(normalized) == -1)
		return fallback || 'standard';

	return normalized;
}

function hotspotPolicyChoices() {
	return [
		E('option', { 'value': 'standard' }, _('Standard')),
		E('option', { 'value': 'premium' }, _('Premium')),
		E('option', { 'value': 'guest' }, _('Guest')),
		E('option', { 'value': 'staff' }, _('Staff')),
		E('option', { 'value': 'trial' }, _('Trial'))
	];
}

function normalizePort(value, fallback) {
	var port = parseInt(String(value || '').trim(), 10);

	if (!(port >= 1 && port <= 65535))
		return fallback || '1812';

	return String(port);
}

function normalizePositiveNumber(value, fallback) {
	var number = parseInt(String(value || '').trim(), 10);

	if (!(number >= 1))
		return fallback || '1';

	return String(number);
}

function splitQuickList(value) {
	function normalizeEntry(entry) {
		var text = String(entry || '').trim();

		text = text.replace(/^[A-Za-z][A-Za-z0-9+.-]*:\/\//, '');
		text = text.replace(/^\/\//, '');
		text = text.split(/[/?#]/)[0];
		text = text.replace(/:[0-9]+$/, '');
		return text.trim();
	}

	if (Array.isArray(value))
		return value.map(normalizeEntry).filter(function(entry) { return entry !== ''; });

	return String(value || '').split(/[\n,\s]+/).map(function(entry) {
		return normalizeEntry(entry);
	}).filter(function(entry) {
		return entry !== '';
	});
}

function quickListText(value) {
	return splitQuickList(value).join('\n');
}

function validQuickDomain(value) {
	return /^[A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9]$/.test(String(value || ''));
}

function ipv4ToInt(value) {
	var parts;

	if (!isIPv4(value))
		return null;

	parts = String(value).split('.').map(function(part) {
		return parseInt(part, 10) || 0;
	});

	return (((parts[0] << 24) >>> 0) + ((parts[1] << 16) >>> 0) + ((parts[2] << 8) >>> 0) + (parts[3] >>> 0)) >>> 0;
}

function sameIpv4Subnet24(a, b) {
	var left = String(a || '').split('.');
	var right = String(b || '').split('.');

	if (!isIPv4(a) || !isIPv4(b) || left.length != 4 || right.length != 4)
		return false;

	return left[0] == right[0] && left[1] == right[1] && left[2] == right[2];
}

function deriveHotspotPoolIp(gateway, host) {
	var octets = String(gateway || '').trim().split('.');

	if (octets.length == 4 && isIPv4(gateway))
		return [ octets[0], octets[1], octets[2], String(host) ].join('.');

	return host == 10 ? '192.168.10.10' : '192.168.10.199';
}

function deriveHotspotPoolStart(gateway) {
	return deriveHotspotPoolIp(gateway, 10);
}

function deriveHotspotPoolEnd(gateway) {
	return deriveHotspotPoolIp(gateway, 199);
}

function ipv4LastTwoOctets(value) {
	var octets = String(value || '').trim().split('.');

	if (octets.length == 4 && isIPv4(value))
		return octets[2] + '.' + octets[3];

	return '';
}

function stripNasIdIpSuffix(value) {
	return String(value || '').trim().replace(/[-_][0-9]{1,3}\.[0-9]{1,3}$/, '');
}

function deriveHotspotQuickNasId(baseName, lanIpaddr) {
	var suffix = ipv4LastTwoOctets(lanIpaddr);
	var base = stripNasIdIpSuffix(baseName) || 'KT-KM14-102H-HOTSPOT';

	return suffix ? (base + '-' + suffix) : base;
}

function normalizeHotspotLoginMode(value) {
	return value == 'username' ? 'username' : 'both';
}

function hotspotLoginModeChoices() {
	return [
		E('option', { 'value': 'username' }, _('رقم كرت فقط')),
		E('option', { 'value': 'both' }, _('اسم مستخدم وكلمة مرور'))
	];
}

function normalizeBrowserCookieDays(value) {
	var days = parseInt(value, 10);

	if (!isFinite(days) || days < 1)
		return '7';

	if (days > 365)
		return '365';

	return String(days);
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

function normalizeRouterOsScheme(value) {
	return value == 'http' ? 'http' : 'https';
}

function routerOsSchemeChoices() {
	return [
		E('option', { 'value': 'https' }, 'https'),
		E('option', { 'value': 'http' }, 'http')
	];
}

function validRateLimit(value) {
	var text = String(value || '').trim();

	return !text || /^[0-9]+[KMG]?\/[0-9]+[KMG]?$/i.test(text);
}

function normalizeSpeedOptionsText(value) {
	return String(value || '').replace(/\\n/g, '\n').trim();
}

function validateHotspotQuickProfile(state, index) {
	var suffix = String(index || 1);
	var ssid = String(state['hotspotQuickSsid' + suffix] || '').trim();
	var gateway = String(state['hotspotQuickGateway' + suffix] || '').trim();
	var poolStart = deriveHotspotPoolStart(gateway);
	var poolEnd = deriveHotspotPoolEnd(gateway);
	var startInt;
	var endInt;

	if (!ssid)
		return _('أدخل اسم شبكة الهوتسبوت رقم ') + suffix + _('.');

	if (!isIPv4(gateway))
		return _('أدخل عنوان بوابة IPv4 صحيح للشبكة رقم ') + suffix + _('.');

	if (!isIPv4(poolStart) || !isIPv4(poolEnd))
		return _('أدخل مدى عناوين صحيح للشبكة رقم ') + suffix + _('.');

	if (!sameIpv4Subnet24(gateway, poolStart) || !sameIpv4Subnet24(gateway, poolEnd))
		return _('يجب أن يكون مدى العناوين ضمن نفس الشبكة /24 للشبكة رقم ') + suffix + _('.');

	startInt = ipv4ToInt(poolStart);
	endInt = ipv4ToInt(poolEnd);

	if (startInt == null || endInt == null || startInt > endInt)
		return _('نهاية المدى يجب أن تكون أكبر أو مساوية للبداية للشبكة رقم ') + suffix + _('.');

	return '';
}

function summarizeHotspotQuick(state) {
	if (!state || !state.hotspotQuickEnabled)
		return _('معطل');

	if (state.hotspotQuickSecondaryEnabled === false)
		return String(state.hotspotQuickSsid1 || 'Hotspot-1') + ' (' + String(state.hotspotQuickGateway1 || '192.168.10.1') + ')';

	return String(state.hotspotQuickSsid1 || 'Hotspot-1') + ' (' + String(state.hotspotQuickGateway1 || '192.168.10.1') + ') | ' +
		String(state.hotspotQuickSsid2 || 'Hotspot-2') + ' (' + String(state.hotspotQuickGateway2 || '192.168.20.1') + ')';
}

function enforceHotspotNoVlan(state) {
	if (!state || !state.hotspotQuickEnabled)
		return;

	state.isVlan = false;
	state.vlanId = '10';
}

function deriveVlanGateway(baseIp, vlanId) {
	var octets = String(baseIp || '').split('.');
	var derivedId = Math.min(Math.max(parseInt(vlanId, 10) || 10, 1), 254);

	if (octets.length == 4)
		return [ octets[0], octets[1], String(derivedId), '1' ].join('.');

	return [ '192', '168', String(derivedId), '1' ].join('.');
}

function deriveLanGateway(baseIp) {
	var octets = String(baseIp || '').trim().split('.');

	if (octets.length == 4 && isIPv4(baseIp))
		return [ octets[0], octets[1], octets[2], '1' ].join('.');

	return '';
}

function wifiSsidIpSuffix(state) {
	var ipaddr = String(state && state.lanIpaddr || '').trim();
	var octets = ipaddr.split('.');

	if (!state || !state.wifiSsidVlanIpSuffix || octets.length != 4 || !isIPv4(ipaddr))
		return '';

	return octets[2] + '.' + octets[3];
}

function appendWifiSsidIpSuffix(ssid, state) {
	var suffix = wifiSsidIpSuffix(state);
	var normalized = String(ssid || '').trim();
	var marker = '_' + suffix;

	if (!normalized || !suffix || normalized.slice(-marker.length) == marker)
		return normalized;

	return normalized + marker;
}

function stripWifiSsidIpSuffix(ssid, state) {
	var suffix = wifiSsidIpSuffix(state);
	var normalized = String(ssid || '').trim();
	var marker = '_' + suffix;

	if (normalized && suffix && normalized.slice(-marker.length) == marker)
		return normalized.slice(0, -marker.length);

	return normalized;
}

function appendVlanSsidIpSuffix(ssid, state) {
	return appendWifiSsidIpSuffix(ssid, state);
}

function stripVlanSsidIpSuffix(ssid, state) {
	return stripWifiSsidIpSuffix(ssid, state);
}

function describeSecondaryVlanBinding(vlanId) {
	var normalizedId = Math.min(Math.max(parseInt(vlanId, 10) || 10, 1), 4094);

	return 'VLAN ' + normalizedId;
}

function normalizeList(value) {
	if (Array.isArray(value))
		return value.slice();

	if (value == null || value === '')
		return [];

	if (typeof value == 'string')
		return value.trim().split(/\s+/).filter(function(entry) { return entry !== ''; });

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

function cleanupHotspotWizardState() {
	var firewallLanZone = findFirewallZone('lan');
	var hotspotNetworks = [ 'hotspot', 'hotspot2' ];
	var hotspotNetworkMap = {};
	var hotspotTunnels = { tun0: true, tun1: true };

	hotspotNetworks.forEach(function(networkName) {
		hotspotNetworkMap[networkName] = true;
	});

	uci.remove('wireless', 'wizard_hotspot');
	uci.remove('wireless', HOTSPOT_QUICK_IFACE_PRIMARY);
	uci.remove('wireless', HOTSPOT_QUICK_IFACE_SECONDARY);

	uci.sections('wireless', 'wifi-iface').forEach(function(section) {
		var sid = section['.name'];
		var sectionNetworks = normalizeList(section.network);

		if (sectionNetworks.some(function(networkName) { return !!hotspotNetworkMap[networkName]; }))
			uci.remove('wireless', sid);
	});

	hotspotNetworks.forEach(function(networkName) {
		uci.remove('network', networkName);
		uci.remove('network', networkName + '_dev');
		uci.remove('dhcp', networkName);

		if (firewallLanZone)
			removeListValue('firewall', firewallLanZone, 'network', networkName);
	});

	uci.sections('chilli', 'chilli').forEach(function(section) {
		var sid = section['.name'];
		var dhcpif = normalizeInterfaceName(section.dhcpif || '', '');
		var tundev = String(section.tundev || '').trim();

		if (hotspotNetworkMap[dhcpif] || hotspotTunnels[tundev] || sid == 'hotspot_openwrt' || sid == 'hotspot_openwrt_secondary')
			uci.remove('chilli', sid);
	});

	if (uci.get('hotspot_openwrt', 'main')) {
		uci.set('hotspot_openwrt', 'main', 'enabled', '0');
		uci.set('hotspot_openwrt', 'main', 'quick_setup_enabled', '0');
		uci.set('hotspot_openwrt', 'main', 'quick_runtime_dual_enabled', '0');
		uci.unset('hotspot_openwrt', 'main', 'wifi_iface');
	}

	uci.set('setup', 'default', 'hotspot_quick_enabled', '0');
	uci.set('setup', 'default', 'hotspot_quick_secondary_enabled', '0');
	uci.set('setup', 'default', 'hotspot_enabled_from_wizard', '0');
}

function findNetworkDeviceSectionByName(deviceName) {
	var sections = uci.sections('network', 'device');
	var i;

	for (i = 0; i < sections.length; i++) {
		var section = sections[i];

		if (section.name == deviceName || section['.name'] == deviceName)
			return section['.name'];
	}

	return null;
}

function ensureBridgeAgingTime(deviceName, seconds) {
	var normalizedName = String(deviceName || '').trim();
	var sid;

	if (!normalizedName)
		return;

	sid = findNetworkDeviceSectionByName(normalizedName);

	if (!sid && uci.get('network', normalizedName) == 'device')
		sid = normalizedName;

	if (!sid)
		return;

	uci.set('network', sid, 'ageing_time', String(seconds || 10));
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

function nextWifiIfaceSid() {
	var index = 0;
	var sid;

	do {
		sid = 'wifinet' + String(index++);
	} while (uci.get('wireless', sid));

	return sid;
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

	ifaceName = nextWifiIfaceSid();
	ensureNamedSection('wireless', ifaceName, 'wifi-iface');
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
	var normalizedBase = String(state ? state.wifiSsid : baseSsid || '').trim() || 'OpenWrt';
	var configuredSecondaryBase = String(state ? state.wifiSsidVlan2g : '').trim();
	var suffixedSecondaryBase;

	if (!configuredSecondaryBase)
		configuredSecondaryBase = normalizedBase + '_VLAN';

	suffixedSecondaryBase = appendWifiSsidIpSuffix(configuredSecondaryBase, state);

	if (band == '5g')
		return suffixedSecondaryBase + '_5G';

	return suffixedSecondaryBase;
}

function previewSecondaryManualSsid(state, band) {
	if (band == '5g')
		return String(state ? state.wifiSsidVlan5g : '').trim();

	return String(state ? state.wifiSsidVlan2g : '').trim();
}

function previewSecondarySsid(state, band) {
	var manualSsid = previewSecondaryManualSsid(state, band);

	if (manualSsid)
		return appendWifiSsidIpSuffix(manualSsid, state);

	return secondarySsid(state, band);
}

function primarySsid(baseSsid, band) {
	var state = (baseSsid != null && typeof baseSsid == 'object') ? baseSsid : null;
	var normalizedBase = String(state ? state.wifiSsid : baseSsid || '').trim();
	var custom5g = String(state ? state.wifiSsid5g : '').trim();
	var custom5gEnabled = !!(state && state.wifiSsid5gMode == 'custom' && custom5g);
	var suffixedBase = appendWifiSsidIpSuffix(normalizedBase, state);

	if (band == '5g')
		if (custom5gEnabled)
			return appendWifiSsidIpSuffix(custom5g, state);

	if (band == '5g')
		return suffixedBase ? (suffixedBase + '_5G') : '';

	return suffixedBase;
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
	if (!state) return [];
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
		return _('تم حفظ VLAN الثانوية بدون بث لاسلكي.');

	if (remainingCount == 1)
		return _('تم حفظ VLAN الثانوية على ') + bandLabel(onlyBand) + _('.');

	return _('تم حفظ VLAN الثانوية على الراديوهات المحلية.');
}

function describeAppliedModeResult(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var radio2g = getRadioByBand(radios || [], '2g');
	var uplinkBand = getRadioByBand(radios || [], state.uplinkBand) ? state.uplinkBand : (radio2g ? '2g' : '5g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');

	if (state.mode == 'ap_wds') {
		if (!remainingBands.length)
			return _('تم حفظ AP + WDS، ولا توجد شبكة محلية نشطة.');

		if (remainingBands.length == 1)
			return _('تم حفظ AP + WDS على ') + bandLabel(onlyBand) + _('.');

		return _('تم حفظ AP + WDS على الراديوهات المحلية.');
	}

	if (state.mode == 'sta_wds') {
		if (!remainingBands.length)
			return _('تم حفظ Client + WDS. الربط الصاعد على ') + bandLabel(uplinkBand) + _('، ولا توجد شبكة محلية.');

		if (remainingBands.length == 1)
			return _('تم حفظ Client + WDS. الربط الصاعد على ') + bandLabel(uplinkBand) + _(' والبث المحلي على ') + bandLabel(onlyBand) + _('.');

		return _('تم حفظ Client + WDS. الربط الصاعد على ') + bandLabel(uplinkBand) + _('.');
	}

	if (state.mode == 'mesh') {
		if (!remainingBands.length)
			return _('تم حفظ الميش على ') + bandLabel(meshBand) + _('، ولا توجد شبكة محلية.');

		if (remainingBands.length == 1)
			return _('تم حفظ الميش على ') + bandLabel(meshBand) + _(' والبث المحلي على ') + bandLabel(onlyBand) + _('.');

		return _('تم حفظ الميش على ') + bandLabel(meshBand) + _('.');
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
		return _('أعد الاتصال يدويًا بـ ') + activeSsids[0] + _('.');

	return _('أعد الاتصال يدويًا بإحدى الشبكات: ') + activeSsids.join(', ') + _('.');
}

function describePrimaryWifiPlan(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];
	var primaryFirst = firstBand ? primarySsid(state, firstBand) : '';
	var primarySecond = secondBand ? primarySsid(state, secondBand) : '';

	if (!remainingBands.length)
		return _('لن تبقى شبكة واي فاي محلية نشطة.');

	if (!String(state ? state.wifiSsid : '').trim())
		return _('أدخل اسم الشبكة الأساسية.');

	if (remainingBands.length == 1)
		return primaryFirst + _(' على ') + bandLabel(firstBand);

	return bandLabel(firstBand) + ': ' + primaryFirst + ' | ' + bandLabel(secondBand) + ': ' + primarySecond;
}

function describePrimaryWifiNamingHelp(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var baseSsid = String(state ? state.wifiSsid : '').trim();
	var automatic5gName = primarySsid({
		wifiSsid: baseSsid,
		wifiSsid5gMode: 'derived',
		wifiSsid5g: ''
	}, '5g');

	if (!remainingBands.length)
		return _('لن تبقى شبكة محلية في هذا الوضع.');

	if (!baseSsid)
		return _('أدخل اسم SSID الأساسي أولًا.');

	if (remainingBands.length == 1) {
		if (remainingBands[0] == '5g')
			return (state && state.wifiSsid5gMode == 'custom')
				? _('سيستخدم 5GHz الاسم المخصص.')
				: _('اسم 5GHz سيكون: ') + automatic5gName;

		return _('سيُستخدم الاسم الأساسي كما هو على 2.4GHz.');
	}

	if (state && state.wifiSsid5gMode == 'custom')
		return _('2.4GHz بالاسم الأساسي، و5GHz بالاسم المخصص.');

	return _('2.4GHz بالاسم الأساسي، و5GHz سيكون: ') + automatic5gName;
}

function describeSecondaryNetworkNotice(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!state.isVlan)
		return '';

	if (!remainingBands.length)
		return _('في هذا الوضع لا يوجد راديو محلي متاح لبث الشبكة الثانوية.');

	if (remainingBands.length == 1) {
		return _('الشبكة الثانوية ستبث فقط على ') + bandLabel(onlyBand) + _(' باسم ') + previewSecondarySsid(state, onlyBand) + _('.');
	}

	return _('الشبكة الثانوية ستبث على ') + bandLabel(firstBand) + _(' باسم ') + previewSecondarySsid(state, firstBand) + _(' وعلى ') + bandLabel(secondBand) + _(' باسم ') + previewSecondarySsid(state, secondBand) + _('.');
}

function describeSecondarySubnetHelp(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];
	var vlanBinding = describeSecondaryVlanBinding(state && state.vlanId);

	if (!state.isVlan)
		return _('عند التفعيل سيتم إنشاء شبكة واي فاي ثانوية منفصلة عن الشبكة الرئيسية.');

	if (!remainingBands.length)
		return _('سيتم تجهيز ') + vlanBinding + _('، لكن من دون بث شبكة ثانوية في الوضع الحالي.');

	if (remainingBands.length == 1)
		return _('الأجهزة التي تتصل بـ ') + previewSecondarySsid(state, onlyBand) + _(' ستدخل إلى ') + vlanBinding + _(' بدل الشبكة الرئيسية.');

	return _('الأجهزة التي تتصل بـ ') + previewSecondarySsid(state, firstBand) + _(' أو ') + previewSecondarySsid(state, secondBand) + _(' ستدخل إلى ') + vlanBinding + _(' بدل الشبكة الرئيسية.');
}

function describeSecondaryNetworkIntro(state, radios) {
	var remainingBands = getRemainingLocalBands(radios, state);
	var onlyBand = remainingBands[0];
	var firstBand = remainingBands[0];
	var secondBand = remainingBands[1];

	if (!remainingBands.length)
		return _('فعّل VLAN لإعداد شبكة ثانوية معزولة. في هذا الوضع لن يتم بث شبكة واي فاي ثانوية.');

	if (remainingBands.length == 1)
		return _('فعّل VLAN لإضافة شبكة ثانوية معزولة مع بقاء الشبكة الرئيسية كما هي. البث سيكون فقط على ') + bandLabel(onlyBand) + _('.');

	return _('فعّل VLAN لإضافة شبكة ثانوية معزولة مع بقاء الشبكة الرئيسية كما هي. البث سيكون على ') + bandLabel(firstBand) + _(' و ') + bandLabel(secondBand) + _('.');
}

function describeUplinkSettingsHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var uplinkBand = getRadioByBand(radios || [], state.uplinkBand) ? state.uplinkBand : (radio2g ? '2g' : '5g');
	var remainingBands = getRemainingLocalBands(radios || [], state);
	var onlyBand = remainingBands[0];

	if (!remainingBands.length)
		return _('الربط الصاعد سيكون على ') + bandLabel(uplinkBand) + _('، ولا توجد شبكة محلية.');

	if (remainingBands.length == 1)
		return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، والبث المحلي على ') + bandLabel(onlyBand) + _('.');

	return _('اختر راديو الربط الصاعد، والباقي يبقى للبث المحلي.');
}

function describeMeshSettingsHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');
	var remainingBands = getRemainingLocalBands(radios || [], state);
	var onlyBand = remainingBands[0];

	if (!remainingBands.length)
		return _('الميش سيكون على ') + bandLabel(meshBand) + _('، ولا توجد شبكة محلية.');

	if (remainingBands.length == 1)
		return _('الميش على ') + bandLabel(meshBand) + _('، والبث المحلي على ') + bandLabel(onlyBand) + _('.');

	return _('اختر راديو الميش، والباقي يبقى للبث المحلي.');
}

function describeMeshChannelHelp(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var meshBand = getRadioByBand(radios || [], state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');
	var meshChannel = meshBand == '5g' ? state.channel5g : state.channel2g;

	if (meshChannel && meshChannel != 'auto')
		return _('قناة الميش: ') + meshChannel + _(' على ') + bandLabel(meshBand) + _('.');

	return _('الميش يحتاج قناة ثابتة على ') + bandLabel(meshBand) + _('.');
}

function summarizeLanCard(state) {
	var ipaddr = String(state && state.lanIpaddr || '').trim() || '-';
	var netmask = String(state && state.lanNetmask || '').trim() || '-';

	return ipaddr + ' / ' + netmask;
}

function summarizeModeCard(state) {
	return modeTitle(state && state.mode);
}

function summarizePrimaryWifiCard(state, radios) {
	var bands = getRemainingLocalBands(radios || [], state || {});

	if (!bands.length)
		return _('لا توجد شبكات محلية نشطة');

	return bands.map(function(band) {
		return bandLabel(band) + ': ' + primarySsid(state, band);
	}).join(' | ');
}

function summarizeWifiSecurity(state) {
	return (state && state.wifiKey)
		? _('محمية بكلمة مرور')
		: _('بدون كلمة مرور');
}

function summarizeUplinkCard(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var band = getRadioByBand(radios || [], state && state.uplinkBand) ? state.uplinkBand : (radio2g ? '2g' : '5g');

	if (!state || state.mode != 'sta_wds')
		return _('غير مستخدم في الوضع الحالي');

	if (!String(state.uplinkSsid || '').trim())
		return _('بانتظار اسم شبكة الربط الصاعد على ') + bandLabel(band);

	return bandLabel(band) + ': ' + state.uplinkSsid;
}

function summarizeMeshCard(state, radios) {
	var radio2g = getRadioByBand(radios || [], '2g');
	var band = getRadioByBand(radios || [], state && state.meshBand) ? state.meshBand : (radio2g ? '2g' : '5g');

	if (!state || state.mode != 'mesh')
		return _('غير مستخدم في الوضع الحالي');

	if (!String(state.meshId || '').trim())
		return _('بانتظار معرف الميش على ') + bandLabel(band);

	return bandLabel(band) + ': ' + state.meshId;
}

function summarizeVlanCard(state, radios) {
	var bands;
	var names;

	if (!state || !state.isVlan)
		return _('VLAN معطلة');

	bands = getRemainingLocalBands(radios || [], state);
	names = bands.map(function(band) {
		return previewSecondarySsid(state, band);
	});

	return 'VLAN ' + String(state.vlanId || '10') + (names.length ? ' | ' + names.join(' / ') : ' | ' + _('بدون SSID محلي'));
}

function summarizeChannelCard(state, radios) {
	var parts = [];

	if (getRadioByBand(radios || [], '2g'))
		parts.push('2.4GHz: ' + String(state && state.channel2g || 'auto'));

	if (getRadioByBand(radios || [], '5g'))
		parts.push('5GHz: ' + String(state && state.channel5g || 'auto'));

	return parts.length ? parts.join(' | ') : _('لا توجد راديوهات متاحة');
}

function summarizeOtaCard(state) {
	return (state && state.otaWindowAvailable)
		? describeOtaWindow(state.otaWindowStart, state.otaWindowEnd)
		: _('إعدادات التحديث التلقائي غير متوفرة على هذا الجهاز.');
}

function summarizeButtonPolicies(state) {
	return _('زر Reset: ') + ((state && state.resetDisabled) ? _('معطل') : _('مفعل')) + ' | ' + _('زر WPS: ') + ((state && state.wpsDisabled) ? _('معطل') : _('مفعل'));
}

function summarizeRebootPolicy(state) {
	if (!state || !state.rebootEnabled)
		return _('إعادة التشغيل التلقائية معطلة');

	return _('كل ') + String(state.rebootHours || '24') + _(' ساعة');
}

function summarizePasswordCard(state) {
	if (!state || (!state.adminPassword && !state.adminPasswordConfirm))
		return _('لا يوجد تغيير معلّق');

	if (!state.adminPassword || !state.adminPasswordConfirm)
		return _('بانتظار إدخال وتأكيد كلمة المرور');

	if (state.adminPassword != state.adminPasswordConfirm)
		return _('كلمتا المرور غير متطابقتين');

	return _('جاهزة للتطبيق');
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

function optionIsEnabled(value) {
	var normalized = String(value == null ? '' : value).trim().toLowerCase();

	return normalized == '1' || normalized == 'true' || normalized == 'on' || normalized == 'yes';
}

function sectionHasNetwork(section, networkName) {
	return normalizeList(section && section.network).indexOf(networkName) > -1;
}

function prefixToNetmask(prefixLength) {
	var bits = parseInt(prefixLength, 10);
	var octets = [];
	var i;

	if (isNaN(bits) || bits < 0 || bits > 32)
		return '';

	for (i = 0; i < 4; i++) {
		if (bits >= 8) {
			octets.push('255');
			bits -= 8;
		}
		else if (bits > 0) {
			octets.push(String((0xFF << (8 - bits)) & 0xFF));
			bits = 0;
		}
		else {
			octets.push('0');
		}
	}

	return octets.join('.');
}

function parseLanRuntimeState(lanStatus) {
	var result = { ipaddr: '', netmask: '' };
	var addresses = lanStatus && lanStatus['ipv4-address'];
	var addr;
	var mask;

	if (!Array.isArray(addresses) || !addresses.length)
		return result;

	addr = addresses[0] || {};
	result.ipaddr = String(addr.address || '').trim();
	mask = addr.mask;

	if (mask != null) {
		if (/^[0-9]+$/.test(String(mask)))
			result.netmask = prefixToNetmask(mask);
		else if (isIPv4(String(mask)))
			result.netmask = String(mask);
	}

	return result;
}

function findNamedWifiIfaceSection(name) {
	var sections = uci.sections('wireless', 'wifi-iface');
	var i;

	for (i = 0; i < sections.length; i++) {
		if (sections[i]['.name'] == name)
			return sections[i];
	}

	return null;
}

function findFirstWifiIfaceSection(predicateFn) {
	var sections = uci.sections('wireless', 'wifi-iface');
	var i;

	for (i = 0; i < sections.length; i++) {
		if (predicateFn(sections[i]))
			return sections[i];
	}

	return null;
}

function findUplinkIfaceSection() {
	var named = findNamedWifiIfaceSection('wizard_uplink');

	if (named && named.mode == 'sta')
		return named;

	return findFirstWifiIfaceSection(function(section) {
		return section.mode == 'sta' && sectionHasNetwork(section, 'lan');
	}) || findFirstWifiIfaceSection(function(section) {
		return section.mode == 'sta';
	});
}

function findMeshIfaceSection() {
	var named = findNamedWifiIfaceSection('wizard_mesh');

	if (named && named.mode == 'mesh')
		return named;

	return findFirstWifiIfaceSection(function(section) {
		return section.mode == 'mesh';
	});
}

function findApIfaceSection(deviceName, preferredNetwork) {
	var sections = uci.sections('wireless', 'wifi-iface');
	var fallback = null;
	var i;

	if (!deviceName)
		return null;

	for (i = 0; i < sections.length; i++) {
		var section = sections[i];
		var mode = section.mode;

		if (section.device != deviceName)
			continue;

		if (mode != null && mode != 'ap')
			continue;

		if (preferredNetwork && sectionHasNetwork(section, preferredNetwork))
			return section;

		if (preferredNetwork) {
			if (!sectionHasNetwork(section, 'wizardvlan') && fallback == null)
				fallback = section;

			continue;
		}

		if (!sectionHasNetwork(section, 'wizardvlan') && fallback == null)
			fallback = section;
		else if (fallback == null)
			fallback = section;
	}

	return fallback;
}

function findSecondaryApIfaceSection(radios, band) {
	var radio = getRadioByBand(radios || [], band);

	if (!radio)
		return null;

	return findFirstWifiIfaceSection(function(section) {
		var mode = section.mode;

		if (section.device != radio['.name'])
			return false;

		if (mode != null && mode != 'ap')
			return false;

		return sectionHasNetwork(section, 'wizardvlan');
	});
}

function inferCurrentMode() {
	if (findMeshIfaceSection())
		return 'mesh';

	if (findUplinkIfaceSection())
		return 'sta_wds';

	if (findFirstWifiIfaceSection(function(section) {
		var mode = section.mode;

		if (mode != null && mode != 'ap')
			return false;

		if (!sectionHasNetwork(section, 'lan'))
			return false;

		return optionIsEnabled(section.wds);
	}))
		return 'ap_wds';

	return 'ap';
}

function inferVlanEnabled() {
	if (uci.get('network', 'wizardvlan') || uci.get('network', 'wizard_vlan_dev') || uci.get('network', 'wizard_vlan_bridge'))
		return true;

	return !!findFirstWifiIfaceSection(function(section) {
		return sectionHasNetwork(section, 'wizardvlan');
	});
}

function inferVlanId() {
	var vid = String(uci.get('network', 'wizard_vlan_dev', 'vid') || '').trim();
	var deviceName = String(uci.get('network', 'wizardvlan', 'device') || '').trim();
	var parsed;

	if (/^[0-9]+$/.test(vid) && +vid >= 1 && +vid <= 4094)
		return vid;

	if ((parsed = deviceName.match(/^vlan_([0-9]{1,4})$/))) {
		if (+parsed[1] >= 1 && +parsed[1] <= 4094)
			return parsed[1];
	}

	vid = String(uci.get('setup', 'default', 'vlan_id') || '').trim();
	if (/^[0-9]+$/.test(vid) && +vid >= 1 && +vid <= 4094)
		return vid;

	return '10';
}

function inferSecondarySsids(radios, baseSsid) {
	var secondary2g = findSecondaryApIfaceSection(radios, '2g');
	var secondary5g = findSecondaryApIfaceSection(radios, '5g');
	var actual2g = secondary2g ? String(secondary2g.ssid || '').trim() : '';
	var actual5g = secondary5g ? String(secondary5g.ssid || '').trim() : '';
	var configured2g = String(uci.get('setup', 'default', 'wifi_ssid_vlan_2g') || uci.get('setup', 'default', 'wifi_ssid_vlan') || '').trim();
	var configured5g = String(uci.get('setup', 'default', 'wifi_ssid_vlan_5g') || '').trim();
	var expectedState = {
		lanIpaddr: uci.get('network', 'lan', 'ipaddr') || uci.get('setup', 'default', 'lan_ipaddr') || '192.168.1.1',
		wifiSsid: baseSsid || 'OpenWrt',
		wifiSsidVlan2g: configured2g,
		wifiSsidVlan5g: configured5g,
		wifiSsidVlanIpSuffix: uci.get('setup', 'default', 'wifi_ssid_vlan_ip_suffix') == '1'
	};
	var expected2g = secondarySsid(expectedState, '2g');
	var expected5g = secondarySsid(expectedState, '5g');
	var inferred2g = '';
	var inferred5g = '';

	if (actual2g && actual2g != expected2g)
		inferred2g = stripVlanSsidIpSuffix(actual2g, expectedState);

	if (actual5g && actual5g != expected5g)
		inferred5g = stripVlanSsidIpSuffix(actual5g, expectedState);

	if (!inferred5g && inferred2g) {
		var inferred2gTo5g = inferred2g + '_5G';

		if (actual5g == inferred2gTo5g)
			inferred5g = inferred2gTo5g;
	}

	return {
		ssid2g: inferred2g,
		ssid5g: inferred5g
	};
}

function inferUplinkBand(radio2g, radio5g, uplinkIface) {
	var configuredBand = uci.get('setup', 'default', 'uplink_band');
	var uplinkDevice = uplinkIface ? uplinkIface.device : uci.get('wireless', 'wizard_uplink', 'device');

	if (radio2g && uplinkDevice == radio2g['.name'])
		return '2g';

	if (radio5g && uplinkDevice == radio5g['.name'])
		return '5g';

	if (configuredBand == '2g' || configuredBand == '5g')
		return configuredBand;

	return radio2g ? '2g' : '5g';
}

function inferMeshBand(radio2g, radio5g, meshIface) {
	var configuredBand = uci.get('setup', 'default', 'mesh_band');
	var meshDevice = meshIface ? meshIface.device : uci.get('wireless', 'wizard_mesh', 'device');

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
	var badges = [];
	var keys = Object.keys(status || {}).sort();
	var i;

	if (!keys.length)
		return E('p', { 'class': 'alemprator-empty-text' }, _('لا تتوفر حاليًا معلومات تشغيل مباشرة عن الواي فاي.'));

	for (i = 0; i < keys.length; i++) {
		var radioName = keys[i];
		var radio = status[radioName] || {};
		var band = (radio.config && radio.config.band) || '';
		var isUp = false;
		var interfaces = Array.isArray(radio.interfaces) ? radio.interfaces : [];
		var firstSsid = '';
		var j;

		for (j = 0; j < interfaces.length; j++) {
			if (interfaces[j].up) isUp = true;
			if (!firstSsid) firstSsid = interfaces[j].ssid || (interfaces[j].config && interfaces[j].config.ssid);
		}

		// Fallback to radio up state if no interfaces defined
		if (!interfaces.length && radio.up) isUp = true;

		var label = radioLabel({ '.name': radioName, band: band });
		// Cleanup the label to be just "2G" or "5G" if possible, or keep it short
		var shortLabel = label.replace(_('الراديو'), '').replace(':', '').trim();
		
		badges.push(E('div', { 'class': 'alemprator-status-badge ' + (isUp ? 'is-up' : 'is-down') }, [
			E('span', { 'class': 'alemprator-status-badge__dot' }),
			E('strong', shortLabel + (firstSsid ? ': ' + firstSsid : '')),
			E('span', { 'style': 'font-size:10px; opacity:0.8; margin-right:4px;' }, isUp ? _('نشط') : _('متوقف'))
		]));
	}

	return E('div', { 'class': 'alemprator-status-badge-wrap' }, badges);
}

function renderStatusPanel(board, lanStatus, wirelessStatus) {
	var ipv4 = '-';
	var addresses = lanStatus && lanStatus['ipv4-address'];

	if (Array.isArray(addresses) && addresses.length) {
		ipv4 = addresses[0].address || '-';

		if (addresses[0].mask != null)
			ipv4 += '/' + addresses[0].mask;
	}

	return E('div', { 'class': 'cbi-section alemprator-card alemprator-status-card' }, [
		E('h3', { 'class': 'alemprator-card__title' }, _('حالة الجهاز')),
		E('div', { 'class': 'alemprator-status-grid' }, [
			renderStatusItem(_('العنوان المحلي'), E('span', ipv4)),
			renderStatusItem(_('الواي فاي'), renderWirelessSummary(wirelessStatus), true)
		]),
		E('div', { 'style': 'margin-top:12px; padding-top:10px; border-top:1px solid #eee; font-size:11px; opacity:0.6; display:flex; gap:15px;' }, [
			E('span', (board && board.model) || (board && board.system) || '-'),
			E('span', (board && board.release && board.release.target) || '-')
		])
	]);
}

function renderWizardCard(title, description, children, isTooltip) {
	var headerChildren = [ E('h4', { 'style': 'margin:0;' }, title) ];
	var bodyChildren = Array.isArray(children) ? children.filter(function(child) { return child != null; }) : [];
	var classes = 'alemprator-card alemprator-card--section';

	if (isTooltip)
		classes += ' alemprator-card--tooltip';

	if (description)
		headerChildren.push(E('p', { 'style': 'margin:6px 0 0 0;' }, description));

	return E('div', { 'class': classes }, [
		E('div', { 'style': 'margin-bottom:12px; padding-bottom:10px; border-bottom:1px solid #e3ebf4;' }, headerChildren),
		E('div', { 'class': 'alemprator-card__body' }, (bodyChildren.length > 0 ? bodyChildren : [ E('span', { 'style': 'display:none;' }) ]))
	]);
}

function normalizeHour(value, fallback) {
	var parsed = parseInt(value, 10);

	if (isNaN(parsed))
		parsed = fallback;

	if (parsed < 0)
		return 0;

	if (parsed > 23)
		return 23;

	return parsed;
}

function formatHour(value) {
	var hour = normalizeHour(value, 0);
	var period = hour < 12 ? _('صباحًا') : _('مساءً');
	var display = hour % 12;

	if (display === 0)
		display = 12;

	return String(display) + ':00 ' + period + ' (' + String(hour) + ':00)';
}

function otaHourChoices() {
	var choices = [];
	var i;

	for (i = 0; i < 24; i++)
		choices.push({ value: String(i), label: formatHour(i) });

	return choices;
}

function describeOtaWindow(startHour, endHour) {
	var start = normalizeHour(startHour, 2);
	var end = normalizeHour(endHour, 6);

	if (start == end)
		return _('التحديث مسموح طوال اليوم.');

	return formatHour(start) + _(' إلى ') + formatHour(end);
}

function summarizeHotspotCard(state) {
	if (!state || !state.hotspotAvailable)
		return _('الحزمة غير مثبتة');

	var isActive = (state.mode === 'hotspot' || state.mode === 'hotspot_quick' || state.hotspotEnabled);

	if (!isActive)
		return _('معطل');

	return (state.hotspotSsid || 'Hotspot') + ' → ' + (state.hotspotRadiusServer || '-');
}

function hotspotIpConflictsWithLan(lanIpaddr, hotspotIp) {
	var lanParts = String(lanIpaddr || '').split('.');
	var hsParts = String(hotspotIp || '').split('.');

	if (lanParts.length !== 4 || hsParts.length !== 4)
		return false;

	return lanParts[0] === hsParts[0] && lanParts[1] === hsParts[1] && lanParts[2] === hsParts[2];
}

function boolText(value) {
	return value ? _('نعم') : _('لا');
}

function enabledText(value) {
	return value ? _('مفعّل') : _('متوقف');
}

function describeFirstbootCleanupState(armed, pending) {
	if (!armed)
		return _('غير مُسلّح');

	if (pending)
		return _('قيد الانتظار');

	return _('جاهز للمراقبة');
}

function describeFirstbootSummary(state) {
	if (!state)
		return '';

	if (state.firstbootEnabled && !state.firstbootInitialSetupComplete)
		return _('firstboot ما زال نشطًا.');

	if (state.firstbootEnabled && state.firstbootAutoCleanupPending)
		return _('يوجد تنظيف مؤجل لبيئة firstboot.');

	if (!state.firstbootEnabled && (state.firstbootConfiguredOnce || state.firstbootInitialSetupComplete))
		return _('firstboot مكتمل.');

	return _('راجع حالة firstboot.');
}

function describeFirstbootSections(state) {
	if (!state)
		return '';

	return 'network=' + state.firstbootNetworkSection + ', wireless=' + state.firstbootWirelessSection + ', dhcp=' + state.firstbootDhcpSection + ', firewall=' + state.firstbootFirewallSection;
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
	uci.set('dhcp', 'lan', 'ignore', '1');
	uci.set('dhcp', 'lan', 'dynamicdhcp', '0');
	uci.set('alemprator_firstboot', 'main', 'enabled', '0');
	uci.set('alemprator_firstboot', 'main', 'configured_once', '1');
	uci.set('alemprator_firstboot', 'main', 'auto_cleanup_armed', '0');
	uci.set('alemprator_firstboot', 'main', 'auto_cleanup_pending', '0');

	return true;
}

return view.extend({
	load: function() {
		return Promise.all([
			L.resolveDefault(callBoard(), {}),
			L.resolveDefault(callLanStatus(), {}),
			L.resolveDefault(callWirelessStatus(), {}),
			L.resolveDefault(uci.load('alemprator_firstboot'), null),
			L.resolveDefault(uci.load('alemprator_ota'), null),
			uci.load('setup'),
			L.resolveDefault(uci.load('hotspot_openwrt'), null),
			L.resolveDefault(uci.load('hotspot_licensing'), null),
			L.resolveDefault(uci.load('chilli'), null),
			L.resolveDefault(uci.load('watchcat'), null),
			uci.load('network'),
			uci.load('wireless'),
			uci.load('dhcp'),
			uci.load('firewall'),
			L.resolveDefault(uci.load('hotspot_openwrt'), null)
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

	setBackupStatus: function(message) {
		var self = this;
		setTextContent(self.refs.backupStatus, message);
		setTextContent(self.refs.backupCardSummary, message);
	},

	downloadConfigBackup: function() {
		var form = E('form', {
			'method': 'post',
			'action': L.env.cgi_base + '/cgi-backup',
			'enctype': 'application/x-www-form-urlencoded',
			'style': 'display:none;'
		}, E('input', {
			'type': 'hidden',
			'name': 'sessionid',
			'value': rpc.getSessionID()
		}));

		document.body.appendChild(form);
		form.submit();
		document.body.removeChild(form);

		self.setBackupStatus(_('تم بدء تنزيل ملف النسخة الاحتياطية.'));
	},

	safeRestoreConfigBackup: function() {
		var self = this;

		self.setBackupStatus(_('جاري رفع ملف النسخة الاحتياطية...'));

		return ui.uploadFile(SAFE_RESTORE_BACKUP_PATH).then(function() {
			self.setBackupStatus(_('تم رفع الملف، جاري فحص الأرشيف...'));

			return fs.exec('/bin/tar', [ '-tzf', SAFE_RESTORE_BACKUP_PATH ]);
		}).then(function(res) {
			if (res.code != 0) {
				self.setBackupStatus(_('فشل فحص ملف النسخة الاحتياطية.'));

				ui.addNotification(null, E('p', _('تعذر قراءة ملف النسخة الاحتياطية. تأكد من اختيار ملف صحيح من الجهاز.')));
				return L.resolveDefault(fs.remove(SAFE_RESTORE_BACKUP_PATH), null);
			}

			var entries = String(res.stdout || '').trim();
			var lines = entries ? entries.split(/\n/) : [];
			var preview = lines.slice(0, 80).join('\n');

			if (lines.length > 80)
				preview += '\n...';

			self.setBackupStatus(_('تم فحص الملف بنجاح. بانتظار تأكيد الاسترجاع.'));

			ui.showModal(_('تأكيد الاسترجاع الآمن'), [
				E('p', _('تم التأكد من أن ملف النسخة الاحتياطية قابل للقراءة. عند المتابعة سيتم استرجاع الإعدادات ثم إعادة تشغيل الجهاز تلقائيًا.')),
				preview ? E('pre', { 'style': 'max-height:220px; overflow:auto; direction:ltr; text-align:left;' }, [ preview ]) : E('p', _('لا توجد قائمة ملفات قابلة للعرض داخل الأرشيف.')),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(self, function() {
							self.setBackupStatus(_('تم إلغاء الاسترجاع الآمن.'));

							return L.resolveDefault(fs.remove(SAFE_RESTORE_BACKUP_PATH), null).finally(ui.hideModal);
						})
					}, [ _('إلغاء') ]),
					' ',
					E('button', {
						'class': 'btn cbi-button-action important',
						'click': ui.createHandlerFn(self, 'confirmSafeRestore')
					}, [ _('متابعة الاسترجاع') ])
				])
			]);
		}).catch(function(err) {
			self.setBackupStatus(_('فشل رفع ملف النسخة الاحتياطية.'));

			ui.addNotification(null, E('p', _('فشل رفع الملف أو التحقق منه: %s').format(err.message || err)));
		});
	},

	confirmSafeRestore: function() {
		var self = this;

		self.setBackupStatus(_('جاري تطبيق النسخة الاحتياطية...'));

		ui.showModal(_('جاري الاسترجاع...'), [
			E('p', { 'class': 'spinning' }, _('يتم الآن استرجاع إعدادات الجهاز ثم إعادة تشغيله. لا تغلق الصفحة حتى تبدأ إعادة التشغيل.'))
		]);

		return fs.exec('/sbin/sysupgrade', [ '--restore-backup', SAFE_RESTORE_BACKUP_PATH ]).then(function(res) {
			if (res.code != 0) {
				ui.addNotification(null, [
					E('p', _('فشل أمر الاسترجاع برمز %d').format(res.code)),
					res.stderr ? E('pre', {}, [ res.stderr ]) : ''
				]);

				throw new Error(_('restore command failed'));
			}

			return fs.exec('/sbin/reboot');
		}).then(function(res) {
			var expectedLan = String(self.state && self.state.lanIpaddr || '').trim();

			if (res.code != 0) {
				ui.addNotification(null, E('p', _('فشل أمر إعادة التشغيل برمز %d').format(res.code)));
				throw new Error(_('reboot command failed'));
			}

			self.setBackupStatus(_('تم بدء إعادة التشغيل لإكمال الاسترجاع.'));

			ui.showModal(_('إعادة تشغيل الجهاز...'), [
				E('p', { 'class': 'spinning' }, _('بدأت إعادة التشغيل. إذا تغيّر عنوان LAN بعد الاسترجاع قد تحتاج للاتصال يدويًا.'))
			]);

			if (isIPv4(expectedLan))
				ui.awaitReconnect(window.location.host, expectedLan, 'openwrt.lan');
			else
				ui.awaitReconnect(window.location.host, 'openwrt.lan');
		}).catch(function(err) {
			self.setBackupStatus(_('تعذر إكمال الاسترجاع الآمن.'));

			ui.hideModal();
			ui.addNotification(null, E('p', _('فشل الاسترجاع الآمن: %s').format(err.message || err)));
		}).finally(function() {
			L.resolveDefault(fs.remove(SAFE_RESTORE_BACKUP_PATH), null);
		});
	},

	syncFormFromState: function() {
		var self = this;
		var radio2g = getRadioByBand(self.radios || [], '2g');
		var radio5g = getRadioByBand(self.radios || [], '5g');

		if (self.refs.lanIpaddr)
			self.refs.lanIpaddr.value = self.state.lanIpaddr || '';

		if (self.refs.lanNetmask)
			self.refs.lanNetmask.value = self.state.lanNetmask || '';

		if (self.refs.mode)
			self.refs.mode.value = self.state.mode || 'ap';

		if (self.refs.wifiSsid)
			self.refs.wifiSsid.value = self.state.wifiSsid || '';

		if (self.refs.wifiSsid5gMode)
			self.refs.wifiSsid5gMode.value = self.state.wifiSsid5gMode || 'derived';

		if (self.refs.wifiSsid5g)
			self.refs.wifiSsid5g.value = self.state.wifiSsid5g || '';

		if (self.refs.wifiSsidVlan2g)
			self.refs.wifiSsidVlan2g.value = self.state.wifiSsidVlan2g || '';

		if (self.refs.wifiSsidVlan5g)
			self.refs.wifiSsidVlan5g.value = self.state.wifiSsidVlan5g || '';

		if (self.refs.wifiSsidIpSuffixPrimary)
			self.refs.wifiSsidIpSuffixPrimary.checked = !!self.state.wifiSsidVlanIpSuffix;

		if (self.refs.wifiSsidVlanIpSuffix)
			self.refs.wifiSsidVlanIpSuffix.checked = !!self.state.wifiSsidVlanIpSuffix;

		if (self.refs.wifiKey)
			self.refs.wifiKey.value = self.state.wifiKey || '';

		if (self.refs.uplinkSsid)
			self.refs.uplinkSsid.value = self.state.uplinkSsid || '';

		if (self.refs.uplinkKey)
			self.refs.uplinkKey.value = self.state.uplinkKey || '';

		if (self.refs.uplinkBand)
			self.refs.uplinkBand.value = self.state.uplinkBand || '2g';

		if (self.refs.meshId)
			self.refs.meshId.value = self.state.meshId || '';

		if (self.refs.meshKey)
			self.refs.meshKey.value = self.state.meshKey || '';

		if (self.refs.meshBand)
			self.refs.meshBand.value = self.state.meshBand || '2g';

		if (self.refs.isVlan)
			self.refs.isVlan.checked = !!self.state.isVlan;

		if (self.refs.vlanId)
			self.refs.vlanId.value = self.state.vlanId || '10';

		if (self.refs.channel2g && radio2g) {
			populateSelectOptions(
				self.refs.channel2g,
				channelChoices('2g', self.frequencyMap ? self.frequencyMap[radio2g['.name']] : null),
				self.state.channel2g
			);
		}

		if (self.refs.channel5g && radio5g) {
			populateSelectOptions(
				self.refs.channel5g,
				channelChoices('5g', self.frequencyMap ? self.frequencyMap[radio5g['.name']] : null),
				self.state.channel5g
			);
		}

		/* Keep step-3 radio mode/width selects aligned with freshly loaded state. */
		self.syncRadioModeWidthUi();

		if (self.refs.resetDisabled)
			self.refs.resetDisabled.checked = !!self.state.resetDisabled;

		if (self.refs.resetHoldSeconds)
			self.refs.resetHoldSeconds.value = self.state.resetHoldSeconds || '5';

		if (self.refs.wpsDisabled)
			self.refs.wpsDisabled.checked = !!self.state.wpsDisabled;

		if (self.refs.rebootEnabled)
			self.refs.rebootEnabled.checked = !!self.state.rebootEnabled;

		if (self.refs.rebootHours)
			self.refs.rebootHours.value = self.state.rebootHours || '24';

		if (self.refs.otaWindowStart)
			self.refs.otaWindowStart.value = String(self.state.otaWindowStart == null ? 2 : self.state.otaWindowStart);

		if (self.refs.otaWindowEnd)
			self.refs.otaWindowEnd.value = String(self.state.otaWindowEnd == null ? 6 : self.state.otaWindowEnd);

		if (self.refs.hotspotQuickEnabled)
			self.refs.hotspotQuickEnabled.checked = !!(self.state || {}).hotspotQuickEnabled;

		if (self.refs.hotspotQuickWanInterface)
			self.refs.hotspotQuickWanInterface.value = self.state.hotspotQuickWanInterface || 'lan';

		if (self.refs.hotspotQuickSubscriberInterface)
			self.refs.hotspotQuickSubscriberInterface.value = self.state.hotspotQuickSubscriberInterface || 'hotspot';

		if (self.refs.hotspotQuickSsid1)
			self.refs.hotspotQuickSsid1.value = self.state.hotspotQuickSsid1 || 'Hotspot-1';

		if (self.refs.hotspotQuickGateway1)
			self.refs.hotspotQuickGateway1.value = self.state.hotspotQuickGateway1 || '192.168.10.1';

		if (self.refs.hotspotQuickPoolStart1)
			self.refs.hotspotQuickPoolStart1.value = self.state.hotspotQuickPoolStart1 || '192.168.10.10';

		if (self.refs.hotspotQuickPoolEnd1)
			self.refs.hotspotQuickPoolEnd1.value = self.state.hotspotQuickPoolEnd1 || '192.168.10.199';

		if (self.refs.hotspotQuickPolicy1)
			self.refs.hotspotQuickPolicy1.value = self.state.hotspotQuickPolicy1 || 'standard';

		if (self.refs.hotspotQuickSecondaryEnabled)
			self.refs.hotspotQuickSecondaryEnabled.checked = self.state.hotspotQuickSecondaryEnabled !== false;

		if (self.refs.hotspotQuickSsid2)
			self.refs.hotspotQuickSsid2.value = self.state.hotspotQuickSsid2 || 'Hotspot-2';

		if (self.refs.hotspotQuickGateway2)
			self.refs.hotspotQuickGateway2.value = self.state.hotspotQuickGateway2 || '192.168.20.1';

		if (self.refs.hotspotQuickPoolStart2)
			self.refs.hotspotQuickPoolStart2.value = self.state.hotspotQuickPoolStart2 || '192.168.20.10';

		if (self.refs.hotspotQuickPoolEnd2)
			self.refs.hotspotQuickPoolEnd2.value = self.state.hotspotQuickPoolEnd2 || '192.168.20.199';

		if (self.refs.hotspotQuickPolicy2)
			self.refs.hotspotQuickPolicy2.value = self.state.hotspotQuickPolicy2 || 'premium';

		if (self.refs.hotspotQuickRadiusServer)
			self.refs.hotspotQuickRadiusServer.value = self.state.hotspotQuickRadiusServer || '192.168.1.2';

		if (self.refs.hotspotQuickRadiusServer2)
			self.refs.hotspotQuickRadiusServer2.value = self.state.hotspotQuickRadiusServer2 || '';

		if (self.refs.hotspotQuickRadiusSecret)
			self.refs.hotspotQuickRadiusSecret.value = self.state.hotspotQuickRadiusSecret || '';

		if (self.refs.hotspotQuickRadiusAuthPort)
			self.refs.hotspotQuickRadiusAuthPort.value = self.state.hotspotQuickRadiusAuthPort || '1812';

		if (self.refs.hotspotQuickRadiusAcctPort)
			self.refs.hotspotQuickRadiusAcctPort.value = self.state.hotspotQuickRadiusAcctPort || '1813';

		if (self.refs.hotspotQuickRadiusNasIp)
			self.refs.hotspotQuickRadiusNasIp.value = self.state.hotspotQuickRadiusNasIp || '';

		if (self.refs.hotspotQuickAcctInterim)
			self.refs.hotspotQuickAcctInterim.value = self.state.hotspotQuickAcctInterim || '60';

		if (self.refs.hotspotQuickCoaEnabled)
			self.refs.hotspotQuickCoaEnabled.checked = !!self.state.hotspotQuickCoaEnabled;

		if (self.refs.hotspotQuickCoaPort)
			self.refs.hotspotQuickCoaPort.value = self.state.hotspotQuickCoaPort || '3799';

		if (self.refs.hotspotQuickTrialEnabled)
			self.refs.hotspotQuickTrialEnabled.checked = !!self.state.hotspotQuickTrialEnabled;

		if (self.refs.hotspotQuickTrialDuration)
			self.refs.hotspotQuickTrialDuration.value = self.state.hotspotQuickTrialDuration || '30';

		if (self.refs.hotspotQuickTrialUptimeLimit)
			self.refs.hotspotQuickTrialUptimeLimit.value = self.state.hotspotQuickTrialUptimeLimit || '30';

		if (self.refs.hotspotQuickMacAuthEnabled)
			self.refs.hotspotQuickMacAuthEnabled.checked = !!self.state.hotspotQuickMacAuthEnabled;

		if (self.refs.hotspotQuickMacAuthSuffix)
			self.refs.hotspotQuickMacAuthSuffix.value = self.state.hotspotQuickMacAuthSuffix || '@mac';

		if (self.refs.hotspotQuickMacAuthPassword)
			self.refs.hotspotQuickMacAuthPassword.value = self.state.hotspotQuickMacAuthPassword || 'mac';

		if (self.refs.hotspotQuickWalledGarden)
			self.refs.hotspotQuickWalledGarden.value = self.state.hotspotQuickWalledGarden || '';

		if (self.refs.hotspotQuickDomain)
			self.refs.hotspotQuickDomain.value = self.state.hotspotQuickDomain || 'hotspot.local';

		if (self.refs.hotspotQuickDns1)
			self.refs.hotspotQuickDns1.value = self.state.hotspotQuickDns1 || '8.8.8.8';

		if (self.refs.hotspotQuickDns2)
			self.refs.hotspotQuickDns2.value = self.state.hotspotQuickDns2 || '82.114.163.31';

		if (self.refs.hotspotQuickBridgeAgeingTime)
			self.refs.hotspotQuickBridgeAgeingTime.value = self.state.hotspotQuickBridgeAgeingTime || '10';

		if (self.refs.hotspotQuickLoginMode)
			self.refs.hotspotQuickLoginMode.value = self.state.hotspotQuickLoginMode || 'standard';

		if (self.refs.hotspotQuickRateLimit)
			self.refs.hotspotQuickRateLimit.value = self.state.hotspotQuickRateLimit || '2M/5M';

		if (self.refs.hotspotQuickMacCookieEnabled)
			self.refs.hotspotQuickMacCookieEnabled.checked = !!self.state.hotspotQuickMacCookieEnabled;

		if (self.refs.hotspotQuickAvailableSpeeds)
			self.refs.hotspotQuickAvailableSpeeds.value = self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast';

		if (self.refs.hotspotQuickSupportPhone)
			self.refs.hotspotQuickSupportPhone.value = self.state.hotspotQuickSupportPhone || '';

		if (self.refs.hotspotQuickNoticeText)
			self.refs.hotspotQuickNoticeText.value = self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا';

		if (self.refs.hotspotQuickLiveStreamEnabled)
			self.refs.hotspotQuickLiveStreamEnabled.checked = !!self.state.hotspotQuickLiveStreamEnabled;

		if (self.refs.hotspotQuickLiveStreamUrl)
			self.refs.hotspotQuickLiveStreamUrl.value = self.state.hotspotQuickLiveStreamUrl || '';

		if (self.refs.hotspotQuickRestAreaEnabled)
			self.refs.hotspotQuickRestAreaEnabled.checked = !!self.state.hotspotQuickRestAreaEnabled;

		if (self.refs.hotspotQuickRestAreaUrl)
			self.refs.hotspotQuickRestAreaUrl.value = self.state.hotspotQuickRestAreaUrl || '';

		if (self.refs.hotspotQuickSpeedtestEnabled)
			self.refs.hotspotQuickSpeedtestEnabled.checked = !!self.state.hotspotQuickSpeedtestEnabled;

		if (self.refs.hotspotQuickBrowserCookieEnabled)
			self.refs.hotspotQuickBrowserCookieEnabled.checked = self.state.hotspotQuickBrowserCookieEnabled !== false;

		if (self.refs.hotspotQuickBrowserCookieDays)
			self.refs.hotspotQuickBrowserCookieDays.value = self.state.hotspotQuickBrowserCookieDays || '7';

		if (self.refs.hotspotQuickUsermanRestEnabled)
			self.refs.hotspotQuickUsermanRestEnabled.checked = !!self.state.hotspotQuickUsermanRestEnabled;

		if (self.refs.hotspotQuickUsermanRestScheme)
			self.refs.hotspotQuickUsermanRestScheme.value = self.state.hotspotQuickUsermanRestScheme || 'http';

		if (self.refs.hotspotQuickUsermanRestUsername)
			self.refs.hotspotQuickUsermanRestUsername.value = self.state.hotspotQuickUsermanRestUsername || 'hotspot-read';

		if (self.refs.hotspotQuickUsermanRestPassword)
			self.refs.hotspotQuickUsermanRestPassword.value = self.state.hotspotQuickUsermanRestPassword || '';

			self.refs.hotspotQuickRadiusServer.value = self.state.hotspotQuickRadiusServer || '192.168.1.2';

		if (self.refs.hotspotQuickRadiusServer2)
			self.refs.hotspotQuickRadiusServer2.value = self.state.hotspotQuickRadiusServer2 || '';

		if (self.refs.hotspotQuickRadiusSecret)
			self.refs.hotspotQuickRadiusSecret.value = self.state.hotspotQuickRadiusSecret || '';

		if (self.refs.hotspotQuickRadiusAuthPort)
			self.refs.hotspotQuickRadiusAuthPort.value = self.state.hotspotQuickRadiusAuthPort || '1812';

		if (self.refs.hotspotQuickRadiusAcctPort)
			self.refs.hotspotQuickRadiusAcctPort.value = self.state.hotspotQuickRadiusAcctPort || '1813';

		if (self.refs.hotspotQuickRadiusNasIp)
			self.refs.hotspotQuickRadiusNasIp.value = self.state.hotspotQuickRadiusNasIp || '';

		if (self.refs.hotspotQuickNasId)
			self.refs.hotspotQuickNasId.value = self.state.hotspotQuickNasId || '';

		if (self.refs.hotspotQuickAcctInterim)
			self.refs.hotspotQuickAcctInterim.value = self.state.hotspotQuickAcctInterim || '60';

		if (self.refs.hotspotQuickCoaEnabled)
			self.refs.hotspotQuickCoaEnabled.checked = !!self.state.hotspotQuickCoaEnabled;

		if (self.refs.hotspotQuickCoaPort)
			self.refs.hotspotQuickCoaPort.value = self.state.hotspotQuickCoaPort || '3799';

		if (self.refs.hotspotQuickTrialEnabled)
			self.refs.hotspotQuickTrialEnabled.checked = !!self.state.hotspotQuickTrialEnabled;

		if (self.refs.hotspotQuickTrialDuration)
			self.refs.hotspotQuickTrialDuration.value = self.state.hotspotQuickTrialDuration || '30';

		if (self.refs.hotspotQuickTrialUptimeLimit)
			self.refs.hotspotQuickTrialUptimeLimit.value = self.state.hotspotQuickTrialUptimeLimit || '30';

		if (self.refs.hotspotQuickMacAuthEnabled)
			self.refs.hotspotQuickMacAuthEnabled.checked = !!self.state.hotspotQuickMacAuthEnabled;

		if (self.refs.hotspotQuickMacAuthSuffix)
			self.refs.hotspotQuickMacAuthSuffix.value = self.state.hotspotQuickMacAuthSuffix || '@mac';

		if (self.refs.hotspotQuickMacAuthPassword)
			self.refs.hotspotQuickMacAuthPassword.value = self.state.hotspotQuickMacAuthPassword || 'mac';

		if (self.refs.hotspotQuickWalledGarden)
			self.refs.hotspotQuickWalledGarden.value = self.state.hotspotQuickWalledGarden || '';

		if (self.refs.hotspotQuickDomain)
			self.refs.hotspotQuickDomain.value = self.state.hotspotQuickDomain || 'hotspot.local';

		if (self.refs.hotspotQuickDns1)
			self.refs.hotspotQuickDns1.value = self.state.hotspotQuickDns1 || '8.8.8.8';

		if (self.refs.hotspotQuickDns2)
			self.refs.hotspotQuickDns2.value = self.state.hotspotQuickDns2 || '82.114.163.31';

		if (self.refs.hotspotQuickBridgeAgeingTime)
			self.refs.hotspotQuickBridgeAgeingTime.value = self.state.hotspotQuickBridgeAgeingTime || '10';

		if (self.refs.hotspotQuickLoginMode)
			self.refs.hotspotQuickLoginMode.value = normalizeHotspotLoginMode(self.state.hotspotQuickLoginMode);

		if (self.refs.hotspotQuickRateLimit)
			self.refs.hotspotQuickRateLimit.value = self.state.hotspotQuickRateLimit || '2M/5M';

		if (self.refs.hotspotQuickMacCookieEnabled)
			self.refs.hotspotQuickMacCookieEnabled.checked = !!self.state.hotspotQuickMacCookieEnabled;

		if (self.refs.hotspotQuickAvailableSpeeds)
			self.refs.hotspotQuickAvailableSpeeds.value = self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast';

		if (self.refs.hotspotQuickSupportPhone)
			self.refs.hotspotQuickSupportPhone.value = self.state.hotspotQuickSupportPhone || '';

		if (self.refs.hotspotQuickNoticeText)
			self.refs.hotspotQuickNoticeText.value = self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا';

		if (self.refs.hotspotQuickLiveStreamEnabled)
			self.refs.hotspotQuickLiveStreamEnabled.checked = !!self.state.hotspotQuickLiveStreamEnabled;

		if (self.refs.hotspotQuickLiveStreamUrl)
			self.refs.hotspotQuickLiveStreamUrl.value = self.state.hotspotQuickLiveStreamUrl || '';

		if (self.refs.hotspotQuickRestAreaEnabled)
			self.refs.hotspotQuickRestAreaEnabled.checked = !!self.state.hotspotQuickRestAreaEnabled;

		if (self.refs.hotspotQuickRestAreaUrl)
			self.refs.hotspotQuickRestAreaUrl.value = self.state.hotspotQuickRestAreaUrl || '';

		if (self.refs.hotspotQuickSpeedtestEnabled)
			self.refs.hotspotQuickSpeedtestEnabled.checked = !!self.state.hotspotQuickSpeedtestEnabled;

		if (self.refs.hotspotQuickBrowserCookieEnabled)
			self.refs.hotspotQuickBrowserCookieEnabled.checked = self.state.hotspotQuickBrowserCookieEnabled !== false;

		if (self.refs.hotspotQuickBrowserCookieDays)
			self.refs.hotspotQuickBrowserCookieDays.value = normalizeBrowserCookieDays(self.state.hotspotQuickBrowserCookieDays || '7');

		if (self.refs.hotspotQuickUsermanRestEnabled)
			self.refs.hotspotQuickUsermanRestEnabled.checked = !!self.state.hotspotQuickUsermanRestEnabled;

		if (self.refs.hotspotQuickUsermanRestScheme)
			self.refs.hotspotQuickUsermanRestScheme.value = normalizeRouterOsScheme(self.state.hotspotQuickUsermanRestScheme);

		if (self.refs.hotspotQuickUsermanRestUsername)
			self.refs.hotspotQuickUsermanRestUsername.value = self.state.hotspotQuickUsermanRestUsername || 'hotspot-read';

		if (self.refs.hotspotQuickUsermanRestPassword)
			self.refs.hotspotQuickUsermanRestPassword.value = self.state.hotspotQuickUsermanRestPassword || '';

		if (self.refs.adminPassword)
			self.refs.adminPassword.value = '';

		if (self.refs.adminPasswordConfirm)
			self.refs.adminPasswordConfirm.value = '';

		if (self.refs.hotspotEnabled)
			self.refs.hotspotEnabled.checked = !!self.state.hotspotEnabled;

		if (self.refs.hotspotSsid)
			self.refs.hotspotSsid.value = self.state.hotspotSsid || 'Hotspot';

		if (self.refs.hotspotRadiusServer)
			self.refs.hotspotRadiusServer.value = self.state.hotspotRadiusServer || '192.168.1.2';

		if (self.refs.hotspotRadiusSecret)
			self.refs.hotspotRadiusSecret.value = self.state.hotspotRadiusSecret || '';

		if (self.refs.hotspotNasId)
			self.refs.hotspotNasId.value = self.state.hotspotNasId || '';

		if (self.refs.hotspotIp)
			self.refs.hotspotIp.value = self.state.hotspotIp || '192.168.10.1';

		if (self.refs.hotspotPoolStart)
			self.refs.hotspotPoolStart.value = self.state.hotspotPoolStart || '192.168.10.10';

		if (self.refs.hotspotPoolEnd)
			self.refs.hotspotPoolEnd.value = self.state.hotspotPoolEnd || '192.168.10.254';
	},

	reloadStateFromDevice: function() {
		var self = this;
		var configs = [ 'alemprator_firstboot', 'alemprator_ota', 'setup', 'watchcat', 'network', 'wireless', 'hotspot_openwrt', 'hotspot_licensing' ];

		if (!window.confirm(_('سيتم استبدال القيم الحالية داخل المعالج بإعدادات الجهاز الفعلية. هل تريد المتابعة؟')))
			return Promise.resolve();

		if (self.refs.reloadButton) {
			self.refs.reloadButton.disabled = true;
			self.refs.reloadButton.textContent = _('جارٍ التحديث...');
		}

		if (typeof uci.unload == 'function') {
			configs.forEach(function(conf) {
				uci.unload(conf);
			});
		}

		return Promise.all([
			L.resolveDefault(callLanStatus(), {}),
			L.resolveDefault(uci.load('alemprator_firstboot'), null),
			L.resolveDefault(uci.load('alemprator_ota'), null),
			uci.load('setup'),
			L.resolveDefault(uci.load('hotspot_openwrt'), null),
			L.resolveDefault(uci.load('hotspot_licensing'), null),
			L.resolveDefault(uci.load('chilli'), null),
			L.resolveDefault(uci.load('watchcat'), null),
			uci.load('network'),
			uci.load('wireless'),
			L.resolveDefault(uci.load('hotspot_openwrt'), null)
		]).then(function(results) {
			var radios = uci.sections('wireless', 'wifi-device');

			return Promise.all(radios.map(function(radio) {
				return L.resolveDefault(callFrequencyList(radio['.name']), []);
			})).then(function(freqLists) {
				var frequencyMap = {};

				radios.forEach(function(radio, index) {
					frequencyMap[radio['.name']] = freqLists[index] || [];
				});

				self.radios = radios;
				self.frequencyMap = frequencyMap;
				self.state = self.readState(radios, results[0]);
				self.syncFormFromState();
				self.updateStepUi();

				if (self.statusContainer)
					return self.renderStatus(self.statusContainer);

				return null;
			});
		}).then(function() {
			notify(_('تم تحديث قيم المعالج من إعدادات الجهاز الحالية.'));
		}).catch(function(err) {
			notify(_('تعذر تحديث قيم المعالج من الجهاز.') + ' ' + (err || ''));
		}).finally(function() {
			if (self.refs.reloadButton) {
				self.refs.reloadButton.disabled = false;
				self.refs.reloadButton.textContent = _('تحديث القيم من الجهاز');
			}
		});
	},

	readState: function(radios, lanStatus) {
		var radio2g = getRadioByBand(radios, '2g');
		var radio5g = getRadioByBand(radios, '5g');
		var htmode2g = radio2g ? (uci.get('wireless', radio2g['.name'], 'htmode') || '') : '';
		var htmode5g = radio5g ? (uci.get('wireless', radio5g['.name'], 'htmode') || '') : '';
		var lanRuntime = parseLanRuntimeState(lanStatus);
		var firstbootEnabled = uci.get('alemprator_firstboot', 'main', 'enabled') == '1';
		var firstbootConfiguredOnce = uci.get('alemprator_firstboot', 'main', 'configured_once') == '1';
		var firstbootAutoCleanupArmed = uci.get('alemprator_firstboot', 'main', 'auto_cleanup_armed') == '1';
		var firstbootAutoCleanupPending = uci.get('alemprator_firstboot', 'main', 'auto_cleanup_pending') == '1';
		var firstbootInitialSetupComplete = uci.get('setup', 'default', 'initial_setup_complete') == '1';
		var firstbootNetworkSection = uci.get('alemprator_firstboot', 'main', 'network_section') || FIRSTBOOT_DEFAULT_NETWORK;
		var firstbootWirelessSection = uci.get('alemprator_firstboot', 'main', 'wireless_section') || FIRSTBOOT_DEFAULT_WIRELESS;
		var firstbootDhcpSection = uci.get('alemprator_firstboot', 'main', 'dhcp_section') || firstbootNetworkSection;
		var firstbootFirewallSection = uci.get('alemprator_firstboot', 'main', 'firewall_section') || firstbootNetworkSection;
		var firstbootLanIpaddr = uci.get('alemprator_firstboot', 'main', 'lan_ipaddr') || '';
		var firstbootLanNetmask = uci.get('alemprator_firstboot', 'main', 'lan_netmask') || '';
		var apIface2g = findApIfaceSection(radio2g ? radio2g['.name'] : null, 'lan');
		var apIface5g = findApIfaceSection(radio5g ? radio5g['.name'] : null, 'lan');
		var uplinkIface = findUplinkIfaceSection();
		var meshIface = findMeshIfaceSection();
		var mode = inferCurrentMode();
		var baseSsid = '';
		var key = '';
		var rebootSection = getPeriodicRebootSection();
		var rebootHours = rebootSection ? parseHours(rebootSection.period) : null;
		var otaConfig = uci.get('alemprator_ota', 'main');
		var otaWindowStart = otaConfig ? normalizeHour(uci.get('alemprator_ota', 'main', 'window_start'), 2) : null;
		var otaWindowEnd = otaConfig ? normalizeHour(uci.get('alemprator_ota', 'main', 'window_end'), 6) : null;
		var lanIpaddr = lanRuntime.ipaddr || uci.get('network', 'lan', 'ipaddr') || (firstbootEnabled ? firstbootLanIpaddr : '') || uci.get('setup', 'default', 'lan_ipaddr') || '192.168.1.1';
		var wifiSsidIpSuffixState = {
			lanIpaddr: lanIpaddr,
			wifiSsidVlanIpSuffix: uci.get('setup', 'default', 'wifi_ssid_vlan_ip_suffix') == '1'
		};
		var ssid5gActual = apIface5g ? String(apIface5g.ssid || '').trim() : '';
		var ssid5gDerived;
		var ssid5gMode = 'derived';
		var ssid5gValue = '';
		var isVlanEnabled = inferVlanEnabled();
		var secondarySsids;
		var secondary2g = '';
		var secondary5g = '';
		var inferredMode2g = inferWifiModeFromHtmode('2g', htmode2g);
		var inferredMode5g = inferWifiModeFromHtmode('5g', htmode5g);
		var inferredWidth2g = inferWifiWidthFromHtmode('2g', htmode2g);
		var inferredWidth5g = inferWifiWidthFromHtmode('5g', htmode5g);
		var hasPrimaryApIface = !!(apIface2g || apIface5g);
		var hasVlanApIface = !!(findSecondaryApIfaceSection(radios, '2g') || findSecondaryApIfaceSection(radios, '5g'));
		var hotspotQuickEnabled = uci.get('setup', 'default', 'hotspot_quick_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'quick_setup_enabled') == '1';
		var hotspotQuickWanInterface = normalizeInterfaceName(uci.get('setup', 'default', 'hotspot_quick_wan_interface') || uci.get('hotspot_openwrt', 'main', 'wan_interface') || 'wan', 'wan');
		var hotspotQuickSubscriberInterface = normalizeInterfaceName(uci.get('setup', 'default', 'hotspot_quick_subscriber_interface') || uci.get('hotspot_openwrt', 'main', 'subscriber_interface') || 'hotspot', 'hotspot');
		var hotspotQuickSsid1 = String(uci.get('setup', 'default', 'hotspot_quick_ssid_1') || uci.get('hotspot_openwrt', 'main', 'quick_ssid_primary') || 'Hotspot-1').trim();
		var hotspotQuickGateway1 = String(uci.get('setup', 'default', 'hotspot_quick_gateway_1') || uci.get('hotspot_openwrt', 'main', 'quick_gateway_primary') || uci.get('hotspot_openwrt', 'main', 'hotspot_ip') || '192.168.10.1').trim();
		var hotspotQuickPoolStart1 = String(uci.get('setup', 'default', 'hotspot_quick_pool_start_1') || uci.get('hotspot_openwrt', 'main', 'quick_pool_start_primary') || uci.get('hotspot_openwrt', 'main', 'pool_start') || '192.168.10.10').trim();
		var hotspotQuickPoolEnd1 = String(uci.get('setup', 'default', 'hotspot_quick_pool_end_1') || uci.get('hotspot_openwrt', 'main', 'quick_pool_end_primary') || uci.get('hotspot_openwrt', 'main', 'pool_end') || '192.168.10.199').trim();
		var hotspotQuickPolicy1 = normalizeHotspotPolicy(uci.get('setup', 'default', 'hotspot_quick_policy_1') || uci.get('hotspot_openwrt', 'main', 'quick_policy_primary'), 'standard');
		var hotspotQuickSecondaryEnabled = uci.get('setup', 'default', 'hotspot_quick_secondary_enabled') != '0' && uci.get('hotspot_openwrt', 'main', 'quick_runtime_dual_enabled') != '0';
		var hotspotQuickSsid2 = String(uci.get('setup', 'default', 'hotspot_quick_ssid_2') || uci.get('hotspot_openwrt', 'main', 'quick_ssid_secondary') || 'Hotspot-2').trim();
		var hotspotQuickGateway2 = String(uci.get('setup', 'default', 'hotspot_quick_gateway_2') || uci.get('hotspot_openwrt', 'main', 'quick_gateway_secondary') || '192.168.20.1').trim();
		var hotspotQuickPoolStart2 = String(uci.get('setup', 'default', 'hotspot_quick_pool_start_2') || uci.get('hotspot_openwrt', 'main', 'quick_pool_start_secondary') || '192.168.20.10').trim();
		var hotspotQuickPoolEnd2 = String(uci.get('setup', 'default', 'hotspot_quick_pool_end_2') || uci.get('hotspot_openwrt', 'main', 'quick_pool_end_secondary') || '192.168.20.199').trim();
		var hotspotQuickPolicy2 = normalizeHotspotPolicy(uci.get('setup', 'default', 'hotspot_quick_policy_2') || uci.get('hotspot_openwrt', 'main', 'quick_policy_secondary'), 'premium');
		var hotspotQuickRadiusServer = String(uci.get('setup', 'default', 'hotspot_quick_radius_server') || uci.get('hotspot_openwrt', 'main', 'radius_server') || '192.168.1.2').trim();
		var hotspotQuickRadiusServer2 = String(uci.get('setup', 'default', 'hotspot_quick_radius_server2') || uci.get('hotspot_openwrt', 'main', 'radius_server2') || '').trim();
		var hotspotQuickRadiusSecret = uci.get('setup', 'default', 'hotspot_quick_radius_secret') || uci.get('hotspot_openwrt', 'main', 'radius_secret') || '';
		var hotspotQuickRadiusAuthPort = normalizePort(uci.get('setup', 'default', 'hotspot_quick_radius_auth_port') || uci.get('hotspot_openwrt', 'main', 'radius_auth_port'), '1812');
		var hotspotQuickRadiusAcctPort = normalizePort(uci.get('setup', 'default', 'hotspot_quick_radius_acct_port') || uci.get('hotspot_openwrt', 'main', 'radius_acct_port'), '1813');
		var hotspotQuickRadiusNasIp = String(uci.get('setup', 'default', 'hotspot_quick_radius_nas_ip') || uci.get('hotspot_openwrt', 'main', 'radius_nas_ip') || '').trim();
		var hotspotQuickNasId = deriveHotspotQuickNasId(uci.get('setup', 'default', 'hotspot_quick_nas_id') || uci.get('hotspot_openwrt', 'main', 'radius_nas_id') || '', lanIpaddr);
		var hotspotQuickAcctInterim = normalizePositiveNumber(uci.get('setup', 'default', 'hotspot_quick_acct_interim') || uci.get('hotspot_openwrt', 'main', 'acct_interim'), '60');
		var hotspotQuickCoaEnabled = uci.get('setup', 'default', 'hotspot_quick_coa_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'coa_enabled') == '1';
		var hotspotQuickCoaPort = normalizePort(uci.get('setup', 'default', 'hotspot_quick_coa_port') || uci.get('hotspot_openwrt', 'main', 'coa_port'), '3799');
		var hotspotQuickTrialEnabled = uci.get('setup', 'default', 'hotspot_quick_trial_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'trial_enabled') == '1';
		var hotspotQuickTrialDuration = normalizePositiveNumber(uci.get('setup', 'default', 'hotspot_quick_trial_duration') || uci.get('hotspot_openwrt', 'main', 'trial_duration'), '30');
		var hotspotQuickTrialUptimeLimit = normalizePositiveNumber(uci.get('setup', 'default', 'hotspot_quick_trial_uptime_limit') || uci.get('hotspot_openwrt', 'main', 'trial_uptime_limit'), '30');
		var hotspotQuickMacAuthEnabled = uci.get('setup', 'default', 'hotspot_quick_mac_auth_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'mac_auth_enabled') == '1';
		var hotspotQuickMacAuthSuffix = String(uci.get('setup', 'default', 'hotspot_quick_mac_auth_suffix') || uci.get('hotspot_openwrt', 'main', 'mac_auth_suffix') || '@mac').trim();
		var hotspotQuickMacAuthPassword = uci.get('setup', 'default', 'hotspot_quick_mac_auth_password') || uci.get('hotspot_openwrt', 'main', 'mac_auth_password') || 'mac';
		var hotspotQuickWalledGarden = quickListText(uci.get('setup', 'default', 'hotspot_quick_walled_garden') || uci.get('hotspot_openwrt', 'main', 'walled_garden') || '');
		var hotspotQuickDomain = String(uci.get('setup', 'default', 'hotspot_quick_domain') || uci.get('hotspot_openwrt', 'main', 'domain') || 'hotspot.local').trim();
		var hotspotQuickDnsList = uci.get('hotspot_openwrt', 'main', 'dns') || [];
		var hotspotQuickDns1 = String(uci.get('setup', 'default', 'hotspot_quick_dns1') || hotspotQuickDnsList[0] || '8.8.8.8').trim();
		var hotspotQuickDns2 = String(uci.get('setup', 'default', 'hotspot_quick_dns2') || hotspotQuickDnsList[1] || '82.114.163.31').trim();
		var hotspotQuickBridgeAgeingTime = normalizePositiveNumber(uci.get('setup', 'default', 'hotspot_quick_bridge_ageing_time') || uci.get('hotspot_openwrt', 'main', 'bridge_ageing_time'), '10');
		var hotspotQuickLoginMode = normalizeHotspotLoginMode(uci.get('setup', 'default', 'hotspot_quick_login_mode') || uci.get('hotspot_openwrt', 'main', 'login_mode'));
		var hotspotQuickRateLimit = String(uci.get('setup', 'default', 'hotspot_quick_rate_limit') || uci.get('hotspot_openwrt', 'main', 'rate_limit_rx_tx') || '2M/5M').trim();
		var hotspotQuickMacCookieEnabled = uci.get('setup', 'default', 'hotspot_quick_mac_cookie_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'mac_cookie_enabled') == '1';
		var hotspotQuickAvailableSpeeds = normalizeSpeedOptionsText(uci.get('setup', 'default', 'hotspot_quick_available_speeds') || uci.get('hotspot_openwrt', 'main', 'available_speeds') || '1M/2M Standard\n2M/4M Fast');
		var hotspotQuickSupportPhone = String(uci.get('setup', 'default', 'hotspot_quick_support_phone') || uci.get('hotspot_openwrt', 'main', 'support_phone') || '').trim();
		var hotspotQuickNoticeText = String(uci.get('setup', 'default', 'hotspot_quick_notice_text') || uci.get('hotspot_openwrt', 'main', 'notice_text') || 'أهلاً بكم في شبكتنا').trim();
		var hotspotQuickLiveStreamEnabled = uci.get('setup', 'default', 'hotspot_quick_live_stream_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'live_stream_enabled') == '1';
		var hotspotQuickLiveStreamUrl = String(uci.get('setup', 'default', 'hotspot_quick_live_stream_url') || uci.get('hotspot_openwrt', 'main', 'live_stream_url') || '').trim();
		var hotspotQuickRestAreaEnabled = uci.get('setup', 'default', 'hotspot_quick_rest_area_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'rest_area_enabled') == '1';
		var hotspotQuickRestAreaUrl = String(uci.get('setup', 'default', 'hotspot_quick_rest_area_url') || uci.get('hotspot_openwrt', 'main', 'rest_area_url') || '').trim();
		var hotspotQuickSpeedtestEnabled = uci.get('setup', 'default', 'hotspot_quick_speedtest_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'speedtest_enabled') == '1';
		var hotspotQuickMaintEnabled = uci.get('setup', 'default', 'hotspot_quick_maint_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'maint_enabled') == '1';
		var hotspotQuickMaintStart = uci.get('setup', 'default', 'hotspot_quick_maint_start') || uci.get('hotspot_openwrt', 'main', 'maint_start') || '02:00';
		var hotspotQuickMaintEnd = uci.get('setup', 'default', 'hotspot_quick_maint_end') || uci.get('hotspot_openwrt', 'main', 'maint_end') || '03:00';
		var hotspotQuickMaintMode = uci.get('setup', 'default', 'hotspot_quick_maint_mode') || uci.get('hotspot_openwrt', 'main', 'maint_mode') || 'free';
		var hotspotQuickBrowserCookieEnabled = uci.get('setup', 'default', 'hotspot_quick_browser_cookie_enabled') != '0' && uci.get('hotspot_openwrt', 'main', 'browser_cookie_enabled') != '0';
		var hotspotQuickBrowserCookieDays = normalizeBrowserCookieDays(uci.get('setup', 'default', 'hotspot_quick_browser_cookie_days') || uci.get('hotspot_openwrt', 'main', 'browser_cookie_days') || '7');
		var hotspotQuickUsermanRestEnabled = uci.get('setup', 'default', 'hotspot_quick_userman_rest_enabled') == '1' || uci.get('hotspot_openwrt', 'main', 'userman_rest_enabled') == '1';
		var hotspotQuickUsermanRestScheme = normalizeRouterOsScheme(uci.get('setup', 'default', 'hotspot_quick_userman_rest_scheme') || uci.get('hotspot_openwrt', 'main', 'userman_rest_scheme') || 'https');
		var hotspotQuickUsermanRestUsername = String(uci.get('setup', 'default', 'hotspot_quick_userman_rest_username') || uci.get('hotspot_openwrt', 'main', 'userman_rest_username') || 'hotspot-read').trim();
		var hotspotQuickUsermanRestPassword = uci.get('setup', 'default', 'hotspot_quick_userman_rest_password') || uci.get('hotspot_openwrt', 'main', 'userman_rest_password') || '';

		if (apIface2g)
			baseSsid = stripWifiSsidIpSuffix(apIface2g.ssid || '', wifiSsidIpSuffixState);
		else if (apIface5g)
			baseSsid = stripWifiSsidIpSuffix(strip5GSuffix(apIface5g.ssid || ''), wifiSsidIpSuffixState);

		if (!baseSsid && (hasPrimaryApIface || !hasVlanApIface))
			baseSsid = uci.get('setup', 'default', 'wifi_ssid') || '';

		if (!baseSsid && (hasPrimaryApIface || !hasVlanApIface))
			baseSsid = 'OpenWrt';

		ssid5gDerived = baseSsid ? primarySsid({
			lanIpaddr: lanIpaddr,
			wifiSsid: baseSsid,
			wifiSsid5gMode: 'derived',
			wifiSsid5g: '',
			wifiSsidVlanIpSuffix: wifiSsidIpSuffixState.wifiSsidVlanIpSuffix
		}, '5g') : '';

		if (ssid5gActual && ssid5gDerived && ssid5gActual != ssid5gDerived) {
			ssid5gMode = 'custom';
			ssid5gValue = stripWifiSsidIpSuffix(ssid5gActual, wifiSsidIpSuffixState);
		}
		else if (!ssid5gActual && (hasPrimaryApIface || !hasVlanApIface) && uci.get('setup', 'default', 'wifi_ssid_5g_mode') == 'custom') {
			ssid5gMode = 'custom';
			ssid5gValue = uci.get('setup', 'default', 'wifi_ssid_5g') || '';
		}

		if (apIface2g)
			key = apIface2g.key || '';
		else if (apIface5g)
			key = apIface5g.key || '';

		if (!key && (hasPrimaryApIface || !hasVlanApIface))
			key = uci.get('setup', 'default', 'wifi_key') || '';

		secondarySsids = inferSecondarySsids(radios, baseSsid);
		secondary2g = secondarySsids.ssid2g;
		secondary5g = secondarySsids.ssid5g;

		if (!secondary2g && isVlanEnabled)
			secondary2g = uci.get('setup', 'default', 'wifi_ssid_vlan_2g') || uci.get('setup', 'default', 'wifi_ssid_vlan') || '';

		if (!secondary5g && isVlanEnabled)
			secondary5g = uci.get('setup', 'default', 'wifi_ssid_vlan_5g') || '';

		if (!isVlanEnabled) {
			secondary2g = '';
			secondary5g = '';
		}

		return {
			lanIpaddr: lanIpaddr,
			lanNetmask: lanRuntime.netmask || uci.get('network', 'lan', 'netmask') || (firstbootEnabled ? firstbootLanNetmask : '') || uci.get('setup', 'default', 'lan_netmask') || '255.255.255.0',
			mode: hotspotQuickEnabled ? 'ap' : mode,
			wifiSsid: baseSsid,
			wifiSsid5gMode: ssid5gMode,
			wifiSsid5g: ssid5gValue,
			wifiSsidVlan2g: secondary2g,
			wifiSsidVlan5g: secondary5g,
			wifiSsidVlanIpSuffix: wifiSsidIpSuffixState.wifiSsidVlanIpSuffix,
			wifiKey: key,
			uplinkSsid: uplinkIface ? (uplinkIface.ssid || '') : (uci.get('setup', 'default', 'uplink_ssid') || ''),
			uplinkKey: uplinkIface ? (uplinkIface.key || '') : (uci.get('setup', 'default', 'uplink_key') || ''),
			uplinkBand: inferUplinkBand(radio2g, radio5g, uplinkIface),
			meshId: meshIface ? (meshIface.mesh_id || '') : (uci.get('setup', 'default', 'mesh_id') || ''),
			meshKey: meshIface ? (meshIface.key || '') : (uci.get('setup', 'default', 'mesh_key') || ''),
			meshBand: inferMeshBand(radio2g, radio5g, meshIface),
			hotspotQuickEnabled: hotspotQuickEnabled,
			hotspotQuickWanInterface: hotspotQuickWanInterface,
			hotspotQuickSubscriberInterface: hotspotQuickSubscriberInterface,
			hotspotQuickSsid1: hotspotQuickSsid1,
			hotspotQuickGateway1: hotspotQuickGateway1,
			hotspotQuickPoolStart1: hotspotQuickPoolStart1,
			hotspotQuickPoolEnd1: hotspotQuickPoolEnd1,
			hotspotQuickPolicy1: hotspotQuickPolicy1,
			hotspotQuickSecondaryEnabled: hotspotQuickSecondaryEnabled,
			hotspotQuickSsid2: hotspotQuickSsid2,
			hotspotQuickGateway2: hotspotQuickGateway2,
			hotspotQuickPoolStart2: hotspotQuickPoolStart2,
			hotspotQuickPoolEnd2: hotspotQuickPoolEnd2,
			hotspotQuickPolicy2: hotspotQuickPolicy2,
			hotspotQuickRadiusServer: hotspotQuickRadiusServer,
			hotspotQuickRadiusServer2: hotspotQuickRadiusServer2,
			hotspotQuickRadiusSecret: hotspotQuickRadiusSecret,
			hotspotQuickRadiusAuthPort: hotspotQuickRadiusAuthPort,
			hotspotQuickRadiusAcctPort: hotspotQuickRadiusAcctPort,
			hotspotQuickRadiusNasIp: hotspotQuickRadiusNasIp,
			hotspotQuickNasId: hotspotQuickNasId,
			hotspotQuickAcctInterim: hotspotQuickAcctInterim,
			hotspotQuickCoaEnabled: hotspotQuickCoaEnabled,
			hotspotQuickCoaPort: hotspotQuickCoaPort,
			hotspotQuickTrialEnabled: hotspotQuickTrialEnabled,
			hotspotQuickTrialDuration: hotspotQuickTrialDuration,
			hotspotQuickTrialUptimeLimit: hotspotQuickTrialUptimeLimit,
			hotspotQuickMacAuthEnabled: hotspotQuickMacAuthEnabled,
			hotspotQuickMacAuthSuffix: hotspotQuickMacAuthSuffix,
			hotspotQuickMacAuthPassword: hotspotQuickMacAuthPassword,
			hotspotQuickWalledGarden: hotspotQuickWalledGarden,
			hotspotQuickDomain: hotspotQuickDomain,
			hotspotQuickDns1: hotspotQuickDns1,
			hotspotQuickDns2: hotspotQuickDns2,
			hotspotQuickBridgeAgeingTime: hotspotQuickBridgeAgeingTime,
			hotspotQuickLoginMode: hotspotQuickLoginMode,
			hotspotQuickRateLimit: hotspotQuickRateLimit,
			hotspotQuickMacCookieEnabled: hotspotQuickMacCookieEnabled,
			hotspotQuickAvailableSpeeds: hotspotQuickAvailableSpeeds,
			hotspotQuickSupportPhone: hotspotQuickSupportPhone,
			hotspotQuickNoticeText: hotspotQuickNoticeText,
			hotspotQuickLiveStreamEnabled: hotspotQuickLiveStreamEnabled,
			hotspotQuickLiveStreamUrl: hotspotQuickLiveStreamUrl,
			hotspotQuickRestAreaEnabled: hotspotQuickRestAreaEnabled,
			hotspotQuickRestAreaUrl: hotspotQuickRestAreaUrl,
			hotspotQuickSpeedtestEnabled: hotspotQuickSpeedtestEnabled,
			hotspotQuickMaintEnabled: hotspotQuickMaintEnabled,
			hotspotQuickMaintStart: hotspotQuickMaintStart,
			hotspotQuickMaintEnd: hotspotQuickMaintEnd,
			hotspotQuickMaintMode: hotspotQuickMaintMode,
			hotspotQuickBrowserCookieEnabled: hotspotQuickBrowserCookieEnabled,
			hotspotQuickBrowserCookieDays: hotspotQuickBrowserCookieDays,
			hotspotQuickUsermanRestEnabled: hotspotQuickUsermanRestEnabled,
			hotspotQuickUsermanRestScheme: hotspotQuickUsermanRestScheme,
			hotspotQuickUsermanRestUsername: hotspotQuickUsermanRestUsername,
			hotspotQuickUsermanRestPassword: hotspotQuickUsermanRestPassword,
			isVlan: hotspotQuickEnabled ? false : isVlanEnabled,
			vlanId: inferVlanId(),
			channel2g: (radio2g && uci.get('wireless', radio2g['.name'], 'channel')) || uci.get('setup', 'default', 'channel_2g') || 'auto',
			channel5g: (radio5g && uci.get('wireless', radio5g['.name'], 'channel')) || uci.get('setup', 'default', 'channel_5g') || 'auto',
			wifiMode2g: normalizeWifiModeForBand('2g', inferredMode2g || uci.get('setup', 'default', 'wifi_mode_2g')),
			wifiWidth2g: normalizeWifiWidthForBand('2g', inferredMode2g || uci.get('setup', 'default', 'wifi_mode_2g'), inferredWidth2g || uci.get('setup', 'default', 'wifi_width_2g')),
			wifiMode5g: normalizeWifiModeForBand('5g', inferredMode5g || uci.get('setup', 'default', 'wifi_mode_5g')),
			wifiWidth5g: normalizeWifiWidthForBand('5g', inferredMode5g || uci.get('setup', 'default', 'wifi_mode_5g'), inferredWidth5g || uci.get('setup', 'default', 'wifi_width_5g')),
			resetDisabled: uci.get('setup', 'default', 'reset_button_disabled') == '1',
			resetHoldSeconds: uci.get('setup', 'default', 'reset_hold_seconds') || '5',
			wpsDisabled: uci.get('setup', 'default', 'wps_button_disabled') == '1',
			rebootEnabled: rebootSection ? rebootSection.mode == 'periodic_reboot' : false,
			rebootHours: rebootHours || '24',
			otaWindowAvailable: !!otaConfig,
			otaWindowStart: otaWindowStart,
			otaWindowEnd: otaWindowEnd,
			firstbootEnabled: firstbootEnabled,
			firstbootConfiguredOnce: firstbootConfiguredOnce,
			firstbootAutoCleanupArmed: firstbootAutoCleanupArmed,
			firstbootAutoCleanupPending: firstbootAutoCleanupPending,
			firstbootInitialSetupComplete: firstbootInitialSetupComplete,
			firstbootNetworkSection: firstbootNetworkSection,
			firstbootWirelessSection: firstbootWirelessSection,
			firstbootDhcpSection: firstbootDhcpSection,
			firstbootFirewallSection: firstbootFirewallSection,
			adminPassword: '',
			adminPasswordConfirm: '',
			hotspotAvailable: !!(uci.get('hotspot_openwrt', 'main')),
			hotspotEnabled: uci.get('setup', 'default', 'hotspot_enabled_from_wizard') === '1',
			hotspotSsid: (function() {
				var sec = findNamedWifiIfaceSection('wizard_hotspot');
				return sec ? String(sec.ssid || 'Hotspot') : 'Hotspot';
			}.call(this)),
			hotspotRadiusServer: uci.get('hotspot_openwrt', 'main', 'radius_server') || '192.168.1.2',
			hotspotRadiusSecret: uci.get('hotspot_openwrt', 'main', 'radius_secret') || '',
			hotspotNasId: uci.get('hotspot_openwrt', 'main', 'radius_nas_id') || '',
			hotspotIp: uci.get('hotspot_openwrt', 'main', 'hotspot_ip') || '192.168.10.1',
			hotspotPoolStart: uci.get('hotspot_openwrt', 'main', 'pool_start') || '192.168.10.10',
			hotspotPoolEnd: uci.get('hotspot_openwrt', 'main', 'pool_end') || '192.168.10.254'
		};
	},

	collectState: function() {
		var self = this;
		if (!self.state)
			self.state = {};
		self.state.lanIpaddr = self.refs.lanIpaddr.value.trim();
		self.state.lanNetmask = self.refs.lanNetmask.value.trim();
		self.state.mode = self.refs.mode.value;

		/* Bridge Hotspot mode and Quick Hotspot flag */
		if (self.state.mode == 'hotspot' || (self.state.mode == 'ap' && self.state.hotspotQuickEnabled)) {
			self.state.hotspotQuickEnabled = true;
			self.state.hotspotQuickSecondaryEnabled = true;
		} else {
			self.state.hotspotQuickEnabled = false;
		}

		self.state.wifiSsid = self.refs.wifiSsid.value.trim();
		self.state.wifiSsid5gMode = self.refs.wifiSsid5gMode ? self.refs.wifiSsid5gMode.value : (self.state.wifiSsid5gMode || 'derived');
		self.state.wifiSsid5g = self.refs.wifiSsid5g ? self.refs.wifiSsid5g.value.trim() : (self.state.wifiSsid5g || '');
		self.state.wifiSsidVlan2g = self.refs.wifiSsidVlan2g ? self.refs.wifiSsidVlan2g.value.trim() : (self.state.wifiSsidVlan2g || '');
		self.state.wifiSsidVlan5g = self.refs.wifiSsidVlan5g ? self.refs.wifiSsidVlan5g.value.trim() : (self.state.wifiSsidVlan5g || '');
		self.state.wifiSsidVlanIpSuffix = self.refs.wifiSsidIpSuffixPrimary ? self.refs.wifiSsidIpSuffixPrimary.checked : (self.refs.wifiSsidVlanIpSuffix ? self.refs.wifiSsidVlanIpSuffix.checked : !!self.state.wifiSsidVlanIpSuffix);
		self.state.wifiKey = self.refs.wifiKey.value;
		self.state.uplinkSsid = self.refs.uplinkSsid ? self.refs.uplinkSsid.value.trim() : '';
		self.state.uplinkKey = self.refs.uplinkKey ? self.refs.uplinkKey.value : '';
		self.state.uplinkBand = self.refs.uplinkBand ? self.refs.uplinkBand.value : '2g';
		self.state.meshId = self.refs.meshId ? self.refs.meshId.value.trim() : '';
		self.state.meshKey = self.refs.meshKey ? self.refs.meshKey.value : '';
		self.state.meshBand = self.refs.meshBand ? self.refs.meshBand.value : '2g';
		self.state.isVlan = self.refs.isVlan.checked;
		self.state.vlanId = self.refs.vlanId.value.trim();
		self.state.channel2g = self.refs.channel2g ? self.refs.channel2g.value : 'auto';
		self.state.channel5g = self.refs.channel5g ? self.refs.channel5g.value : 'auto';
		self.state.wifiMode2g = self.refs.wifiMode2g ? self.refs.wifiMode2g.value : (self.state.wifiMode2g || 'ax');
		self.state.wifiWidth2g = self.refs.wifiWidth2g ? self.refs.wifiWidth2g.value : (self.state.wifiWidth2g || '20');
		self.state.wifiMode5g = self.refs.wifiMode5g ? self.refs.wifiMode5g.value : (self.state.wifiMode5g || 'ax');
		self.state.wifiWidth5g = self.refs.wifiWidth5g ? self.refs.wifiWidth5g.value : (self.state.wifiWidth5g || '80');
		self.state.resetDisabled = self.refs.resetDisabled.checked;
		self.state.resetHoldSeconds = self.refs.resetHoldSeconds.value;
		self.state.wpsDisabled = self.refs.wpsDisabled.checked;
		self.state.rebootEnabled = self.refs.rebootEnabled ? self.refs.rebootEnabled.checked : false;
		self.state.rebootHours = self.refs.rebootHours ? self.refs.rebootHours.value.trim() : '24';
		self.state.otaWindowStart = self.refs.otaWindowStart ? normalizeHour(self.refs.otaWindowStart.value, 2) : self.state.otaWindowStart;
		self.state.otaWindowEnd = self.refs.otaWindowEnd ? normalizeHour(self.refs.otaWindowEnd.value, 6) : self.state.otaWindowEnd;
		self.state.hotspotQuickWanInterface = self.refs.hotspotQuickWanInterface ? self.refs.hotspotQuickWanInterface.value.trim() : (self.state.hotspotQuickWanInterface || 'lan');
		self.state.hotspotQuickSubscriberInterface = self.refs.hotspotQuickSubscriberInterface ? self.refs.hotspotQuickSubscriberInterface.value.trim() : (self.state.hotspotQuickSubscriberInterface || 'hotspot');
		self.state.hotspotQuickSsid1 = self.refs.hotspotQuickSsid1 ? self.refs.hotspotQuickSsid1.value.trim() : (self.state.hotspotQuickSsid1 || 'Hotspot-1');
		self.state.hotspotQuickGateway1 = self.refs.hotspotQuickGateway1 ? self.refs.hotspotQuickGateway1.value.trim() : (self.state.hotspotQuickGateway1 || '192.168.10.1');
		self.state.hotspotQuickPoolStart1 = self.refs.hotspotQuickPoolStart1 ? self.refs.hotspotQuickPoolStart1.value.trim() : deriveHotspotPoolStart(self.state.hotspotQuickGateway1);
		self.state.hotspotQuickPoolEnd1 = self.refs.hotspotQuickPoolEnd1 ? self.refs.hotspotQuickPoolEnd1.value.trim() : deriveHotspotPoolEnd(self.state.hotspotQuickGateway1);
		self.state.hotspotQuickPolicy1 = normalizeHotspotPolicy(self.refs.hotspotQuickPolicy1 ? self.refs.hotspotQuickPolicy1.value : self.state.hotspotQuickPolicy1, 'standard');
		self.state.hotspotQuickSecondaryEnabled = self.refs.hotspotQuickSecondaryEnabled ? self.refs.hotspotQuickSecondaryEnabled.checked : (self.state.hotspotQuickSecondaryEnabled !== false);
		self.state.hotspotQuickSsid2 = self.refs.hotspotQuickSsid2 ? self.refs.hotspotQuickSsid2.value.trim() : (self.state.hotspotQuickSsid2 || 'Hotspot-2');
		self.state.hotspotQuickGateway2 = self.refs.hotspotQuickGateway2 ? self.refs.hotspotQuickGateway2.value.trim() : (self.state.hotspotQuickGateway2 || '192.168.20.1');
		self.state.hotspotQuickPoolStart2 = self.refs.hotspotQuickPoolStart2 ? self.refs.hotspotQuickPoolStart2.value.trim() : deriveHotspotPoolStart(self.state.hotspotQuickGateway2);
		self.state.hotspotQuickPoolEnd2 = self.refs.hotspotQuickPoolEnd2 ? self.refs.hotspotQuickPoolEnd2.value.trim() : deriveHotspotPoolEnd(self.state.hotspotQuickGateway2);
		self.state.hotspotQuickPolicy2 = normalizeHotspotPolicy(self.refs.hotspotQuickPolicy2 ? self.refs.hotspotQuickPolicy2.value : self.state.hotspotQuickPolicy2, 'premium');
		self.state.hotspotQuickRadiusServer = self.refs.hotspotQuickRadiusServer ? self.refs.hotspotQuickRadiusServer.value.trim() : (self.state.hotspotQuickRadiusServer || '192.168.1.2');
		self.state.hotspotQuickRadiusServer2 = self.refs.hotspotQuickRadiusServer2 ? self.refs.hotspotQuickRadiusServer2.value.trim() : (self.state.hotspotQuickRadiusServer2 || '');
		self.state.hotspotQuickRadiusSecret = self.refs.hotspotQuickRadiusSecret ? self.refs.hotspotQuickRadiusSecret.value : (self.state.hotspotQuickRadiusSecret || '');
		self.state.hotspotQuickRadiusAuthPort = self.refs.hotspotQuickRadiusAuthPort ? self.refs.hotspotQuickRadiusAuthPort.value.trim() : (self.state.hotspotQuickRadiusAuthPort || '1812');
		self.state.hotspotQuickRadiusAcctPort = self.refs.hotspotQuickRadiusAcctPort ? self.refs.hotspotQuickRadiusAcctPort.value.trim() : (self.state.hotspotQuickRadiusAcctPort || '1813');
		self.state.hotspotQuickRadiusNasIp = self.refs.hotspotQuickRadiusNasIp ? self.refs.hotspotQuickRadiusNasIp.value.trim() : (self.state.hotspotQuickRadiusNasIp || '');
		self.state.hotspotQuickNasId = deriveHotspotQuickNasId(self.state.hotspotQuickNasId, self.state.lanIpaddr);
		self.state.hotspotQuickAcctInterim = self.refs.hotspotQuickAcctInterim ? self.refs.hotspotQuickAcctInterim.value.trim() : (self.state.hotspotQuickAcctInterim || '60');
		self.state.hotspotQuickCoaEnabled = self.refs.hotspotQuickCoaEnabled ? self.refs.hotspotQuickCoaEnabled.checked : !!self.state.hotspotQuickCoaEnabled;
		self.state.hotspotQuickCoaPort = self.refs.hotspotQuickCoaPort ? self.refs.hotspotQuickCoaPort.value.trim() : (self.state.hotspotQuickCoaPort || '3799');
		self.state.hotspotQuickTrialEnabled = self.refs.hotspotQuickTrialEnabled ? self.refs.hotspotQuickTrialEnabled.checked : !!self.state.hotspotQuickTrialEnabled;
		self.state.hotspotQuickTrialDuration = self.refs.hotspotQuickTrialDuration ? self.refs.hotspotQuickTrialDuration.value.trim() : (self.state.hotspotQuickTrialDuration || '30');
		self.state.hotspotQuickTrialUptimeLimit = self.refs.hotspotQuickTrialUptimeLimit ? self.refs.hotspotQuickTrialUptimeLimit.value.trim() : (self.state.hotspotQuickTrialUptimeLimit || '30');
		self.state.hotspotQuickMacAuthEnabled = self.refs.hotspotQuickMacAuthEnabled ? self.refs.hotspotQuickMacAuthEnabled.checked : !!self.state.hotspotQuickMacAuthEnabled;
		self.state.hotspotQuickMacAuthSuffix = self.refs.hotspotQuickMacAuthSuffix ? self.refs.hotspotQuickMacAuthSuffix.value.trim() : (self.state.hotspotQuickMacAuthSuffix || '@mac');
		self.state.hotspotQuickMacAuthPassword = self.refs.hotspotQuickMacAuthPassword ? self.refs.hotspotQuickMacAuthPassword.value : (self.state.hotspotQuickMacAuthPassword || 'mac');
		self.state.hotspotQuickWalledGarden = self.refs.hotspotQuickWalledGarden ? self.refs.hotspotQuickWalledGarden.value.trim() : (self.state.hotspotQuickWalledGarden || '');
		self.state.hotspotQuickDomain = self.refs.hotspotQuickDomain ? self.refs.hotspotQuickDomain.value.trim() : (self.state.hotspotQuickDomain || 'hotspot.local');
		self.state.hotspotQuickDns1 = self.refs.hotspotQuickDns1 ? self.refs.hotspotQuickDns1.value.trim() : (self.state.hotspotQuickDns1 || '8.8.8.8');
		self.state.hotspotQuickDns2 = self.refs.hotspotQuickDns2 ? self.refs.hotspotQuickDns2.value.trim() : (self.state.hotspotQuickDns2 || '82.114.163.31');
		self.state.hotspotQuickBridgeAgeingTime = normalizePositiveNumber(self.refs.hotspotQuickBridgeAgeingTime ? self.refs.hotspotQuickBridgeAgeingTime.value.trim() : (self.state.hotspotQuickBridgeAgeingTime || '10'), '10');
		self.state.hotspotQuickLoginMode = normalizeHotspotLoginMode(self.refs.hotspotQuickLoginMode ? self.refs.hotspotQuickLoginMode.value : self.state.hotspotQuickLoginMode);
		self.state.hotspotQuickRateLimit = self.refs.hotspotQuickRateLimit ? self.refs.hotspotQuickRateLimit.value.trim() : (self.state.hotspotQuickRateLimit || '2M/5M');
		self.state.hotspotQuickMacCookieEnabled = self.refs.hotspotQuickMacCookieEnabled ? self.refs.hotspotQuickMacCookieEnabled.checked : !!self.state.hotspotQuickMacCookieEnabled;
		self.state.hotspotQuickAvailableSpeeds = self.refs.hotspotQuickAvailableSpeeds ? self.refs.hotspotQuickAvailableSpeeds.value.trim() : (self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
		self.state.hotspotQuickSupportPhone = self.refs.hotspotQuickSupportPhone ? self.refs.hotspotQuickSupportPhone.value.trim() : (self.state.hotspotQuickSupportPhone || '');
		self.state.hotspotQuickNoticeText = self.refs.hotspotQuickNoticeText ? self.refs.hotspotQuickNoticeText.value.trim() : (self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا');
		self.state.hotspotQuickLiveStreamEnabled = self.refs.hotspotQuickLiveStreamEnabled ? self.refs.hotspotQuickLiveStreamEnabled.checked : !!self.state.hotspotQuickLiveStreamEnabled;
		self.state.hotspotQuickLiveStreamUrl = self.refs.hotspotQuickLiveStreamUrl ? self.refs.hotspotQuickLiveStreamUrl.value.trim() : (self.state.hotspotQuickLiveStreamUrl || '');
		self.state.hotspotQuickRestAreaEnabled = self.refs.hotspotQuickRestAreaEnabled ? self.refs.hotspotQuickRestAreaEnabled.checked : !!self.state.hotspotQuickRestAreaEnabled;
		self.state.hotspotQuickRestAreaUrl = self.refs.hotspotQuickRestAreaUrl ? self.refs.hotspotQuickRestAreaUrl.value.trim() : (self.state.hotspotQuickRestAreaUrl || '');
		self.state.hotspotQuickSpeedtestEnabled = self.refs.hotspotQuickSpeedtestEnabled ? self.refs.hotspotQuickSpeedtestEnabled.checked : !!self.state.hotspotQuickSpeedtestEnabled;
		self.state.hotspotQuickMaintEnabled = self.refs.hotspotQuickMaintEnabled ? self.refs.hotspotQuickMaintEnabled.checked : !!self.state.hotspotQuickMaintEnabled;
		self.state.hotspotQuickMaintStart = self.refs.hotspotQuickMaintStart ? self.refs.hotspotQuickMaintStart.value : (self.state.hotspotQuickMaintStart || '02:00');
		self.state.hotspotQuickMaintEnd = self.refs.hotspotQuickMaintEnd ? self.refs.hotspotQuickMaintEnd.value : (self.state.hotspotQuickMaintEnd || '03:00');
		self.state.hotspotQuickMaintMode = self.refs.hotspotQuickMaintMode ? self.refs.hotspotQuickMaintMode.value : (self.state.hotspotQuickMaintMode || 'free');
		self.state.hotspotQuickBrowserCookieEnabled = self.refs.hotspotQuickBrowserCookieEnabled ? self.refs.hotspotQuickBrowserCookieEnabled.checked : (self.state.hotspotQuickBrowserCookieEnabled !== false);
		self.state.hotspotQuickBrowserCookieDays = normalizeBrowserCookieDays(self.refs.hotspotQuickBrowserCookieDays ? self.refs.hotspotQuickBrowserCookieDays.value.trim() : (self.state.hotspotQuickBrowserCookieDays || '7'));
		self.state.hotspotQuickUsermanRestEnabled = self.refs.hotspotQuickUsermanRestEnabled ? self.refs.hotspotQuickUsermanRestEnabled.checked : !!self.state.hotspotQuickUsermanRestEnabled;
		self.state.hotspotQuickUsermanRestScheme = normalizeRouterOsScheme(self.refs.hotspotQuickUsermanRestScheme ? self.refs.hotspotQuickUsermanRestScheme.value : self.state.hotspotQuickUsermanRestScheme);
		self.state.hotspotQuickUsermanRestUsername = self.refs.hotspotQuickUsermanRestUsername ? self.refs.hotspotQuickUsermanRestUsername.value.trim() : (self.state.hotspotQuickUsermanRestUsername || 'hotspot-read');
		self.state.hotspotQuickUsermanRestPassword = self.refs.hotspotQuickUsermanRestPassword ? self.refs.hotspotQuickUsermanRestPassword.value : (self.state.hotspotQuickUsermanRestPassword || '');
		self.state.adminPassword = self.refs.adminPassword ? self.refs.adminPassword.value : '';
		self.state.adminPasswordConfirm = self.refs.adminPasswordConfirm ? self.refs.adminPasswordConfirm.value : '';
		self.state.hotspotEnabled = self.refs.hotspotEnabled ? self.refs.hotspotEnabled.checked : false;
		self.state.hotspotSsid = self.refs.hotspotSsid ? self.refs.hotspotSsid.value.trim() : (self.state.hotspotSsid || 'Hotspot');
		self.state.hotspotRadiusServer = self.refs.hotspotRadiusServer ? self.refs.hotspotRadiusServer.value.trim() : (self.state.hotspotRadiusServer || '192.168.1.2');
		self.state.hotspotRadiusSecret = self.refs.hotspotRadiusSecret ? self.refs.hotspotRadiusSecret.value : '';
		self.state.hotspotNasId = self.refs.hotspotNasId ? self.refs.hotspotNasId.value.trim() : (self.state.hotspotNasId || '');
		self.state.hotspotIp = self.refs.hotspotIp ? self.refs.hotspotIp.value.trim() : (self.state.hotspotIp || '192.168.10.1');
		self.state.hotspotPoolStart = self.refs.hotspotPoolStart ? self.refs.hotspotPoolStart.value.trim() : (self.state.hotspotPoolStart || '192.168.10.10');
		self.state.hotspotPoolEnd = self.refs.hotspotPoolEnd ? self.refs.hotspotPoolEnd.value.trim() : (self.state.hotspotPoolEnd || '192.168.10.254');
	},

	describeModePlan: function() {
		var self = this;
		var state = self.state || {};
		if (!state.mode) return '';
		var radio2g = getRadioByBand(self.radios || [], '2g');
		var remainingBands = getRemainingLocalBands(self.radios || [], self.state);
		var onlyBand = remainingBands[0];
		var uplinkBand = getRadioByBand(self.radios || [], self.state.uplinkBand) ? self.state.uplinkBand : (radio2g ? '2g' : '5g');
		var meshBand = getRadioByBand(self.radios || [], self.state.meshBand) ? self.state.meshBand : (radio2g ? '2g' : '5g');

		if (self.state.mode == 'ap_wds') {
			if (!remainingBands.length)
				return _('AP + WDS بدون شبكة محلية.');

			if (remainingBands.length == 1)
				return _('AP + WDS على ') + bandLabel(onlyBand) + _('.');

			return _('AP + WDS على الراديوهات المحلية.');
		}

		if (self.state.mode == 'sta_wds') {
			if (!remainingBands.length)
				return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، ولا توجد شبكة محلية.');

			if (remainingBands.length == 1)
				return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، والبث المحلي على ') + bandLabel(onlyBand) + _('.');

			return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، والباقي للبث المحلي.');
		}

		if (self.state.mode == 'mesh') {
			if (!remainingBands.length)
				return _('الميش على ') + bandLabel(meshBand) + _('، ولا توجد شبكة محلية.');

			if (remainingBands.length == 1)
				return _('الميش على ') + bandLabel(meshBand) + _('، والبث المحلي على ') + bandLabel(onlyBand) + _('.');

			return _('الميش على ') + bandLabel(meshBand) + _('، والباقي للبث المحلي.');
		}

		if (!remainingBands.length)
			return _('لا توجد شبكة محلية.');

		if (remainingBands.length == 1)
			return _('نقطة الوصول على ') + bandLabel(onlyBand) + _('.');

		return _('نقطة الوصول على الراديوهات المحلية.');
	},

	describeSecondaryNetworkPlan: function() {
		var self = this;
		var state = self.state || {};
		if (!state.mode) return '';
		var vlanId = self.state.vlanId || '10';
		var vlanBinding = describeSecondaryVlanBinding(vlanId);
		var secondary2g = previewSecondarySsid(self.state, '2g');
		var secondary5g = previewSecondarySsid(self.state, '5g');
		var remainingBands = getRemainingLocalBands(self.radios || [], self.state);
		var remainingCount = remainingBands.length;
		var onlyBand = remainingCount ? remainingBands[0] : null;
		var firstBand = remainingBands[0];
		var secondBand = remainingBands[1];
		if (!self.state.isVlan)
			return _('معطلة.');

		if (!remainingCount)
			return _('مفعلة بدون بث لاسلكي.');

		if (remainingCount == 1)
			return _('مفعلة على ') + bandLabel(onlyBand) + _(': ') + previewSecondarySsid(self.state, onlyBand) + _(' ضمن ') + vlanBinding + _('.');

		return _('مفعلة: ') + bandLabel(firstBand) + ' ' + secondary2g + _(' | ') + bandLabel(secondBand) + ' ' + secondary5g + _(' ضمن ') + vlanBinding + _('.');
	},

	syncRadioModeWidthUi: function() {
		var self = this;
		if (!self.state) return;
		if (self.refs.wifiMode2g && self.refs.wifiWidth2g) {
			self.state.wifiMode2g = normalizeWifiModeForBand('2g', self.state.wifiMode2g);
			populateSelectOptions(self.refs.wifiMode2g, wifiModeChoices('2g'), self.state.wifiMode2g);
			self.state.wifiWidth2g = normalizeWifiWidthForBand('2g', self.state.wifiMode2g, self.state.wifiWidth2g);
			populateSelectOptions(self.refs.wifiWidth2g, wifiWidthChoices('2g', self.state.wifiMode2g), self.state.wifiWidth2g);
		}

		if (self.refs.wifiMode5g && self.refs.wifiWidth5g) {
			self.state.wifiMode5g = normalizeWifiModeForBand('5g', self.state.wifiMode5g);
			populateSelectOptions(self.refs.wifiMode5g, wifiModeChoices('5g'), self.state.wifiMode5g);
			self.state.wifiWidth5g = normalizeWifiWidthForBand('5g', self.state.wifiMode5g, self.state.wifiWidth5g);
			populateSelectOptions(self.refs.wifiWidth5g, wifiWidthChoices('5g', self.state.wifiMode5g), self.state.wifiWidth5g);
		}
	},

	updateStepUi: function() {
		var self = this;
		if (!self.state || Object.keys(self.state).length === 0) return;
		var i;
		var lastStep = self.stepPanels.length - 1;
		var vlanBinding;
		var meshBandIs5g;
		var meshChannel;

		self.collectState();
		self.syncRadioModeWidthUi();

		var isHotspotMode = (self.state.mode === 'hotspot' || self.state.mode === 'hotspot_quick');

		enforceHotspotNoVlan(self.state);
		vlanBinding = describeSecondaryVlanBinding(self.state.vlanId);
		meshBandIs5g = (self.state.meshBand == '5g');
		meshChannel = meshBandIs5g ? self.state.channel5g : self.state.channel2g;

		if (self.refs.isVlan)
			self.refs.isVlan.checked = !!self.state.isVlan;

		for (i = 0; i < self.stepPanels.length; i++) {
			self.stepPanels[i].style.display = (i == self.stepIndex) ? '' : 'none';

			if (self.stepChips && self.stepChips[i]) {
				setClassState(self.stepChips[i], 'is-active', i == self.stepIndex);
				setClassState(self.stepChips[i], 'is-complete', i < self.stepIndex);
				setClassState(self.stepChips[i], 'is-skipped', self.isStepSkipped(i));
			}

			if (self.stepBadges && self.stepBadges[i]) {
				setClassState(self.stepBadges[i], 'is-active', i == self.stepIndex);
				setClassState(self.stepBadges[i], 'is-complete', i < self.stepIndex);
			}
		}

		
		if (self.refs.progressFill) {
            var perc = ((self.stepIndex + 1) / self.stepPanels.length) * 100;
            self.refs.progressFill.style.width = perc + '%';
        }

        if (self.stepIndex === (self.stepPanels.length - 1) && self.refs.reviewContainer) {
            dom.content(self.refs.reviewContainer, [
                E('div', { 'class': 'alemprator-review-item' }, [ E('span', { 'class': 'alemprator-review-label' }, _('وضع التشغيل:')), E('span', { 'class': 'alemprator-review-value' }, modeTitle(self.state.mode)) ]),
                E('div', { 'class': 'alemprator-review-item' }, [ E('span', { 'class': 'alemprator-review-label' }, _('عنوان الشبكة:')), E('span', { 'class': 'alemprator-review-value' }, self.state.lanIpaddr) ]),
                E('div', { 'class': 'alemprator-review-item' }, [ E('span', { 'class': 'alemprator-review-label' }, _('اسم الهوتسبوت:')), E('span', { 'class': 'alemprator-review-value' }, self.state.hotspotQuickSsid1 || 'Hotspot-1') ])
            ]);
            self.refs.saveButton.classList.add('is-luxury');
        } else if (self.refs.saveButton) {
            self.refs.saveButton.classList.remove('is-luxury');
        }

		self.refs.prevButton.disabled = (self.stepIndex === 0);
		setElementVisible(self.refs.nextButton, self.stepIndex !== lastStep);
		setElementVisible(self.refs.saveButton, self.stepIndex === lastStep);
		setElementVisible(self.refs.uplinkSettingsWrapper, (self.state.mode == 'sta_wds'));
		setElementVisible(self.refs.meshSettingsWrapper, self.state.mode == 'mesh');
		setElementVisible(self.refs.hotspotQuickDetailsWrapper, !!(self.state || {}).hotspotQuickEnabled);
		setElementVisible(self.refs.hotspotQuickAuthWrapper, !!(self.state || {}).hotspotQuickEnabled);
		setElementVisible(self.refs.hotspotQuickRestFieldsWrapper, !!(self.state.hotspotQuickEnabled && self.state.hotspotQuickUsermanRestEnabled));
		setElementVisible(self.refs.hotspotQuickSecondaryWrapper, !!(self.state.hotspotQuickEnabled && self.state.hotspotQuickSecondaryEnabled));
		setElementVisible(self.refs.hotspotQuickMaintWrapper, !!(self.state.hotspotQuickEnabled && self.state.hotspotQuickMaintEnabled));
		if (self.refs.hotspotQuickCard)
			setClassState(self.refs.hotspotQuickCard, 'is-wide', !!(self.state || {}).hotspotQuickEnabled);
		if (self.refs.vlanSettingsCard)
			setElementVisible(self.refs.vlanSettingsCard, !(self.state || {}).hotspotQuickEnabled && !isHotspotMode);
		
		if (self.refs.lanAdvancedCard)
			setElementVisible(self.refs.lanAdvancedCard, true);

		// Radio settings: Show as minimalist tooltip even in Hotspot mode for Alemprator minimalism
		if (self.refs.radioSettingsCard)
			setElementVisible(self.refs.radioSettingsCard, true);

		if (self.refs.meshSettingsCard)
			setElementVisible(self.refs.meshSettingsCard, !isHotspotMode);

		if (self.refs.otaCard)
			setElementVisible(self.refs.otaCard, true);
		if (self.refs.firstbootCard)
			setElementVisible(self.refs.firstbootCard, true);
		if (self.refs.buttonPoliciesCard)
			setElementVisible(self.refs.buttonPoliciesCard, true);
		if (self.refs.rebootCard)
			setElementVisible(self.refs.rebootCard, true);
		
		// Hide maintenance header and backup in hotspot mode if total minimalism is desired
		// For now, let's keep backup but hide the technical stuff.
		// If the user wants to hide the header too:
		if (self.refs.maintenanceHeader)
			setElementVisible(self.refs.maintenanceHeader, true);
		if (self.refs.backupCard)
			setElementVisible(self.refs.backupCard, true);

		if (self.refs.mode)
			self.refs.mode.disabled = !!(self.state || {}).hotspotQuickEnabled;
		setElementVisible(self.refs.vlanIdWrapper, self.refs.isVlan.checked);
		if (self.refs.vlanSsid2gRow)
			setElementVisible(self.refs.vlanSsid2gRow, self.refs.isVlan.checked);
		if (self.refs.vlanSsid5gRow)
			setElementVisible(self.refs.vlanSsid5gRow, self.refs.isVlan.checked);
		if (self.refs.vlanSsidIpSuffixRow)
			setElementVisible(self.refs.vlanSsidIpSuffixRow, true);
		setElementVisible(self.refs.vlanPreviewWrapper, self.refs.isVlan.checked);
		if (self.refs.hotspotVlanLockNotice)
			setElementVisible(self.refs.hotspotVlanLockNotice, !!(self.state || {}).hotspotQuickEnabled);

		if (self.refs.isVlan)
			self.refs.isVlan.disabled = !!(self.state || {}).hotspotQuickEnabled;
		if (self.refs.vlanId)
			self.refs.vlanId.disabled = !!(self.state || {}).hotspotQuickEnabled;
		if (self.refs.wifiSsidVlan2g)
			self.refs.wifiSsidVlan2g.disabled = !!(self.state || {}).hotspotQuickEnabled;
		if (self.refs.wifiSsidVlan5g)
			self.refs.wifiSsidVlan5g.disabled = !!(self.state || {}).hotspotQuickEnabled;
		if (self.refs.wifiSsidVlanIpSuffix)
			self.refs.wifiSsidVlanIpSuffix.disabled = !!(self.state || {}).hotspotQuickEnabled;
		if (self.refs.wifiSsidIpSuffixPrimary)
			self.refs.wifiSsidIpSuffixPrimary.disabled = !!(self.state || {}).hotspotQuickEnabled;
		setElementVisible(self.refs.resetHoldWrapper, !self.refs.resetDisabled.checked);
		setElementVisible(self.refs.rebootHoursWrapper, self.refs.rebootEnabled.checked);
		var apVlanOnlyMode = (self.state.mode == 'ap' && self.state.isVlan);
		if (self.refs.primaryWifiSection)
			setElementVisible(self.refs.primaryWifiSection, !apVlanOnlyMode && !(self.state || {}).hotspotQuickEnabled);
		if (self.refs.wifiSecurityCard)
			setElementVisible(self.refs.wifiSecurityCard, !(self.state || {}).hotspotQuickEnabled);
		if (self.refs.apVlanWarning)
			setElementVisible(self.refs.apVlanWarning, apVlanOnlyMode);
		var hasLocal5g = (getRemainingLocalBands(self.radios || [], self.state).indexOf('5g') != -1);
		if (self.refs.ssid5gModeRow)
			setElementVisible(self.refs.ssid5gModeRow, hasLocal5g);
		if (self.refs.ssid5gCustomRow)
			setElementVisible(self.refs.ssid5gCustomRow, hasLocal5g && self.state.wifiSsid5gMode == 'custom');
		if (self.refs.ssidPreviewRow)
			setElementVisible(self.refs.ssidPreviewRow, hasLocal5g);
		self.refs.ssidPreview.textContent = primarySsid(self.state, '5g');
		if (self.refs.heroCurrentLan)
			self.refs.heroCurrentLan.textContent = self.state.lanIpaddr || '-';
		if (self.refs.heroCurrentMode)
			self.refs.heroCurrentMode.textContent = modeTitle(self.state.mode);
		if (self.refs.heroCurrentSecondary)
			self.refs.heroCurrentSecondary.textContent = self.state.hotspotQuickEnabled
				? _('هوتسبوت سريع: شبكتان')
				: describeHeroSecondarySummary(self.state, self.radios || []);
		if (self.refs.heroSetupSummary)
			self.refs.heroSetupSummary.textContent = describeFirstbootSummary(self.state);
		if (self.refs.wifiNameHelp)
			self.refs.wifiNameHelp.textContent = describePrimaryWifiNamingHelp(self.state, self.radios || []);
		self.refs.vlanPreview.textContent = vlanBinding;
		if (self.refs.secondaryNetworkIntro)
			self.refs.secondaryNetworkIntro.textContent = describeSecondaryNetworkIntro(self.state, self.radios || []);
		if (self.refs.secondarySubnetHelp)
			self.refs.secondarySubnetHelp.textContent = describeSecondarySubnetHelp(self.state, self.radios || []);
		if (self.refs.uplinkHelp)
			self.refs.uplinkHelp.textContent = describeUplinkSettingsHelp(self.state, self.radios || []);
		if (self.refs.meshHelp)
			self.refs.meshHelp.textContent = describeMeshSettingsHelp(self.state, self.radios || []);

		if (self.refs.channel2gRow) {
			setClassState(self.refs.channel2gRow, 'is-mesh-target', self.state.mode == 'mesh' && !meshBandIs5g);
		}

		if (self.refs.channel5gRow) {
			setClassState(self.refs.channel5gRow, 'is-mesh-target', self.state.mode == 'mesh' && meshBandIs5g);
		}

		if (self.refs.meshChannelHelp) {
			if (self.state.mode == 'mesh') {
				setElementVisible(self.refs.meshChannelHelp, true);
				self.refs.meshChannelHelp.textContent = describeMeshChannelHelp(self.state, self.radios || []);
			}
			else {
				setElementVisible(self.refs.meshChannelHelp, false);
				self.refs.meshChannelHelp.textContent = '';
			}
		}

		if (self.refs.modePlan)
			self.refs.modePlan.textContent = self.describeModePlan();

		if (self.refs.primaryWifiPlan)
			self.refs.primaryWifiPlan.textContent = describePrimaryWifiPlan(self.state, self.radios || []);

		if (self.refs.secondaryNetworkPlan)
			self.refs.secondaryNetworkPlan.textContent = self.describeSecondaryNetworkPlan();

		if (self.refs.secondaryNetworkNotice) {
			self.refs.secondaryNetworkNotice.textContent = describeSecondaryNetworkNotice(self.state, self.radios || []);
			setElementVisible(self.refs.secondaryNetworkNotice, self.state.isVlan);
		}

		if (self.refs.otaWindowStatus)
			self.refs.otaWindowStatus.textContent = self.state.otaWindowAvailable ? describeOtaWindow(self.state.otaWindowStart, self.state.otaWindowEnd) : _('إعدادات التحديث التلقائي غير متوفرة على هذا الجهاز.');

		if (self.refs.firstbootSummary)
			self.refs.firstbootSummary.textContent = describeFirstbootSummary(self.state);

		if (self.refs.firstbootEnabledStatus)
			self.refs.firstbootEnabledStatus.textContent = enabledText(self.state.firstbootEnabled);

		if (self.refs.firstbootConfiguredOnceStatus)
			self.refs.firstbootConfiguredOnceStatus.textContent = boolText(self.state.firstbootConfiguredOnce);

		if (self.refs.firstbootInitialSetupStatus)
			self.refs.firstbootInitialSetupStatus.textContent = boolText(self.state.firstbootInitialSetupComplete);

		if (self.refs.firstbootCleanupStatus)
			self.refs.firstbootCleanupStatus.textContent = describeFirstbootCleanupState(self.state.firstbootAutoCleanupArmed, self.state.firstbootAutoCleanupPending);

		if (self.refs.firstbootSections)
			self.refs.firstbootSections.textContent = describeFirstbootSections(self.state);

		setTextContent(self.refs.lanCardSummary, summarizeLanCard(self.state));
		setTextContent(self.refs.modeCardSummary, summarizeModeCard(self.state));
		setTextContent(self.refs.primaryWifiCardSummary, summarizePrimaryWifiCard(self.state, self.radios || []));
		setTextContent(self.refs.wifiSecurityCardSummary, summarizeWifiSecurity(self.state));
		setTextContent(self.refs.uplinkCardSummary, summarizeUplinkCard(self.state, self.radios || []));
		setTextContent(self.refs.meshCardSummary, summarizeMeshCard(self.state, self.radios || []));
		setTextContent(self.refs.vlanCardSummary, summarizeVlanCard(self.state, self.radios || []));
		setTextContent(self.refs.radioCardSummary, summarizeChannelCard(self.state, self.radios || []));
		setTextContent(self.refs.backupCardSummary, (self.refs.backupStatus && self.refs.backupStatus.textContent) || _('جاهز لتنزيل النسخة الاحتياطية أو استرجاعها بأمان.'));
		setTextContent(self.refs.firstbootCardSummary, describeFirstbootSummary(self.state));
		setTextContent(self.refs.otaCardSummary, summarizeOtaCard(self.state));
		setTextContent(self.refs.buttonPoliciesCardSummary, summarizeButtonPolicies(self.state));
		setTextContent(self.refs.rebootCardSummary, summarizeRebootPolicy(self.state));
		setTextContent(self.refs.passwordCardSummary, summarizePasswordCard(self.state));

		setTextContent(self.refs.hotspotCardSummary, summarizeHotspotCard(self.state));

		if (self.refs.hotspotFieldsWrapper)
			setElementVisible(self.refs.hotspotFieldsWrapper, !!(self.state.hotspotAvailable && self.state.hotspotEnabled));

		if (self.refs.hotspotIpConflictWarning) {
			var showConflict = self.state.hotspotEnabled && hotspotIpConflictsWithLan(self.state.lanIpaddr, self.state.hotspotIp);
			setElementVisible(self.refs.hotspotIpConflictWarning, showConflict);
		}
	},

	validateStep: function(index) { var self = this;
		self.collectState();

		if (STEP_KEYS[index] == 'network') {
			if (!isIPv4(self.state.lanIpaddr)) {
				notify(_('أدخل عنوان LAN IPv4 صالحًا.'));
				return false;
			}

			if (!isIPv4(self.state.lanNetmask)) {
				notify(_('أدخل قناع شبكة LAN صالحًا.'));
				return false;
			}

			if (normalizeMode(self.state.mode) != self.state.mode) {
				notify(_('اختر وضع تشغيل صالحًا.'));
				return false;
			}

			if (self.state.hotspotQuickEnabled && (self.state.mode != 'ap' && self.state.mode != 'hotspot')) {
				notify(_('وضع الهوتسبوت السريع يعمل فقط مع نقطة الوصول AP.'));
				return false;
			}

			var apVlanOnlyMode = (self.state.mode == 'ap' && self.state.isVlan);
			if (!(self.state || {}).hotspotQuickEnabled && !apVlanOnlyMode && !self.state.wifiSsid) {
				notify(_('أدخل اسم الشبكة اللاسلكية الأساسي.'));
				return false;
			}

			if (self.state.mode == 'mesh') {
				var meshChannel = (self.state.meshBand == '5g') ? self.state.channel5g : self.state.channel2g;
				if (!meshChannel || meshChannel == 'auto') {
					notify(_('في وضع الميش، يجب تحديد قناة ثابتة للراديو المخصص.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'hotspot_net') {
			var quickModeProfileError = validateHotspotQuickProfile(self.state, 1);
			if (!quickModeProfileError && self.state.hotspotQuickSecondaryEnabled)
				quickModeProfileError = validateHotspotQuickProfile(self.state, 2);

			if (quickModeProfileError) {
				notify(quickModeProfileError);
				return false;
			}
		}

		if (STEP_KEYS[index] == 'hotspot_auth') {
			if (self.state.hotspotQuickEnabled) {
				if (!isIPv4(self.state.hotspotQuickRadiusServer)) {
					notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS (IP الميكروتك).'));
					return false;
				}
				if (!self.state.hotspotQuickRadiusSecret) {
					notify(_('كلمة سر RADIUS مطلوبة.'));
					return false;
				}
				if (self.state.hotspotQuickUsermanRestEnabled) {
					if (!self.state.hotspotQuickUsermanRestUsername || !self.state.hotspotQuickUsermanRestPassword) {
						notify(_('يجب إدخال اسم المستخدم وكلمة مرور API عند تفعيل User Manager REST.'));
						return false;
					}
				}
			}
		}

		if (STEP_KEYS[index] == 'maintenance') {
			if ((self.state.adminPassword || self.state.adminPasswordConfirm) &&
			    (!self.state.adminPassword || !self.state.adminPasswordConfirm)) {
				notify(_('أدخل كلمة مرور الجهاز الجديدة ثم أكدها.'));
				return false;
			}

			if (self.state.adminPassword != self.state.adminPasswordConfirm) {
				notify(_('تأكيد كلمة مرور الجهاز غير مطابق.'));
				return false;
			}
		}

		return true;
	},

	isStepSkipped: function(index) {
		var self = this;
		var state = self.state || {};
		
		if (!state || Object.keys(state).length === 0)
			return true;

		// Step 0 (Identity), Step 1 (Wireless) and Step 4 (Maintenance) always visible
		if (index === 0 || index === 1 || index === 4) return false;

		// Step 2 (Hotspot Network) and Step 3 (Hotspot Auth)
		// Only show if Hotspot mode is selected
		if (STEP_KEYS[index] == 'hotspot_net' || STEP_KEYS[index] == 'hotspot_auth') {
			var isHotspot = (state.mode === 'hotspot' || state.hotspotQuickEnabled);
			return !isHotspot;
		}

		return false;
	},

	nextStep: function() { var self = this;
		self.collectState();
		if (!self.validateStep(self.stepIndex))
			return;

		var nextIndex = self.stepIndex + 1;

		while (nextIndex < self.stepPanels.length - 1 && self.isStepSkipped(nextIndex))
			nextIndex++;

		if (nextIndex < self.stepPanels.length) {
			self.stepIndex = nextIndex;
			self.updateStepUi();
		}
	},

	prevStep: function() { var self = this;
		self.collectState();

		if (self.stepIndex > 0) {
			var prevIndex = self.stepIndex - 1;

			while (prevIndex > 0 && self.isStepSkipped(prevIndex))
				prevIndex--;

			self.stepIndex = prevIndex;
			self.updateStepUi();
		}
	},

	applyHotspotSettings: function(state, radios) {
		var hotspotIface = 'wizard_hotspot';
		var hotspotRadio;

		if (!state.hotspotAvailable || !uci.get('hotspot_openwrt', 'main'))
			return;

		if (state.hotspotQuickEnabled) {
			uci.remove('wireless', hotspotIface);
			uci.set('setup', 'default', 'hotspot_enabled_from_wizard', '0');
			return;
		}

		ensureNamedSection('hotspot_openwrt', 'main', 'main');
		uci.set('hotspot_openwrt', 'main', 'enabled', state.hotspotEnabled ? '1' : '0');

		if (state.hotspotEnabled) {
			hotspotRadio = getRadioByBand(radios, '2g') || getRadioByBand(radios, '5g');

			if (hotspotRadio) {
				ensureNamedWifiIface(hotspotIface);
				uci.set('wireless', hotspotIface, 'device', wifiDeviceName(hotspotRadio));
				uci.set('wireless', hotspotIface, 'mode', 'ap');
				uci.set('wireless', hotspotIface, 'network', 'hotspot');
				uci.set('wireless', hotspotIface, 'disabled', '0');
				uci.set('wireless', hotspotIface, 'ssid', state.hotspotSsid || 'Hotspot');
				uci.set('wireless', hotspotIface, 'encryption', 'none');
				uci.unset('wireless', hotspotIface, 'key');
				uci.unset('wireless', hotspotIface, 'wds');
				uci.set('hotspot_openwrt', 'main', 'wifi_iface', hotspotIface);
			}

			uci.set('hotspot_openwrt', 'main', 'radius_server', state.hotspotRadiusServer);
			uci.set('hotspot_openwrt', 'main', 'radius_secret', state.hotspotRadiusSecret);

			if (state.hotspotNasId)
				uci.set('hotspot_openwrt', 'main', 'radius_nas_id', state.hotspotNasId);
			else
				uci.unset('hotspot_openwrt', 'main', 'radius_nas_id');

			if (state.hotspotIp)
				uci.set('hotspot_openwrt', 'main', 'hotspot_ip', state.hotspotIp);

			if (state.hotspotPoolStart)
				uci.set('hotspot_openwrt', 'main', 'pool_start', state.hotspotPoolStart);

			if (state.hotspotPoolEnd)
				uci.set('hotspot_openwrt', 'main', 'pool_end', state.hotspotPoolEnd);

			uci.set('setup', 'default', 'hotspot_enabled_from_wizard', '1');
		}
		else {
			uci.remove('wireless', hotspotIface);
			uci.set('setup', 'default', 'hotspot_enabled_from_wizard', '0');
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
		var uplinkStaIface = null;
		var uplinkLanApIface = null;
		var meshRadio = null;
		var meshApIface = null;
		var meshIface = null;
		var secondaryIface2g = radio2g ? secondaryApSectionName(radio2g['.name']) : null;
		var secondaryIface5g = radio5g ? secondaryApSectionName(radio5g['.name']) : null;
		var iface;
		var localRadios;
		var managedSids = {};

		applyRadioHtmode(radio2g, '2g', state);
		applyRadioHtmode(radio5g, '5g', state);

		if (state.hotspotQuickEnabled) {
			var hotspotNetworkPrimary = normalizeInterfaceName(state.hotspotQuickSubscriberInterface, 'hotspot');
			var hotspotNetworkSecondary = deriveHotspotQuickSecondaryInterface(hotspotNetworkPrimary);
			var primaryRadio = radio2g || radio5g;
			var secondaryRadio = radio5g || radio2g || primaryRadio;
			var hotspotPolicyPrimary = getLocalApPolicy({ mode: 'ap', isVlan: false }, hotspotNetworkPrimary);
			var hotspotPolicySecondary = getLocalApPolicy({ mode: 'ap', isVlan: false }, hotspotNetworkSecondary);

			uci.remove('wireless', 'wizard_uplink');
			uci.remove('wireless', 'wizard_uplink_ap');
			uci.remove('wireless', 'wizard_mesh');

			if (secondaryIface2g)
				uci.remove('wireless', secondaryIface2g);
			if (secondaryIface5g)
				uci.remove('wireless', secondaryIface5g);

			if (primaryRadio) {
				ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_PRIMARY);
				configureApIface(
					HOTSPOT_QUICK_IFACE_PRIMARY,
					wifiDeviceName(primaryRadio),
					hotspotNetworkPrimary,
					String(state.hotspotQuickSsid1 || 'Hotspot-1').trim(),
					state.wifiKey,
					hotspotPolicyPrimary
				);
			}

			if (state.hotspotQuickSecondaryEnabled && secondaryRadio) {
				ensureNamedWifiIface(HOTSPOT_QUICK_IFACE_SECONDARY);
				configureApIface(
					HOTSPOT_QUICK_IFACE_SECONDARY,
					wifiDeviceName(secondaryRadio),
					hotspotNetworkSecondary,
					String(state.hotspotQuickSsid2 || 'Hotspot-2').trim(),
					state.wifiKey,
					hotspotPolicySecondary
				);
			}
			else {
				uci.remove('wireless', HOTSPOT_QUICK_IFACE_SECONDARY);
			}

			uci.sections('wireless', 'wifi-iface').forEach(function(section) {
				var sid = section['.name'];
				var sectionNetworks = normalizeList(section.network);

				if (sid == HOTSPOT_QUICK_IFACE_PRIMARY || sid == HOTSPOT_QUICK_IFACE_SECONDARY)
					return;

				if (section.mode != null && section.mode != 'ap')
					return;

				if (sectionNetworks.indexOf('wizardvlan') > -1) {
					uci.remove('wireless', sid);
					return;
				}

				if (sectionNetworks.indexOf('lan') > -1)
					uci.set('wireless', sid, 'disabled', '1');
			});

			if (radio2g)
				uci.set('wireless', radio2g['.name'], 'channel', state.channel2g || 'auto');

			if (radio5g)
				uci.set('wireless', radio5g['.name'], 'channel', state.channel5g || 'auto');

			return;
		}

		uci.remove('wireless', HOTSPOT_QUICK_IFACE_PRIMARY);
		uci.remove('wireless', HOTSPOT_QUICK_IFACE_SECONDARY);

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

			uplinkLanApIface = ensureNamedWifiIface('wizard_uplink_ap');
			managedSids[uplinkLanApIface] = true;
			configureApIface(
				uplinkLanApIface,
				wifiDeviceName(uplinkRadio),
				'lan',
				primarySsid(state, uplinkRadio && uplinkRadio.band == '5g' ? '5g' : '2g'),
				state.wifiKey,
				lanPolicy
			);

			uci.sections('wireless', 'wifi-iface').forEach(function(section) {
				var sid = section['.name'];

				if (!uplinkRadio || section.device != uplinkRadio['.name'])
					return;

				if (sid == uplinkStaIface || sid == uplinkLanApIface)
					return;

				if (sid == secondaryIface2g || sid == secondaryIface5g)
					return;

				if (section.mode == null || section.mode == 'ap') {
					uci.set('wireless', sid, 'disassoc_low_ack', '0');
					uci.set('wireless', sid, 'disabled', '1');
				}
			});

			if (uplinkRadio)
				uci.set('wireless', uplinkRadio['.name'], 'channel', 'auto');
		}
		else {
			uci.remove('wireless', 'wizard_uplink');
			uci.remove('wireless', 'wizard_uplink_ap');
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
			managedSids[iface] = true;

			if (vlanOnlyAp)
				uci.remove('wireless', iface);
			else
				configureApIface(iface, radio2g['.name'], 'lan', primarySsid(state, '2g'), state.wifiKey, lanPolicy);

			uci.set('wireless', radio2g['.name'], 'channel', state.channel2g || 'auto');

			if (state.isVlan) {
				ensureNamedWifiIface(secondaryIface2g);
				managedSids[secondaryIface2g] = true;
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
			managedSids[iface] = true;

			if (vlanOnlyAp)
				uci.remove('wireless', iface);
			else
				configureApIface(iface, radio5g['.name'], 'lan', primarySsid(state, '5g'), state.wifiKey, lanPolicy);

			uci.set('wireless', radio5g['.name'], 'channel', state.channel5g || 'auto');

			if (state.isVlan) {
				ensureNamedWifiIface(secondaryIface5g);
				managedSids[secondaryIface5g] = true;
				configureApIface(secondaryIface5g, radio5g['.name'], 'wizardvlan', previewSecondarySsid(state, '5g'), state.wifiKey, vlanPolicy);
			}
			else {
				uci.remove('wireless', secondaryIface5g);
			}
		}
		else if (secondaryIface5g) {
			uci.remove('wireless', secondaryIface5g);
		}

		if (requestedMode == 'sta_wds' && uplinkRadio) {
			if (state.isVlan) {
				if (uplinkRadio['.name'] == (radio2g && radio2g['.name']) && secondaryIface2g) {
					ensureNamedWifiIface(secondaryIface2g);
					configureApIface(secondaryIface2g, uplinkRadio['.name'], 'wizardvlan', previewSecondarySsid(state, '2g'), state.wifiKey, vlanPolicy);
				}

				if (uplinkRadio['.name'] == (radio5g && radio5g['.name']) && secondaryIface5g) {
					ensureNamedWifiIface(secondaryIface5g);
					configureApIface(secondaryIface5g, uplinkRadio['.name'], 'wizardvlan', previewSecondarySsid(state, '5g'), state.wifiKey, vlanPolicy);
				}
			}
			else {
				if (uplinkRadio['.name'] == (radio2g && radio2g['.name']) && secondaryIface2g)
					uci.remove('wireless', secondaryIface2g);

				if (uplinkRadio['.name'] == (radio5g && radio5g['.name']) && secondaryIface5g)
					uci.remove('wireless', secondaryIface5g);
			}
		}

		if (requestedMode == 'mesh' && meshRadio) {
			if (state.isVlan) {
				if (meshRadio['.name'] == (radio2g && radio2g['.name']) && secondaryIface2g) {
					ensureNamedWifiIface(secondaryIface2g);
					configureApIface(secondaryIface2g, meshRadio['.name'], 'wizardvlan', previewSecondarySsid(state, '2g'), state.wifiKey, vlanPolicy);
				}

				if (meshRadio['.name'] == (radio5g && radio5g['.name']) && secondaryIface5g) {
					ensureNamedWifiIface(secondaryIface5g);
					configureApIface(secondaryIface5g, meshRadio['.name'], 'wizardvlan', previewSecondarySsid(state, '5g'), state.wifiKey, vlanPolicy);
				}
			}
			else {
				if (meshRadio['.name'] == (radio2g && radio2g['.name']) && secondaryIface2g)
					uci.remove('wireless', secondaryIface2g);

				if (meshRadio['.name'] == (radio5g && radio5g['.name']) && secondaryIface5g)
					uci.remove('wireless', secondaryIface5g);
			}
		}

                uci.sections('wireless', 'wifi-iface').forEach(function(section) {
                        var sid = section['.name'];
                        var sectionNetworks = normalizeList(section.network);
                        var isLocalRadio = localRadios.some(function(radio) {
                                return section.device == radio['.name'];
                        });

                        if (section.mode == null || section.mode == 'ap')
                                uci.set('wireless', sid, 'disassoc_low_ack', '0');

                        if (!isLocalRadio)
                                return;

                        if (section.mode != null && section.mode != 'ap')
                                return;

                        if (sid === 'wizard_hotspot') {
                                return; // managed by applyHotspotSettings
                        }

                        // Remove AP interfaces that are unmanaged (ghost SSIDs)
                        if (!managedSids[sid]) {
                                uci.remove('wireless', sid);
                                return;
                        }

                        if (sectionNetworks.indexOf('lan') > -1) {
                                if (vlanOnlyAp) {
                                        uci.remove('wireless', sid);
                                        return;
                                }

                                if (lanPolicy.enableWds)
                                        uci.set('wireless', sid, 'wds', '1');
                                else
                                        uci.unset('wireless', sid, 'wds');

                                applyWifiIfaceFlag('wireless', sid, 'hidden', lanPolicy.hidden);
                                applyWifiIfaceFlag('wireless', sid, 'isolate', lanPolicy.isolate);
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                        else if (sectionNetworks.indexOf('wizardvlan') > -1) {
                                if (vlanPolicy.enableWds)
                                        uci.set('wireless', sid, 'wds', '1');
                                else
                                        uci.unset('wireless', sid, 'wds');

                                applyWifiIfaceFlag('wireless', sid, 'hidden', vlanPolicy.hidden);
                                applyWifiIfaceFlag('wireless', sid, 'isolate', vlanPolicy.isolate);
                                uci.set('wireless', sid, 'disabled', '0');
                        }
                        else {
                                // Remove ghost interfaces that aren't lan/vlan (orphaned hotspot SSIDs etc.)
                                uci.remove('wireless', sid);
                        }
                });

	},

	applyVlanSettings: function(state) {
		var firewallLanZone = findFirewallZone('lan');

		if (state.hotspotQuickEnabled)
			state.isVlan = false;

		uci.set('network', 'lan', 'ageing_time', '10');
		ensureBridgeAgingTime('br-lan', 10);

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
			uci.set('network', 'wizard_vlan_bridge', 'ageing_time', '10');

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

	testHotspotQuickRadius: function() {
		var self = this;

		self.collectState();

		if (!isIPv4(self.state.hotspotQuickRadiusServer)) {
			notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS أولاً.'));
			return Promise.resolve();
		}

		if (!self.state.hotspotQuickRadiusSecret) {
			notify(_('كلمة سر RADIUS مطلوبة قبل الاختبار.'));
			return Promise.resolve();
		}

		if (self.refs.hotspotQuickRadiusTestButton)
			self.refs.hotspotQuickRadiusTestButton.disabled = true;

		if (self.refs.hotspotQuickRadiusTestStatus)
			self.refs.hotspotQuickRadiusTestStatus.textContent = _('جارٍ الاختبار...');

		return L.resolveDefault(fs.exec_direct(HOTSPOT_TEST_RADIUS_CMD, [
			self.state.hotspotQuickRadiusServer,
			self.state.hotspotQuickRadiusAuthPort || '1812',
			self.state.hotspotQuickRadiusAcctPort || '1813',
			self.state.hotspotQuickCoaEnabled ? (self.state.hotspotQuickCoaPort || '3799') : '0'
		], 'json'), null).then(function(result) {
			var message = result && result.message ? result.message : _('تعذر قراءة نتيجة الاختبار.');

			if (self.refs.hotspotQuickRadiusTestStatus)
				self.refs.hotspotQuickRadiusTestStatus.textContent = message;

			if (!result || !result.ok)
				notify(message);
		}).finally(function() {
			if (self.refs.hotspotQuickRadiusTestButton)
				self.refs.hotspotQuickRadiusTestButton.disabled = false;
		});
	},

	testHotspotQuickRest: function() {
		var self = this;

		self.collectState();

		if (!isIPv4(self.state.hotspotQuickRadiusServer)) {
			notify(_('أدخل عنوان IPv4 صالحاً لميكروتك (RADIUS Server) أولاً.'));
			return Promise.resolve();
		}

		if (!self.state.hotspotQuickUsermanRestUsername || !self.state.hotspotQuickUsermanRestPassword) {
			notify(_('بيانات الدخول (API/REST) مطلوبة قبل الاختبار.'));
			return Promise.resolve();
		}

		if (self.refs.hotspotQuickRestTestButton)
			self.refs.hotspotQuickRestTestButton.disabled = true;

		if (self.refs.hotspotQuickRestTestStatus)
			self.refs.hotspotQuickRestTestStatus.textContent = _('جارٍ الاختبار...');

		var port = (self.state.hotspotQuickUsermanRestScheme == 'http') ? '80' : '443';

		return L.resolveDefault(fs.exec_direct(HOTSPOT_TEST_REST_CMD, [
			self.state.hotspotQuickRadiusServer,
			port,
			self.state.hotspotQuickUsermanRestUsername,
			self.state.hotspotQuickUsermanRestPassword,
			self.state.hotspotQuickUsermanRestScheme
		], 'json'), null).then(function(result) {
			var message = result && result.message ? result.message : _('تعذر قراءة نتيجة الاختبار.');

			if (self.refs.hotspotQuickRestTestStatus)
				self.refs.hotspotQuickRestTestStatus.textContent = message;

			if (!result || !result.ok)
				notify(message);
		}).finally(function() {
			if (self.refs.hotspotQuickRestTestButton)
				self.refs.hotspotQuickRestTestButton.disabled = false;
		});
	},

	normalizeAnonymousWifiIfaces: function() {
		var wifiIfaces = uci.sections('wireless', 'wifi-iface');
		var usedNames = {};
		var nextId = 0;
		var tasks = [];

		wifiIfaces.forEach(function(iface) {
			if (!iface['.anonymous'])
				usedNames[iface['.name']] = true;
		});

		wifiIfaces.forEach(function(iface) {
			var newName;

			if (!iface['.anonymous'])
				return;

			do {
				newName = 'wifinet' + String(nextId++);
			} while (usedNames[newName]);

			usedNames[newName] = true;
			tasks.push(fs.exec('/sbin/uci', [ 'rename', 'wireless.' + iface['.name'] + '=' + newName ]));
		});

		if (!tasks.length)
			return Promise.resolve(false);

		return Promise.all(tasks).then(function() {
			return fs.exec('/sbin/uci', [ 'commit', 'wireless' ]);
		}).then(function(res) {
			if (res.code != 0)
				throw new Error('uci commit wireless failed: ' + (res.stderr || res.code));

			if (typeof uci.unload == 'function')
				uci.unload('wireless');

			return uci.load('wireless');
		}).then(function() {
			return true;
		});
	},

	saveAndApply: function() {
		var self = this;
		var oldLanIpaddr = uci.get('network', 'lan', 'ipaddr') || self.state.lanIpaddr;
		var oldSsid = self.state.wifiSsid;
		var migratedAnonymousWifi = false;

		if (!self.validateStep(self.stepIndex))
			return;

		if (self.stepIndex !== 0 && !self.validateStep(0)) {
			self.stepIndex = 0;
			self.updateStepUi();
			return;
		}

		self.collectState();
		enforceHotspotNoVlan(self.state);

		if (self.state.hotspotQuickEnabled)
			self.state.mode = 'ap';

		self.refs.saveButton.disabled = true;
		self.refs.saveButton.textContent = (self.state.hotspotQuickEnabled || self.state.hotspotEnabled) ? _('جارٍ فحص الترخيص...') : _('جارٍ التطبيق...');

		confirmHotspotLicenseBeforeSetupApply(self.state).then(function(allowed) {
			if (!allowed)
				throw new Error(_('تم إلغاء التطبيق بناءً على حالة الترخيص.'));

			self.refs.saveButton.textContent = _('جارٍ التطبيق...');
			return self.normalizeAnonymousWifiIfaces();
		}).then(function(migrated) {
			migratedAnonymousWifi = !!migrated;
			self.radios = uci.sections('wireless', 'wifi-device');
			self.state.hotspotQuickWanInterface = normalizeInterfaceName(self.state.hotspotQuickWanInterface, 'lan');
			self.state.hotspotQuickSubscriberInterface = normalizeInterfaceName(self.state.hotspotQuickSubscriberInterface, 'hotspot');
			self.state.hotspotQuickSubscriberInterface2 = deriveHotspotQuickSecondaryInterface(self.state.hotspotQuickSubscriberInterface);
			self.state.hotspotQuickPolicy1 = normalizeHotspotPolicy(self.state.hotspotQuickPolicy1, 'standard');
			self.state.hotspotQuickPolicy2 = normalizeHotspotPolicy(self.state.hotspotQuickPolicy2, 'premium');

			ensureNamedSection('setup', 'default', 'setup');

			uci.set('setup', 'default', 'lan_ipaddr', self.state.lanIpaddr);
			uci.set('setup', 'default', 'lan_netmask', self.state.lanNetmask);
			uci.set('setup', 'default', 'initial_setup_complete', '1');
			uci.set('setup', 'default', 'mode', self.state.mode);
			uci.set('setup', 'default', 'wifi_ssid', self.state.wifiSsid);
			uci.set('setup', 'default', 'wifi_ssid_5g_mode', self.state.wifiSsid5gMode || 'derived');
			uci.set('setup', 'default', 'wifi_ssid_5g', self.state.wifiSsid5g || '');
			uci.set('setup', 'default', 'wifi_ssid_vlan', self.state.wifiSsidVlan2g || '');
			uci.set('setup', 'default', 'wifi_ssid_vlan_2g', self.state.wifiSsidVlan2g || '');
			uci.set('setup', 'default', 'wifi_ssid_vlan_5g', self.state.wifiSsidVlan5g || '');
			uci.set('setup', 'default', 'wifi_ssid_vlan_ip_suffix', self.state.wifiSsidVlanIpSuffix ? '1' : '0');
			uci.set('setup', 'default', 'wifi_key', self.state.wifiKey);
			uci.set('setup', 'default', 'uplink_ssid', self.state.uplinkSsid);
			uci.set('setup', 'default', 'uplink_key', self.state.uplinkKey);
			uci.set('setup', 'default', 'uplink_band', self.state.uplinkBand);
			uci.set('setup', 'default', 'mesh_id', self.state.meshId);
			uci.set('setup', 'default', 'mesh_key', self.state.meshKey);
			uci.set('setup', 'default', 'mesh_band', self.state.meshBand);
			uci.set('setup', 'default', 'hotspot_quick_enabled', self.state.hotspotQuickEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_wan_interface', self.state.hotspotQuickWanInterface);
			uci.set('setup', 'default', 'hotspot_quick_subscriber_interface', self.state.hotspotQuickSubscriberInterface);
			uci.set('setup', 'default', 'hotspot_quick_subscriber_interface_2', self.state.hotspotQuickSubscriberInterface2 || 'hotspot2');
			uci.set('setup', 'default', 'hotspot_quick_ssid_1', self.state.hotspotQuickSsid1 || 'Hotspot-1');
			uci.set('setup', 'default', 'hotspot_quick_gateway_1', self.state.hotspotQuickGateway1 || '192.168.10.1');
			uci.set('setup', 'default', 'hotspot_quick_pool_start_1', self.state.hotspotQuickPoolStart1 || '192.168.10.10');
			uci.set('setup', 'default', 'hotspot_quick_pool_end_1', self.state.hotspotQuickPoolEnd1 || '192.168.10.199');
			uci.set('setup', 'default', 'hotspot_quick_policy_1', self.state.hotspotQuickPolicy1);
			uci.set('setup', 'default', 'hotspot_quick_secondary_enabled', self.state.hotspotQuickSecondaryEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_ssid_2', self.state.hotspotQuickSsid2 || 'Hotspot-2');
			uci.set('setup', 'default', 'hotspot_quick_gateway_2', self.state.hotspotQuickGateway2 || '192.168.20.1');
			uci.set('setup', 'default', 'hotspot_quick_pool_start_2', self.state.hotspotQuickPoolStart2 || '192.168.20.10');
			uci.set('setup', 'default', 'hotspot_quick_pool_end_2', self.state.hotspotQuickPoolEnd2 || '192.168.20.199');
			uci.set('setup', 'default', 'hotspot_quick_policy_2', self.state.hotspotQuickPolicy2);
			uci.set('setup', 'default', 'hotspot_quick_radius_server', self.state.hotspotQuickRadiusServer || '192.168.1.2');
			uci.set('setup', 'default', 'hotspot_quick_radius_server2', self.state.hotspotQuickRadiusServer2 || '');
			uci.set('setup', 'default', 'hotspot_quick_radius_secret', self.state.hotspotQuickRadiusSecret || '');
			uci.set('setup', 'default', 'hotspot_quick_radius_auth_port', normalizePort(self.state.hotspotQuickRadiusAuthPort, '1812'));
			uci.set('setup', 'default', 'hotspot_quick_radius_acct_port', normalizePort(self.state.hotspotQuickRadiusAcctPort, '1813'));
			uci.set('setup', 'default', 'hotspot_quick_radius_nas_ip', self.state.hotspotQuickRadiusNasIp || '');
			uci.set('setup', 'default', 'hotspot_quick_nas_id', self.state.hotspotQuickNasId || '');
			uci.set('setup', 'default', 'hotspot_quick_acct_interim', normalizePositiveNumber(self.state.hotspotQuickAcctInterim, '60'));
			uci.set('setup', 'default', 'hotspot_quick_coa_enabled', self.state.hotspotQuickCoaEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_coa_port', normalizePort(self.state.hotspotQuickCoaPort, '3799'));
			uci.set('setup', 'default', 'hotspot_quick_trial_enabled', self.state.hotspotQuickTrialEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_trial_duration', normalizePositiveNumber(self.state.hotspotQuickTrialDuration, '30'));
			uci.set('setup', 'default', 'hotspot_quick_trial_uptime_limit', normalizePositiveNumber(self.state.hotspotQuickTrialUptimeLimit, '30'));
			uci.set('setup', 'default', 'hotspot_quick_mac_auth_enabled', self.state.hotspotQuickMacAuthEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_mac_auth_suffix', self.state.hotspotQuickMacAuthSuffix || '@mac');
			uci.set('setup', 'default', 'hotspot_quick_mac_auth_password', self.state.hotspotQuickMacAuthPassword || 'mac');
			uci.set('setup', 'default', 'hotspot_quick_walled_garden', splitQuickList(self.state.hotspotQuickWalledGarden).join(' '));
			uci.set('setup', 'default', 'hotspot_quick_domain', self.state.hotspotQuickDomain || 'hotspot.local');
			uci.set('setup', 'default', 'hotspot_quick_dns1', self.state.hotspotQuickDns1 || '8.8.8.8');
			uci.set('setup', 'default', 'hotspot_quick_dns2', self.state.hotspotQuickDns2 || '82.114.163.31');
			uci.set('setup', 'default', 'hotspot_quick_bridge_ageing_time', normalizePositiveNumber(self.state.hotspotQuickBridgeAgeingTime || '10', '10'));
			uci.set('setup', 'default', 'hotspot_quick_login_mode', normalizeHotspotLoginMode(self.state.hotspotQuickLoginMode));
			uci.set('setup', 'default', 'hotspot_quick_rate_limit', self.state.hotspotQuickRateLimit || '2M/5M');
			uci.set('setup', 'default', 'hotspot_quick_mac_cookie_enabled', self.state.hotspotQuickMacCookieEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_available_speeds', self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
			uci.set('setup', 'default', 'hotspot_quick_support_phone', self.state.hotspotQuickSupportPhone || '');
			uci.set('setup', 'default', 'hotspot_quick_notice_text', self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا');
			uci.set('setup', 'default', 'hotspot_quick_live_stream_enabled', self.state.hotspotQuickLiveStreamEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_live_stream_url', self.state.hotspotQuickLiveStreamUrl || '');
			uci.set('setup', 'default', 'hotspot_quick_rest_area_enabled', self.state.hotspotQuickRestAreaEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_rest_area_url', self.state.hotspotQuickRestAreaUrl || '');
			uci.set('setup', 'default', 'hotspot_quick_speedtest_enabled', self.state.hotspotQuickSpeedtestEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_browser_cookie_enabled', self.state.hotspotQuickBrowserCookieEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_browser_cookie_days', normalizeBrowserCookieDays(self.state.hotspotQuickBrowserCookieDays || '7'));
			uci.set('setup', 'default', 'hotspot_quick_userman_rest_enabled', self.state.hotspotQuickUsermanRestEnabled ? '1' : '0');
			uci.set('setup', 'default', 'hotspot_quick_userman_rest_scheme', normalizeRouterOsScheme(self.state.hotspotQuickUsermanRestScheme));
			uci.set('setup', 'default', 'hotspot_quick_userman_rest_username', self.state.hotspotQuickUsermanRestUsername || 'hotspot-read');
			uci.set('setup', 'default', 'hotspot_quick_userman_rest_password', self.state.hotspotQuickUsermanRestPassword || '');
			uci.set('setup', 'default', 'is_vlan', self.state.isVlan ? '1' : '0');
			uci.set('setup', 'default', 'vlan_id', self.state.vlanId || '10');
			uci.set('setup', 'default', 'channel_2g', self.state.channel2g || 'auto');
			uci.set('setup', 'default', 'channel_5g', self.state.channel5g || 'auto');
			uci.set('setup', 'default', 'wifi_mode_2g', normalizeWifiModeForBand('2g', self.state.wifiMode2g));
			uci.set('setup', 'default', 'wifi_width_2g', normalizeWifiWidthForBand('2g', self.state.wifiMode2g, self.state.wifiWidth2g));
			uci.set('setup', 'default', 'wifi_mode_5g', normalizeWifiModeForBand('5g', self.state.wifiMode5g));
			uci.set('setup', 'default', 'wifi_width_5g', normalizeWifiWidthForBand('5g', self.state.wifiMode5g, self.state.wifiWidth5g));
			uci.set('setup', 'default', 'reset_button_disabled', self.state.resetDisabled ? '1' : '0');
			uci.set('setup', 'default', 'reset_hold_seconds', self.state.resetHoldSeconds || '5');
			uci.set('setup', 'default', 'wps_button_disabled', self.state.wpsDisabled ? '1' : '0');

			if (self.state.otaWindowAvailable) {
				ensureNamedSection('alemprator_ota', 'main', 'ota');
				uci.set('alemprator_ota', 'main', 'window_start', String(normalizeHour(self.state.otaWindowStart, 2)));
				uci.set('alemprator_ota', 'main', 'window_end', String(normalizeHour(self.state.otaWindowEnd, 6)));
			}

			uci.set('network', 'lan', 'proto', 'static');
			uci.set('network', 'lan', 'ipaddr', self.state.lanIpaddr);
			uci.set('network', 'lan', 'netmask', self.state.lanNetmask);

			var lanGateway = deriveLanGateway(self.state.lanIpaddr);
			if (lanGateway)
				uci.set('network', 'lan', 'gateway', lanGateway);
			else
				uci.unset('network', 'lan', 'gateway');

			disableFirstbootProvisioning();

			if (self.state.hotspotQuickEnabled) {
				var quickSubscriber = self.state.hotspotQuickSubscriberInterface;
				var quickDeviceSection = quickSubscriber + '_dev';
				var quickDeviceName = (quickSubscriber == 'hotspot') ? 'br-hotspot' : ('br-' + quickSubscriber);
				var quickSubscriberSecondary = self.state.hotspotQuickSubscriberInterface2 || deriveHotspotQuickSecondaryInterface(quickSubscriber);
				var quickDeviceSectionSecondary = quickSubscriberSecondary + '_dev';
				var quickDeviceNameSecondary = (quickSubscriberSecondary == 'hotspot') ? 'br-hotspot' : ('br-' + quickSubscriberSecondary);

				ensureNamedSection('network', quickDeviceSection, 'device');
				uci.set('network', quickDeviceSection, 'name', quickDeviceName);
				uci.set('network', quickDeviceSection, 'type', 'bridge');
				uci.set('network', quickDeviceSection, 'bridge_empty', '1');
				uci.set('network', quickDeviceSection, 'ipv6', '0');

				ensureNamedSection('network', quickSubscriber, 'interface');
				uci.set('network', quickSubscriber, 'proto', 'none');
				uci.set('network', quickSubscriber, 'device', quickDeviceName);
				uci.unset('network', quickSubscriber, 'ipaddr');
				uci.unset('network', quickSubscriber, 'netmask');
				uci.unset('network', quickSubscriber, 'gateway');

				if (self.state.hotspotQuickSecondaryEnabled) {
					ensureNamedSection('network', quickDeviceSectionSecondary, 'device');
					uci.set('network', quickDeviceSectionSecondary, 'name', quickDeviceNameSecondary);
					uci.set('network', quickDeviceSectionSecondary, 'type', 'bridge');
					uci.set('network', quickDeviceSectionSecondary, 'bridge_empty', '1');
					uci.set('network', quickDeviceSectionSecondary, 'ipv6', '0');

					ensureNamedSection('network', quickSubscriberSecondary, 'interface');
					uci.set('network', quickSubscriberSecondary, 'proto', 'none');
					uci.set('network', quickSubscriberSecondary, 'device', quickDeviceNameSecondary);
					uci.unset('network', quickSubscriberSecondary, 'ipaddr');
					uci.unset('network', quickSubscriberSecondary, 'netmask');
					uci.unset('network', quickSubscriberSecondary, 'gateway');
				}
				else {
					uci.remove('network', quickDeviceSectionSecondary);
					uci.remove('network', quickSubscriberSecondary);
				}

				ensureNamedSection('hotspot_openwrt', 'main', 'hotspot');
				uci.set('hotspot_openwrt', 'main', 'enabled', '1');
				uci.set('hotspot_openwrt', 'main', 'wan_interface', self.state.hotspotQuickWanInterface);
				uci.set('hotspot_openwrt', 'main', 'subscriber_interface', self.state.hotspotQuickSubscriberInterface);
				uci.set('hotspot_openwrt', 'main', 'wifi_iface', '');
				uci.set('hotspot_openwrt', 'main', 'hotspot_ip', self.state.hotspotQuickGateway1 || '192.168.10.1');
				uci.set('hotspot_openwrt', 'main', 'hotspot_cidr', '24');
				uci.set('hotspot_openwrt', 'main', 'pool_start', self.state.hotspotQuickPoolStart1 || '192.168.10.10');
				uci.set('hotspot_openwrt', 'main', 'pool_end', self.state.hotspotQuickPoolEnd1 || '192.168.10.199');
				uci.set('hotspot_openwrt', 'main', 'bridge_ageing_time', normalizePositiveNumber(self.state.hotspotQuickBridgeAgeingTime || '10', '10'));
				uci.set('hotspot_openwrt', 'main', 'network_name', self.state.hotspotQuickSsid1 || 'Hotspot-1');
				uci.set('hotspot_openwrt', 'main', 'domain', self.state.hotspotQuickDomain || 'hotspot.local');
				uci.set('hotspot_openwrt', 'main', 'dns', [ self.state.hotspotQuickDns1 || '8.8.8.8', self.state.hotspotQuickDns2 || '82.114.163.31' ]);
				uci.set('hotspot_openwrt', 'main', 'login_mode', normalizeHotspotLoginMode(self.state.hotspotQuickLoginMode));
				uci.set('hotspot_openwrt', 'main', 'rate_limit_rx_tx', self.state.hotspotQuickRateLimit || '2M/5M');
				uci.set('hotspot_openwrt', 'main', 'mac_cookie_enabled', self.state.hotspotQuickMacCookieEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'available_speeds', self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
				uci.set('hotspot_openwrt', 'main', 'support_phone', self.state.hotspotQuickSupportPhone || '');
				uci.set('hotspot_openwrt', 'main', 'notice_text', self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا');
				uci.set('hotspot_openwrt', 'main', 'live_stream_enabled', self.state.hotspotQuickLiveStreamEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'live_stream_url', self.state.hotspotQuickLiveStreamUrl || '');
				uci.set('hotspot_openwrt', 'main', 'rest_area_enabled', self.state.hotspotQuickRestAreaEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'rest_area_url', self.state.hotspotQuickRestAreaUrl || '');
				uci.set('hotspot_openwrt', 'main', 'speedtest_enabled', self.state.hotspotQuickSpeedtestEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'maint_enabled', self.state.hotspotQuickMaintEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'maint_start', self.state.hotspotQuickMaintStart || '02:00');
				uci.set('hotspot_openwrt', 'main', 'maint_end', self.state.hotspotQuickMaintEnd || '03:00');
				uci.set('hotspot_openwrt', 'main', 'maint_mode', self.state.hotspotQuickMaintMode || 'free');
				uci.set('hotspot_openwrt', 'main', 'browser_cookie_enabled', self.state.hotspotQuickBrowserCookieEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'browser_cookie_days', normalizeBrowserCookieDays(self.state.hotspotQuickBrowserCookieDays || '7'));
				uci.set('hotspot_openwrt', 'main', 'userman_rest_enabled', self.state.hotspotQuickUsermanRestEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_scheme', normalizeRouterOsScheme(self.state.hotspotQuickUsermanRestScheme));
				uci.set('hotspot_openwrt', 'main', 'userman_rest_host', self.state.hotspotQuickRadiusServer || '192.168.1.2');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_port', normalizeRouterOsScheme(self.state.hotspotQuickUsermanRestScheme) == 'http' ? '80' : '443');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_username', self.state.hotspotQuickUsermanRestUsername || 'hotspot-read');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_password', self.state.hotspotQuickUsermanRestPassword || '');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_insecure_ssl', '1');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_user_field', 'name');
				uci.set('hotspot_openwrt', 'main', 'userman_rest_timeout', '5');
				uci.set('hotspot_openwrt', 'main', 'captive_notify', '1');
				uci.set('hotspot_openwrt', 'main', 'quick_setup_enabled', '1');
				uci.set('hotspot_openwrt', 'main', 'quick_no_vlan', '1');
				uci.set('hotspot_openwrt', 'main', 'quick_wan_interface', self.state.hotspotQuickWanInterface);
				uci.set('hotspot_openwrt', 'main', 'quick_subscriber_interface', self.state.hotspotQuickSubscriberInterface);
				uci.set('hotspot_openwrt', 'main', 'quick_subscriber_interface_secondary', quickSubscriberSecondary);
				uci.set('hotspot_openwrt', 'main', 'quick_runtime_dual_enabled', self.state.hotspotQuickSecondaryEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'quick_ssid_primary', self.state.hotspotQuickSsid1 || 'Hotspot-1');
				uci.set('hotspot_openwrt', 'main', 'quick_gateway_primary', self.state.hotspotQuickGateway1 || '192.168.10.1');
				uci.set('hotspot_openwrt', 'main', 'quick_pool_start_primary', self.state.hotspotQuickPoolStart1 || '192.168.10.10');
				uci.set('hotspot_openwrt', 'main', 'quick_pool_end_primary', self.state.hotspotQuickPoolEnd1 || '192.168.10.199');
				uci.set('hotspot_openwrt', 'main', 'quick_policy_primary', self.state.hotspotQuickPolicy1);
				uci.set('hotspot_openwrt', 'main', 'quick_ssid_secondary', self.state.hotspotQuickSsid2 || 'Hotspot-2');
				uci.set('hotspot_openwrt', 'main', 'quick_gateway_secondary', self.state.hotspotQuickGateway2 || '192.168.20.1');
				uci.set('hotspot_openwrt', 'main', 'quick_pool_start_secondary', self.state.hotspotQuickPoolStart2 || '192.168.20.10');
				uci.set('hotspot_openwrt', 'main', 'quick_pool_end_secondary', self.state.hotspotQuickPoolEnd2 || '192.168.20.199');
				uci.set('hotspot_openwrt', 'main', 'quick_policy_secondary', self.state.hotspotQuickPolicy2);
				uci.set('hotspot_openwrt', 'main', 'radius_server', self.state.hotspotQuickRadiusServer || '192.168.1.2');
				if (self.state.hotspotQuickRadiusServer2)
					uci.set('hotspot_openwrt', 'main', 'radius_server2', self.state.hotspotQuickRadiusServer2);
				else
					uci.unset('hotspot_openwrt', 'main', 'radius_server2');
				uci.set('hotspot_openwrt', 'main', 'radius_secret', self.state.hotspotQuickRadiusSecret || '');
				uci.set('hotspot_openwrt', 'main', 'radius_auth_port', normalizePort(self.state.hotspotQuickRadiusAuthPort, '1812'));
				uci.set('hotspot_openwrt', 'main', 'radius_acct_port', normalizePort(self.state.hotspotQuickRadiusAcctPort, '1813'));
				if (self.state.hotspotQuickRadiusNasIp)
					uci.set('hotspot_openwrt', 'main', 'radius_nas_ip', self.state.hotspotQuickRadiusNasIp);
				else
					uci.unset('hotspot_openwrt', 'main', 'radius_nas_ip');
				if (self.state.hotspotQuickNasId)
					uci.set('hotspot_openwrt', 'main', 'radius_nas_id', self.state.hotspotQuickNasId);
				else
					uci.unset('hotspot_openwrt', 'main', 'radius_nas_id');
				uci.set('hotspot_openwrt', 'main', 'acct_interim', normalizePositiveNumber(self.state.hotspotQuickAcctInterim, '60'));
				uci.set('hotspot_openwrt', 'main', 'coa_enabled', self.state.hotspotQuickCoaEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'coa_port', normalizePort(self.state.hotspotQuickCoaPort, '3799'));
				uci.set('hotspot_openwrt', 'main', 'trial_enabled', self.state.hotspotQuickTrialEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'trial_duration', normalizePositiveNumber(self.state.hotspotQuickTrialDuration, '30'));
				uci.set('hotspot_openwrt', 'main', 'trial_uptime_limit', normalizePositiveNumber(self.state.hotspotQuickTrialUptimeLimit, '30'));
				uci.set('hotspot_openwrt', 'main', 'mac_auth_enabled', self.state.hotspotQuickMacAuthEnabled ? '1' : '0');
				uci.set('hotspot_openwrt', 'main', 'mac_auth_suffix', self.state.hotspotQuickMacAuthSuffix || '@mac');
				uci.set('hotspot_openwrt', 'main', 'mac_auth_password', self.state.hotspotQuickMacAuthPassword || 'mac');
				var quickWalledGarden = splitQuickList(self.state.hotspotQuickWalledGarden);
				if (quickWalledGarden.length)
					uci.set('hotspot_openwrt', 'main', 'walled_garden', quickWalledGarden);
				else
					uci.unset('hotspot_openwrt', 'main', 'walled_garden');
			}
			else if (uci.get('hotspot_openwrt', 'main')) {
				uci.set('hotspot_openwrt', 'main', 'quick_setup_enabled', '0');
				uci.set('hotspot_openwrt', 'main', 'quick_runtime_dual_enabled', '0');
			}

			self.applyVlanSettings(self.state);
			self.applyWifiSettings(self.state, self.radios);
			self.applyPeriodicRebootSettings(self.state);
			self.applyHotspotSettings(self.state, self.radios);

			if (!(self.state || {}).hotspotQuickEnabled && !self.state.hotspotEnabled)
				cleanupHotspotWizardState();

			return uci.save();
		}).then(function() {
			return ui.changes.apply();
		}).then(function() {
			if (!(self.state || {}).hotspotQuickEnabled && !self.state.hotspotEnabled)
				return L.resolveDefault(fs.exec(HOTSPOT_CLEANUP_CMD, [ '--force', '--reload' ]), null).then(function() {
					return L.resolveDefault(fs.exec(HOTSPOT_INIT_CMD, [ 'stop' ]), null);
				});
		}).then(function() {
			if (self.state.hotspotAvailable && self.state.hotspotEnabled) {
				return runApply('/usr/libexec/hotspot-openwrt/apply', [], _('تم تطبيق إعدادات الهوتسبوت بنجاح.'), true).catch(function() {
					notify(_('تحذير: تعذر تطبيق إعدادات الهوتسبوت تلقائياً. يمكن تطبيقها يدوياً من صفحة الخدمات.'));
				});
			}
		}).then(function() {
			var changedIp = self.state.lanIpaddr != oldLanIpaddr;
			var hotspotApplyPromise = (self.state.hotspotQuickEnabled && !self.state.hotspotEnabled)
				? runApply(HOTSPOT_APPLY_CMD, [], _('تم تطبيق الهوتسبوت السريع بنجاح.'), true)
				: Promise.resolve(null);

			return hotspotApplyPromise.then(function(hotspotApplyResult) {
				if (!self.state.adminPassword) {
					return {
						changedIp: changedIp,
						passwordChanged: null,
						hotspotApplyResult: hotspotApplyResult
					};
				}

				return L.resolveDefault(callSetPassword('root', self.state.adminPassword), false).then(function(success) {
					return {
						changedIp: changedIp,
						passwordChanged: !!success,
						hotspotApplyResult: hotspotApplyResult
					};
				});
			});
		}).then(function(result) {
			var modeMessage = self.state.hotspotQuickEnabled
				? _('تم تفعيل مسار الهوتسبوت السريع على وضع نقطة الوصول.')
				: describeAppliedModeResult(self.state, self.radios || []);
			var secondaryNetworkMessage = self.state.hotspotQuickEnabled ? null : describeAppliedSecondaryNetworkResult(self.state, self.radios || []);
			var reconnectMessage = describeReconnectHint(self.state, self.radios || [], oldSsid);

			self.refs.saveButton.disabled = false;
			self.refs.saveButton.textContent = _('حفظ وتطبيق');
			self.refs.adminPassword.value = '';
			self.refs.adminPasswordConfirm.value = '';
			self.state.adminPassword = '';
			self.state.adminPasswordConfirm = '';

			if (migratedAnonymousWifi)
				notify(_('تمت ترقية أقسام الواي فاي القديمة تلقائيًا. لن تحتاج إلى الضغط على Continue من صفحة Wireless بعد الآن.'));

			if (result.passwordChanged === true)
				notify(_('تم تغيير كلمة مرور الجهاز بنجاح.'));
			else if (result.passwordChanged === false)
				notify(_('تم تطبيق الإعدادات، لكن تعذر تغيير كلمة مرور الجهاز.'));

			if (self.state.hotspotQuickEnabled) {
				if (result.hotspotApplyResult && result.hotspotApplyResult.ok === true)
					notify(_('تم تطبيق الهوتسبوت السريع بنجاح.'));
				else if (result.hotspotApplyResult && result.hotspotApplyResult.ok === false)
					notify(_('تم حفظ إعدادات الهوتسبوت السريع لكن الخدمة أعادت رسالة خطأ: ') + String(result.hotspotApplyResult.message || _('غير معروفة')));
				else
					notify(_('تم حفظ إعدادات الهوتسبوت السريع. تأكد من حالة الخدمة من صفحة الهوتسبوت.'));
			}

			if (modeMessage)
				notify(modeMessage);

			if (secondaryNetworkMessage)
				notify(secondaryNetworkMessage);

			if (result.changedIp) {
				notify(_('تم تطبيق الإعدادات. تغيّر عنوان LAN إلى ') + self.state.lanIpaddr + _('، وسيتم فتح الصفحة الافتراضية على العنوان الجديد خلال بضع ثوانٍ.'));
				scheduleDefaultAdminRedirect(self.state.lanIpaddr, 8000);
			}
			else {
				notify(_('تم تطبيق الإعدادات بنجاح. سيتم نقلك إلى الصفحة الافتراضية بعد إعادة تحميل الإعدادات.'));
				scheduleDefaultAdminRedirect(self.state.lanIpaddr, 2500);
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
		ensureSetupStyles();
        
        // --- ♛ ALEMPRATOR LUXURY ENGINE ♛ ---
        var callNetworkStatus = L.rpc.declare({ object: 'network.interface.wan', method: 'status' });
        
        self.state = {};
		self.refs = {};
		self.stepPanels = [];
		self.stepBadges = [];
		self.stepChips = [];
		self.stepIndex = 0;

		// Branding
		var brand = document.querySelector('header a.brand') || document.querySelector('header a');
		if (brand) brand.innerHTML = '♛ <span style="color:#D4AF37; font-weight:bold; letter-spacing:2px">ALEMPRATOR</span>';
        
        // 1. Progress Bar
        var progressBar = E('div', { 'class': 'alemprator-progress-container' }, [
            self.refs.progressFill = E('div', { 'class': 'alemprator-progress-fill' })
        ]);

        // 2. WAN Pulse
        var wanPulse = E('span', { 'class': 'alemprator-status-pulse status-err', 'id': 'alemprator-wan-pulse' });
        var checkWan = function() {
            callNetworkStatus().then(function(res) {
                var el = document.getElementById('alemprator-wan-pulse');
                if (!el) return;
                var isUp = !!(res && res.up);
                el.className = 'alemprator-status-pulse ' + (isUp ? 'status-ok' : 'status-err');
            }).catch(function(){});
        };
        setInterval(checkWan, 5000);
        setTimeout(checkWan, 1000);

        // 3. Force Show Menus
        try {
            if (!window._alemprator_timer) {
                window._alemprator_timer = setInterval(function() {
                    ['#topmenu', '.nav', '.side-nav'].forEach(function(s) {
                        var el = document.querySelector(s);
                        if (el && el.style.display === 'none') {
                            el.style.setProperty('display', 'flex', 'important');
                            el.style.setProperty('visibility', 'visible', 'important');
                            el.style.setProperty('opacity', '1', 'important');
                        }
                    });
                }, 500);
            }
        } catch(e) {}

        // 4. Mode Grid System
        var createModeCard = function(val, icon, title, desc) {
            var isActive = (self.state.mode == val || (val == 'hotspot' && self.state.hotspotQuickEnabled));
            return E('div', { 
                'class': 'alemprator-mode-card' + (isActive ? ' is-active' : ''),
                'click': function(ev) {
                    document.querySelectorAll('.alemprator-mode-card').forEach(function(c){ c.classList.remove('is-active'); });
                    ev.currentTarget.classList.add('is-active');
                    if (val === 'hotspot') {
                        self.refs.mode.value = 'ap';
                        self.state.mode = 'ap';
                        self.state.hotspotQuickEnabled = true;
                        self.state.hotspotQuickSecondaryEnabled = true;
                    } else {
                        self.refs.mode.value = val;
                        self.state.mode = val;
                        self.state.hotspotQuickEnabled = false;
                    }
                    self.updateStepUi();
                    setTimeout(function() {
                        self.nextStep();
                    }, 150);
                }
            }, [
                E('span', { 'class': 'alemprator-mode-card__icon' }, icon),
                E('span', { 'class': 'alemprator-mode-card__title' }, title),
                E('div', { 'class': 'alemprator-mode-card__desc' }, desc)
            ]);
        };

        var modeGrid = E('div', { 'class': 'alemprator-mode-grid' }, [
            createModeCard('ap', '📡', _('نقطة وصول (AP)'), _('توزيع إنترنت عبر كيبل')),
            createModeCard('hotspot', '🌐', _('الإمبراطور (Hotspot)'), _('تحكم سيادي بالمشتركين')),
            createModeCard('ap_wds', '🔗', _('نقطة وصول + WDS'), _('ربط لاسلكي شفاف')),
            createModeCard('sta_wds', '📥', _('استقبال لاسلكي'), _('لقط إنترنت وإعادة بثه')),
            createModeCard('mesh', '🕸️', _('ميش ذكي'), _('تغطية موحدة للمساحات'))
        ]);
        // --- END LUXURY ENGINE ---

		var statusContainer = E('div', { 'class': 'alemprator-setup-status-column' });
		var wizardContainer = E('div', { 'class': 'cbi-section alemprator-setup-wizard' });
		var radios = uci.sections('wireless', 'wifi-device');
		var frequencyMap = Array.isArray(data) ? (data[data.length - 1] || {}) : {};
		var radio2g = getRadioByBand(radios, '2g');
		var radio5g = getRadioByBand(radios, '5g');
		var stepNav = E('div', { 'class': 'alemprator-step-nav' });
		var stepsWrap = E('div', { 'class': 'cbi-section-node alemprator-steps-wrap' });
		var actions = E('div', { 'class': 'alemprator-setup-actions' });
		var panel = E('div', { 'class': 'alemprator-setup-shell' });
		var wizardIntro;
		var stepTitles = [ _('هوية الجهاز والوضع'), _('إعدادات الواي فاي'), _('شبكة الهوتسبوت'), _('صلاحيات الدخول'), _('المراجعة والتشغيل') ];
		var stepPanels = self.stepPanels;
		var stepBadges = self.stepBadges;
		var stepChips = self.stepChips;
		var radioSettingsCard;
		var i;

		self.radios = radios;
		self.frequencyMap = frequencyMap;
		self.state = self.readState(radios, Array.isArray(data) ? data[1] : null);
		self.statusContainer = statusContainer;

		ensureSetupStyles();

		panel.appendChild(statusContainer);
		self.refs.heroCurrentLan = E('span');
		self.refs.heroCurrentMode = E('span');
		self.refs.heroCurrentSecondary = E('span');
		self.refs.heroSetupSummary = E('span');
		self.refs.lanCardSummary = E('span');
		self.refs.modeCardSummary = E('span');
		self.refs.primaryWifiCardSummary = E('span');
		self.refs.wifiSecurityCardSummary = E('span');
		self.refs.uplinkCardSummary = E('span');
		self.refs.meshCardSummary = E('span');
		self.refs.vlanCardSummary = E('span');
		self.refs.radioCardSummary = E('span');
		self.refs.backupCardSummary = E('span');
		self.refs.firstbootCardSummary = E('span');
		self.refs.otaCardSummary = E('span');
		self.refs.buttonPoliciesCardSummary = E('span');
		self.refs.rebootCardSummary = E('span');
		self.refs.passwordCardSummary = E('span');
		self.refs.hotspotCardSummary = E('span');

		wizardIntro = E('div', { 'class': 'alemprator-card alemprator-card--hero' }, [
			E('div', { 'class': 'alemprator-hero__grid' }, [
				E('div', [
					E('h3', { 'class': 'alemprator-card__title alemprator-card__title--light' }, _('خطوات الإعداد')),
					E('p', { 'class': 'alemprator-card__desc alemprator-card__desc--light' }, _('تجهيز الجهاز في ثوانٍ.')),
					E('div', { 'class': 'alemprator-hero__actions' }, [
				E('a', {
					'href': VIDEO_EXPLAIN_URL,
					'target': '_blank',
					'rel': 'noopener noreferrer',
					'class': 'alemprator-hero__link'
				}, _('مشاهدة الشرح'))
					]),
					E('div', { 'class': 'alemprator-hero__summary' }, [ self.refs.heroSetupSummary ])
				]),
				E('div', { 'class': 'alemprator-hero__facts' }, [
					renderSummaryFact(_('حالة المنفذ'), E('span', [wanPulse, _(' فحص حي...')])), renderSummaryFact(_('العنوان المحلي'), self.refs.heroCurrentLan),
					renderSummaryFact(_('وضع التشغيل'), self.refs.heroCurrentMode)
				])
			])
		]);

		wizardContainer.appendChild(progressBar);
        
        // --- LUXURY LOGO OVERLAY ---
        wizardContainer.appendChild(E('div', { 'class': 'alemprator-luxury-logo' }, [
            E('div', { 'class': 'luxury-text' }, 'ALEMPRATOR'),
            E('div', { 'class': 'luxury-subtext' }, 'PLATINUM EDITION')
        ]));

		// modeGrid moved to step panel
		wizardContainer.appendChild(wizardIntro);
    

		for (i = 0; i < stepTitles.length; i++) {
			var badge = E('div', {
				'class': 'alemprator-step-chip',
				'click': (function(idx) {
					return function(ev) {
						self.stepIndex = idx;
						self.updateStepUi();
					};
				})(i)
			}, [
				E('span', {
					'class': 'alemprator-step-index'
				}, String(i + 1)),
				E('span', { 'class': 'alemprator-step-label' }, stepTitles[i])
			]);

			stepChips.push(badge);
			stepBadges.push(badge.firstChild);
			stepNav.appendChild(badge);
		}

		wizardContainer.appendChild(stepNav);

		self.refs.lanIpaddr = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.lanIpaddr, 'style': 'max-width:280px;' });
		self.refs.lanNetmask = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.lanNetmask, 'style': 'max-width:280px;' });
		
		self.refs.mode = E('select', { 'style': 'display:none' }, [
			E('option', { 'value': 'ap' }),
			E('option', { 'value': 'hotspot' }),
			E('option', { 'value': 'ap_wds' }),
			E('option', { 'value': 'sta_wds' }),
			E('option', { 'value': 'mesh' })
		]);

		self.refs.mode.value = self.state.mode;
		self.refs.wifiSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.wifiSsid, 'style': 'max-width:280px;' });
		self.refs.wifiSsid5gMode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, [
			E('option', { 'value': 'derived' }, _('تلقائي من الاسم الأساسي')),
			E('option', { 'value': 'custom' }, _('اسم مخصص'))
		]);
		self.refs.wifiSsid5gMode.value = self.state.wifiSsid5gMode || 'derived';
		self.refs.wifiSsid5g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.wifiSsid5g, 'style': 'max-width:280px;' });
		self.refs.wifiSsidVlan2g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.wifiSsidVlan2g, 'style': 'max-width:280px;' });
		self.refs.wifiSsidVlan5g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.wifiSsidVlan5g, 'style': 'max-width:280px;' });
		self.refs.wifiSsidIpSuffixPrimary = E('input', { 'type': 'checkbox' });
		self.refs.wifiSsidIpSuffixPrimary.checked = !!self.state.wifiSsidVlanIpSuffix;
		self.refs.wifiSsidVlanIpSuffix = E('input', { 'type': 'checkbox' });
		self.refs.wifiSsidVlanIpSuffix.checked = !!self.state.wifiSsidVlanIpSuffix;
		self.refs.wifiKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.wifiKey, 'style': 'max-width:280px;' });
		self.refs.uplinkSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.uplinkSsid, 'style': 'max-width:280px;' });
		self.refs.uplinkKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.uplinkKey, 'style': 'max-width:280px;' });
		self.refs.meshId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.meshId, 'style': 'max-width:280px;' });
		self.refs.meshKey = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.meshKey, 'style': 'max-width:280px;' });
		self.refs.uplinkBand = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			radio2g ? E('option', { 'value': '2g' }, _('راديو 2.4GHz')) : null,
			radio5g ? E('option', { 'value': '5g' }, _('راديو 5GHz')) : null
		]);
		self.refs.meshBand = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			radio2g ? E('option', { 'value': '2g' }, _('راديو 2.4GHz')) : null,
			radio5g ? E('option', { 'value': '5g' }, _('راديو 5GHz')) : null
		]);

		if ((self.state.uplinkBand == '5g' && !radio5g) || (self.state.uplinkBand == '2g' && !radio2g))
			self.state.uplinkBand = radio2g ? '2g' : '5g';

		if ((self.state.meshBand == '5g' && !radio5g) || (self.state.meshBand == '2g' && !radio2g))
			self.state.meshBand = radio2g ? '2g' : '5g';

		self.refs.uplinkBand.value = self.state.uplinkBand;
		self.refs.meshBand.value = self.state.meshBand;
		self.refs.ssidPreview = E('strong', primarySsid(self.state, '5g'));
		self.refs.primaryWifiPlan = E('span');
		self.refs.isVlan = E('input', { 'type': 'checkbox' });
		self.refs.isVlan.checked = self.state.isVlan;
		self.refs.vlanId = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '4094', 'value': self.state.vlanId, 'style': 'max-width:140px;' });
		self.refs.vlanPreview = E('strong', describeSecondaryVlanBinding(self.state.vlanId));
		self.refs.secondaryNetworkPlan = E('span');
		self.refs.secondaryNetworkNotice = E('div', {
			'class': 'alemprator-notice alemprator-notice--info',
			'style': 'display:none;'
		}, describeSecondaryNetworkNotice(self.state, self.radios || []));
		self.refs.channel2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.channel5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.wifiMode2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.wifiWidth2g = radio2g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.wifiMode5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.wifiWidth5g = radio5g ? E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }) : null;
		self.refs.resetDisabled = E('input', { 'type': 'checkbox' });
		self.refs.resetDisabled.checked = self.state.resetDisabled;
		self.refs.resetHoldSeconds = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:180px;' }, [
			E('option', { 'value': '5' }, _('5 ثوان')),
			E('option', { 'value': '10' }, _('10 ثوان')),
			E('option', { 'value': '20' }, _('20 ثانية')),
			E('option', { 'value': '30' }, _('30 ثانية')),
			E('option', { 'value': '40' }, _('40 ثانية')),
			E('option', { 'value': '60' }, _('60 ثانية'))
		]);
		self.refs.resetHoldSeconds.value = self.state.resetHoldSeconds;
		self.refs.wpsDisabled = E('input', { 'type': 'checkbox' });
		self.refs.wpsDisabled.checked = self.state.wpsDisabled;
		self.refs.rebootEnabled = E('input', { 'type': 'checkbox' });
		self.refs.rebootEnabled.checked = self.state.rebootEnabled;
		self.refs.rebootHours = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'step': '1', 'value': self.state.rebootHours, 'style': 'max-width:140px;' });
		self.refs.hotspotQuickWanInterface = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickWanInterface || 'lan', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickSubscriberInterface = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickSubscriberInterface || 'hotspot', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickSsid1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickSsid1 || 'Hotspot-1', 'style': 'max-width:280px;' });
		self.refs.hotspotQuickGateway1 = E('input', { 
			'class': 'cbi-input-text', 
			'type': 'text', 
			'value': self.state.hotspotQuickGateway1 || '192.168.10.1', 
			'style': 'max-width:220px;',
			'oninput': function(ev) {
				var val = ev.target.value.trim();
				if (val && self.refs.hotspotQuickPoolStart1 && self.refs.hotspotQuickPoolEnd1) {
					self.refs.hotspotQuickPoolStart1.value = deriveHotspotPoolStart(val);
					self.refs.hotspotQuickPoolEnd1.value = deriveHotspotPoolEnd(val);
				}
			}
		});
		self.refs.hotspotQuickPoolStart1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickPoolStart1 || '192.168.10.10', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickPoolEnd1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickPoolEnd1 || '192.168.10.199', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickPolicy1 = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, hotspotPolicyChoices());
		self.refs.hotspotQuickPolicy1.value = self.state.hotspotQuickPolicy1 || 'standard';
		self.refs.hotspotQuickSecondaryEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickSecondaryEnabled.checked = self.state.hotspotQuickSecondaryEnabled !== false;
		self.refs.hotspotQuickSsid2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickSsid2 || 'Hotspot-2', 'style': 'max-width:280px;' });
		self.refs.hotspotQuickGateway2 = E('input', { 
			'class': 'cbi-input-text', 
			'type': 'text', 
			'value': self.state.hotspotQuickGateway2 || '192.168.20.1', 
			'style': 'max-width:220px;',
			'oninput': function(ev) {
				var val = ev.target.value.trim();
				if (val && self.refs.hotspotQuickPoolStart2 && self.refs.hotspotQuickPoolEnd2) {
					self.refs.hotspotQuickPoolStart2.value = deriveHotspotPoolStart(val);
					self.refs.hotspotQuickPoolEnd2.value = deriveHotspotPoolEnd(val);
				}
			}
		});
		self.refs.hotspotQuickPoolStart2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickPoolStart2 || '192.168.20.10', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickPoolEnd2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickPoolEnd2 || '192.168.20.199', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickPolicy2 = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, hotspotPolicyChoices());
		self.refs.hotspotQuickPolicy2.value = self.state.hotspotQuickPolicy2 || 'premium';
		self.refs.hotspotQuickRadiusServer = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickRadiusServer || '192.168.1.2', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickRadiusServer2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickRadiusServer2 || '', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickRadiusSecret = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.hotspotQuickRadiusSecret || '', 'style': 'max-width:220px;', 'autocomplete': 'new-password' });
		self.refs.hotspotQuickRadiusSecretToggle = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button', 'style': 'margin-inline-start:8px;' }, _('إظهار'));
		self.refs.hotspotQuickRadiusAuthPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': self.state.hotspotQuickRadiusAuthPort || '1812', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickRadiusAcctPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': self.state.hotspotQuickRadiusAcctPort || '1813', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickRadiusNasIp = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickRadiusNasIp || '', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickNasId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickNasId || '', 'style': 'max-width:280px;' });
		self.refs.hotspotQuickAcctInterim = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': self.state.hotspotQuickAcctInterim || '60', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickCoaEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickCoaEnabled.checked = !!self.state.hotspotQuickCoaEnabled;
		self.refs.hotspotQuickCoaPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': self.state.hotspotQuickCoaPort || '3799', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickTrialEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickTrialEnabled.checked = !!self.state.hotspotQuickTrialEnabled;
		self.refs.hotspotQuickTrialDuration = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': self.state.hotspotQuickTrialDuration || '30', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickTrialUptimeLimit = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': self.state.hotspotQuickTrialUptimeLimit || '30', 'style': 'max-width:140px;' });
		self.refs.hotspotQuickMacAuthEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickMacAuthEnabled.checked = !!self.state.hotspotQuickMacAuthEnabled;
		self.refs.hotspotQuickMacAuthSuffix = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickMacAuthSuffix || '@mac', 'style': 'max-width:160px;' });
		self.refs.hotspotQuickMacAuthPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.hotspotQuickMacAuthPassword || 'mac', 'style': 'max-width:180px;', 'autocomplete': 'new-password' });
		self.refs.hotspotQuickWalledGarden = E('textarea', { 'class': 'cbi-input-textarea', 'rows': '4', 'style': 'width:100%; max-width:420px;' }, self.state.hotspotQuickWalledGarden || '');
		self.refs.hotspotQuickDomain = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickDomain || 'hotspot.local', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickDns1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickDns1 || '8.8.8.8', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickDns2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickDns2 || '82.114.163.31', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickBridgeAgeingTime = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': self.state.hotspotQuickBridgeAgeingTime || '10', 'style': 'max-width:120px;' });
		self.refs.hotspotQuickLoginMode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:260px;' }, hotspotLoginModeChoices());
		self.refs.hotspotQuickLoginMode.value = normalizeHotspotLoginMode(self.state.hotspotQuickLoginMode);
		self.refs.hotspotQuickRateLimit = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickRateLimit || '2M/5M', 'style': 'max-width:180px;' });
		self.refs.hotspotQuickMacCookieEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickMacCookieEnabled.checked = !!self.state.hotspotQuickMacCookieEnabled;
		self.refs.hotspotQuickAvailableSpeeds = E('textarea', { 'class': 'cbi-input-textarea', 'rows': '3', 'style': 'width:100%; max-width:420px;' }, self.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
		self.refs.hotspotQuickSupportPhone = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickSupportPhone || '', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickNoticeText = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا', 'style': 'max-width:420px;' });
		self.refs.hotspotQuickLiveStreamEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickLiveStreamEnabled.checked = !!self.state.hotspotQuickLiveStreamEnabled;
		self.refs.hotspotQuickLiveStreamUrl = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickLiveStreamUrl || '', 'style': 'max-width:420px;' });
		self.refs.hotspotQuickRestAreaEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickRestAreaEnabled.checked = !!self.state.hotspotQuickRestAreaEnabled;
		self.refs.hotspotQuickRestAreaUrl = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickRestAreaUrl || '', 'style': 'max-width:420px;' });
		self.refs.hotspotQuickSpeedtestEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickSpeedtestEnabled.checked = !!self.state.hotspotQuickSpeedtestEnabled;
		self.refs.hotspotQuickMaintEnabled = E('input', { 'type': 'checkbox', 'checked': !!self.state.hotspotQuickMaintEnabled });
		self.refs.hotspotQuickMaintStart = createTimePicker(self.state.hotspotQuickMaintStart || '02:00');
		self.refs.hotspotQuickMaintEnd = createTimePicker(self.state.hotspotQuickMaintEnd || '03:00');
		self.refs.hotspotQuickMaintMode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:320px;' }, [
			E('option', { 'value': 'free' }, _('السماح بالإنترنت المجاني للجميع (وضع الباي باس)')),
			E('option', { 'value': 'block' }, _('قطع الإنترنت وطرد جميع المشتركين'))
		]);
		self.refs.hotspotQuickMaintMode.value = self.state.hotspotQuickMaintMode || 'free';
		self.refs.hotspotQuickBrowserCookieEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickBrowserCookieEnabled.checked = self.state.hotspotQuickBrowserCookieEnabled !== false;
		self.refs.hotspotQuickBrowserCookieDays = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '365', 'value': normalizeBrowserCookieDays(self.state.hotspotQuickBrowserCookieDays || '7'), 'style': 'max-width:140px;' });
		self.refs.hotspotQuickUsermanRestEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotQuickUsermanRestEnabled.checked = !!self.state.hotspotQuickUsermanRestEnabled;
		self.refs.hotspotQuickUsermanRestScheme = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:140px;' }, routerOsSchemeChoices());
		self.refs.hotspotQuickUsermanRestScheme.value = normalizeRouterOsScheme(self.state.hotspotQuickUsermanRestScheme);
		self.refs.hotspotQuickUsermanRestUsername = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotQuickUsermanRestUsername || 'hotspot-read', 'style': 'max-width:220px;' });
		self.refs.hotspotQuickUsermanRestPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.hotspotQuickUsermanRestPassword || '', 'style': 'max-width:220px;', 'autocomplete': 'new-password' });
		self.refs.hotspotQuickUsermanRestPasswordToggle = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button', 'style': 'margin-inline-start:8px;' }, _('إظهار'));
		self.refs.hotspotQuickRadiusTestButton = E('button', { 'class': 'cbi-button cbi-button-action', 'type': 'button' }, _('اختبار RADIUS'));
		self.refs.hotspotQuickRadiusTestStatus = E('span', { 'style': 'margin-inline-start:8px; color:#52606d;' }, _('لم يتم الاختبار بعد.'));
		self.refs.hotspotQuickRestTestButton = E('button', { 'class': 'cbi-button cbi-button-action', 'type': 'button' }, _('اختبار REST API'));
		self.refs.hotspotQuickRestTestStatus = E('span', { 'style': 'margin-inline-start:8px; color:#52606d;' }, _('لم يتم الاختبار بعد.'));
		self.refs.adminPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });
		self.refs.adminPasswordConfirm = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });
		self.refs.hotspotEnabled = E('input', { 'type': 'checkbox' });
		self.refs.hotspotEnabled.checked = self.state.hotspotEnabled;
		self.refs.hotspotSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotSsid || 'Hotspot', 'style': 'max-width:280px;' });
		self.refs.hotspotRadiusServer = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotRadiusServer || '192.168.1.2', 'style': 'max-width:280px;' });
		self.refs.hotspotRadiusSecret = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': self.state.hotspotRadiusSecret || '', 'style': 'max-width:280px;', 'autocomplete': 'new-password' });
		self.refs.hotspotNasId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotNasId || '', 'style': 'max-width:280px;' });
		self.refs.hotspotIp = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotIp || '192.168.10.1', 'style': 'max-width:280px;' });
		self.refs.hotspotPoolStart = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotPoolStart || '192.168.10.10', 'style': 'max-width:280px;' });
		self.refs.hotspotPoolEnd = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': self.state.hotspotPoolEnd || '192.168.10.254', 'style': 'max-width:280px;' });
		self.refs.hotspotIpConflictWarning = E('div', {
			'class': 'alemprator-notice alemprator-notice--warning',
			'style': 'display:none; margin-top:8px;'
		}, _('تحذير: نطاق الهوتسبوت يتعارض مع نطاق LAN. يرجى تغيير عنوان IP للهوتسبوت.'));
		self.refs.otaWindowStart = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' });
		self.refs.otaWindowEnd = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' });
		populateSelectOptions(self.refs.otaWindowStart, otaHourChoices(), String(self.state.otaWindowStart == null ? 2 : self.state.otaWindowStart));
		populateSelectOptions(self.refs.otaWindowEnd, otaHourChoices(), String(self.state.otaWindowEnd == null ? 6 : self.state.otaWindowEnd));
		self.refs.otaWindowStart.disabled = !self.state.otaWindowAvailable;
		self.refs.otaWindowEnd.disabled = !self.state.otaWindowAvailable;
		self.refs.otaWindowStatus = E('strong', self.state.otaWindowAvailable ? describeOtaWindow(self.state.otaWindowStart, self.state.otaWindowEnd) : _('غير متوفرة على هذا الجهاز.'));
		self.refs.backupButton = E('button', {
			'class': 'cbi-button cbi-button-action',
			'type': 'button'
		}, _('تنزيل نسخة احتياطية الآن'));
		self.refs.safeRestoreButton = E('button', {
			'class': 'cbi-button cbi-button-negative',
			'type': 'button'
		}, _('استرجاع آمن من ملف نسخة احتياطية'));
		self.refs.backupStatus = E('span', _('جاهز لتنزيل نسخة احتياطية.'));
		self.refs.firstbootSummary = E('strong', describeFirstbootSummary(self.state));
		self.refs.firstbootEnabledStatus = E('strong', enabledText(self.state.firstbootEnabled));
		self.refs.firstbootConfiguredOnceStatus = E('strong', boolText(self.state.firstbootConfiguredOnce));
		self.refs.firstbootInitialSetupStatus = E('strong', boolText(self.state.firstbootInitialSetupComplete));
		self.refs.firstbootCleanupStatus = E('strong', describeFirstbootCleanupState(self.state.firstbootAutoCleanupArmed, self.state.firstbootAutoCleanupPending));
		self.refs.firstbootSections = E('span', describeFirstbootSections(self.state));

		if (self.refs.channel2g) {
			populateSelectOptions(
				self.refs.channel2g,
				channelChoices('2g', radio2g ? frequencyMap[radio2g['.name']] : null),
				self.state.channel2g
			);
		}

		if (self.refs.channel5g) {
			populateSelectOptions(
				self.refs.channel5g,
				channelChoices('5g', radio5g ? frequencyMap[radio5g['.name']] : null),
				self.state.channel5g
			);
		}

		self.syncRadioModeWidthUi();

		self.refs.radioSettingsCard = renderWizardCard(
			_('القنوات وإعدادات الراديو', true),
			null,
			[
				renderCardLiveSummary(self.refs.radioCardSummary),
				(self.refs.meshChannelHelp = E('p', { 'style': 'display:none; margin:0 0 12px 0; color:#52606d;' })),
				radio2g ? (self.refs.channel2gRow = E('div', { 'class': 'cbi-value alemprator-channel-row' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio2g)), E('div', { 'class': 'cbi-value-field' }, [ self.refs.channel2g ]) ])) : E('p', _('لم يتم اكتشاف راديو 2.4GHz.')),
				radio2g ? (self.refs.mode2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiMode2g ]) ])) : null,
				radio2g ? (self.refs.width2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiWidth2g ]) ])) : null,
				radio5g ? (self.refs.channel5gRow = E('div', { 'class': 'cbi-value alemprator-channel-row' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio5g)), E('div', { 'class': 'cbi-value-field' }, [ self.refs.channel5g ]) ])) : E('p', _('لم يتم اكتشاف راديو 5GHz.')),
				radio5g ? (self.refs.mode5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiMode5g ]) ])) : null,
				radio5g ? (self.refs.width5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiWidth5g ]) ])) : null
			], true
		);

		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel' }, [
			
			(self.refs.lanAdvancedCard = renderWizardCard(
				_('حدد عنوان الدخول المحلي للجهاز', true),
				'192.168.1.20 / 255.255.255.0',
				[
					renderCardLiveSummary(self.refs.lanCardSummary),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'style': 'font-weight:bold; color:#D4AF37' }, _('عنوان LAN IPv4')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.lanIpaddr ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'style': 'font-weight:bold; color:#D4AF37' }, _('قناع شبكة LAN')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.lanNetmask ]) ])
				], true
			))
		]));

		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' }, [
			(self.refs.modeCard = renderWizardCard(
				_('اختيار وضع التشغيل'),
				null,
				[
					renderCardLiveSummary(self.refs.modeCardSummary),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('وضع التشغيل')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.mode ]) ]),
					E('div', { 'style': 'margin-top:12px; padding:10px; background:#f4f9fc; border-radius:8px; border:1px dashed #c3d6e8; color:#234064; font-size:13px;' }, [ self.refs.modePlan = E('span') ])
				]
			)),
			self.refs.radioSettingsCard,
			(self.refs.hotspotQuickCard = renderWizardCard(
				_('إعدادات شبكة الهوتسبوت السريع'),
				null,
				[
					(self.refs.hotspotQuickDetailsWrapper = E('div', { 'class': 'alemprator-responsive-fields', 'style': 'display:none;' }, [
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('واجهة الإنترنت')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickWanInterface ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('واجهة المشتركين')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSubscriberInterface ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSsid1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('IP الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickGateway1 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool بداية الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPoolStart1 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool نهاية الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPoolEnd1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Name (الاسم الداخلي)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickDomain ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Server 1')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickDns1 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Server 2')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickDns2 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Ageing time')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickBridgeAgeingTime ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('صفحة الكرت')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickLoginMode ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('سرعة الميكروتك (Rate Limit)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRateLimit ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('دعم MAC Cookie')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMacCookieEnabled ]) ]),
						E('div', { 'style': 'margin: 20px 0; border-top: 1px dashed #D4AF37;' }),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title', 'style': 'color:#D4AF37; font-weight:bold;' }, _('تفعيل جدولة الصيانة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMaintEnabled ]) ]),
						(self.refs.hotspotQuickMaintWrapper = E('div', [
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('سلوك الصيانة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMaintMode ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('وقت بدء الصيانة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMaintStart ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('وقت انتهاء الصيانة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMaintEnd ]) ])
						])),
						E('div', { 'style': 'margin: 20px 0; border-top: 1px dashed #D4AF37;' }),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('قائمة السرعات المتاحة للمشتركين')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickAvailableSpeeds ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رقم الدعم الفني')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSupportPhone ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تنبيه للمشتركين')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickNoticeText ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إظهار بث مباشر')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickLiveStreamEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رابط البث المباشر')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickLiveStreamUrl ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إظهار الاستراحة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRestAreaEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رابط الاستراحة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRestAreaUrl ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل فحص السرعة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSpeedtestEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Policy/Profile للشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPolicy1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSecondaryEnabled ]) ]),
						(self.refs.hotspotQuickSecondaryWrapper = E('div', { 'class': 'alemprator-responsive-fields', 'style': 'display:none;' }, [
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickSsid2 ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('IP الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickGateway2 ]) ]),
							E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool بداية الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPoolStart2 ]) ]),
							E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool نهاية الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPoolEnd2 ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Policy/Profile للشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickPolicy2 ]) ])
						])),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Users')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickTrialEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Duration')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickTrialDuration ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Uptime Limit')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickTrialUptimeLimit ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Authentication')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMacAuthEnabled ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Auth Suffix')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMacAuthSuffix ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Auth Password')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickMacAuthPassword ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Walled Garden Domains')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickWalledGarden ]) ]),
						(self.refs.hotspotVlanLockNotice = renderNoticeBox('warning', null, [ E('span', _('عند تفعيل الهوتسبوت السريع يتم تعطيل VLAN تلقائيًا ومنع حفظه.')) ]))
					]))
				]
			)),
			(self.refs.hotspotQuickAuthCard = renderWizardCard(
				_('إعدادات المصادقة والربط (RADIUS/REST)'),
				null,
				[
					(self.refs.hotspotQuickAuthWrapper = E('div', { 'class': 'alemprator-responsive-fields', 'style': 'display:none;' }, [
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مخدم RADIUS الأساسي')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusServer ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مخدم RADIUS الاحتياطي')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusServer2 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة سر RADIUS')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusSecret, self.refs.hotspotQuickRadiusSecretToggle ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('منفذ المصادقة (Auth)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusAuthPort ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('منفذ المحاسبة (Acct)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusAcctPort ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('NAS IP Address')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusNasIp ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('NAS ID')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickNasId ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Interim Update (sec)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickAcctInterim ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل COA')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickCoaEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('منفذ COA')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickCoaPort ]) ]),
						E('div', { 'style': 'margin: 20px 0; border-top: 1px dashed #ccc;' }),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل REST API (MikroTik)')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickUsermanRestEnabled ]) ]),
						(self.refs.hotspotQuickRestFieldsWrapper = E('div', [
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('بروتوكول الربط')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickUsermanRestScheme ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم مستخدم REST')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickUsermanRestUsername ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور REST')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickUsermanRestPassword, self.refs.hotspotQuickUsermanRestPasswordToggle ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('أدوات الاختبار')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRadiusTestButton, self.refs.hotspotQuickRadiusTestStatus ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, ''), E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotQuickRestTestButton, self.refs.hotspotQuickRestTestStatus ]) ])
						]))
					]))
				]
			)),
			(self.refs.apVlanWarning = E('div', {
				'class': 'alemprator-notice alemprator-notice--warning',
				'style': 'display:none; margin:12px 0 0 0;'
			}, _('عند تفعيل VLAN هنا ستعتمد على شبكات VLAN فقط.'))),
			E('div', { 'class': 'alemprator-card-grid' }, [
				(self.refs.primaryWifiSection = E('div', [
					renderWizardCard(
						_('الشبكة اللاسلكية الأساسية'),
						null,
						[
							renderCardLiveSummary(self.refs.primaryWifiCardSummary),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم SSID الأساسي')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsid ]) ]),
							(self.refs.ssid5gModeRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('طريقة تعيين اسم 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsid5gMode ]) ])),
							(self.refs.ssid5gCustomRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم المخصص لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsid5g ]) ])),
							(self.refs.ssidPreviewRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم النهائي لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.ssidPreview ]) ])),
							(self.refs.primarySsidIpSuffixRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إضافة آخر IP إلى اسم الشبكة الأساسية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsidIpSuffixPrimary ]) ])),
							renderNoticeBox('neutral', null, [ self.refs.primaryWifiPlan ])
						]
					)
				])),
				(self.refs.wifiSecurityCard = renderWizardCard(
					_('حماية الواي فاي المحلية'),
					null,
					[
						renderCardLiveSummary(self.refs.wifiSecurityCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الواي فاي')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiKey ]) ])
					]
				)),
				(self.refs.uplinkSettingsWrapper = E('div', { 'style': 'display:none;' }, [
					renderWizardCard(
						_('إعدادات الربط الصاعد'),
						null,
						[
							renderCardLiveSummary(self.refs.uplinkCardSummary),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.uplinkBand ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم شبكة الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.uplinkSsid ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.uplinkKey ]) ])
						]
					)
				])),
				(self.refs.meshSettingsWrapper = E('div', { 'style': 'display:none;' }, [
					renderWizardCard(
						_('إعدادات الميش'),
						null,
						[
							renderCardLiveSummary(self.refs.meshCardSummary),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الميش')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.meshBand ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('معرف الميش')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.meshId ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الميش')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.meshKey ]) ])
						]
					)
				])),
				(self.refs.vlanSettingsCard = renderWizardCard(
					_('إعداد شبكة VLAN الثانوية'),
					null,
					[
						renderCardLiveSummary(self.refs.vlanCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل شبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.isVlan ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('VLAN ID')), (self.refs.vlanIdWrapper = E('div', { 'class': 'cbi-value-field' }, [ self.refs.vlanId ])) ]),
						(self.refs.vlanSsid2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم الأساسي لشبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsidVlan2g ]) ])),
						(self.refs.vlanSsid5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم الاختياري لشبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsidVlan5g ]) ])),
						(self.refs.vlanSsidIpSuffixRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إضافة آخر IP إلى أسماء الواي فاي')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wifiSsidVlanIpSuffix ]) ])),
						(self.refs.vlanPreviewWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('معرّف VLAN الثانوية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.vlanPreview ]) ])),
						renderNoticeBox('neutral', null, [ self.refs.secondaryNetworkPlan ]),
						self.refs.secondaryNetworkNotice
					]
				))
			])
		]));

		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' }, (function(hotspotAvailable) {
			if (!hotspotAvailable) {
				return [
					renderNoticeBox('warning', _('الهوتسبوت غير متوفر'), [
						E('span', _('لم يتم اكتشاف حزمة luci-app-hotspot-openwrt على الجهاز. هذه الخطوة لن تظهر أثناء التنقل.'))
					])
				];
			}

			return [
				renderWizardCard(
					null,
					null,
					[
						(self.refs.hotspotFieldsWrapper = E('div', {
							'class': 'alemprator-hotspot-fields'
						}, [
							E('div', { 'class': 'cbi-value' }, [
								E('label', { 'class': 'cbi-value-title' }, _('اسم شبكة الهوتسبوت (SSID)')),
								E('div', { 'class': 'cbi-value-field' }, [
									self.refs.hotspotSsid,
									E('div', { 'style': 'margin-top:6px; color:#666;' }, _('الشبكة المفتوحة التي يراها العملاء.'))
								])
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', { 'class': 'cbi-value-title' }, _('عنوان مخدم RADIUS (IP الميكروتك)')),
								E('div', { 'class': 'cbi-value-field' }, [
									self.refs.hotspotRadiusServer,
									E('div', { 'style': 'margin-top:6px; color:#666;' }, _('عنوان IPv4 لـ MikroTik أو أي مخدم RADIUS آخر.'))
								])
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', { 'class': 'cbi-value-title' }, _('كلمة سر RADIUS')),
								E('div', { 'class': 'cbi-value-field' }, [
									self.refs.hotspotRadiusSecret,
									E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يجب أن تتطابق مع الإعداد في User Manager.'))
								])
							]),
							E('button', {
								'class': 'alemprator-hotspot-advanced-toggle',
								'type': 'button',
								'click': function(ev) {
									ev.preventDefault();
									var wrapper = self.refs.hotspotAdvancedWrapper;
									if (!wrapper) return;
									var visible = wrapper.style.display != 'none';
									wrapper.style.display = visible ? 'none' : '';
									ev.currentTarget.textContent = visible ? _('▼ الإعدادات المتقدمة') : _('▲ إخفاء الإعدادات المتقدمة');
								}
							}, _('▼ الإعدادات المتقدمة')),
							(self.refs.hotspotAdvancedWrapper = E('div', { 'style': 'display:none; margin-top:10px;' }, [
								E('div', { 'class': 'cbi-value' }, [
									E('label', { 'class': 'cbi-value-title' }, _('معرف NAS (اختياري)')),
									E('div', { 'class': 'cbi-value-field' }, [
										self.refs.hotspotNasId,
										E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اتركه فارغاً لتوليده تلقائياً.'))
									])
								]),
								E('div', { 'class': 'cbi-value' }, [
									E('label', { 'class': 'cbi-value-title' }, _('بوابة الهوتسبوت (IP)')),
									E('div', { 'class': 'cbi-value-field' }, [
										self.refs.hotspotIp,
										self.refs.hotspotIpConflictWarning,
										E('div', { 'style': 'margin-top:6px; color:#666;' }, _('الافتراضي 192.168.10.1 — تأكد من عدم تعارضه مع LAN.'))
									])
								]),
								E('div', { 'class': 'cbi-value' }, [
									E('label', { 'class': 'cbi-value-title' }, _('بداية نطاق DHCP')),
									E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotPoolStart ])
								]),
								E('div', { 'class': 'cbi-value' }, [
									E('label', { 'class': 'cbi-value-title' }, _('نهاية نطاق DHCP')),
									E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotPoolEnd ])
								])
							]))
						]))
					]
				)
			];
		}(self.state.hotspotAvailable))));

		self.refs.resetHoldWrapper = E('div', { 'class': 'cbi-value-field' }, [ self.refs.resetHoldSeconds ]);
		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' }, [
			E('div', { 'class': 'alemprator-card-grid' }, [
				(self.refs.backupCard = renderWizardCard(
					_('النسخ الاحتياطي', true),
					null,
					[
						renderCardLiveSummary(self.refs.backupCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('تنزيل النسخة الاحتياطية')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.backupButton ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الاسترجاع الآمن')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.safeRestoreButton ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الحالة')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.backupStatus ])
						])
					]
				)),
				(self.refs.firstbootCard = renderWizardCard(
					_('حالة النظام (M)'),
					null,
					[
						renderCardLiveSummary(self.refs.firstbootCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الملخص الحالي')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootSummary ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('حالة firstboot')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootEnabledStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('configured_once')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootConfiguredOnceStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('initial_setup_complete')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootInitialSetupStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('حالة التنظيف المؤجل')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootCleanupStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('أسماء المقاطع المرتبطة')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.firstbootSections ])
						])
					]
				)),
				(self.refs.otaCard = renderWizardCard(
					_('وقت التحديث التلقائي', true),
					null,
					[
						renderCardLiveSummary(self.refs.otaCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('بداية نافذة التحديث التلقائي')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.otaWindowStart ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('نهاية نافذة التحديث التلقائي')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.otaWindowEnd ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('نافذة التحديث الحالية')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.otaWindowStatus ])
						])
					]
				)),
				(self.refs.buttonPoliciesCard = renderWizardCard(
					_('سياسات الأزرار', true),
					null,
					[
						renderCardLiveSummary(self.refs.buttonPoliciesCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر إعادة الضبط')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.resetDisabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مدة الضغط لإعادة ضبط المصنع')), self.refs.resetHoldWrapper ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر WPS/ميش')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.wpsDisabled ]) ])
					]
				)),
				(self.refs.rebootCard = renderWizardCard(
					_('إعادة تشغيل الجهاز', true),
					null,
					[
						renderCardLiveSummary(self.refs.rebootCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل إعادة التشغيل التلقائية')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.rebootEnabled ]) ]),
						(self.refs.rebootHoursWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إعادة التشغيل كل كم ساعة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.rebootHours ]) ]))
					]
				)),
				(self.refs.passwordCard = renderWizardCard(
					_('كلمة مرور الجهاز', true),
					null,
					[
						renderCardLiveSummary(self.refs.passwordCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة المرور الجديدة')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.adminPassword ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تأكيد كلمة المرور')), E('div', { 'class': 'cbi-value-field' }, [ self.refs.adminPasswordConfirm ]) ])
					]
				))
			])
		]));

		if (self.refs.radioSettingsCard) self.refs.radioSettingsCard.classList.add('alemprator-card--tooltip');
		if (self.refs.lanAdvancedCard) self.refs.lanAdvancedCard.classList.add('alemprator-card--tooltip');
		if (self.refs.firstbootCard) self.refs.firstbootCard.classList.add('alemprator-card--tooltip');
		if (self.refs.passwordCard) self.refs.passwordCard.classList.add('alemprator-card--tooltip');
		if (self.refs.otaCard) self.refs.otaCard.classList.add('alemprator-card--tooltip');
		if (self.refs.buttonPoliciesCard) self.refs.buttonPoliciesCard.classList.add('alemprator-card--tooltip');
		if (self.refs.rebootCard) self.refs.rebootCard.classList.add('alemprator-card--tooltip');
		if (self.refs.backupCard) self.refs.backupCard.classList.add('alemprator-card--tooltip');

		(function() {
		var self = this;
		var legacyPanels = stepPanels.slice();

		var networkPage = E('div', { 'class': 'cbi-section-node alemprator-step-panel' });
		var hotspotNetPage = E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' });
		var hotspotAuthPage = E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' });
		var maintenancePage = E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' });

		var moveChildren = function(panel, target) {
			if (!panel) return;
			panel.style.display = '';
			while (panel.firstChild) target.appendChild(panel.firstChild);
		};

		legacyPanels.forEach(function(panel) {
			if (panel) panel.style.display = '';
		});

		
		// 1. Identity & Login Step (Step 1)
		networkPage.appendChild(E('h4', { 'class': 'alemprator-step-title' }, '❶ ' + stepTitles[0]));
		moveChildren(legacyPanels[0], networkPage); // LAN IP Card
		networkPage.appendChild(modeGrid);          // Mode Choice Card
		if (self.refs.modeCard) networkPage.appendChild(self.refs.modeCard);

		// 2. Wireless Step (Step 2)
		var wirelessPage = E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' });
		wirelessPage.appendChild(E('h4', { 'class': 'alemprator-step-title' }, '❷ ' + stepTitles[1]));

		// 3. Hotspot Network (Step 3) - Header first
		hotspotNetPage.appendChild(E('h4', { 'class': 'alemprator-step-title' }, '❸ ' + stepTitles[2]));

		// 4. Hotspot Auth (Step 4) - Header first
		hotspotAuthPage.appendChild(E('h4', { 'class': 'alemprator-step-title' }, '❹ ' + stepTitles[3]));

		if (legacyPanels && legacyPanels[1]) {
			var children1 = Array.prototype.slice.call(legacyPanels[1].childNodes);
			children1.forEach(function(child) {
				// Wireless Basic/Radio settings
				if (child !== self.refs.hotspotQuickCard && 
					child !== self.refs.hotspotQuickAuthCard &&
					child !== self.refs.uplinkSettingsWrapper && 
					child !== self.refs.meshSettingsWrapper && 
					child !== self.refs.vlanSettingsCard &&
					child !== self.refs.modeCard) {
					wirelessPage.appendChild(child);
				} else if (child === self.refs.hotspotQuickAuthCard) {
					hotspotAuthPage.appendChild(child);
				} else if (child !== self.refs.modeCard) {
					// Hotspot/Advanced Connectivity (like hotspotQuickCard)
					hotspotNetPage.appendChild(child);
				}
			});
		}

		// 4. Hotspot Auth (Continued)
		if (legacyPanels && legacyPanels[2]) {
			var standardHotspotGrid = legacyPanels[2].querySelector('.alemprator-hotspot-fields');
			if (standardHotspotGrid) {
				hotspotAuthPage.appendChild(standardHotspotGrid);
			} else {
				moveChildren(legacyPanels[2], hotspotAuthPage);
			}
		}

		// 5. Maintenance Page (Step 5)
		maintenancePage.appendChild(E('h4', { 'class': 'alemprator-step-title' }, '❺ ' + stepTitles[4]));
		moveChildren(legacyPanels[3], maintenancePage);
		if (self.refs.reviewContainer) maintenancePage.insertBefore(self.refs.reviewContainer, maintenancePage.lastChild);

		// Final Step Panels assignment
		stepPanels.length = 0;
		stepPanels.push(networkPage);    // Index 0
		stepPanels.push(wirelessPage);   // Index 1 (Always Visible)
		stepPanels.push(hotspotNetPage); // Index 2 (Hotspot Only)
		stepPanels.push(hotspotAuthPage);// Index 3 (Hotspot Only)
		stepPanels.push(maintenancePage);// Index 4 (Always Visible)

	}.call(this));

		stepPanels.forEach(function(stepPanel) {
			stepsWrap.appendChild(stepPanel);
		});

		wizardContainer.appendChild(stepsWrap);

		self.refs.prevButton = E('button', { 'class': 'cbi-button cbi-button-neutral' }, _('السابق'));
		self.refs.nextButton = E('button', { 'class': 'cbi-button cbi-button-action important' }, _('التالي'));
		self.refs.saveButton = E('button', { 'class': 'cbi-button cbi-button-save important', 'style': 'display:none;' }, _('حفظ وتطبيق'));
		self.refs.reloadButton = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button' }, _('تحديث القيم من الجهاز'));

		self.refs.prevButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.prevStep();
		});

		self.refs.nextButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.nextStep();
		});

		self.refs.saveButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.saveAndApply();
		});

		self.refs.reloadButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.reloadStateFromDevice();
		});

		self.refs.backupButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.downloadConfigBackup();
		});

		self.refs.safeRestoreButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.safeRestoreConfigBackup();
		});

		self.refs.otaWindowStart.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.otaWindowEnd.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsid.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsid5gMode.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsid5g.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.lanIpaddr.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.lanNetmask.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.mode.addEventListener('change', function() {
                if (self.refs.mode.value !== 'ap') {
                        // User chose Mesh, Extender, etc. Reset hotspot.
                        // Actually, even if they explicitly select 'ap' from the dropdown, maybe reset? Yes, if they are touching mode, they want basic setup.
                }
                if (self.refs.hotspotQuickEnabled) self.refs.hotspotQuickEnabled.checked = false;
                if (self.refs.hotspotEnabled) self.refs.hotspotEnabled.checked = false;
                if (self.refs.hotspotQuickSecondaryEnabled) self.refs.hotspotQuickSecondaryEnabled.checked = false;
                self.updateStepUi();
        });

		self.refs.uplinkSsid.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.uplinkKey.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.uplinkBand.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.meshId.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.meshKey.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.meshBand.addEventListener('change', function() {
			self.updateStepUi();
		});

		if (self.refs.channel2g) {
			self.refs.channel2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.channel5g) {
			self.refs.channel5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.wifiMode2g) {
			self.refs.wifiMode2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.wifiWidth2g) {
			self.refs.wifiWidth2g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.wifiMode5g) {
			self.refs.wifiMode5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.wifiWidth5g) {
			self.refs.wifiWidth5g.addEventListener('change', function() {
				self.updateStepUi();
			});
		}

		self.refs.isVlan.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.vlanId.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsidVlan2g.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsidVlan5g.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.wifiSsidIpSuffixPrimary.addEventListener('change', function() {
			self.state.wifiSsidVlanIpSuffix = self.refs.wifiSsidIpSuffixPrimary.checked;
			self.refs.wifiSsidVlanIpSuffix.checked = self.state.wifiSsidVlanIpSuffix;
			self.updateStepUi();
		});

		self.refs.wifiSsidVlanIpSuffix.addEventListener('change', function() {
			self.state.wifiSsidVlanIpSuffix = self.refs.wifiSsidVlanIpSuffix.checked;
			self.refs.wifiSsidIpSuffixPrimary.checked = self.state.wifiSsidVlanIpSuffix;
			self.updateStepUi();
		});

		self.refs.wifiKey.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.rebootEnabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.rebootHours.addEventListener('input', function() {
			self.updateStepUi();
		});

		
           if (self.refs.hotspotQuickSecondaryEnabled) {
                   self.refs.hotspotQuickSecondaryEnabled.addEventListener('change', function() {
                           self.updateStepUi();
                   });
           }

           if (self.refs.hotspotQuickMaintEnabled) {
                   self.refs.hotspotQuickMaintEnabled.addEventListener('change', function() {
                           self.updateStepUi();
                   });
           }

           if (self.refs.hotspotQuickEnabled) {

			self.refs.hotspotQuickEnabled.addEventListener('change', function() {
				self.updateStepUi();
				if (self.refs.hotspotQuickEnabled.checked)
					showHotspotLicenseSelectionMessage(_('الهوتسبوت السريع'));
			});
		}

		self.refs.adminPassword.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.adminPasswordConfirm.addEventListener('input', function() {
			self.updateStepUi();
		});

		self.refs.resetDisabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.resetHoldSeconds.addEventListener('change', function() {
			self.updateStepUi();
		});

		self.refs.wpsDisabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		if (self.refs.hotspotEnabled) {
			self.refs.hotspotEnabled.addEventListener('change', function() {
				self.updateStepUi();
				if (self.refs.hotspotEnabled.checked)
					showHotspotLicenseSelectionMessage(_('الهوتسبوت'));
			});
		}

		if (self.refs.hotspotSsid) {
			self.refs.hotspotSsid.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.hotspotRadiusServer) {
			self.refs.hotspotRadiusServer.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.hotspotRadiusSecret) {
			self.refs.hotspotRadiusSecret.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (self.refs.hotspotIp) {
			self.refs.hotspotIp.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		[
			'hotspotQuickEnabled', 'hotspotQuickWanInterface', 'hotspotQuickSubscriberInterface',
			'hotspotQuickRadiusServer', 'hotspotQuickRadiusServer2', 'hotspotQuickRadiusSecret', 'hotspotQuickRadiusAuthPort',
			'hotspotQuickRadiusAcctPort', 'hotspotQuickRadiusNasIp', 'hotspotQuickNasId', 'hotspotQuickAcctInterim',
			'hotspotQuickCoaEnabled', 'hotspotQuickCoaPort', 'hotspotQuickTrialEnabled', 'hotspotQuickTrialDuration',
			'hotspotQuickTrialUptimeLimit', 'hotspotQuickMacAuthEnabled', 'hotspotQuickMacAuthSuffix',
			'hotspotQuickMacAuthPassword', 'hotspotQuickWalledGarden', 'hotspotQuickDomain',
			'hotspotQuickDns1', 'hotspotQuickDns2', 'hotspotQuickBridgeAgeingTime', 'hotspotQuickLoginMode', 'hotspotQuickRateLimit',
			'hotspotQuickMacCookieEnabled', 'hotspotQuickAvailableSpeeds', 'hotspotQuickSupportPhone',
			'hotspotQuickNoticeText', 'hotspotQuickLiveStreamEnabled', 'hotspotQuickLiveStreamUrl',
			'hotspotQuickRestAreaEnabled', 'hotspotQuickRestAreaUrl', 'hotspotQuickSpeedtestEnabled',
			'hotspotQuickMaintEnabled', 'hotspotQuickMaintStart', 'hotspotQuickMaintEnd', 'hotspotQuickMaintMode',
			'hotspotQuickBrowserCookieEnabled',
			'hotspotQuickBrowserCookieDays', 'hotspotQuickUsermanRestEnabled', 'hotspotQuickUsermanRestScheme',
			'hotspotQuickUsermanRestUsername', 'hotspotQuickUsermanRestPassword',
			'hotspotQuickSsid1', 'hotspotQuickGateway1', 'hotspotQuickPoolStart1', 'hotspotQuickPoolEnd1',
			'hotspotQuickPolicy1', 'hotspotQuickSecondaryEnabled', 'hotspotQuickSsid2',
			'hotspotQuickGateway2', 'hotspotQuickPoolStart2', 'hotspotQuickPoolEnd2', 'hotspotQuickPolicy2'
		].forEach(function(refName) {
			if (self.refs[refName]) {
				self.refs[refName].addEventListener((self.refs[refName].tagName == 'SELECT' || self.refs[refName].type == 'checkbox') ? 'change' : 'input', function() {
					self.updateStepUi();
				});
			}
		});

		if (self.refs.hotspotQuickRadiusTestButton) {
			self.refs.hotspotQuickRadiusTestButton.addEventListener('click', function(ev) {
				ev.preventDefault();
				self.testHotspotQuickRadius();
			});
		}

		if (self.refs.hotspotQuickRestTestButton) {
			self.refs.hotspotQuickRestTestButton.addEventListener('click', function(ev) {
				ev.preventDefault();
				self.testHotspotQuickRest();
			});
		}

		if (self.refs.hotspotQuickRadiusSecretToggle) {
			self.refs.hotspotQuickRadiusSecretToggle.addEventListener('click', function(ev) {
				ev.preventDefault();

				if (!self.refs.hotspotQuickRadiusSecret)
					return;

				if (self.refs.hotspotQuickRadiusSecret.type == 'password') {
					self.refs.hotspotQuickRadiusSecret.type = 'text';
					self.refs.hotspotQuickRadiusSecretToggle.textContent = _('إخفاء');
				}
				else {
					self.refs.hotspotQuickRadiusSecret.type = 'password';
					self.refs.hotspotQuickRadiusSecretToggle.textContent = _('إظهار');
				}
			});
		}

		if (self.refs.hotspotQuickUsermanRestPasswordToggle) {
			self.refs.hotspotQuickUsermanRestPasswordToggle.addEventListener('click', function(ev) {
				ev.preventDefault();

				if (!self.refs.hotspotQuickUsermanRestPassword)
					return;

				if (self.refs.hotspotQuickUsermanRestPassword.type == 'password') {
					self.refs.hotspotQuickUsermanRestPassword.type = 'text';
					self.refs.hotspotQuickUsermanRestPasswordToggle.textContent = _('إخفاء');
				}
				else {
					self.refs.hotspotQuickUsermanRestPassword.type = 'password';
					self.refs.hotspotQuickUsermanRestPasswordToggle.textContent = _('إظهار');
				}
			});
		}

		actions.appendChild(self.refs.reloadButton);
		actions.appendChild(self.refs.prevButton);
		actions.appendChild(self.refs.nextButton);
		actions.appendChild(self.refs.saveButton);
		wizardContainer.appendChild(actions);

		wizardContainer.appendChild(E('div', {
			'class': 'alemprator-copyright-footer',
			'style': 'text-align:center; padding:24px 16px 12px; margin-top:32px; border-top:1px solid rgba(0,0,0,0.08); color:#6c757d; font-size:12px; line-height:1.8; direction:rtl;'
		}, [
			E('div', {}, [
				E('span', { 'style': 'font-size:13px;' }, '© جميع الحقوق محفوظة | '),
				E('strong', { 'style': 'color:#415a77;' }, 'تطوير وتنفيذ: م. جلال أحمد القحم – م. محمد باعلوي')
			]),
			E('div', { 'style': 'margin-top:4px;' }, [
				E('span', { 'style': 'color:#52606d;' }, 'شركة الإمبراطور للسوفتويرات | حلول برمجية وأنظمة وتطبيقات حسب الطلب')
			]),
			E('div', { 'style': 'margin-top:4px;' }, [
				E('span', {}, '📱 '),
				E('a', { 'href': 'tel:+967774070632', 'style': 'color:#1b4965; text-decoration:none;' }, '774070632'),
				E('span', {}, ' | '),
				E('a', { 'href': 'tel:+967777440819', 'style': 'color:#1b4965; text-decoration:none;' }, '777440819')
			])
		]));

		panel.appendChild(wizardContainer);

		self.updateStepUi();

		return self.renderStatus(statusContainer).then(function() {
			poll.add(function() {
				return self.renderStatus(statusContainer);
			});

			return panel;
		});
	}
});