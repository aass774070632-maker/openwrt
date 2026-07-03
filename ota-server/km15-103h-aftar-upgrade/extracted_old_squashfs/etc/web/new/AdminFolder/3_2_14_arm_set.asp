<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>
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
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
function changeTableAdmin()
{

	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}
function convRSSI_to_sign( strValue ){
	return ( '' + (0 - parseInt( strValue )) );
}

function convRSSI_to_abs( strLabel ){
	var strValue = $("#"+strLabel).val();
	var nValue = parseInt( strValue );
	var nABSValue = Math.abs(nValue);
	return ( '' + nABSValue );
}

function validateOnSubmit(){
	var ret = 0;
	var rssi = 0;
	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", "1"); %>';
	var armEnable = document.form_BndStrg.bs_enable[0].checked;
	if(wlanRadioActivity == "0" && armEnable){
		alert("Dual WLAN 설정을 먼저 활성화해 주세요");
		form_BndStrg.bs_enable[1].checked = true;
		changeArm(0);
		return false;
	}
	ret = validateRangeById("bs_ChThPreAssoc_5G", 10, 1, 100, true);
	if( ret!= 1 ){
		alert( "범위 초과(0 ~ 100)" );
		return false;
	}
	ret = validateRangeById("bs_ChThPreAssoc_2G", 10, 1, 100, true);
	if( ret!= 1 ){
		alert( "범위 초과(0 ~ 100)" );
		return false;
	}
	ret = validateRangeById("bs_ChThPostAssoc_5G", 10, 1, 100, true);
	if( ret!= 1 ){
		alert( "범위 초과(0 ~ 100)" );
		return false;
	}
	ret = validateRangeById("bs_ChThPostAssoc_2G", 10, 1, 100, true);
	if( ret!= 1 ){
		alert( "범위 초과(0 ~ 100)" );
		return false;
	}

	ret = validateRangeById("bs_ui_RSSIThPostAssoc_5G", 10, -99, -1, true);
	if( ret!= 1 ){
		alert( "범위 초과(-99 ~ -1)" );
		return false;
	}
	ret = validateRangeById("bs_ui_RSSIThPostAssoc_2G", 10, -99, -1, true);
	if( ret!= 1 ){
		alert( "범위 초과(-99 ~ -1)" );
		return false;
	}

	rssi = convRSSI_to_abs(  "bs_ui_RSSIThPostAssoc_5G" );
	$("#bs_RSSIThPostAssoc_5G").val( rssi );

	rssi = convRSSI_to_abs(  "bs_ui_RSSIThPostAssoc_2G" );
	$("#bs_RSSIThPostAssoc_2G").val( rssi );
	
	form_act('/goform/mcr_setWirelessBndStrg');
	return false;
}

