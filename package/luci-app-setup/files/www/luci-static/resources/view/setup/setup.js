'use strict';
'require view';
'require dom';
'require poll';
'require rpc';
'require fs';
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

var SETUP_STYLE_ID = 'alemprator-setup-styles';
var WATCHCAT_SID = 'alemprator_periodic_reboot';
var STEP_KEYS = [ 'options', 'maintenance' ];
var WIZARD_BUILD_TAG = 'r120';
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
var HOTSPOT_QUICK_IFACE_PRIMARY = 'wizard_hotspot_quick_primary';
var HOTSPOT_QUICK_IFACE_SECONDARY = 'wizard_hotspot_quick_secondary';

function notify(message) {
	ui.addNotification(null, E('p', message));
}

function hotspotLicenseCacheInfo() {
	var enabled = uci.get('hotspot_licensing', 'main', 'enabled') != '0';
	var rawStatus = uci.get('hotspot_licensing', 'main', 'license_status');
	var status = rawStatus || 'unknown';
	var expiresAt = Number(uci.get('hotspot_licensing', 'main', 'expires_at') || 0);
	var now = Math.floor(Date.now() / 1000);
	var active = !enabled || (status == 'active' && expiresAt > now);
	var known = !!rawStatus;

	return {
		enabled: enabled,
		status: status,
		expiresAt: expiresAt,
		active: active,
		known: known,
		label: !enabled ? _('فحص الترخيص معطل') : (!known ? _('غير معروف') : (active ? _('مرخص') : _('غير مرخص')))
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
	return L.resolveDefault(fs.exec(HOTSPOT_LICENSE_CHECK_CMD, []), { code: 1 }).then(function(res) {
		return {
			ok: !!(res && res.code === 0),
			message: (res && (res.stderr || res.stdout)) || ''
		};
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
	if (!state || (!state.hotspotQuickEnabled && !state.hotspotEnabled))
		return Promise.resolve(true);

	return checkHotspotLicenseLive().then(function(result) {
		var message = result.ok
			? _('الهوتسبوت مرخص. سيتم حفظ الإعدادات وتشغيل الخدمة الآن. هل تريد المتابعة؟')
			: _('الهوتسبوت غير مرخص. سيتم حفظ الإعدادات، لكن تشغيل الخدمة سيفشل وسيبقى العملاء بدون إنترنت عبر الهوتسبوت حتى يتم تفعيل الترخيص من لوحة OTA. هل تريد المتابعة؟');

		if (result.message)
			message += '\n\n' + _('تفاصيل الفحص: ') + String(result.message).trim();

		return window.confirm(message);
	});
}

function ensureSetupStyles() {
	var styleTag;

	if (document.getElementById(SETUP_STYLE_ID))
		return;

	styleTag = document.createElement('style');
	styleTag.id = SETUP_STYLE_ID;
	styleTag.textContent = [
		'.alemprator-setup-shell {',
		'  display:grid;',
		'  grid-template-columns:minmax(0, 1fr);',
		'  gap:16px;',
		'  align-items:start;',
		'  position:relative;',
		'  left:50%;',
		'  transform:translateX(-50%);',
		'  width:calc(100vw - 48px);',
		'  max-width:1680px;',
		'  min-width:0;',
		'}',
		'.alemprator-setup-wizard {',
		'  min-width:0;',
		'}',
		'.alemprator-setup-status-column {',
		'  position:static;',
		'  align-self:stretch;',
		'  min-width:0;',
		'}',
		'@media (max-width: 1120px) {',
		'  .alemprator-setup-shell {',
		'    grid-template-columns:1fr;',
		'    width:calc(100vw - 28px);',
		'  }',
		'  .alemprator-setup-status-column {',
		'    position:static;',
		'  }',
		'}',
		'.alemprator-card {',
		'  position:relative;',
		'  overflow:hidden;',
		'  margin:0;',
		'  padding:18px 20px;',
		'  border:1px solid #d7e3ea;',
		'  border-radius:22px;',
		'  background:linear-gradient(180deg, #ffffff 0%, #f8fbfc 100%);',
		'  box-shadow:0 14px 36px rgba(7, 59, 76, 0.08);',
		'}',
		'.alemprator-card__eyebrow {',
		'  display:inline-flex;',
		'  align-items:center;',
		'  gap:6px;',
		'  padding:5px 10px;',
		'  border-radius:999px;',
		'  background:rgba(15, 118, 110, 0.12);',
		'  color:#0f766e;',
		'  font-size:11px;',
		'  font-weight:700;',
		'  letter-spacing:.08em;',
		'  text-transform:uppercase;',
		'}',
		'.alemprator-card__eyebrow--light {',
		'  background:rgba(255, 255, 255, 0.16);',
		'  color:#fff7d1;',
		'}',
		'.alemprator-card__title {',
		'  margin:10px 0 0 0;',
		'  color:#102a43;',
		'  font:700 28px/1.15 "Trebuchet MS", Tahoma, sans-serif;',
		'}',
		'.alemprator-card__title--light {',
		'  color:#fff;',
		'}',
		'.alemprator-card__desc {',
		'  margin:10px 0 0 0;',
		'  color:#52606d;',
		'  line-height:1.7;',
		'}',
		'.alemprator-card__desc--light {',
		'  color:rgba(255, 255, 255, 0.88);',
		'}',
		'.alemprator-card--hero {',
		'  padding:24px;',
		'  border-color:rgba(9, 36, 47, 0.28);',
		'  background:linear-gradient(135deg, #073b4c 0%, #0f766e 58%, #c97a12 100%);',
		'  box-shadow:0 18px 40px rgba(7, 59, 76, 0.22);',
		'}',
		'.alemprator-card--hero::after {',
		'  content:"";',
		'  position:absolute;',
		'  inset:auto -45px -55px auto;',
		'  width:170px;',
		'  height:170px;',
		'  border-radius:50%;',
		'  background:rgba(255, 255, 255, 0.10);',
		'}',
		'.alemprator-hero__grid {',
		'  display:grid;',
		'  grid-template-columns:minmax(0, 1.6fr) minmax(230px, .9fr);',
		'  gap:18px;',
		'  align-items:end;',
		'}',
		'@media (max-width: 760px) {',
		'  .alemprator-hero__grid {',
		'    grid-template-columns:1fr;',
		'  }',
		'}',
		'.alemprator-hero__actions {',
		'  display:flex;',
		'  gap:12px;',
		'  flex-wrap:wrap;',
		'  align-items:center;',
		'  margin-top:18px;',
		'}',
		'.alemprator-hero__link {',
		'  display:inline-flex;',
		'  align-items:center;',
		'  justify-content:center;',
		'  padding:10px 16px;',
		'  border-radius:999px;',
		'  background:rgba(255, 255, 255, 0.16);',
		'  color:#fff;',
		'  text-decoration:none;',
		'  font-weight:700;',
		'  border:1px solid rgba(255, 255, 255, 0.28);',
		'  backdrop-filter:blur(4px);',
		'}',
		'.alemprator-hero__hint {',
		'  color:rgba(255, 255, 255, 0.80);',
		'}',
		'.alemprator-hero__summary {',
		'  margin-top:18px;',
		'  color:#fff;',
		'  font-weight:600;',
		'  line-height:1.7;',
		'}',
		'.alemprator-hero__facts {',
		'  display:grid;',
		'  grid-template-columns:repeat(auto-fit, minmax(150px, 1fr));',
		'  gap:12px;',
		'}',
		'.alemprator-summary-fact {',
		'  padding:14px 16px;',
		'  border-radius:18px;',
		'  background:rgba(255, 255, 255, 0.14);',
		'  border:1px solid rgba(255, 255, 255, 0.18);',
		'  backdrop-filter:blur(4px);',
		'}',
		'.alemprator-summary-fact__label {',
		'  display:block;',
		'  font-size:12px;',
		'  color:rgba(255, 255, 255, 0.74);',
		'}',
		'.alemprator-summary-fact__value {',
		'  display:block;',
		'  margin-top:6px;',
		'  color:#fff;',
		'  font:700 16px/1.45 "Trebuchet MS", Tahoma, sans-serif;',
		'  word-break:break-word;',
		'}',
		'.alemprator-status-card {',
		'  margin:0;',
		'}',
		'.alemprator-status-grid {',
		'  display:grid;',
		'  grid-template-columns:repeat(auto-fit, minmax(min(100%, 180px), 1fr));',
		'  gap:12px;',
		'  margin-top:14px;',
		'}',
		'@media (max-width: 560px) {',
		'  .alemprator-status-grid {',
		'    grid-template-columns:1fr;',
		'  }',
		'}',
		'.alemprator-status-item {',
		'  padding:14px 15px;',
		'  border-radius:18px;',
		'  background:#f6fafb;',
		'  border:1px solid #dfebef;',
		'}',
		'.alemprator-status-item.is-wide {',
		'  grid-column:1 / -1;',
		'}',
		'.alemprator-status-item__label {',
		'  display:block;',
		'  margin-bottom:6px;',
		'  color:#5c6c7a;',
		'  font-size:12px;',
		'}',
		'.alemprator-status-item__value {',
		'  color:#102a43;',
		'  font-weight:700;',
		'  line-height:1.6;',
		'  word-break:break-word;',
		'}',
		'.alemprator-wireless-list {',
		'  margin:0;',
		'  padding:0;',
		'  list-style:none;',
		'  display:grid;',
		'  gap:8px;',
		'}',
		'.alemprator-wireless-item {',
		'  padding:10px 12px;',
		'  border-radius:14px;',
		'  background:#fff;',
		'  border:1px solid #d9e7ed;',
		'  color:#234064;',
		'  font-weight:500;',
		'}',
		'.alemprator-empty-text {',
		'  margin:0;',
		'  color:#66788a;',
		'}',
		'.alemprator-step-nav {',
		'  display:grid;',
		'  grid-template-columns:repeat(auto-fit, minmax(170px, 1fr));',
		'  gap:10px;',
		'  margin:0 0 18px 0;',
		'}',
		'.alemprator-step-chip {',
		'  display:flex;',
		'  align-items:center;',
		'  gap:10px;',
		'  padding:11px 13px;',
		'  border-radius:18px;',
		'  border:1px solid #d6e2ef;',
		'  background:#fff;',
		'  box-shadow:0 6px 18px rgba(15, 23, 42, 0.04);',
		'  transition:transform .18s ease, box-shadow .18s ease, border-color .18s ease, background .18s ease;',
		'}',
		'.alemprator-step-chip.is-active {',
		'  border-color:#0f766e;',
		'  background:linear-gradient(180deg, #f4fffd 0%, #e7f8f5 100%);',
		'  box-shadow:0 0 0 1px rgba(15, 118, 110, 0.12) inset, 0 12px 28px rgba(15, 118, 110, 0.10);',
		'  transform:translateY(-1px);',
		'}',
		'.alemprator-step-chip.is-complete:not(.is-active) {',
		'  border-color:#cfe8df;',
		'  background:#f8fdfa;',
		'}',
		'.alemprator-step-index {',
		'  display:inline-flex;',
		'  align-items:center;',
		'  justify-content:center;',
		'  width:30px;',
		'  height:30px;',
		'  border-radius:50%;',
		'  background:#cbd5e1;',
		'  color:#1f2937;',
		'  font-weight:700;',
		'  flex:0 0 auto;',
		'}',
		'.alemprator-step-index.is-active {',
		'  background:#0f766e;',
		'  color:#fff;',
		'}',
		'.alemprator-step-index.is-complete:not(.is-active) {',
		'  background:#d97706;',
		'  color:#fff;',
		'}',
		'.alemprator-step-label {',
		'  color:#172033;',
		'  font-weight:600;',
		'  line-height:1.4;',
		'}',
		'.alemprator-steps-wrap {',
		'  padding:0;',
		'  background:none;',
		'  border:none;',
		'  box-shadow:none;',
		'}',
		'.alemprator-step-panel {',
		'  padding:0;',
		'  background:none;',
		'  border:none;',
		'}',
		'.alemprator-step-panel > h4 {',
		'  margin:0 0 10px 0;',
		'  color:#102a43;',
		'  font:700 23px/1.25 "Trebuchet MS", Tahoma, sans-serif;',
		'}',
		'.alemprator-step-panel > p {',
		'  margin:0 0 14px 0;',
		'  color:#52606d;',
		'  line-height:1.7;',
		'}',
		'.alemprator-card--section {',
		'  margin-top:18px;',
		'}',
		'.alemprator-card-grid {',
		'  display:grid;',
		'  grid-template-columns:repeat(4, minmax(0, 1fr));',
		'  gap:14px;',
		'  align-items:start;',
		'}',
		'.alemprator-card-grid--fluid {',
		'  margin-top:12px;',
		'  grid-template-columns:repeat(4, minmax(0, 1fr));',
		'}',
		'@media (max-width: 1280px) {',
		'  .alemprator-card-grid,',
		'  .alemprator-card-grid--fluid {',
		'    grid-template-columns:repeat(3, minmax(0, 1fr));',
		'  }',
		'}',
		'@media (max-width: 920px) {',
		'  .alemprator-card-grid,',
		'  .alemprator-card-grid--fluid {',
		'    grid-template-columns:repeat(2, minmax(0, 1fr));',
		'  }',
		'}',
		'@media (max-width: 760px) {',
		'  .alemprator-card-grid {',
		'    grid-template-columns:1fr;',
		'  }',
		'}',
		'.alemprator-card-grid > * {',
		'  min-width:0;',
		'}',
		'.alemprator-card-grid > .alemprator-card--section,',
		'.alemprator-card-grid > * > .alemprator-card--section {',
		'  margin-top:0;',
		'  height:100%;',
		'}',
		'.alemprator-card-grid > .alemprator-card--section.is-wide,',
		'.alemprator-card-grid > * > .alemprator-card--section.is-wide {',
		'  grid-column:1 / -1;',
		'  height:auto;',
		'}',
		'.alemprator-card-grid > .alemprator-notice,',
		'.alemprator-card-grid > .alemprator-card-grid {',
		'  grid-column:1 / -1;',
		'}',
		'.alemprator-card__body {',
		'  display:grid;',
		'  grid-template-columns:repeat(auto-fit, minmax(min(100%, 210px), 1fr));',
		'  gap:10px 16px;',
		'  align-items:start;',
		'}',
		'.alemprator-card__body > .alemprator-inline-summary,',
		'.alemprator-card__body > .alemprator-notice,',
		'.alemprator-card__body > p,',
		'.alemprator-card__body > .alemprator-responsive-fields,',
		'.alemprator-card__body > .alemprator-card-grid {',
		'  grid-column:1 / -1;',
		'}',
		'.alemprator-responsive-fields {',
		'  display:grid;',
		'  grid-template-columns:repeat(auto-fit, minmax(min(100%, 230px), 1fr));',
		'  gap:10px 16px;',
		'  align-items:start;',
		'}',
		'.alemprator-responsive-fields > .alemprator-notice,',
		'.alemprator-responsive-fields > .alemprator-responsive-fields {',
		'  grid-column:1 / -1;',
		'}',
		'.alemprator-inline-summary {',
		'  display:flex;',
		'  align-items:flex-start;',
		'  gap:10px;',
		'  flex-wrap:wrap;',
		'  margin:0 0 14px 0;',
		'  padding:10px 12px;',
		'  border-radius:16px;',
		'  border:1px solid #dbe7ef;',
		'  background:linear-gradient(180deg, #fbfdff 0%, #eef5f9 100%);',
		'}',
		'.alemprator-inline-summary__label {',
		'  color:#5c6c7a;',
		'  font-size:12px;',
		'  font-weight:700;',
		'  white-space:nowrap;',
		'}',
		'.alemprator-inline-summary__value {',
		'  color:#12344d;',
		'  font-weight:600;',
		'  line-height:1.7;',
		'  word-break:break-word;',
		'  flex:1 1 220px;',
		'}',
		'.alemprator-card--section .cbi-value:last-child {',
		'  margin-bottom:0;',
		'}',
		'.alemprator-notice {',
		'  margin-top:12px;',
		'  padding:12px 14px;',
		'  border-radius:16px;',
		'  border:1px solid #dce7ec;',
		'  background:#f7fafb;',
		'  color:#21405c;',
		'  line-height:1.7;',
		'}',
		'.alemprator-notice--accent {',
		'  border-color:#cfe1f8;',
		'  background:linear-gradient(180deg, #fafdff 0%, #eef6ff 100%);',
		'  color:#234064;',
		'}',
		'.alemprator-notice--info {',
		'  border-color:#abc7ff;',
		'  background:#eef6ff;',
		'  color:#1f3b6d;',
		'}',
		'.alemprator-notice--warning {',
		'  border-color:#f4c38a;',
		'  background:#fff4e8;',
		'  color:#8a3d06;',
		'}',
		'.alemprator-setup-wizard .cbi-value-title {',
		'  font-weight:700;',
		'  color:#12344d;',
		'}',
		'.alemprator-setup-wizard .cbi-value {',
		'  padding:10px 0;',
		'  border-top:1px solid #edf2f7;',
		'}',
		'.alemprator-setup-wizard .cbi-value:first-child {',
		'  border-top:none;',
		'  padding-top:0;',
		'}',
		'.alemprator-setup-wizard .cbi-value-field {',
		'  color:#2a3f52;',
		'}',
		'.alemprator-setup-wizard .cbi-input-text, .alemprator-setup-wizard .cbi-input-select, .alemprator-setup-wizard .cbi-input-password {',
		'  max-width:100%;',
		'  border-radius:12px;',
		'  border-color:#cbd8e6;',
		'  box-shadow:inset 0 1px 2px rgba(15, 23, 42, 0.03);',
		'}',
		'.alemprator-channel-row {',
		'  transition:background .18s ease, border-color .18s ease, box-shadow .18s ease;',
		'  border:1px solid transparent;',
		'  border-radius:14px;',
		'  padding:10px 12px;',
		'}',
		'.alemprator-channel-row.is-mesh-target {',
		'  border-color:#0f766e;',
		'  background:linear-gradient(180deg, #f3fffd 0%, #e6faf5 100%);',
		'  box-shadow:0 0 0 1px rgba(15, 118, 110, 0.10) inset;',
		'}',
		'.alemprator-setup-actions {',
		'  display:flex;',
		'  gap:10px;',
		'  justify-content:flex-end;',
		'  flex-wrap:wrap;',
		'  margin-top:20px;',
		'  padding:14px 16px;',
		'  border-radius:18px;',
		'  border:1px solid #d7e3ea;',
		'  background:rgba(250, 252, 253, 0.92);',
		'  box-shadow:0 12px 30px rgba(15, 23, 42, 0.06);',
		'}',
		'.alemprator-setup-actions .cbi-button {',
		'  min-width:110px;',
		'  border-radius:999px;',
		'}',
		'.alemprator-step-chip.is-skipped {',
		'  opacity:0.38;',
		'  pointer-events:none;',
		'}',
		'.alemprator-hotspot-fields {',
		'  margin-top:10px;',
		'}',
		'.alemprator-hotspot-advanced-toggle {',
		'  display:inline-flex;',
		'  align-items:center;',
		'  gap:6px;',
		'  margin:10px 0 0 0;',
		'  padding:7px 14px;',
		'  border-radius:999px;',
		'  border:1px solid #c3d6e8;',
		'  background:#f4f9fc;',
		'  color:#234064;',
		'  cursor:pointer;',
		'  font-size:13px;',
		'  font-weight:600;',
		'}'
	].join('\n');

	document.head.appendChild(styleTag);
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
		E('span', { 'class': 'alemprator-inline-summary__label' }, _('الملخص الحي')),
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
	if (value == 'ap' || value == 'ap_wds' || value == 'sta_wds' || value == 'mesh')
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
	var entries = [];
	var keys = Object.keys(status || {}).sort();
	var i;

	if (!keys.length)
		return E('p', { 'class': 'alemprator-empty-text' }, _('لا تتوفر حاليًا معلومات تشغيل مباشرة عن الواي فاي.'));

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

		entries.push(E('li', { 'class': 'alemprator-wireless-item' }, radioLabel({ '.name': radioName, band: radio.config && radio.config.band }) + ': ' + ifaceSummary.join(', ')));
	}

	return E('ul', { 'class': 'alemprator-wireless-list' }, entries);
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
		E('span', { 'class': 'alemprator-card__eyebrow' }, _('Live Overview')),
		E('h3', { 'class': 'alemprator-card__title' }, _('الحالة الحالية')),
		E('p', { 'class': 'alemprator-card__desc' }, _('ملخص سريع قبل الحفظ.')),
		E('div', { 'class': 'alemprator-status-grid' }, [
			renderStatusItem(_('الموديل'), E('span', (board && board.model) || (board && board.system) || '-')),
			renderStatusItem(_('المنصة'), E('span', (board && board.release && board.release.target) || '-')),
			renderStatusItem(_('عنوان LAN'), E('span', ipv4)),
			renderStatusItem(_('الواي فاي'), renderWirelessSummary(wirelessStatus), true)
		])
	]);
}

