<html>
<head>
<%include('new/metatag.asp');%>
<title>IDS 설정</title>
<%include('new/script.asp');%>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
.TB-1{
        width:778px;
        table-layout:fixed;
}
</style>
<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript"></script>
<script>

var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

var beforId = "menu02";
function mouseover(clickId){
        var obj = document.getElementById(clickId);
        obj.className="menu3rdMouse";
}
function mouseout(clickId){
        var obj = document.getElementById(clickId);
        if(beforId == clickId)
        {
                obj.className="menu3rdSelect";
        }else{
                obj.className="menu3rdNormal";
        }
}

function selectMenu3rd(){
        $("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function changeTableAdmin()
{
        if(document.body.scrollHeight>656) {
                parent.document.getElementById("main").style.height=document.body.scrollHeight;
                parent.document.getElementById("menu").style.height=document.body.scrollHeight;
        }else{
                parent.document.getElementById("main").style.height=656;
                parent.document.getElementById("menu").style.height=656;
        }
}

function initValue(){
        var Enable = '<%mcr_getCfgString("IDSCfgParam_IDSEnable"); %>';

        selectMenu3rd();

        if(Enable == '1'){
                form_ids_enable.radioActivity_IDSEnable[0].checked = true;
		
        }else{
                form_ids_enable.radioActivity_IDSEnable[1].checked = true;
        }

	if(opmode == "0")
		$("input[id='radioActivity_IDSEnable']").attr('disabled',true);
	
	parent.mcrProgress.stopProgress();

}
		
function onClick_IDSEnable(){
	if(opmode == "0") {
		alert("브릿지 모드에서는 설정이 불가한 기능입니다.");
	} else {
		parent.mcrProgress.startProgressSimple('apply', 10);
		form_act('/goform/mcr_setIDS_Enable');
	}
}

function form_act(url){
	form_ids_enable.action = url;
	form_ids_enable.submit();
	return true;
}
		
</script>
</head>
<body onload="initValue()">
<form method="post" class="form_layout" id="form_ids_enable" name="form_ids_enable"> 
<input type="hidden" id="IDSRedirectPage" name="IDSRedirectPage" value="/new/AdminFolder/3_5_3_ids_set.asp"/>

<table width="800%" border="0" cellspacing="0" cellpadding="0">
  <tr><td valign="top"><%include('new/AdminFolder/3_5_menu3rd.asp');%></td></tr>
  <tr><td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
    <table width="800" height="200" border="0" cellspacing="0" cellpadding="10">
    <tr><td valign="top">
      <table width="98%" border="0" cellspacing="0" cellpadding="0">
        <tr><td class="font5">IDS 설정</td></tr>
        <tr><td class="PD4"></td></tr>
        <tr><td class="PD5"></td></tr>
        <tr><td>
          <table class="TB" width="100%" border="0">
          <tr>
            <td height="25" class="BG2" style="width:140px;">IDS 설정</td>
            <td class="BG2-2" width="600" colspan="3">
              <table  border="0" cellpadding="0" cellspacing="0" class="font1">
                <tr>
                  <td width="110"><input name="radioActivity_IDSEnable" id="radioActivity_IDSEnable" type="radio" value="1"/>활성</td>
                  <td><input name="radioActivity_IDSEnable" id="radioActivity_IDSEnable" type="radio" value="0"/>비활성</td>
                </tr>
              </table>
            </td>
          </tr>
          </table>
          <tr id ="apply">
            <td class="PD6" colspan="3">
              <input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply" height="24" width="52"name="btn_apply" onClick="return onClick_IDSEnable()"/>
            </td>
          </tr>
        </td></tr>
      </table>
    </td></tr>
    </table>
  </td></tr>
</table>
</form>
</body>
</html>
