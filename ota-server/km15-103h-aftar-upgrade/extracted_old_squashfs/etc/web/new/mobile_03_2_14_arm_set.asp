<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
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
	document.form.action = "/goform/mcr_KTlogOut";
	document.form.submit();
}

function initForms(useDefault){
	var bs_enable = 0;
	var bs_SSID = "";

	if( useDefault == 0 ){
		bs_SSID = '<% mcr_getCfgWireless("Wlan_SSID", "1"); %>';
		bs_enable = '<% mcr_getCfgWireless("Wlan_BS_Enable", "-1"); %>';
	}

	setarm(bs_enable);
	
	initTextById("bs_SSID", bs_SSID);
	document.form_BndStrg.bs_SSID.disabled = true;
}
function validateOnSubmit(){
	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", "1"); %>';
	var armEnable = $("#bs_enable").val();
	if(wlanRadioActivity == "0" && armEnable == "1"){
		alert("Dual WLAN 설정을 먼저 활성화해 주세요");
		setarm(0);
		return false;
	}
	form_act('/goform/mcr_setWirelessBndStrg_UserMode');
	return false;
}
function initValue(){
        initForms(0);
}
function form_act(url)
{
	parent.mcrProgress.startProgressSimple("apply",30);
	form_BndStrg.action = url;
	form_BndStrg.submit();

	return false;
}
function setarm(value){
	if(value == "1"){
		mcr_clickradio_arm('1');
		$("input[id='m_bs_enable']").attr("checked", true).checkboxradio("refresh");
		$("#bs_enable").val("1");
	}else{
		mcr_clickradio_arm('0');
		$("input[id='m_bs_enable0']").attr("checked", true).checkboxradio("refresh");
		$("#bs_enable").val("0");
	}
}
function mcr_clickradio_arm(val){
	$('label[for=m_bs_enable]').removeClass('ui-btn-active');
	$('label[for=m_bs_enable0]').removeClass('ui-btn-active');

	if(val == "1"){
		$('label[for=m_bs_enable]').addClass('ui-btn-active-c');
		$('label[for=m_bs_enable0]').removeClass('ui-btn-active-c');
	}else{
		$('label[for=m_bs_enable0]').addClass('ui-btn-active-c');
		$('label[for=m_bs_enable]').removeClass('ui-btn-active-c');
	}
}
</script>
</head>

<body onload="initValue()">
<form method="post" name="form_BndStrg" data-ajax="false" action="/goform/mcr_setWirelessBndStrg_UserMode" onsubmit="return validateOnSubmit()">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_2_14_arm_set.asp">
<input type="hidden" id="bs_enable" name="bs_enable" value="">

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
					ARM 설정
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
							<td>ARM 활성화</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_bs_enable">　활성　</label>
									<input type="radio" name="m_bs_enable" id="m_bs_enable" value="1" onclick="setarm(this.value)">
									<label for="m_bs_enable0">　비활성　</label>
									<input type="radio" name="m_bs_enable" id="m_bs_enable0" value="0" onclick="setarm(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>적용 무선랜명</td>
							<td>
								<input name="bs_SSID" type="input2-1" id="bs_SSID" maxlength="30" size="30" value="" style="ime-mode:disabled">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return validateOnSubmit();" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
