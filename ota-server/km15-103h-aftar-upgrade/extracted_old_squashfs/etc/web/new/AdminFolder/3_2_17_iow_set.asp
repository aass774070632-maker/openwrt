<html>
<head>
<%include('new/metatag.asp');%>
<title>IoW 설정</title>
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

function initForm_WLAN_Security(flag){
	var wlanIOWActivity, iow_OnChannel_MonInterval, iow_OnChannelTh_OBSS, iow_OnChannelTh_Traffic, iow_OffChannel_MaxLoopCnt, iow_NewChannel_StayTime;
	var wlanSSIDIdx, wlanRadioActivity, cur_wlanSSID, wlanBroadSSID;
	var wlanSecurityMode, wlanEncType, wlanKeyType, wlanWEPPSKKey, wlanWEPDefaultKeyIndex, wlanWPAKeyRenewInterval;
	var wlanWEPKey0, wlanWEPKey1, wlanWEPKey2, wlanWEPKey3;
	var wlanWEPRekeyEnable, wlanMACAuthEnable;
	var wlanWMMEnable;

	if( flag == 0 ){
		wlanIOWActivity = '<% mcr_getCfgWireless("Wlan_IOW_Enable", "-1"); %>';
		iow_OnChannel_MonInterval = '<% mcr_getCfgWireless("Wlan_IOW_OnChannel_MonInterval", "-1"); %>';
		iow_OnChannelTh_OBSS = '<% mcr_getCfgWireless("Wlan_IOW_OnChannelTh_OBSS", "-1"); %>';
		iow_OnChannelTh_Traffic = '<% mcr_getCfgWireless("Wlan_IOW_OnChannelTh_Traffic", "-1"); %>';
		iow_OffChannel_MaxLoopCnt = '<% mcr_getCfgWireless("Wlan_IOW_OffChannel_MaxLoopCnt", "-1"); %>';
		iow_NewChannel_StayTime = '<% mcr_getCfgWireless("Wlan_IOW_NewChannel_StayTime", "-1"); %>';

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
	}

	$("input[name='wlanIOWActivity']").val([wlanIOWActivity]);
	$("input[name='iow_OnChannel_MonInterval']").val([iow_OnChannel_MonInterval]);
	$("input[name='iow_OnChannelTh_OBSS']").val([iow_OnChannelTh_OBSS]);
	$("input[name='iow_OnChannelTh_Traffic']").val([iow_OnChannelTh_Traffic]);
	$("input[name='iow_OffChannel_MaxLoopCnt']").val([iow_OffChannel_MaxLoopCnt]);
	$("input[name='iow_NewChannel_StayTime']").val([iow_NewChannel_StayTime]);

	$("#wlanTitle").text("IoW 접속 설정");
	$("#wlanUIMenu25").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	
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

	if( wlanSecurityMode == '1' || wlanSecurityMode == '2' || wlanSecurityMode == '3' ){
		$("#wlanWEPKey").val(wlanWEPPSKKey);
	}else if( wlanSecurityMode == '4' || wlanSecurityMode == '5' || wlanSecurityMode == '6' ||
		wlanSecurityMode == '13' || wlanSecurityMode == '14' || wlanSecurityMode == '15'){
		$("#wlanPSKKey").val(wlanWEPPSKKey);
	}
	iow_check(wlanIOWActivity);

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

function initTable_offchan(){
	var row;
	if(arrData.length != 0 ) {
		for(var i = 0; i < arrData.length; i++ ) {
			var part_str = arrData[i].split('|');
				row += "<tr bgcolor='#FFFFFF' style='text-align:center;'>";
				row += "<td class='BG2-2'>"+part_str[0]+"</td>";
				row += "<td class='BG2-2'>"+part_str[2]+"</td>";
				row += "<td class='BG2-2'>"+part_str[1]+"</td>";
				row += "<td class='BG2-2'>"+part_str[3]+"</td>";
				row += "<td class='BG2-2'>"+part_str[4]+"</td>";
				row += "<td class='BG2-2'>"+part_str[5]+"</td>";
				row += "<td class='BG2-2'>"+part_str[6]+"</td>";
				row += "</tr>"
			}
		} else {
			row += "<tr bgcolor='#FFFFFF' style='text-align:center;' >";
			row += "<td colspan='8' class='BG2-2'>접속된 단말이 없습니다.</td>";
			row += "</tr>"
	}

	$("#offchanlist").empty();
	$("#offchanlist").append(row);
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
	initTable_offchan();
}
function onClickRefresh(){
	httpRequest("/goform/mcr_getOffchanScan", "n/a", processHttpResponse);
}
$(document).ready(function(){
	$("input[name='wlanUISecurityType']").bind( "click", function(){
		var ret = onClick_WLAN_SecurityType(null);
		return ret;
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


function validateOnSubmit(){
	var confirmed = false;
	var confirmed1 = false;
	var bs_enable = '<% mcr_getCfgWireless("Wlan_BS_Enable", "-1"); %>';
	var en = document.form_security.wlanRadioActivity[0].checked;
	var cur_en = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';

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
/*
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

function iow_check(value){
    if(value == "0"){
        $("#onchannelscan").hide();
        $("#offchannelscan").hide();
        $("#offchannelscanrst").hide();
        $("#channelswitching").hide();
    }else{
        $("#onchannelscan").show();
        $("#offchannelscan").show();
        $("#offchannelscanrst").show();
        $("#channelswitching").show();
    }
}


function checkIoWChannelRange(){
	var ret = 1;
	//IOW 설정상태 확인 DB

	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';

	if( wlanRadioActivity == '0' ) return 1;
	
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

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();

	initForms(0);

	checkWirelessActivity();

	changeTableAdmin();

	onClickRefresh();
	
}

function form_act(url)
{
	var wlanIOWActivity = '<% mcr_getCfgWireless("Wlan_IOW_Enable", "-1"); %>';
	var IOWEnable = '<% mcr_getCfgWireless("Wlan_Enable_4", "-1"); %>';
	var confirmed = false;
	
	if(checkIoWChannelRange() != 1 && form_security.wlanIOWActivity[0].checked == true){
		confirmed = confirm("설정된 채널에서 IoW 동작이 원활하지 않을 수 있습니다. 계속하시겠습니까?");
		if(!confirmed)
			return false;
	}
	if(IOWEnable == 0 && form_security.wlanIOWActivity[0].checked == true){
		if(IOWEnable == 0){
			alert("IoW WLAN 설정을 먼저 활성화해 주세요");
			return false;
		}
	}

	parent.mcrProgress.startProgressSimple('apply', 20);
	form_security.action = url;
	form_security.submit();

	return false;
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
                    <td valign="top">
                        <table width="98%" border="0" cellspacing="0" cellpadding="0">
                            <tr id="lbl_iow">
                                <td class="font5">IoW 기능</td>
                            </tr>
                            <tr>
                                <td class="PD4"></td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="TB" width="100%" border="0">
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">활성 여부</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td width="110">
                                                            <input type="radio" name="wlanIOWActivity" id="wlanIOWActivity" value="1" Onclick="iow_check(this.value)">활성
                                                        </td>
                                                        <td>
                                                            <input name="wlanIOWActivity" type="radio" id="wlanIOWActivity0" value="0" Onclick="iow_check(this.value)">비활성
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr id="apply_btn">
                                <td class="PD6" colspan="3">
                                    <input type="image" src="/images/BTN/BTN_01.gif" id="btn_apply" name="btn_apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessIOW'); return false;"/></input>
                                </td>
                            </tr>
                        </table>
                        <table id="onchannelscan" width="98%" border="0" cellspacing="0" cellpadding="0" style="display=none;">
                            <tr>
                                <td class="font5">On-Channel Scan 조건</td>
                            </tr>
                            <tr>
                                <td class="PD4"></td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="TB" width="100%" border="0">
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">Scan 주기</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td>
                                                            <input type="text" name="iow_OnChannel_MonInterval" id="iow_OnChannel_MonInterval" size="8" value=""/>  초
														</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">OBSS 채널효율</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td>
                                                            <input type="text" name="iow_OnChannelTh_OBSS" id="iow_OnChannelTh_OBSS" size="8" value=""/>  % 이상 시
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">Traffic 임계치</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td>
                                                            <input type="text" name="iow_OnChannelTh_Traffic" id="iow_OnChannelTh_Traffic" size="8" value=""/>  KB 이하
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>

                            <tr id="apply_btn">
                                <td class="PD6" colspan="3">
                                    <input type="image" src="/images/BTN/BTN_01.gif" id="btn_apply" name="btn_apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessIOW'); return false;"/></input>
                                </td>
                            </tr>
                        </table>
                        <table id="offchannelscan" width="98%" border="0" cellspacing="0" cellpadding="0" style="display=none;">
                            <tr>
                                <td class="font5">Off-Channel Scan 조건</td>
                            </tr>
                            <tr>
                                <td class="PD4"></td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="TB" width="100%" border="0">
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">Scan 횟수</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td>
                                                            <input type="text" name="iow_OffChannel_MaxLoopCnt" id="iow_OffChannel_MaxLoopCnt" size="8" value=""/>  회
														</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr id="apply_btn">
                                <td class="PD6" colspan="3">
                                    <input type="image" src="/images/BTN/BTN_01.gif" id="btn_apply" name="btn_apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessIOW'); return false;"/></input>
                                </td>
                            </tr>
                        </table>
                        <table id="offchannelscanrst" width="98%" border="0" cellspacing="0" cellpadding="0" style="display=none;">
                            <tr>
                                <td class="font5">Off-Channel Scan 결과</td>
                            </tr>
                            <tr>
                                <td colspan="2" class="PD4"></td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                <table class="TB" width="100%" border="0">
                                    <thead>
                                        <tr>
                                            <td rowspan="2" class="BG1" style="width:10%">채널</td>
                                            <td rowspan="2" class="BG1" style="width:20%">STB MAC</td>
											<td rowspan="2" class="BG1" style="width:10%">OBSS CU</td>
											<td rowspan="2" class="BG1" style="width:10%">RSSI</td>
											<td rowspan="2" class="BG1" style="width:10%">Tx Rate</td>
											<td rowspan="2" class="BG1" style="width:10%">Rx Rate</td>
											<td rowspan="2" class="BG1" style="width:20%">시간</td>
                                        </tr>
                                    </thead>
                                    <tbody id="offchanlist" name="offchanlist">
                                    </tbody>
                                </table>
                                </td>
                            </tr>
                        </table>
                        <table id="channelswitching" width="98%" border="0" cellspacing="0" cellpadding="0" style="display=none;">
                            <tr>
                                <td class="font5">Channel Switching 조건</td>
                            </tr>
                            <tr>
                                <td class="PD4"></td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="TB" width="100%" border="0">
                                        <tr>
                                            <td height="25" class="BG2" style="width:140px;">연속이동 금지시간</td>
                                            <td class="BG2-2" width="600">
                                                <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                                                    <tr>
                                                        <td>
                                                            <input type="text" name="iow_NewChannel_StayTime" id="iow_NewChannel_StayTime" size="8" value=""/>  초
														</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr id="apply_btn">
                                <td class="PD6" colspan="3">
                                    <input type="image" src="/images/BTN/BTN_01.gif" id="btn_apply" name="btn_apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessIOW'); return false;"/></input>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</body>
</html>
