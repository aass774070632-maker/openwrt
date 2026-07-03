<html>
<head>
<%include('new/metatag.asp');%>
<title>GiGA WiFi home</title>
<%include('new/script.asp');%>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
a { font-style:normal; font-weight:normal; text-decoration:none; }
body {
        margin-left: 10px;
        margin-top: 10px;
        margin-right: 10px;
        margin-bottom: 10px;
        background-color: #ffffff;
}

.table {
        border-top-width: 2px;
        border-top-style: solid;
        border-top-color: #333333;
}
.font100 {
        FONT-FAMILY: "돋움",  "arial";
        FONT-SIZE: 14px;
        LINE-HEIGHT: 14pt;
        COLOR: #000000
}
.font101 {
        FONT-FAMILY: "돋움",  "arial";
        FONT-SIZE: 12px;
        LINE-HEIGHT: 12pt;
        COLOR: #666666
}
-->
</style>

<script>

var beforId = "menu01";

function mouseover(clickId){
	var obj = document.getElementById(clickId);
	obj.className="menu3rdMouse";

}

function mouseout(clickId)
{
	var obj = document.getElementById(clickId);
	if(beforId == clickId)
	{
		obj.className="menu3rdSelect";
	}
	else
	{
		obj.className="menu3rdNormal";
	}
}

function isUnderBarCheck(data) {
	if (data.indexOf(("_"))==-1){
		return true;
	}
	return false;
}

function form_act(url){
	User.action = url;
	User.submit();
	return false;
}

