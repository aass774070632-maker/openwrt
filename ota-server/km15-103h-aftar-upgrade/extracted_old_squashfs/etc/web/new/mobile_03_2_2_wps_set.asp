<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">
<%include('new/script.asp');%>

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>"></script>

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

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
<%
        var gWlanSSID2ndIndexEJ;
        if ( gWlanIfIndexEJ == '0' )
                gWlanSSID2ndIndexEJ = '0';
        else
                gWlanSSID2ndIndexEJ = '100';
%>

var gUserPrivilege;

function initForm_WLAN_WPS(flag){
	var wlanUserPriority;
	var wlanWPSActivity, wlanWPSMode;
	var wlanSSIDIdx, wlanUIPINSelf, wlanUIConfigured;

	var wlanSSID_0, wlanSecurityMode_0, wlanEncType_0, wlanWEPPSKKey_0;
	var wlanSSID_1, wlanSecurityMode_1, wlanEncType_1, wlanWEPPSKKey_1;

	if( flag == 0 ){
		wlanUserPriority = '7'; 
		wlanWPSActivity = '<% mcr_getCfgWireless("Wlan_Wps_WpsEnable", gWlanIfIndexEJ); %>';
		wlanWPSMode = '<% mcr_getCfgWireless("Wlan_Wps_WpsMode", gWlanIfIndexEJ); %>';
		wlanSSIDIdx = '<% mcr_getCfgWireless("Wlan_Wps_SSIDIdx", gWlanIfIndexEJ); %>';
		wlanUIPINSelf = '<% mcr_getCfgWireless("Wlan_Wps_PINSelf", gWlanIfIndexEJ); %>';
		wlanUIConfigured = '<% mcr_getCfgWireless("Wlan_Wps_Configured", gWlanIfIndexEJ); %>';

		wlanSSID_0 = '<% mcr_getCfgWireless("Wlan_SSID", gWlanIfIndexEJ); %>';
		wlanSecurityMode_0 = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
		wlanEncType_0 = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>';
		wlanWEPPSKKey_0 = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanIfIndexEJ); %>';

		wlanSSID_1 = '<% mcr_getCfgWireless("Wlan_SSID", gWlanSSID2ndIndexEJ); %>';
		wlanSecurityMode_1 = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanSSID2ndIndexEJ); %>';
		wlanEncType_1 = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanSSID2ndIndexEJ); %>';
		wlanWEPPSKKey_1 = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanSSID2ndIndexEJ); %>';
	}


	$("#wlanUserPriority").val(wlanUserPriority);
	$("input[name='wlanWPSActivity']").val([wlanWPSActivity]);      
	WPSactivityButton(wlanWPSActivity);

	$("#wlanUIPINSelf").text(wlanUIPINSelf);

	if( wlanSSIDIdx == '0' || wlanSSIDIdx == '100' ){
		cfg2web_WLAN_WPS_Security(
			"wlanUISecurityType", "wlanUIEncType", "wlanUIKey", wlanSecurityMode_0, wlanEncType_0, "●●●●●●●●●●");
	}else{
		cfg2web_WLAN_WPS_Security(
			"wlanUISecurityType", "wlanUIEncType", "wlanUIKey", wlanSecurityMode_1, wlanEncType_1, "●●●●●●●●●●");
	}

	if( wlanUIConfigured == '0' ){
		$("#wlanUIConfigured").text('Unconfigured');
	}else{
		$("#wlanUIConfigured").text('Configured');
	}

}

function WPSactivityButton(nWpsAct){
	switch(nWpsAct){
	case "0":
		mcr_clickradio_nWpsAct('0');
		$("input[id='m_wlanWPSActivity_1']").attr("checked", true).checkboxradio("refresh");
		break;
	case "1":
		mcr_clickradio_nWpsAct('1');
		$("input[id='m_wlanWPSActivity_2']").attr("checked", true).checkboxradio("refresh");
		break;
	default:
		alert("WPS 적용대상이 잘못되었습니다.");
		break;
	}
}

function mcr_clickradio_nWpsAct(val){
	$('label[for=m_wlanWPSActivity_1]').removeClass('ui-btn-active');
	$('label[for=m_wlanWPSActivity_2]').removeClass('ui-btn-active');
	switch(val){
	case '0':
		$('label[for=m_wlanWPSActivity_1]').addClass('ui-btn-active-c');
		$('label[for=m_wlanWPSActivity_2]').removeClass('ui-btn-active-c');
		break;
	case '1':
		$('label[for=m_wlanWPSActivity_2]').addClass('ui-btn-active-c');
		$('label[for=m_wlanWPSActivity_1]').removeClass('ui-btn-active-c');
	break;
	default:
	break;
	}
}

