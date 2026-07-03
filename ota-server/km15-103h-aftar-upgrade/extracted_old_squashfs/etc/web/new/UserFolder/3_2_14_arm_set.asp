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

<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>"></script>
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

function validateOnSubmit(){
	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", "1"); %>';
	var armEnable = document.form_BndStrg.bs_enable[0].checked;
	if(wlanRadioActivity == "0" && armEnable){
		alert("Dual WLAN 설정을 먼저 활성화해 주세요");
		form_BndStrg.bs_enable[1].checked = true;
		return false;
	}
	form_act('/goform/mcr_setWirelessBndStrg_UserMode');
	return false;
}
function initForms(useDefault){
	var bs_enable = 0;
	var bs_SSID = "";
	$("#wlanUIMenu21").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	if( useDefault == 0 ){
		bs_SSID = '<% mcr_getCfgWireless("Wlan_SSID", "1"); %>';
		bs_enable = '<% mcr_getCfgWireless("Wlan_BS_Enable", "-1"); %>';
	}

	if(bs_enable == "1"){
		form_BndStrg.bs_enable[0].checked = true;
	}else{
		form_BndStrg.bs_enable[1].checked = true;
	}
	initTextById("bs_SSID", bs_SSID);
	$("input[name='bs_SSID']").prop("disabled",true);

	changeTableAdmin();
}
function initValue(){
	parent.mcrProgress.stopProgress();
	initForms(0);
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

<body class="wbody" onload="initValue()">
<form method="post" class="form_layout" id="form_BndStrg" name="form_BndStrg" action="/goform/mcr_setWirelessBndStrg_UserMode" onsubmit="return validateOnSubmit()">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/UserFolder/3_2_14_arm_set.asp">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_2_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
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
												<table border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="bs_enable" id="bs_enable" value="1">활성
														</td>
														<td>
															<input name="bs_enable" type="radio" id="bs_enable0" value="0">비활성
														</td>
													</tr>
													<tr>
														<td width="110">적용할 무선랜명
														</td>
														<td>
															<input class="input2-4" name="bs_SSID" type="text" id="bs_SSID" maxlength="30" size="30" value="">
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
									<input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply_antpath" name="btn_apply" height="24" width="52" onclick="return validateOnSubmit();">
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