function initForms(useDefault){
	var chUtilRefreshTime_0 = 0;    
	var bs_SSID = "";

	var bs_enable = 0;

	var bs_ChThPreAssoc_5G = 0;
	var bs_ChThPreAssoc_2G = 0;
	var bs_ChThPostAssoc_5G = 0;
	var bs_ChThPostAssoc_2G = 0;

	var bs_ui_RSSIThPostAssoc_5G = 0;
	var bs_ui_RSSIThPostAssoc_2G = 0;

	var bs_str_RSSIThPreAssoc_5G = 0;
	var bs_str_RSSIThPreAssoc_2G = 0;
	var bs_str_RSSIThPostAssoc_5G = 0;
	var bs_str_RSSIThPostAssoc_2G = 0;

	var bs_HoldTime = 0;
	var bs_AgeTime_Legacy = 0;
	var bs_AgeTime_11V = 0;

	var bs_BTMReleaseTime = 0;

	$("#wlanUIMenu21").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	if( useDefault == 0 ){
		chUtilRefreshTime_0 = '<% mcr_getCfgWireless("Wlan_BS_ChUtilAvgTime", "-1"); %>';

		bs_SSID = '<% mcr_getCfgWireless("Wlan_SSID", "1"); %>';

		bs_enable = '<% mcr_getCfgWireless("Wlan_BS_Enable", "-1"); %>';

		bs_ChThPreAssoc_5G = '<% mcr_getCfgWireless("Wlan_BS_ChThPreAssoc_5G", "-1"); %>';
		bs_ChThPreAssoc_2G = '<% mcr_getCfgWireless("Wlan_BS_ChThPreAssoc_2G", "-1"); %>';
		bs_ChThPostAssoc_5G = '<% mcr_getCfgWireless("Wlan_BS_ChThPostAssoc_5G", "-1"); %>';
		bs_ChThPostAssoc_2G = '<% mcr_getCfgWireless("Wlan_BS_ChThPostAssoc_2G", "-1"); %>';

		bs_str_RSSIThPreAssoc_5G = '<% mcr_getCfgWireless("Wlan_BS_RSSIThPreAssoc_5G", "-1"); %>';
		bs_str_RSSIThPreAssoc_2G = '<% mcr_getCfgWireless("Wlan_BS_RSSIThPreAssoc_2G", "-1"); %>';
		bs_str_RSSIThPostAssoc_5G = '<% mcr_getCfgWireless("Wlan_BS_RSSIThPostAssoc_5G", "-1"); %>';
		bs_str_RSSIThPostAssoc_2G = '<% mcr_getCfgWireless("Wlan_BS_RSSIThPostAssoc_2G", "-1"); %>';

		bs_HoldTime = '<% mcr_getCfgWireless("Wlan_BS_HoldTime", "-1"); %>';
		bs_AgeTime_Legacy = '<% mcr_getCfgWireless("Wlan_BS_AgeTime_Legacy", "-1"); %>';
		bs_AgeTime_11V = '<% mcr_getCfgWireless("Wlan_BS_AgeTime_11V", "-1"); %>';

		bs_ui_RSSIThPostAssoc_5G = convRSSI_to_sign(bs_str_RSSIThPostAssoc_5G);
		bs_ui_RSSIThPostAssoc_2G = convRSSI_to_sign(bs_str_RSSIThPostAssoc_2G);

		bs_BTMReleaseTime = '<% mcr_getCfgWireless("Wlan_BS_BTMReleaseTime", "-1"); %>';
	}

	if(bs_enable == "1"){
		form_BndStrg.bs_enable[0].checked = true;	
	}else{
		form_BndStrg.bs_enable[1].checked = true;	
	}
	changeArm(bs_enable);
	$("input[name='bs_SSID']").prop("disabled",true);

	initTextById("bs_SSID", bs_SSID);

	initTextById("bs_ChThPreAssoc_5G", bs_ChThPreAssoc_5G);
	initTextById("bs_ChThPreAssoc_2G", bs_ChThPreAssoc_2G);
	initTextById("bs_ChThPostAssoc_5G", bs_ChThPostAssoc_5G);
	initTextById("bs_ChThPostAssoc_2G", bs_ChThPostAssoc_2G);

	initTextById("bs_ui_RSSIThPostAssoc_5G", bs_ui_RSSIThPostAssoc_5G);
	initTextById("bs_ui_RSSIThPostAssoc_2G", bs_ui_RSSIThPostAssoc_2G);

	initTextById("bs_HoldTime", bs_HoldTime);
	initTextById("bs_AgeTime_Legacy", bs_AgeTime_Legacy);
	initTextById("bs_AgeTime_11V", bs_AgeTime_11V);

	initTextById("bs_chutil_PreAssoc", chUtilRefreshTime_0);
	initTextById("bs_chutil_PostAssoc", chUtilRefreshTime_0);

	initTextById("bs_BTMReleaseTime", bs_BTMReleaseTime);

	changeTableAdmin();
}

function initValue(){
	parent.mcrProgress.stopProgress();
	initForms(0);
}

function changeArm(value){
	if(value == "1"){
		// $("#PreList").show();
		$("#PreList").hide();
		$("#PostList").show();
	}else{
		$("#PreList").hide();
		$("#PostList").hide();
	}
}

function form_act(url)
{
	parent.mcrProgress.startProgressSimple('apply', 20);
	form_BndStrg.action = url;
	form_BndStrg.submit();

	return false;
}

</script>
</head>

<body class="wbody" onLoad="initValue()">
<form method="post" class="form_layout" id="form_BndStrg" name="form_BndStrg"
        action="/goform/mcr_setWirelessBndStrg" onSubmit="return validateOnSubmit()">

<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/AdminFolder/3_2_14_arm_set.asp"/>

