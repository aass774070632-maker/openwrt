<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<%include('new/script.asp');%>

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">
#scroll_wrap {
	width: device-width;
	overflow-x: scroll;
	scroll-behavior:smooth;
}
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

var maxStationCount = 0;
var arrData = new Array();
var aSSID = new Array();
var aChannel = new Array();
var tableRule = null;
var nMaxSSID = 0;

var arrData_dhcp = new Array();         
var tableRule_dhcp = null;                      

var sel_nrow;

function parseData_dhcp(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var btnName = "ping_"+nRow;

	arrCol[0] = items[0];
	arrCol[1] = items[1];
	if( items[3] =='1' || items[3]=='2' || items[3] == '3' || items[3] =='4' ){
		arrCol[2] = "LAN"+items[3];
	} else if( items[3] =='5' ){
		arrCol[2] = "USB";
	}else{
		arrCol[2] = items[3];
		if( arrCol[2] == 'KT_SoIP' ){
			arrCol[2] = "SoIP";
		}else if( arrCol[2] == 'ollehWiFi ' ){
			arrCol[2] = "ollehWiFiBasic";
		}
	}

	arrCol[3] = "<input type='image' src='/images/BTN/BTN_29.gif' id='"+btnName+"' name='"+btnName+"' value='"+btnName+"' onclick='return onClick_Ping("+nRow+",\""+items[1]+"\");'></input>";
	arrCol[4] = "";

	return arrCol;
}


function initTable_dhcp(){
	var strTableAttr = "id='connDeviceInfo' align=center cellspacing=0 cellpadding=0 width=100% valign=middle";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "width='20%' style=word-break:break-all";

	tableRule_dhcp = new MCRTable("view_dhcplist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
			strTableAttr,
			"",
			strTableTr,
			"접속된단말이 없습니다", ",", parseData_dhcp );
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "", strTableTh, strTableTd+" align='center'", "");
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "IP 주소", "", strTableTh, strTableTd+" align='center'", "");
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "포트정보", "", strTableTh, strTableTd+" align='center'", "");
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "핑테스트", "", strTableTh, strTableTd+" align='center'", "");
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "결과", "", strTableTh, strTableTd+" align='center'", "");
}

function layoutStationList_dhcp(){
	if( tableRule_dhcp == null ){
		initTable_dhcp();
	}
	if( tableRule_dhcp != null ){
		tableRule_dhcp.setRows(arrData_dhcp);
		tableRule_dhcp.layout();
	}
}

function process_dhcp_info(strResponse){
	var lineArr = strResponse.split(";;");

	arrData_dhcp.length = 0;

	for( var row=0; row < lineArr.length; row++){
		if( lineArr[row].length > 1 ){
			arrData_dhcp[row] = lineArr[row];
		}
	}

	initForms(2);
}

function calcAssocTime(val){
	var nTime = parseInt( val, 10 );

	hour = Math.floor( nTime / 3600 );
	hourRemain = ( nTime % 3600 );

	min = Math.floor( hourRemain / 60 );
	minRemain = ( hourRemain % 60 );

	sec = minRemain;

	return ( ''+hour+'시간 '+ min+'분 '+sec+'초' );
}

function calcRssiToDBm(mode, ssidIndex, rssi){
	if( rssi < 0) return rssi;

	dbm = 0
	if( ssidIndex >= 100 ){
		if( mode == 'B' ){
			if( rssi > 36 )
				dbm = ( (rssi - 91.463 - 11.385*2 ) / (11.385/10) )
			else if( rssi > 20 && rssi <= 36)
				dbm = ( (rssi - 53.325 - 17.1*6 ) / (17.1/10) )
			else
				dbm = ( (rssi - 27.45 - 8.325*7 ) / (8.325/10) )
		}else if( mode == 'G' ){
			if( rssi > 35 )
				dbm = ( (rssi - 85.388 - 10.395*2 ) / (10.395/10) )
			else if( rssi > 15 && rssi <= 35 )
				dbm = ( (rssi - 53.325 - 19.8*6 ) / (19.8/10) )
			else
				dbm = ( (rssi - 16.65 - 2.925*7 ) / (2.925/10) )
		}else{
			dbm = ( (rssi - 85.661 - 10.358*2 ) / (10.358/10) )
		}
	}else{
		if( mode == 'A' )
			dbm = ( (rssi - 81.929 - 10.277*2 ) / (10.277/10) )
		else
			dbm = ( (rssi - 86.107 - 10.357*2 ) / (10.357/10) )
	}
	return parseInt(dbm);
}

