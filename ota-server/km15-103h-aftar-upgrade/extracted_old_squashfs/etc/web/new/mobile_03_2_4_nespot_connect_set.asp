<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.ui-btn-up-a {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #333;
	text-shadow: 0 1px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#dedede),to(#bebebe));
	background-image: -webkit-linear-gradient(#dedede,#bebebe);
	background-image: -moz-linear-gradient(#dedede,#bebebe);
	background-image: -ms-linear-gradient(#dedede,#bebebe);
	background-image: -o-linear-gradient(#dedede,#bebebe);
	background-image: linear-gradient(#dedede,#bebebe);
}



.ui-btn-active-a{
	border:1px solid #bbb;
	background:#bebebe;
	font-weight:bold;
	color:#333;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#bebebe),to(#9e9e9e));
	background-image:-webkit-linear-gradient(#bebebe,#9e9e9e);
	background-image:-moz-linear-gradient(#bebebe,#9e9e9e);
	background-image:-ms-linear-gradient(#bebebe,#9e9e9e);
	background-image:-o-linear-gradient(#bebebe,#9e9e9e);
	background-image:linear-gradient(#bebebe,#9e9e9e);
	font-family:Helvetica,Arial,sans-serif
}


.ui-btn-active-c{
	border:1px solid #bbb;
	background:#fff;
	font-weight:bold;
	color:#fff;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
	background-image:-webkit-linear-gradient(#f16045,#ec2427);
	background-image:-moz-linear-gradient(#f16045,#ec2427);
	background-image:-ms-linear-gradient(#f16045,#ec2427);
	background-image:-o-linear-gradient(#f16045,#ec2427);
	background-image:linear-gradient(#f16045,#ec2427);
	font-family:Helvetica,Arial,sans-serif
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
	document.form_security.action = "/goform/mcr_KTlogOut";
	document.form_security.submit();
}

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

<%
var gWlanSSIDIndexEJ;
if ( gWlanIfIndexEJ == '0' )
gWlanSSIDIndexEJ = '2';
else
gWlanSSIDIndexEJ = '102';
%>

if( gWlanIfIndex == '0' ){
	gWlanSSIDIndex = '2';
}else{
	gWlanSSIDIndex = '102';
}

var gUserPrivilege;

var maxCount = 0;
var arrData = new Array();
var tableRule = null;

var gKTSohoZoneMode;

var gWLANRedirectEnable;



function initForm_WLAN_Security(flag){
	var wlanSSIDIdx, wlanRadioActivity, cur_wlanSSID, wlanBroadSSID;
	var wlanSecurityMode, wlanEncType, wlanKeyType, wlanWEPPSKKey, wlanWEPDefaultKeyIndex, wlanWPAKeyRenewInterval;
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable;
	var wlanRedirectEnable, wlanRedirectURL;
	var raRedirectURL, refreshInterval, strWhiteList;
	var wauthPk, wauthURL_Login, wauthURL_Logout;

	if( flag == 0 ){
		wlanSSIDIdx = gWlanSSIDIndex;   

		wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';
		cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", gWlanSSIDIndexEJ); %>';
		wlanBroadSSID = '<% mcr_getCfgWireless("Wlan_BroadSSID", gWlanSSIDIndexEJ); %>';

		wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanSSIDIndexEJ); %>';
		wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanSSIDIndexEJ); %>';

		wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", gWlanSSIDIndexEJ); %>';
		wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanSSIDIndexEJ); %>';
		wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", gWlanSSIDIndexEJ); %>';

		wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", gWlanSSIDIndexEJ); %>';
		wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", gWlanSSIDIndexEJ); %>';
		wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", gWlanSSIDIndexEJ); %>';
		wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", gWlanSSIDIndexEJ); %>';

		wlanWPAKeyRenewInterval = '<% mcr_getCfgWireless("Wlan_WPARenewInterval", gWlanSSIDIndexEJ); %>';

		wlanWEPRekeyEnable = '<% mcr_getCfgWireless("Wlan_WepRekeyEnable", gWlanSSIDIndexEJ); %>';
		wlanMACAuthEnable = '<% mcr_getCfgWireless("Wlan_MacAuthEnable", gWlanSSIDIndexEJ); %>';

		wlanWMMEnable = '<% mcr_getCfgWireless("Wlan_WMMEnable", gWlanSSIDIndexEJ); %>';
		gWLANRedirectEnable = wlanRedirectEnable = '<% mcr_getCfgWireless("Wlan_RedirectEnable", gWlanSSIDIndexEJ); %>';
		wlanRedirectURL = '<% mcr_getCfgWireless("Wlan_RedirectURL"); %>';
		strWhiteList = '<% mcr_getCfgWireless("Wlan_RedirectWhitelist"); %>';
		wlanWauthPk = '<% mcr_getCfgWireless("Wlan_WAuthPk"); %>';
		wlanWauthURL_Login = '<% mcr_getCfgWireless("Wlan_WAuthRedirectURL_0"); %>';
		wlanWauthURL_Logout = '<% mcr_getCfgWireless("Wlan_WAuthRedirectURL_2"); %>';
	}

	gKTSohoZoneMode = '<% mcr_getCfgWireless("SysOperMode_KTSOHOZoneMode"); %>';
	if( gKTSohoZoneMode == '0' ){
		$("#wlanTitle").text("ollehWiFi(Basic) 접속 설정");
		$("#wlanWhitelistTitle").text("ollehWiFi(Basic) 웹 화이트 리스트 설정");
	}else if( gKTSohoZoneMode == '1' || gKTSohoZoneMode == '2' ){
		if( gKTSohoZoneMode == '1' ){
			$("#wlanTitle").text("ollehWiFi(Basic) 접속 설정");
			$("#wlanWhitelistTitle").text("ollehWiFi(Basic) 웹 화이트 리스트 설정");
		}else if( gKTSohoZoneMode == '2' ){
			$("#wlanTitle").text("olleh NAVER 접속 설정");
			$("#wlanWhitelistTitle").text("olleh NAVER 웹 화이트 리스트 설정");
		}

		$("#wlanViewWebRedirection").show();
		$("#wlanView_wauthEnable").show();
		$("#wlanView_wauthPk").show();
		$("#wlanView_wauthURL_Login").show();
		$("#wlanView_wauthURL_Logout").show();
		$("#wlanView_whitelist").show();
	}


	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	setwlanRadioActivity(wlanRadioActivity);
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);

	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
		$("#wlanWEPKey").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ){
		$("#wlanPSKKey").val(wlanWEPPSKKey);
	}
	$("#wlanWPAKeyRenewInterval").val(wlanWPAKeyRenewInterval);

	setwlanWEPKeyType(wlanKeyType);
	setwlanWEPKeyIndex(wlanWEPDefaultKeyIndex);
	$("#wlanUIWEPKey0").val(wlanWEPKey0);
	$("#wlanUIWEPKey1").val(wlanWEPKey1);
	$("#wlanUIWEPKey2").val(wlanWEPKey2);
	$("#wlanUIWEPKey3").val(wlanWEPKey3);

	setwlanWEPRekeyEnable(wlanWEPRekeyEnable);
	setwlanMACAuthEnable(wlanMACAuthEnable);
	setwlanWMMEnable(wlanWMMEnable);

	$("#wlanRedirectURL").val(wlanRedirectURL);

	$("#wlanWauthPk").val(wlanWauthPk);
	$("#wlanWauthURL_Login").val(wlanWauthURL_Login);
	$("#wlanWauthURL_Logout").val(wlanWauthURL_Logout);

	if( wlanRedirectEnable == '0' ){                
		setwlanRedirectSet('0');
		setwlanWauthEnable('0');
	}else if( wlanRedirectEnable == '1' ){  
		setwlanRedirectSet('1');
		setwlanWauthEnable('0');
	}else if( wlanRedirectEnable == '2' ){  
		setwlanRedirectSet('1');
		setwlanWauthEnable('1');
	}else if( wlanRedirectEnable == '3' ){  
		setwlanRedirectSet('1');
		setwlanWauthEnable('1');
	}

	parseWhitelist(strWhiteList);
	layoutStationList();


	$("label[for='m_wlanUISecurityType1']").show();
	$("input[id='m_wlanUISecurityType1']").show();

	$("label[for='m_wlanUISecurityType4']").show();
	$("input[id='m_wlanUISecurityType4']").show();

	cfg2web_mobile_WLAN_Security();
	initTextById("KTSohoZoneMode", gKTSohoZoneMode);

}


$(document).ready(function(){
	
	$("#wlanUIWPAKeyRenewalEnable").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable(null);
	});

	$("#wlanBtnSecurity").bind( "click", function(){
		$("#wlanSSID").val($("#cur_wlanSSID").val());
		if(!validateOnSubmit())
			return false;
		$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
		$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessSecurity');

	});

	$("#btn_add").bind( "click", function(){
		if( onClickAdd() == false ) return false;

		if( validateOnSubmit_applyWhiteList() == true ){
			$('a[name=btn_add]').removeClass('ui-btn-active');
			$('a[name=btn_add]').addClass('ui-btn-active-a');
			form_act('/goform/mcr_KT_setWirelessWebRedirect');
		}
		return false;
	});
	$("#btn_del").bind( "click", function(){
		onButtonDel();

		if( validateOnSubmit_applyWhiteList() == true ){
			$('a[name=btn_del]').removeClass('ui-btn-active');
			$('a[name=btn_del]').addClass('ui-btn-active-a');
			form_act('/goform/mcr_KT_setWirelessWebRedirect');
		}
		return false;
	});
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(0);
	});
	$("input[name='check_box_1']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(1);
	});

	initValue();
});

function validateOnSubmit(){
	var ret = validateOnSubmit_WLAN_mobile_SecurityType();
	if( ret == true &&
		(gWLANRedirectEnable == '2' || gWLANRedirectEnable =='3') ){
		ret = validateOnSubmit_wauth();
	}
	return ret;
}

function initForms(flag){
	initForm_WLAN_Security(flag);
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function checkWirelessActivity(){
	var bInactive = false;
	var radioActivity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanIfIndexEJ); %>';	
	var gWanOperMode = 	'<% mcr_getCfgWireless("Wlan_WanOperMode"); %>';
	if( radioActivity == '0' ){
		if( gWlanIfIndex == '0' ){
			alert("5Ghz Root Ssid가 비활성화 상태입니다.");
		}else{
			alert("2.4Ghz Root Ssid가 비활성화 상태입니다.");
		}
		$("input[name='m_wlanRadioActivity']").attr("disabled", "disabled");
		$("#wlanBtnSecuritybutton").hide();
		return false;
	}
	if( gWanOperMode != '0' ){
		if( gWlanSSIDIndex == '1' || gWlanSSIDIndex == '101' ){
			alert("리피터 모드 설정 시 Roaming설정을 할 수 없습니다.");
			bInactive = true;
		}else if( gWlanSSIDIndex == '2' || gWlanSSIDIndex == '102' ){
			alert("리피터 모드 설정 시 ollehWiFi(Basic)설정을 할 수 없습니다.");
			bInactive = true;
		}else if( gWlanSSIDIndex == '3' || gWlanSSIDIndex == '103' ){
			alert("리피터 모드 설정 시 ollehWiFi설정을 할 수 없습니다.");
			bInactive = true;
		}
	}
	if( bInactive || gUserPrivilege == "3" || gUserPrivilege == "1" ){
		$("input[type='radio']").attr("disabled", "disabled");
		$("input[type='text']").attr("disabled", "disabled");
		$("input[type='password']").attr("disabled", "disabled");
		$("input[type='checkbox']").attr("disabled", "disabled");
		$("#wlanBtnSecuritybutton").hide();
		return false;
	}	
	return true;
}

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );


	vendor_init();
	initForms(0);

	checkWirelessActivity();
}


function validateInputTextForm(){
	var ret = true;
	var arrTextForm = new Array("whiteAddr", "raRedirectURL", "refreshInterval");

	ret = checkKoreanTextFormArray(arrTextForm);
	if( ret == false ){
		alert( "한글은 입력할 수 없습니다" );
	}
	return ret;
}


function validateOnSubmit_applyWhiteList(){
	var strSaveWhiteList = "";
	var first = 1;

	for( var i=0; i<maxCount; i++ ){
		var e = document.getElementById("dellist_"+i);
		if( e != null && e.checked == false ){
			if( first != 1 ){
				strSaveWhiteList+=";";
			}
			strSaveWhiteList+=arrData[i];
			first = 0;
		}
	}

	initTextById("saveWhiteList", strSaveWhiteList);

	return validateInputTextForm();
}


function checkWhitelistLen(addValue){
	var strWhiteList = "";

	for( var i=0; i<maxCount; i++ ){
		strWhiteList+=arrData[i];
		strWhiteList+=";";
	}
	strWhiteList+=addValue;

	if( strWhiteList.length > 1780 ){       
		return false;
	}

	return true;
}


function onButtonDel(){
	if( maxCount > 0 ){
		var strWhiteList = "";

		for( var i=0; i<maxCount; i++ ){
			var e = document.getElementById("dellist_"+i);
			if( e != null && e.checked == false ){
				strWhiteList+=arrData[i];
				strWhiteList+=";";
			}
		}

		parseWhitelist(strWhiteList);

		layoutStationList();
	}
}


function onClickSelectAll(){
	if( maxCount > 0 ){
		var e = document.getElementById("btn_selectAll");
		var newChecked = e.checked;

		for( var row = 0; row < maxCount; row++ ){
			var strElementName = "dellist_"+row;
			initCheckboxById(strElementName, newChecked);
		}
	}
}


function onClickAdd(){
	var e = document.getElementById("whiteAddr");
	var bDuplicated = false;


	if( maxCount > 100 ){
		alert("설정 최대수를 초과했습니다");
		return false;
	}

	for( var i=0; i<maxCount; i++ ){
		if( arrData[i] == e.value ){
			bDuplicated = true;
		}
	}
	if( bDuplicated ){
		alert("중복된 항목이 있습니다");
		return false;
	}

	if( checkWhitelistLen(e.value) == false ){
		alert("설정 최대수를 초과했습니다");
		return false;
	}

	for( var idx = maxCount; idx >= 1; idx-- ){
		arrData[idx] = arrData[idx-1];
	}
	arrData[0] = e.value;
	maxCount++;

	layoutStationList();

	return true;
}


function parseWhitelist(strWhiteList){
	var arrList = strWhiteList.split(";");

	maxCount = 0;
	arrData = new Array();
	for( var i = 0; i < arrList.length; i++ ){
		if( arrList[i].length > 0 ){
			arrData[maxCount] = arrList[i];
			maxCount++;
		}
	}
}


function parseData(nRow, aColumns, aRow, strSplit){
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;

	if( aColumns[0].type & MCRColumn.TYPE_CHECKBOX ){
		var aCheckElement = new Array(2);
		aCheckElement[0] = aColumns[0].name+"_"+nRow;   
		aCheckElement[1] = "1"; 

		arrCol[0] = aCheckElement;
		nOffset = 1;
	}

	arrCol[1] = aRow;

	return arrCol;
}


function initTable(){
	var strTableAttr = "align='center' border='0' cellspacing='0' cellpadding='0' width='100%' valign='middle' id='Grid_Table' style='table-layout:fixed;''";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "style=word-break:break-all";

	tableRule = new MCRTable("view_whitelist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"화이트 리스트 정보가 없습니다", "", parseData );
	tableRule.addColumn(MCRColumn.TYPE_CHECKBOX, "dellist", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "도메인", "", strTableTh, strTableTd, "");
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

function validateOnSubmit_wauth(){
	var wlanWauthPk = $("#wlanWauthPk").val();
	if( isEmpty(wlanWauthPk) || wlanWauthPk.length != 16 ){
		alert("Web인증 Key가 부적절합니다");
		$("#wlanWauthPk").focus();
		return false;
	}

	var wlanWauthURL_Login = $("#wlanWauthURL_Login").val();
	if( isEmpty(wlanWauthURL_Login) ){
		alert("Web인증 Login URL이 부적절합니다");
		$("#wlanWauthURL_Login").focus();
		return false;
	}
	var wlanWauthURL_Logout = $("#wlanWauthURL_Logout").val();
	if( isEmpty(wlanWauthURL_Logout) ){
		alert("Web인증 Logout URL이 부적절합니다");
		$("#wlanWauthURL_Logout").focus();
		return false;
	}
	var wlanRedirectURL = $("#wlanRedirectURL").val();
	if( isEmpty(wlanRedirectURL) ){
		alert("Redirect URL이 부적절합니다");
		$("#wlanRedirectURL").focus();
		return false;
	}

	if( gKTSohoZoneMode == '1' || gKTSohoZoneMode == '2' ){
		var wlanRedirectSet = $("input[name='wlanRedirectSet']").val();
		var wlanWauthEnable = $("input[name='wlanWauthEnable']").val();
		if( wlanRedirectSet == '0' && wlanWauthEnable == '0' ){
			$("#wlanRedirectEnable").val('0');
		}else if( wlanRedirectSet == '0' && wlanWauthEnable == '1' ){
			alert("Web인증 사용시 Web Redirect를 해제할 수 없습니다");
			return false;
		}else if( wlanRedirectSet == '1' && wlanWauthEnable == '0' ){
			$("#wlanRedirectEnable").val('1');
		}else if( wlanRedirectSet == '1' && wlanWauthEnable == '1' ){
			if( gKTSohoZoneMode == '1' ){
				$("#wlanRedirectEnable").val('2');
			}else if( gKTSohoZoneMode == '2' ){
				$("#wlanRedirectEnable").val('3');
			}
		}
	}else{
		$("#wlanRedirectEnable").val('0');
	}

	return true;
}

function form_act(url){
	form_security.action = url;
	form_security.submit();
	return false;
}

</script>

</head>
<body>
<form method="post" name="form_security" data-ajax="false">


<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="">
<input type="hidden" id="wlanSSID" name="wlanSSID" value="">

<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value="">
<input type="hidden" id="wlanBroadSSID" name="wlanBroadSSID" value="">
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value="">
<input type="hidden" id="wlanEncType" name="wlanEncType" value="">
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value="">
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value="">
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value="">

<input type="hidden" id="saveWhiteList" name="saveWhiteList" value="">
<input type="hidden" id="wlanRedirectEnable" name="wlanRedirectEnable" value="">

<input type="hidden" id="KTSohoZoneMode" name="KTSohoZoneMode" value="">

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
					ollehWiFi(Basic) 접속 설정
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
		<%include('new/mobile_wlan_security_common.asp');%>
	</div>
	<div id="wlanBtnSecuritybutton" style="padding:10px 0 0 0;">
		<input type="button" value="적용" id="wlanBtnSecurity" name="wlanBtnSecurity" data-theme="d" data-mini="false" data-ajax="false">
	</div>
	<div id="wlanView_whitelist" style="padding:0 5 12 5px; display:none;" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td><label id="wlanWhitelistTitle">ollehWiFi(Basic) 웹 화이트 리스트 설정</label></td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>도메인 추가</td>
							<td>
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td>
											<input type="text" name="whiteAddr" id="whiteAddr">
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<a href="javascript:;" id="btn_add" name="btn_add" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<tr>
										<td>
											<input type="checkbox" value="1" id="btn_selectAll" name="btn_selectAll" onclick="onClickSelectAll()" data-role="none">선택
										</td>
									</tr>
								</span>
							</td>
						</tr>
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<div id="view_whitelist"></div>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:;" id="btn_del" name="btn_del" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
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
