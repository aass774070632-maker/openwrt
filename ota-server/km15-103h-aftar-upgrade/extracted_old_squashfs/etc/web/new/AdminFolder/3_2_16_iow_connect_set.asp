<html>
<head>
<%include('new/metatag.asp');%>
<title>IoW 접속 설정</title>
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
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var arrData = new Array();

<%
	var gWlanSSIDIndexEJ;
	if ( gWlanIfIndexEJ == '0' )
		gWlanSSIDIndexEJ = '4';
%>

if( gWlanIfIndex == '0' ){
	gWlanSSIDIndex = '4';
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
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3, wlanWEPPSKKey_backup;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable,wlan_count;

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
		wlan_count = '<% mcr_getCfgWireless("Wlan_StaAssociationCount", gWlanSSIDIndexEJ); %>';
	}

	$("#wlanTitle").text("IoW WLAN 접속 설정");
	$("#wlanUIMenu24").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	
	$("#wlanSSIDIdx").val(wlanSSIDIdx);
	$("input[name='wlanRadioActivity']").val([wlanRadioActivity]);	
	$("#cur_wlanSSID").val(cur_wlanSSID);
	$("#wlanBroadSSID").val(wlanBroadSSID);
	
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
	initComboById("stb_num", wlan_count);

	        
        $("#wlan_change").show();
        document.getElementById("cur_wlanSSID").style.color = "#666666";
        document.form_security.cur_wlanSSID.disabled = true;      

        $("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
        if(wlanSSIDIdx == 4){
                document.getElementById("change_wlanSSID").value = "KT_GiGA_5G_IPTV_";
                $("#lbl_wireless_wlanSSID").text("KT_GiGA_5G_IPTV_ 뒤에 이어서 입력하세요.");
		$("#stb_info").show();
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

function processHttpResponse(strResponse) {
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	if(lineArr[0] == ""){
		arrData = [];
	} else {
		for( var row =0; row < lineArr.length-rowOnly; row++) {
			arrData[row] = lineArr[row];
		}
	}
}
function onClickRefresh(){
	httpRequest("/goform/mcr_getOffchanScan", "n/a", processHttpResponse);
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
	
	$("input[name='btn_refresh']").bind("click", function() {
		onClickRefresh();
		return false;
	});
	
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

	initValue();
});

function checkIoWChannelRange(){
	var ret = 1;
	//IOW 설정상태 확인 DB

	channelStr = '<% mcr_getCfgWireless("Wlan_Channel", 0); %>';   
	autoChannelRangeStr = '<% mcr_getCfgWireless("Wlan_AutoChannelRange",0); %>';

	var channel = parseInt( channelStr, 10 );
	var autoChannelRange = parseInt( autoChannelRangeStr, 10 );

	if( channel  != 0  ){    //수동
		if( channel > 48 && channel < 149 ){
			ret = 0;
		}
	}else{
		if( autoChannelRange & (1<<30) ){    //auto(select)
			if( isDFSRange(autoChannelRange) == 1 ){
				ret = 0;
			}
			// if( ( autoChannelRange & Channel_5G_BITMASK_DFS ) != 0 && (autoChannelRange & Channel_5G_BITMASK_NONDFS) == 0){
			// 	ret = 0;
			// }
		}else{    //auto
			// no need check
			ret = 1;
		}
	}
	return ret;
}


function validateOnSubmit(){
	var confirmed = false;
	var confirmed1 = false;
	var bs_enable = '<% mcr_getCfgWireless("Wlan_BS_Enable", "-1"); %>';
	var en = document.form_security.wlanRadioActivity[0].checked;
	var cur_en = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';
	var wlanIOWActivity = '<% mcr_getCfgWireless("Wlan_IOW_Enable", "-1"); %>';
	var IOWEnable = '<% mcr_getCfgWireless("Wlan_Enable_4", "-1"); %>';

	if(form_security.wlanRadioActivity[1].checked == true){
		if(wlanIOWActivity == 1){
			confirmed = confirm("IoW 설정이 비활성화 됩니다. 계속하시겠습니까?");
			if(!confirmed)
				return false;
		}
	}
	
	if(form_security.wlanRadioActivity[0].checked == true){
		if(wlanIOWActivity == 0){
			if(checkIoWChannelRange() != 1 ){
				confirmed = confirm("설정된 채널에서 IoW 동작이 원활하지 않을 수 있습니다. 계속하시겠습니까?");
				if(!confirmed)
					return false;
			}
			confirmed = confirm("IoW 설정도 활성화 됩니다. 계속하시겠습니까?");
			if(!confirmed)
				return false;
		}
	}
	
	if($("#change_wlanSSID").val() == "KT_GiGA_5G_IPTV_"){
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
	/*if( radioActivity == '0' ){
		if( gWlanIfIndex == '0' ){
			alert("5Ghz Root Ssid가 비활성화 상태입니다.");
		}else{
			alert("2.4Ghz Root Ssid가 비활성화 상태입니다.");
		}
		$("input[name='wlanRadioActivity']").prop("disabled", true);
		$("#wlanBtnSecurity").hide();
		return false;
	}
	*/
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
		}else if( gWlanSSIDIndex == '4' || gWlanSSIDIndex == '104' ){
			alert("리피터 모드 설정 시 IoW설정을 할 수 없습니다.");
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

	checkWirelessActivity();

	changeTableAdmin();

	onClickRefresh();
	
}
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
