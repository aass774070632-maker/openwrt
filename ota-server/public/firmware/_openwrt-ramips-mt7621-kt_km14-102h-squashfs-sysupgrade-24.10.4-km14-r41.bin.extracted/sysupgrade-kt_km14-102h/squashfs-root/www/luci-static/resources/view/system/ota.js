'use strict';
'require view';
'require fs';
'require rpc';
'require uci';
'require ui';

var refreshTimer = null;
var MANUAL_IMAGE_PATH = '/tmp/alemprator-ota/manual-update.bin';
var STATUS_LABELS = {
	idle: 'خامل',
	checking: 'جارٍ التحقق',
	available: 'يوجد تحديث',
	staged: 'بانتظار دفعة النشر',
	window_wait: 'بانتظار نافذة التحديث',
	blocked: 'محظور',
	backoff: 'تراجع مؤقت',
	downloading: 'جارٍ التنزيل',
	upgrading: 'جارٍ التثبيت',
	error: 'خطأ'
};
var RESULT_LABELS = {
	idle: 'خامل',
	up_to_date: 'محدّث',
	retry_wait: 'بانتظار إعادة المحاولة',
	check_failed: 'فشل التحقق',
	staged_wait: 'بانتظار دفعة النشر',
	upgrade_blocked: 'التحديث محظور',
	manual_required: 'يتطلب تشغيلًا يدويًا',
	outside_window: 'خارج نافذة التحديث',
	missing_url: 'رابط التنزيل مفقود',
	download_or_hash_failed: 'فشل التنزيل أو المطابقة',
	upgrade_start: 'بدأ التحديث',
	sysupgrade_failed: 'فشل تشغيل sysupgrade',
	manual_upgrade_start: 'بدأ التحديث اليدوي',
	manual_sysupgrade_failed: 'فشل التحديث اليدوي',
	manual_image_missing: 'ملف يدوي مفقود'
};

var callStatus = rpc.declare({
	object: 'file',
	method: 'exec',
	params: [ 'command', 'params' ],
	expect: { '': { code: 0, stdout: '', stderr: '' } }
});

var callBoard = rpc.declare({
	object: 'system',
	method: 'board',
	expect: { '': {} }
});

function fetchStatus() {
	return L.resolveDefault(callStatus('/usr/libexec/alemprator-ota/status-json', []), { stdout: '' }).then(function(res) {
		if (res.code && res.code !== 0)
			return {
				status: 'error',
				last_error: res.stderr || _('Failed to read OTA status')
			};

		return parseJsonSafe(res.stdout || '{}');
	});
}

function execScript(command, args) {
	return callStatus(command, args).then(function(res) {
		if (res && res.code && res.code !== 0) {
			var stderr = (res.stderr || '').trim();
			return Promise.reject(stderr || (_('Command failed with exit code ') + String(res.code)));
		}

		return res || {};
	});
}

function startUpdateRequest() {
	return fs.exec_direct('/usr/libexec/alemprator-ota/start-update', [], 'json');
}

function startCheckRequest() {
	return fs.exec_direct('/usr/libexec/alemprator-ota/start-check', [], 'json');
}

function fetchManualInfo() {
	return L.resolveDefault(fs.exec_direct('/usr/libexec/alemprator-ota/manual-info', [], 'json'), {
		available: false,
		valid: false,
		path: MANUAL_IMAGE_PATH,
		filename: '',
		size_bytes: 0,
		sha256: '',
		message: ''
	});
}

function clearManualImage() {
	return fs.exec_direct('/usr/libexec/alemprator-ota/manual-clear', [], 'json');
}

function startManualUpdateRequest() {
	return fs.exec_direct('/usr/libexec/alemprator-ota/start-manual-update', [], 'json');
}

function parseJsonSafe(text) {
	try {
		return JSON.parse(text || '{}');
	}
	catch (e) {
		return { status: 'error', last_error: 'Invalid status JSON' };
	}
}

function epochText(epoch) {
	var n = Number(epoch || 0);
	if (!n)
		return '-';
	return new Date(n * 1000).toLocaleString('ar-SA');
}

function boolText(v) {
	if (v == null)
		return '-';

	if (typeof(v) === 'string')
		return (v === '1' || v.toLowerCase() === 'true') ? 'نعم' : 'لا';

	return v ? 'نعم' : 'لا';
}