<input type="hidden" id="bs_RSSIThPreAssoc_5G" name="bs_RSSIThPreAssoc_5G" value=""/>
<input type="hidden" id="bs_RSSIThPreAssoc_2G" name="bs_RSSIThPreAssoc_2G" value=""/>
<input type="hidden" id="bs_RSSIThPostAssoc_5G" name="bs_RSSIThPostAssoc_5G" value=""/>
<input type="hidden" id="bs_RSSIThPostAssoc_2G" name="bs_RSSIThPostAssoc_2G" value=""/>

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
							<tr id="lbl_ARM">
								<td class="font5">ARM 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">ARM 설정</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="bs_enable" id="bs_enable" value="1" OnClick="changeArm(this.value)">활성
														</td>
														<td>
															<input name="bs_enable" type="radio" id="bs_enable0" value="0" OnClick="changeArm(this.value)">비활성
														</td>
													</tr>
													<tr>
														<td width="110">적용 무선랜명
														</td>
														<td>
															<input class="input2-4" name="bs_SSID" type="text" id="bs_SSID" maxlength="30" size="30" value="" >
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
							<tr id="PreList" style="display:none">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">접속 이전(Pre-Association) 단계</td>
										</tr>
										<tr height="20">
											<td height="25" class="BG1" style="width:140px;">구분</td>
											<td height="25" class="BG1" style="width:140px;">채널효율/RSSI</td>
											<td height="25" class="BG1" style="width:140px;">설정 값</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">5GHz로 접속 허용</td>
											<td height="25" class="BG2-2" style="width:140px;">2.4GHz Channel Utilization</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ChThPreAssoc_2G" name="bs_ChThPreAssoc_2G" size="4" maxlength="4" value=""></input>
												<label>% 이상</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">2.4GHz로 접속 허용</td>
											<td height="25" class="BG2-2" style="width:140px;">5GHz Channel Utilization</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ChThPreAssoc_5G" name="bs_ChThPreAssoc_5G" size="4" maxlength="4" value=""></input>
												<label>% 이상</label>
											</td>
										</tr>
										<tr rowspan="2">
											<td height="25" class="BG2-2" style="width:140px;" rowspan="2">시간 설정</td>
											<td height="25" class="BG2-2" style="width:140px;">Channel Utilization 측정 시간</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_chutil_PreAssoc" name="bs_chutil_PreAssoc" size="4" maxlength="4" value=""></input>
												<label>초</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">Probe Response 전달 대기 시간</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_HoldTime" name="bs_HoldTime" size="4" maxlength="4" value=""></input>
												<label>초</label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="PostList" style="display:none">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">접속 이후(Post-Association) 단계</td>
										</tr>
										<tr height="20">
											<td height="25" class="BG1" style="width:140px;">구분</td>
											<td height="25" class="BG1" style="width:140px;">채널효율/RSSI</td>
											<td height="25" class="BG1" style="width:140px;">설정 값</td>
										</tr>
										<tr rowspan="2">
											<td height="25" class="BG2-2" style="width:140px;" rowspan="2">2.4GHz로 이동</td>
											<td height="25" class="BG2-2" style="width:140px;">5GHz RSSI</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ui_RSSIThPostAssoc_5G" name="bs_ui_RSSIThPostAssoc_5G" size="4" maxlength="4" value=""></input>
												<label>dBm 이하</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">2.4GHz Channel Utilization</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ChThPostAssoc_2G" name="bs_ChThPostAssoc_2G" size="4" maxlength="4" value=""></input>
												<label>% 이하</label>
											</td>
										</tr>
										<tr rowspan="2">
											<td height="25" class="BG2-2" style="width:140px;" rowspan="2">5GHz로 이동</td>
											<td height="25" class="BG2-2" style="width:140px;">2.4GHz RSSI</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ui_RSSIThPostAssoc_2G" name="bs_ui_RSSIThPostAssoc_2G" size="4" maxlength="4" value=""></input>
												<label>dBm 이상</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">5GHz Channel Utilization</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_ChThPostAssoc_5G" name="bs_ChThPostAssoc_5G" size="4" maxlength="4" value=""></input>
												<label>% 이하</label>
											</td>
										</tr>
										<tr rowspan="3">
											<td height="25" class="BG2-2" style="width:140px;" rowspan="4">시간 설정</td>
											<td height="25" class="BG2-2" style="width:140px;">Channel Utilization 측정시간</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_chutil_PostAssoc" name="bs_chutil_PostAssoc" size="4" maxlength="4" value=""></input>
												<label>초</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">이동 금지시간(802.11v 지원)</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_AgeTime_11V" name="bs_AgeTime_11V" size="4" maxlength="4" value=""></input>
												<label>초</label>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;">연속 3회 이동요청 후 대기시간</td>
											<td height="25" class="BG2-2" style="width:140px;">
												<input class="input2-1" type="text" id="bs_BTMReleaseTime" name="bs_BTMReleaseTime" size="4" maxlength="4" value=""></input>
												<label>초</label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="apply_btn">
								<td class="PD6" colspan="3">
									<input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply_antpath" name="btn_apply" height="24" width="52" onClick="return validateOnSubmit();"></input>
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
											

