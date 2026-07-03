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

var beforId = "menu04";

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

function changeTable() 
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

function checkRange(str, min, max)
{
        d = parseInt(str, 10);
        if (d > max || d < min)
                return false;
        return true;
}
function CheckValidData()
{
	var remoteip,remotelevel;
	if ( document.form.remote[0].checked ) {
	 	remoteip = "<% mcr_getCfgCommon("SyslogdCfgParam_RemoteIp"); %>";
        	remotelevel = "<% mcr_getCfgCommon("SyslogdCfgParam_Level"); %>";
		if ( isEmpty(document.form.remoteip.value) ) {
			alert("원격서버 IP주소를 입력해 주세요");
			return false;
		}
		if ( !isIpAddress(document.form.remoteip.value) ) {
			alert("정상적인 IP 주소를 입력해 주세요");
			document.form.remoteip.value = remoteip;
                        document.form.remotelevel.value = remotelevel;
			return false;
		}
		if ( isEmpty(document.form.remotelevel.value) ) {
			alert("원격서버 전송레벨을 입력해 주세요");
			return false;
		}
		if ( !checkRange(document.form.remotelevel.value, 1, 7) ) {
			alert("1 ~ 7 사이의 정수를 입력해 주세요");
			document.form.remotelevel.value = remotelevel;
			return false;
		}
	}
}

function InitData()
{
	selectMenu3rd();
	
	var memory = "<% mcr_getCfgCommon("SyslogdCfgParam_MemoryEnable"); %>";
	var flash = "<% mcr_getCfgCommon("SyslogdCfgParam_FlashEnable"); %>";
	var remote = "<% mcr_getCfgCommon("SyslogdCfgParam_RmtEnable"); %>";
	var remoteip = "<% mcr_getCfgCommon("SyslogdCfgParam_RemoteIp"); %>";
	var remotelevel = "<% mcr_getCfgCommon("SyslogdCfgParam_Level"); %>";
	var Adminlog = "<% mcr_getCfgCommon("ExtWebCtrl_AdminLogAllow"); %>";	

	document.form.memory[0].checked = false;
	document.form.memory[1].checked = false;
	if ( memory == "1" ) {
		document.form.memory[0].checked = true;
	}
	else {
		document.form.memory[1].checked = true;
	}

	document.form.flash[0].checked = false;
	document.form.flash[1].checked = false;
	if ( flash == "1" ) {
		document.form.flash[0].checked = true;
	}
	else {
		document.form.flash[1].checked = true;
	}

	document.form.remote[0].checked = false;
	document.form.remote[1].checked = false;
	if ( remote == "1" ) {
		document.form.remote[0].checked = true;
		if(remoteip != ""){
			document.form.remoteip.value = remoteip;
		}else if(remoteip == ""){
			document.form.remoteip.value = "";
		}
	}
	else {
		document.form.remote[1].checked = true;
		document.form.remoteip.value = "";
	}
	document.form.remotelevel.value = remotelevel;

	document.form.adminlog[0].checked = false;
	document.form.adminlog[1].checked = false;
	if( Adminlog == "1"){
		document.form.adminlog[0].checked = true;
	}else{
		document.form.adminlog[1].checked = true;
	}

	changeTable();
}
function EnableSet(val){
	var remoteip = "<% mcr_getCfgCommon("SyslogdCfgParam_RemoteIp"); %>";
	
	if(val == 1){
		document.form.remoteip.value = "";
	}else{
		document.form.remoteip.value = remoteip;
	}
}
function selectMenu3rd(){
		$("#menu04").removeClass("menu3rdNormal").addClass("menu3rdSelect");
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

<body onLoad="InitData();">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<form name="form" action="/goform/mcr_setSyslogd" >
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">로그 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">메모리 저장</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="memory" id="memory" value="0" />활성
														</td>
														<td>
															<input type="radio" name="memory" id="memory" value="1" />비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">플래시 저장</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="flash" id="flash" value="0" />활성
														</td>
														<td>
															<input type="radio" name="flash" id="flash" value="1" />비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td rowspan="3" class="BG2" style="width:140px;">원격저장</td>
											<td height="25" class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="remote" id="remote" value="0" OnClick="EnableSet(value)"/>활성
														</td>
														<td>
															<input type="radio" name="remote" id="remote" value="1" OnClick="EnableSet(value)"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" width="600">원격서버 IP 주소  
												<input type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" name="remoteip" id="remoteip" value="" />
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" width="600">원격서버 전송레벨  
												<input type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" name="remotelevel" id="remotelevel" maxlength="1" size="2"  value="" /> (Level: 1 ~ 7)
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">관리자 로그 정보</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="adminlog" id="adminlog" value="1" />활성
														</td>
														<td>
															<input type="radio" name="adminlog" id="adminlog" value="0" />비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr style="display:none">
								<td>
									<input name="redirect_url" type="text" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_url" value="/new/AdminFolder/3_7_5_log_set.asp" />
								<td>
							</tr>
							<tr>
								<td class="PD6">
									<input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" OnClick="return CheckValidData()" />
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			</form>			
		</td>
	</tr>
</table>
</body>
</html>
