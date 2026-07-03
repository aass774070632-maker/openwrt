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
	document.natra.action = "/goform/mcr_KTlogOut";
	document.natra.submit();
}

function initValue() {

	var ra_inform = '<% mcr_getCfgString("RaaCfg_Enable"); %>';
	var igd_inform = '<% mcr_getCfgString("NatAlgCfgParam_upnpEnable"); %>';
	var otvEnable = '<% mcr_getCfgCommon("OTVCfgParam_Enable"); %>';


	setinfenable(ra_inform);
	setupnpen(igd_inform);
	setotvEnable(otvEnable);

}

function setinfenable(infenable){
	switch(infenable){
		case '0':
			$("input[id='radio3']").attr("checked", true).checkboxradio("refresh");
			$("#upnpRa1").hide();
			$("#upnpRa2").hide();
			$("#upnpRa3").hide();
			$("#infenable").val("0");
			break;
		case '1':
			$("input[id='radio2']").attr("checked", true).checkboxradio("refresh");
			$("#upnpRa1").show();
			$("#upnpRa2").show();
			$("#upnpRa3").show();
			$("#infenable").val("1");
			break;
		default:
			break;
	}
}

function setupnpen(upnpen){
	switch(upnpen){
		case '0':
			mcr_clickradio_upnpen('0');
			$("input[id='aupnpD']").attr("checked", true).checkboxradio("refresh");
			$("#upnp_en").val("0");
			break;
		case '1':
			mcr_clickradio_upnpen('1');
			$("input[id='aupnpE']").attr("checked", true).checkboxradio("refresh");
			$("#upnp_en").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_upnpen(val){
	$('label[for=aupnpD]').removeClass('ui-btn-active');
	$('label[for=aupnpE]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=aupnpD]').addClass('ui-btn-active-c');
			$('label[for=aupnpE]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=aupnpE]').addClass('ui-btn-active-c');
			$('label[for=aupnpD]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setotvEnable(otvEnable){
	switch(otvEnable){
		case '0':
			mcr_clickradio_otvEnable('0');
			$("input[id='m_otvEnable1']").attr("checked", true).checkboxradio("refresh");
			$("#otvEnable").val("0");
			break;
		case '1':
			mcr_clickradio_otvEnable('1');
			$("input[id='m_otvEnable']").attr("checked", true).checkboxradio("refresh");
			$("#otvEnable").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_otvEnable(val){
	$('label[for=m_otvEnable]').removeClass('ui-btn-active');
	$('label[for=m_otvEnable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_otvEnable1]').addClass('ui-btn-active-c');
			$('label[for=m_otvEnable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_otvEnable]').addClass('ui-btn-active-c');
			$('label[for=m_otvEnable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function changeHomeNetwork() {
	if ($("#infenable").val() == "1") {
		if ( document.natra.username.value=="") {
			document.natra.username.focus();
			return false;
		}
		if ( document.natra.password.value=="") {
			document.natra.password.focus();
			return false;
		}
		if ( document.natra.url.value=="") {
			document.natra.url.focus();
			return false;
		}
	}
	return true;
}

function form_act(url){
	if(url == "/goform/mcr_setNatRaConf"){
		if(!changeHomeNetwork()){
			return false;
		}
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
	}
	if(url == "/goform/mcr_KT_setOTV"){
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	}
	parent.mcrProgress.startProgressSimple("apply",5);

	natra.action = url;
	natra.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="natra" data-ajax="false">

<input type="hidden" name="infenable" id="infenable" value="">
<input type="hidden" name="upnp_en" id="upnp_en" value="">
<input type="hidden" name="otvEnable" id="otvEnable" value="">

<input type="hidden" name="SETUPNP" value="/new/mobile_03_6_3_home_network_set.asp">

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
					홈 네트워크 설정
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
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr id="upnuRa0" style="display:none">
							<td>UPnP RA</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="radio2">　활성　</label>
									<input type="radio" name="m_infenable" id="radio2" value="1" onclick="setinfenable(this.value)" disabled="disabled">
									<label for="radio3">　비활성　</label>
									<input type="radio" name="m_infenable" id="radio3" value="0" onclick="setinfenable(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="upnpRa1" style="display:none">
							<td>사용자 ID</td>
							<td>
								<input name="username" type="text" id="username" size="32" maxlength="40" value="<% mcr_getCfgString("RaaCfg_UserId"); %>">
							</td>
						</tr>
						<tr id="upnpRa2" style="display:none">
							<td>패스워드</td>
							<td>
								<input name="password" type="text" id="password" size="32" maxlength="40" value="<% mcr_getCfgString("RaaCfg_UserPasswd"); %>">
							</td>
						</tr>
						<tr id="upnpRa3" style="display:none">
							<td>서버 IP 주소</td>
							<td>
								<input name="url" type="text" id="url" size="32" maxlength="50" value="<% mcr_getCfgString("RaaCfg_RaServerIp"); %>">
							</td>
						</tr>
						<tr>
							<td>UPnP IGD</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="aupnpE">　활성　</label>
									<input type="radio" name="m_upnp_en" id="aupnpE" value="1" onclick="setupnpen(this.value)">
									<label for="aupnpD">　비활성　</label>
									<input type="radio" name="m_upnp_en" id="aupnpD" value="0" onclick="setupnpen(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return form_act('/goform/mcr_setNatRaConf')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
							</td>
						</tr>
					</table>
				<td>
			</tr>
			
		</table>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
