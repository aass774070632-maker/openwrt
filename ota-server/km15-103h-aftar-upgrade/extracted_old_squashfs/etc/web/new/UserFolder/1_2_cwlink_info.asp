<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
a { font-style:normal; font-weight:normal; text-decoration:none; }
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	background-color: #ffffff;
}
-->
</style>

<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.js?version=<% mcr_getWebVersion(); %>"></script>

<script>

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function wireless_port_info()
{
	var enable = new Array();
	var secure = new Array();
	var wlan_ssidname = new Array();
	var mode = new Array();
	var i, j, keyTail;
	
	var activeUIFlag = 0xff;
	
	var maxPhyInf = '<% mcr_getCfgWireless("Wlan_MaxPhyInf"); %>';
	var maxSSID = '<% mcr_getCfgWireless("Wlan_MaxSSID"); %>';
	var nMaxPhyInf = parseInt( maxPhyInf, 10 );
	var nMaxSSID = parseInt( maxSSID, 10 );
/*	
	enable[0] = '<% mcr_getWlanLinkStatus(0); %>';
	enable[1] = '<% mcr_getWlanLinkStatus(1); %>';
	enable[2] = '<% mcr_getWlanLinkStatus(2); %>';
	enable[3] = '<% mcr_getWlanLinkStatus(3); %>';
	enable[4] = '<% mcr_getWlanLinkStatus(4); %>';
	enable[5] = '<% mcr_getWlanLinkStatus(100); %>';
	enable[6] = '<% mcr_getWlanLinkStatus(101); %>';
	enable[7] = '<% mcr_getWlanLinkStatus(102); %>';
	enable[8] = '<% mcr_getWlanLinkStatus(103); %>';
	enable[9] = '<% mcr_getWlanLinkStatus(104); %>';
*/	
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
	secure[4] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 4); %>';
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
			if(j==1 && i==1) {

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

	changeTable();
}
</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="initApp()">
<table width="800" border="0" cellspacing="0" cellpadding="10" bgcolor="#FFFFFF">
	<tr>
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">유선포트정보</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						<table class="TB" width="100%" border="0">
							<tr>
								<td>　</td>
								<td colspan="3" class="BG1" width="45%">현재 상태</td>
								<td colspan="4" class="BG1" width="45%">설정 상태</td>
							</tr>
							<tr>
								<td class="font2-1">포트이름</td>
								<td class="BG5">Link</td>
								<td class="BG5">Speed</td>
								<td class="BG5">Duplex</td>
								<td class="BG5">Auto Nego.</td>
								<td class="BG5">Speed</td>
								<td class="BG5">Duplex</td>
								<td class="BG5">Pause</td>
							</tr>
							<tr>
								<td class="BG2-CT">LAN1</td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(1,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(1,4); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(1,5); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(1,1); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(1,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(1,3); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(1,4); %></td>
							</tr>
							<tr>
								<td class="BG2-CT">LAN2</td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(2,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(2,4); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(2,5); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(2,1); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(2,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(2,3); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(2,4); %></td>
							</tr>
							<tr>
								<td class="BG2-CT">LAN3</td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(3,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(3,4); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(3,5); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(3,1); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(3,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(3,3); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(3,4); %></td>
							</tr>
							<tr>
								<td class="BG2-CT">LAN4</td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(4,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(4,4); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(4,5); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(4,1); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(4,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(4,3); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(4,4); %></td>
							</tr>
							<tr>
								<td class="BG2-CT">WAN</td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(0,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(0,4); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortStatus(0,5); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(0,1); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(0,2); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(0,3); %></td>
								<td class="BG2-2-3"><% mcr_getLanPortConfig(0,4); %></td>
							</tr>
							<tr>
								<td class="BG2-CT">WAN(USB)</td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortStatus(0,2); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortStatus(0,4); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortStatus(0,5); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortConfig(0,1); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortConfig(0,2); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortConfig(0,3); %></td>
								<td class="BG2-2-3"><% mcr_getUsbWanPortConfig(0,4); %></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5"> 무선포트정보</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						<table class="TB" width="100%" border="0">
							<tr>
								<td class="BG1" width="25%">무선랜명(SSID)</td>
								<td class="BG1">상태</td>
								<td class="BG1">인증모드</td>
								<td class="BG1">무선모드</td>
							</tr>
							
							<tr id="view_2g_ssid_100">
								<td class="BG2-CT"><label id="wlan_ssidname_100" name="wlan_ssidname_100"></label></td>
								<td class="BG2-2-3" name="enable_100" id="enable_100" value=""></td>
								<td class="BG2-2-3" name="secure_100" id="secure_100" value=""></td>
								<td class="BG2-2-3" name="mode_100" id="mode_100" value=""></td>
							</tr>
							
							<tr id="view_5g_ssid_0">
								<td class="BG2-CT"><label id="wlan_ssidname_0" name="wlan_ssidname_0"></label></td>
								<td class="BG2-2-3" name="enable_0" id="enable_0" value=""></td>
								<td class="BG2-2-3" name="secure_0" id="secure_0" value=""></td>
								<td rowspan="3" class="BG2-2-3" name="mode_0" id="mode_0" value=""></td>
							</tr>
							<tr id="view_5g_ssid_1">
								<td class="BG2-CT"><label id="wlan_ssidname_1" name="wlan_ssidname_1"></label></td>
								<td class="BG2-2-3" name="enable_1" id="enable_1" value=""></td>
								<td class="BG2-2-3" name="secure_1" id="secure_1" value=""></td>
							</tr>
							
							<tr id="view_5g_ssid_4" style="display:none">
								<td class="BG2-CT"><label id="wlan_ssidname_4" name="wlan_ssidname_4"></label></td>
								<td class="BG2-2-3" name="enable_4" id="enable_4" value=""></td>
								<td class="BG2-2-3" name="secure_4" id="secure_4" value=""></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
