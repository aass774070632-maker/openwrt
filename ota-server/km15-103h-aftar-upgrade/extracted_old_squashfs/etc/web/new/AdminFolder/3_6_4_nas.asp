<html>
<head>
<%include('new/metatag.asp');%>
<title>NAS 설정</title>
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
<script language='JavaScript' type='text/javascript' src='/script/mcr_common.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>

<script>
var beforId = "menu03";
var arrData = new Array();
var editerEnable;
var i;
var entries_user = new Array();
var entries_status = new Array();
var all_str;
var one_entry;

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

function changeTableA() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}else{
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function isNumberKey(evt) {
	var charCode = (evt.which) ? evt.which : event.keyCode;
	if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57))
		return false;
	return true;
}

function onClickSelectAll()
{
	var userlist_cnt = "<% mcr_getCfgString("NASUserManage_MaxUserInfo"); %>";

	for( var row = 0; row < userlist_cnt; row++ ){
		var strElementName = "deluser_"+row;
		initCheckboxById(strElementName, "1");
	}
}

function selectMenu3rd(){
	$("#menu03").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function initValue(){
	
	selectMenu3rd();
	chkeckPwdEditer();

	parent.mcrProgress.stopProgress();

	var encryp = "<% mcr_getCfgString("HOMEDrivceCfgParam_Encryption"); %>";
	var mcr_DLNAEnable	= "<% mcr_getCfgString("DLNACfgParam_Enable"); %>";
	var mcr_SMBEnable	= "<% mcr_getCfgString("SMBCfgParam_Enable"); %>";
	var mcr_WebServerEnable = "<% mcr_getCfgString("WebServerCfgParam_Enable"); %>";
	var mcr_UsbEnable	= "<% mcr_getCfgString("USBCfgParam_Enable"); %>";


	if(encryp == "1"){
		form_nas.encrypenable[1].checked = true; 
	}
	else{
		form_nas.encrypenable[0].checked = true;
	}

	if(mcr_UsbEnable == "1"){
		form_nas.usbenable[0].checked = true;
		$("#dlnaTitle").show();
		$("#webserverTitle").show();
		$("#usbstgTitle").show();
		$("#usbstrTile1").show();
		
		if(mcr_DLNAEnable == "1")
			form_nas.dlnaenable[0].checked = true;
		else
			form_nas.dlnaenable[1].checked = true;

		if(mcr_SMBEnable == "1")
			form_nas.smbenable[0].checked = true;
		else
			form_nas.smbenable[1].checked = true;

		if(mcr_WebServerEnable == "1")
			form_nas.nasWebenable[0].checked = true;
		else
			form_nas.nasWebenable[1].checked = true;

	}else{
		form_nas.usbenable[1].checked = true;
		$("#dlnaTitle").hide();
		$("#webserverTitle").hide();
		$("#usbstgTitle").hide();
		$("#usbstgTitle_1").hide();
		$("#usbstgTitle_2").hide();
		$("#usbstrTile1").hide();
		$("#usbstorage1").hide();
		$("#usbstorage2").hide();
		$("#usbstorage2-1").hide();
		$("#usbstorage3").hide();
	}
			
		initSMBEnable();
		initUsbListEnable(mcr_UsbEnable);

		changeTableA();

}
function CheckValue()
{
	parent.mcrProgress.startProgressSimple("apply", 3);
	form_act('/goform/mcr_setHOMEDrive');
	
	return true;
}	
function initSMBEnable()
{
	for(i=0; i<form_nas.smbenable.length; i++){   
      if(form_nas.smbenable[i].checked){                 
        var SMBEnable = form_nas.smbenable[i].value;                
       }                                                              
    }                     
	
	if(SMBEnable == 0) {
		$("#btn_apply").show();
		$("#usbstorage1").hide();
		$("#usbstorage2").hide();
		$("#usbstorage2-1").hide();
		$("#usbstorage3").hide();
	
		
	}
	else if (SMBEnable == 1) {
		$("#btn_apply").hide();
		$("#usbstorage1").show();
		$("#usbstorage2").show();
		$("#usbstorage2-1").show();
		$("#usbstorage3").show();
	}
	changeTableA();
}

function changeSMB()
{
	initSMBEnable();

}	
function onClickApplySMB(){

	parent.mcrProgress.startProgressSimple('apply', 3);
	form_act('/goform/mcr_setSMB');
	initSMBEnable();
}
	
function chkeckPwdEditer()
{
    if(form_nas.hidepwd.checked){
		$("#userpwdpass").hide();
		$("#userpwdtext").show();
		document.getElementById("adduserpwd_text").value=document.getElementById("adduserpwd").value;	
	} else {
		$("#userpwdpass").show();
		$("#userpwdtext").hide();
		document.getElementById("adduserpwd").value=document.getElementById("adduserpwd_text").value;	
	}
}

function onClickApplyWebServer() {
	parent.mcrProgress.startProgressSimple('apply', 10);
	form_act('/goform/mcr_addWebServer');
}

function initNasWebListEnable()
{
	for(i=0; i<form_nas.nasWebenable.length; i++){   
      if(form_nas.nasWebenable[i].checked){                 
        var WebListEnable = form_nas.nasWebenable[i].value;                
       }                                                              
    }                     
	
	if(WebListEnable == 0) {
		$("#view_WebServer").hide();
	}
	else if (WebListEnable == 1) {
		$("#view_WebServer").show();
	}
}
function ChangeNasWebList()
{
}

function WebServerFormCheck()
{
	var mcr_ExWebPort = "<% mcr_getCfgString("ExtWebCtrl_Port"); %>";
	var mcr_ExWebUserPort = "<% mcr_getCfgString("ExtWebCtrl_UserPort"); %>";
	var mcr_SMBEnable1 = "<% mcr_getCfgString("SMBCfgParam_Enable"); %>";
	
	if(form_nas.nasWebenable[0].checked){
		if(mcr_SMBEnable1 == "0"){
			alert("USB 스토리지 설정을 활성화해 주세요");
			return true;
		}
	}

	if( document.form_nas.nasWebPort.value < 0 ||
		document.form_nas.nasWebPort.value > 65535 ) {
			alert("웹서버의 Port를 입력해 주세요(0~65535, 예) 8090, 9433");
			document.form_nas.nasWebPort.focus();
			return false;
		}
	if( document.form_nas.nasWebPort.value == mcr_ExWebPort ||
		  document.form_nas.nasWebPort.value == mcr_ExWebUserPort ) {
			alert("이미 사용중인 Port 입니다.");
			document.form_nas.nasWebPort.focus();
			return false;
		}

	form_act('/goform/mcr_addWebServer');
	return true;
}

function onClickApplyaddNASUser(){
    if(form_nas.hidepwd.checked){
		document.getElementById("adduserpwd").value=document.getElementById("adduserpwd_text").value;	
	}
	var UserCount = "<%mcr_getCfgString("NASUserManage_MaxUserInfo");%>";
	var UserID = document.getElementById("adduserid").value;
	var UserPW = document.getElementById("adduserpwd").value;
	var UserTag = document.getElementById("addusertag").value;
	var UserList = "<% mcr_getNASUserList(); %>";
	var message = 0;
	var cnt=1;
	var a, UserType = false;

	var num = UserPW.search(/[0-9]/g);
	var eng = UserPW.search(/[a-z]/ig);
	var spe = UserPW.search(/[`~!@@#$%^&*|\\\'\";:\/?]/gi);


	for(var i=0;i<3;i++){
		if(document.getElementsByName("addusertype")[i].checked == true){
			UserType = true;
			break;
		}
	}
	if((UserCount != 0) && (UserID == "") && (UserPW == "") && (UserType == false ) && (UserTag =="")){
		message = 0;
	}else{
		if(UserID == "") message = 1;	
		else if(UserPW == "") message = 2;	
		else if(UserPW.length < 8) message = 5;	
		else if(num < 0 || eng < 0 || spe < 0) message=7;
		else if(UserType == false) message = 6;
		else if (UserList != "") {
			entries_user = UserList.split(";");

			for(i=0; i<entries_user.length; i++){
				var one_entry = entries_user[i].split(",");
				arrData[i] = one_entry;
			}
			for(i=0;i<entries_user.length; i++){
				var e = document.getElementById("deluser_"+i);
				if(e.checked == true){
					cnt = 0;
					a = i;
					break;
				}
			}
			
			if(cnt){
				for(i=0; i<entries_user.length; i++){
					if( UserID == arrData[i][0]) message = 4; 
				}
			}else{
			}
			if(cnt){
				if(message == 0 && (entries_user.length >=6)) message = 3;
			}
		}
	}
	switch(message) {
		case 1:		
			alert("이름(ID)를 입력해 주세요");
			document.getElementById("adduserid").focus();
			return false;
			break;
		case 2:
			alert("암호가 입력되지 않았습니다. 암호를 확인해 주세요");
			document.getElementById("adduserpwd").focus();
			return false;
			break;
		case 3:
			alert("사용자계정을 더 이상 추가 할 수 없습니다");
			document.getElementById("adduserid").focus();
			return false;
			break;
		case 4:
			alert("사용자 계정이 중복되었습니다. 사용자 이름(ID)를 확인해 주세요");
			document.getElementById("adduserid").focus();
			return false;
			break;
		case 5:
			alert("비밀번호는 8자 이상 입력해 주세요");
			document.getElementById("adduserpwd").focus();
			return false;
			break;
		case 6:
			alert("권한을 체크하세요");
			return false;
			break;
		case 7:
			alert("비밀번호는 영문 대소문자(A~Z, a~z), 숫자, 특수문자 중 3가지 조합으로 8자 이상 입력해 주세요.");
			return false;
			break;
		default:
			
			parent.mcrProgress.startProgressSimple('apply', 10);
			form_act('/goform/mcr_setSMB');
			break;
	}
	changeTableA();
	return;
}

function initUsbListEnable(USBEnable)
{
	if(USBEnable == 0) {
		$("#usbstatus0").hide();
		$("#usbstatus1").hide();
	}
	else if(USBEnable == 1){
		$("#usbstatus0").show();
		$("#usbstatus1").show();
	}
}		
	
function ChangeUSBEnable()
{
	if(form_nas.usbenable[0].checked){
		parent.mcrProgress.startProgressSimple('apply', 20);
	}
	
	form_act('/goform/mcr_setUSB');
}
function act(index){
	
	var UserList = "<% mcr_getNASUserList(); %>";
	entries_user = UserList.split(";");
	one_entry = entries_user[index].split(",");
	arrData[index] = one_entry;
		
	document.form_nas.adduserid.value = arrData[index][0];

	if(arrData[index][2] == "r"){
		document.getElementsByName("addusertype")[0].checked = true;
	}else if(arrData[index][2] == "rw"){
		document.getElementsByName("addusertype")[1].checked = true;
	}else
		document.getElementsByName("addusertype")[2].checked = true;	
	document.form_nas.addusertag.value = arrData[index][3];

	$("#modyuser").val( '' + index );

	return false;
			
}
function onClickModify()
{
	var UserList = "<% mcr_getNASUserList(); %>";
	entries_user = UserList.split(";");
	for(var j=0; j<entries_user.length;j++){
		one_entry = entries_user[j].split(",");
		arrData[j] = one_entry;
	}
	for(var k=0; k<entries_user.length; k++){
		obj = document.getElementById("deluser_"+k); 
		if(obj.checked == true){
			document.form_nas.adduserid.value = arrData[k][0];
			document.form_nas.addusertype.value = arrData[k][2];
			document.form_nas.addusertag.value = arrData[k][3];
			
		}
	}
		
	return false;
}
		
function onClickApplydelNASUser()
{
	parent.mcrProgress.startProgressSimple('apply', 10);
	form_act('/goform/mcr_deleteNASUser');
}

function onClickApplydelUSB()
{
	parent.mcrProgress.startProgressSimple('apply', 5);
	form_act('/goform/mcr_deleteUSB');
}

function form_act(url){
	form_nas.action = url;
	form_nas.submit();
	return false;
}
var disable_tags=["input", "textarea", "select"];

disable_tags=disable_tags.join("|");

$(document).ready(function(){
$("input[type='text']").mjq_disableInputEnter();
$("input[type='password']").mjq_disableInputEnter();
});

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

<body onload="initValue()">
<form method=post name="form_nas">
<input type="hidden" name="Redirect_url" id="Redirect_url" value="/new/AdminFolder/3_6_4_nas.asp" />
<input type="hidden" id="modyuser" name="modyuser" value="" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_6_menu3rd.asp');%>

		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="200" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">스마트드라이브 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0" id="encryption">
							<tr>
								<td class="font5">암호화 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr id = "encryptionset">
											<td height="25" class="BG2" style="width:140px;">암호화</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="encrypenable" type="radio" value="0" /> 활성
														</td>
														<td>
															<input name="encrypenable" type="radio" value="1" /> 비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return CheckValue()"/></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">USB 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr id = "usbset">
											<td height="25" class="BG2" style="width:140px;">USB 설정</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="usbenable" type="radio" value="1" /> 활성
														</td>
														<td>
															<input name="usbenable" type="radio" value="0" /> 비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return ChangeUSBEnable()"/></td>
										</tr>
									</table>
									<table class="TB"width="20%" border="0" id="usbstatus0">
										<tr id = "usblist">
											<td height="25" class="BG2" style="width:140px;">USB 현황</td>
										</tr>
										<br>
									</table>
									<table class="TB" width="100%" border="0" id="usbstatus1">
										<tr id = "connectusb">
											<td height="25" class="BG2-1" style="width:100px;"align="center" >선택</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >이름</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >종류</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >상태</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >파일시스템</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >총 용량(Byte)</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >남은 용량(Byte)</td>
										</tr>
										<script language="JavaScript" type="text/javascript">

											entries = new Array();
											all_str = "<% mcr_getUSBConnectList(); %>";

											if (all_str == "") {
												document.write("<tr>");
												document.write("<td colspan=7 id=USBListNone align=\"center\"> 접속된 USB 정보 없음 </td>");
												document.write("</tr>\n");
											}
											else {
												entries = all_str.split(";");
												for(i=0; i<entries.length; i++){
													one_entry = entries[i].split(",");
													arrData[i] = one_entry;
												}
												for(i=0; i<entries.length; i++){
													document.write("<tr>");
													document.write("<td class='BG2-2' width='10%' align=\"center\">");
													document.write("<input type=checkbox name=delusb_" + i + " id=delusb_" + i + "/>");
													document.write("</td>");
													document.write("<td class='BG2-2' width='17%' align=\"center\">" + arrData[i][0] +"</td>");
													document.write("<td class='BG2-2' width='10%' align=\"center\">" + arrData[i][1] +"</td>");
													document.write("<td class='BG2-2' width='10%' align=\"center\">" + arrData[i][2] +"</td>");
													document.write("<td class='BG2-2' width='10%' align=\"center\">" + arrData[i][3] +"</td>");
													document.write("<td class='BG2-2' width='13%' align=\"center\">" + arrData[i][4] +"</td>");
													document.write("<td class='BG2-2' width='13%' align=\"center\">" + arrData[i][5] +"</td>");
													document.write("</tr>\n");
												}
											}
										</script>
										<tr>
											<td class="PD6" colspan="7"><input name="Apply" type="image" src="/images/BTN/BTN_09.gif" width="52" height="24" onclick="return onClickApplydelUSB()"/></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0" id="dlnaTitle">
							<tr>
								<td class="font5">DLNA 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr id = "dlnaset">
											<td height="25" class="BG2" style="width:140px;">DLNA 설정</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="dlnaenable" type="radio" value="1" /> 활성
														</td>
														<td>
															<input name="dlnaenable" type="radio" value="0" /> 비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return form_act('/goform/mcr_setDLNA')"/></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0" id="webserverTitle">
							<tr>
								<td class="font5">Web 접속 설정(Samba)</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr id = "dlnaset">
											<td height="25" class="BG2" style="width:140px;" rowspan="2">Web 접속</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="nasWebenable" type="radio" value="1" onchange="ChangeNasWebList()"/> 활성
														</td>
														<td>
															<input name="nasWebenable" type="radio" value="0" onchange="ChangeNasWebList()"/> 비활성
														</td>
													</tr>
												</table>
											</td>
											<tr width="400px" id="view_WebServer" name="view_WebServer">
												<td class="BG2-2" width="600px">
													<table  border="0" cellpadding="0" cellspacing="0" class="font1">
														<td width="110">포트</td>
														<td width="5"></td>
														<td width="10"><input name="nasWebPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="nasWebPort" size="32" maxlength="17" value="<%mcr_getCfgString("WebServerCfgParam_Port"); %>"/>
														</td>
													</table>
												</td>
											</tr>
										</tr>
										<tr>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return WebServerFormCheck()"/></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr id="usbstgTitle">
								<td class="font5">USB 스토리지 설정</td>
							</tr>
							<tr id="usbstgTitle_1">
								<td class="PD4"></td>
							</tr>
							<tr id="usbstgTitle_2">
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0" id="usbstrTile1">
										<tr>
											<td height="25" class="BG2" style="width:140px;">USB 스토리지</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="smbenable" type="radio" value="1" onChange="initSMBEnable()"/> 활성
														</td>
														<td>
															<input name="smbenable" type="radio" value="0" onChange="initSMBEnable()"/> 비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id=btn_apply>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return onClickApplySMB()"/></td>
										</tr>
									</table> 
									<table class="TB" width="100%" border="0" id="usbstorage1">
										<tr id = "adduser1">
											<td height="25" class="BG2" style="width:140px;">이름(ID)</td>
											<td class="BG2-2" width="600">
												<input name="adduserid" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="adduserid" size="32" maxlength="17" value="" autocomplete="off"></td>
										</tr>
										<tr id = "adduser2">
											<td height="25" class="BG2" style="width:140px;">암호</td>
											<td class="BG2-2" width="600">					
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
													<td width="200" id="userpwdpass" style="display:none">
														<input id="adduserpwd" name="adduserpwd" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" size="32" maxlength="17" value="" autocomplete="new-password">
													</td>
													<td width="200" id="userpwdtext" style="display:none">
														<input id="adduserpwd_text" name="adduserpwd_text" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" size="32" maxlength="17" value="" autocomplete="off">
													</td>
														<td width="200"><input name="hidepwd" type="checkbox" onclick="chkeckPwdEditer()" />암호보기(8자이상)</td>
													</tr>
												</table>
										</tr>
										<tr id = "adduser3">
											<td height="25" class="BG2" style="width:140px;">권한</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="addusertype" type="radio" value="r" /> 읽기
														</td>
														<td width="110">
															<input name="addusertype" type="radio" value="rw" /> 읽기/쓰기
														</td>
														<td>
															<input name="addusertype" type="radio" value="x" /> 사용 안함
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id = "adduser4">
											<td height="25" class="BG2" style="width:140px;">설명</td>
											<td class="BG2-2" width="600">	<input name="addusertag" style="width:300;" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="addusertag" size="32" maxlength="17"/></td>
										</tr>
										<tr>
											<td class="PD6" colspan="2"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif" width="52" height="24" onclick="return onClickApplyaddNASUser()"/></td>
											
										</tr>
									</table>

									<table class="TB" width="20%" id="usbstorage2">
										<tr id = "userlist">
											<td height="25" class="BG2" style="width:140px;"colspan="1">사용자 계정</td>
											<td></td>
										</tr>
									</table>
									<table class="TB" width="100%" border="0" id="usbstorage2-1">
										<tr id = "deluser1">
											<td height="25" class="BG2-1" style="width:100px;"align="center" >선택</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >ID</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >권한</td>
											<td height="25" class="BG2-1" style="width:200px;"align="center" >설명</td>
										</tr>
 											<script language="JavaScript" type="text/javascript">
												
												entries_user = new Array();
												all_str = "<% mcr_getNASUserList(); %>";
															
												if (all_str == "") {
													document.write("<tr>");
													document.write("<td colspan=4 id=nasUserListNone align=\"center\"> 등록된 사용자가 없음 </td>");
													document.write("</tr>\n");
												}
												else{
													entries_user = all_str.split(";");
													for(i=0; i<entries_user.length; i++){
														one_entry = entries_user[i].split(",");
														arrData[i] = one_entry;
													}
													
													for(i=0; i<entries_user.length; i++){
														if(arrData[i][2] == "rw"){
															arrData[i][2] = "읽기/쓰기";
														}else if(arrData[i][2] == "r"){
															arrData[i][2] = "읽기";
														}else if(arrData[i][2] == "x"){
															arrData[i][2] = "사용안함";
														}
														document.write("<tr>");
														document.write("<td class='BG2-2' width='10%' align=\"center\">");
														document.write("<input type=checkbox name=deluser_" + i + " id=deluser_" + i + " onClick=act("+i+")>");
														document.write("</td>");
														document.write("<td class='BG2-2' width='30%' align=\"center\">" + arrData[i][0] +"</td>");
														document.write("<td class='BG2-2' width='20%' align=\"center\">" + arrData[i][2] +"</td>");
														document.write("<td class='BG2-2' width='40%' align=\"center\">" + arrData[i][3] +"</td>");
														document.write("</tr>\n");
													}
												}
											</script>
										<tr>
											<td class="PD6" colspan="4">
												<input name="Apply" type="image" src="/images/BTN/BTN_02.gif" width="52" height="24" onclick="return onClickApplydelNASUser()"/>
											</td>
										</tr>
									</table>

									<table class="TB" width="100%" border="0" id="usbstorage3">
										<tr id = "connectList">
											<td height="25" class="BG2" style="width:100px;" colspan="1"> 접속현황</td>
											<td height="25"><input name="Apply" type="image" src="/images/ad_refresh_select.gif" width="71" height="18" onclick="location.reload()"/>
											<td></td>
										</tr>
										<tr id = "connectuser">
											<td height="25" class="BG2-1" style="width:100px;"align="center" >구분</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >접속주소</td>
											<td height="25" class="BG2-1" style="width:100px;"align="center" >이름</td>
											<td height="25" class="BG2-1" style="width:200px;"align="center" >접속시간</td>
										</tr>
 											<script language="JavaScript" type="text/javascript">
												entries_status = new Array();
												all_str = "<% mcr_getConnectList(); %>";
															
												if (all_str == "") {
													document.write("<tr>");
													document.write("<td colspan=4 id=nasUserListNone align=\"center\"> 접속된 사용자가 없음 </td>");
													document.write("</tr>\n");
												}
												else{
													entries_status = all_str.split(";");
													for(i=0; i<(entries_status.length-1); i++){
														one_entry = entries_status[i].split(",");
														arrData[i] = one_entry;
													}

													for(i=0; i<(entries_status.length-1); i++){
														if(arrData[i][0] == "web") {
															arrData[i][0] = "Web";
														} else if( arrData[i][0] == "app") {
															arrData[i][0] = "App";
														}

														document.write("<tr>");
														document.write("<td class='BG2-2' width='20%' align=\"center\">" + arrData[i][0] +"</td>");
														document.write("<td class='BG2-2' width='20%' align=\"center\">" + arrData[i][1] +"</td>");
														document.write("<td class='BG2-2' width='20%' align=\"center\">" + arrData[i][2] +"</td>");
														document.write("<td class='BG2-2' width='40%' align=\"center\">" + arrData[i][3] +"</td>");
														document.write("</tr>\n");
													}
												}
											</script>
									</table>
									<br>


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
</body>
</html>
