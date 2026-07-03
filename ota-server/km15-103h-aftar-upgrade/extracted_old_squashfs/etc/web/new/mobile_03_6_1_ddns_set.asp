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

function initValue(){
	var ddnsserver  = "<% mcr_getCfgString("DdnsCfgParam_DdnsServer"); %>";
	var user        = "<% mcr_getCfgString("DdnsCfgParam_DdnsUser"); %>";
	var pwd         = "<% mcr_getCfgString("DdnsCfgParam_DdnsPassword"); %>";
	var url         = "<% mcr_getCfgString("DdnsCfgParam_DdnsHost"); %>";

	if ( isEmpty(ddnsserver) ) {
		changDdns('1');
		document.form.ddnsserver.value = "";
		document.form.usrid.value = "";
		document.form.password.value = "";
		document.form.url.value = "";
	}
	else {
		changDdns('0');
		document.form.ddnsserver.value = ddnsserver;
		document.form.usrid.value = user;
		document.form.password.value = pwd;
		document.form.url.value = url;
	}

}

function changDdns(Ddns){
	switch(Ddns){
		case '0':
			mcr_clickradio_Ddns('0');
			$("input[id='m_radio13']").attr("checked", true).checkboxradio("refresh");
			$("#ddns2").show();
			$("#ddns3").show();
			$("#ddns4").show();
			$("#ddns5").show();
			$("#ddns6").show();
			$("#radio1").val("0");
			break;
		case '1':
			mcr_clickradio_Ddns('1');
			$("input[id='m_radio14']").attr("checked", true).checkboxradio("refresh");
			$("#ddns2").hide();
			$("#ddns3").hide();
			$("#ddns4").hide();
			$("#ddns5").hide();
			$("#ddns6").hide();
			$("#radio1").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_Ddns(val){
	$('label[for=m_radio13]').removeClass('ui-btn-active');
	$('label[for=m_radio14]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_radio13]').addClass('ui-btn-active-c');
			$('label[for=m_radio14]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_radio14]').addClass('ui-btn-active-c');
			$('label[for=m_radio13]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function on_focus_clear(id){
	document.getElementById(id).value="";
}

function CheckValue(){
	if($("#radio1").val() == "0") {
		if ( isEmpty(document.form.ddnsserver.value) ) {
			alert("DDNS 서버를 입력해 주세요");
			return false;
		}

		if ( CheckInternetAddress(document.form.ddnsserver, 1) == false ) {
			alert("잘못된 DDNS서버 입니다");
			return false;
		}

		if ( isEmpty(document.form.usrid.value) ) {
			alert("사용자ID를 입력해 주세요");
			return false;
		}

		if ( isEmpty(document.form.password.value) ) {
			alert("비밀번호를 입력해 주세요");
			return false;
		}

		if ( CheckDomain(document.form.url.value) == false ) {
			alert("잘못된 URL주소 입니다");
			return false;
		}
	}
	else {
		document.form.ddnsserver.value = "";
		document.form.usrid.value = "";
		document.form.password.value = "";
		document.form.url.value = "";
	}
	return true;
}

function form_act(url){
	if(!CheckValue())
		return false;

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",1);
	form.action = url;
	form.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form" data-ajax="false">

<input type="hidden" name="radio1" id="radio1" value="">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/mobile_03_6_1_ddns_set.asp">

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
					DDNS 설정
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
							<td>DDNS 사용</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_radio13">　활성　</label>
									<input type="radio" name="m_radio1" id="m_radio13" value="0" onclick="changDdns(this.value)">
									<label for="m_radio14">　비활성　</label>
									<input type="radio" name="m_radio1" id="m_radio14" value="1" onclick="changDdns(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="ddns2" style="display:none">
							<td>DDNS 서버</td>
							<td>
								<input name="ddnsserver" type="text" id="ddnsserver" maxlength="30" value="dyndns.org" style="ime-mode:disabled" onfocus="on_focus_clear('ddnsserver')">
							</td>
						</tr>
						<tr id="ddns3" style="display:none">
							<td>사용자 ID</td>
							<td>
								<input name="usrid" type="text" id="usrid" maxlength="30" value="" style="ime-mode:disabled" onfocus="on_focus_clear('usrid')">
							</td>
						</tr>
						<tr id="ddns4" style="display:none">
							<td>비밀번호</td>
							<td>
								<input type="text" id="user_id_fake" name="user_id_fake" autocomplete="off" style="display: none;">
								<input type="password" id="user_id_fake" name="user_pwd_fake" autocomplete="off" style="display: none;">
								<input name="password" type="password" id="password" maxlength="30" style="ime-mode:disabled" onfocus="on_focus_clear('password')">
							</td>
						</tr>
						<tr id="ddns5" style="display:none">
							<td rowspan="2">URL</td>
							<td>
								<input name="url" type="text" id="url" maxlength="30" value="" style="ime-mode:disabled" onfocus="on_focus_clear('url')">
							</td>
						</tr>
						<tr id="ddns6" style="display:none">
							<td>ex)userhost.dyndns.org</td>
						</tr>

					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setDDNS')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>

</div>
</form>
</body>
</html>
