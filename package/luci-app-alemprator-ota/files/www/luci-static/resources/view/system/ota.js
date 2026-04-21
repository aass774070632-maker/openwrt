'use strict';
'require view';
'require rpc';
'require uci';
'require ui';

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

	return v ? _('Yes') : _('No');
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
		return _('Upgrade process started. Device may reboot shortly.');

	if (status.status == 'downloading')
		return _('Update package download started.');

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

		var checkBtn = E('button', {
			'class': 'btn cbi-button cbi-button-action'
		}, [ _('Check Update') ]);

		var updateBtn = E('button', {
			'class': 'btn cbi-button cbi-button-apply'
		}, [ _('Update Now') ]);

		if (status.upgrade_allowed === false) {
			updateBtn.disabled = true;
			updateBtn.setAttribute('title', status.block_message || _('Upgrade is currently blocked.'));
		}

		var guardBox = status.upgrade_allowed === false ? E('div', {
			'class': 'alert-message warning',
			'style': 'margin: 12px 0;'
		}, [
			E('strong', _('Upgrade Blocked')),
			E('p', status.block_message || _('Upgrade is blocked until provisioning requirements are completed.')),
			E('p', _('Firstboot provisioning: ') + (status.firstboot_enabled ? _('enabled') : _('disabled')) + ' | ' + _('Initial setup complete: ') + boolText(status.initial_setup_complete))
		]) : null;

		var statusBox = E('div', { 'style': 'margin-top:12px;' }, [
			E('table', { 'class': 'table cbi-section-table' }, [
				E('tr', [ E('th', _('Device Model')), E('td', status.model || board.model || '-') ]),
				E('tr', [ E('th', _('Board Name')), E('td', status.board || board.board_name || '-') ]),
				E('tr', [ E('th', _('MAC')), E('td', status.mac || '-') ]),
				E('tr', [ E('th', _('Firstboot Provisioning')), E('td', status.firstboot_enabled ? _('Enabled') : _('Disabled')) ]),
				E('tr', [ E('th', _('Initial Setup Complete')), E('td', boolText(status.initial_setup_complete)) ]),
				E('tr', [ E('th', _('Upgrade Allowed')), E('td', boolText(status.upgrade_allowed)) ]),
				E('tr', [ E('th', _('Block Reason')), E('td', status.block_message || status.block_reason || '-') ]),
				E('tr', [ E('th', _('Current Version')), E('td', status.current_version || '-') ]),
				E('tr', [ E('th', _('Latest Version')), E('td', status.latest_version || '-') ]),
				E('tr', [ E('th', _('Update Available')), E('td', boolText(status.update_available)) ]),
				E('tr', [ E('th', _('Status')), E('td', status.status || '-') ]),
				E('tr', [ E('th', _('Last Result')), E('td', status.last_result || '-') ]),
				E('tr', [ E('th', _('Last Check')), E('td', epochText(status.last_check_epoch)) ]),
				E('tr', [ E('th', _('Retry Attempts')), E('td', String(status.retry_attempts || 0)) ]),
				E('tr', [ E('th', _('Next Retry')), E('td', epochText(status.next_retry_epoch)) ]),
				E('tr', [ E('th', _('Token Tail')), E('td', status.token_tail || '-') ]),
				E('tr', [ E('th', _('Last Error')), E('td', status.last_error || '-') ]),
				E('tr', [ E('th', _('Changelog')), E('td', status.changelog || '-') ])
			])
		]);

		checkBtn.addEventListener('click', function() {
			checkBtn.disabled = true;
			callStatus('/usr/libexec/alemprator-ota/run-once', [ '--check-only' ]).then(function() {
				return fetchStatus().then(function(nextStatus) {
					ui.addNotification(null, E('p', describeStatus(nextStatus, 'check')));
					location.reload();
				});
			}).catch(function(err) {
				ui.addNotification(null, E('p', _('Failed to request update check: ') + (err || '')));
			}).finally(function() {
				checkBtn.disabled = false;
			});
		});

		updateBtn.addEventListener('click', function() {
			updateBtn.disabled = true;
			callStatus('/usr/libexec/alemprator-ota/run-once', [ '--update-now' ]).then(function() {
				return fetchStatus().then(function(nextStatus) {
					ui.addNotification(null, E('p', describeStatus(nextStatus, 'update')));
					location.reload();
				}, function() {
					ui.addNotification(null, E('p', _('Update process started. Device may reboot if update is applied.')));
				});
			}).catch(function(err) {
				ui.addNotification(null, E('p', _('Failed to start update: ') + (err || '')));
			}).finally(function() {
				updateBtn.disabled = false;
			});
		});

		return E('div', { 'class': 'cbi-map' }, [
			E('h2', _('OTA Update')),
			E('p', _('This page shows OTA identity and update status and allows manual check or immediate update.')),
			E('div', { 'style': 'display:flex; gap:10px; margin: 12px 0;' }, [ checkBtn, updateBtn ])
		].concat(guardBox ? [ guardBox ] : []).concat([
			statusBox
		]));
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
