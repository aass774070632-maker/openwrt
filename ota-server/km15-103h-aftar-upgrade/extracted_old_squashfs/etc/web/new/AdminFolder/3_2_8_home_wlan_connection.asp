<html>
<head>
<%include('new/metatag.asp');%>
<title>Home WLAN 접속 설정</title>
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

<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

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
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3, wlanWEPPSKKey_backup;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable;
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
	$("#wlanUIMenu13").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	
	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	$("input[name='wlanRadioActivity']").val([wlanRadioActivity]);	
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);
	
	$("#wlanSecurityMode").val(wlanSecurityMode);
	$("#wlanEncType").val(wlanEncType);

	$("#wlanEnable_org").val(wlanRadioActivity);
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
	 	wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15'){
	$("#wlanPSKKey").val(wlanWEPPSKKey);
	}
	cfg2web_WLAN_Security();

	
	$("#wlan_change").show();
	document.getElementById("cur_wlanSSID").style.color = "#666666";
	document.form_security.cur_wlanSSID.disabled = true;      

	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
	if(wlanSSIDIdx == 100){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_";
		$("#lbl_wireless_wlanSSID").text("KT_GiGA_ 뒤에 이어서 입력하세요.");
	}else if(wlanSSIDIdx == 0){
		document.getElementById("change_wlanSSID").value = "KT_GiGA_5G_";
		$("#lbl_wireless_wlanSSID").text("KT_GiGA_5G_ 뒤에 이어서 입력하세요.");
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

	// $("input[name='wlanUIWPAEncType']").bind( "click", function(){
	// 	//do something
	// });
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(0);
	});
	$("input[name='check_box_1']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(1);
	});

	$("#wlanUIWPAKeyRenewalEnable").bind( "click", function(){
		return onClick_WLAN_SecurityWPAKeyRenewalEnable(null);
	});
	
	$("#form_security").bind( "submit", function(){
		return validateOnSubmit();
	});
	$("input[name='wlanRadioActivity']").bind( "click", function(){
		if( MTK_WLAN_isNeedReboot() ){
			alert("활성여부가 변경되면 단말 재부팅 됩니다.");	
		}
		return true;
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

	initValue();
});


function validateOnSubmit(){
	var wlanSSIDIdx = gWlanIfIndex;
	var Activity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
	var wlanSecurityMode_main = '<% mcr_getCfgWireless("Wlan_SecurityMode_0", "-1"); %>';
	var wlanEncType_main = '<% mcr_getCfgWireless("Wlan_EncryptType_0", "-1"); %>';
	var confirmed = true;
	var apply_flag = 0;
	if(($("#change_wlanSSID").val() == "KT_GiGA_") || ($("#change_wlanSSID").val() == "KT_GiGA_5G_")){
		$("#wlanSSID").val($("#cur_wlanSSID").val());
	}else{
		$("#wlanSSID").val($("#change_wlanSSID").val());
	}
	if(deviceRole != '2'){
		if(!form_security.wlanUISecurityType[0].checked){
			if(form_security.wlanUISecurityType[2].checked){//WEP
				apply_flag = 1;
			}else{ //WPA
				if((form_security.wlanUIWPAType[1].checked && (form_security.wlanUIWPAEncType[1].checked || form_security.wlanUIWPAEncType[2].checked))){ // WPA2 - AES/TKIP-AES
					apply_flag = 0;
				}else if((form_security.wlanUIWPAType[2].checked &&(form_security.wlanUIWPAEncType[1].checked || form_security.wlanUIWPAEncType[2].checked))){ //WPA-WPA2 - AES/TKIP-AES
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
	var ret = validateOnSubmit_WLAN_SecurityType(null);
	if( ret == true ){
		var vapEnable = 0;
		if( gWlanSSID_vap2_Activity =='1' || gWlanSSID_vap3_Activity =='1' ){
			vapEnable = 1;
		}
		ret = confirm_main_Activity(gWlanIfIndex,
			getRadioSelectedValueByName("wlanRadioActivity"), vapEnable );

	}
	
	if(ret == true && wlanSSIDIdx == 0){
		if(Activity == 1 && form_security.wlanRadioActivity[1].checked == true){
			ret = confirm("IoW WLAN 접속 설정이 비활성화 됩니다. 계속하시겠습니까?");
		}else if(Activity == 0 && form_security.wlanRadioActivity[0].checked == true){
			ret = confirm("IoW WLAN 접속 설정도 활성화 됩니다.");
		}
	}
	
	if( ret == true ){
		if( MTK_WLAN_isNeedReboot() ){
			$("#wlanReboot").val("1");
			parent.mcrProgress.startProgressSimple("apply", 50);
		}else{
			$("#wlanReboot").val("0");
			parent.mcrProgress.startProgressSimple("apply", 40);
		}
	}
	return ret;
}

function initForms(flag){
	initForm_WLAN_Security(flag);
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();

	initForms(0);
	
	changeTableAdmin();
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
<form method="post" class="form_layout" id="form_security" name="form_security" action="/goform/mcr_KT_setWirelessSecurity">

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
<input type="hidden" id="wlanEnable_org" name="wlanEnable_org" value=""/>
<input type="hidden" id="wlanReboot" name="wlanReboot" value=""/>
<input type="hidden" id="security_flag" name="security_flag" value=""/>

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
