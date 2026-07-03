<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">
</style>

<script language="javascript" type="text/javascript">

function remove_auth_cache() {
	if($.browser.msie) { 
		document.execCommand("ClearAuthenticationCache");
	}else{
		try {
			xml = new XMLHttpRequest();
			xml.open("GET", "PAGE FROM REALM TO LOGOUT", true, "", "logout"); 
			xml.send("");
			xml.abort();
		} catch(e) { return; }
	}
}

function logoff(){
	remove_auth_cache();
	document.form.action = "/goform/mcr_KTlogOut";
	document.form.submit();
}

function wireless_port_info()
{
	var enable = new Array();
	var secure = new Array();
	var wlan_ssidname = new Array();
	var mode = new Array();
	var i, j, keyTail;

	var activeUIFlag = 0xff;
	var projectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';
	var modelName = '<% mcr_getCfgCommon("DeviceInfo_ModelName"); %>';


	var maxPhyInf = '<% mcr_getCfgWireless("Wlan_MaxPhyInf"); %>';
	var maxSSID = '<% mcr_getCfgWireless("Wlan_MaxSSID"); %>';
	var nMaxPhyInf = parseInt( maxPhyInf, 10 );
	var nMaxSSID = parseInt( maxSSID, 10 );

	enable[0] = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
	enable[1] = '<% mcr_getCfgWireless("Wlan_Enable", 1); %>';
	enable[2] = '<% mcr_getCfgWireless("Wlan_Enable", 2); %>';
	enable[3] = '<% mcr_getCfgWireless("Wlan_Enable", 3); %>';
	enable[4] = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
	enable[5] = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';
	enable[6] = '<% mcr_getCfgWireless("Wlan_Enable", 101); %>';
	enable[7] = '<% mcr_getCfgWireless("Wlan_Enable", 102); %>';
	enable[8] = '<% mcr_getCfgWireless("Wlan_Enable", 103); %>';
	enable[9] = '<% mcr_getCfgWireless("Wlan_Enable", 104); %>';

	secure[0] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 0); %>';
	secure[1] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 1); %>';
	secure[2] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 2); %>';
	secure[3] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 3); %>';
	secure[4] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 3); %>';
	secure[5] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 100); %>';
	secure[6] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 101); %>';
	secure[7] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 102); %>';
	secure[8] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 103); %>';
	secure[9] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 104); %>';

	mode[0] = '<% mcr_getCfgWireless("Wlan_WirelessMode", 0); %>';
	mode[1] = '<% mcr_getCfgWireless("Wlan_WirelessMode", 100); %>';

	wlan_ssidname[0] = '<% mcr_getCfgWireless("Wlan_SSID", 0); %>';
	wlan_ssidname[1] = '<% mcr_getCfgWireless("Wlan_SSID", 1); %>';
	wlan_ssidname[2] = '<% mcr_getCfgWireless("Wlan_SSID", 2); %>';
	wlan_ssidname[3] = '<% mcr_getCfgWireless("Wlan_SSID", 3); %>';
	wlan_ssidname[4] = '<% mcr_getCfgWireless("Wlan_SSID", 4); %>';
	wlan_ssidname[5] = '<% mcr_getCfgWireless("Wlan_SSID", 100); %>';
	wlan_ssidname[6] = '<% mcr_getCfgWireless("Wlan_SSID", 101); %>';
	wlan_ssidname[7] = '<% mcr_getCfgWireless("Wlan_SSID", 102); %>';
	wlan_ssidname[8] = '<% mcr_getCfgWireless("Wlan_SSID", 103); %>';
	wlan_ssidname[9] = '<% mcr_getCfgWireless("Wlan_SSID", 104); %>';

	var nIfIndex, nArrayIndex, nBitIndex;
	for( i = 0; i < nMaxPhyInf; i++ ){
		nIfIndex = i*100;
		keyTail = "_"+nIfIndex;
		mode_format("mode"+keyTail, mode[i]);

		for( j = 0; j < 2; j++ ){
			if(j==1 && i==1){

			}else{
				nIfIndex = i*100+j;
				nArrayIndex = convertMultiSSIDIdxToArrayIndex(nMaxSSID, nIfIndex );
				nBitIndex = 1 << nArrayIndex;
				keyTail = "_"+nIfIndex;

				if( (activeUIFlag & nBitIndex) != 0 ){
					if( wlan_ssidname[nArrayIndex] == "KT_SoIP" ){
						changeLabelHTML("wlan_ssidname"+keyTail, "****");
					}else{
						changeLabelHTML("wlan_ssidname"+keyTail, convertSpaceToEscape(wlan_ssidname[nArrayIndex]));
					}
					enable_format("enable"+keyTail, enable[nArrayIndex]);
					security_format("secure"+keyTail, secure[nArrayIndex]);
				}
			}
		}
	}
}

