<html>
<head>
<title>Mobile simple</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_simple.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>

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

.ui-btn-up-b {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #fff;
	text-shadow: 0 0px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
	background-image: -webkit-linear-gradient(#f16045,#ec2427);
	background-image: -moz-linear-gradient(#f16045,#ec2427);
	background-image: -ms-linear-gradient(#f16045,#ec2427);
	background-image: -o-linear-gradient(#f16045,#ec2427);
	background-image: linear-gradient(#f16045,#ec2427);
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


var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';

function logoff(){
	remove_auth_cache();
	document.form_simple.action = "/goform/mcr_wlan_simple_KTlogOut";
	document.form_simple.submit();
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

function cfg2web_mobile_WLAN_Security_simple() 
{
	var bWebKeyEnable = 0;
	var bWPAEnable = 0;
	var bPSKEnable = 0;
	var b8021xEnable = 0;
	var bWebRedirectEnable = 0;
	var bWepRekeyEnable = 0;
	var securityModeValue = $("#wlanSecurityMode").val();
	var uiSecurityMode = ''+conv2UI_WLAN_SecurityType(securityModeValue);

	//security
	$("input[name='wlanUISecurityType']").val(uiSecurityMode);

	setwlanUISecurityType(uiSecurityMode);

	switch( securityModeValue ){
		case '0':       //SECURITY_MODE_DISABLE
			break;
		case '1':       //SECURITY_MODE_OPEN
			setwlanUIWEPEncType('0');
			break;
		case '2':       //SECURITY_MODE_SHARED
			setwlanUIWEPEncType('1');
			break;
		case '3':       //SECURITY_MODE_AUTO
			setwlanUIWEPEncType('2');
			break;
		case '4':       //SECURITY_MODE_WPA_PSK
			setwlanUIWPAType('0');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '5':       //SECURITY_MODE_WPA2_PSK
			setwlanUIWPAType('1');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '6':       //SECURITY_MODE_WPA_WPA2_PSK
			setwlanUIWPAType('2');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '7':       //SECURITY_MODE_WPA_ENT
			setwlanUIWPAType('0');
			bWPAEnable = 1;
			break;
		case '8':       //SECURITY_MODE_WPA2_ENT
			setwlanUIWPAType('1');
			bWPAEnable = 1;
			break;
		case '9':       //SECURITY_MODE_WPA_WPA2_ENT
			setwlanUIWPAType('2');
			bWPAEnable = 1;
			break;
		case '10'://SECURITY_MODE_8021X
			b8021xEnable = 1;
			bWebRedirectEnable = 1;
			bWepRekeyEnable = 1;
			break;
		case '13'://SECURITY_MODE_WPA3_PSK
			setwlanUIWPAType('3');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '14'://SECURITY_MODE_WPA2_WPA3_PSK
			setwlanUIWPAType('4');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '15'://SECURITY_MODE_WPA_WPA2_WPA3_PSK
			setwlanUIWPAType('5');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
	}
	//////////////////////////
	// WEP
	var wlanWEPKey = $("#wlanWEPKey").val();
	var wlanWEPKeyIndex = $("#wlanWEPKeyIndex").val();
	if( wlanWEPKey != null ){
		if( wlanWEPKey.length == 13 || wlanWEPKey.length == 26 ){
			setwlanUIWEPKeyLen('1');
		}else{
			setwlanUIWEPKeyLen('0');
		}

		if( wlanWEPKey != null ){
			initTextById("wlanUIWEPKey"+wlanWEPKeyIndex, wlanWEPKey);
		}
	}

	//////////////////////////
	// WPA
	if(bWPAEnable == 1 ){
		var WlanEncType = $("#wlanEncType").val();
		setwlanUIWPAEncType(WlanEncType);

		if( bPSKEnable == 1 ){
			var pskKey = $("#wlanPSKKey").val();
			if( pskKey != null ){
				setwlanUIPSKKeyType((pskKey.length == 64 ) ? '1' : '0');
				initTextById("wlanUIPSKKey", pskKey);
			}
		}
	}
	onClick_WLAN_mobile_SecurityType();

	$("#wlanSSID").show();
	$("#wlanSSID_pass").hide();

}
function web2cfg_WLAN_mobile_Security_2g()
{
	var wlanUISecurityType = $("input[name='wlanUISecurityType']").val();
	var wlanSecurityMode = '0';

	if( wlanUISecurityType == '0' ){        //None
		wlanSecurityMode = '0';
	}else if( wlanUISecurityType == '1' ){  //WEP
		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType']").val(); 
		if( wlanUIWEPEncType == '0' ){                  //Open
			wlanSecurityMode = '1';
		}else if( wlanUIWEPEncType == '1' ){    //Shared
			wlanSecurityMode = '2';
		}else if( wlanUIWEPEncType == '2' ){    //Auto
			wlanSecurityMode = '3';
		}

		if( validate_WLAN_mobile_Security_wepkey() == false ) return false;
		else{
			var wlanWEPKeyIndex = $("#wlanWEPKeyIndex").val();
			var keyName = "wlanUIWEPKey"+wlanWEPKeyIndex;

			initTextById( "wlanWEPKey", document.getElementById(keyName).value );
		}
		initTextById( "wlanEncType", '1' );             //WEP Only
	}else if( wlanUISecurityType == '2' ){  //WPA-PSK
		var wlanUIWPAType = $("input[name='wlanUIWPAType']").val();
		if( wlanUIWPAType == '0' ){                     //WPA
			wlanSecurityMode = '4';
		}else if( wlanUIWPAType == '1' ){       //WPA2
			wlanSecurityMode = '5';
		}else if( wlanUIWPAType == '2' ){       //WPA/WPA2
			wlanSecurityMode = '6';
		}else if( wlanUIWPAType == '3'){	//WPA3
			wlanSecurityMode = '13';
		}else if( wlanUIWPAType == '4'){	//WPA2/WPA3
			wlanSecurityMode = '14';
		}else if( wlanUIWPAType == '5'){	//WPA/WPA2/WPA3
			wlanSecurityMode = '15';
		}

		if( validate_WLAN_mobile_Security_pskkey() == false ) return false;
		else{
			initTextById( "wlanPSKKey", document.getElementById("wlanUIPSKKey").value );
		}
		initTextById( "wlanEncType", $("input[name='wlanUIWPAEncType']").val() );
	}

	initTextById( "wlanSecurityMode", wlanSecurityMode );

	return true;
}

function validateOnSubmit_WLAN_mobile_SecurityType_simple(val)
{
	var ret = false;
	if (val == '100') {
		ret = validateSecurityInputTextForm();
	} else {
		ret = validateSecurityInputTextForm_5g();
	}
	if( ret == false ){
		return ret;
	}
	if (val == '100') {
		ret = web2cfg_WLAN_mobile_Security_2g();
	} else {
		ret = web2cfg_WLAN_mobile_Security_5g();
	}
	if( ret == false ){
		return ret;
	}
	return ret;
}



function initForm_WLAN_Security_2G(){
        var wlanRadioActivity, cur_wlanSSID;
        var wlanSecurityMode, wlanWEPPSKKey, wlanEncType, wlanKeyType, wlanWEPDefaultKeyIndex;
        var wlanWEPKey, wlanWEPPSKKey_backup;


	wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';
	cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", 100); %>';
	cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);

	wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", 100); %>';
	wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", 100); %>';
	wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", 100); %>';

	wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", 100); %>';

	wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", 100); %>';
	wlanWEPPSKKey = Xss_desubstitution(wlanWEPPSKKey);
	wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", 100); %>';
	wlanWEPPSKKey_backup = Xss_desubstitution(wlanWEPPSKKey_backup);
	wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", 100); %>';
	wlanWEPKey0 = Xss_desubstitution(wlanWEPKey0);
	wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", 100); %>';
	wlanWEPKey1 = Xss_desubstitution(wlanWEPKey1);
	wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", 100); %>';
	wlanWEPKey2 = Xss_desubstitution(wlanWEPKey2);
	wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", 100); %>';
	wlanWEPKey3 = Xss_desubstitution(wlanWEPKey3);
	
	$("#wlanUIWEPKey0").val(wlanWEPKey0);
	$("#wlanUIWEPKey1").val(wlanWEPKey1);
	$("#wlanUIWEPKey2").val(wlanWEPKey2);
	$("#wlanUIWEPKey3").val(wlanWEPKey3);
	setwlanWEPKeyType(wlanKeyType);
	setwlanWEPKeyIndex(wlanWEPDefaultKeyIndex);

	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	$("#wlanWEPPSKKey_backup").val(wlanWEPPSKKey_backup);
	$("#change_wlanSSID").val("KT_GiGA_");

	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
	$("#main_ssid").show();
	$("#wlanTitle_2g").text("간편개통설정(2.4GHz)");
	$("#wlanWEPPSKKey_backup").val(wlanWEPPSKKey_backup);

	if(wlanSecurityMode == 4 || wlanSecurityMode == 5 || wlanSecurityMode == 6 || 
		wlanSecurityMode == 13 || wlanSecurityMode == 14 || wlanSecurityMode == 15){	
		$("#cur_wlanSSID").val(cur_wlanSSID);
		$("#wlanPSKKey").val(wlanWEPPSKKey);
		$("#wlan_change").show();
		$("#wlanViewPSK2").show();
		$("#wireless_wlanUIPSKKey").show();
		document.getElementById("cur_wlanSSID").style.color = "#666666";
		document.form_simple.cur_wlanSSID.disabled = true;      
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
	}else if(wlanSecurityMode == 1 || wlanSecurityMode == 2 || wlanSecurityMode == 3){
		$("#cur_wlanSSID").val(cur_wlanSSID);
		$("#wlanWEPKey").val(wlanWEPPSKKey);
		$("#wlan_change").show();
		$("#wlanViewWEP").show();
		$("#wireless_wlanUIPSKKey").hide();
		document.getElementById("cur_wlanSSID").style.color = "#666666";
		document.form_simple.cur_wlanSSID.disabled = true;      
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
	}else{
		$("#cur_wlanSSID").val(cur_wlanSSID);
		$("#wlan_change").show();
		$("#wireless_wlanUIPSKKey").hide();
		document.getElementById("cur_wlanSSID").style.color = "#666666";
		document.form_simple.cur_wlanSSID.disabled = true;      
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
	}
	cfg2web_mobile_WLAN_Security_simple();
}

function initForm_WLAN_Security_5g(){
        var wlanRadioActivity, cur_wlanSSID;
        var wlanSecurityMode, wlanWEPPSKKey, wlanEncType, wlanKeyType, wlanWEPDefaultKeyIndex;
        var wlanWEPKey, wlanWEPPSKKey_backup;


	wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
	cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", 0); %>';
	cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);

	wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", 0); %>';
	wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", 0); %>';
	wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", 0); %>';

	wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", 0); %>';

	wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", 0); %>';
	wlanWEPPSKKey = Xss_desubstitution(wlanWEPPSKKey);
	wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", 0); %>';
	wlanWEPPSKKey_backup = Xss_desubstitution(wlanWEPPSKKey_backup);
	wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", 0); %>';
	wlanWEPKey0 = Xss_desubstitution(wlanWEPKey0);
	wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", 0); %>';
	wlanWEPKey1 = Xss_desubstitution(wlanWEPKey1);
	wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", 0); %>';
	wlanWEPKey2 = Xss_desubstitution(wlanWEPKey2);
	wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", 0); %>';
	wlanWEPKey3 = Xss_desubstitution(wlanWEPKey3);
	
	$("#wlanUIWEPKey0_5g").val(wlanWEPKey0);
	$("#wlanUIWEPKey1_5g").val(wlanWEPKey1);
	$("#wlanUIWEPKey2_5g").val(wlanWEPKey2);
	$("#wlanUIWEPKey3_5g").val(wlanWEPKey3);
	setwlanWEPKeyType_5g(wlanKeyType);
	setwlanWEPKeyIndex_5g(wlanWEPDefaultKeyIndex);

	$("#wlanSecurityMode_5g").val(wlanSecurityMode);
	$("#wlanEncType_5g").val(wlanEncType);
	$("#wlanWEPPSKKey_backup_5g").val(wlanWEPPSKKey_backup);

	$("#lbl_wireless_wlanUIPSKKey_5g").text("암호는 10자 이상 64자 이하여야 합니다.");
	$("#main_ssid_5g").show();
	$("#wlanTitle_5g").text("간편개통설정(5GHz)");

	if(wlanSecurityMode == 4 || wlanSecurityMode == 5 || wlanSecurityMode == 6 || 
		wlanSecurityMode == 13 || wlanSecurityMode == 14 || wlanSecurityMode == 15){	
		$("#cur_wlanSSID_5g").val(cur_wlanSSID);
		$("#wlanPSKKey_5g").val(wlanWEPPSKKey);
		$("#wlan_change_5g").show();
		$("#wlanViewPSK2_5g").show();
		document.getElementById("cur_wlanSSID_5g").style.color = "#666666";
		document.form_simple.cur_wlanSSID_5g.disabled = true;      
		document.getElementById("change_wlanSSID_5g").value = "KT_GiGA_5G_";
	}else if(wlanSecurityMode == 1 || wlanSecurityMode == 2 || wlanSecurityMode == 3){
		$("#cur_wlanSSID_5g").val(cur_wlanSSID);
		$("#wlanWEPKey_5g").val(wlanWEPPSKKey);
		$("#wlan_change_5g").show();
		$("#wlanViewWEP_5g").show();
		document.getElementById("cur_wlanSSID_5g").style.color = "#666666";
		document.form_simple.cur_wlanSSID_5g.disabled = true;      
		document.getElementById("change_wlanSSID_5g").value = "KT_GiGA_5G_";
	}else{
		$("#cur_wlanSSID_5g").val(cur_wlanSSID);
		$("#wlan_change_5g").show();
		document.getElementById("cur_wlanSSID_5g").style.color = "#666666";
		document.form_simple.cur_wlanSSID_5g.disabled = true;      
		document.getElementById("change_wlanSSID_5g").value = "KT_GiGA_5G_";
	}
	cfg2web_mobile_WLAN_Security_5g();
}

function initValue(){
	initForm_WLAN_Security_2G();	
	initForm_WLAN_Security_5g();	

	$("#wlanPSKKey_org").val( $("#wlanPSKKey").val());
	$("#wlanWEPKey_org").val( $("#wlanWEPKey").val());
	$("#wlanPSKKey_5g_org").val( $("#wlanPSKKey_5g").val());
	$("#wlanWEPKey_5g_org").val( $("#wlanWEPKey_5g").val());
}


function form_act(url){
	if(url =='/goform/mcr_KT_set_simple_WirelessSecurity'){
		if(($("#change_wlanSSID").val() == "KT_GiGA_") ){
			$("#change_wlanSSID").val($("#cur_wlanSSID").val());
		} else {
			$("#change_wlanSSID").val($("#change_wlanSSID").val());
		}

		if(($("#change_wlanSSID_5g").val() == "KT_GiGA_5G_")){
			$("#change_wlanSSID_5g").val($("#cur_wlanSSID_5g").val());
		} else {
			$("#change_wlanSSID_5g").val($("#change_wlanSSID_5g").val());
		}
	}

	$("#redirection_url").val("new/mobile_00_1_wlan_simple.asp");
	parent.mcrProgress.startProgressSimple("apply",30);

	form_simple.action = url;
	form_simple.submit();
	return false;
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

function mobile_simple_pop_up(wlan_ssid_idx) {

	var stype = 0;
	var wpa_type, wpa_enc_type;
	var p_ret = true;

	if (wlan_ssid_idx == 0) {
		stype = $("#wlanUISecurityType_5g").val();
		wpa_type = $("#wlanUIWPAType_5g").val();
		wpa_enc_type = $("#wlanUIWPAEncType_5g").val();
	} else if(wlan_ssid_idx == 100) {
		stype = $("#wlanUISecurityType").val();
		wpa_type = $("#wlanUIWPAType").val();
		wpa_enc_type = $("#wlanUIWPAEncType").val();
	}

	if(deviceRole != '2'){
		if(stype != '0'){
			if(stype == '1'){ // WEP
				apply_flag = 1;
			}else{  //WPA
				if((wpa_type == '1' && (wpa_enc_type == '1' || wpa_enc_type == '2'))){  //WPA2/AES
					apply_flag = 0;
				}else if((wpa_type  == '2' && (wpa_enc_type == '1' || wpa_enc_type == '2'))){
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
					p_ret = false;
			}
		}
	}
	return p_ret;
}

$(document).ready(function(){
	$("#wlanBtnSecurity").bind( "click", function(){
		var wlanSecurityMode = $("#wlanSecurityMode").val();
		var wlanSecurityMode_5g = $("#wlanSecurityMode_5g").val();
		var pret1, pret2, ret1, ret2;

		pret1 = mobile_simple_pop_up(100);
		pret2 = mobile_simple_pop_up(0);

		ret1 = validateOnSubmit_WLAN_mobile_SecurityType_simple(100); // web2cfg
		ret2 = validateOnSubmit_WLAN_mobile_SecurityType_simple(0); // web2cfg

		if ((pret1 == true) && (pret2 == true)) {
			if ((ret1 == true) && (ret2 == true)) {
				$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
				$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');

				form_act('/goform/mcr_KT_set_simple_WirelessSecurity');
				return false;
			}
		}
		return false;

	});
	$("#change_wlanSSID").keyup(function(){
		var count = SaveCountBytes(this.value);
		if ( count > 32 ){
			if (event.keyCode != '8'){
				alert("최대 설정 글자수 입니다");
				this.value = this.value.substring(0, this.value.length-1);
			}	
		}
	})
	initValue();
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(0);
	});
	$("input[name='check_box_1']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(1);
	});
	$("input[name='check_box_2']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(3);
	});
	$("input[name='check_box_3']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(4);
	});
});

</script>
</head>
<body onload="initValue()">
<form method="post" name="form_simple" data-ajax="false">
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value="">
<input type="hidden" id="wlanSecurityMode_5g" name="wlanSecurityMode_5g" value="">
<input type="hidden" id="redirection_url" name="redirection_url" value="">
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value="">
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value="">
<input type="hidden" id="wlanWEPPSKKey_backup" name="wlanWEPPSKKey_backup" value="">
<input type="hidden" id="wlanWEPPSKKey_backup_5g" name="wlanWEPPSKKey_backup_5g" value="">
<input type="hidden" id="wlanWEPKey_5g" name="wlanWEPKey_5g" value="">
<input type="hidden" id="wlanPSKKey_5g" name="wlanPSKKey_5g" value="">
<input type="hidden" id="wlanWEPKey_org" name="wlanWEPKey_org" value="">
<input type="hidden" id="wlanPSKKey_org" name="wlanPSKKey_org" value="">
<input type="hidden" id="wlanEncType" name="wlanEncType" value="">
<input type="hidden" id="wlanEncType_5g" name="wlanEncType_5g" value="">
<input type="hidden" id="security_flag" name="security_flag" value="">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<input type="button" value="로그아웃" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png">
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
					<img src="/images/kt_logo.png" style="width: 24px;">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					비밀번호 설정
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
		<%include('new/mobile_wlan_security_common_2g.asp');%>	
	</div>
	<div style="padding:0 5 12 5px;">
		<%include('new/mobile_wlan_security_common_5g.asp');%>	
	</div>

	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
		<a href="/mobile.asp" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
