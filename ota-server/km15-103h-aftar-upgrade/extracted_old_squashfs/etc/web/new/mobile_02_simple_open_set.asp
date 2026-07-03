<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
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

function logoff(){
	remove_auth_cache();
	document.form_simple.action = "/goform/mcr_KTlogOut";
	document.form_simple.submit();
}


<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var org_opmode;
var gUserPrivilege;
var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
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
		wlanWEPPSKKey =  Xss_desubstitution(wlanWEPPSKKey);
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
	document.form_simple.cur_wlanSSID.disabled = true;      
	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");

	if(wlanSSIDIdx == 100){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
		$("#title_24").show();
		$("#title_5").hide();
	}else if(wlanSSIDIdx == 0){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_5G_";
		$("#title_24").hide();
		$("#title_5").show();
	}
}


function initForm_WLAN(flag){

	initForm_WLAN_Security(flag);

	$("#wlanRedirectPage").val("/new/mobile_02_simple_open_set.asp");
	$("#wlanViewWMM").hide();

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
				if($("#wlanUISecurityType").val() =='1'){ // WEP
					apply_flag = 1;
				}else{  //WPA
					if(($("#wlanUIWPAType").val() == '1' && ($("#wlanUIWPAEncType").val() == '1' || $("#wlanUIWPAEncType").val() == '2'))){  //WPA2/AES
						apply_flag = 0;
					}else if(($("#wlanUIWPAType").val() == '2' && ($("#wlanUIWPAEncType").val() == '1' || $("#wlanUIWPAEncType").val() == '2'))){
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
		ret = validateOnSubmit_WLAN_mobile_SecurityType();
		if( ret == true ){
			$("#wlanAction").val("wlanBtnSecurity");

			$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
			$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');
			
			if(wlanSSIDIdx == '0'){
				if(Activity == '1' && checked == '0'){
					confirmed = confirm("IoW WLAN 접속 설정이 비활성화 됩니다. 계속하시겠습니까?");
					if(!confirmed) return false;
				}else if(Activity == '0' && checked == '1'){
					confirmed = confirm("IoW WLAN 접속 설정도 활성화 됩니다.");
					if(!confirmed) return false;
				}
			}

			if(MTK_WLAN_isNeedReboot_mobile()){
				$("#wlanReboot").val("1");
			}else{
				$("#wlanReboot").val("0");
			}

			form_act('/goform/mcr_KT_setWirelessSecurity');				
			return false;
		}
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

function initForms(flag){
	initForm_WLAN(flag);
}

function macClone_act(macaddr) {
	document.form_simple.macCloneMac.value = macaddr;
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){
	var network = '<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>';
	var opmode = '<% mcr_getCfgString("SysOperMode_OperMode"); %>';
	var macClone = '<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>';

	var sohoZoneMode = "<% mcr_getCfgString("SysOperMode_KTSOHOZoneMode"); %>";

	vendor_init();

	if(opmode == "1" && network == "0") {
		if( sohoZoneMode == "0" ){
			setopmode('0');
			org_opmode = 0;
		}else if( sohoZoneMode == "1" ){
			setopmode('3');
			org_opmode = 3;
		}

		$("#opmode_sohozone").val(sohoZoneMode);
	}
	else {
		if(opmode == "1"){
			setopmode('1');	
			org_opmode = 1;
		}else{
			setopmode('2');	
			org_opmode = 2;
		}
	}

	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	initForm_WLAN(0);
}


function validateOnSubmit_IPAlloc()
{
	var confirmed;
	var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
	if ($("#macCloneEnbl").val()== "1")
	{
		if (document.form_simple.macCloneMac.value != "") {
			var re = /[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}/;
			if (re.test(document.form_simple.macCloneMac.value)) {
				document.form_simple.redirect_url.value = "/new/mobile_02_simple_open_set.asp"
			}
			else {
				alert("Mac 입력형식 오류입니다");
				return false;
			}
		}
		else {
			alert("리스트에서 대상을 선택해 주세요");
			return false;
		}
	}
	if($("#opmode").val() == '0') {
		if (org_opmode != 0) {
			$("#opmodeChgFlag").val("1");
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
			if (!confirmed)
				return false;
			check_apply_wlan=1;
		} else {
			$("#opmodeChgFlag").val("0");
		}
	}
	else if($("#opmode").val() == '1') {
		if (org_opmode != 1) {
			$("#opmodeChgFlag").val("1");
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
			if (!confirmed)
				return false;
			check_apply_wlan=1;
		} else {
			$("#opmodeChgFlag").val("0");
		}
	}
	else if($("#opmode").val() == '2') {
		if(waninterface == "1") {
				confirmed = confirm("리피터 모드를 해지하려면 재부팅이 필요합니다. 모드를 변경하시겠습니까?");
				if (!confirmed)
					return false;
				check_apply_wlan=1;
				$("#opmodeChgFlag").val("1");
		} else {
			if (org_opmode != 2) {
				$("#opmodeChgFlag").val("1");
				confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
				if (!confirmed)
					return false;
				check_apply_wlan=1;
			} else {
				$("#opmodeChgFlag").val("0");
			}
		}
	}
	else if($("#opmode").val() == '3') {
		if (org_opmode != 3) {
			$("#opmodeChgFlag").val("1");
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
			if (!confirmed)
				return false;
			check_apply_wlan=1;
		} else {
			$("#opmodeChgFlag").val("0");
		}
		$("#opmode").val("0");
	}
	
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');

	form_act('/goform/mcr_KT_setSimpleConfig');

	return false;
}

function form_act(url){
	if(check_apply_wlan ==1)
                parent.mcrProgress.startProgressSimple("apply",50);
        else
                parent.mcrProgress.startProgressSimple("apply",30);
	form_simple.action = url;
	form_simple.submit();
	return false;
}

function setopmode(opmode){
	var macClone = "<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>";
	var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";

	$("#view_macClone").show();
	switch(opmode){
		case '0':	
			mcr_clickradio_opmode('0');

			$("input[id='m_opmode']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("0");
			$("#opmode_sohozone").val("0");
			break;

		case '1':
			mcr_clickradio_opmode('1');

			$("input[id='m_opmode1']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("1");
			$("#opmode_sohozone").val("0");

			break;
		case '2':
			mcr_clickradio_opmode('2');

			$("input[id='m_opmode2']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("2");

			$("#macCloneList").hide();
			$("#macCloneMacRow").hide();

			$("#m_macCloneEnbl").attr('disabled',true).checkboxradio("refresh");
			setMacCtl("0");
			break;
		case '3':
			mcr_clickradio_opmode('3');

			$("input[id='m_opmode3']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("3");
			$("#opmode_sohozone").val("1");

			break;
		default:
			break;
	}

	if(opmode != "2") {
		if (macClone == "0" || limit_cnt_en == "0") {
			setMacCtl("0");
			$("input[id='m_macCloneEnbl']").attr("checked", false).checkboxradio("refresh");
			document.form_simple.macCloneMac.value = "";
		} else {
			setMacCtl("1");
			$("input[id='m_macCloneEnbl1']").attr("checked", false).checkboxradio("refresh");
		}

		if (limit_cnt_en == "0") {
			$("#m_opmode2").attr('disabled',true).checkboxradio("refresh");
			$("#m_macCloneEnbl").attr('disabled',true).checkboxradio("refresh");
			setMacCtl("0");
		} else {
			$("#m_opmode2").attr('disabled',false).checkboxradio("refresh");
			$("#m_macCloneEnbl").attr('disabled',false).checkboxradio("refresh");
		}
	}

}

function setMacCtl(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_mac('1');
			$("input[id='m_macCloneEnbl']").attr("checked", true).checkboxradio("refresh");
			$("#macCloneList").show();
			$("#macCloneMacRow").show();
			$("#macCloneEnbl").val("1");
			break;
		case '0':       
			mcr_clickradio_mac('0');
			$("input[id='m_macCloneEnbl1']").attr("checked", true).checkboxradio("refresh");
			$("#macCloneList").hide();
			$("#macCloneMacRow").hide();
			$("#macCloneEnbl").val("0");
			break;
	}
}

function mcr_clickradio_opmode(val){
	$('label[for=m_opmode]').removeClass('ui-btn-active');
	$('label[for=m_opmode1]').removeClass('ui-btn-active');
	$('label[for=m_opmode2]').removeClass('ui-btn-active');
	$('label[for=m_opmode3]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_opmode]').addClass('ui-btn-active-c');

			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_opmode1]').addClass('ui-btn-active-c');

			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_opmode2]').addClass('ui-btn-active-c');

			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_opmode3]').addClass('ui-btn-active-c');

			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function mcr_clickradio_mac(val){
	$('label[for=m_macCloneEnbl]').removeClass('ui-btn-active');
	$('label[for=m_macCloneEnbl1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_macCloneEnbl1]').addClass('ui-btn-active-c');
			$('label[for=m_macCloneEnbl]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_macCloneEnbl]').addClass('ui-btn-active-c');
			$('label[for=m_macCloneEnbl1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}
</script>

</head>
<body onload="initValue()">
<form method="post" name="form_simple" data-ajax="false">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="">

<input type="hidden" name="redirect_url" value="/mobile_login.asp">
<input type="hidden" name="redirect_admWanSet" id="redirect_admWanSet" value="/new/mobile_02_simple_open_set.asp">

<input type="hidden" name="opmode" id="opmode" value="">

<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value="">
<input type="hidden" id="wlanSSID" name="wlanSSID" value="">
<input type="hidden" id="wlanBroadSSID" name="wlanBroadSSID" value="">
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value="">
<input type="hidden" id="wlanEncType" name="wlanEncType" value="">
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value="">
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value="">
<input type="hidden" id="wlanWEPPSKKey_backup" name="wlanWEPPSKKey_backup" value="">
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value="">

<input type="hidden" id="opmode_sohozone" name="opmode_sohozone" value="0">

<input type="hidden" id="macCloneEnbl" name="macCloneEnbl" value="">
<input type="hidden" id="opmodeChgFlag" name="opmodeChgFlag" value="">
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
				<td id="title_24" align="left" width="90%" style="font-weight:bold; disaply:none;">
					간편개통설정(2.4GHz)
				</td>
				<td id="title_5" align="left" width="90%" style="font-weight:bold; disaply:none;">
					간편개통설정(5GHz)
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
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IP 할당 정책</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_opmode">KT 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode" value="0" onclick="setopmode(this.value)">
									<label for="m_opmode1">공유기 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode1" value="1" onclick="setopmode(this.value)">
									<label for="m_opmode2">브릿지 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode2" value="2" onclick="setopmode(this.value)">
									
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">MAC Clone 활성</td>
							<td id="view_macClone">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_macCloneEnbl">　활성　</label>
									<input type="radio" name="m_macCloneEnbl" id="m_macCloneEnbl" value="1" onclick="setMacCtl(this.value)">
									<label for="m_macCloneEnbl1">　비활성　</label>
									<input type="radio" name="m_macCloneEnbl" id="m_macCloneEnbl1" value="0" onclick="setMacCtl(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="macCloneMacRow" style="display:none">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">MAC Clone 주소</td>
							<td>
								<input name="macCloneMac" type="text" id="macCloneMac" value="<% mcr_getCfgInterface("MacCloneCfgParam_LanMac"); %>">
							</td>
						</tr>
					</table>
				</td>
			<tr id="macCloneList" style="display:none">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<colgroup><col>
										<col>
										<col>
										<col>
										<col> 
										<tr>
											<td>
												<p>선택</p>
											</td>
											<td>
												<p>PC 이름</p>
											</td>
											<td>
												<p>IP 주소</p>
											</td>
											<td>
												<p>MAC 주소</p>
											</td>
											<td>
												<p>상태</p>
											</td>
										</tr>
									</table>
								</span>
							</td>
						</tr>
						<tr>
							<td width="100%" valign="top">
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<colgroup><col align="center"> 
										<col>
										<col>
										<col>
										<col align="center">
										<%
											var i;
											var rule_num = mcr_getMacInfoCount(0);
	
											if (rule_num > 0) {
												for ( i = 0; i < rule_num; i++ ){
													write("<tr>");

													write("<td style='padding-left:0px;' align='center'>");
													write("<input name=DR type=radio onClick=macClone_act(\""+mcr_getMacInfoList(i,2)+"\") data-role='none' >");
													write("</td>");

													write("<td style='word-break:break-all'>");
													write("<p>");write(mcr_getMacInfoList(i,0));write("</p>");
													write("</td>");

													write("<td>");
													write("<p>");write(mcr_getMacInfoList(i,1));write("</p>");
													write("</td>");

													write("<td>");
													write("<p>");write(mcr_getMacInfoList(i,2));write("</p>");
													write("</td>");

													write("<td>");
													write("<p>");write(mcr_getMacInfoList(i,3));write("</p>");
													write("</td>");
													write("</tr>\n");
												}
											}
											else {
												write("<tr>");
												write("<td colspan=5 align='center'>");
												write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
												write("</td>");
												write("</tr>\n");
											}
										%>
									</table>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return validateOnSubmit_IPAlloc();" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:0 5 12 5px;">
		<%include('new/mobile_wlan_security_common.asp');%>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="form_act('/goform/mcr_setRestart'); return false;" data-theme="b" data-role="button" data-mini="false" data-ajax="false">시스템 재시동</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#firstPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
