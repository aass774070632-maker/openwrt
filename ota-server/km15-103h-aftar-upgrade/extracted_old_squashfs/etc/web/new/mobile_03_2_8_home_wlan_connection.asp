<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
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
	var gWlanSSIDIndex_vap2_EJ;
	var gWlanSSIDIndex_vap3_EJ;

	if ( gWlanIfIndexEJ == '0' ) {
		gWlanSSIDIndex_vap2_EJ = '2';
		gWlanSSIDIndex_vap3_EJ = '3';
	} else {
		gWlanSSIDIndex_vap2_EJ = '102';
		gWlanSSIDIndex_vap3_EJ = '103';
	}
%>

var gWlanSSID_vap2_Activity;
var gWlanSSID_vap3_Activity;
var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';

var gUserPrivilege;
var check_apply_wlan=0;

function replaceAll(content, before, after) {
	return content.split(before).join(after);
}
function Xss_desubstitution(content) {
	content = replaceAll(content, "&lt;", "\<");
	content = replaceAll(content, "&gt;", "\>");
	content = replaceAll(content, "&#40;", "\(");
	content = replaceAll(content, "&#41;", "\)");
	content = replaceAll(content, "&#35;", "\#");
	content = replaceAll(content, "&#38;", "\&");
	content = replaceAll(content, "&#39;", "\'");
	content = replaceAll(content, "&quot;", "\"");

	return content;
}
function initForm_WLAN_Security(flag){
	var wlanSSIDIdx, wlanRadioActivity, cur_wlanSSID, wlanBroadSSID;
	var wlanSecurityMode, wlanEncType, wlanKeyType, wlanWEPPSKKey, wlanWEPDefaultKeyIndex, wlanWPAKeyRenewInterval;
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable, wlanWEPPSKKey_backup;

	if( flag == 0 ){
		wlanSSIDIdx = gWlanIfIndex;     

		wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanIfIndexEJ); %>';
		cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", gWlanIfIndexEJ); %>';
		cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);
		wlanBroadSSID = '<% mcr_getCfgWireless("Wlan_BroadSSID", gWlanIfIndexEJ); %>';

		wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
		wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>';

		wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", gWlanIfIndexEJ); %>';
		wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanIfIndexEJ); %>';
		wlanWEPPSKKey = Xss_desubstitution(wlanWEPPSKKey);
		wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", gWlanIfIndexEJ); %>';
		wlanWEPPSKKey_backup = Xss_desubstitution(wlanWEPPSKKey_backup);
		wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", gWlanIfIndexEJ); %>';

		wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", gWlanIfIndexEJ); %>';
		wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", gWlanIfIndexEJ); %>';
		wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", gWlanIfIndexEJ); %>';
		wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", gWlanIfIndexEJ); %>';

		wlanWPAKeyRenewInterval = '<% mcr_getCfgWireless("Wlan_WPARenewInterval", gWlanIfIndexEJ); %>';

		wlanWEPRekeyEnable = '<% mcr_getCfgWireless("Wlan_WepRekeyEnable", gWlanIfIndexEJ); %>';
		wlanMACAuthEnable = '<% mcr_getCfgWireless("Wlan_MacAuthEnable", gWlanIfIndexEJ); %>';

		wlanWMMEnable = '<% mcr_getCfgWireless("Wlan_WMMEnable", gWlanIfIndexEJ); %>';
		
		gWlanSSID_vap2_Activity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndex_vap2_EJ); %>';
		gWlanSSID_vap3_Activity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndex_vap3_EJ); %>';		
	}

	$("#wlanTitle").text("Home WLAN 접속 설정");


	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	setwlanRadioActivity(wlanRadioActivity);
	
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);

	$("#wlanWPAKeyRenewInterval").val(wlanWPAKeyRenewInterval);
	$("#wlanEnable_org").val(wlanRadioActivity);

	setwlanWEPKeyType(wlanKeyType);
	setwlanWEPKeyIndex(wlanWEPDefaultKeyIndex);
	$("#wlanUIWEPKey0").val(wlanWEPKey0);
	$("#wlanUIWEPKey1").val(wlanWEPKey1);
	$("#wlanUIWEPKey2").val(wlanWEPKey2);
	$("#wlanUIWEPKey3").val(wlanWEPKey3);

	setwlanWEPRekeyEnable(wlanWEPRekeyEnable);
	setwlanMACAuthEnable(wlanMACAuthEnable);
	setwlanWMMEnable(wlanWMMEnable);
	$("#wlanViewWMM").hide();
	
	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	$("#wlanWEPPSKKey_backup").val(wlanWEPPSKKey_backup);
	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
		$("#wlanWEPKey").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ||
		wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15'){
		$("#wlanPSKKey").val(wlanWEPPSKKey);
	}
	cfg2web_mobile_WLAN_Security();

	
	$("#wlan_change").show();
	$("#main_ssid").show();
	document.getElementById("cur_wlanSSID").style.color = "#666666";
	document.form_security.cur_wlanSSID.disabled = true;      
	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");

	if(wlanSSIDIdx == 100){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
	}else if(wlanSSIDIdx == 0){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_5G_";
	}
}

