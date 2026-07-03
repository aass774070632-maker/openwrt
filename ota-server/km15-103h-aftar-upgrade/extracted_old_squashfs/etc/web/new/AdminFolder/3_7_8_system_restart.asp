<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템 재시동</title>
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

var beforId = "menu07";

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

function changeTableAdmin() 
{
	var nasr;
	nasr = '<% mcr_getCfgString("X_KT_PeriodicReset_Enable"); %>';

	selectMenu3rd();

	parent.mcrProgress.stopProgress();

	initRadioByName("Enable", nasr);
	changeAsr();

	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function selectMenu3rd(){
		$("#menu07").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function CheckValue()
{
	if(form_asr.Enable[0].checked) {
		if(form_asr.Interval.value ==""){
			alert("재시동 주기를 입력해 주세요");
			return false;
		}
		else {
			if (!checkRange(document.form_asr.Interval.value, 1, 0, 1000)) {
				alert("재시동 주기 값을 변경해 주세요");
				return false;
			}
		}

		if(form_asr.StartTime.value ==""){
			alert("재시동 시작 시간을 입력해 주세요");
			return false;
		}
		else {
			if (!checkRange(document.form_asr.StartTime.value, 1, 0, 24)) {
				alert("재시동 시작 시간을  변경해 주세요");
				return false;
			}
		}

		if(form_asr.UserExist.value ==""){
			alert("사용자 확인을 입력해 주세요");
			return false;
		}
		else {
			if (!checkRange(document.form_asr.UserExist.value, 1, 0, 1)) {
				alert("사용자 확인값을  변경해 주세요");
				return false;
			}
		}
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	return true;
}

function changeAsr() {
	if(form_asr.Enable[0].checked) {
		$("#AsrInterval").show();
		$("#AsrStartTime").show();
		$("#AsrDuringTime").show();
		$("#AsrUserExist").show();
		$("#AsrUniCast").show();
		$("#AsrSetTopUniCast").show();
		$("#AsrSetTopIgmp").show();
		$("#AsrWlanPacket").show();
	} else {
		$("#AsrInterval").hide();
		$("#AsrStartTime").hide();
		$("#AsrDuringTime").hide();
		$("#AsrUserExist").hide();
		$("#AsrUniCast").hide();
		$("#AsrSetTopUniCast").hide();
		$("#AsrSetTopIgmp").hide();
		$("#AsrWlanPacket").hide();
	}
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
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<!-- menu 3rd -->
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
			<!-- menu 3rd -->
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="670" border="0" cellspacing="0" cellpadding="10">
				<tr style="height:100px">
					<td valign="top" >
						<form method="post" name="sysRestart" action="/goform/mcr_setRestart">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">시스템 재시동</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr style="display:none">
								<td>
									<input name="redirect_url" type="text" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_url" value="/new/AdminFolder/3_7_8_system_restart_process.asp" />
								<td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25">
												<input name = "Apply" type="image" src="/images/BTN/BTN_21.gif?Sp2" width="99" height="24" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				<tr id="AutoReset">
					<td valign="top">
						<form method="post" name="form_asr" action="/goform/mcr_setAsrConfig">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr> <td class="font5">자동 재시동(이 기능은 AP 사용 중에는 동작하지 않습니다.)</td> </tr>
							<tr> <td class="PD4"></td> </tr>
							<tr> <td class="PD5"></td> </tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">주기적 재시동</td>
											<td class="BG2-2">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="Enable" id="Enable" value="1" OnClick="changeAsr()">
															활성
														</td>
														<td width="110">
															<input name="Enable" type="radio" id="Enable" value="0" OnClick="changeAsr()">
															비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id = "AsrInterval" style="display:none">
											<td height ="25" class="BG2" style="width:170px;">재시동 주기</td>
											<td class="BG2-2">
												<input name="Interval" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="Interval"  size=10 value="<% mcr_getCfgString("X_KT_PeriodicReset_IntervalTime"); %>"/>시간마다
											</td>
										</tr>
										<tr id = "AsrStartTime" style="display:none">
											<td class="BG2" style="width:170px;">재시동 시작 시간</td>
											<td class="BG2-2">
												<input name="StartTime" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="StartTime" maxlength=2 size=7 value="<% mcr_getCfgString("X_KT_PeriodicReset_StartTime"); %>"/>시
											</td>
										</tr>
										<tr id = "AsrDuringTime" style="display:none">
											<td class="BG2" style="width:170px;">재시동 시도 시간</td>
											<td class="BG2-2">
												<input name="DuringTime" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="DuringTime" maxlength=2 size=7 value="<% mcr_getCfgString("X_KT_PeriodicReset_DuringTime"); %>"/>시간마다
											</td>
										</tr>
										<tr id = "AsrUserExist" style="display:none">
											<td class="BG2" style="width:170px;">사용자 확인</td>
											<td class="BG2-2">
												<input name="UserExist" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="UserExist" maxlength=1 size=7 value="<% mcr_getCfgString("X_KT_PeriodicReset_CpeStatusCondition"); %>"/>
											</td>
										</tr>
										<tr id = "AsrUniCast" style="display:none">
											<td class="BG2" style="width:170px;">유선 UNICAST 사용 기준</td>
											<td class="BG2-2">
												<input name="UniCast" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="UniCast" size=10 value="<% mcr_getCfgString("X_KT_PeriodicReset_Unicast_MAX"); %>"/>
											</td>
										</tr>
										<tr id = "AsrSetTopUniCast" style="display:none">
											<td class="BG2" style="width:170px;">SETTOP UNICAST  사용 기준</td>
											<td class="BG2-2">
												<input name="SetTopUniCast" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="SetTopUniCast"  size=10 value="<% mcr_getCfgString("X_KT_PeriodicReset_Settop_MAX"); %>"/>
											</td>
										</tr>
										<tr id = "AsrSetTopIgmp" style="display:none">
											<td class="BG2" style="width:170px;">SETTOP IGMP 사용 기준</td>
											<td class="BG2-2">
												<input name="SetTopIgmp" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="SetTopIgmp" size=10  value="<% mcr_getCfgString("X_KT_PeriodicReset_Igmp_Count"); %>"/>
											</td>
										</tr>
										<tr id = "AsrWlanPacket" style="display:none">
											<td class="BG2" style="width:170px;">무선 PACKET 사용 기준</td>
											<td class="BG2-2">
												<input name="WlanPacket" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="WlanPacket" size=10 value="<% mcr_getCfgString("X_KT_PeriodicReset_Wireless_MAX"); %>"/>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onClick="return CheckValue()" /></td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