function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;
	var nMappingIdx = convertMultiSSIDIdxToArrayIndex(nMaxSSID, parseInt(items[0], 10));

	var btnName = "delmac_"+nRow;
	arrCol[0] = convertSpaceToEscape( aSSID[ nMappingIdx ] );       
	if( arrCol[0] == 'KT_SoIP' ){
		arrCol[0] = "SoIP";
	}else if( arrCol[0] == 'ollehWiFi&nbsp;' ){
		arrCol[0] = "ollehWiFiBasic";
	}

	arrCol[1] = items[2];
	arrCol[2] = calcRssiToDBm( items[5], parseInt(items[0], 10), parseInt(items[7], 10) );
	arrCol[3] = items[6];
	arrCol[4] = items[10];
	arrCol[5] = items[11];
	arrCol[6] = items[8];
	arrCol[7] = items[9];
	arrCol[8] = calcAssocTime( items[12] );

	if( items[14] == '0' ){
		arrCol[9] = "-";
	}else{
		arrCol[9] = items[14] + "SS";
	}
	if( items[15] == '255' ){
		arrCol[10] = "-";
	}else{
		arrCol[10] = items[15];
	}
	return arrCol;
}


function initTable(){
	var strTableAttr = "align=center cellspacing=0 cellpadding=0 width=100% valign=middle";
	var strTableTr = "";
	var strTableTh = "style=word-break:break-all";
	var strTableTd = "style=word-break:break-all";

	tableRule = new MCRTable("view_stalist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
			strTableAttr,
			"",
			strTableTr,
			"접속된단말이 없습니다", "\r", parseData );

	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선랜명<br>(SSID)</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC <br>주소</br>", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "RSSI", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rate", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Tx <br>packets</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Tx <br>bytes</br>", "", strTableTh, strTableTd+" align='center'", "");


	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rx <br>packets</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rx <br>bytes</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Association <br>경과시간</br>", "", strTableTh, strTableTd+" align='center'", "");

	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MU Stream <br>개수</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MU Group <br>ID</br>", "", strTableTh, strTableTd+" align='center'", "");
}

function layoutStationList(){
	if( tableRule == null ){
		initTable();
	}
	if( tableRule != null ){
		tableRule.setRows(arrData);
		tableRule.layout();
	}
}

function processHttpResponse(strResponse){
	var maxStationCount = 0;
	var rowOnly = 0;
	var lineArr = strResponse.split("\n");

	arrData.length = 0;

	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 1 ){
			arrData[row] = lineArr[row+rowOnly];
			maxStationCount++;
		}
	}

	initTextById("maxStaCount", ""+maxStationCount);

	initForms(1);
}

function updateFormValue(useDefault){
	if( useDefault == 1 ){
		layoutStationList();
	}else if( useDefault == 2 ){
		layoutStationList_dhcp();
	}

}

