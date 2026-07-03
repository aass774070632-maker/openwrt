<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">

<head>
<%include('new/script.asp');%>
<title>Login Fail</title>
<%include('new/metatag.asp');%>

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
        form_act("/goform/mcr_logOut");
}
function db_reset(url)
{
        form_act(url);
        return false;
}
function form_act(url){
        form_authentic.action = url;
        form_authentic.submit();

        return false;
}

$(document).ready(function(){
        $("input[name='checkoption']").bind( "click", function(){
                var Enable = $("input[name='checkoption']:checked").val();
                if(Enable || Enable == "on"){
                        $("input[name='SecurityKey']").prop("type", "text");
                }else{
                        $("input[name='SecurityKey']").prop("type", "password");
                }

                return true;
        });
});

//마우스 드래그 및 오른쪽 버튼 막기
//Crome and Firefox
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

//IE

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

<body>
<form method="post" name="form_authentic">
<input type="hidden" id="blank" name="blank" value="">
<input name="redirect_url" type="hidden" id="redirect_url" value="/login_confirm.asp" />
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
                                <td>
                                </td>
                        </tr>
                        </table>
                        <table cellpadding="0" cellspacing="0" width="100%" height="150">
                                <tr>
                                        <td>
                                        </td>
                                </tr>
                        </table>
                        <table width="98%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                        <td class="font5">사용자 인증</td>
                                </tr>
                                <tr>
                                        <td class="PD4"></td>
                                </tr>
                                <tr>
                                </tr>
                                <tr>
                                        <td>
                                                <table class="TB" width="100%" border="0" id="table1">
                                                        <tr>
                                                                <td height="25" class="BG2" style="width:140px;">암호키</td>
                                                                <td class="BG2-2" width="600">
                                                                        <input type="password" name="SecurityKey" id="SecurityKey" size="32" maxlength="64" value=""/>  암호키보기
                                                                        <input type="checkbox" name="checkoption" value="1"/>
									<br> ※ 계정 재설정을 위한 사용자 인증
                                                                </td>
                                                        </tr>
                                                        <tr align="right">
                                                                <td> </td>
                                                                <td>
                                                                        <input type="image" src="/images/BTN/BTN_ok.gif?version=<% mcr_getWebVersion(); %>" width="52" height="24" id="skey_verify" name="skey_verify" onclick="db_reset('/goform/mcr_SecurityKeyVerify'); return false;"/>
                                                                        <input type="image" src="/images/BTN/BTN_04.gif?version=<% mcr_getWebVersion(); %>" width="52" height="24" id="confirm" name="confirm" onclick="javascript();">
                                                                </td>
                                                        </tr>
                                                </table>
                                        </td>

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