function SaveCountBytes(value)
{
	var count = 0;
	var str;
	var tmp = new String(value);
	var len = tmp.length;

	for ( i=0; i<len; i++ )
	{
		str = tmp.charAt(i);
		if(escape(str).length > 4)
		{
			count += 3;
		}
		else
		{
			count += 1;
		}
	}
	return count;
}

$(document).ready(function(){
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(0);
	});
	$("input[name='check_box_1']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(1);
	});

	$("#wlanUIWPAKeyRenewalEnable").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable(null);
	});

	$("#wlanBtnSecurity").bind( "click", function(){
		if(!validateOnSubmit())
			return false;
		$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
		$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessSecurity');
		return false;
		
	});
	$("input[name='m_wlanRadioActivity']").bind( "click", function(){
		if( MTK_WLAN_isNeedReboot_mobile() ){
			alert("활성여부가 변경되면 단말 재부팅 됩니다.");
		}
		return true;
	});

	$("#change_wlanSSID").keyup(function(){
		var count = SaveCountBytes(this.value);
		if( count > 32 ){
			if (event.keyCode != '8'){
				alert("최대 설정 글자수 입니다");
				this.value = this.value.substring(0, this.value.length-1);
			}
		}
	});

	initValue();
});



function validateOnSubmit(){
	var wlanSSIDIdx = gWlanIfIndex;
	var Activity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
	var checked = $("#wlanRadioActivity").val();
	var confirmed = true;
	var apply_flag = 0;

	if(($("#change_wlanSSID").val() == "KT_GiGA_") || ($("#change_wlanSSID").val() == "KT_GiGA_5G_")){
		$("#wlanSSID").val($("#cur_wlanSSID").val());
	}else{
		$("#wlanSSID").val($("#change_wlanSSID").val());
	}
	if(deviceRole != '2'){
		if($("#wlanUISecurityType").val() !='0'){
			if($("#wlanUISecurityType").val() =='1'){ //WEP
				apply_flag = 1;
			}else{	//WPA-PSK
				if(($("#wlanUIWPAType").val() == '1' && (($("#wlanUIWPAEncType").val() == '1') || $("#wlanUIWPAEncType").val() == '2'))){
					apply_flag = 0;
				}else if(($("#wlanUIWPAType").val() == '2' && ($("#wlanUIWPAEncType").val() == '1'|| $("#wlanUIWPAEncType").val() == '2'))){
					apply_flag = 0;
				}else{
					apply_flag = 1;
				}
			}
			if(apply_flag){
				if(mesh_enable == '0'){
					confirmed = confirm("지금 설정으로 변경 후에 Mesh 기능을 활성으로 설정 시에는 보안방식이 WPA&WPA2/TKIP&AES로 자동 변경됩니다. 계속하시겠습니까?");
					if(confirmed)
						$("#security_flag").val("0");
				}else{
					confirmed = confirm("Mesh 연결이 끊어지게 됩니다. 계속하시겠습니까?");
					if(confirmed)
						$("#security_flag").val("1");
				}	
				if (!confirmed)
					return false;
			}
		}
	}
	var ret = validateOnSubmit_WLAN_mobile_SecurityType();
	if( ret == true ){
		var vapEnable = 0;
		if( gWlanSSID_vap2_Activity =='1' || gWlanSSID_vap3_Activity =='1' ){
			vapEnable = 1;
		}
		ret = confirm_main_Activity(gWlanIfIndex,
			parseInt( $("#wlanRadioActivity").val(), 10 ), vapEnable );
	}
	if(ret == true && wlanSSIDIdx == '0'){
		if(Activity == '1' && checked == '0'){
			ret = confirm("IoW WLAN 접속 설정이 비활성화 됩니다. 계속하시겠습니까?");
		}else if(Activity == '0' && checked == '1'){
			ret = confirm("IoW WLAN 접속 설정도 활성화 됩니다.");
		}
	}
	if(ret == true){
		if( MTK_WLAN_isNeedReboot_mobile() ){
			$("#wlanReboot").val("1");
			check_apply_wlan=1;
		}else{
			$("#wlanReboot").val("0");
			check_apply_wlan=0;
		}
	}
	return ret;
}


function initForms(flag){
	initForm_WLAN_Security(flag);
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );


	vendor_init();
	initForms(0);
}

function form_act(url){
	 if(check_apply_wlan=="1")
                parent.mcrProgress.startProgressSimple("apply",50);
        else
                parent.mcrProgress.startProgressSimple("apply",40);

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
<input type="hidden" id="wlanWEPPSKKey_backup" name="wlanWEPPSKKey_backup" value="">
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value="">
<input type="hidden" id="wlanEnable_org" name="wlanEnable_org" value="">
<input type="hidden" id="wlanReboot" name="wlanReboot" value="">

<input type="hidden" id="meshEnable" name="meshEnable" value="">
<input type="hidden" id="meshIndex" name="meshindex" value="">
<input type="hidden" id="security_flag" name="security_flag" value="">

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
					Home WLAN 접속 설정
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
		<%include('new/mobile_wlan_security_common.asp');%>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
