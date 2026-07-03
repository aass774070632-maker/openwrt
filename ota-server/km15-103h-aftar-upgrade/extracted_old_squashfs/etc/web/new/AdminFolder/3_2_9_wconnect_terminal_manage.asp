<html>
<head>
<%include('new/metatag.asp');%>
<title>무선 접속 단말 관리</title>
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

<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var maxStationCount = 0;
var arrData = new Array(); 
var aSSID = new Array();
var aSecurity = new Array();

var tableRule = null;

var nMaxSSID = 0;

function calcAssocTime(val){
	var nTime = parseInt( val, 10 );
	
	hour = Math.floor( nTime / 3600 );
	hourRemain = ( nTime % 3600 );
	
	min = Math.floor( hourRemain / 60 );
	minRemain = ( hourRemain % 60 );
	
	sec = minRemain;
	
	return ( ''+hour+'시간 '+ min+'분 '+sec+'초' );
}

function convEAPType(eapType, securityType){
	var securityStr = conv2Str_WLAN_SecurityMode( securityType, null )
	if( eapType == '-' ){
		return securityStr;
	}else if( eapType == '252' ){
		return 'MAC인증';
	}else if( eapType == '253' ){
		return '웹인증';
	}else{
		return 'EAP인증('+ securityStr +')';
	}
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
	arrCol[4] = convEAPType(items[13], aSecurity[ nMappingIdx ]);
	arrCol[5] = items[11];
	arrCol[6] = items[9];
	arrCol[7] = calcAssocTime( items[12] );
	arrCol[8] = "<input type='image' src='/images/BTN/BTN_09_2.gif?Sp2' width='31' height='24' border='0' id='"+btnName+"' name='"+btnName+"' value='"+items[2]+"'></input>";
	
	return arrCol;
}

function initTable(){
	var strTableAttr = "class='TB' width='100%' border='0' cellspacing='1' cellpadding='0'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "class='BG1'";
	var strTableTd = "class='BG2-2' style='word-break:break-all; padding-left:0px;' align='center'";
	
	tableRule = new MCRTable("view_stalist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
		strTableAttr,
		"",
		strTableTr, 
		"접속된단말이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선랜명(SSID)", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "접속ID", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "IP 주소", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "인증방식", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Tx bytes", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Rx bytes", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "Association 경과시간", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "접속제어", "", strTableTh, strTableTd, "");
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
		
		aSecurity[0] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 0); %>';
		aSecurity[1] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 1); %>';
		aSecurity[2] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 2); %>';
		aSecurity[3] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 3); %>';
		aSecurity[4] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 4); %>';
		aSecurity[5] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 100); %>';
		aSecurity[6] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 101); %>';
		aSecurity[7] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 102); %>';
		aSecurity[8] = '<% mcr_getCfgWireless("Wlan_SecurityMode", 103); %>';
		
		$("#wlanUIMenu20").removeClass("menu3rdNormal").addClass("menu3rdSelect");
		
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
	var menu_sel = 0;
	$("label[id^='wlanUIMenu']").each( function(){
		$(this).bind({
			mouseenter: function(){
				menu_sel = $( this ).hasClass('menu3rdSelect');
				$( this ).removeClass("menu3rdNormal menu3rdSelect").addClass("menu3rdMouse");
			},
			mouseleave: function(){
				if( menu_sel ){
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdSelect");
					menu_sel = 0;
				}else{
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdNormal");
				}
			}
		});
	});
	$(document).mjq_disableSelection();
	$("input[type='text']").mjq_disableInputEnter();
	
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
		$("#form_staInfo").submit();
		return false;
	});
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );
	
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

<body>
<form method="post" class="form_layout" id="form_staInfo" name="form_staInfo" action="/goform/mcr_KT_setWirelessStation">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>

<input type="hidden" id="maxStaCount" name="maxStaCount" value="" />
<input type="hidden" id="ssid" name="ssid" value="0" />

<input type="hidden" id="delmac" name="delmac" value="" />

<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_2_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">무선 접속 단말 관리</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td height="5" style="font-size:5px;">&nbsp;</td>
							</tr>
							<tr>
								<td>
									<div id="view_stalist"></div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