function enabledText(v) {
	return v ? 'مفعّل' : 'متوقف';
}

function translateValue(value, labels) {
	var key = String(value == null ? '' : value);

	if (!key)
		return '-';

	return labels[key] || key;
}

function shortenHash(value) {
	var text = String(value || '').trim();

	if (!text)
		return '-';

	if (text.length <= 20)
		return text;

	return text.substring(0, 20) + '...';
}

function safeNumber(value) {
	var n = Number(value || 0);

	if (!isFinite(n) || n < 0)
		return 0;

	return n;
}

function formatBytes(value) {
	var units = [ 'B', 'KB', 'MB', 'GB' ];
	var n = safeNumber(value);
	var unit = 0;
	var precision;

	if (!n)
		return '0 B';

	while (n >= 1024 && unit < units.length - 1) {
		n = n / 1024;
		unit++;
	}

	precision = (n >= 100 || unit === 0) ? 0 : (n >= 10 ? 1 : 2);

	return n.toFixed(precision).replace(/\.0+$|(\.\d*[1-9])0+$/, '$1') + ' ' + units[unit];
}

function formatRate(value) {
	var rate = safeNumber(value);

	if (!rate)
		return '-';

	return formatBytes(rate) + '/s';
}

function formatDuration(value) {
	var total = Math.max(0, Math.round(Number(value || 0)));
	var hours = Math.floor(total / 3600);
	var minutes = Math.floor((total % 3600) / 60);
	var seconds = total % 60;
	var parts = [];

	if (!total)
		return '0 ث';

	if (hours)
		parts.push(String(hours) + ' س');

	if (minutes)
		parts.push(String(minutes) + ' د');

	if (seconds || !parts.length)
		parts.push(String(seconds) + ' ث');

	return parts.join(' ');
}

function formatCountdown(value) {
	var total = Math.max(0, Math.round(Number(value || 0)));
	var hours = Math.floor(total / 3600);
	var minutes = Math.floor((total % 3600) / 60);
	var seconds = total % 60;

	function pad(n) {
		return (n < 10 ? '0' : '') + String(n);
	}

	return pad(hours) + ':' + pad(minutes) + ':' + pad(seconds);
}

function nextWindowStartEpoch(startHour, endHour) {
	var startValue = (startHour == null || startHour === '') ? 2 : startHour;
	var endValue = (endHour == null || endHour === '') ? 6 : endHour;
	var start = Math.max(0, Math.min(23, Math.floor(safeNumber(startValue))));
	var end = Math.max(0, Math.min(23, Math.floor(safeNumber(endValue))));
	var now = new Date();
	var candidate = new Date(now.getTime());

	candidate.setHours(start, 0, 0, 0);

	if (start == end)
		return Math.floor(now.getTime() / 1000);

	if (start < end) {
		if (now.getHours() < start)
			return Math.floor(candidate.getTime() / 1000);

		if (now.getHours() >= end) {
			candidate.setDate(candidate.getDate() + 1);
			return Math.floor(candidate.getTime() / 1000);
		}

		return Math.floor(now.getTime() / 1000);
	}

	if (now.getHours() >= start || now.getHours() < end)
		return Math.floor(now.getTime() / 1000);

	return Math.floor(candidate.getTime() / 1000);
}

function isWindowWaiting(status) {
	return status.status == 'window_wait' || status.last_result == 'outside_window' || /outside update window/i.test(status.last_error || '');
}

function setText(node, value) {
	node.textContent = (value == null || value === '') ? '-' : String(value);
}

function isUpdateBusy(status) {
	return status.status == 'downloading' || status.status == 'upgrading' || status.last_result == 'upgrade_start';
}