function renderWizardCard(title, description, children) {
	var headerChildren = [ E('h4', { 'style': 'margin:0;' }, title) ];
	var bodyChildren = Array.isArray(children) ? children.filter(function(child) { return child != null; }) : [];

	if (description)
		headerChildren.push(E('p', { 'style': 'margin:6px 0 0 0;' }, description));

	return E('div', { 'class': 'alemprator-card alemprator-card--section' }, [
		E('div', { 'style': 'margin-bottom:12px; padding-bottom:10px; border-bottom:1px solid #e3ebf4;' }, headerChildren),
		E('div', { 'class': 'alemprator-card__body' }, bodyChildren)
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

	if (!state.hotspotEnabled)
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
		setTextContent(this.refs.backupStatus, message);
		setTextContent(this.refs.backupCardSummary, message);
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

		this.setBackupStatus(_('تم بدء تنزيل ملف النسخة الاحتياطية.'));
	},

	safeRestoreConfigBackup: function() {
		var self = this;

		this.setBackupStatus(_('جاري رفع ملف النسخة الاحتياطية...'));

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

		this.setBackupStatus(_('جاري تطبيق النسخة الاحتياطية...'));

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
		var radio2g = getRadioByBand(this.radios || [], '2g');
		var radio5g = getRadioByBand(this.radios || [], '5g');

		if (this.refs.lanIpaddr)
			this.refs.lanIpaddr.value = this.state.lanIpaddr || '';

		if (this.refs.lanNetmask)
			this.refs.lanNetmask.value = this.state.lanNetmask || '';

		if (this.refs.mode)
			this.refs.mode.value = this.state.mode || 'ap';

		if (this.refs.wifiSsid)
			this.refs.wifiSsid.value = this.state.wifiSsid || '';

		if (this.refs.wifiSsid5gMode)
			this.refs.wifiSsid5gMode.value = this.state.wifiSsid5gMode || 'derived';

		if (this.refs.wifiSsid5g)
			this.refs.wifiSsid5g.value = this.state.wifiSsid5g || '';

		if (this.refs.wifiSsidVlan2g)
			this.refs.wifiSsidVlan2g.value = this.state.wifiSsidVlan2g || '';

		if (this.refs.wifiSsidVlan5g)
			this.refs.wifiSsidVlan5g.value = this.state.wifiSsidVlan5g || '';

		if (this.refs.wifiSsidIpSuffixPrimary)
			this.refs.wifiSsidIpSuffixPrimary.checked = !!this.state.wifiSsidVlanIpSuffix;

		if (this.refs.wifiSsidVlanIpSuffix)
			this.refs.wifiSsidVlanIpSuffix.checked = !!this.state.wifiSsidVlanIpSuffix;

		if (this.refs.wifiKey)
			this.refs.wifiKey.value = this.state.wifiKey || '';

		if (this.refs.uplinkSsid)
			this.refs.uplinkSsid.value = this.state.uplinkSsid || '';

		if (this.refs.uplinkKey)
			this.refs.uplinkKey.value = this.state.uplinkKey || '';

		if (this.refs.uplinkBand)
			this.refs.uplinkBand.value = this.state.uplinkBand || '2g';

		if (this.refs.meshId)
			this.refs.meshId.value = this.state.meshId || '';

		if (this.refs.meshKey)
			this.refs.meshKey.value = this.state.meshKey || '';

		if (this.refs.meshBand)
			this.refs.meshBand.value = this.state.meshBand || '2g';

		if (this.refs.isVlan)
			this.refs.isVlan.checked = !!this.state.isVlan;

		if (this.refs.vlanId)
			this.refs.vlanId.value = this.state.vlanId || '10';

		if (this.refs.channel2g && radio2g) {
			populateSelectOptions(
				this.refs.channel2g,
				channelChoices('2g', this.frequencyMap ? this.frequencyMap[radio2g['.name']] : null),
				this.state.channel2g
			);
		}

		if (this.refs.channel5g && radio5g) {
			populateSelectOptions(
				this.refs.channel5g,
				channelChoices('5g', this.frequencyMap ? this.frequencyMap[radio5g['.name']] : null),
				this.state.channel5g
			);
		}

		/* Keep step-3 radio mode/width selects aligned with freshly loaded state. */
		this.syncRadioModeWidthUi();

		if (this.refs.resetDisabled)
			this.refs.resetDisabled.checked = !!this.state.resetDisabled;

		if (this.refs.resetHoldSeconds)
			this.refs.resetHoldSeconds.value = this.state.resetHoldSeconds || '5';

		if (this.refs.wpsDisabled)
			this.refs.wpsDisabled.checked = !!this.state.wpsDisabled;

		if (this.refs.rebootEnabled)
			this.refs.rebootEnabled.checked = !!this.state.rebootEnabled;

		if (this.refs.rebootHours)
			this.refs.rebootHours.value = this.state.rebootHours || '24';

		if (this.refs.otaWindowStart)
			this.refs.otaWindowStart.value = String(this.state.otaWindowStart == null ? 2 : this.state.otaWindowStart);

		if (this.refs.otaWindowEnd)
			this.refs.otaWindowEnd.value = String(this.state.otaWindowEnd == null ? 6 : this.state.otaWindowEnd);

		if (this.refs.hotspotQuickEnabled)
			this.refs.hotspotQuickEnabled.checked = !!this.state.hotspotQuickEnabled;

		if (this.refs.hotspotQuickWanInterface)
			this.refs.hotspotQuickWanInterface.value = this.state.hotspotQuickWanInterface || 'lan';

		if (this.refs.hotspotQuickSubscriberInterface)
			this.refs.hotspotQuickSubscriberInterface.value = this.state.hotspotQuickSubscriberInterface || 'hotspot';

		if (this.refs.hotspotQuickSsid1)
			this.refs.hotspotQuickSsid1.value = this.state.hotspotQuickSsid1 || 'Hotspot-1';

		if (this.refs.hotspotQuickGateway1)
			this.refs.hotspotQuickGateway1.value = this.state.hotspotQuickGateway1 || '192.168.10.1';

		if (this.refs.hotspotQuickPoolStart1)
			this.refs.hotspotQuickPoolStart1.value = this.state.hotspotQuickPoolStart1 || '192.168.10.10';

		if (this.refs.hotspotQuickPoolEnd1)
			this.refs.hotspotQuickPoolEnd1.value = this.state.hotspotQuickPoolEnd1 || '192.168.10.199';

		if (this.refs.hotspotQuickPolicy1)
			this.refs.hotspotQuickPolicy1.value = this.state.hotspotQuickPolicy1 || 'standard';

		if (this.refs.hotspotQuickSecondaryEnabled)
			this.refs.hotspotQuickSecondaryEnabled.checked = this.state.hotspotQuickSecondaryEnabled !== false;

		if (this.refs.hotspotQuickSsid2)
			this.refs.hotspotQuickSsid2.value = this.state.hotspotQuickSsid2 || 'Hotspot-2';

		if (this.refs.hotspotQuickGateway2)
			this.refs.hotspotQuickGateway2.value = this.state.hotspotQuickGateway2 || '192.168.20.1';

		if (this.refs.hotspotQuickPoolStart2)
			this.refs.hotspotQuickPoolStart2.value = this.state.hotspotQuickPoolStart2 || '192.168.20.10';

		if (this.refs.hotspotQuickPoolEnd2)
			this.refs.hotspotQuickPoolEnd2.value = this.state.hotspotQuickPoolEnd2 || '192.168.20.199';

		if (this.refs.hotspotQuickPolicy2)
			this.refs.hotspotQuickPolicy2.value = this.state.hotspotQuickPolicy2 || 'premium';

		if (this.refs.hotspotQuickRadiusServer)
			this.refs.hotspotQuickRadiusServer.value = this.state.hotspotQuickRadiusServer || '192.168.1.2';

		if (this.refs.hotspotQuickRadiusServer2)
			this.refs.hotspotQuickRadiusServer2.value = this.state.hotspotQuickRadiusServer2 || '';

		if (this.refs.hotspotQuickRadiusSecret)
			this.refs.hotspotQuickRadiusSecret.value = this.state.hotspotQuickRadiusSecret || '';

		if (this.refs.hotspotQuickRadiusAuthPort)
			this.refs.hotspotQuickRadiusAuthPort.value = this.state.hotspotQuickRadiusAuthPort || '1812';

		if (this.refs.hotspotQuickRadiusAcctPort)
			this.refs.hotspotQuickRadiusAcctPort.value = this.state.hotspotQuickRadiusAcctPort || '1813';

		if (this.refs.hotspotQuickRadiusNasIp)
			this.refs.hotspotQuickRadiusNasIp.value = this.state.hotspotQuickRadiusNasIp || '';

		if (this.refs.hotspotQuickNasId)
			this.refs.hotspotQuickNasId.value = this.state.hotspotQuickNasId || '';

		if (this.refs.hotspotQuickAcctInterim)
			this.refs.hotspotQuickAcctInterim.value = this.state.hotspotQuickAcctInterim || '60';

		if (this.refs.hotspotQuickCoaEnabled)
			this.refs.hotspotQuickCoaEnabled.checked = !!this.state.hotspotQuickCoaEnabled;

		if (this.refs.hotspotQuickCoaPort)
			this.refs.hotspotQuickCoaPort.value = this.state.hotspotQuickCoaPort || '3799';

		if (this.refs.hotspotQuickTrialEnabled)
			this.refs.hotspotQuickTrialEnabled.checked = !!this.state.hotspotQuickTrialEnabled;

		if (this.refs.hotspotQuickTrialDuration)
			this.refs.hotspotQuickTrialDuration.value = this.state.hotspotQuickTrialDuration || '30';

		if (this.refs.hotspotQuickTrialUptimeLimit)
			this.refs.hotspotQuickTrialUptimeLimit.value = this.state.hotspotQuickTrialUptimeLimit || '30';

		if (this.refs.hotspotQuickMacAuthEnabled)
			this.refs.hotspotQuickMacAuthEnabled.checked = !!this.state.hotspotQuickMacAuthEnabled;

		if (this.refs.hotspotQuickMacAuthSuffix)
			this.refs.hotspotQuickMacAuthSuffix.value = this.state.hotspotQuickMacAuthSuffix || '@mac';

		if (this.refs.hotspotQuickMacAuthPassword)
			this.refs.hotspotQuickMacAuthPassword.value = this.state.hotspotQuickMacAuthPassword || 'mac';

		if (this.refs.hotspotQuickWalledGarden)
			this.refs.hotspotQuickWalledGarden.value = this.state.hotspotQuickWalledGarden || '';

		if (this.refs.hotspotQuickDomain)
			this.refs.hotspotQuickDomain.value = this.state.hotspotQuickDomain || 'hotspot.local';

		if (this.refs.hotspotQuickDns1)
			this.refs.hotspotQuickDns1.value = this.state.hotspotQuickDns1 || '8.8.8.8';

		if (this.refs.hotspotQuickDns2)
			this.refs.hotspotQuickDns2.value = this.state.hotspotQuickDns2 || '82.114.163.31';

		if (this.refs.hotspotQuickBridgeAgeingTime)
			this.refs.hotspotQuickBridgeAgeingTime.value = this.state.hotspotQuickBridgeAgeingTime || '10';

		if (this.refs.hotspotQuickLoginMode)
			this.refs.hotspotQuickLoginMode.value = normalizeHotspotLoginMode(this.state.hotspotQuickLoginMode);

		if (this.refs.hotspotQuickRateLimit)
			this.refs.hotspotQuickRateLimit.value = this.state.hotspotQuickRateLimit || '2M/5M';

		if (this.refs.hotspotQuickMacCookieEnabled)
			this.refs.hotspotQuickMacCookieEnabled.checked = !!this.state.hotspotQuickMacCookieEnabled;

		if (this.refs.hotspotQuickAvailableSpeeds)
			this.refs.hotspotQuickAvailableSpeeds.value = this.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast';

		if (this.refs.hotspotQuickSupportPhone)
			this.refs.hotspotQuickSupportPhone.value = this.state.hotspotQuickSupportPhone || '';

		if (this.refs.hotspotQuickNoticeText)
			this.refs.hotspotQuickNoticeText.value = this.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا';

		if (this.refs.hotspotQuickLiveStreamEnabled)
			this.refs.hotspotQuickLiveStreamEnabled.checked = !!this.state.hotspotQuickLiveStreamEnabled;

		if (this.refs.hotspotQuickLiveStreamUrl)
			this.refs.hotspotQuickLiveStreamUrl.value = this.state.hotspotQuickLiveStreamUrl || '';

		if (this.refs.hotspotQuickRestAreaEnabled)
			this.refs.hotspotQuickRestAreaEnabled.checked = !!this.state.hotspotQuickRestAreaEnabled;

		if (this.refs.hotspotQuickRestAreaUrl)
			this.refs.hotspotQuickRestAreaUrl.value = this.state.hotspotQuickRestAreaUrl || '';

		if (this.refs.hotspotQuickSpeedtestEnabled)
			this.refs.hotspotQuickSpeedtestEnabled.checked = !!this.state.hotspotQuickSpeedtestEnabled;

		if (this.refs.hotspotQuickBrowserCookieEnabled)
			this.refs.hotspotQuickBrowserCookieEnabled.checked = this.state.hotspotQuickBrowserCookieEnabled !== false;

		if (this.refs.hotspotQuickBrowserCookieDays)
			this.refs.hotspotQuickBrowserCookieDays.value = normalizeBrowserCookieDays(this.state.hotspotQuickBrowserCookieDays || '7');

		if (this.refs.hotspotQuickUsermanRestEnabled)
			this.refs.hotspotQuickUsermanRestEnabled.checked = !!this.state.hotspotQuickUsermanRestEnabled;

		if (this.refs.hotspotQuickUsermanRestScheme)
			this.refs.hotspotQuickUsermanRestScheme.value = normalizeRouterOsScheme(this.state.hotspotQuickUsermanRestScheme);

		if (this.refs.hotspotQuickUsermanRestUsername)
			this.refs.hotspotQuickUsermanRestUsername.value = this.state.hotspotQuickUsermanRestUsername || 'hotspot-read';

		if (this.refs.hotspotQuickUsermanRestPassword)
			this.refs.hotspotQuickUsermanRestPassword.value = this.state.hotspotQuickUsermanRestPassword || '';

		if (this.refs.adminPassword)
			this.refs.adminPassword.value = '';

		if (this.refs.adminPasswordConfirm)
			this.refs.adminPasswordConfirm.value = '';

		if (this.refs.hotspotEnabled)
			this.refs.hotspotEnabled.checked = !!this.state.hotspotEnabled;

		if (this.refs.hotspotSsid)
			this.refs.hotspotSsid.value = this.state.hotspotSsid || 'Hotspot';

		if (this.refs.hotspotRadiusServer)
			this.refs.hotspotRadiusServer.value = this.state.hotspotRadiusServer || '192.168.1.2';

		if (this.refs.hotspotRadiusSecret)
			this.refs.hotspotRadiusSecret.value = this.state.hotspotRadiusSecret || '';

		if (this.refs.hotspotNasId)
			this.refs.hotspotNasId.value = this.state.hotspotNasId || '';

		if (this.refs.hotspotIp)
			this.refs.hotspotIp.value = this.state.hotspotIp || '192.168.10.1';

		if (this.refs.hotspotPoolStart)
			this.refs.hotspotPoolStart.value = this.state.hotspotPoolStart || '192.168.10.10';

		if (this.refs.hotspotPoolEnd)
			this.refs.hotspotPoolEnd.value = this.state.hotspotPoolEnd || '192.168.10.254';
	},

	reloadStateFromDevice: function() {
		var self = this;
		var configs = [ 'alemprator_firstboot', 'alemprator_ota', 'setup', 'watchcat', 'network', 'wireless', 'hotspot_openwrt', 'hotspot_licensing' ];

		if (!window.confirm(_('سيتم استبدال القيم الحالية داخل المعالج بإعدادات الجهاز الفعلية. هل تريد المتابعة؟')))
			return Promise.resolve();

		if (this.refs.reloadButton) {
			this.refs.reloadButton.disabled = true;
			this.refs.reloadButton.textContent = _('جارٍ التحديث...');
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
		var hotspotQuickWanInterface = normalizeInterfaceName(uci.get('setup', 'default', 'hotspot_quick_wan_interface') || uci.get('hotspot_openwrt', 'main', 'wan_interface') || 'lan', 'lan');
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
			hotspotEnabled: uci.get('hotspot_openwrt', 'main', 'enabled') === '1',
			hotspotSsid: (function() {
				var sec = findNamedWifiIfaceSection('wizard_hotspot');
				return sec ? String(sec.ssid || 'Hotspot') : 'Hotspot';
			}()),
			hotspotRadiusServer: uci.get('hotspot_openwrt', 'main', 'radius_server') || '192.168.1.2',
			hotspotRadiusSecret: uci.get('hotspot_openwrt', 'main', 'radius_secret') || '',
			hotspotNasId: uci.get('hotspot_openwrt', 'main', 'radius_nas_id') || '',
			hotspotIp: uci.get('hotspot_openwrt', 'main', 'hotspot_ip') || '192.168.10.1',
			hotspotPoolStart: uci.get('hotspot_openwrt', 'main', 'pool_start') || '192.168.10.10',
			hotspotPoolEnd: uci.get('hotspot_openwrt', 'main', 'pool_end') || '192.168.10.254'
		};
	},

	collectState: function() {
		this.state.lanIpaddr = this.refs.lanIpaddr.value.trim();
		this.state.lanNetmask = this.refs.lanNetmask.value.trim();
		this.state.mode = this.refs.mode.value;
		this.state.wifiSsid = this.refs.wifiSsid.value.trim();
		this.state.wifiSsid5gMode = this.refs.wifiSsid5gMode ? this.refs.wifiSsid5gMode.value : (this.state.wifiSsid5gMode || 'derived');
		this.state.wifiSsid5g = this.refs.wifiSsid5g ? this.refs.wifiSsid5g.value.trim() : (this.state.wifiSsid5g || '');
		this.state.wifiSsidVlan2g = this.refs.wifiSsidVlan2g ? this.refs.wifiSsidVlan2g.value.trim() : (this.state.wifiSsidVlan2g || '');
		this.state.wifiSsidVlan5g = this.refs.wifiSsidVlan5g ? this.refs.wifiSsidVlan5g.value.trim() : (this.state.wifiSsidVlan5g || '');
		this.state.wifiSsidVlanIpSuffix = this.refs.wifiSsidIpSuffixPrimary ? this.refs.wifiSsidIpSuffixPrimary.checked : (this.refs.wifiSsidVlanIpSuffix ? this.refs.wifiSsidVlanIpSuffix.checked : !!this.state.wifiSsidVlanIpSuffix);
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
		this.state.otaWindowStart = this.refs.otaWindowStart ? normalizeHour(this.refs.otaWindowStart.value, 2) : this.state.otaWindowStart;
		this.state.otaWindowEnd = this.refs.otaWindowEnd ? normalizeHour(this.refs.otaWindowEnd.value, 6) : this.state.otaWindowEnd;
		this.state.hotspotQuickEnabled = this.refs.hotspotQuickEnabled ? this.refs.hotspotQuickEnabled.checked : !!this.state.hotspotQuickEnabled;
		this.state.hotspotQuickWanInterface = this.refs.hotspotQuickWanInterface ? this.refs.hotspotQuickWanInterface.value.trim() : (this.state.hotspotQuickWanInterface || 'lan');
		this.state.hotspotQuickSubscriberInterface = this.refs.hotspotQuickSubscriberInterface ? this.refs.hotspotQuickSubscriberInterface.value.trim() : (this.state.hotspotQuickSubscriberInterface || 'hotspot');
		this.state.hotspotQuickSsid1 = this.refs.hotspotQuickSsid1 ? this.refs.hotspotQuickSsid1.value.trim() : (this.state.hotspotQuickSsid1 || 'Hotspot-1');
		this.state.hotspotQuickGateway1 = this.refs.hotspotQuickGateway1 ? this.refs.hotspotQuickGateway1.value.trim() : (this.state.hotspotQuickGateway1 || '192.168.10.1');
		this.state.hotspotQuickPoolStart1 = this.refs.hotspotQuickPoolStart1 ? this.refs.hotspotQuickPoolStart1.value.trim() : deriveHotspotPoolStart(this.state.hotspotQuickGateway1);
		this.state.hotspotQuickPoolEnd1 = this.refs.hotspotQuickPoolEnd1 ? this.refs.hotspotQuickPoolEnd1.value.trim() : deriveHotspotPoolEnd(this.state.hotspotQuickGateway1);
		this.state.hotspotQuickPolicy1 = normalizeHotspotPolicy(this.refs.hotspotQuickPolicy1 ? this.refs.hotspotQuickPolicy1.value : this.state.hotspotQuickPolicy1, 'standard');
		this.state.hotspotQuickSecondaryEnabled = this.refs.hotspotQuickSecondaryEnabled ? this.refs.hotspotQuickSecondaryEnabled.checked : (this.state.hotspotQuickSecondaryEnabled !== false);
		this.state.hotspotQuickSsid2 = this.refs.hotspotQuickSsid2 ? this.refs.hotspotQuickSsid2.value.trim() : (this.state.hotspotQuickSsid2 || 'Hotspot-2');
		this.state.hotspotQuickGateway2 = this.refs.hotspotQuickGateway2 ? this.refs.hotspotQuickGateway2.value.trim() : (this.state.hotspotQuickGateway2 || '192.168.20.1');
		this.state.hotspotQuickPoolStart2 = this.refs.hotspotQuickPoolStart2 ? this.refs.hotspotQuickPoolStart2.value.trim() : deriveHotspotPoolStart(this.state.hotspotQuickGateway2);
		this.state.hotspotQuickPoolEnd2 = this.refs.hotspotQuickPoolEnd2 ? this.refs.hotspotQuickPoolEnd2.value.trim() : deriveHotspotPoolEnd(this.state.hotspotQuickGateway2);
		this.state.hotspotQuickPolicy2 = normalizeHotspotPolicy(this.refs.hotspotQuickPolicy2 ? this.refs.hotspotQuickPolicy2.value : this.state.hotspotQuickPolicy2, 'premium');
		this.state.hotspotQuickRadiusServer = this.refs.hotspotQuickRadiusServer ? this.refs.hotspotQuickRadiusServer.value.trim() : (this.state.hotspotQuickRadiusServer || '192.168.1.2');
		this.state.hotspotQuickRadiusServer2 = this.refs.hotspotQuickRadiusServer2 ? this.refs.hotspotQuickRadiusServer2.value.trim() : (this.state.hotspotQuickRadiusServer2 || '');
		this.state.hotspotQuickRadiusSecret = this.refs.hotspotQuickRadiusSecret ? this.refs.hotspotQuickRadiusSecret.value : (this.state.hotspotQuickRadiusSecret || '');
		this.state.hotspotQuickRadiusAuthPort = this.refs.hotspotQuickRadiusAuthPort ? this.refs.hotspotQuickRadiusAuthPort.value.trim() : (this.state.hotspotQuickRadiusAuthPort || '1812');
		this.state.hotspotQuickRadiusAcctPort = this.refs.hotspotQuickRadiusAcctPort ? this.refs.hotspotQuickRadiusAcctPort.value.trim() : (this.state.hotspotQuickRadiusAcctPort || '1813');
		this.state.hotspotQuickRadiusNasIp = this.refs.hotspotQuickRadiusNasIp ? this.refs.hotspotQuickRadiusNasIp.value.trim() : (this.state.hotspotQuickRadiusNasIp || '');
		this.state.hotspotQuickNasId = deriveHotspotQuickNasId(this.state.hotspotQuickNasId, this.state.lanIpaddr);
		this.state.hotspotQuickAcctInterim = this.refs.hotspotQuickAcctInterim ? this.refs.hotspotQuickAcctInterim.value.trim() : (this.state.hotspotQuickAcctInterim || '60');
		this.state.hotspotQuickCoaEnabled = this.refs.hotspotQuickCoaEnabled ? this.refs.hotspotQuickCoaEnabled.checked : !!this.state.hotspotQuickCoaEnabled;
		this.state.hotspotQuickCoaPort = this.refs.hotspotQuickCoaPort ? this.refs.hotspotQuickCoaPort.value.trim() : (this.state.hotspotQuickCoaPort || '3799');
		this.state.hotspotQuickTrialEnabled = this.refs.hotspotQuickTrialEnabled ? this.refs.hotspotQuickTrialEnabled.checked : !!this.state.hotspotQuickTrialEnabled;
		this.state.hotspotQuickTrialDuration = this.refs.hotspotQuickTrialDuration ? this.refs.hotspotQuickTrialDuration.value.trim() : (this.state.hotspotQuickTrialDuration || '30');
		this.state.hotspotQuickTrialUptimeLimit = this.refs.hotspotQuickTrialUptimeLimit ? this.refs.hotspotQuickTrialUptimeLimit.value.trim() : (this.state.hotspotQuickTrialUptimeLimit || '30');
		this.state.hotspotQuickMacAuthEnabled = this.refs.hotspotQuickMacAuthEnabled ? this.refs.hotspotQuickMacAuthEnabled.checked : !!this.state.hotspotQuickMacAuthEnabled;
		this.state.hotspotQuickMacAuthSuffix = this.refs.hotspotQuickMacAuthSuffix ? this.refs.hotspotQuickMacAuthSuffix.value.trim() : (this.state.hotspotQuickMacAuthSuffix || '@mac');
		this.state.hotspotQuickMacAuthPassword = this.refs.hotspotQuickMacAuthPassword ? this.refs.hotspotQuickMacAuthPassword.value : (this.state.hotspotQuickMacAuthPassword || 'mac');
		this.state.hotspotQuickWalledGarden = this.refs.hotspotQuickWalledGarden ? this.refs.hotspotQuickWalledGarden.value.trim() : (this.state.hotspotQuickWalledGarden || '');
		this.state.hotspotQuickDomain = this.refs.hotspotQuickDomain ? this.refs.hotspotQuickDomain.value.trim() : (this.state.hotspotQuickDomain || 'hotspot.local');
		this.state.hotspotQuickDns1 = this.refs.hotspotQuickDns1 ? this.refs.hotspotQuickDns1.value.trim() : (this.state.hotspotQuickDns1 || '8.8.8.8');
		this.state.hotspotQuickDns2 = this.refs.hotspotQuickDns2 ? this.refs.hotspotQuickDns2.value.trim() : (this.state.hotspotQuickDns2 || '82.114.163.31');
		this.state.hotspotQuickBridgeAgeingTime = normalizePositiveNumber(this.refs.hotspotQuickBridgeAgeingTime ? this.refs.hotspotQuickBridgeAgeingTime.value.trim() : (this.state.hotspotQuickBridgeAgeingTime || '10'), '10');
		this.state.hotspotQuickLoginMode = normalizeHotspotLoginMode(this.refs.hotspotQuickLoginMode ? this.refs.hotspotQuickLoginMode.value : this.state.hotspotQuickLoginMode);
		this.state.hotspotQuickRateLimit = this.refs.hotspotQuickRateLimit ? this.refs.hotspotQuickRateLimit.value.trim() : (this.state.hotspotQuickRateLimit || '2M/5M');
		this.state.hotspotQuickMacCookieEnabled = this.refs.hotspotQuickMacCookieEnabled ? this.refs.hotspotQuickMacCookieEnabled.checked : !!this.state.hotspotQuickMacCookieEnabled;
		this.state.hotspotQuickAvailableSpeeds = this.refs.hotspotQuickAvailableSpeeds ? this.refs.hotspotQuickAvailableSpeeds.value.trim() : (this.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
		this.state.hotspotQuickSupportPhone = this.refs.hotspotQuickSupportPhone ? this.refs.hotspotQuickSupportPhone.value.trim() : (this.state.hotspotQuickSupportPhone || '');
		this.state.hotspotQuickNoticeText = this.refs.hotspotQuickNoticeText ? this.refs.hotspotQuickNoticeText.value.trim() : (this.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا');
		this.state.hotspotQuickLiveStreamEnabled = this.refs.hotspotQuickLiveStreamEnabled ? this.refs.hotspotQuickLiveStreamEnabled.checked : !!this.state.hotspotQuickLiveStreamEnabled;
		this.state.hotspotQuickLiveStreamUrl = this.refs.hotspotQuickLiveStreamUrl ? this.refs.hotspotQuickLiveStreamUrl.value.trim() : (this.state.hotspotQuickLiveStreamUrl || '');
		this.state.hotspotQuickRestAreaEnabled = this.refs.hotspotQuickRestAreaEnabled ? this.refs.hotspotQuickRestAreaEnabled.checked : !!this.state.hotspotQuickRestAreaEnabled;
		this.state.hotspotQuickRestAreaUrl = this.refs.hotspotQuickRestAreaUrl ? this.refs.hotspotQuickRestAreaUrl.value.trim() : (this.state.hotspotQuickRestAreaUrl || '');
		this.state.hotspotQuickSpeedtestEnabled = this.refs.hotspotQuickSpeedtestEnabled ? this.refs.hotspotQuickSpeedtestEnabled.checked : !!this.state.hotspotQuickSpeedtestEnabled;
		this.state.hotspotQuickBrowserCookieEnabled = this.refs.hotspotQuickBrowserCookieEnabled ? this.refs.hotspotQuickBrowserCookieEnabled.checked : (this.state.hotspotQuickBrowserCookieEnabled !== false);
		this.state.hotspotQuickBrowserCookieDays = normalizeBrowserCookieDays(this.refs.hotspotQuickBrowserCookieDays ? this.refs.hotspotQuickBrowserCookieDays.value.trim() : (this.state.hotspotQuickBrowserCookieDays || '7'));
		this.state.hotspotQuickUsermanRestEnabled = this.refs.hotspotQuickUsermanRestEnabled ? this.refs.hotspotQuickUsermanRestEnabled.checked : !!this.state.hotspotQuickUsermanRestEnabled;
		this.state.hotspotQuickUsermanRestScheme = normalizeRouterOsScheme(this.refs.hotspotQuickUsermanRestScheme ? this.refs.hotspotQuickUsermanRestScheme.value : this.state.hotspotQuickUsermanRestScheme);
		this.state.hotspotQuickUsermanRestUsername = this.refs.hotspotQuickUsermanRestUsername ? this.refs.hotspotQuickUsermanRestUsername.value.trim() : (this.state.hotspotQuickUsermanRestUsername || 'hotspot-read');
		this.state.hotspotQuickUsermanRestPassword = this.refs.hotspotQuickUsermanRestPassword ? this.refs.hotspotQuickUsermanRestPassword.value : (this.state.hotspotQuickUsermanRestPassword || '');
		this.state.adminPassword = this.refs.adminPassword ? this.refs.adminPassword.value : '';
		this.state.adminPasswordConfirm = this.refs.adminPasswordConfirm ? this.refs.adminPasswordConfirm.value : '';
		this.state.hotspotEnabled = this.refs.hotspotEnabled ? this.refs.hotspotEnabled.checked : false;
		this.state.hotspotSsid = this.refs.hotspotSsid ? this.refs.hotspotSsid.value.trim() : (this.state.hotspotSsid || 'Hotspot');
		this.state.hotspotRadiusServer = this.refs.hotspotRadiusServer ? this.refs.hotspotRadiusServer.value.trim() : (this.state.hotspotRadiusServer || '192.168.1.2');
		this.state.hotspotRadiusSecret = this.refs.hotspotRadiusSecret ? this.refs.hotspotRadiusSecret.value : '';
		this.state.hotspotNasId = this.refs.hotspotNasId ? this.refs.hotspotNasId.value.trim() : (this.state.hotspotNasId || '');
		this.state.hotspotIp = this.refs.hotspotIp ? this.refs.hotspotIp.value.trim() : (this.state.hotspotIp || '192.168.10.1');
		this.state.hotspotPoolStart = this.refs.hotspotPoolStart ? this.refs.hotspotPoolStart.value.trim() : (this.state.hotspotPoolStart || '192.168.10.10');
		this.state.hotspotPoolEnd = this.refs.hotspotPoolEnd ? this.refs.hotspotPoolEnd.value.trim() : (this.state.hotspotPoolEnd || '192.168.10.254');
	},

	describeModePlan: function() {
		var radio2g = getRadioByBand(this.radios || [], '2g');
		var remainingBands = getRemainingLocalBands(this.radios || [], this.state);
		var onlyBand = remainingBands[0];
		var uplinkBand = getRadioByBand(this.radios || [], this.state.uplinkBand) ? this.state.uplinkBand : (radio2g ? '2g' : '5g');
		var meshBand = getRadioByBand(this.radios || [], this.state.meshBand) ? this.state.meshBand : (radio2g ? '2g' : '5g');

		if (this.state.mode == 'ap_wds') {
			if (!remainingBands.length)
				return _('AP + WDS بدون شبكة محلية.');

			if (remainingBands.length == 1)
				return _('AP + WDS على ') + bandLabel(onlyBand) + _('.');

			return _('AP + WDS على الراديوهات المحلية.');
		}

		if (this.state.mode == 'sta_wds') {
			if (!remainingBands.length)
				return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، ولا توجد شبكة محلية.');

			if (remainingBands.length == 1)
				return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، والبث المحلي على ') + bandLabel(onlyBand) + _('.');

			return _('الربط الصاعد على ') + bandLabel(uplinkBand) + _('، والباقي للبث المحلي.');
		}

		if (this.state.mode == 'mesh') {
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
		var vlanId = this.state.vlanId || '10';
		var vlanBinding = describeSecondaryVlanBinding(vlanId);
		var secondary2g = previewSecondarySsid(this.state, '2g');
		var secondary5g = previewSecondarySsid(this.state, '5g');
		var remainingBands = getRemainingLocalBands(this.radios || [], this.state);
		var remainingCount = remainingBands.length;
		var onlyBand = remainingCount ? remainingBands[0] : null;
		var firstBand = remainingBands[0];
		var secondBand = remainingBands[1];
		if (!this.state.isVlan)
			return _('معطلة.');

		if (!remainingCount)
			return _('مفعلة بدون بث لاسلكي.');

		if (remainingCount == 1)
			return _('مفعلة على ') + bandLabel(onlyBand) + _(': ') + previewSecondarySsid(this.state, onlyBand) + _(' ضمن ') + vlanBinding + _('.');

		return _('مفعلة: ') + bandLabel(firstBand) + ' ' + secondary2g + _(' | ') + bandLabel(secondBand) + ' ' + secondary5g + _(' ضمن ') + vlanBinding + _('.');
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
		enforceHotspotNoVlan(this.state);
		if (this.state.hotspotQuickEnabled) {
			this.state.mode = 'ap';
			if (this.refs.mode)
				this.refs.mode.value = 'ap';
		}
		vlanBinding = describeSecondaryVlanBinding(this.state.vlanId);
		meshBandIs5g = (this.state.meshBand == '5g');
		meshChannel = meshBandIs5g ? this.state.channel5g : this.state.channel2g;

		if (this.refs.isVlan)
			this.refs.isVlan.checked = !!this.state.isVlan;

		for (i = 0; i < this.stepPanels.length; i++) {
			this.stepPanels[i].style.display = (i == this.stepIndex) ? '' : 'none';

			if (this.stepChips && this.stepChips[i]) {
				setClassState(this.stepChips[i], 'is-active', i == this.stepIndex);
				setClassState(this.stepChips[i], 'is-complete', i < this.stepIndex);
				setClassState(this.stepChips[i], 'is-skipped', this.isStepSkipped(i));
			}

			if (this.stepBadges && this.stepBadges[i]) {
				setClassState(this.stepBadges[i], 'is-active', i == this.stepIndex);
				setClassState(this.stepBadges[i], 'is-complete', i < this.stepIndex);
			}
		}

		this.refs.backButton.disabled = (this.stepIndex === 0);
		setElementVisible(this.refs.nextButton, this.stepIndex !== lastStep);
		setElementVisible(this.refs.saveButton, this.stepIndex === lastStep);
		setElementVisible(this.refs.uplinkSettingsWrapper, this.state.mode == 'sta_wds');
		setElementVisible(this.refs.meshSettingsWrapper, this.state.mode == 'mesh');
		setElementVisible(this.refs.hotspotQuickDetailsWrapper, !!this.state.hotspotQuickEnabled);
		setElementVisible(this.refs.hotspotQuickSecondaryWrapper, !!(this.state.hotspotQuickEnabled && this.state.hotspotQuickSecondaryEnabled));
		if (this.refs.hotspotQuickCard)
			setClassState(this.refs.hotspotQuickCard, 'is-wide', !!this.state.hotspotQuickEnabled);
		if (this.refs.vlanSettingsCard)
			setElementVisible(this.refs.vlanSettingsCard, !this.state.hotspotQuickEnabled);
		if (this.refs.mode)
			this.refs.mode.disabled = !!this.state.hotspotQuickEnabled;
		setElementVisible(this.refs.vlanIdWrapper, this.refs.isVlan.checked);
		if (this.refs.vlanSsid2gRow)
			setElementVisible(this.refs.vlanSsid2gRow, this.refs.isVlan.checked);
		if (this.refs.vlanSsid5gRow)
			setElementVisible(this.refs.vlanSsid5gRow, this.refs.isVlan.checked);
		if (this.refs.vlanSsidIpSuffixRow)
			setElementVisible(this.refs.vlanSsidIpSuffixRow, true);
		setElementVisible(this.refs.vlanPreviewWrapper, this.refs.isVlan.checked);
		if (this.refs.hotspotVlanLockNotice)
			setElementVisible(this.refs.hotspotVlanLockNotice, !!this.state.hotspotQuickEnabled);

		if (this.refs.isVlan)
			this.refs.isVlan.disabled = !!this.state.hotspotQuickEnabled;
		if (this.refs.vlanId)
			this.refs.vlanId.disabled = !!this.state.hotspotQuickEnabled;
		if (this.refs.wifiSsidVlan2g)
			this.refs.wifiSsidVlan2g.disabled = !!this.state.hotspotQuickEnabled;
		if (this.refs.wifiSsidVlan5g)
			this.refs.wifiSsidVlan5g.disabled = !!this.state.hotspotQuickEnabled;
		if (this.refs.wifiSsidVlanIpSuffix)
			this.refs.wifiSsidVlanIpSuffix.disabled = !!this.state.hotspotQuickEnabled;
		if (this.refs.wifiSsidIpSuffixPrimary)
			this.refs.wifiSsidIpSuffixPrimary.disabled = !!this.state.hotspotQuickEnabled;
		setElementVisible(this.refs.resetHoldWrapper, !this.refs.resetDisabled.checked);
		setElementVisible(this.refs.rebootHoursWrapper, this.refs.rebootEnabled.checked);
		var apVlanOnlyMode = (this.state.mode == 'ap' && this.state.isVlan);
		if (this.refs.primaryWifiSection)
			setElementVisible(this.refs.primaryWifiSection, !apVlanOnlyMode && !this.state.hotspotQuickEnabled);
		if (this.refs.wifiSecurityCard)
			setElementVisible(this.refs.wifiSecurityCard, !this.state.hotspotQuickEnabled);
		if (this.refs.apVlanWarning)
			setElementVisible(this.refs.apVlanWarning, apVlanOnlyMode);
		var hasLocal5g = (getRemainingLocalBands(this.radios || [], this.state).indexOf('5g') != -1);
		if (this.refs.ssid5gModeRow)
			setElementVisible(this.refs.ssid5gModeRow, hasLocal5g);
		if (this.refs.ssid5gCustomRow)
			setElementVisible(this.refs.ssid5gCustomRow, hasLocal5g && this.state.wifiSsid5gMode == 'custom');
		if (this.refs.ssidPreviewRow)
			setElementVisible(this.refs.ssidPreviewRow, hasLocal5g);
		this.refs.ssidPreview.textContent = primarySsid(this.state, '5g');
		if (this.refs.heroCurrentLan)
			this.refs.heroCurrentLan.textContent = this.state.lanIpaddr || '-';
		if (this.refs.heroCurrentMode)
			this.refs.heroCurrentMode.textContent = modeTitle(this.state.mode);
		if (this.refs.heroCurrentSecondary)
			this.refs.heroCurrentSecondary.textContent = this.state.hotspotQuickEnabled
				? _('هوتسبوت سريع: شبكتان')
				: describeHeroSecondarySummary(this.state, this.radios || []);
		if (this.refs.heroSetupSummary)
			this.refs.heroSetupSummary.textContent = describeFirstbootSummary(this.state);
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
			setClassState(this.refs.channel2gRow, 'is-mesh-target', this.state.mode == 'mesh' && !meshBandIs5g);
		}

		if (this.refs.channel5gRow) {
			setClassState(this.refs.channel5gRow, 'is-mesh-target', this.state.mode == 'mesh' && meshBandIs5g);
		}

		if (this.refs.meshChannelHelp) {
			if (this.state.mode == 'mesh') {
				setElementVisible(this.refs.meshChannelHelp, true);
				this.refs.meshChannelHelp.textContent = describeMeshChannelHelp(this.state, this.radios || []);
			}
			else {
				setElementVisible(this.refs.meshChannelHelp, false);
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
			setElementVisible(this.refs.secondaryNetworkNotice, this.state.isVlan);
		}

		if (this.refs.otaWindowStatus)
			this.refs.otaWindowStatus.textContent = this.state.otaWindowAvailable ? describeOtaWindow(this.state.otaWindowStart, this.state.otaWindowEnd) : _('إعدادات التحديث التلقائي غير متوفرة على هذا الجهاز.');

		if (this.refs.firstbootSummary)
			this.refs.firstbootSummary.textContent = describeFirstbootSummary(this.state);

		if (this.refs.firstbootEnabledStatus)
			this.refs.firstbootEnabledStatus.textContent = enabledText(this.state.firstbootEnabled);

		if (this.refs.firstbootConfiguredOnceStatus)
			this.refs.firstbootConfiguredOnceStatus.textContent = boolText(this.state.firstbootConfiguredOnce);

		if (this.refs.firstbootInitialSetupStatus)
			this.refs.firstbootInitialSetupStatus.textContent = boolText(this.state.firstbootInitialSetupComplete);

		if (this.refs.firstbootCleanupStatus)
			this.refs.firstbootCleanupStatus.textContent = describeFirstbootCleanupState(this.state.firstbootAutoCleanupArmed, this.state.firstbootAutoCleanupPending);

		if (this.refs.firstbootSections)
			this.refs.firstbootSections.textContent = describeFirstbootSections(this.state);

		setTextContent(this.refs.lanCardSummary, summarizeLanCard(this.state));
		setTextContent(this.refs.modeCardSummary, summarizeModeCard(this.state));
		setTextContent(this.refs.primaryWifiCardSummary, summarizePrimaryWifiCard(this.state, this.radios || []));
		setTextContent(this.refs.wifiSecurityCardSummary, summarizeWifiSecurity(this.state));
		setTextContent(this.refs.uplinkCardSummary, summarizeUplinkCard(this.state, this.radios || []));
		setTextContent(this.refs.meshCardSummary, summarizeMeshCard(this.state, this.radios || []));
		setTextContent(this.refs.vlanCardSummary, summarizeVlanCard(this.state, this.radios || []));
		setTextContent(this.refs.radioCardSummary, summarizeChannelCard(this.state, this.radios || []));
		setTextContent(this.refs.backupCardSummary, (this.refs.backupStatus && this.refs.backupStatus.textContent) || _('جاهز لتنزيل النسخة الاحتياطية أو استرجاعها بأمان.'));
		setTextContent(this.refs.firstbootCardSummary, describeFirstbootSummary(this.state));
		setTextContent(this.refs.otaCardSummary, summarizeOtaCard(this.state));
		setTextContent(this.refs.buttonPoliciesCardSummary, summarizeButtonPolicies(this.state));
		setTextContent(this.refs.rebootCardSummary, summarizeRebootPolicy(this.state));
		setTextContent(this.refs.passwordCardSummary, summarizePasswordCard(this.state));

		setTextContent(this.refs.hotspotCardSummary, summarizeHotspotCard(this.state));

		if (this.refs.hotspotFieldsWrapper)
			setElementVisible(this.refs.hotspotFieldsWrapper, !!(this.state.hotspotAvailable && this.state.hotspotEnabled));

		if (this.refs.hotspotIpConflictWarning) {
			var showConflict = this.state.hotspotEnabled && hotspotIpConflictsWithLan(this.state.lanIpaddr, this.state.hotspotIp);
			setElementVisible(this.refs.hotspotIpConflictWarning, showConflict);
		}
	},

	validateStep: function(index) {
		this.collectState();

		if (STEP_KEYS[index] == 'hotspot') {
			if (this.state.hotspotAvailable && this.state.hotspotEnabled) {
				if (!isIPv4(this.state.hotspotRadiusServer)) {
					notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS.'));
					return false;
				}

				if (!this.state.hotspotRadiusSecret) {
					notify(_('كلمة سر RADIUS مطلوبة.'));
					return false;
				}

				if (!this.state.hotspotSsid) {
					notify(_('أدخل اسم شبكة الهوتسبوت.'));
					return false;
				}

				if (!isIPv4(this.state.hotspotIp)) {
					notify(_('أدخل عنوان IPv4 صالحاً لشبكة الهوتسبوت.'));
					return false;
				}

				if (hotspotIpConflictsWithLan(this.state.lanIpaddr, this.state.hotspotIp)) {
					notify(_('نطاق الهوتسبوت يتعارض مع نطاق LAN. غيّر hotspot IP إلى نطاق مختلف (مثل 192.168.10.1).'));
					return false;
				}

				var localRadios = this.radios || [];
				if (!localRadios.length) {
					notify(_('لا توجد راديوهات واي فاي متاحة لبث شبكة الهوتسبوت.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'lan' || STEP_KEYS[index] == 'options') {
			if (!isIPv4(this.state.lanIpaddr)) {
				notify(_('أدخل عنوان LAN IPv4 صالحًا.'));
				return false;
			}

			if (!isIPv4(this.state.lanNetmask)) {
				notify(_('أدخل قناع شبكة LAN صالحًا.'));
				return false;
			}
		}

		if (STEP_KEYS[index] == 'mode' || STEP_KEYS[index] == 'options') {
			if (normalizeMode(this.state.mode) != this.state.mode) {
				notify(_('اختر وضع تشغيل صالحًا.'));
				return false;
			}

			if (this.state.hotspotQuickEnabled && this.state.mode != 'ap') {
				notify(_('وضع الهوتسبوت السريع يعمل فقط مع نقطة الوصول AP.'));
				return false;
			}

			if (this.state.hotspotQuickEnabled && this.state.isVlan) {
				notify(_('لا يمكن تفعيل VLAN مع الهوتسبوت السريع.'));
				return false;
			}

			if (this.state.hotspotQuickEnabled) {
				if (!isIPv4(this.state.hotspotQuickRadiusServer)) {
					notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS في الهوتسبوت السريع.'));
					return false;
				}

				if (this.state.hotspotQuickRadiusServer2 && !isIPv4(this.state.hotspotQuickRadiusServer2)) {
					notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS الاحتياطي أو اتركه فارغاً.'));
					return false;
				}

				if (!this.state.hotspotQuickRadiusSecret) {
					notify(_('كلمة سر RADIUS مطلوبة للهوتسبوت السريع.'));
					return false;
				}

				if (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickRadiusAuthPort) || +this.state.hotspotQuickRadiusAuthPort > 65535) {
					notify(_('أدخل منفذ RADIUS Auth صحيحاً بين 1 و65535.'));
					return false;
				}

				if (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickRadiusAcctPort) || +this.state.hotspotQuickRadiusAcctPort > 65535) {
					notify(_('أدخل منفذ RADIUS Accounting صحيحاً بين 1 و65535.'));
					return false;
				}

				if (this.state.hotspotQuickRadiusNasIp && !isIPv4(this.state.hotspotQuickRadiusNasIp)) {
					notify(_('أدخل NAS IP صحيحاً أو اتركه فارغاً.'));
					return false;
				}

				if (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickAcctInterim)) {
					notify(_('أدخل Accounting Interim صحيحاً بالثواني.'));
					return false;
				}

				if (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickCoaPort) || +this.state.hotspotQuickCoaPort > 65535) {
					notify(_('أدخل منفذ CoA صحيحاً بين 1 و65535.'));
					return false;
				}

				if (this.state.hotspotQuickTrialEnabled && (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickTrialDuration) || !/^[1-9][0-9]*$/.test(this.state.hotspotQuickTrialUptimeLimit))) {
					notify(_('أدخل مدة Trial وحد وقت Trial بالدقائق كأرقام صحيحة.'));
					return false;
				}

				if (this.state.hotspotQuickMacAuthEnabled && !this.state.hotspotQuickMacAuthPassword) {
					notify(_('أدخل كلمة مرور MAC Authentication أو عطّل الخيار.'));
					return false;
				}

				if (!validQuickDomain(this.state.hotspotQuickDomain)) {
					notify(_('أدخل DNS Domain صحيحاً بدون http:// أو مسارات.'));
					return false;
				}

				if (!isIPv4(this.state.hotspotQuickDns1) || (this.state.hotspotQuickDns2 && !isIPv4(this.state.hotspotQuickDns2))) {
					notify(_('أدخل DNS Server صحيحاً.'));
					return false;
				}

				if (!validRateLimit(this.state.hotspotQuickRateLimit)) {
					notify(_('أدخل Rate Limit بصيغة صحيحة مثل 2M/5M أو اتركه فارغاً.'));
					return false;
				}

				if (!/^[1-9][0-9]*$/.test(this.state.hotspotQuickBrowserCookieDays) || +this.state.hotspotQuickBrowserCookieDays > 365) {
					notify(_('مدة كوكي المتصفح يجب أن تكون من 1 إلى 365 يوماً.'));
					return false;
				}

				if (this.state.hotspotQuickUsermanRestEnabled && !this.state.hotspotQuickUsermanRestUsername) {
					notify(_('أدخل RouterOS API User أو عطّل قراءة رصيد User Manager.'));
					return false;
				}

				if (this.state.hotspotQuickUsermanRestEnabled && !this.state.hotspotQuickUsermanRestPassword) {
					notify(_('أدخل RouterOS API Password أو عطّل قراءة رصيد User Manager.'));
					return false;
				}

				var walledGardenDomains = splitQuickList(this.state.hotspotQuickWalledGarden);
				for (var wgIndex = 0; wgIndex < walledGardenDomains.length; wgIndex++) {
					if (!validQuickDomain(walledGardenDomains[wgIndex])) {
						notify(_('أدخل نطاقات Walled Garden صحيحة بدون http:// أو مسارات.'));
						return false;
					}
				}

				var quickModeProfileError = validateHotspotQuickProfile(this.state, 1);
				if (!quickModeProfileError && this.state.hotspotQuickSecondaryEnabled)
					quickModeProfileError = validateHotspotQuickProfile(this.state, 2);

				if (quickModeProfileError) {
					notify(quickModeProfileError);
					return false;
				}

				if (this.state.hotspotQuickSecondaryEnabled && sameIpv4Subnet24(this.state.hotspotQuickGateway1, this.state.hotspotQuickGateway2)) {
					notify(_('يجب أن تكون الشبكة الأولى والثانية في نطاقين مختلفين.'));
					return false;
				}
			}

			var uplinkRadio = getRadioByBand(this.radios || [], this.state.uplinkBand);
			var meshRadio = getRadioByBand(this.radios || [], this.state.meshBand);
			var hasLocal5g = (getRemainingLocalBands(this.radios || [], this.state).indexOf('5g') != -1);
			var apVlanOnlyMode = (this.state.mode == 'ap' && this.state.isVlan);

			if (!this.state.hotspotQuickEnabled && !apVlanOnlyMode && !this.state.wifiSsid) {
				notify(_('أدخل اسم الشبكة اللاسلكية الأساسي.'));
				return false;
			}

			if (!this.state.hotspotQuickEnabled && !apVlanOnlyMode && hasLocal5g && this.state.wifiSsid5gMode == 'custom' && !this.state.wifiSsid5g) {
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

			if (this.state.isVlan) {
				var vlanIdInMode = +this.state.vlanId;
				var activeBandsInMode = getRemainingLocalBands(this.radios || [], this.state);
				var manualSecondary2gInMode = previewSecondaryManualSsid(this.state, '2g');
				var manualSecondary5gInMode = previewSecondaryManualSsid(this.state, '5g');
				var effectiveSecondary2gInMode = previewSecondarySsid(this.state, '2g');
				var effectiveSecondary5gInMode = previewSecondarySsid(this.state, '5g');
				var primary2gInMode = primarySsid(this.state, '2g');
				var primary5gInMode = primarySsid(this.state, '5g');

				if (!(vlanIdInMode >= 1 && vlanIdInMode <= 4094)) {
					notify(_('اختر قيمة VLAN ID بين 1 و4094.'));
					return false;
				}

				if (activeBandsInMode.length && !manualSecondary2gInMode) {
					notify(_('أدخل اسم شبكة VLAN الأساسي.'));
					return false;
				}

				if (activeBandsInMode.indexOf('2g') != -1 && effectiveSecondary2gInMode && (effectiveSecondary2gInMode == primary2gInMode || effectiveSecondary2gInMode == primary5gInMode)) {
					notify(_('اسم شبكة VLAN على 2.4GHz يتعارض مع اسم شبكة أساسية موجودة. اختر اسمًا مختلفًا.'));
					return false;
				}

				if (activeBandsInMode.indexOf('5g') != -1 && effectiveSecondary5gInMode && (effectiveSecondary5gInMode == primary2gInMode || effectiveSecondary5gInMode == primary5gInMode)) {
					notify(_('اسم شبكة VLAN على 5GHz يتعارض مع اسم شبكة أساسية موجودة. اختر اسمًا مختلفًا.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'vlan' || STEP_KEYS[index] == 'options') {
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

			if (this.state.isVlan) {
				var vlanId = +this.state.vlanId;

				if (!(vlanId >= 1 && vlanId <= 4094)) {
					notify(_('اختر قيمة VLAN ID بين 1 و4094.'));
					return false;
				}
			}
		}

		if (STEP_KEYS[index] == 'advanced' || STEP_KEYS[index] == 'maintenance') {
			if (this.state.hotspotQuickEnabled) {
				var blockedSubscriberIfaces = [ 'lan', 'wan', 'wan6', 'loopback', 'wizardvlan' ];
				var quickSubscriber = normalizeInterfaceName(this.state.hotspotQuickSubscriberInterface, 'hotspot');
				var quickSubscriberSecondary = deriveHotspotQuickSecondaryInterface(quickSubscriber);
				var quickWan = normalizeInterfaceName(this.state.hotspotQuickWanInterface, 'lan');

				if (this.state.mode != 'ap') {
					notify(_('الهوتسبوت السريع يتطلب وضع نقطة الوصول AP فقط.'));
					return false;
				}

				if (blockedSubscriberIfaces.indexOf(quickSubscriber) > -1) {
					notify(_('واجهة مشتركي الهوتسبوت غير صالحة. استخدم واجهة مستقلة مثل hotspot.'));
					return false;
				}

				if (blockedSubscriberIfaces.indexOf(quickSubscriberSecondary) > -1) {
					notify(_('تم اشتقاق واجهة ثانية غير صالحة. غيّر اسم واجهة المشتركين الأساسية.'));
					return false;
				}

				if (quickSubscriber == quickWan) {
					notify(_('لا يمكن أن تكون واجهة المشتركين هي نفس واجهة الإنترنت في الهوتسبوت السريع.'));
					return false;
				}

				if (quickSubscriberSecondary == quickWan) {
					notify(_('الواجهة الثانية للهوتسبوت السريع لا يمكن أن تساوي واجهة الإنترنت. غيّر اسم واجهة المشتركين الأساسية.'));
					return false;
				}

				var quickProfileError = validateHotspotQuickProfile(this.state, 1) || (this.state.hotspotQuickSecondaryEnabled ? validateHotspotQuickProfile(this.state, 2) : '');

				if (quickProfileError) {
					notify(quickProfileError);
					return false;
				}

				if (this.state.hotspotQuickSecondaryEnabled && String(this.state.hotspotQuickSsid1 || '').trim() == String(this.state.hotspotQuickSsid2 || '').trim()) {
					notify(_('يجب أن يكون اسم الشبكة الأولى مختلفًا عن الثانية في الهوتسبوت السريع.'));
					return false;
				}

				if (this.state.hotspotQuickSecondaryEnabled && String(this.state.hotspotQuickGateway1 || '').trim() == String(this.state.hotspotQuickGateway2 || '').trim()) {
					notify(_('يجب أن يكون عنوان الخروج مختلفًا بين الشبكتين في الهوتسبوت السريع.'));
					return false;
				}

				if (this.state.isVlan) {
					notify(_('الهوتسبوت السريع يرفض VLAN تلقائيًا. عطّل VLAN للمتابعة.'));
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

	isStepSkipped: function(index) {
		if (STEP_KEYS[index] == 'hotspot' && !(this.state && this.state.hotspotAvailable))
			return true;

		if (STEP_KEYS[index] == 'vlan' && this.state && this.state.hotspotAvailable && this.state.hotspotEnabled)
			return true;

		return false;
	},

	nextStep: function() {
		if (!this.validateStep(this.stepIndex))
			return;

		var nextIndex = this.stepIndex + 1;

		while (nextIndex < this.stepPanels.length - 1 && this.isStepSkipped(nextIndex))
			nextIndex++;

		if (nextIndex < this.stepPanels.length) {
			this.stepIndex = nextIndex;
			this.updateStepUi();
		}
	},

	prevStep: function() {
		this.collectState();

		if (this.stepIndex > 0) {
			var prevIndex = this.stepIndex - 1;

			while (prevIndex > 0 && this.isStepSkipped(prevIndex))
				prevIndex--;

			this.stepIndex = prevIndex;
			this.updateStepUi();
		}
	},

	applyHotspotSettings: function(state, radios) {
		var hotspotIface = 'wizard_hotspot';
		var hotspotRadio;

		if (!state.hotspotAvailable || !uci.get('hotspot_openwrt', 'main'))
			return;

		if (state.hotspotQuickEnabled)
			return;

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

			uci.set('wireless', sid, 'disassoc_low_ack', '0');

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
			else {
				uci.set('wireless', sid, 'disabled', '1');
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

		this.collectState();

		if (!isIPv4(this.state.hotspotQuickRadiusServer)) {
			notify(_('أدخل عنوان IPv4 صالحاً لخادم RADIUS أولاً.'));
			return Promise.resolve();
		}

		if (!this.state.hotspotQuickRadiusSecret) {
			notify(_('كلمة سر RADIUS مطلوبة قبل الاختبار.'));
			return Promise.resolve();
		}

		if (this.refs.hotspotQuickRadiusTestButton)
			this.refs.hotspotQuickRadiusTestButton.disabled = true;

		if (this.refs.hotspotQuickRadiusTestStatus)
			this.refs.hotspotQuickRadiusTestStatus.textContent = _('جارٍ الاختبار...');

		return L.resolveDefault(fs.exec_direct(HOTSPOT_TEST_RADIUS_CMD, [
			this.state.hotspotQuickRadiusServer,
			this.state.hotspotQuickRadiusAuthPort || '1812',
			this.state.hotspotQuickRadiusAcctPort || '1813',
			this.state.hotspotQuickCoaEnabled ? (this.state.hotspotQuickCoaPort || '3799') : '0'
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
		var oldLanIpaddr = uci.get('network', 'lan', 'ipaddr') || this.state.lanIpaddr;
		var oldSsid = this.state.wifiSsid;
		var migratedAnonymousWifi = false;

		if (!this.validateStep(this.stepIndex))
			return;

		if (this.stepIndex !== 0 && !this.validateStep(0)) {
			this.stepIndex = 0;
			this.updateStepUi();
			return;
		}

		this.collectState();
		enforceHotspotNoVlan(this.state);

		if (this.state.hotspotQuickEnabled)
			this.state.mode = 'ap';

		this.refs.saveButton.disabled = true;
		this.refs.saveButton.textContent = (this.state.hotspotQuickEnabled || this.state.hotspotEnabled) ? _('جارٍ فحص الترخيص...') : _('جارٍ التطبيق...');

		confirmHotspotLicenseBeforeSetupApply(this.state).then(function(allowed) {
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

			if (!self.state.hotspotQuickEnabled && !self.state.hotspotEnabled)
				cleanupHotspotWizardState();

			return uci.save();
		}).then(function() {
			return ui.changes.apply();
		}).then(function() {
			if (!self.state.hotspotQuickEnabled && !self.state.hotspotEnabled)
				return L.resolveDefault(fs.exec(HOTSPOT_CLEANUP_CMD, [ '--force', '--reload' ]), null).then(function() {
					return L.resolveDefault(fs.exec(HOTSPOT_INIT_CMD, [ 'stop' ]), null);
				});
		}).then(function() {
			if (self.state.hotspotAvailable && self.state.hotspotEnabled) {
				return L.resolveDefault(fs.exec('/usr/libexec/hotspot-openwrt/apply', []), null).then(function(res) {
					if (res && res.code !== 0)
						notify(_('تحذير: تعذر تطبيق إعدادات الهوتسبوت تلقائياً. يمكن تطبيقها يدوياً من صفحة الخدمات.'));
				});
			}
		}).then(function() {
			var changedIp = self.state.lanIpaddr != oldLanIpaddr;
			var hotspotApplyPromise = self.state.hotspotQuickEnabled
				? L.resolveDefault(fs.exec_direct(HOTSPOT_APPLY_CMD, [], 'json'), null)
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
		var stepTitles = [ _('صفحة الخيارات'), _('صفحة الصيانة') ];
		var stepPanels = [];
		var stepBadges = [];
		var stepChips = [];
		var radioSettingsCard;
		var i;

		this.radios = radios;
		this.frequencyMap = frequencyMap;
		this.state = this.readState(radios, Array.isArray(data) ? data[1] : null);
		this.stepIndex = 0;
		this.refs = {};
		this.stepPanels = stepPanels;
		this.stepBadges = stepBadges;
		this.stepChips = stepChips;
		this.statusContainer = statusContainer;

		ensureSetupStyles();

		panel.appendChild(statusContainer);
		this.refs.heroCurrentLan = E('span');
		this.refs.heroCurrentMode = E('span');
		this.refs.heroCurrentSecondary = E('span');
		this.refs.heroSetupSummary = E('span');
		this.refs.lanCardSummary = E('span');
		this.refs.modeCardSummary = E('span');
		this.refs.primaryWifiCardSummary = E('span');
		this.refs.wifiSecurityCardSummary = E('span');
		this.refs.uplinkCardSummary = E('span');
		this.refs.meshCardSummary = E('span');
		this.refs.vlanCardSummary = E('span');
		this.refs.radioCardSummary = E('span');
		this.refs.backupCardSummary = E('span');
		this.refs.firstbootCardSummary = E('span');
		this.refs.otaCardSummary = E('span');
		this.refs.buttonPoliciesCardSummary = E('span');
		this.refs.rebootCardSummary = E('span');
		this.refs.passwordCardSummary = E('span');
		this.refs.hotspotCardSummary = E('span');

		wizardIntro = E('div', { 'class': 'alemprator-card alemprator-card--hero' }, [
			E('div', { 'class': 'alemprator-hero__grid' }, [
				E('div', [
					E('span', { 'class': 'alemprator-card__eyebrow alemprator-card__eyebrow--light' }, _('ALemprator Setup')),
					E('h3', { 'class': 'alemprator-card__title alemprator-card__title--light' }, _('الإعداد السريع')),
					E('p', { 'class': 'alemprator-card__desc alemprator-card__desc--light' }, _('اضبط LAN ووضع التشغيل والواي فاي وVLAN ثم احفظ.')),
					E('div', { 'class': 'alemprator-hero__actions' }, [
				E('a', {
					'href': VIDEO_EXPLAIN_URL,
					'target': '_blank',
					'rel': 'noopener noreferrer',
					'class': 'alemprator-hero__link'
				}, _('مشاهدة الشرح')),
				E('span', { 'class': 'alemprator-hero__hint' }, _('بعد الحفظ ستعود تلقائيًا للواجهة الرئيسية.'))
					]),
					E('div', { 'class': 'alemprator-hero__summary' }, [ this.refs.heroSetupSummary ])
				]),
				E('div', { 'class': 'alemprator-hero__facts' }, [
					renderSummaryFact(_('LAN الحالية'), this.refs.heroCurrentLan),
					renderSummaryFact(_('وضع التشغيل'), this.refs.heroCurrentMode),
					renderSummaryFact(_('الشبكة الثانوية'), this.refs.heroCurrentSecondary)
				])
			])
		]);

		wizardContainer.appendChild(wizardIntro);

		for (i = 0; i < stepTitles.length; i++) {
			var badge = E('div', {
				'class': 'alemprator-step-chip'
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
		this.refs.wifiSsidVlan2g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.wifiSsidVlan2g, 'style': 'max-width:280px;' });
		this.refs.wifiSsidVlan5g = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.wifiSsidVlan5g, 'style': 'max-width:280px;' });
		this.refs.wifiSsidIpSuffixPrimary = E('input', { 'type': 'checkbox' });
		this.refs.wifiSsidIpSuffixPrimary.checked = !!this.state.wifiSsidVlanIpSuffix;
		this.refs.wifiSsidVlanIpSuffix = E('input', { 'type': 'checkbox' });
		this.refs.wifiSsidVlanIpSuffix.checked = !!this.state.wifiSsidVlanIpSuffix;
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
			'class': 'alemprator-notice alemprator-notice--info',
			'style': 'display:none;'
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
		this.refs.hotspotQuickEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickEnabled.checked = !!this.state.hotspotQuickEnabled;
		this.refs.hotspotQuickWanInterface = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickWanInterface || 'lan', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickSubscriberInterface = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickSubscriberInterface || 'hotspot', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickSsid1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickSsid1 || 'Hotspot-1', 'style': 'max-width:280px;' });
		this.refs.hotspotQuickGateway1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickGateway1 || '192.168.10.1', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPoolStart1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickPoolStart1 || '192.168.10.10', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPoolEnd1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickPoolEnd1 || '192.168.10.199', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPolicy1 = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, hotspotPolicyChoices());
		this.refs.hotspotQuickPolicy1.value = this.state.hotspotQuickPolicy1 || 'standard';
		this.refs.hotspotQuickSecondaryEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickSecondaryEnabled.checked = this.state.hotspotQuickSecondaryEnabled !== false;
		this.refs.hotspotQuickSsid2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickSsid2 || 'Hotspot-2', 'style': 'max-width:280px;' });
		this.refs.hotspotQuickGateway2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickGateway2 || '192.168.20.1', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPoolStart2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickPoolStart2 || '192.168.20.10', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPoolEnd2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickPoolEnd2 || '192.168.20.199', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickPolicy2 = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' }, hotspotPolicyChoices());
		this.refs.hotspotQuickPolicy2.value = this.state.hotspotQuickPolicy2 || 'premium';
		this.refs.hotspotQuickRadiusServer = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickRadiusServer || '192.168.1.2', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickRadiusServer2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickRadiusServer2 || '', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickRadiusSecret = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.hotspotQuickRadiusSecret || '', 'style': 'max-width:220px;', 'autocomplete': 'new-password' });
		this.refs.hotspotQuickRadiusSecretToggle = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button', 'style': 'margin-inline-start:8px;' }, _('إظهار'));
		this.refs.hotspotQuickRadiusAuthPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': this.state.hotspotQuickRadiusAuthPort || '1812', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickRadiusAcctPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': this.state.hotspotQuickRadiusAcctPort || '1813', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickRadiusNasIp = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickRadiusNasIp || '', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickNasId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickNasId || '', 'style': 'max-width:280px;' });
		this.refs.hotspotQuickAcctInterim = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': this.state.hotspotQuickAcctInterim || '60', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickCoaEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickCoaEnabled.checked = !!this.state.hotspotQuickCoaEnabled;
		this.refs.hotspotQuickCoaPort = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '65535', 'value': this.state.hotspotQuickCoaPort || '3799', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickTrialEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickTrialEnabled.checked = !!this.state.hotspotQuickTrialEnabled;
		this.refs.hotspotQuickTrialDuration = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': this.state.hotspotQuickTrialDuration || '30', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickTrialUptimeLimit = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': this.state.hotspotQuickTrialUptimeLimit || '30', 'style': 'max-width:140px;' });
		this.refs.hotspotQuickMacAuthEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickMacAuthEnabled.checked = !!this.state.hotspotQuickMacAuthEnabled;
		this.refs.hotspotQuickMacAuthSuffix = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickMacAuthSuffix || '@mac', 'style': 'max-width:160px;' });
		this.refs.hotspotQuickMacAuthPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.hotspotQuickMacAuthPassword || 'mac', 'style': 'max-width:180px;', 'autocomplete': 'new-password' });
		this.refs.hotspotQuickWalledGarden = E('textarea', { 'class': 'cbi-input-textarea', 'rows': '4', 'style': 'width:100%; max-width:420px;' }, this.state.hotspotQuickWalledGarden || '');
		this.refs.hotspotQuickDomain = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickDomain || 'hotspot.local', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickDns1 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickDns1 || '8.8.8.8', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickDns2 = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickDns2 || '82.114.163.31', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickBridgeAgeingTime = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'value': this.state.hotspotQuickBridgeAgeingTime || '10', 'style': 'max-width:120px;' });
		this.refs.hotspotQuickLoginMode = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:260px;' }, hotspotLoginModeChoices());
		this.refs.hotspotQuickLoginMode.value = normalizeHotspotLoginMode(this.state.hotspotQuickLoginMode);
		this.refs.hotspotQuickRateLimit = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickRateLimit || '2M/5M', 'style': 'max-width:180px;' });
		this.refs.hotspotQuickMacCookieEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickMacCookieEnabled.checked = !!this.state.hotspotQuickMacCookieEnabled;
		this.refs.hotspotQuickAvailableSpeeds = E('textarea', { 'class': 'cbi-input-textarea', 'rows': '3', 'style': 'width:100%; max-width:420px;' }, this.state.hotspotQuickAvailableSpeeds || '1M/2M Standard\n2M/4M Fast');
		this.refs.hotspotQuickSupportPhone = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickSupportPhone || '', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickNoticeText = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickNoticeText || 'أهلاً بكم في شبكتنا', 'style': 'max-width:420px;' });
		this.refs.hotspotQuickLiveStreamEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickLiveStreamEnabled.checked = !!this.state.hotspotQuickLiveStreamEnabled;
		this.refs.hotspotQuickLiveStreamUrl = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickLiveStreamUrl || '', 'style': 'max-width:420px;' });
		this.refs.hotspotQuickRestAreaEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickRestAreaEnabled.checked = !!this.state.hotspotQuickRestAreaEnabled;
		this.refs.hotspotQuickRestAreaUrl = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickRestAreaUrl || '', 'style': 'max-width:420px;' });
		this.refs.hotspotQuickSpeedtestEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickSpeedtestEnabled.checked = !!this.state.hotspotQuickSpeedtestEnabled;
		this.refs.hotspotQuickBrowserCookieEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickBrowserCookieEnabled.checked = this.state.hotspotQuickBrowserCookieEnabled !== false;
		this.refs.hotspotQuickBrowserCookieDays = E('input', { 'class': 'cbi-input-text', 'type': 'number', 'min': '1', 'max': '365', 'value': normalizeBrowserCookieDays(this.state.hotspotQuickBrowserCookieDays || '7'), 'style': 'max-width:140px;' });
		this.refs.hotspotQuickUsermanRestEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotQuickUsermanRestEnabled.checked = !!this.state.hotspotQuickUsermanRestEnabled;
		this.refs.hotspotQuickUsermanRestScheme = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:140px;' }, routerOsSchemeChoices());
		this.refs.hotspotQuickUsermanRestScheme.value = normalizeRouterOsScheme(this.state.hotspotQuickUsermanRestScheme);
		this.refs.hotspotQuickUsermanRestUsername = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotQuickUsermanRestUsername || 'hotspot-read', 'style': 'max-width:220px;' });
		this.refs.hotspotQuickUsermanRestPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.hotspotQuickUsermanRestPassword || '', 'style': 'max-width:220px;', 'autocomplete': 'new-password' });
		this.refs.hotspotQuickUsermanRestPasswordToggle = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button', 'style': 'margin-inline-start:8px;' }, _('إظهار'));
		this.refs.hotspotQuickRadiusTestButton = E('button', { 'class': 'cbi-button cbi-button-action', 'type': 'button' }, _('اختبار RADIUS'));
		this.refs.hotspotQuickRadiusTestStatus = E('span', { 'style': 'margin-inline-start:8px; color:#52606d;' }, _('لم يتم الاختبار بعد.'));
		this.refs.adminPassword = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });
		this.refs.adminPasswordConfirm = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'autocomplete': 'new-password', 'style': 'max-width:280px;' });
		this.refs.hotspotEnabled = E('input', { 'type': 'checkbox' });
		this.refs.hotspotEnabled.checked = this.state.hotspotEnabled;
		this.refs.hotspotSsid = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotSsid || 'Hotspot', 'style': 'max-width:280px;' });
		this.refs.hotspotRadiusServer = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotRadiusServer || '192.168.1.2', 'style': 'max-width:280px;' });
		this.refs.hotspotRadiusSecret = E('input', { 'class': 'cbi-input-password', 'type': 'password', 'value': this.state.hotspotRadiusSecret || '', 'style': 'max-width:280px;', 'autocomplete': 'new-password' });
		this.refs.hotspotNasId = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotNasId || '', 'style': 'max-width:280px;' });
		this.refs.hotspotIp = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotIp || '192.168.10.1', 'style': 'max-width:280px;' });
		this.refs.hotspotPoolStart = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotPoolStart || '192.168.10.10', 'style': 'max-width:280px;' });
		this.refs.hotspotPoolEnd = E('input', { 'class': 'cbi-input-text', 'type': 'text', 'value': this.state.hotspotPoolEnd || '192.168.10.254', 'style': 'max-width:280px;' });
		this.refs.hotspotIpConflictWarning = E('div', {
			'class': 'alemprator-notice alemprator-notice--warning',
			'style': 'display:none; margin-top:8px;'
		}, _('تحذير: نطاق الهوتسبوت يتعارض مع نطاق LAN. يرجى تغيير عنوان IP للهوتسبوت.'));
		this.refs.otaWindowStart = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' });
		this.refs.otaWindowEnd = E('select', { 'class': 'cbi-input-select', 'style': 'max-width:220px;' });
		populateSelectOptions(this.refs.otaWindowStart, otaHourChoices(), String(this.state.otaWindowStart == null ? 2 : this.state.otaWindowStart));
		populateSelectOptions(this.refs.otaWindowEnd, otaHourChoices(), String(this.state.otaWindowEnd == null ? 6 : this.state.otaWindowEnd));
		this.refs.otaWindowStart.disabled = !this.state.otaWindowAvailable;
		this.refs.otaWindowEnd.disabled = !this.state.otaWindowAvailable;
		this.refs.otaWindowStatus = E('strong', this.state.otaWindowAvailable ? describeOtaWindow(this.state.otaWindowStart, this.state.otaWindowEnd) : _('غير متوفرة على هذا الجهاز.'));
		this.refs.backupButton = E('button', {
			'class': 'cbi-button cbi-button-action',
			'type': 'button'
		}, _('تنزيل نسخة احتياطية الآن'));
		this.refs.safeRestoreButton = E('button', {
			'class': 'cbi-button cbi-button-negative',
			'type': 'button'
		}, _('استرجاع آمن من ملف نسخة احتياطية'));
		this.refs.backupStatus = E('span', _('جاهز لتنزيل نسخة احتياطية.'));
		this.refs.firstbootSummary = E('strong', describeFirstbootSummary(this.state));
		this.refs.firstbootEnabledStatus = E('strong', enabledText(this.state.firstbootEnabled));
		this.refs.firstbootConfiguredOnceStatus = E('strong', boolText(this.state.firstbootConfiguredOnce));
		this.refs.firstbootInitialSetupStatus = E('strong', boolText(this.state.firstbootInitialSetupComplete));
		this.refs.firstbootCleanupStatus = E('strong', describeFirstbootCleanupState(this.state.firstbootAutoCleanupArmed, this.state.firstbootAutoCleanupPending));
		this.refs.firstbootSections = E('span', describeFirstbootSections(this.state));

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

		radioSettingsCard = renderWizardCard(
			_('القنوات وإعدادات الراديو'),
			_('اختر القناة والنمط وعرض القناة. في الميش استخدم قناة ثابتة.'),
			[
				renderCardLiveSummary(this.refs.radioCardSummary),
				(this.refs.meshChannelHelp = E('p', { 'style': 'display:none; margin:0 0 12px 0; color:#52606d;' })),
				radio2g ? (this.refs.channel2gRow = E('div', { 'class': 'cbi-value alemprator-channel-row' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio2g)), E('div', { 'class': 'cbi-value-field' }, [ this.refs.channel2g ]) ])) : E('p', _('لم يتم اكتشاف راديو 2.4GHz.')),
				radio2g ? (this.refs.mode2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiMode2g ]) ])) : null,
				radio2g ? (this.refs.width2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (2.4GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiWidth2g ]) ])) : null,
				radio5g ? (this.refs.channel5gRow = E('div', { 'class': 'cbi-value alemprator-channel-row' }, [ E('label', { 'class': 'cbi-value-title' }, radioLabel(radio5g)), E('div', { 'class': 'cbi-value-field' }, [ this.refs.channel5g ]) ])) : E('p', _('لم يتم اكتشاف راديو 5GHz.')),
				radio5g ? (this.refs.mode5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('النمط (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiMode5g ]) ])) : null,
				radio5g ? (this.refs.width5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عرض القناة (5GHz)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiWidth5g ]) ])) : null
			]
		);

		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel' }, [
			renderWizardCard(
				_('تحديد عنوان الشبكة المحلية'),
				_('حدد عنوان الدخول المحلي للجهاز.'),
				[
					renderCardLiveSummary(this.refs.lanCardSummary),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('عنوان LAN IPv4')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.lanIpaddr ]) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('قناع شبكة LAN')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.lanNetmask ]) ])
				]
			)
		]));

		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' }, [
			renderNoticeBox('accent', _('الترتيب'), [
				E('span', _('اختر الوضع ثم اضبط الواي فاي والربط الصاعد أو الميش وVLAN عند الحاجة.'))
			]),
			renderWizardCard(
				_('اختيار وضع التشغيل'),
				_('حدد دور الجهاز أولًا.'),
				[
					renderCardLiveSummary(this.refs.modeCardSummary),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('وضع التشغيل')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.mode ]) ]),
					renderNoticeBox('neutral', _('النتيجة'), [ this.refs.modePlan = E('span') ])
				]
			),
			radioSettingsCard,
			(this.refs.hotspotQuickCard = renderWizardCard(
				_('Hotspot Quick (بدون VLAN)'),
				_('برمجة الهوتسبوت من نفس خطوة وضع التشغيل. عند التفعيل يثبت الوضع على AP ويعطل VLAN.'),
				[
					renderCardLiveSummary(this.refs.hotspotQuickCardSummary),
						renderNoticeBox(hotspotLicenseCacheInfo().active ? 'info' : 'warning', _('ترخيص الهوتسبوت'), [ E('span', hotspotLicenseCacheMessage()) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل الهوتسبوت السريع')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickEnabled ]) ]),
					(this.refs.hotspotQuickDetailsWrapper = E('div', { 'class': 'alemprator-responsive-fields', 'style': 'display:none;' }, [
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('واجهة الإنترنت')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickWanInterface, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اتركها lan في البرمجة المعتادة، ولا تغيّرها إلا إذا كان مصدر الإنترنت على واجهة أخرى.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('واجهة المشتركين')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSubscriberInterface, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('الواجهة الأساسية للهوتسبوت. سيتم اشتقاق واجهة الشبكة الثانية تلقائياً.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RADIUS Server')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusServer ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RADIUS Server 2')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusServer2 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RADIUS Secret')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusSecret, this.refs.hotspotQuickRadiusSecretToggle ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RADIUS Auth Port')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusAuthPort ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RADIUS Accounting Port')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusAcctPort ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('NAS IP')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusNasIp, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اختياري. اتركه فارغاً لاستخدام عنوان LAN تلقائياً.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('NAS ID')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickNasId ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Accounting Interim')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickAcctInterim, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('بالثواني، يرسل تحديثات الاستهلاك إلى MikroTik/User Manager.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('CoA / Disconnect')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickCoaEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('CoA Port')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickCoaPort ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('اختبار RADIUS')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRadiusTestButton, this.refs.hotspotQuickRadiusTestStatus ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSsid1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('IP الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickGateway1, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('سيتم توليد Pool تلقائيًا من نفس الشبكة: .10 إلى .199.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool بداية الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPoolStart1 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool نهاية الشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPoolEnd1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Domain')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickDomain ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Server 1')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickDns1 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('DNS Server 2')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickDns2 ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Ageing time')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickBridgeAgeingTime, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يكتب ageing_time لجسري Hotspot-1 و Hotspot-2. الافتراضي 10.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('صفحة الكرت')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickLoginMode ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Rate Limit (rx/tx)')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRateLimit, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اختياري مثل 2M/5M. يطبق كحد افتراضي upload/download إذا لم يرجعه RADIUS.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Add MAC Cookie')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickMacCookieEnabled, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يحفظ MAC وIP واسم الكرت بعد نجاح الدخول، ثم يسمح بالدخول التلقائي لنفس الجهاز لاحقًا مثل MikroTik Cookies.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('قائمة السرعات المتاحة للمشتركين')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickAvailableSpeeds, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('أدخل خيارات السرعة، سطر لكل خيار. الصيغة: السرعة الاسم.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رقم الدعم الفني')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSupportPhone, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يظهر كزر تواصل في أسفل الصفحة.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تنبيه للمشتركين')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickNoticeText, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('نص يظهر بشكل بارز للتنبيهات.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إظهار بث مباشر')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickLiveStreamEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رابط البث المباشر')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickLiveStreamUrl ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إظهار الاستراحة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRestAreaEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('رابط الاستراحة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickRestAreaUrl ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل فحص السرعة في صفحة الحالة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSpeedtestEnabled, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يظهر زر للمشترك لقياس سرعة اتصاله الحقيقية بالراوتر.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Browser Cookie')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickBrowserCookieEnabled, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يتذكر المتصفح رقم الكرت محليًا عند فتح صفحة الدخول.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مدة كوكي المتصفح بالأيام')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickBrowserCookieDays, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('من 1 إلى 365 يومًا.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('قراءة رصيد User Manager')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickUsermanRestEnabled, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يفعل جسر RouterOS REST لعرض الرصيد والبروفايل ووقت الانتهاء في صفحة المشترك.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RouterOS REST Scheme')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickUsermanRestScheme, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('استخدم https مع www-ssl. يمكن استخدام http للاختبار فقط.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RouterOS API User')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickUsermanRestUsername, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('مستخدم قراءة فقط على MikroTik بصلاحيات User Manager.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('RouterOS API Password')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickUsermanRestPassword, this.refs.hotspotQuickUsermanRestPasswordToggle, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('تحفظ على الراوتر فقط ولا ترسل للمتصفح.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Policy/Profile للشبكة الأولى')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPolicy1 ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSecondaryEnabled ]) ]),
						(this.refs.hotspotQuickSecondaryWrapper = E('div', { 'class': 'alemprator-responsive-fields', 'style': 'display:none;' }, [
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickSsid2 ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('IP الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickGateway2, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('سيتم توليد Pool تلقائيًا من نفس الشبكة: .10 إلى .199.')) ]) ]),
							E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool بداية الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPoolStart2 ]) ]),
							E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('Pool نهاية الشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPoolEnd2 ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Policy/Profile للشبكة الثانية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickPolicy2 ]) ])
						])),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Users')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickTrialEnabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Duration')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickTrialDuration, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('بالدقائق.')) ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Trial Uptime Limit')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickTrialUptimeLimit, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('بالدقائق لكل جهاز.')) ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Authentication')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickMacAuthEnabled ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Auth Suffix')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickMacAuthSuffix ]) ]),
						E('div', { 'class': 'cbi-value', 'style': 'display:none;' }, [ E('label', { 'class': 'cbi-value-title' }, _('MAC Auth Password')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickMacAuthPassword ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Walled Garden Domains')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.hotspotQuickWalledGarden ]) ]),
						(this.refs.hotspotVlanLockNotice = renderNoticeBox('warning', _('تنبيه'), [ E('span', _('عند تفعيل الهوتسبوت السريع يتم تعطيل VLAN تلقائيًا ومنع حفظه.')) ]))
					]))
				]
			)),
			(this.refs.apVlanWarning = E('div', {
				'class': 'alemprator-notice alemprator-notice--warning',
				'style': 'display:none; margin:12px 0 0 0;'
			}, _('عند تفعيل VLAN هنا ستعتمد على شبكات VLAN فقط.'))),
			E('div', { 'class': 'alemprator-card-grid' }, [
				(this.refs.primaryWifiSection = E('div', [
					renderWizardCard(
						_('الشبكة اللاسلكية الأساسية'),
						_('سمِّ الشبكات المحلية المتاحة.'),
						[
							renderCardLiveSummary(this.refs.primaryWifiCardSummary),
							(this.refs.wifiNameHelp = E('p', describePrimaryWifiNamingHelp(this.state, this.radios || []))),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم SSID الأساسي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid ]) ]),
							(this.refs.ssid5gModeRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('طريقة تعيين اسم 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid5gMode ]) ])),
							(this.refs.ssid5gCustomRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم المخصص لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsid5g ]) ])),
							(this.refs.ssidPreviewRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم النهائي لشبكة 5GHz')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.ssidPreview ]) ])),
							(this.refs.primarySsidIpSuffixRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إضافة آخر IP إلى اسم الشبكة الأساسية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsidIpSuffixPrimary, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('مثال: 192.168.1.20 يضيف _1.20 إلى أسماء الشبكات الأساسية وVLAN.')) ]) ])),
							renderNoticeBox('neutral', _('ملخص الواي فاي'), [ this.refs.primaryWifiPlan ])
						]
					)
				])),
				(this.refs.wifiSecurityCard = renderWizardCard(
					_('حماية الواي فاي المحلية'),
					_('كلمة المرور للشبكات المحلية. اتركها فارغة للشبكة المفتوحة.'),
					[
						renderCardLiveSummary(this.refs.wifiSecurityCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الواي فاي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اتركه فارغًا للشبكة المفتوحة.')) ]) ])
					]
				)),
				(this.refs.uplinkSettingsWrapper = E('div', { 'style': 'display:none;' }, [
					renderWizardCard(
						_('إعدادات الربط الصاعد للعميل + WDS'),
						_('يظهر فقط في وضع العميل + WDS.'),
						[
							renderCardLiveSummary(this.refs.uplinkCardSummary),
							(this.refs.uplinkHelp = E('p', describeUplinkSettingsHelp(this.state, this.radios || []))),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkBand ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('اسم شبكة الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkSsid ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الربط الصاعد')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.uplinkKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اتركه فارغًا للشبكة المفتوحة.')) ]) ])
						]
					)
				])),
				(this.refs.meshSettingsWrapper = E('div', { 'style': 'display:none;' }, [
					renderWizardCard(
						_('إعدادات الميش'),
						_('يظهر فقط في وضع الميش.'),
						[
							renderCardLiveSummary(this.refs.meshCardSummary),
							(this.refs.meshHelp = E('p', describeMeshSettingsHelp(this.state, this.radios || []))),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('نطاق الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshBand ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('معرف الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshId ]) ]),
							E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة مرور الميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.meshKey, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('اتركه فارغًا لميش مفتوح.')) ]) ])
						]
					)
				])),
				(this.refs.vlanSettingsCard = renderWizardCard(
					_('إعداد شبكة VLAN الثانوية'),
					_('أضف شبكة واي فاي ثانوية معزولة من دون تغيير الشبكة الرئيسية.'),
					[
						renderCardLiveSummary(this.refs.vlanCardSummary),
						(this.refs.secondaryNetworkIntro = E('p', { 'style': 'margin:0 0 12px 0; color:#415a77;' }, describeSecondaryNetworkIntro(this.state, this.radios || []))),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل شبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.isVlan ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('VLAN ID')), (this.refs.vlanIdWrapper = E('div', { 'class': 'cbi-value-field' }, [ this.refs.vlanId ])) ]),
						(this.refs.vlanSsid2gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم الأساسي لشبكة VLAN')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsidVlan2g, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('هذا الحقل مطلوب. وإذا تُرك حقل شبكة خمسة جيجاهرتز فارغًا، فسيُشتق اسمه من هذا الحقل.')) ]) ])),
						(this.refs.vlanSsid5gRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('الاسم الاختياري لشبكة VLAN على خمسة جيجاهرتز')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsidVlan5g, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('هذا الحقل اختياري. وإذا تُرك فارغًا، فسيُنشأ الاسم تلقائيًا من الاسم الأساسي.')) ]) ])),
						(this.refs.vlanSsidIpSuffixRow = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إضافة آخر IP إلى أسماء الواي فاي')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wifiSsidVlanIpSuffix, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('مثال: 192.168.1.20 يضيف _1.20 إلى أسماء الشبكات الأساسية وVLAN.')) ]) ])),
						(this.refs.vlanPreviewWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('معرّف VLAN الثانوية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.vlanPreview, (this.refs.secondarySubnetHelp = E('div', { 'style': 'margin-top:6px; color:#666;' }, describeSecondarySubnetHelp(this.state, this.radios || []))) ]) ])),
						renderNoticeBox('neutral', _('ملخص VLAN الثانوية'), [ this.refs.secondaryNetworkPlan ]),
						this.refs.secondaryNetworkNotice
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
				renderNoticeBox('accent', _('الهوتسبوت'), [
					E('span', _('اضبط بيانات RADIUS لتشغيل بوابة الدخول. ترك الخانة معطلة لا يؤثر على الإعداد الحالي.'))
				]),
				renderWizardCard(
					_('إعداد الهوتسبوت السريع'),
					_('يتطلب CoovaChilli ومخدم RADIUS (MikroTik User Manager). الإعدادات المتقدمة متاحة من صفحة الخدمات.'),
					[
						renderCardLiveSummary(self.refs.hotspotCardSummary),
						renderNoticeBox(hotspotLicenseCacheInfo().active ? 'info' : 'warning', _('ترخيص الهوتسبوت'), [ E('span', hotspotLicenseCacheMessage()) ]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('تشغيل الهوتسبوت')),
							E('div', { 'class': 'cbi-value-field' }, [ self.refs.hotspotEnabled ])
						]),
						(self.refs.hotspotFieldsWrapper = E('div', {
							'class': 'alemprator-hotspot-fields',
							'style': 'display:none;'
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
							])),
							E('p', { 'style': 'margin-top:14px; color:#52606d; font-size:13px;' }, [
								_('للإعدادات المتقدمة (Walled Garden، المهلات، Portal): '),
								E('a', {
									'href': L.url('admin', 'services', 'hotspot-openwrt'),
									'target': '_blank',
									'rel': 'noopener noreferrer',
									'style': 'color:#1a5faa; text-decoration:underline;'
								}, _('افتح صفحة الهوتسبوت'))
							])
						])),
						renderNoticeBox('neutral', _('ملخص الهوتسبوت'), [ self.refs.hotspotCardSummary ])
					]
				)
			];
		}(this.state.hotspotAvailable))));

		this.refs.resetHoldWrapper = E('div', { 'class': 'cbi-value-field' }, [ this.refs.resetHoldSeconds ]);
		stepPanels.push(E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' }, [
			renderNoticeBox('accent', _('الصيانة'), [
				E('span', _('النسخ الاحتياطي والحماية قبل الحفظ.'))
			]),
			E('div', { 'class': 'alemprator-card-grid' }, [
				renderWizardCard(
					_('النسخ الاحتياطي'),
					_('نزّل نسخة احتياطية أو استرجعها بأمان.'),
					[
						renderCardLiveSummary(this.refs.backupCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('تنزيل النسخة الاحتياطية')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.backupButton ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الاسترجاع الآمن')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.safeRestoreButton ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الحالة')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.backupStatus ])
						])
					]
				),
				renderWizardCard(
					_('حالة firstboot'),
					_('حالة تهيئة التشغيل الأول.'),
					[
						renderCardLiveSummary(this.refs.firstbootCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('الملخص الحالي')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootSummary ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('حالة firstboot')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootEnabledStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('configured_once')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootConfiguredOnceStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('initial_setup_complete')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootInitialSetupStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('حالة التنظيف المؤجل')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootCleanupStatus ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('أسماء المقاطع المرتبطة')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.firstbootSections ])
						])
					]
				),
				renderWizardCard(
					_('وقت التحديث التلقائي'),
					_('اختر نافذة التحديث التلقائي.'),
					[
						renderCardLiveSummary(this.refs.otaCardSummary),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('بداية نافذة التحديث التلقائي')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.otaWindowStart ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('نهاية نافذة التحديث التلقائي')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.otaWindowEnd ])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, _('نافذة التحديث الحالية')),
							E('div', { 'class': 'cbi-value-field' }, [ this.refs.otaWindowStatus ])
						])
					]
				),
				renderWizardCard(
					_('سياسات الأزرار'),
					_('تحكم سريع في أزرار الجهاز.'),
					[
						renderCardLiveSummary(this.refs.buttonPoliciesCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر إعادة الضبط')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.resetDisabled ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('مدة الضغط لإعادة ضبط المصنع')), this.refs.resetHoldWrapper ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تعطيل زر WPS/ميش')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.wpsDisabled ]) ])
					]
				),
				renderWizardCard(
					_('إعادة تشغيل الجهاز'),
					_('إعادة تشغيل دورية خاصة بهذا المعالج فقط.'),
					[
						renderCardLiveSummary(this.refs.rebootCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تفعيل إعادة التشغيل التلقائية')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.rebootEnabled ]) ]),
						(this.refs.rebootHoursWrapper = E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('إعادة التشغيل كل كم ساعة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.rebootHours, E('div', { 'style': 'margin-top:6px; color:#666;' }, _('يؤثر على هذه القاعدة فقط.')) ]) ]))
					]
				),
				renderWizardCard(
					_('كلمة مرور الجهاز'),
					_('اترك الحقلين فارغين إذا لا تريد تغييرها.'),
					[
						renderCardLiveSummary(this.refs.passwordCardSummary),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('كلمة المرور الجديدة')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.adminPassword ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('تأكيد كلمة المرور')), E('div', { 'class': 'cbi-value-field' }, [ this.refs.adminPasswordConfirm ]) ])
					]
				)
			])
		]));

		(function() {
			var legacyPanels = stepPanels.slice();
			var optionsPage = E('div', { 'class': 'cbi-section-node alemprator-step-panel' });
			var maintenancePage = E('div', { 'class': 'cbi-section-node alemprator-step-panel', 'style': 'display:none;' });
			var optionBlocks = E('div', { 'class': 'alemprator-card-grid alemprator-card-grid--fluid' });
			var maintenanceBlocks = E('div', { 'class': 'alemprator-card-grid alemprator-card-grid--fluid' });
			var moveChildren = function(panel, target) {
				if (!panel)
					return;

				panel.style.display = '';
				while (panel.firstChild)
					target.appendChild(panel.firstChild);
			};
			var moveModeChildren = function(panel, target) {
				var deferred = [];

				if (!panel)
					return;

				panel.style.display = '';
				while (panel.firstChild) {
					var child = panel.firstChild;

					if (child.className && String(child.className).indexOf('alemprator-notice') > -1) {
						panel.removeChild(child);
						deferred.push(child);
					}
					else
						target.appendChild(child);
				}

				deferred.forEach(function(node) {
					target.appendChild(node);
				});
			};

			legacyPanels.forEach(function(panel) {
				if (panel)
					panel.style.display = '';
			});

			optionsPage.appendChild(renderNoticeBox('accent', _('صفحة الخيارات'), [
				E('span', _('كل خيارات البرمجة السريعة في مكان واحد: LAN، وضع التشغيل، الواي فاي، الهوتسبوت السريع، VLAN والقنوات.'))
			]));

			moveChildren(legacyPanels[0], optionBlocks);
			moveModeChildren(legacyPanels[1], optionBlocks);
			moveChildren(legacyPanels[3], optionBlocks);

			maintenancePage.appendChild(renderNoticeBox('accent', _('صفحة الصيانة'), [
				E('span', _('النسخ الاحتياطي، الاسترجاع، OTA، أزرار الجهاز، إعادة التشغيل وكلمة المرور.'))
			]));

			moveChildren(legacyPanels[4], maintenanceBlocks);

			optionsPage.appendChild(optionBlocks);
			maintenancePage.appendChild(maintenanceBlocks);

			stepPanels.length = 0;
			stepPanels.push(optionsPage);
			stepPanels.push(maintenancePage);
		}());

		stepPanels.forEach(function(stepPanel) {
			stepsWrap.appendChild(stepPanel);
		});

		wizardContainer.appendChild(stepsWrap);

		this.refs.backButton = E('button', { 'class': 'cbi-button cbi-button-neutral' }, _('السابق'));
		this.refs.nextButton = E('button', { 'class': 'cbi-button cbi-button-action important' }, _('التالي'));
		this.refs.saveButton = E('button', { 'class': 'cbi-button cbi-button-save important', 'style': 'display:none;' }, _('حفظ وتطبيق'));
		this.refs.reloadButton = E('button', { 'class': 'cbi-button cbi-button-neutral', 'type': 'button' }, _('تحديث القيم من الجهاز'));

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

		this.refs.reloadButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.reloadStateFromDevice();
		});

		this.refs.backupButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.downloadConfigBackup();
		});

		this.refs.safeRestoreButton.addEventListener('click', function(ev) {
			ev.preventDefault();
			self.safeRestoreConfigBackup();
		});

		this.refs.otaWindowStart.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.otaWindowEnd.addEventListener('change', function() {
			self.updateStepUi();
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

		this.refs.lanNetmask.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.mode.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.uplinkSsid.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.uplinkKey.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.uplinkBand.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.meshId.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.meshKey.addEventListener('input', function() {
			self.updateStepUi();
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

		this.refs.wifiSsidVlan2g.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.wifiSsidVlan5g.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.wifiSsidIpSuffixPrimary.addEventListener('change', function() {
			self.state.wifiSsidVlanIpSuffix = self.refs.wifiSsidIpSuffixPrimary.checked;
			self.refs.wifiSsidVlanIpSuffix.checked = self.state.wifiSsidVlanIpSuffix;
			self.updateStepUi();
		});

		this.refs.wifiSsidVlanIpSuffix.addEventListener('change', function() {
			self.state.wifiSsidVlanIpSuffix = self.refs.wifiSsidVlanIpSuffix.checked;
			self.refs.wifiSsidIpSuffixPrimary.checked = self.state.wifiSsidVlanIpSuffix;
			self.updateStepUi();
		});

		this.refs.wifiKey.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.rebootEnabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.rebootHours.addEventListener('input', function() {
			self.updateStepUi();
		});

		if (this.refs.hotspotQuickEnabled) {
			this.refs.hotspotQuickEnabled.addEventListener('change', function() {
				self.updateStepUi();
				if (self.refs.hotspotQuickEnabled.checked)
					showHotspotLicenseSelectionMessage(_('الهوتسبوت السريع'));
			});
		}

		this.refs.adminPassword.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.adminPasswordConfirm.addEventListener('input', function() {
			self.updateStepUi();
		});

		this.refs.resetDisabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.resetHoldSeconds.addEventListener('change', function() {
			self.updateStepUi();
		});

		this.refs.wpsDisabled.addEventListener('change', function() {
			self.updateStepUi();
		});

		if (this.refs.hotspotEnabled) {
			this.refs.hotspotEnabled.addEventListener('change', function() {
				self.updateStepUi();
				if (self.refs.hotspotEnabled.checked)
					showHotspotLicenseSelectionMessage(_('الهوتسبوت'));
			});
		}

		if (this.refs.hotspotSsid) {
			this.refs.hotspotSsid.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.hotspotRadiusServer) {
			this.refs.hotspotRadiusServer.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.hotspotRadiusSecret) {
			this.refs.hotspotRadiusSecret.addEventListener('input', function() {
				self.updateStepUi();
			});
		}

		if (this.refs.hotspotIp) {
			this.refs.hotspotIp.addEventListener('input', function() {
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
			'hotspotQuickRestAreaEnabled', 'hotspotQuickRestAreaUrl', 'hotspotQuickSpeedtestEnabled', 'hotspotQuickBrowserCookieEnabled',
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

		if (this.refs.hotspotQuickRadiusTestButton) {
			this.refs.hotspotQuickRadiusTestButton.addEventListener('click', function(ev) {
				ev.preventDefault();
				self.testHotspotQuickRadius();
			});
		}

		if (this.refs.hotspotQuickRadiusSecretToggle) {
			this.refs.hotspotQuickRadiusSecretToggle.addEventListener('click', function(ev) {
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

		if (this.refs.hotspotQuickUsermanRestPasswordToggle) {
			this.refs.hotspotQuickUsermanRestPasswordToggle.addEventListener('click', function(ev) {
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

		actions.appendChild(this.refs.reloadButton);
		actions.appendChild(this.refs.backButton);
		actions.appendChild(this.refs.nextButton);
		actions.appendChild(this.refs.saveButton);
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

		this.updateStepUi();

		return this.renderStatus(statusContainer).then(function() {
			poll.add(function() {
				return self.renderStatus(statusContainer);
			});

			return panel;
		});
	}
});