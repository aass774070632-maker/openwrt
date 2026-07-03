<html>
<head>
<%include('new/metatag.asp');%>
<title>SoIP 접속 설정</title>
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

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
// var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
// var wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
// var wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>';
<%
	var gWlanSSIDIndexEJ;
	if ( gWlanIfIndexEJ == '0' )
		gWlanSSIDIndexEJ = '1';
	else
		gWlanSSIDIndexEJ = '101';
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
	$("#wlanUIMenu12").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	
	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	$("input[name='wlanRadioActivity']").val([wlanRadioActivity]);	
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);
	
	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);
	$("#wlanWPAKeyRenewInterval").val(wlanWPAKeyRenewInterval);
	
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
	$("#wlanWEPPSKKey_backup").val(wlanWEPPSKKey_backup);

	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
	$("#wlanWEPKey").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ||
	 	wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15' ){
	$("#wlanPSKKey").val(wlanWEPPSKKey);
	}
	cfg2web_WLAN_Security();

	        
        document.getElementById("cur_wlanSSID").style.color = "#666666";
        document.form_security.cur_wlanSSID.disabled = true;      

        $("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
	document.getElementById("change_wlanSSID").value = "KT_GiGA_Mesh_";
	$("#lbl_wireless_wlanSSID").text("KT_GiGA_Mesh_ 뒤에 이어서 입력하세요.");
	
	if(wlanSSIDIdx == 101){
		$("#wlanViewWPA").hide();
		$("#wlanViewWMM").hide();
		$("#main_ssid").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewSecure").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlan_change").hide();
	}else if(wlanSSIDIdx == 1){
		$("#wlan_change").show();
		$("#wlanViewWMM").show();
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
	$("input[name='wlanUISecurityType']").bind( "click", function(){
		var ret = onClick_WLAN_SecurityType(null);
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

//	$("input[name='wlanRadioActivity']").bind( "click", function(){
//		if(mesh_enable == '0' && gWlanSSIDIndex == '1') {
//			var ret = onClick_WLAN_Enable(null);
//			return ret;
//		}
//	});
	
	$("#form_security").bind( "submit", function(){
		return validateOnSubmit();
	});

	$("#change_wlanSSID").keyup(function(){
                var count = SaveCountBytes(this.value);
                if ( count > 32 ){
                        if (event.keyCode != '8'){
                                alert("최대 설정 글자수 입니다.");
                                this.value = this.value.substring(0, this.value.length-1);
                        }
                }
        });

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

	$("input[name='wlanBtnSecurity']").bind( "click", function(){
		var ret = onClick_WLANMode(null);
		return ret;
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
		if(!form_security.wlanUISecurityType[0].checked){
			if(form_security.wlanUISecurityType[2].checked){//WEP
				apply_flag = 1;
			}else{ //WPA - PSK
				if((form_security.wlanUIWPAType[1].checked && (form_security.wlanUIWPAEncType[1].checked || form_security.wlanUIWPAEncType[2].checked))){ // WPA2 - AES/TKIP-AES
					apply_flag = 0;
				}else if((form_security.wlanUIWPAType[2].checked &&(form_security.wlanUIWPAEncType[1].checked || form_security.wlanUIWPAEncType[2].checked))){ //WPA-WPA2 - AES/TKIP-AES
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
			}else{ //WPA - PSK
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

function onClick_WLANMode(){
	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_MapEnable","-1"); %>';
	if (form_security.wlanRadioActivity[0].checked) {
		if(!onClick_MeshPopUpSet()) {
		 	return false;
		}
	} else if((form_security.wlanRadioActivity[1].checked && gWlanSSIDIndex == '1') ) {
		$("#mesh_en").val(mesh_enable);
		alert("비활성화시, Mesh 연결이 끊어집니다.");
		return true;
	}
}

function validateOnSubmit(){
	if($("#change_wlanSSID").val() == "KT_GiGA_Mesh_"){
		$("#wlanSSID").val($("#cur_wlanSSID").val());
	}else{
		$("#wlanSSID").val($("#change_wlanSSID").val());
	}
	var ret = validateOnSubmit_WLAN_SecurityType(null);
	if( ret == true ){
		parent.mcrProgress.startProgressSimple("apply", 27);
	}
	return ret;
}

function initForms(flag){
	initForm_WLAN_Security(flag);
}

function roamingFormDisable(setFlag){
	$("input[name='wlanUIPSKKeyType']").prop("disabled", setFlag);
	$("input[name='wlanUISecurityType']").prop("disabled", setFlag);
	$("input[name='wlanWEPRekeyEnable']").prop("disabled", setFlag);
	$("input[name='wlanMACAuthEnable']").prop("disabled", setFlag);
	$("input[name='wlanUIWEPEncType']").prop("disabled", setFlag);
	$("input[name='wlanUIWEPKeyLen']").prop("disabled", setFlag);
	$("input[name='wlanWEPKeyType']").prop("disabled", setFlag);
	$("input[name='wlanWEPKeyIndex']").prop("disabled", setFlag);
	$("input[name='wlanUIWPAType']").prop("disabled", setFlag);
	$("input[name='wlanUIWPAEncType']").prop("disabled", setFlag);
	$("input[name='wlanWMMEnable']").prop("disabled", setFlag);
	$("input[name='wlanWauthEnable']").prop("disabled", setFlag);
	$("input[name='wlanRedirectSet']").prop("disabled", setFlag);
	$("input[name='wlanRedirectSet']").prop("disabled", setFlag);

	$("input[type='text']").prop("disabled", setFlag);
	$("input[type='password']").prop("disabled", setFlag);
	$("input[type='checkbox']").prop("disabled", setFlag);
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
		$("input[name='wlanRadioActivity']").prop("disabled", true);
		$("#wlanBtnSecurity").hide();
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
		if( bInactive ){
			$("input[type='radio']").prop("disabled", true);
			$("input[type='text']").prop("disabled", true);
			$("input[type='password']").prop("disabled", true);
			$("input[type='checkbox']").prop("disabled", true);

			$("#wlanBtnSecurity").hide();
		}		
		return false;
	}
	return true;
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();

	initForms(0);

	changeTableAdmin();
}

/*
function changeAuthSecurity(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanSSIDIndex%100))){
		if(value != 2){
			alert("mesh가 설정된 경우, 인증 보안 WPA-PSK 이외는 설정할 수 없습니다.");
			document.getElementsByName("wlanUISecurityType")[3].checked = true;
			return false;
		}
	}
}

function changeWpaMode(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanSSIDIndex%100))){
		if(value != 1){
			alert("mesh가 설정된 경우, WPA Mode는 WPA2  이외는 설정할 수 없습니다.");
			document.getElementsByName("wlanUIWPAType")[1].checked = true;
			return false;
		}
	}
}
function changeWpaEnc(value){
	if(mesh_enable == 1 && (mesh_index == (gWlanSSIDIndex%100))){
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
<form method="post" class="form_layout" id="form_security" name="form_security" action="/goform/mcr_KT_setWirelessMeshSecurity">

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>
<input type="hidden" id="wlanSSID" name="wlanSSID" value=""/>
<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value=""/>
<input type="hidden" id="wlanBroadSSID" name="wlanBroadSSID" value=""/>
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value=""/>
<input type="hidden" id="wlanEncType" name="wlanEncType" value=""/>
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value=""/>
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value=""/>
<input type="hidden" id="wlanWEPPSKKey_backup" name="wlanWEPPSKKey_backup" value=""/>
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value=""/>

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
					<td valign="top" >
						<%include('new/common_wlan_security_common.asp');%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