function describeStatus(status, action) {
	if (status.status == 'blocked')
		return status.block_message || 'التحديث محظور حتى تكتمل متطلبات التهيئة.';

	if (status.status == 'error')
		return 'فشلت العملية: ' + (status.last_error || 'سبب غير معروف');

	if (action == 'check') {
		if (status.status == 'available')
			return 'يوجد تحديث جديد وجاهز للتثبيت اليدوي.';

		if (status.status == 'staged')
			return 'يوجد تحديث جديد، لكن هذا الجهاز ما زال بانتظار دفعة النشر المخصصة له.';

		if (status.status == 'window_wait')
			return 'يوجد تحديث جديد، لكن الوقت الحالي خارج نافذة التحديث المسموح بها.';

		if (status.last_result == 'up_to_date')
			return 'لا يوجد تحديث أحدث حاليًا.';
	}

	if (status.status == 'upgrading' || status.last_result == 'upgrade_start')
		return 'بدأت عملية التحديث. سيظهر التقدم الحي أدناه وقد يعيد الجهاز التشغيل قريبًا.';

	if (status.status == 'downloading')
		return 'بدأ تنزيل حزمة التحديث. سيظهر التقدم الحي أدناه.';

	return 'اكتملت عملية OTA.';
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('alemprator_ota'),
			L.resolveDefault(callBoard(), {}),
			fetchStatus(),
			fetchManualInfo()
		]);
	},

	render: function(data) {
		var board = data[1] || {};
		var status = data[2] || {};
		var manualInfo = data[3] || {};
		var statusCells = {};
		var guardTitle;
		var guardBody;
		var guardMeta;
		var progressTitle;
		var progressFill;
		var progressSummary;
		var progressDetail;
		var manualSummary;
		var manualDetail;
		var manualUploadProgress = document.createTextNode('-');

		var checkBtn = E('button', {
			'class': 'btn cbi-button cbi-button-action'
		}, [ 'فحص التحديث' ]);

		var updateBtn = E('button', {
			'class': 'btn cbi-button cbi-button-apply'
		}, [ 'تحديث الآن' ]);

		var uploadManualBtn = E('button', {
			'class': 'btn cbi-button cbi-button-action'
		}, [ 'رفع ملف يدوي' ]);

		var applyManualBtn = E('button', {
			'class': 'btn cbi-button cbi-button-apply'
		}, [ 'تطبيق الملف اليدوي' ]);

		var clearManualBtn = E('button', {
			'class': 'btn cbi-button cbi-button-neutral'
		}, [ 'حذف الملف اليدوي' ]);

		function createValueCell() {
			return E('td');
		}

		function createRow(label, cell) {
			return E('tr', [ E('th', label), cell ]);
		}

		statusCells.deviceModel = createValueCell();
		statusCells.boardName = createValueCell();
		statusCells.mac = createValueCell();
		statusCells.firstboot = createValueCell();
		statusCells.initialSetup = createValueCell();
		statusCells.upgradeAllowed = createValueCell();
		statusCells.blockReason = createValueCell();
		statusCells.currentVersion = createValueCell();
		statusCells.latestVersion = createValueCell();
		statusCells.updateAvailable = createValueCell();
		statusCells.status = createValueCell();
		statusCells.lastResult = createValueCell();
		statusCells.lastCheck = createValueCell();
		statusCells.retryAttempts = createValueCell();
		statusCells.nextRetry = createValueCell();
		statusCells.tokenTail = createValueCell();
		statusCells.lastError = createValueCell();
		statusCells.changelog = createValueCell();

		var guardBox = E('div', {
			'class': 'alert-message warning',
			'style': 'margin: 12px 0; display:none;'
		}, [
			guardTitle = E('strong'),
			guardBody = E('p'),
			guardMeta = E('p')
		]);

		var progressBox = E('div', {
			'style': 'display:none; margin-top:12px;'
		}, [
			E('div', {
				'style': 'padding:14px; border:1px solid #d9e4ea; border-radius:12px; background:linear-gradient(180deg, #fbfdff, #eef5f8);'
			}, [
				progressTitle = E('div', {
					'style': 'font-size:15px; font-weight:600;'
				}),
				E('div', {
					'style': 'height:12px; margin-top:10px; background:#d7e3e8; border-radius:999px; overflow:hidden;'
				}, [
					progressFill = E('div', {
						'style': 'height:100%; width:0%; border-radius:999px; transition:width .8s ease; background:linear-gradient(90deg, #2b8a3e, #74b816);'
					})
				]),
				progressSummary = E('div', {
					'style': 'margin-top:8px; font-weight:600;'
				}),
				progressDetail = E('div', {
					'style': 'margin-top:4px; color:#666;'
				})
			])
		]);

		var statusBox = E('div', { 'style': 'margin-top:12px;' }, [
			E('table', { 'class': 'table cbi-section-table' }, [
				createRow('طراز الجهاز', statusCells.deviceModel),
				createRow('اسم اللوحة', statusCells.boardName),
				createRow(_('MAC'), statusCells.mac),
				createRow('تهيئة firstboot', statusCells.firstboot),
				createRow('اكتمل الإعداد الأولي', statusCells.initialSetup),
				createRow('السماح بالتحديث', statusCells.upgradeAllowed),
				createRow('سبب الحظر', statusCells.blockReason),
				createRow('الإصدار الحالي', statusCells.currentVersion),
				createRow('أحدث إصدار', statusCells.latestVersion),
				createRow('يوجد تحديث', statusCells.updateAvailable),
				createRow('الحالة', statusCells.status),
				createRow('آخر نتيجة', statusCells.lastResult),
				createRow('آخر فحص', statusCells.lastCheck),
				createRow('عدد المحاولات', statusCells.retryAttempts),
				createRow('المحاولة التالية', statusCells.nextRetry),
				createRow('نهاية الرمز', statusCells.tokenTail),
				createRow('آخر خطأ', statusCells.lastError),
				createRow('سجل التغييرات', statusCells.changelog)
			])
		]);

		var manualBox = E('div', {
			'style': 'margin-top:12px;'
		}, [
			E('div', {
				'style': 'padding:14px; border:1px solid #e7dcc5; border-radius:12px; background:linear-gradient(180deg, #fffdf8, #f7f1e7);'
			}, [
				E('div', {
					'style': 'font-size:15px; font-weight:600;'
				}, 'التحديث اليدوي من ملف'),
				E('p', {
					'style': 'margin:6px 0 10px 0; color:#666;'
				}, 'يرفع هذا المسار ملف sysupgrade من جهازك إلى الراوتر ثم يفحصه محليًا قبل السماح بالتطبيق.'),
				E('div', {
					'style': 'display:flex; gap:10px; flex-wrap:wrap;'
				}, [ uploadManualBtn, applyManualBtn, clearManualBtn ]),
				E('div', {
					'style': 'margin-top:10px; color:#666;'
				}, [ 'تقدم الرفع: ', manualUploadProgress ]),
				manualSummary = E('div', {
					'style': 'margin-top:8px; font-weight:600;'
				}),
				manualDetail = E('div', {
					'style': 'margin-top:4px; color:#666; unicode-bidi: plaintext;'
				})
			])
		]);

		function renderProgress(currentStatus) {
			var totalBytes = safeNumber(currentStatus.download_size_bytes);
			var currentBytes = safeNumber(currentStatus.download_bytes);
			var percent = Math.max(0, Math.min(100, Math.round(safeNumber(currentStatus.download_percent))));
			var etaSeconds = Math.round(safeNumber(currentStatus.download_eta_seconds));
			var upgradeStarted = Math.round(safeNumber(currentStatus.upgrade_started_epoch));
			var upgradeExpected = Math.round(safeNumber(currentStatus.upgrade_expected_seconds || 180));
			var now = Math.floor(Date.now() / 1000);
			var upgradeElapsed;
			var upgradeRemaining;
			var upgradePercent;
			var detailParts;

			if (currentStatus.status == 'downloading') {
				progressBox.style.display = '';
				setText(progressTitle, 'جارٍ تنزيل حزمة التحديث');
				progressFill.style.width = String(percent) + '%';
				progressFill.style.background = 'linear-gradient(90deg, #2b8a3e, #74b816)';

				if (totalBytes > 0)
					setText(progressSummary, formatBytes(currentBytes) + ' / ' + formatBytes(totalBytes) + ' (' + String(percent) + '%)');
				else
					setText(progressSummary, formatBytes(currentBytes) + ' تم تنزيلها');

				detailParts = [];
				if (safeNumber(currentStatus.download_rate_bps) > 0)
					detailParts.push('السرعة: ' + formatRate(currentStatus.download_rate_bps));
				if (etaSeconds > 0)
					detailParts.push('الوقت المتبقي: ' + formatDuration(etaSeconds));

				setText(progressDetail, detailParts.length ? detailParts.join(' | ') : 'جارٍ تجهيز مؤشرات التقدم الحية...');
				return;
			}

			if (currentStatus.status == 'upgrading' || currentStatus.last_result == 'upgrade_start') {
				progressBox.style.display = '';
				upgradeElapsed = upgradeStarted > 0 ? Math.max(0, now - upgradeStarted) : 0;
				upgradeRemaining = upgradeExpected > 0 ? Math.max(0, upgradeExpected - upgradeElapsed) : 0;
				upgradePercent = upgradeExpected > 0 ? Math.floor((upgradeElapsed * 100) / upgradeExpected) : 0;
				upgradePercent = Math.max(8, Math.min(100, upgradePercent));

				setText(progressTitle, 'جارٍ تطبيق التحديث والاستعداد لإعادة التشغيل');
				progressFill.style.width = String(upgradePercent) + '%';
				progressFill.style.background = 'linear-gradient(90deg, #f0ad4e, #d9534f)';
				setText(progressSummary, 'اكتمل تنزيل البرنامج الثابت، ويجري الآن تطبيق التحديث على الجهاز.');

				if (upgradeRemaining > 0)
					setText(progressDetail, 'الوقت التقديري المتبقي: ' + formatDuration(upgradeRemaining));
				else
					setText(progressDetail, 'قد يعيد الجهاز التشغيل في أي لحظة. أعد الاتصال وحدّث الصفحة بعد عودته.');
				return;
			}

			progressBox.style.display = 'none';
		}

		function applyManualInfo(nextManualInfo) {
			var detailParts = [];

			manualInfo = nextManualInfo || {};
			uploadManualBtn.disabled = isUpdateBusy(status);
			clearManualBtn.disabled = !manualInfo.available || isUpdateBusy(status);
			applyManualBtn.disabled = !manualInfo.available || !manualInfo.valid || isUpdateBusy(status) || status.upgrade_allowed === false;

			if (!manualInfo.available) {
				setText(manualSummary, 'لا يوجد ملف يدوي مرفوع حاليًا');
				setText(manualDetail, 'اضغط على "رفع ملف يدوي" لاختيار ملف sysupgrade من جهازك ثم فحصه قبل التثبيت.');
				applyManualBtn.removeAttribute('title');
				clearManualBtn.removeAttribute('title');
				return;
			}

			if (manualInfo.valid) {
				setText(manualSummary, 'الملف اليدوي جاهز للتطبيق');
			}
			else {
				setText(manualSummary, 'الملف المرفوع غير صالح للتثبيت');
			}

			detailParts.push('المسار: ' + (manualInfo.path || MANUAL_IMAGE_PATH));
			if (safeNumber(manualInfo.size_bytes) > 0)
				detailParts.push('الحجم: ' + formatBytes(manualInfo.size_bytes));
			if (manualInfo.sha256)
				detailParts.push('SHA256: ' + shortenHash(manualInfo.sha256));
			if (manualInfo.message)
				detailParts.push('النتيجة: ' + manualInfo.message);

			setText(manualDetail, detailParts.join(' | '));

			if (status.upgrade_allowed === false)
				applyManualBtn.setAttribute('title', status.block_message || 'التحديث محظور حاليًا.');
			else if (!manualInfo.valid)
				applyManualBtn.setAttribute('title', manualInfo.message || 'فشل فحص الملف اليدوي.');
			else if (isUpdateBusy(status))
				applyManualBtn.setAttribute('title', 'يوجد تحديث يعمل بالفعل.');
			else
				applyManualBtn.removeAttribute('title');
		}

		function refreshManualInfo() {
			return fetchManualInfo().then(function(nextManualInfo) {
				applyManualInfo(nextManualInfo);
				return nextManualInfo;
			});
		}

		function applyStatus(nextStatus) {
			var nextRetryText;
			var nextWindowEpoch;
			var windowRemaining;
			var waitingForWindow;
			var statusText;

			status = nextStatus || {};

			if (status.upgrade_allowed === false) {
				guardBox.style.display = '';
				setText(guardTitle, 'التحديث محظور');
				setText(guardBody, status.block_message || 'التحديث محظور حتى تكتمل متطلبات التهيئة.');
				setText(guardMeta, 'حالة firstboot: ' + enabledText(status.firstboot_enabled) + ' | اكتمال الإعداد الأولي: ' + boolText(status.initial_setup_complete));
			}
			else {
				guardBox.style.display = 'none';
			}

			checkBtn.disabled = isUpdateBusy(status);
			updateBtn.disabled = status.upgrade_allowed === false || isUpdateBusy(status);

			if (status.upgrade_allowed === false)
				updateBtn.setAttribute('title', status.block_message || 'التحديث محظور حاليًا.');
			else if (isUpdateBusy(status))
				updateBtn.setAttribute('title', 'يوجد تحديث يعمل بالفعل.');
			else
				updateBtn.removeAttribute('title');

			setText(statusCells.deviceModel, status.model || board.model || '-');
			setText(statusCells.boardName, status.board || board.board_name || '-');
			setText(statusCells.mac, status.mac || '-');
			setText(statusCells.firstboot, enabledText(status.firstboot_enabled));
			setText(statusCells.initialSetup, boolText(status.initial_setup_complete));
			setText(statusCells.upgradeAllowed, boolText(status.upgrade_allowed));
			setText(statusCells.blockReason, status.block_message || status.block_reason || '-');
			setText(statusCells.currentVersion, status.current_version || '-');
			setText(statusCells.latestVersion, status.latest_version || '-');
			setText(statusCells.updateAvailable, boolText(status.update_available));
			waitingForWindow = isWindowWaiting(status);
			nextWindowEpoch = safeNumber(status.next_window_epoch);
			if (waitingForWindow && nextWindowEpoch <= 0)
				nextWindowEpoch = nextWindowStartEpoch(status.window_start_hour, status.window_end_hour);
			windowRemaining = nextWindowEpoch > 0 ? Math.max(0, nextWindowEpoch - Math.floor(Date.now() / 1000)) : 0;
			statusText = translateValue(status.status, STATUS_LABELS);

			if (waitingForWindow && nextWindowEpoch > 0 && windowRemaining > 0)
				statusText += ' (النافذة التالية بعد ' + formatCountdown(windowRemaining) + ')';

			setText(statusCells.status, statusText);
			setText(statusCells.lastResult, translateValue(status.last_result, RESULT_LABELS));
			setText(statusCells.lastCheck, epochText(status.last_check_epoch));
			setText(statusCells.retryAttempts, String(status.retry_attempts || 0));

			nextRetryText = epochText(status.next_retry_epoch);
			if (waitingForWindow && nextWindowEpoch > 0) {
				nextRetryText = epochText(nextWindowEpoch);
				if (windowRemaining > 0)
					nextRetryText += ' (' + formatCountdown(windowRemaining) + ')';
			}

			setText(statusCells.nextRetry, nextRetryText);
			setText(statusCells.tokenTail, status.token_tail || '-');
			setText(statusCells.lastError, status.last_error || '-');
			setText(statusCells.changelog, status.changelog || '-');

			renderProgress(status);
			applyManualInfo(manualInfo);
		}

		function refreshStatus() {
			return fetchStatus().then(function(nextStatus) {
				applyStatus(nextStatus);
				return nextStatus;
			}).catch(function() {
				if (isUpdateBusy(status)) {
					progressBox.style.display = '';
					setText(progressDetail, 'بانتظار استجابة الجهاز. قد يكون قد دخل في إعادة التشغيل الآن.');
				}

				return status;
			});
		}

		function scheduleRefresh(delay) {
			window.setTimeout(function() {
				refreshStatus();
			}, delay || 0);
		}

		checkBtn.addEventListener('click', function() {
			checkBtn.disabled = true;
			startCheckRequest().then(function(res) {
				if (res && res.started === false && res.already_running)
					ui.addNotification(null, E('p', 'يوجد فحص تحديث يعمل بالفعل. سيتم تحديث الحالة الحية أدناه.'));
				scheduleRefresh(800);
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');
				var rawMsg = String(err || '') + ' ' + msg;

				if (/(timed?\s*out|timeout|abort|xhr request)/i.test(rawMsg || '')) {
					scheduleRefresh(800);
					return;
				}

				return refreshStatus().then(function(nextStatus) {
					if (isUpdateBusy(nextStatus))
						return;

					ui.addNotification(null, E('p', 'تعذر طلب فحص التحديث: ' + msg));
					applyStatus(nextStatus || status);
				});
			});
		});

		updateBtn.addEventListener('click', function() {
			updateBtn.disabled = true;
			startUpdateRequest().then(function(res) {
				if (res && res.started === false && res.already_running) {
					ui.addNotification(null, E('p', 'يوجد تحديث يعمل بالفعل. التقدم الحي ظاهر أدناه.'));
				}
				else {
					ui.addNotification(null, E('p', 'بدأت عملية التحديث في الخلفية. سيظهر التقدم الحي أدناه.'));
				}

				scheduleRefresh(800);
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');
				var rawMsg = String(err || '') + ' ' + msg;

				if (/(timed?\s*out|timeout|abort|xhr request)/i.test(rawMsg || '')) {
					scheduleRefresh(800);
					return;
				}

				return refreshStatus().then(function(nextStatus) {
					if (isUpdateBusy(nextStatus)) {
						ui.addNotification(null, E('p', 'عملية التحديث تعمل بالفعل. التقدم الحي ظاهر أدناه.'));
						return;
					}

					ui.addNotification(null, E('p', 'تعذر بدء التحديث: ' + msg));
					applyStatus(nextStatus || status);
				});
			});
		});

		uploadManualBtn.addEventListener('click', function() {
			if (isUpdateBusy(status))
				return;

			uploadManualBtn.disabled = true;
			manualUploadProgress.data = '0.00%';

			ui.uploadFile(MANUAL_IMAGE_PATH, manualUploadProgress).then(function() {
				return refreshManualInfo().then(function(nextManualInfo) {
					if (nextManualInfo.available && nextManualInfo.valid)
						ui.addNotification(null, E('p', 'تم رفع الملف اليدوي والتحقق منه بنجاح. يمكنك الآن تطبيقه.'));
					else
						ui.addNotification(null, E('p', 'تم رفع الملف لكن فحص sysupgrade فشل: ' + (nextManualInfo.message || 'سبب غير معروف')));
				});
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');

				if (/cancel/i.test(msg || '')) {
					if (!manualInfo.available)
						manualUploadProgress.data = '-';
					return;
				}

				ui.addNotification(null, E('p', 'فشل رفع الملف اليدوي: ' + msg));
			}).finally(function() {
				applyManualInfo(manualInfo);
			});
		});

		clearManualBtn.addEventListener('click', function() {
			clearManualBtn.disabled = true;
			clearManualImage().then(function() {
				manualUploadProgress.data = '-';
				return refreshManualInfo();
			}).then(function() {
				ui.addNotification(null, E('p', 'تم حذف الملف اليدوي من الراوتر.'));
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');
				ui.addNotification(null, E('p', 'تعذر حذف الملف اليدوي: ' + msg));
			}).finally(function() {
				applyManualInfo(manualInfo);
			});
		});

		applyManualBtn.addEventListener('click', function() {
			applyManualBtn.disabled = true;
			startManualUpdateRequest().then(function(res) {
				if (res && res.started === false) {
					ui.addNotification(null, E('p', res.message || 'تعذر بدء التحديث اليدوي.'));
					return refreshStatus().then(function(nextStatus) {
						applyStatus(nextStatus || status);
					});
				}

				ui.addNotification(null, E('p', 'بدأ التحديث اليدوي من الملف المحلي. سيظهر التقدم الحي أدناه.'));
				scheduleRefresh(800);
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');
				ui.addNotification(null, E('p', 'تعذر بدء التحديث اليدوي: ' + msg));
				applyManualInfo(manualInfo);
			});
		});

		applyStatus(status);

		if (refreshTimer)
			window.clearInterval(refreshTimer);

		refreshTimer = window.setInterval(function() {
			refreshStatus();
		}, 2000);

		window.addEventListener('beforeunload', function() {
			if (refreshTimer) {
				window.clearInterval(refreshTimer);
				refreshTimer = null;
			}
		}, { once: true });

		return E('div', { 'class': 'cbi-map' }, [
			E('h2', 'تحديث OTA'),
			E('p', 'تعرض هذه الصفحة هوية OTA وحالة التحديث، وتسمح بفحص التحديث من الخادم أو تطبيق تحديث يدوي من ملف محلي.'),
			E('div', { 'style': 'display:flex; gap:10px; margin: 12px 0;' }, [ checkBtn, updateBtn ])
		].concat([
			guardBox,
			progressBox,
			manualBox,
			statusBox
		]));
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