function CheckValue(chgType, new_id, new_pwd, new_pwd_verify)
{
	var new_userId = document.getElementById(new_id).value;
	var new_password = document.getElementById(new_pwd).value;
	var new_password_verify = document.getElementById(new_pwd_verify).value;
	var sys_user_id;
	var userId = '<% mcr_getCfgCommon("UserManage_Name_1"); %>';
	var num = new_password.search(/[0-9]/g);
	var eng = new_password.search(/[a-z]/ig);

	var value = $("#user_ChgPassword").val();

	if ( !isEmpty(new_userId) ) {
		if ( userId == new_userId ) {
			alert("신규 ID와 사용자 ID가 일치합니다.");
			return false;
		}
	}
	if ( !isEmpty(new_password) || !isEmpty(new_password_verify) ) {
		if ( isEmpty(new_password) || isEmpty(new_password_verify) ) {
			alert("신규 비밀번호를 입력해 주세요");
			return false;
		}
		if ( new_password != new_password_verify) {
			alert("신규 비밀번호가 일치하지 않습니다");
			return false;
		}
		if( num < 0 || eng < 0 || value.length < 10){
			alert("비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.");
			return false;
		}
		if( num < 0 || eng < 0 || value.length > 64){
			alert("비밀번호는 최대 64자 입니다.");
			return false;
		}
	}
	if ( isEmpty(new_userId) || ( isEmpty(new_password) || isEmpty(new_password_verify) ) ) {
		alert("신규 ID나 비밀번호를 입력해 주세요");
		return false;
	}

	form_act('/goform/mcr_setSysAdmNew');
	return true;
}

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
function CheckCancel(id, new_id, pwd, new_pwd, new_pwd_verify)
{
	
	document.User.action = "/goform/mcr_KTlogOut";
	document.User.submit();
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function initValue()
{
	selectMenu3rd();
	
}

function selectMenu3rd(){
		$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

var disable_tags=["input", "textarea", "select"];

disable_tags=disable_tags.join("|");

function disable_select(e){
        if (disable_tags.indexOf(e.target.tagName.toLowerCase())==-1)
        return false;
}

function reEnable(){
        return true;
}

if (typeof document.onselectstart!="undefined")
        document.onselectstart=new Function ("return false;")
else{
        document.onmousedown=disable_select;
        document.onmouseup=reEnable;
}


document.oncontextmenu = function() {return false;};
document.onselectstart = function() {return false;};
document.ondragstart = function() {return false;};

function unlock() {
        document.oncontextmenu = null;
        document.onselectstart = null;
        document.ondragstart = null;

}

function lock() {
        document.oncontextmenu = function() {return false;};
        document.onselectstart = function() {return false;};
        document.ondragstart = function() {return false;};
}

</script>

</head>

<body onload="initValue();">
<form method="post" name="User"> 
<input name="redirect_url" type="hidden" id="redirect_url" value="/reset_account.asp" />
<table border="0" cellpadding="0" cellspacing="0" style="font-size:10px" width="990" height="600">
	<tr>
		<td valign="top">
			<table valign="top" border="0" cellpadding="0" cellspacing="0" width="988" height="51" bgcolor="#F9F9F9">
                       		<tr height="3">
                               		<td width="988" colspan="8" style="font-size:8px;"></td>
                               	</tr>
                               	<tr height="45">
                               		<td width="5"></td>
                                       	<td width="45" height="45">
                                       		<img src="/images/top_01.gif?version=<% mcr_getWebVersion(); %>" width="45" height="45" border="0">
                                       	</td>
                                       	<td width="5"></td>
                                       	<td width="230" height="45">
                                       		<img src="/images/top_02.gif?version=<% mcr_getWebVersion(); %>" width="190" height="45" border="0">
                                       	</td>
                                    	<td width="20"></td>
                                       	<td height="45" align="left" valign="bottom">
                                       		<img src="/images/top_04.gif?version=<% mcr_getWebVersion(); %>" width="360" height="22" border="0">
                                       	</td>
                                       	<td width="5"></td>
                                       	<td width="45" height="45" align="right" valign="bottom">
                                       		<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" width="35" height="28" border="0">
                                       	</td>
                                       	<td width="5"></td>
                               	</tr>
                               	<tr height="3">
                               		<td width="988" colspan="8" style="font-size:8px;"></td>
                               	</tr>
                       	</table>
                       	<table cellpadding="0" cellspacing="0" width="988" height="4" bgcolor="#DF2428">
                       		<tr>
                       			<td> </td>
                        	</tr>
                       	</table>
                       	<table cellpadding="0" cellspacing="0" width="100%" height="150">
                       		<tr>
                       			<td> </td>
                             	</tr>
                        </table>
			<table width="98%" border="0" cellspacing="0" cellpadding="0">	
				<tr>
					<td class="font5">사용자 계정 설정</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td>
						<table class="TB" width="100%" border="0" id="table1">
							<tr>
								<td height="25" class="BG2" style="width:140px;">신규 사용자 ID</td>
								<td class="BG2-2" width="600">
									<input name="ChgUserId" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgUserId" value="" style="ime-mode:disabled" maxlength="64" onFocus="on_focus_clear('user_ChgUserId')"/>
								</td>
							</tr>
							<tr>
								<td height="25" class="BG2" style="width:140px;">신규 비밀번호 입력</td>
								<td class="BG2-2" width="600">
									<input name="ChgPassword" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgPassword" value="" style="ime-mode:disabled" maxlength="100" onFocus="on_focus_clear('user_ChgPassword')" />
									비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.
								</td>
							</tr>
							<tr>
								<td height="25" class="BG2" style="width:140px;">신규 비밀번호 확인</td>
								<td class="BG2-2" width="600">
									<input name="ChgPasswordVerify" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgPasswordVerify" value="" style="ime-mode:disabled" maxlength="100" onFocus="on_focus_clear('user_ChgPasswordVerify')" />
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
                               		<td>
                                        	<table width="100%" border="0" cellspacing="0" cellpadding="0" id="table1">
							<tr>
								<td class="PD6">
									<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?version=<% mcr_getWebVersion(); %>" width="52" height="24" onClick="return CheckValue(1, 'user_ChgUserId', 'user_ChgPassword', 'user_ChgPasswordVerify')" />
									<input name="Cancel" type="image" src="/images/BTN/BTN_04.gif?version=<% mcr_getWebVersion(); %>" width="52" height="24" onClick="form_act('/goform/mcr_logOut'); return false;"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6">　</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
<table class="table" cellpadding="0" cellspacing="0" width="975" height="62" bgcolor="#F9F9F9">
        <tr>
                <td width="975" height="62" style="font-size:8px;">
                        <p><img src="/images/bottom.gif?version=<% mcr_getWebVersion(); %>" width="975" height="62" border="0"></p>
                </td>
        </tr>
</table>
</body>
</html>
