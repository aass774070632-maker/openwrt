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
var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
<%
	var gWlanSSIDIndexEJ;

	if ( gWlanIfIndexEJ == '0' ) {
		gWlanSSIDIndexEJ = '1';
	} else {
		gWlanSSIDIndexEJ = '101';
	}
%>

if( gWlanIfIndex == '0' ){
	gWlanSSIDIndex = '1';
}else{
	gWlanSSIDIndex = '101';
}

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
	var wlanWEPRekeyEnable, wlanMACAuthEnable, wlanWEPPSKKey_backup;
	var wlanWMMEnable;

	if( flag == 0 ){
		wlanSSIDIdx = gWlanSSIDIndex;     

		wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';
		cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", gWlanSSIDIndexEJ); %>';
		cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);
		wlanBroadSSID = '<% mcr_getCfgWireless("Wlan_BroadSSID", gWlanSSIDIndexEJ); %>';

		wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanSSIDIndexEJ); %>';
		wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanSSIDIndexEJ); %>';

		wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", gWlanSSIDIndexEJ); %>';
		wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanSSIDIndexEJ); %>';
		wlanWEPPSKKey = Xss_desubstitution(wlanWEPPSKKey);
		wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", gWlanSSIDIndexEJ); %>';
		wlanWEPPSKKey_backup = Xss_desubstitution(wlanWEPPSKKey_backup);
		wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", gWlanSSIDIndexEJ); %>';

		wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", gWlanSSIDIndexEJ); %>';
		wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", gWlanSSIDIndexEJ); %>';
		wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", gWlanSSIDIndexEJ); %>';
		wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", gWlanSSIDIndexEJ); %>';

		wlanWPAKeyRenewInterval = '<% mcr_getCfgWireless("Wlan_WPARenewInterval", gWlanSSIDIndexEJ); %>';

		wlanWEPRekeyEnable = '<% mcr_getCfgWireless("Wlan_WepRekeyEnable", gWlanSSIDIndexEJ); %>';
		wlanMACAuthEnable = '<% mcr_getCfgWireless("Wlan_MacAuthEnable", gWlanSSIDIndexEJ); %>';

		wlanWMMEnable = '<% mcr_getCfgWireless("Wlan_WMMEnable", gWlanSSIDIndexEJ); %>';
		
	}

	$("#wlanTitle").text("Mesh WLAN 접속 설정");


	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	setwlanRadioActivity(wlanRadioActivity);
	
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);

	$("#wlanWPAKeyRenewInterval").val(wlanWPAKeyRenewInterval);

	setwlanWEPKeyType(wlanKeyType);
	setwlanWEPKeyIndex(wlanWEPDefaultKeyIndex);
	$("#wlanUIWEPKey0").val(wlanWEPKey0);
	$("#wlanUIWEPKey1").val(wlanWEPKey1);
	$("#wlanUIWEPKey2").val(wlanWEPKey2);
	$("#wlanUIWEPKey3").val(wlanWEPKey3);
	$("input[name='wlanWMMEnable']").val([wlanWMMEnable]);

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

	
	document.getElementById("cur_wlanSSID").style.color = "#666666";
	document.form_security.cur_wlanSSID.disabled = true;      
	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");

	$("label[for='m_wlanUIWPAType3']").hide();
	$("input[id='m_wlanUIWPAType3']").hide();
	$("label[for='m_wlanUIWPAType4']").hide();
	$("input[id='m_wlanUIWPAType4']").hide();
	$("label[for='m_wlanUIWPAType5']").hide();
	$("input[id='m_wlanUIWPAType5']").hide();
	if(wlanSSIDIdx == 101){
		$("#wlanViewWPA").hide();
		$("#main_ssid").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanViewPSK1").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlanViewSecure").hide();
		document.getElementById("change_wlanSSID").value = "KT_GiGA_Mesh_";
	}else if(wlanSSIDIdx == 1){
		$("#wlan_change").show();
                $("#main_ssid").show();
		document.getElementById("change_wlanSSID").value = "KT_GiGA_Mesh_";
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
	$("input[name='wlanUISecurityType']").bind( "click", function(){
		var ret = onClick_WLAN_mobile_SecurityType(null);
		return ret;
	});
	$("#wlanUIWPAKeyRenewalEnable").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable(null);
	});

	$("#wlanBtnSecurity").bind( "click", function(){
		if(!validateOnSubmit())
			return false;
		$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
		$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessMeshSecurity');
		return false;
		
	});
//	$("input[name='m_wlanRadioActivity']").bind( "click", function(){
//		if(mesh_enable == '0' && gWlanSSIDIndex == '1') {
//		var act = $("input[name='m_wlanRadioActivity']").val();
//		if(act == '1'){
//			$("#wlanSecurityMode").val('6');
//			$("#wlanEncType").val('2');
//			cfg2web_mobile_WLAN_Security();
//		}
//		return false;
//		}
//	});

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

function onClick_MeshPopUpSet(){
	var MeshDeviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
	var wlanSecurityMode_main = '<% mcr_getCfgWireless("Wlan_SecurityMode_0", "-1"); %>';
	var wlanEncType_main = '<% mcr_getCfgWireless("Wlan_EncryptType_0", "-1"); %>';
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	var wlanEncType_mesh = '<% mcr_getCfgWireless("Wlan_EncryptType_1", "-1"); %>';
	var apply_flag = 0;
	var flag = 0;

	if(MeshDeviceRole != '2'){
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
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}
		if(wlanSecurityMode_main != '0'){
			if(wlanSecurityMode_main == '3'){//WEP
				flag = 1;
			}else{
				if((wlanSecurityMode_main == '5' && (wlanEncType_main == '1' || wlanEncType_main == '2'))){ //WPA2 - AES/TKIP-AES
					flag = 0;
				}else if((wlanSecurityMode_main == '6' && (wlanEncType_main == '1' || wlanEncType_main == '2'))){ //WPA-WPA2 - AES/TKIP-AES
					flag = 0;
				}else{
					flag = 1;
				}
			}
			if(flag){
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}
	}
	return true;
}
function validateOnSubmit(){
	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_MapEnable","-1"); %>';
	var checked = $("#wlanRadioActivity").val();

	if(checked == '1'){
		if(!onClick_MeshPopUpSet()){
			return false;
		}
	}else if(gWlanSSIDIndex == '1') {
		alert("비활성 시, Mesh 연결이 끊어집니다.");
	} else {}

	if($("#change_wlanSSID").val() == "KT_GiGA_Mesh_"){
		$("#wlanSSID").val($("#cur_wlanSSID").val());
	}else{
		$("#wlanSSID").val($("#change_wlanSSID").val());
	}
	var ret = validateOnSubmit_WLAN_mobile_SecurityType();
	return ret;
}
function initForms(flag){
	initForm_WLAN_Security(flag);
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	initForms(0);
}

function form_act(url){
	parent.mcrProgress.startProgressSimple("apply",30);
        form_security.action = url;
        form_security.submit();
        return false;
}

</script>

</head>
<body>
<form method="post" name="form_security" data-ajax="false" action="/goform/mcr_KT_setWirelessMeshSecurity">


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
					Mesh WLAN 접속 설정
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
