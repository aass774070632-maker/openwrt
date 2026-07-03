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
	var value = $("#user_ChgPassword").val();



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
				if( num < 0 || eng < 0 || value.length < 10){
					alert("비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.");
					return false;
				}
				if(value.length > 64) {
					alert("비밀번호는 최대 64자 입니다.");
					return false;
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
			if( num < 0 || eng < 0 || value.length < 10){
				alert("비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.");
				return false;
			}
			if( num < 0 || eng < 0 || value.length > 64) {
				 alert("비밀번호는 최대 64자 입니다.");
				 return false;
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

	form_act('/goform/mcr_setSysAdm');
	return true;
}

function CheckCancel(id, new_id, pwd, new_pwd, new_pwd_verify)
{
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

function initValue()
{
	selectMenu3rd();
	
	changeTableAdmin();
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
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/UserFolder/3_7_2_mange_account_set.asp">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_7_menu3rd.asp');%>
			</td>
	</tr>
	<tr>
        <td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
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
											<td height="25" class="BG2" style="width:140px;">사용자 ID</td>
											<td class="BG2-2" width="600">
												<input name="userId" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_userId" value="" style="ime-mode:disabled" maxlength="64" onfocus="on_focus_clear('user_userId')">
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">변경할 ID 입력</td>
											<td class="BG2-2" width="600">
												<input name="ChgUserId" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgUserId" value="" style="ime-mode:disabled" maxlength="64" onfocus="on_focus_clear('user_ChgUserId')">
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">현재 비밀번호 입력</td>
											<td class="BG2-2" width="600">
												<input name="password" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_password" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_password')">
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">변경할 비밀번호 입력</td>
											<td class="BG2-2" width="600">
												<input name="ChgPassword" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgPassword" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_ChgPassword')">
												비밀번호는 영문과 숫자 조합으로 10자이상 이어야 합니다.
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">변경할 비밀번호 확인</td>
											<td class="BG2-2" width="600">
												<input name="ChgPasswordVerify" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="user_ChgPasswordVerify" value="" style="ime-mode:disabled" maxlength="100" onfocus="on_focus_clear('user_ChgPasswordVerify')">
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
												<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onclick="return CheckValue(1, 'user_userId', 'user_ChgUserId', 'user_password', 'user_ChgPassword', 'user_ChgPasswordVerify')">
												<input name="Cancel" type="image" src="/images/BTN/BTN_04.gif?Sp2" width="52" height="24" onclick="return CheckCancel('user_userId', 'user_ChgUserId', 'user_password', 'user_ChgPassword', 'user_ChgPasswordVerify')">
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
		</td>
	</tr>
</table>
</form>
</body>
</html>
