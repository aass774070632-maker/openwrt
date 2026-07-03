<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Login Fail</title>

<link href="/style/style.css" rel="stylesheet" type="text/css">

<%include('new/metatag.asp');%>
<style>
.font8-1 
{
    FONT-FAMILY: "돋움",  "arial";
    FONT-SIZE: 14px;
    LINE-HEIGHT: 14pt;
    COLOR: #5f5f5f;
    padding-left:10px;
}
</style>
<script language="javascript" type="text/javascript" src="/lang/b28n.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common_new.js"></script>
<script language="javascript" type="text/javascript">

Butterlate.setTextDomain("admin");

function noEvent() {
    if (event.keyCode == 116) {
        event.keyCode= 2;
        return false;
    }
    else if(event.ctrlKey && (event.keyCode==78 || event.keyCode == 82))
    {
        return false;
    }
}
document.onkeydown = noEvent;

function javascript(){
	window.opener.location.href="http://"+window.location.host+"/login.asp"
	self.close();
}
function javascript1(){
	window.opener.location.href="http://"+window.location.host+"/login_confirm.asp"
	self.close();
}
function db_reset(url)
{
        httpRequest(url, "n/a", processHttpGetLog, "");
        return false;
}

function processHttpGetLog(strResponse){
	window.opener.location.href="http://"+window.location.host+"/login.asp"
	self.close();
}
</script>
</head>

<body>
<form method="post" name="form_login">
<input type="hidden" id="blank" name="blank" value="">
<table width="90%" height="150">
	<tr>
		<td>
			<table width="420" height="100" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td class="font8-1">ID 또는 비밀번호를 확인해주세요</td>
				</tr>
				<tr align="right">
					<td>
						<input type="image" src="/images/BTN/BTN_ok.gif" width="52" height="24" id="confirm" name="confirm" onclick="javascript();">
						<input type="image" src="/images/BTN/BTN_id_reset1.gif" width="85" height="24" id="confirm1" name="confirm1" onclick="javascript1();">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
