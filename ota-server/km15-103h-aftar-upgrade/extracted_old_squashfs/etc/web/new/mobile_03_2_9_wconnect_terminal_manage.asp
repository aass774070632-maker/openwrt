<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="javascript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="javascript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
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
	document.form_staInfo.action = "/goform/mcr_KTlogOut";
	document.form_staInfo.submit();
}

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var maxStationCount = 0;
var arrData = new Array();
var aSSID = new Array();
var aSecurity = new Array();

var tableRule = null;

var nMaxSSID = 0;

var gUserPrivilege;


function calcAssocTime(val){
	var nTime = parseInt( val, 10 );

	hour = Math.floor( nTime / 3600 );
	hourRemain = ( nTime % 3600 );

	min = Math.floor( hourRemain / 60 );
	minRemain = ( hourRemain % 60 );

	sec = minRemain;

	return ( ''+hour+'시간 '+ min+'분 '+sec+'초' );
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
	if( items[4] == 'MAC' ){
		arrCol[1] = items[2];
	}else{
		arrCol[1] = items[4];
	}
	arrCol[2] = items[2];
	arrCol[3] = items[3];
	arrCol[4] = conv2Str_WLAN_SecurityMode( aSecurity[ nMappingIdx ], null );
	arrCol[5] = items[11];
	arrCol[6] = items[9];
	arrCol[7] = calcAssocTime( items[12] );
	arrCol[8] = "<input type='image' src='/images/BTN/BTN_09_2.gif' border='0' id='"+btnName+"' name='"+btnName+"' value='"+items[2]+"'></input>";

	return arrCol;
}

function initTable(){
	var strTableAttr = "align='center' cellspacing='0' cellpadding='0' width='100%' valign='middle'";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "style='word-break:break-all; padding-left:0px;' align='center'";

	tableRule = new MCRTable("view_stalist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
			strTableAttr,
			"",
			strTableTr,
			"접속된단말이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선랜명(SSID)", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "접속ID", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "IP 주소", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "인증방식", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Tx bytes", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rx bytes", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Association 경과시간", "", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "접속제어", "", strTableTh, strTableTd+" align='center'", "");
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
	layoutStationList();

	refreshEventHandler();
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

		aSecurity[0] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 0); %>';
		aSecurity[1] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 1); %>';
		aSecurity[2] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 2); %>';
		aSecurity[3] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 3); %>';
		aSecurity[4] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 4); %>';
		aSecurity[5] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 100); %>';
		aSecurity[6] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 101); %>';
		aSecurity[7] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 102); %>';
		aSecurity[8] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 103); %>';


		onClick_WLAN_refreshStation();
	}else if( flag == 1 ){
		updateFormValue(0);
	}
}

function onClick_WLAN_refreshStation(){
	var target = 0;
	if( gWlanIfIndex == '0' ){
		targetSSID = ''+0x01f;
	}else{
		targetSSID = ''+0x3e0;
	}
	httpRequest("/goform/mcr_KT_getWirelessStation", targetSSID, processHttpResponse);
}

$(document).ready(function(){
	initValue();
});

function refreshEventHandler(){
	$("input[name*='delmac_']").bind( "click", function(event){
		var targetName = event.target.name;

		var targetInfo = targetName.split("_");
		var rowNo = targetInfo[1];
		var rowInfo = arrData[ rowNo ].split("\r");
		var ssidIdx = rowInfo[0];

		$("#ssid").val( ssidIdx );
		$("#delmac").val( event.target.value );

		form_staInfo.action = '/goform/mcr_KT_setWirelessStation';
		form_staInfo.submit();

		return false;
	});
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	vendor_init();
	initForms(0);
}

</script>

</head>
<body>
<form method="post" name="form_staInfo" data-ajax="false">


<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="">


<input type="hidden" id="maxStaCount" name="maxStaCount" value="">
<input type="hidden" id="ssid" name="ssid" value="0">

<input type="hidden" id="delmac" name="delmac" value="">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
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
					무선 접속 단말 관리
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
					<div id="view_stalist"></div>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