function enable_format(id, wlanEnable) {
	if ( wlanEnable == "0" ) {
		document.getElementById(id).innerHTML = "비활성";
	} else if ( wlanEnable == "1" ) {
		document.getElementById(id).innerHTML = "활성";
	}
}
function security_format(id, wlanSecurityMode) {
	document.getElementById(id).innerHTML = conv2Str_WLAN_SecurityMode(wlanSecurityMode, null);
}
function mode_format(id, wlanMode) {
	if ( wlanMode == "1" ) {
		document.getElementById(id).innerHTML = "11b";
	} else if ( wlanMode == "2" ) {
		document.getElementById(id).innerHTML = "11g";
	} else if ( wlanMode == "3" ) {
		document.getElementById(id).innerHTML = "11b/g";
	} else if ( wlanMode == "4" ) {
		document.getElementById(id).innerHTML = "11n";
	} else if ( wlanMode == "6" ) {
		document.getElementById(id).innerHTML = "11g/n";
	} else if ( wlanMode == "7" ) {
		document.getElementById(id).innerHTML = "11b/g/n";
	} else if ( wlanMode == "8" ) {
		document.getElementById(id).innerHTML = "11a";
	} else if ( wlanMode == "12" ) {
		document.getElementById(id).innerHTML = "11a/n";
	} else if ( wlanMode == "16" ) {
		document.getElementById(id).innerHTML = "11ac";
	} else if ( wlanMode == "28" ) {
		document.getElementById(id).innerHTML = "11a/n/ac";
	} else if ( wlanMode == "32" ) {
		document.getElementById(id).innerHTML = "11ax";
	} else if ( wlanMode == "36" ) {
		document.getElementById(id).innerHTML = "11n/ax";
	} else if ( wlanMode == "38" ) {
		document.getElementById(id).innerHTML = "11g/n/ax";
	} else if ( wlanMode == "48" ) {
		document.getElementById(id).innerHTML = "11ac/ax";
	} else if ( wlanMode == "52" ) {
		document.getElementById(id).innerHTML = "11n/ac/ax";
	} else if ( wlanMode == "60" ) {
		document.getElementById(id).innerHTML = "11a/n/ac/ax";
	} else if ( wlanMode == "39" ) {
		document.getElementById(id).innerHTML = "11b/g/n/ax";
	} else {
		document.getElementById(id).innerHTML = "Unknown";
	}
}

function initApp() {
	wireless_port_info();
}

</script>

