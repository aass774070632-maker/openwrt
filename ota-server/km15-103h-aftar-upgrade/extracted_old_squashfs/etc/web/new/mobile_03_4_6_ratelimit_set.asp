<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>

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
	document.form_rate.action = "/goform/mcr_KTlogOut";
	document.form_rate.submit();
}

function isAllNum(str)
{
	for (var i=0; i<str.length; i++) {
		if (str.charAt(i) >= '0' && str.charAt(i) <= '9')
			continue;
		return 0;
	}
	return 1;
}

function checkVal( field ) {

	if (field.value == "") {
		alert("입력오류입니다.[0-9] 숫자를 입력해 주세요");
		field.focus();
		return false;
	}

	if (isAllNum(field.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력해 주세요");
		field.focus();
		return false;
	}

	var aVal = parseInt(field.value);
	if( aVal < 1 || aVal > 1000) {
		alert("입력오류입니다. [1-1000] 범위값을 입력해야 합니다.");
		field.focus();
		return false;
	}
	return true;
}

function CheckValue() {
	if((!checkVal(document.form_rate.inrl_0 )) ||
			(!checkVal(document.form_rate.inrl_1 )) ||
			(!checkVal(document.form_rate.inrl_2 )) ||
			(!checkVal(document.form_rate.inrl_3 )) ||
			(!checkVal(document.form_rate.inrl_4 )) ||
			(!checkVal(document.form_rate.outrl_0 )) ||
			(!checkVal(document.form_rate.outrl_1 )) ||
			(!checkVal(document.form_rate.outrl_2 )) ||
			(!checkVal(document.form_rate.outrl_3 )) ||
			(!checkVal(document.form_rate.outrl_4 ))) {
		return false;
	}
	return true;
}

function form_act(url) {
	if(url == "/goform/mcr_setRateLimit_New") {
		if(!CheckValue())
			return false;
	}

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	form_rate.action = url;
	form_rate.submit();
	return false;
}

</script>

</head>
<body>
<form method="post" name="form_rate" data-ajax="false">

<input type="hidden" name="SETRATE" value="/new/mobile_03_4_6_ratelimit_set.asp">

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
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					트래픽 제한 설정
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
							<td>포트이름</td>
							<td>입력(단위:100Kbps)</td>
							<td>출력(단위:100Kbps)</td>
						</tr>
						<tr>
							<td>LAN1</td>
							<td>
								<input name="inrl_1" type="text" id="inrl_1" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam1_IngressRate");%>">
							</td>
							<td>
								<input name="outrl_1" type="text" id="outrl_1" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam1_EgressRate");%>">
							</td>
						</tr>
						<tr>
							<td>LAN2</td>
							<td>
								<input name="inrl_2" type="text" id="inrl_2" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam2_IngressRate");%>">
							</td>
							<td>
								<input name="outrl_2" type="text" id="outrl_2" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam2_EgressRate");%>">
							</td>
						</tr>
						<tr>
							<td>LAN3</td>
							<td>
								<input name="inrl_3" type="text" id="inrl_3" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam3_IngressRate");%>">
							</td>
							<td>
								<input name="outrl_3" type="text" id="outrl_3" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam3_EgressRate");%>">
							</td>
						</tr>
						<tr>
							<td>LAN4</td>
							<td>
								<input name="inrl_4" type="text" id="inrl_4" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam4_IngressRate");%>">
							</td>
							<td>
								<input name="outrl_4" type="text" id="outrl_4" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam4_EgressRate");%>">
							</td>
						</tr>
						<tr>
							<td>WAN</td>
							<td>
								<input name="inrl_0" type="text" id="inrl_0" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam0_IngressRate");%>">
							</td>
							<td>
								<input name="outrl_0" type="text" id="outrl_0" maxlength="5" size="45" value="<% mcr_getCfgString("QosEtcCfgParam0_EgressRate");%>">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setRateLimit_New')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
