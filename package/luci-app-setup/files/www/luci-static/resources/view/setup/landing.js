'use strict';
'require view';
'require uci';

var DEFAULT_ADMIN_ROUTE = '/cgi-bin/luci/admin/status/overview';
var WIZARD_ROUTE = '/cgi-bin/luci/admin/applications/alemprator';
var WIZARD_BUILD_TAG = 'r120';
var REAL_OVERVIEW_ROUTE = '/cgi-bin/luci/admin/status/overview-real';

function buildAbsoluteUrl(route, buildTag) {
	var protocol = /^https?:$/.test(window.location.protocol || '') ? window.location.protocol : 'http:';
	var host = window.location.host || window.location.hostname;
	var url = protocol + '//' + host + route;

	if (buildTag)
		url += '?v=' + encodeURIComponent(buildTag);

	return url;
}

return view.extend({
	load: function() {
		return Promise.all([
			L.resolveDefault(uci.load('alemprator_firstboot'), null),
			L.resolveDefault(uci.load('setup'), null)
		]).then(function() {
			return {
				firstbootEnabled: uci.get('alemprator_firstboot', 'main', 'enabled') == '1',
				initialSetupComplete: uci.get('setup', 'default', 'initial_setup_complete') == '1'
			};
		});
	},

	render: function(state) {
		var target = (state && state.firstbootEnabled && !state.initialSetupComplete)
			? buildAbsoluteUrl(WIZARD_ROUTE, WIZARD_BUILD_TAG)
			: buildAbsoluteUrl(REAL_OVERVIEW_ROUTE);

		window.setTimeout(function() {
			window.location.replace(target);
		}, 0);

		return E('div', { 'class': 'cbi-map' }, [
			E('p', { 'class': 'spinning' }, _('جارٍ تحويلك إلى الصفحة المناسبة...'))
		]);
	},

	addFooter: function() {}
});