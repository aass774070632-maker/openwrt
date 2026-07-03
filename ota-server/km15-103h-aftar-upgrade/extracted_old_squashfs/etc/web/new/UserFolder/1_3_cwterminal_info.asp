<html>
<head>
<%include('new/metatag.asp');%>
<title>유무선 연결 정보</title>
<%include('new/script.asp');%>

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

<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="javascript" type="text/javascript">

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
	}else if( items[3] =='5' ){
		arrCol[2] = "USB";
	}else{
		arrCol[2] = items[3];
		if( arrCol[2] == 'KT_SoIP' ){
			arrCol[2] = "SoIP";
		}else if( arrCol[2] == 'ollehWiFi ' ){
			arrCol[2] = "ollehWiFiBasic";
		} 
	}

        arrCol[3] = "<input type='image' src='/images/BTN/BTN_29.gif?Sp2' width='74' height='24' id='"+btnName+"' name='"+btnName+"' value='"+btnName+"' onclick='return onClick_Ping("+nRow+",\""+items[1]+"\");'>";
	arrCol[4] = "";
	
	return arrCol;
}

function initTable_dhcp(){
	var strTableAttr = "class='TB' id='connDeviceInfo' width='100%' border='0'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "class='BG1'";
	var strTableTd = "class='BG2-2'";
	
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
	tableRule_dhcp.addColumn(MCRColumn.TYPE_NORMAL, "결과", "", strTableTh, strTableTd+" width='100'"+" align='center'", "");
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
	
	arrCol[1] = items[2] + " (ch:"+aChannel[nMappingIdx]+")";
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
	var strTableAttr = "class='TB' width='100%' border='0'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "class='BG1'";
	var strTableTd = "class='BG2-2'";
	
	tableRule = new MCRTable("view_stalist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
		strTableAttr,
		"",
		strTableTr, 
		"접속된단말이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선랜명<br>(SSID)</br>", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC<br>주소</br>", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "RSSI", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rate", "", strTableTh, strTableTd, "");
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

	changeTable();
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

		$("#wlanRedirectPage").val("/new/UserFolder/1_3_cwterminal_info.asp");
		
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
	
	changeTable();
}

</script>

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
</script>
</head>

<body oncontextmenu="return false" onselectstart="return false">
<table width="800" border="0" cellspacing="0" cellpadding="10" bgcolor="#FFFFFF">
	<tr>
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">접속 단말 정보</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						
						<div id="view_dhcplist"></div>
						
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">무선 단말 정보</td>
					<td align="right" class="PD7">
						<input type="image" src="/images/BTN/BTN_13.gif?Sp2" width="71" height="24" value="wlanBtnRefresh" id="wlanBtnRefresh" name="wlanBtnRefresh">
					</td>
				</tr>
				<tr>
					<td colspan="2" class="PD4"></td>
				</tr>
				<tr>
					<td colspan="2" class="PD5"></td>
				</tr>
				<tr>
					<td colspan="2">
						<div id="view_stalist"></div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
