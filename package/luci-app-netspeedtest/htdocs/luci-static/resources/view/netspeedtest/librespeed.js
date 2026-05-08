'use strict';
'require view';
'require poll';
'require fs';
'require rpc';
'require uci';
'require ui';
'require form';
'require dom';

const conf = 'librespeed-go';
const instance = 'librespeed-go';
const netspeedtestConf = 'netspeedtest';

const callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList(conf), {})
		.then((res) => {
			let isrunning = false;
			try {
				isrunning = res[conf]['instances'][instance]['running'];
			} catch (e) { }

			if (isrunning)
				return true;

			return L.resolveDefault(callServiceList(netspeedtestConf), {})
				.then((res) => {
					try {
						return res[netspeedtestConf]['instances'][instance]['running'];
					} catch (e) { }

					return false;
				});
		});
}

function routerLibreSpeedUrl(port, ssl) {
	return (ssl === '1' ? 'https' : 'http') + '://' + window.location.hostname + ':' + port + '/';
}

function renderRouterLibreSpeedUrl(port, ssl) {
	const url = routerLibreSpeedUrl(port, ssl);

	return E('a', {
		'id': 'librespeed_server_url',
		'href': url,
		'target': '_blank',
		'rel': 'noopener noreferrer'
	}, [ url ]);
}

function renderServiceStatus(running) {
	return E('span', {
		'id': 'service_status',
		'style': 'color:%s;font-weight:bold'.format(running ? 'green' : 'red')
	}, [ instance + ' - ' + (running ? _('SERVER RUNNING') : _('SERVER NOT RUNNING')) ]);
}

function updateServiceStatus(nodes, running) {
	const view = nodes.querySelector('#service_status');

	if (view) {
		view.setAttribute('style', 'color:%s;font-weight:bold'.format(running ? 'green' : 'red'));
		dom.content(view, [ instance + ' - ' + (running ? _('SERVER RUNNING') : _('SERVER NOT RUNNING')) ]);
	}
}

return view.extend({
//	handleSaveApply: null,
//	handleSave: null,
//	handleReset: null,

	load() {
	return Promise.all([
		L.resolveDefault(getServiceStatus(), false),
		uci.load('netspeedtest'),
		uci.load('librespeed-go')
	]);
	},

	poll_status(nodes, stat) {
		updateServiceStatus(nodes, stat[0]);
	},

	render(data) {
		const isRunning = data[0];
		const port = uci.get('librespeed-go', 'config', 'listen_port') || '8989';
		const ssl = uci.get('librespeed-go', 'config', 'enable_tls') || '0';

		let m, s, o;

		m = new form.Map('netspeedtest', _('librespeed Server'));
		m.parsechain = [ netspeedtestConf, conf ];

		s = m.section(form.NamedSection, 'config', 'netspeedtest', _('librespeed Site Speed Test'));
		s.anonymous = true;

		o = s.option(form.Flag, 'librespeed_enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.DummyValue, '_librespeed_url', _('Router librespeed URL'));
		o.rawhtml = true;
		o.cfgvalue = function() {
			if (port === '0')
				return E('span', { 'style': 'color:red;font-weight:bold' }, [ _('Random port (port=0) is not supported.') ]);

			return renderRouterLibreSpeedUrl(port, ssl);
		};

		s = m.section(form.NamedSection, '_iframe');
		s.anonymous = true;
		s.render = function (section_id) {
			if (port === '0') {
				return E('div', { class: 'alert-message warning' }, [
					_('Random port (port=0) is not supported.'),
					E('br'),
					_('Change to a fixed port and try again.')
				]);
			};
			return E('iframe', {
				src: routerLibreSpeedUrl(port, ssl),
				style: 'width: 100%; min-height: 100vh; border: none; border-radius: 3px;'
			});
		};

		s = m.section(form.NamedSection, 'config', 'librespeed-go', _('librespeed Config'));
		s.uciconfig = conf;
		s.anonymous = true;

		o = s.option(form.DummyValue, '_librespeed_status', _('Status'));
		o.rawhtml = true;
		o.cfgvalue = function() {
			return renderServiceStatus(isRunning);
		};

		o = s.option(form.Value, 'listen_port', _('Listen Port'));
		o.datatype = 'port';
		o.default = 8989;
		o.rmempty = false;

		o = s.option(form.Flag, 'enable_http2', _('Enable HTTP2'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Flag, 'enable_tls', _('Enable TLS'));
		o.default = o.disabled;
		o.rmempty = false;
		o.retain = true;
		o.depends('enable_http2', '1');

		o = s.option(form.Value, 'tls_cert_file', _('TLS Cert file'));
		o.placeholder = '/etc/librespeed-go/cert.pem';
		o.rmempty = false;
		o.retain = true;
		o.depends('enable_tls', '1');

		o = s.option(form.Value, 'tls_key_file', _('TLS Key file'));
		o.placeholder = '/etc/librespeed-go/privkey.pem';
		o.rmempty = false;
		o.retain = true;
		o.depends('enable_tls', '1');

		return m.render().then(L.bind(function(view) {
			poll.add(L.bind(function() {
				return Promise.all([
					L.resolveDefault(getServiceStatus(), false)
				]).then(L.bind(this.poll_status, this, view));
			}, this), 3);

			return view;
		}, this));
	}
});
