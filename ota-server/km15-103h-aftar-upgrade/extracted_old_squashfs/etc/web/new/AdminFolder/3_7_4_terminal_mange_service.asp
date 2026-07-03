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

var beforId = "menu03";
var LocalCheck = "<% mcr_getCfgString("UserManage_LocalCheck"); %>";

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

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
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
	$("input[type='checkbox']").attr("disabled",false);      
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
	selectMenu3rd();

	ExtCtrlCheck();

	switch(LocalCheck){
		case '0':
			$("input[type='text']").attr("readonly",true);  
			$("input[type='checkbox']").attr("disabled",true);      
			break;
		case '1':
			break;
		default:
			break;
	}

	changeTable();
}

function selectMenu3rd(){
	$("#menu03").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

$(document).ready(function(){
	$("#extwebalw").bind( "click", function(){
		if(ServiceControl.extwebalw.checked == true){
			confirmed = confirm("원격 접속을 허용하면 보안에 취약해질 수 있습니다.  그래도 설정하시겠습니까?");
			if(!confirmed){
				return false;
			}
			
		}
	});

	$("#extwebalwad").bind( "click", function(){
		if(ServiceControl.extwebalwad.checked == true){
			confirmed = confirm("원격 접속을 허용하면 보안에 취약해질 수 있습니다.  그래도 설정하시겠습니까?");
			if(!confirmed){
				return false;
			}
		}
	});
});

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
<form method=post name="ServiceControl" action="/goform/mcr_setExtWeb">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/AdminFolder/3_7_4_terminal_mange_service.asp" />
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
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">장치 관리 서비스</td>
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
										<tr>
											<td height="25" class="BG2" style="width:140px;">웹 서버 사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="545">
													<tr>
														<td width="110">
															<input type="radio" name="ActiveSts" id="vAllow" value="1" checked="checked" />
															활성
														</td>
														<td width="110">
															<input type="radio" name="ActiveSts" id="vDeny" value="0" />
															비활성
														</td>
														<td id="user_mode">
															포트
															<input type="text" onmouseover="unlock();" onmouseout="lock();" name="extwebport" id="extwebport" maxlength=5 class="input3" value=<% mcr_getCfgString("ExtWebCtrl_UserPort"); %> />
														</td>
														<td id="user_mode1" width="110">
															<span class="BG2-3">
															<input type="checkbox" value="1" name="extwebalw" id="extwebalw" />
															</span>원격관리
														</td>
														<td>　</td>
													</tr>
													<tr id="Admin_mode">
														<td width="110">
														</td>
														<td width="110">
														</td>
														<td>
															포트
															<input type="text" onmouseover="unlock();" onmouseout="lock();" name="extwebadport" id="extwebadport" maxlength=5 class="input3" value=<% mcr_getCfgString("ExtWebCtrl_Port"); %> />
														</td>
														<td width="110">
															<span class="BG2-3">
															<input type="checkbox" value="1" name="extwebalwad" id="extwebalwad" />
															</span>원격관리
														</td>
														<td>　</td>
													</tr>
												</table>
											</td>
										</tr> 
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onClick="return CheckValue()" /></td>
							</tr>
							<tr>
								<td class="PD6">
									<p>&nbsp;</p>
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
