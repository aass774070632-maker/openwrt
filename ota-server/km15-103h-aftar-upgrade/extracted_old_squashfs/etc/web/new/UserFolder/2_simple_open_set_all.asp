<html>
<head>
<%include('new/metatag.asp');%>
<title>간편개통설정</title>
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
<script language="javascript" type="text/javascript">

var gWlanSSID_vap2_Activity;
var gWlanSSID_vap3_Activity;
<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
var org_opmode;

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

function initForm_WLAN_Security_2g(){
	var wlanSSIDIdx, cur_wlanSSID, wlanBroadSSID;
	var wlanSecurityMode, wlanEncType, wlanKeyType, wlanWEPPSKKey, wlanWEPDefaultKeyIndex, wlanWPAKeyRenewInterval;
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable, wlanWEPPSKKey_backup;


		wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';		
		cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", 100); %>';
		cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);
		wlanBroadSSID = '<% mcr_getCfgWireless("Wlan_BroadSSID", 100); %>';
		
		wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", 100); %>';
		wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", 100); %>';
		
		wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", 100); %>';
		wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", 100); %>';
		wlanWEPPSKKey =  Xss_desubstitution(wlanWEPPSKKey);
		wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", 100); %>';
		wlanWEPPSKKey_backup =  Xss_desubstitution(wlanWEPPSKKey_backup);
		wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", 100); %>';
		
		wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", 100); %>';
		wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", 100); %>';
		wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", 100); %>';
		wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", 100); %>';
		
		wlanWPAKeyRenewInterval = '<% mcr_getCfgWireless("Wlan_WPARenewInterval", 100); %>';
		
		wlanWEPRekeyEnable = '<% mcr_getCfgWireless("Wlan_WepRekeyEnable", 100); %>';
		wlanMACAuthEnable = '<% mcr_getCfgWireless("Wlan_MacAuthEnable", 100); %>';
		
		wlanWMMEnable = '<% mcr_getCfgWireless("Wlan_WMMEnable", 100); %>';

		gWlanSSID_vap2_Activity = '<% mcr_getCfgWireless("Wlan_Enable", 102); %>';
		gWlanSSID_vap3_Activity = '<% mcr_getCfgWireless("Wlan_Enable", 103); %>';

	$("#wlanTitle").text("2.4GHz Home WLAN 접속 설정");
		
	$("#wlanSSIDIdx").val('100');
	$("input[name='wlanRadioActivity']").val([wlanRadioActivity]);  
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);
	
	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	$("#wlanWEPPSKKey_backup").val(wlanWEPPSKKey_backup);
	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
		$("#wlanWEPKey").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ||
		 wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15' ){
		$("#wlanPSKKey").val(wlanWEPPSKKey);
	}

	$("#wlanWEPKey").val(wlanWEPPSKKey);
	$("#wlanPSKKey").val(wlanWEPPSKKey);
	$("#wlanWPAKeyRenewInterval").val(wlanWPAKeyRenewInterval);
	$("#wlanEnable_org").val(wlanRadioActivity);

	$("input[name='wlanWEPKeyType']").val([wlanKeyType]);	
	$("input[name='wlanWEPKeyIndex']").val([wlanWEPDefaultKeyIndex]);	
	$("#wlanUIWEPKey0").val(wlanWEPKey0);
	$("#wlanUIWEPKey1").val(wlanWEPKey1);
	$("#wlanUIWEPKey2").val(wlanWEPKey2);
	$("#wlanUIWEPKey3").val(wlanWEPKey3);

	$("input[name='wlanWEPRekeyEnable']").val([wlanWEPRekeyEnable]);	
	$("input[name='wlanMACAuthEnable']").val([wlanMACAuthEnable]);	
	$("input[name='wlanWMMEnable']").val([wlanWMMEnable]);	
	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	cfg2web_WLAN_Security();

	$("#wlan_change").show();
	$("#wlan_ssid").show();
	document.getElementById("cur_wlanSSID").style.color = "#666666";
	document.form_simple.cur_wlanSSID.disabled = true;	
	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");

	document.getElementById("change_wlanSSID").value = "KT_GiGA_";
	$("#lbl_wireless_wlanSSID").text("KT_GiGA_ 뒤에 이어서 입력하세요.");
}
function initForm_WLAN_Security_5g(){
	var wlanSSIDIdx, cur_wlanSSID, wlanBroadSSID;
	var wlanSecurityMode, wlanEncType, wlanKeyType, wlanWEPPSKKey, wlanWEPDefaultKeyIndex, wlanWPAKeyRenewInterval;
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable, wlanWEPPSKKey_backup;


		wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';		
		cur_wlanSSID = '<% mcr_getCfgWireless("Wlan_SSID", 0); %>';
		cur_wlanSSID = Xss_desubstitution(cur_wlanSSID);
		wlanBroadSSID = '<% mcr_getCfgWireless("Wlan_BroadSSID", 0); %>';
		
		wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", 0); %>';
		wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", 0); %>';
		
		wlanKeyType = '<% mcr_getCfgWireless("Wlan_KeyType", 0); %>';
		wlanWEPPSKKey = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", 0); %>';
		wlanWEPPSKKey =  Xss_desubstitution(wlanWEPPSKKey);
		wlanWEPPSKKey_backup = '<% mcr_getCfgWireless("Wlan_WEPPSKKeyBackup", 0); %>';
		wlanWEPPSKKey_backup =  Xss_desubstitution(wlanWEPPSKKey_backup);
		wlanWEPDefaultKeyIndex = '<% mcr_getCfgWireless("Wlan_WEPDefaultKeyIndex", 0); %>';
		
		wlanWEPKey0 = '<% mcr_getCfgWireless("Wlan_WEPKey0", 0); %>';
		wlanWEPKey1 = '<% mcr_getCfgWireless("Wlan_WEPKey1", 0); %>';
		wlanWEPKey2 = '<% mcr_getCfgWireless("Wlan_WEPKey2", 0); %>';
		wlanWEPKey3 = '<% mcr_getCfgWireless("Wlan_WEPKey3", 0); %>';
		
		wlanWPAKeyRenewInterval = '<% mcr_getCfgWireless("Wlan_WPARenewInterval", 0); %>';
		
		wlanWEPRekeyEnable = '<% mcr_getCfgWireless("Wlan_WepRekeyEnable", 0); %>';
		wlanMACAuthEnable = '<% mcr_getCfgWireless("Wlan_MacAuthEnable", 0); %>';
		
		wlanWMMEnable = '<% mcr_getCfgWireless("Wlan_WMMEnable", 0); %>';

		gWlanSSID_vap2_Activity_5g = '<% mcr_getCfgWireless("Wlan_Enable", 2); %>';
		gWlanSSID_vap3_Activity_5g = '<% mcr_getCfgWireless("Wlan_Enable", 3); %>';


	$("#wlanTitle_5g").text("5GHz Home WLAN 접속 설정");
		
	$("#wlanSSIDIdx_5g").val('0');
	$("input[name='wlanRadioActivity_5g']").val([wlanRadioActivity]);  
	$("#cur_wlanSSID_5g").val(cur_wlanSSID);
	$("#wlanBroadSSID_5g").val(wlanBroadSSID);
	
	$("#wlanSecurityMode_5g").val(wlanSecurityMode);
	$("#wlanEncType_5g").val(wlanEncType);
	$("#wlanWEPPSKKey_backup_5g").val(wlanWEPPSKKey_backup);
	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
		$("#wlanWEPKey_5g").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ||
		 wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15' ){
		$("#wlanPSKKey_5g").val(wlanWEPPSKKey);
	}

	$("#wlanWEPKey_5g").val(wlanWEPPSKKey);
	$("#wlanPSKKey_5g").val(wlanWEPPSKKey);
	$("#wlanWPAKeyRenewInterval_5g").val(wlanWPAKeyRenewInterval);
	$("#wlanEnable_org_5g").val(wlanRadioActivity);

	$("input[name='wlanWEPKeyType_5g']").val([wlanKeyType]);	
	$("input[name='wlanWEPKeyIndex_5g']").val([wlanWEPDefaultKeyIndex]);	
	$("#wlanUIWEPKey0_5g").val(wlanWEPKey0);
	$("#wlanUIWEPKey1_5g").val(wlanWEPKey1);
	$("#wlanUIWEPKey2_5g").val(wlanWEPKey2);
	$("#wlanUIWEPKey3_5g").val(wlanWEPKey3);

	$("input[name='wlanWEPRekeyEnable_5g']").val([wlanWEPRekeyEnable]);	
	$("input[name='wlanMACAuthEnable_5g']").val([wlanMACAuthEnable]);	
	$("input[name='wlanWMMEnable_5g']").val([wlanWMMEnable]);	
	$("#wlanSecurityMode_5g").val(wlanSecurityMode);
	$("#wlanEncType_5g").val(wlanEncType);
	cfg2web_WLAN_Security_5g();

	
	$("#wlan_change_5g").show();
	$("#wlan_ssid_5g").show();
	document.getElementById("cur_wlanSSID_5g").style.color = "#666666";
	document.form_simple.cur_wlanSSID_5g.disabled = true;	
	$("#lbl_wireless_wlanUIPSKKey_5g").text("암호는 10자 이상 64자 이하여야 합니다.");

	document.getElementById("change_wlanSSID_5g").value = "KT_GiGA_5G_";
	$("#lbl_wireless_wlanSSID_5g").text("KT_GiGA_5G_ 뒤에 이어서 입력하세요.");
}

