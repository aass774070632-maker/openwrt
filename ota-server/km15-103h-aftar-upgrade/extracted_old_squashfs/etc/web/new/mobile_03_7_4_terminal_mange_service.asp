<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
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

var UserPrivilege = getUserPrivilege();
var UserPortNum = getUserPortNum();     

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

function CheckValue() {
	var port_val = document.getElementById("extwebport").value;
	var portdigit = parseInt( port_val, 10 );
	if( (isAllNum(port_val) == 0) || portdigit == 80 || portdigit < 0 || portdigit > 65535){
		alert("Port값 오류입니다. \'80\'을 제외한 \'1\'~\'65535\' 값을 사용합니다.  \'0\' ~ \'1023\' 은 이미 사용하는 곳이 많으니 권장하지 않습니다.");
		document.ServiceControl.extwebport.focus();
		return false;
	}

	port_val = document.getElementById("extwebadport").value;
	portdigit = parseInt( port_val, 10 );
	if( (isAllNum(port_val) == 0) || portdigit == 80 || portdigit < 0 || portdigit > 65535){
		alert("Port값 오류입니다. \'80\'을 제외한 \'1\'~\'65535\' 값을 사용합니다.  \'0\' ~ \'1023\' 은 이미 사용하는 곳이 많으니 권장하지 않습니다.");
		document.ServiceControl.extwebadport.focus();
		return false;
	}
	alert("변경사항이 있을 경우에는 웹 서버를 재시행합니다. 재접속 시에는,화면 새로고침(F5)을 눌러주시길 바랍니다.");
	return true;
}

function ExtCtrlCheck() {
	var ewebsel = "<% mcr_getCfgCommon("ExtWebCtrl_WanUserAccess"); %>";

	ewebsel = "<% mcr_getCfgCommon("ExtWebCtrl_WanUser_2_Access"); %>";
	if (ewebsel == "1")
		document.ServiceControl.extwebalw.checked = true;
	else
		document.ServiceControl.extwebalw.checked = false;

	ewebsel = "<% mcr_getCfgCommon("ExtWebCtrl_WanAdminAccess"); %>";
	if (ewebsel == "1")
		document.ServiceControl.extwebalwad.checked = true;
	else
		document.ServiceControl.extwebalwad.checked = false;

}

function initValue() {

	ExtCtrlCheck();

	$('label[for=m_vAllow]').removeClass('ui-btn-active');
	$('label[for=m_vAllow]').addClass('ui-btn-active-c');
	$("input[id='m_vAllow']").attr("checked", true).checkboxradio("refresh");

	if( UserPrivilege == "7"){
		$("#Admin_mode").show()
		$("#User_mode").show()
	}
}



function form_act(url){
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	if(!CheckValue())
		return false;
	ServiceControl.action = url;
	ServiceControl.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="ServiceControl" data-ajax="false">

<input type="hidden" name="ActiveSts" id="ActiveSts" value="1">

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
					장치 관리 서비스
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
							<td>웹 서버 사용</td>
							<td colspan="2">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_vAllow">　활성　</label>
									<input type="radio" name="m_ActiveSts" id="m_vAllow" value="1">
									<label for="m_vDeny">　비활성　</label>
									<input type="radio" name="m_ActiveSts" id="m_vDeny" value="0" disabled="disabled"> 
								</fieldset>
							</td>
						</tr>

						<tr id="User_mode" style="display:none;">
							<td>포트</td>
							<td>
								<input type="text" name="extwebport" id="extwebport" maxlength="5" value="<% mcr_getCfgString("ExtWebCtrl_UserPort"); %> ">
							</td>
							<td>원격관리</td>
							<td>
								<input type="checkbox" value="1" name="extwebalw" id="extwebalw" data-role="none">
							</td>
						</tr>
						<tr id="Admin_mode" style="display:none;">
							<td>포트</td>
							<td>
								<input type="text" name="extwebadport" id="extwebadport" maxlength="5" value="<% mcr_getCfgString("ExtWebCtrl_Port"); %> ">
							</td>
							<td>원격관리</td>
							<td>
								<input type="checkbox" value="1" name="extwebalwad" id="extwebalwad" data-role="none">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setExtWeb');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eleventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