function initForms(flag){
	if( flag == 0 ){
		var maxSSID = '<% mcr_getCfgWireless("Wlan_MaxSSID", -1); %>';
		nMaxSSID = parseInt(maxSSID);

		aSSID[0] = '<% mcr_getCfgWireless("Wlan_SSID", 0); %>';
		aSSID[1] = '<% mcr_getCfgWireless("Wlan_SSID", 1); %>';
		aSSID[2] = '<% mcr_getCfgWireless("Wlan_SSID", 2); %>';
		aSSID[3] = '<% mcr_getCfgWireless("Wlan_SSID", 3); %>';
		aSSID[4] = '<% mcr_getCfgWireless("Wlan_SSID", 4); %>';
		aSSID[5] = '<% mcr_getCfgWireless("Wlan_SSID", 100); %>';
		aSSID[6] = '<% mcr_getCfgWireless("Wlan_SSID", 101); %>';
		aSSID[7] = '<% mcr_getCfgWireless("Wlan_SSID", 102); %>';
		aSSID[8] = '<% mcr_getCfgWireless("Wlan_SSID", 103); %>';

		channel_5G = '<% mcr_getCfgWireless("Wlan_active_channelString", 0); %>';
		channel_2G = '<% mcr_getCfgWireless("Wlan_active_channelString", 100); %>';
		channel_5G_array = channel_5G.split(/[/+ ]+/);
		channel_2G_array = channel_2G.split(/[/+ ]+/);

		aChannel[0] = channel_5G_array[0];
		aChannel[1] = channel_5G_array[0];
		aChannel[2] = channel_5G_array[0];
		aChannel[3] = channel_5G_array[0];
		aChannel[4] = channel_5G_array[0];
		aChannel[5] = channel_2G_array[0];
		aChannel[6] = channel_2G_array[0];
		aChannel[7] = channel_2G_array[0];
		aChannel[8] = channel_2G_array[0];

		$("#wlanRedirectPage").val("/new/mobile_01_3_cwterminal_info.asp");

		$("#wlanBtnRefresh").trigger("click");

		process_dhcp_info( "<% mcr_getDhcpProxyBindInfo(); %>" );
	}else if( flag == 1 ){
		updateFormValue(flag);
	}else if( flag == 2 ){
		updateFormValue(flag);
	}
}

function onClick_WLAN_refreshStation(){
	httpRequest("/goform/mcr_KT_getWirelessStation", ''+0x3ff, processHttpResponse);
}

function onClick_Ping(sel_row, ip_value) {
	var objTable = document.getElementById('connDeviceInfo');
	sel_nrow = sel_row+1;
	objTable.rows[sel_nrow].cells[4].innerHTML = "";                        
	httpRequest("/goform/mcr_connDevicePing?check_ip="+ip_value, "n/a", processHttpResponsePingCheck, processHttpError);
	return false;
}
function processHttpResponsePingCheck(strResponse) {
	var objTable = document.getElementById('connDeviceInfo');

	if (strResponse == '0') {
		objTable.rows[sel_nrow].cells[4].innerHTML = "응답없음"; 
	} else if (strResponse == '1') {
		objTable.rows[sel_nrow].cells[4].innerHTML = "정상"; 
	}
}
function processHttpError() {
	var objTable = document.getElementById('connDeviceInfo');
	objTable.rows[sel_nrow].cells[4].innerHTML = "PING 실패";
}

$(document).ready(function(){
	$("#wlanBtnRefresh").bind( "click", function(){
		return onClick_WLAN_refreshStation();
	});

	initValue();
});


function initValue(){
	initForms(0);
}

</script>

</head>
<body onload="initValue()">
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
					접속 단말 정보
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

	<div style="padding:0 5 12 5px;" id="scroll_wrap">
		<table align="center" cellspacing="0" cellpadding="0" width="210%" valign="middle">
			<tr>
				<td>
					<div id="view_dhcplist"></div>
				</td>
			</tr>
		</table>
	</div>
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>무선 단말 정보</td>
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
					<input type="button" value="Refresh" id="wlanBtnRefresh" name="wlanBtnRefresh">
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" id="scroll_wrap">
		<table align="center" cellspacing="0" cellpadding="0" width="260%" valign="middle">
			<tr>
				<td>
					<div id="view_stalist"></div>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#secondPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