function initForm_WLAN(flag){
	initForm_WLAN_Security_2g();
	initForm_WLAN_Security_5g();

	$("#wlanRedirectPage").val("/new/UserFolder/2_simple_open_set_all.asp");
	$("#wlanViewWMM").hide();
	$("#wlanViewWMM_5g").hide();

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
	$("input[name='wlanUISecurityType']").bind( "click", function(){
		var ret = onClick_WLAN_SecurityType(null);
		
		changeTableAdmin();
		return ret;
	});
	
	$("input[name='wlanUIWPAType']").bind( "click", function(){
		var ret = onClick_WLAN_WPAType(null);
		return ret;
	});
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(0);
	});
	$("input[name='check_box_1']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(1);
	});
	
	$("#wlanUIWPAKeyRenewalEnable").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable(null);
	});

	/* 5G */
	$("input[name='wlanUISecurityType_5g']").bind( "click", function(){
		var ret = onClick_WLAN_SecurityType_5g(null);
		
		changeTableAdmin();
		return ret;
	});
	
	$("input[name='wlanUIWPAType_5g']").bind( "click", function(){
		var ret = onClick_WLAN_WPAType_5g(null);
		return ret;
	});

	$("#wlanUIWPAKeyRenewalEnable_5g").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable_5g(null);
	});
	$("input[name='check_box_2']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(3);
	});
	$("input[name='check_box_3']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(4);
	});
	/* 5G */

	$("#wlanBtnSecurity").bind( "click", function(){

		if(($("#change_wlanSSID").val() == "KT_GiGA_")){
			$("#wlanSSID").val($("#cur_wlanSSID").val());
		}else{
			$("#wlanSSID").val($("#change_wlanSSID").val());
		}
		if( ($("#change_wlanSSID_5g").val() == "KT_GiGA_5G_")){
			$("#wlanSSID_5g").val($("#cur_wlanSSID_5g").val());
		}else{
			$("#wlanSSID_5g").val($("#change_wlanSSID_5g").val());
		}

/* SHCHO - 여기부터 */
		var confirmed = true;
		var apply_flag = 0;
		var apply_flag_5g = 0;
		var Activity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
		var ret = 0;
		var ret_5g = 0;

		/* message */
		var msg_0_0     = "5Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다";
		var msg_100_0   = "2.4Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다";

		if(deviceRole != '2'){
			if(!form_simple.wlanUISecurityType[0].checked){
				if(form_simple.wlanUISecurityType[2].checked){//WEP
					apply_flag = 1;
				}else{ //WPA
					if((form_simple.wlanUIWPAType[1].checked && (form_simple.wlanUIWPAEncType[1].checked || form_simple.wlanUIWPAEncType[2].checked))){ // WPA2 - AES/TKIP-AES
						apply_flag = 0;
					}else if((form_simple.wlanUIWPAType[2].checked &&(form_simple.wlanUIWPAEncType[1].checked || form_simple.wlanUIWPAEncType[2].checked))){ //WPA-WPA2 - AES/TKIP-AES
						apply_flag = 0;
					}else{
						apply_flag = 1;
					}
				}
			}
			if(apply_flag == 0) {
				if(!form_simple.wlanUISecurityType_5g[0].checked){
					if(form_simple.wlanUISecurityType_5g[2].checked){//WEP
						apply_flag_5g = 1;
					}else{ //WPA
						if((form_simple.wlanUIWPAType_5g[1].checked && (form_simple.wlanUIWPAEncType_5g[1].checked || form_simple.wlanUIWPAEncType_5g[2].checked))){ // WPA2 - AES/TKIP-AES
							apply_flag_5g = 0;
						}else if((form_simple.wlanUIWPAType_5g[2].checked &&(form_simple.wlanUIWPAEncType_5g[1].checked || form_simple.wlanUIWPAEncType_5g[2].checked))){ //WPA-WPA2 - AES/TKIP-AES
							apply_flag_5g = 0;
						}else{
							apply_flag_5g = 1;
						}
					}
				}
			}

			if(apply_flag == 1 || apply_flag_5g == 1){
				if(mesh_enable == '0'){
					confirmed = confirm("지금 설정으로 변경 후에 Mesh 기능을 활성으로 설정 시에는 보안방식이 WPA&WPA2/TKIP&AES로 자동 변경됩니다. 계속하시겠습니까?");
					if(confirmed)
						$("#security_flag").val("0"); // mesh enable 설정
				}else{
					confirmed = confirm("Mesh 연결이 끊어지게 됩니다. 계속하시겠습니까?");
					if(confirmed)
						$("#security_flag").val("1"); // mesh disable 설정
				}
				if (!confirmed)
					return false;
			}
		}

		ret = validateOnSubmit_WLAN_SecurityType(null);
		ret_5g = validateOnSubmit_WLAN_SecurityType_5g(null);
		if(ret == true)  {
			//ret = confirm_main_Activity(100, getRadioSelectedValueByName("wlanRadioActivity"), 0);
			var e = $("input[name='wlanRadioActivity']:checked").val();
			if(e == '0') {
				if (MTK_WLAN_isNeedReboot() == true){
					ret = confirm(msg_100_0);
				}
			}
		}
		if(ret_5g == true){
			//ret_5g = confirm_main_Activity(0, getRadioSelectedValueByName("wlanRadioActivity_5g"), 0);
			var e = $("input[name='wlanRadioActivity_5g']:checked").val();
			if(e == '0') {
				if (MTK_WLAN_isNeedReboot_5g() == true){
					ret_5g = confirm(msg_0_0);
				}
			}
			if (ret_5g == true) {
				if(Activity == 1 && form_simple.wlanRadioActivity_5g[1].checked == true){
					ret_5g = confirm("IoW WLAN 접속 설정이 비활성화 됩니다. 계속하시겠습니까?");
				}else if(Activity == 0 && form_simple.wlanRadioActivity_5g[0].checked == true){
					ret_5g = confirm("IoW WLAN 접속 설정도 활성화 됩니다.");
				}
			}
		}

		if( ret == true && ret_5g == true){
			$("#wlanAction").val("wlanBtnSecurity");
			if(MTK_WLAN_isNeedReboot() == true|| MTK_WLAN_isNeedReboot_5g() == true) {
				$("#wlanReboot").val("1");
				parent.mcrProgress.startProgressSimple("apply", 50);
			}else{
				$("#wlanReboot").val("0");
				parent.mcrProgress.startProgressSimple("apply", 27);
			}
			$('#form_simple').attr("action", "/goform/mcr_KT_setWirelessSecurity_all").submit();
		}

		return false;
	});	

	$("input[name='wlanRadioActivity']").bind( "click", function(){
		if( MTK_WLAN_isNeedReboot() ){
			alert("활성여부가 변경되면 단말 재부팅 됩니다.");
		}
		return true;
	});
	$("input[name='wlanRadioActivity_5g']").bind( "click", function(){
		if( MTK_WLAN_isNeedReboot_5g() ){
			alert("활성여부가 변경되면 단말 재부팅 됩니다.");
		}
		return true;
	});

	$("input[name='opmode']").bind( "change", function(){
		var selId = $("input[name='opmode']:checked").attr("id");
		var macClone = "<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>";
		var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";
		
		if (macClone == "0" || selId == 'opmode2' || limit_cnt_en == "0") {
			document.form_simple.macCloneEnbl[1].checked = true;
			changeMacCloneTab();
		} else {
			document.form_simple.macCloneEnbl[0].checked = true;
			changeMacCloneTab();
		}
		if (selId == 'opmode2') {
			$("input[id='macCloneEnbl']").attr('disabled',true);
		} else {
			$("input[id='macCloneEnbl']").attr('disabled',false);
		}
		return true;
	});

	$("#change_wlanSSID").keyup(function(){
		var count = SaveCountBytes(this.value);
		if ( count > 32 ){
			if (event.keyCode != '8'){
				alert("최대 설정 글자수 입니다");
				this.value = this.value.substring(0, this.value.length-1);
			}
		}
	});
	$("#change_wlanSSID_5g").keyup(function(){
		var count = SaveCountBytes(this.value);
		if ( count > 32 ){
			if (event.keyCode != '8'){
				alert("최대 설정 글자수 입니다");
				this.value = this.value.substring(0, this.value.length-1);
			}
		}
	});

	$(document).mjq_disableSelection();
	$("input[type='text']").mjq_disableInputEnter();
	initValue();
});