</head>
<body onload="initApp()">
<form name="form" data-ajax="false">
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<input type="button" value="로그아웃" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<input type="button" value="새로고침" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					유선 포트 정보
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>

	<div style="padding:0 5 12 5px;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td colspan="4" align="center">현재 상태</td>
						</tr>
						<tr>
							<td>포트이름</td>
							<td>Link</td>
							<td>Speed</td>
							<td>Duplex</td>
						</tr>
						<tr>
							<td>LAN1</td>
							<td><% mcr_getLanPortStatus(1,2); %></td>
							<td><% mcr_getLanPortStatus(1,4); %></td>
							<td><% mcr_getLanPortStatus(1,5); %></td>
						</tr>
						<tr>
							<td>LAN2</td>
							<td><% mcr_getLanPortStatus(2,2); %></td>
							<td><% mcr_getLanPortStatus(2,4); %></td>
							<td><% mcr_getLanPortStatus(2,5); %></td>
						</tr>
						<tr>
							<td>LAN3</td>
							<td><% mcr_getLanPortStatus(3,2); %></td>
							<td><% mcr_getLanPortStatus(3,4); %></td>
							<td><% mcr_getLanPortStatus(3,5); %></td>
						</tr>
						<tr>
							<td>LAN4</td>
							<td><% mcr_getLanPortStatus(4,2); %></td>
							<td><% mcr_getLanPortStatus(4,4); %></td>
							<td><% mcr_getLanPortStatus(4,5); %></td>
						</tr>
						<tr>
							<td>WAN</td>
							<td><% mcr_getLanPortStatus(0,2); %></td>
							<td><% mcr_getLanPortStatus(0,4); %></td>
							<td><% mcr_getLanPortStatus(0,5); %></td>
						</tr>
						<tr>
							<td>WAN(USB)</td>
							<td><% mcr_getUsbWanPortStatus(0,2); %></td>
							<td><% mcr_getUsbWanPortStatus(0,4); %></td>
							<td><% mcr_getUsbWanPortStatus(0,5); %></td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td colspan="5" align="center">설정 상태</td>
						</tr>
						<tr>
							<td>포트이름</td>
							<td>Auto Nego.</td>
							<td>Speed</td>
							<td>Duplex</td>
							<td>Pause</td>
						</tr>
						<tr>
							<td>LAN1</td>
							<td><% mcr_getLanPortConfig(1,1); %></td>
							<td><% mcr_getLanPortConfig(1,2); %></td>
							<td><% mcr_getLanPortConfig(1,3); %></td>
							<td><% mcr_getLanPortConfig(1,4); %></td>
						</tr>
						<tr>
							<td>LAN2</td>
							<td><% mcr_getLanPortConfig(2,1); %></td>
							<td><% mcr_getLanPortConfig(2,2); %></td>
							<td><% mcr_getLanPortConfig(2,3); %></td>
							<td><% mcr_getLanPortConfig(2,4); %></td>
						</tr>
						<tr>
							<td>LAN3</td>
							<td><% mcr_getLanPortConfig(3,1); %></td>
							<td><% mcr_getLanPortConfig(3,2); %></td>
							<td><% mcr_getLanPortConfig(3,3); %></td>
							<td><% mcr_getLanPortConfig(3,4); %></td>
						</tr>
						<tr>
							<td>LAN4</td>
							<td><% mcr_getLanPortConfig(4,1); %></td>
							<td><% mcr_getLanPortConfig(4,2); %></td>
							<td><% mcr_getLanPortConfig(4,3); %></td>
							<td><% mcr_getLanPortConfig(4,4); %></td>
						</tr>
						<tr>
							<td>WAN</td>
							<td><% mcr_getLanPortConfig(0,1); %></td>
							<td><% mcr_getLanPortConfig(0,2); %></td>
							<td><% mcr_getLanPortConfig(0,3); %></td>
							<td><% mcr_getLanPortConfig(0,4); %></td>
						</tr>
						<tr>
							<td>WAN(USB)</td>
							<td><% mcr_getUsbWanPortConfig(0,1); %></td>
							<td><% mcr_getUsbWanPortConfig(0,2); %></td>
							<td><% mcr_getUsbWanPortConfig(0,3); %></td>
							<td><% mcr_getUsbWanPortConfig(0,4); %></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
							
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
                <table width="100%">
                        <tr>
                                <td align="left" width="90%" style="font-weight:bold;">
                                        무선 포트 정보
                                </td>
                        </tr>
                </table>
        </div>
        <hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
        <div>
                <table>
                        <tr height="5"></tr>
                </table>
        </div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>무선랜명(SSID)</td>
							<td>상태</td>
							<td>인증모드</td>
							<td>무선모드</td>
						</tr>
						<tr>
							<td><label id="wlan_ssidname_100" name="wlan_ssidname_100"></label></td>
							<td name="enable_100" id="enable_100" value=""></td>
							<td name="secure_100" id="secure_100" value=""></td>
							<td rowspan="1" name="mode_100" id="mode_100" value=""></td>
						</tr>
						<tr style="display:none">
							<td><label id="wlan_ssidname_102" name="wlan_ssidname_102"></label></td>
							<td name="enable_102" id="enable_102" value=""></td>
							<td name="secure_102" id="secure_102" value=""></td>
						</tr>
						<tr style="display:none">
							<td><label id="wlan_ssidname_103" name="wlan_ssidname_103"></label></td>
							<td name="enable_103" id="enable_103" value=""></td>
							<td name="secure_103" id="secure_103" value=""></td>
						</tr>
                                                        
						<tr id="view_5g_ssid_0">
							<td><label id="wlan_ssidname_0" name="wlan_ssidname_0"></label></td>
							<td name="enable_0" id="enable_0" value=""></td>
							<td name="secure_0" id="secure_0" value=""></td>
							<td rowspan="2" name="mode_0" id="mode_0" value=""></td>
						</tr>
						<tr id="view_5g_ssid_1">
							<td><label id="wlan_ssidname_1" name="wlan_ssidname_1"></label></td>
							<td name="enable_1" id="enable_1" value=""></td>
							<td name="secure_1" id="secure_1" value=""></td>
						</tr>
						<tr id="view_5g_ssid_2" style="display:none">
							<td><label id="wlan_ssidname_2" name="wlan_ssidname_2"></label></td>
							<td name="enable_2" id="enable_2" value=""></td>
							<td name="secure_2" id="secure_2" value=""></td>
						</tr>
						<tr id="view_5g_ssid_3" style="display:none">
							<td><label id="wlan_ssidname_3" name="wlan_ssidname_3"></label></td>
							<td name="enable_3" id="enable_3" value=""></td>
							<td name="secure_3" id="secure_3" value=""></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="/mobile.asp#secondPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
