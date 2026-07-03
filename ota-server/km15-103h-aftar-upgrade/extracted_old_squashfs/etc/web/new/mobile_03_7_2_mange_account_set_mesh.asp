\<html>
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
	document.User.action = "/goform/mcr_wlan_mesh_KTlogOut";
	document.User.submit();
}

function vendor_init()
{
	gProjectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';
}

function checkPrivilege(userId)
{
	var user_id = '<% mcr_getCfgCommon("UserManage_Name_1"); %>'; 
	var userIDCookie = '<% mcr_getCfgCookie("ID"); %>';


	if( (userIDCookie == user_id) && (userIDCookie == userId)){
		return "1";
	}
	else{
		return "0";
	}

}

function CheckValue(chgType, id, new_id, pwd, new_pwd, new_pwd_verify)
{
	var userId = document.getElementById(id).value;
	var new_userId = document.getElementById(new_id).value;
	var password = document.getElementById(pwd).value;
	var new_password = document.getElementById(new_pwd).value;
	var new_password_verify = document.getElementById(new_pwd_verify).value;
	var sys_user_id;
	var flag = checkPrivilege(userId);

	var num = new_password.search(/[0-9]/g);
	var eng = new_password.search(/[a-z]/ig);

	switch(flag){
		case "1":
			if (userId == "") {
				alert("ID를 입력해 주세요");
				return false;
			}

			if ( !isEmpty(new_userId) ) {
				if ( userId == new_userId ) {
					alert("변경될 ID가 잘못되어 있습니다");
					return false;
				}
			}

			if ( isEmpty(password) ) {
				alert("비밀번호를 입력해 주세요");
				return false;
			}

			if ( !isEmpty(new_password) || !isEmpty(new_password_verify) ) {
				if ( isEmpty(new_password) || isEmpty(new_password_verify) ) {
					alert("변경할 비밀번호를 입력해 주세요");
					return false;
				}
				if ( new_password != new_password_verify) {
					alert("변경할 비밀번호가 일치하지 않습니다");
					return false;
				}
				if( num < 0 || eng < 0 || ($("#user_ChgPassword").val().length < 10)){
					alert("비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.");
					return true;
				}
				if( num < 0 || eng < 0 || ($("#user_ChgPassword").val().length > 64)) {
					alert("비밀번호는 최대 64자 입니다.");
					return true;
				}
			}
			if ( isEmpty(new_userId) || ( isEmpty(new_password) || isEmpty(new_password_verify) ) ) {
				alert("변경할 ID나 비밀번호를 입력해 주세요");
				return false;
			}
			break;
		case "2":
			if (userId == "") {
				alert("ID를 입력해 주세요");
				return false;
			}
			if ( isEmpty(password) ) {
				alert("비밀번호를 입력해 주세요");
				return false;
			}
			if ( !isEmpty(new_password) || !isEmpty(new_password_verify) ) {
				if ( isEmpty(new_password) || isEmpty(new_password_verify) ) {
					alert("변경할 비밀번호를 입력해 주세요");
					return false;
				}
				if ( new_password != new_password_verify) {
					alert("변경할 비밀번호가 일치하지 않습니다");
					return false;
				}
				if( num < 0 || eng < 0 || ($("#user_ChgPassword").val().length < 10)){
					alert("비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.");
					return true;
				}
				if( num < 0 || eng < 0 || ($("#user_ChgPassword").val().length > 64)) {
					alert("비밀번호는 최대 64자 입니다.");
					return true;
				}
			}
			if ( isEmpty(new_userId) || ( isEmpty(new_password) || isEmpty(new_password_verify) ) ) {
				alert("변경할 ID나 비밀번호를 입력해 주세요");
				return false;
			}
			break;
		default:
			alert("잘못된 사용자 ID나 비밀번호 입니다.");
			return false;
			break;
	}

	$('a[name=Apply]').removeClass('ui-btn-active');
	$('a[name=Apply]').addClass('ui-btn-active-a');

	User.action = "/goform/mcr_setSysAdm";
	User.submit();
	return false;
}

function CheckCancel(id, new_id, pwd, new_pwd, new_pwd_verify)
{
	$('a[name=btn_apply1]').removeClass('ui-btn-active');
	$('a[name=btn_apply1]').addClass('ui-btn-active-a');
	document.getElementById(id).value = "";
	document.getElementById(new_id).value = "";
	document.getElementById(pwd).value = "";
	document.getElementById(new_pwd).value = "";
	document.getElementById(new_pwd_verify).value = "";
	return false;
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function initValue()
{

	vendor_init();

}

function form_act(url){
	User.action = url;
	User.submit();
	return false;
}
</script>

</head>
<body onload="initValue()">
<form method="post" name="User" data-ajax="false" action="/goform/mcr_setSysAdm">

<input name="simple_flag" type="hidden" id="simple_flag" value="2">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/mobile_03_7_2_mange_account_set_mesh.asp">

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
					사용자 계정 설정
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
							<td>사용자 ID</td>
							<td>
								<input name="userId" type="text" id="user_userId" value="" style="ime-mode:disabled" maxlength="64" onfocus="on_focus_clear('user_userId')">
							</td>
						</tr>
						<tr>
							<td>변경할 ID 입력</td>
							<td>
								<input name="ChgUserId" type="text" id="user_ChgUserId" value="" style="ime-mode:disabled" maxlength="64" onfocus="on_focus_clear('user_ChgUserId')">
							</td>
						</tr>
						<tr>
							<td>현재 비밀번호 입력</td>
							<td>
								<input name="password" type="password" id="user_password" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_password')">
							</td>
						</tr>
						<tr>
							<td>변경할 비밀번호 입력</td>
							<td>
								<input name="ChgPassword" type="password" id="user_ChgPassword" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_ChgPassword')">
							</td>
						</tr>
						<tr>
							<td>변경할 비밀번호 확인</td>
							<td>
								<input name="ChgPasswordVerify" type="password" id="user_ChgPasswordVerify" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_ChgPasswordVerify')">
							</td>
						</tr>
						<tr>
							<td></td>
							<td>
								<label id="m_passwd_alert" ame="m_passwd_alert">비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.</label>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<a href="javascript:;" id="Apply" name="Apply" onclick="return CheckValue(1, 'user_userId', 'user_ChgUserId', 'user_password', 'user_ChgPassword', 'user_ChgPasswordVerify')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
				<td>
					<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return form_act('/goform/mcr_wlan_mesh_KTlogOut')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">취소</a>
				</td>
			</tr>
		</table>
	</div>
</div>
</form>
</body>
</html>
