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

var beforId = "menu00";

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

function changeTableAdmin() {
	selectMenu3rd();
	parent.mcrProgress.stopProgress();	
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function isAllNum(str)
{
	for (var i=0; i<str.length; i++) {
		if ((str.charAt(i) >= '0' && str.charAt(i) <= '9') )
			continue;
		return 0;
	}
	return 1;
}

function NTPFormCheck()
{
	if( document.NTP.NTPServer.value == "" ) {
		alert("NTP 서버주소를 입력해 주세요");
		document.NTP.NTPServer.focus();
		return false;
	}
	if( document.NTP.NTPServer2.value == "") {
		alert("NTP 서버주소를 입력해 주세요");
		document.NTP.NTPServer2.focus();
		return false;
	}
	if ( document.NTP.NTPInterval.value == "") {
		alert("NTP 요청간격을 입력해 주세요");
		document.NTP.NTPInterval.focus();
		return false;
	}
	if (isAllNum(document.NTP.NTPInterval.value) == 0) {
		alert("입력오류입니다.숫자를 입력해 주세요");
		document.NTP.NTPInterval.focus();
		return false;
	}
	if ( document.NTP.NTPInterval.value == "0") {
		alert("0 이상의 값을 입력해 주세요");
		document.NTP.NTPInterval.value="";
		document.NTP.NTPInterval.focus();
		return false;
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	return true;
}

function selectMenu3rd(){
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");
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

<body onload="changeTableAdmin();">
<form method="post" name="NTP" action="/goform/mcr_setNTP">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/AdminFolder/3_7_1_time_manage.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
        <td valign="top">
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
            <table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
  <tr>
    <td valign="top" ><table width="98%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="font5">시간 관리</td>
      </tr>
      <tr>
        <td class="PD4"></td>
      </tr>
      <tr>
        <td class="PD5"></td>
      </tr>
      <tr>
        <td><table class="TB" width="100%" border="0">
          <tr>
            <td height="25" class="BG2" style="width:140px;">NTP 기본 서버</td>
            <td class="BG2-2" width="600"><input name="NTPServer" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="NTPServer" value="<% mcr_getCfgString("TimeCfgParam_ntpServer1"); %>" /></td>
          </tr>
          <tr>
            <td height="25" class="BG2" style="width:140px;">NTP 보조 서버</td>
            <td class="BG2-2" width="600"><input name="NTPServer2" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="NTPServer2" value="<% mcr_getCfgString("TimeCfgParam_ntpServer2"); %>" /></td>
          </tr>
          <tr>
            <td height="25" class="BG2" style="width:140px;">NTP 요청 간격</td>
            <td class="BG2-2" width="600"><input name="NTPInterval" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="NTPInterval" value="<% mcr_getCfgString("TimeCfgParam_ntpInterval"); %>"/> min</td>
          </tr>
          <tr>
            <td height="25" colspan="2" class="PD6"><input name="Apply" type="image"  value="Apply" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onClick="return NTPFormCheck()"/></td>
            </tr>
          <tr>
            <td height="25" colspan="2" class="PD5"><p>　</td>
            </tr>
          <tr>
            <td height="25" class="BG2" style="width:140px;">최근 동기화 시간</td>
            <td class="BG2-2"><% mcr_getNtpConTime(); %></td>
          </tr>
          <tr>
            <td height="25" class="PD6" width="778" colspan="2">
                <p align="right"><input name="Sync" type="image" value="Sync" src="/images/BTN/BTN_11.gif?Sp2" width="71" height="24" /></td>
          </tr>
        </table></td>
      </tr>
      
    </table></td>
  </tr>
</table>

        </td>
    </tr>
</table>
</form>
</body>
</html>