function WpsActCheck(){
	var WpsActVal=$(":input:radio[name=m_wlanWPSActivity]:checked").val();

	$("input[name='wlanWPSActivity']").val(WpsActVal);
	WPSactivityButton(WpsActVal);
}

function initForms(flag){
	initForm_WLAN_WPS(flag);
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );
	
	vendor_init();
	initForms(0);
}

function form_act(url,name){
	if(name == "wlanBtnPBC"){
		$("input[name='wlanBtnPBC']").val(name);
		$('a[name=m_wlanBtnPBC]').removeClass('ui-btn-active');
		$('a[name=m_wlanBtnPBC]').addClass('ui-btn-active-a');
	}
	else if(name == "wlanBtnApply"){
		$("input[name='wlanBtnApply']").val(name);
		$('a[name=m_wlanBtnApply]').removeClass('ui-btn-active');
		$('a[name=m_wlanBtnApply]').addClass('ui-btn-active-a');
	}
	else{
		$("input[name='wlanBtnReset']").val(name);
		$('a[name=m_wlanBtnReset]').removeClass('ui-btn-active');
		$('a[name=m_wlanBtnReset]').addClass('ui-btn-active-a');
	}

	parent.mcrProgress.startProgressSimple("apply",30);
	form_wps.action = url;
	form_wps.submit();
	return false;

}

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
	document.form_wps.action = "/goform/mcr_KTlogOut";
	document.form_wps.submit();
}


</script>
</head>
<body onload="initValue()">
<form method="post" name="form_wps" id="form_wps" data-ajax="false">

<input type="hidden" id="wlanUserPriority" name="wlanUserPriority" value="">
<input type="hidden" id="wlanWPSActivity" name="wlanWPSActivity" value="">

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="100">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_2_2_wps_set.asp">

<input type="hidden" id="wlanBtnPBC" name="wlanBtnPBC" value="">
<input type="hidden" id="wlanBtnApply" name="wlanBtnApply" value="">
<input type="hidden" id="wlanBtnReset" name="wlanBtnReset" value="">
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
					WPS 설정
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
	<div style="padding:0 5 0 5px;">
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td>WPS 적용 대상</td>
					<td>
						<label for="m_wlanWPSActivity_1">　None　</label>
							<input type="radio" name="m_wlanWPSActivity" id="m_wlanWPSActivity_1" value="0" onclick="WpsActCheck()" data-mini="true">
						<label for="m_wlanWPSActivity_2">　Home WLAN　</label>
							<input type="radio" name="m_wlanWPSActivity" id="m_wlanWPSActivity_2" value="1" onclick="WpsActCheck()" data-mini="true">
					</td>
				</tr>
			</table>
		</fieldset>
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<a href="javascript:;" id="m_wlanBtnApply" name="m_wlanBtnApply" onclick="form_act('/goform/mcr_KT_setWirelessWps','wlanBtnApply')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
			</tr>	
		</table>
	</div>
	<div style="padding:5 5 0 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>WPS 상태</td>
				<td>
					<label id="wlanUIConfigured"></label>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:;" id="m_wlanBtnReset" name="m_wlanBtnReset" onclick="form_act('/goform/mcr_KT_setWirelessWps','wlanBtnReset')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">Reset to Unconfigured</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:5 5 0 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>PBC 버튼</td>
				<td>
					<a href="javascript:;" id="m_wlanBtnPBC" name="m_wlanBtnPBC" onclick="form_act('/goform/mcr_KT_setWirelessWps','wlanBtnPBC')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">PBC 시작</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="display:none; padding:5 5 0 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>AP PIN Number</td>
				<td>
					<label id="wlanUIPINSelf"></label>
				</td>
			</tr>
		</table>
	</div>
	<div style="display:none; padding:5 5 0 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>단말 PIN Number</td>
				<td>
					<input type="text" id="wlanWPSPIN" name="wlanWPSPIN">
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:5 5 0 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr align="center">
				<td>Current Key 정보</td>
			</tr>
		</table>
	</div>
	<div style="padding:5 5 0 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>Authentication</td>
				<td>Encryption</td>
				<td>Key</td>
			</tr>
			<tr>
				<td>
					<label id="wlanUISecurityType"></label>
				</td>
				<td>
					<label id="wlanUIEncType"></label>
				</td>
				<td>
					<label id="wlanUIKey"></label>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:5 5 0 5px;">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>			
	</div>
</div>
</form>
</body>
</html>