function initForms(flag){
	initForm_WLAN(flag);
}

function macClone_act(macaddr) {
	document.form_simple.macCloneMac.value = macaddr;
}

function changeMacCloneTab() {
	if(document.form_simple.macCloneEnbl[0].checked) {
		$("#macCloneMacRow").show();
		$("#macCloneList").show();
	} 
	else if(document.form_simple.macCloneEnbl[1].checked) {
		$("#macCloneMacRow").hide();
		$("#macCloneList").hide();
	}
	changeTableAdmin();
}

function setMacClone(url) {
	if ( document.form_simple.macCloneEnbl[0].checked == true)
	{
		if (document.form_simple.macCloneMac.value != "") {
			var re = /[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}/;
			if (re.test(document.form_simple.macCloneMac.value)) { 
				document.form_simple.redirect_url.value = "/new/UserFolder/2_simple_open_set_all.asp"
				form_act(url);
				document.form_simple.redirect_url.value = "/new/UserFolder/3_7_8_system_restart_process.asp"
				return false;
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
	else {
		document.form_simple.redirect_url.value = "/new/UserFolder/2_simple_open_set_all.asp"
		form_act(url);
		document.form_simple.redirect_url.value = "/new/UserFolder/3_7_8_system_restart_process.asp"
		return false;
	}
}


function initValue(){
	var network = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>";
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
	var macClone = "<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>";
	var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";
	
	parent.mcrProgress.stopProgress();

	if(opmode == "1" && network == "0") {
		form_simple.opmode[0].checked = true;
		org_opmode = 0;
	}
	else {
		if(opmode == "1"){
			form_simple.opmode[1].checked = true;
			org_opmode = 1;
		}else{
			form_simple.opmode[2].checked = true;
			org_opmode = 2;
			$("input[id='macCloneEnbl']").attr('disabled',true);
		}
	}	
	
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	changeTableAdmin();
	
	$("input[name='opmode']:checked").trigger("change");
	
	initForm_WLAN(0);
	
	if(opmode != "0"){
		if (macClone == "0" || limit_cnt_en == "0") {
			document.form_simple.macCloneEnbl[1].checked = true;
			document.form_simple.macCloneMac.value = "";
			changeMacCloneTab();
		}
		else {
			document.form_simple.macCloneEnbl[0].checked = true;
			changeMacCloneTab();
		}

		if(limit_cnt_en == "0") {
			$("#opmode2").attr('disabled',true);
			$("input[id='macCloneEnbl']").attr('disabled',true);
		} else {
			$("#opmode2").attr('disabled',false);
			$("input[id='macCloneEnbl']").attr('disabled',false);
		}
	}
}

function validateOnSubmit_IPAlloc()
{
	var confirmed;
	var flag=0;
	var NetKeepEn = "<% mcr_getCfgString("NetKeepCfgParam_Enable"); %>";
	var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
        if ( document.form_simple.macCloneEnbl[0].checked == true)
        {
                if (document.form_simple.macCloneMac.value != "") {
                        var re = /[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}/;
                        if (re.test(document.form_simple.macCloneMac.value)) { 
                                document.form_simple.redirect_url.value = "/new/UserFolder/2_simple_open_set_all.asp"
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

	if(document.form_simple.opmode[0].checked == true) {
		if (org_opmode != 0) {
			$("#opmodeChgFlag").val("1");
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
			if (!confirmed)
				return false;
		} else {
			$("#opmodeChgFlag").val("0");
		}
		flag=1;
	}
	else if(document.form_simple.opmode[1].checked == true) {
		if (org_opmode != 1) {
			$("#opmodeChgFlag").val("1");
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
			if (!confirmed)
				return false;
		} else {
			$("#opmodeChgFlag").val("0");
		}
		flag=1;
	}
	else if(document.form_simple.opmode[2].checked == true) {
		if(waninterface == "1") {
			confirmed = confirm("리피터 모드를 해지하려면 재부팅이 필요합니다. 모드를 변경하시겠습니까? ");
			if(!confirmed)
				return false;

			$("#opmodeChgFlag").val("1");
			flag = 1;
		} else {
			if (org_opmode != 2) {
				$("#opmodeChgFlag").val("1");
				if(NetKeepEn == "1"){
					confirmed = confirm("브릿지 모드 설정 시, 스마트 스케쥴러 설정은 사용할 수 없습니다. 계속하시겠습니까?");
					if(!confirmed){
						return false;
					}
					confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
					if (!confirmed)
						return false;
					flag=1;

				}else{
					confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
					if (!confirmed)
						return false;
					flag=1;
				}
			} else {
				$("#opmodeChgFlag").val("0");
			}
		}	
	}	

	if(flag==1){
		parent.mcrProgress.startProgressSimple("apply", 25);
	}

        document.form_simple.action = '/goform/mcr_KT_setSimpleConfig';
        document.form_simple.submit();

	return false;
}

function form_act(url){
	form_simple.action = url;
	form_simple.submit();
	return false;
}

/*
function changeAuthSecurity(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanIfIndex%100))){
		if(value != 2){
			alert("mesh가 설정된 경우, 인증 보안 WPA-PSK 이외는 설정할 수 없습니다.");
			document.getElementsByName("wlanUISecurityType")[3].checked = true;
			return false;
		}
	}
}

function changeWpaMode(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanIfIndex%100))){
		if(value != 1){
			alert("mesh가 설정된 경우, WPA Mode는 WPA2  이외는 설정할 수 없습니다.");
			document.getElementsByName("wlanUIWPAType")[1].checked = true;
			return false;
		}
	}
}
function changeWpaEnc(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanIfIndex%100))){
		if(value != 1){
			alert("mesh가 설정된 경우, Encryption는 AES 이외는 설정할 수 없습니다.");
			document.getElementsByName("wlanUIWPAEncType")[1].checked = true;
			return false;
		}
	}
}
*/
</script>

<script>
	function changeTableAdmin() {
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
<form method="post" name="form_simple" id="form_simple">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>
<input type="hidden" id="wlanSSID" name="wlanSSID" value=""/>
<input type="hidden" id="wlanSSID_5g" name="wlanSSID_5g" value=""/>
<input type="hidden" id="wlanReboot" name="wlanReboot" value=""/>
<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value=""/>
<input type="hidden" id="wlanSSIDIdx_5g" name="wlanSSIDIdx_5g" value=""/>
<input type="hidden" id="wlanBroadSSID" name="wlanBroadSSID" value=""/>
<input type="hidden" id="wlanBroadSSID_5g" name="wlanBroadSSID_5g" value=""/>
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value=""/>
<input type="hidden" id="wlanSecurityMode_5g" name="wlanSecurityMode_5g" value=""/>
<input type="hidden" id="wlanEncType" name="wlanEncType" value=""/>
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value=""/>
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value=""/>
<input type="hidden" id="wlanWEPPSKKey_backup" name="wlanWEPPSKKey_backup" value=""/>
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value=""/>
<input type="hidden" id="wlanEncType_5g" name="wlanEncType_5g" value=""/>
<input type="hidden" id="wlanWEPKey_5g" name="wlanWEPKey_5g" value=""/>
<input type="hidden" id="wlanPSKKey_5g" name="wlanPSKKey_5g" value=""/>
<input type="hidden" id="wlanWEPPSKKey_backup_5g" name="wlanWEPPSKKey_backup_5g" value=""/>
<input type="hidden" id="wlanWPAKeyRenewInterval_5g" name="wlanWPAKeyRenewInterval_5g" value=""/>
<input type="hidden" id="wlanAction" name="wlanAction" value=""/>
<input type="hidden" id="opmodeChgFlag" name="opmodeChgFlag" value=""/>

<input type=hidden name=SETIPMODE value="/new/UserFolder/2_simple_open_set_all.asp" />
<input type="hidden" name="redirect_url" id="redirect_url" value="/new/UserFolder/3_7_8_system_restart_process.asp" />
<input type="hidden" name="redirect_admWanSet" id="redirect_admWanSet" value="/new/UserFolder/2_simple_open_set_all.asp" />
<input type="hidden" id="wlanEnable_org" name="wlanEnable_org" value=""/>
<input type="hidden" id="wlanEnable_org_5g" name="wlanEnable_org_5g" value=""/>

<input type="hidden" id="wirelessOperMode" name="wirelessOperMode" value="0"/>
<input type="hidden" id="security_flag" name="security_flag" value=""/>

<table width="800" border="0" cellspacing="0" cellpadding="10" bgcolor="#FFFFFF">
	<tr>
		<td>
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5"> IP 할당정책</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1" bgcolor="#ffffff">
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td>
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
													<td class="BG2" width="100">IP 할당정책</td>
													<td class="BG2-2">
														<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
															<tr>
																<td width="100">
																	<input name="opmode" type="radio" id="opmode" value="0" />
																	kt 모드
																</td>
																<td width="100">
																	<input name="opmode" type="radio" id="opmode1" value="1"  />
																	공유기 모드
																</td>
																<td>
																	<input name="opmode" type="radio" id="opmode2" value="2" />
																	브릿지 모드
																</td>
															</tr>
														</table>
													</td>
												</table>
											</td>
										</tr>
										<tr>
											<td>
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td class="BG2" width="100">MAC Clone 활성</td>
														<td class="BG2-2">
															<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr id="view_macClone">
																	<td width="100">
																		<input name="macCloneEnbl" type="radio" id="macCloneEnbl" value="1" onClick="changeMacCloneTab()" />활성
																	</td>
																	<td>
																		<input name="macCloneEnbl" type="radio" id="macCloneEnbl1" value="0" onClick="changeMacCloneTab()" />비활성
																	</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
	
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr id="macCloneMacRow" style="display:none">
					<td>
						<table width="780" border="0" class="font1 TB">
							<tr>
								<td class="BG2" width="100">MAC  Clone 주소</td>
								<td class="BG2-2">
									<table width="350" border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="350">
												<input type="text" id="macclone_fake" name="macclone_fake" autocomplete="off" style="display: none;">
												<input name="macCloneMac" type="text" class="input2-1" id="macCloneMac" value="<% mcr_getCfgInterface("MacCloneCfgParam_LanMac"); %>" />
											</td>
										</tr>
									</table>
								</td>
								<td width="283"></td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="macCloneList" style="display:none">
					<td class="PD6">
						<table width="780" border="0" cellspacing="0" cellpadding="0">       
							<tr height="20">
								<td width="490" >
									<table width="490" border="0" cellpadding="0" cellspacing="0" class="fix">
										<tr>
											<td>
												<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
												<table class="TB" width="100%" border="0" style="table-layout:fixed;">
													<col width="30">
													<col width="170">
													<col width="110">
													<col width="130">
													<col width="50">
													<tr height="20">
														<td class="BG1">
															<p style="font-size:9pt; border-width:1px; border-style:none;">
																	선택
															</p>
														</td>
														<td class="BG1">
															<p>PC 이름</p>
														</td>
														<td class="BG1">
															<p>IP 주소</p>
														</td>
														<td class="BG1">
															<p>MAC 주소</p>
														</td>
														<td class="BG1">
															<p>상태</p>
														</td>
													</tr>
												</table>
												</span>
											</td>
										</tr>
									</table>
								</td>
							</tr>

							<tr height="106">
								<td width="100%" valign="top">
									<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<table class="TB" id="Grid_Table" width="490" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
										<col width="30" align="center">
										<col width="170">
										<col width="110">
										<col width="130">
										<col width="50" align="center">

										<%
											var i;
											var rule_num = mcr_getMacInfoCount(0);

											if (rule_num > 0) {
												for ( i = 0; i < rule_num; i++ ){
													write("<tr bgcolor=#FFFFFF>");
								
													write("<td class=BG2-2 style='padding-left:0px;' align='middle'>");
													write("<input name=DR type=radio onClick=macClone_act(\""+mcr_getMacInfoList(i,2)+"\") >");
													write("</td>");
									
													write("<td class=BG2-2 style='padding-left:0px;' align='middle'>");
													write("<p>");write(mcr_getMacInfoList(i,0));write("</p>");
													write("</td>");
									
													write("<td class=BG2-2 style='padding-left:0px;' align='middle'>");
													write("<p>");write(mcr_getMacInfoList(i,1));write("</p>");
													write("</td>");
									
													write("<td class=BG2-2 style='padding-left:0px;' align='middle'>"); 
													write("<p>");write(mcr_getMacInfoList(i,2));write("</p>"); 
													write("</td>");
									
													write("<td class=BG2-2 style='padding-left:0px;' align='middle'>"); 
													write("<p>");write(mcr_getMacInfoList(i,3));write("</p>"); 
													write("</td>");
													write("</tr>\n");
												}
											}
											else {
												write("<tr bgcolor=#FFFFFF>");
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
			<table width="98%" border="0" cellspacing="0" cellpadding="0">	
				<tr>
					<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply" onclick="return validateOnSubmit_IPAlloc();"/></td>
				</tr>
			</table>
		</td>
	</tr>

	<tr>
		<td>
			<%include('new/common_wlan_security_common_2g.asp');%>
		</td>
	</tr>

	<tr>
		<td>
			<%include('new/common_wlan_security_common_5g.asp');%>
		</td>
	</tr>

	<table width="98%" border="0" cellspacing="0" cellpadding="0">	
		<tr>
			<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" value="wlanBtnSecurity" id="wlanBtnSecurity" name="wlanBtnSecurity" width="52" height="24"></td>
		</tr>
	</table>

	<tr>
		<td class>
			<table width="97%" border="0" cellspacing="0" cellpadding="0" align="center">
				<tr>
					<td class="font5">시스템 재시동</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						<table class="TB" width="100%" border="0">
							<tr>
								<td height="25"><input type="image" src="/images/BTN/BTN_21.gif?Sp2" width="99" height="24" value="Apply2" id="btn_apply2" name="btn_apply2" onclick="form_act('/goform/mcr_setRestart'); return false;"/></td>
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
