<html>
<head>
<title>GiGA WiFi Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>

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
	document.form_ippolicy.action = "/goform/mcr_KTlogOut";
	document.form_ippolicy.submit();
}

$(document).ready(function(){	
	$("#mesh_agent").bind("click", function(){
		window.location.href = "/new/mobile_agent_setup.asp";
		return false;
	});
	$("#mesh_controll").bind("click", function(){
		window.location.href = "/new/mobile_meshap_setup.asp";
		return false;
	});
});

</script>

</head>
<body>
<form method="post" name="form_mesh" data-ajax="false">

<input type="hidden" name="redirect" value="/new/mobile_mesh_setup.asp">

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
					Mesh 연결 선택
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="10"></tr>
		</table>
	</div>

	<!--<div style="padding:0 5 12 5px;" data-role="fieldcontain">-->
	<div>
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
		<!--				<tr>
							<td align="middle" style="font-weight:bold;">Mesh 전용 공유기 연결</td>
						</tr>-->
						<tr>
							<td align="middle">
								<!--<img src="/images/mobile/mesh_agent_1.png?version=<% mcr_getWebVersion(); %>" id="mesh_agent" name="mesh_agent" style="width:200px; height:200px">-->
								<img src="/images/mobile/agent.png?version=<% mcr_getWebVersion(); %>" id="mesh_agent" name="mesh_agent" style="width:400px; height:200px">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div>
		<table>
			<tr height="10"></tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
	<!--<div style="padding:0 5 12 5px;" data-role="fieldcontain">-->
<!--	<div>
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="middle" style="font-weight:bold;" >10GiGA WiFi 공유기 연결</td>
						</tr>
						<tr>
							<td align="middle">
								<img src="/images/mobile/10giga_agent.png?version=<% mcr_getWebVersion(); %>" id="mesh_controll" name="mesh_controll" style="width:400px; height:200px">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>-->
</div>
</form>
</body>
</html>
