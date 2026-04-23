'use strict';
'require view';
'require rpc';
'require uci';
'require ui';

var refreshTimer = null;

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
	return new Date(n * 1000).toLocaleString();
}

function boolText(v) {
	if (v == null)
		return '-';

	if (typeof(v) === 'string')
		return (v === '1' || v.toLowerCase() === 'true') ? _('Yes') : _('No');

	return v ? _('Yes') : _('No');
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
		return '0s';

	if (hours)
		parts.push(String(hours) + 'h');

	if (minutes)
		parts.push(String(minutes) + 'm');

	if (seconds || !parts.length)
		parts.push(String(seconds) + 's');

	return parts.join(' ');
}

function setText(node, value) {
	node.textContent = (value == null || value === '') ? '-' : String(value);
}

function isUpdateBusy(status) {
	return status.status == 'downloading' || status.status == 'upgrading' || status.last_result == 'upgrade_start';
}

function describeStatus(status, action) {
	if (status.status == 'blocked')
		return status.block_message || _('Upgrade is blocked until provisioning requirements are completed.');

	if (status.status == 'error')
		return _('Operation failed: ') + (status.last_error || _('unknown error'));

	if (action == 'check') {
		if (status.status == 'available')
			return _('A newer update is available and ready for manual upgrade.');

		if (status.status == 'staged')
			return _('A newer update exists, but this device is still waiting for its rollout batch.');

		if (status.status == 'window_wait')
			return _('A newer update exists, but the current time is outside the allowed upgrade window.');

		if (status.last_result == 'up_to_date')
			return _('No newer update is currently available.');
	}

	if (status.status == 'upgrading' || status.last_result == 'upgrade_start')
		return _('Upgrade process started. Live progress is shown below and the device may reboot shortly.');

	if (status.status == 'downloading')
		return _('Update package download started. Live progress is shown below.');

	return _('OTA command completed.');
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('alemprator_ota'),
			L.resolveDefault(callBoard(), {}),
			fetchStatus()
		]);
	},

	render: function(data) {
		var board = data[1] || {};
		var status = data[2] || {};
		var statusCells = {};
		var guardTitle;
		var guardBody;
		var guardMeta;
		var progressTitle;
		var progressFill;
		var progressSummary;
		var progressDetail;

		var checkBtn = E('button', {
			'class': 'btn cbi-button cbi-button-action'
		}, [ _('Check Update') ]);

		var updateBtn = E('button', {
			'class': 'btn cbi-button cbi-button-apply'
		}, [ _('Update Now') ]);

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
				createRow(_('Device Model'), statusCells.deviceModel),
				createRow(_('Board Name'), statusCells.boardName),
				createRow(_('MAC'), statusCells.mac),
				createRow(_('Firstboot Provisioning'), statusCells.firstboot),
				createRow(_('Initial Setup Complete'), statusCells.initialSetup),
				createRow(_('Upgrade Allowed'), statusCells.upgradeAllowed),
				createRow(_('Block Reason'), statusCells.blockReason),
				createRow(_('Current Version'), statusCells.currentVersion),
				createRow(_('Latest Version'), statusCells.latestVersion),
				createRow(_('Update Available'), statusCells.updateAvailable),
				createRow(_('Status'), statusCells.status),
				createRow(_('Last Result'), statusCells.lastResult),
				createRow(_('Last Check'), statusCells.lastCheck),
				createRow(_('Retry Attempts'), statusCells.retryAttempts),
				createRow(_('Next Retry'), statusCells.nextRetry),
				createRow(_('Token Tail'), statusCells.tokenTail),
				createRow(_('Last Error'), statusCells.lastError),
				createRow(_('Changelog'), statusCells.changelog)
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
				setText(progressTitle, _('Downloading update package'));
				progressFill.style.width = String(percent) + '%';
				progressFill.style.background = 'linear-gradient(90deg, #2b8a3e, #74b816)';

				if (totalBytes > 0)
					setText(progressSummary, formatBytes(currentBytes) + ' / ' + formatBytes(totalBytes) + ' (' + String(percent) + '%)');
				else
					setText(progressSummary, formatBytes(currentBytes) + ' ' + _('downloaded'));

				detailParts = [];
				if (safeNumber(currentStatus.download_rate_bps) > 0)
					detailParts.push(_('Speed: ') + formatRate(currentStatus.download_rate_bps));
				if (etaSeconds > 0)
					detailParts.push(_('ETA: ') + formatDuration(etaSeconds));

				setText(progressDetail, detailParts.length ? detailParts.join(' | ') : _('Preparing live progress metrics...'));
				return;
			}

			if (currentStatus.status == 'upgrading' || currentStatus.last_result == 'upgrade_start') {
				progressBox.style.display = '';
				upgradeElapsed = upgradeStarted > 0 ? Math.max(0, now - upgradeStarted) : 0;
				upgradeRemaining = upgradeExpected > 0 ? Math.max(0, upgradeExpected - upgradeElapsed) : 0;
				upgradePercent = upgradeExpected > 0 ? Math.floor((upgradeElapsed * 100) / upgradeExpected) : 0;
				upgradePercent = Math.max(8, Math.min(100, upgradePercent));

				setText(progressTitle, _('Applying update and rebooting'));
				progressFill.style.width = String(upgradePercent) + '%';
				progressFill.style.background = 'linear-gradient(90deg, #f0ad4e, #d9534f)';
				setText(progressSummary, _('Firmware download completed. The device is now applying the update.'));

				if (upgradeRemaining > 0)
					setText(progressDetail, _('Estimated remaining: ') + formatDuration(upgradeRemaining));
				else
					setText(progressDetail, _('The device may reboot at any moment. Reconnect and refresh after it comes back online.'));
				return;
			}

			progressBox.style.display = 'none';
		}

		function applyStatus(nextStatus) {
			status = nextStatus || {};

			if (status.upgrade_allowed === false) {
				guardBox.style.display = '';
				setText(guardTitle, _('Upgrade Blocked'));
				setText(guardBody, status.block_message || _('Upgrade is blocked until provisioning requirements are completed.'));
				setText(guardMeta, _('Firstboot provisioning: ') + (status.firstboot_enabled ? _('enabled') : _('disabled')) + ' | ' + _('Initial setup complete: ') + boolText(status.initial_setup_complete));
			}
			else {
				guardBox.style.display = 'none';
			}

			checkBtn.disabled = isUpdateBusy(status);
			updateBtn.disabled = status.upgrade_allowed === false || isUpdateBusy(status);

			if (status.upgrade_allowed === false)
				updateBtn.setAttribute('title', status.block_message || _('Upgrade is currently blocked.'));
			else if (isUpdateBusy(status))
				updateBtn.setAttribute('title', _('An update is already running.'));
			else
				updateBtn.removeAttribute('title');

			setText(statusCells.deviceModel, status.model || board.model || '-');
			setText(statusCells.boardName, status.board || board.board_name || '-');
			setText(statusCells.mac, status.mac || '-');
			setText(statusCells.firstboot, status.firstboot_enabled ? _('Enabled') : _('Disabled'));
			setText(statusCells.initialSetup, boolText(status.initial_setup_complete));
			setText(statusCells.upgradeAllowed, boolText(status.upgrade_allowed));
			setText(statusCells.blockReason, status.block_message || status.block_reason || '-');
			setText(statusCells.currentVersion, status.current_version || '-');
			setText(statusCells.latestVersion, status.latest_version || '-');
			setText(statusCells.updateAvailable, boolText(status.update_available));
			setText(statusCells.status, status.status || '-');
			setText(statusCells.lastResult, status.last_result || '-');
			setText(statusCells.lastCheck, epochText(status.last_check_epoch));
			setText(statusCells.retryAttempts, String(status.retry_attempts || 0));
			setText(statusCells.nextRetry, epochText(status.next_retry_epoch));
			setText(statusCells.tokenTail, status.token_tail || '-');
			setText(statusCells.lastError, status.last_error || '-');
			setText(statusCells.changelog, status.changelog || '-');

			renderProgress(status);
		}

		function refreshStatus() {
			return fetchStatus().then(function(nextStatus) {
				applyStatus(nextStatus);
				return nextStatus;
			}).catch(function() {
				if (isUpdateBusy(status)) {
					progressBox.style.display = '';
					setText(progressDetail, _('Waiting for the device to respond. It may be rebooting now.'));
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
			execScript('/usr/libexec/alemprator-ota/run-once', [ '--check-only' ]).then(function() {
				return refreshStatus().then(function(nextStatus) {
					ui.addNotification(null, E('p', describeStatus(nextStatus, 'check')));
				});
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');
				ui.addNotification(null, E('p', _('Failed to request update check: ') + msg));
				applyStatus(status);
			});
		});

		updateBtn.addEventListener('click', function() {
			updateBtn.disabled = true;
			execScript('/usr/libexec/alemprator-ota/start-update', []).then(function() {
				ui.addNotification(null, E('p', _('Update process started in the background. Live progress will appear below.')));
				scheduleRefresh(800);
			}).catch(function(err) {
				var msg = (err && err.message) ? err.message : String(err || '');

				if (/timeout/i.test(msg || '')) {
					ui.addNotification(null, E('p', _('The start request timed out, but the update may already be running in the background. Live status polling will continue below.')));
					scheduleRefresh(1500);
					return;
				}

				ui.addNotification(null, E('p', _('Failed to start update: ') + msg));
				applyStatus(status);
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
			E('h2', _('OTA Update')),
			E('p', _('This page shows OTA identity and update status and allows manual check or immediate update.')),
			E('div', { 'style': 'display:flex; gap:10px; margin: 12px 0;' }, [ checkBtn, updateBtn ])
		].concat([
			guardBox,
			progressBox,
			statusBox
		]));
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
