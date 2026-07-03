<html>
<head>
<%include('new/metatag.asp');%>
<title>QOS 트래픽 제한설정</title>
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

var beforId = "menu05";

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

function isAllNum(str)
{
	for (var i=0; i<str.length; i++) {
		if (str.charAt(i) >= '0' && str.charAt(i) <= '9')
			continue;
		return 0;
	}
	return 1;
}

function checkVal( field ) {

	if (field.value == "") {
		alert("입력오류입니다.[0-9] 숫자를 입력해 주세요");
		field.focus();
		return false;
	}

	if (isAllNum(field.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력해 주세요");
		field.focus();
		return false;
	}

	var aVal = parseInt(field.value);
	if( aVal < 1 || aVal > 1000) {
		alert("입력오류입니다. [1-1000] 범위값을 입력해야 합니다.");
		field.focus();
		return false;
	}
	return true;
}

function CheckValue() {
	if((!checkVal(document.form_rate.inrl_0 )) ||
			(!checkVal(document.form_rate.inrl_1 )) ||
			(!checkVal(document.form_rate.inrl_2 )) ||
			(!checkVal(document.form_rate.inrl_3 )) ||
			(!checkVal(document.form_rate.inrl_4 )) ||
			(!checkVal(document.form_rate.outrl_0 )) ||
			(!checkVal(document.form_rate.outrl_1 )) ||
			(!checkVal(document.form_rate.outrl_2 )) ||
			(!checkVal(document.form_rate.outrl_3 )) ||
			(!checkVal(document.form_rate.outrl_4 ))) {
		return false;
	}
	return true;
}

function form_act(url) {
	if(url == "/goform/mcr_setRateLimit_New") {
		if(!CheckValue())
			return false;
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	form_rate.action = url;
	form_rate.submit();
	return false;
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

function initValue() {
	$("#menu05").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	parent.mcrProgress.stopProgress();
	changeTable();
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
<form name="form_rate">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETRATE value="/new/AdminFolder/3_4_6_ratelimit_set.asp" />
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">트래픽 제한 설정</td>
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
														<td class="BG1">포트이름</td>
														<td class="BG1">입력 (Mbps)</td>
														<td class="BG1">출력 (Mbps)</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN1</td>
														<td class="BG2-3">
															<input name="inrl_1" type="text" onmouseover="unlock();" onmouseout="lock();" id="inrl_1" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam1_IngressRate");%>" style="width:100%">
														</td>
														<td class="BG2-3">
															<input name="outrl_1" type="text" onmouseover="unlock();" onmouseout="lock();" id="outrl_1" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam1_EgressRate");%>" style="width:100%">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN2</td>
														<td class="BG2-3">
															<input name="inrl_2" type="text" onmouseover="unlock();" onmouseout="lock();" id="inrl_2" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam2_IngressRate");%>" style="width:100%">
														</td>
														<td class="BG2-3">
															<input name="outrl_2" type="text" onmouseover="unlock();" onmouseout="lock();" id="outrl_2" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam2_EgressRate");%>" style="width:100%">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN3</td>
														<td class="BG2-3">
															<input name="inrl_3" type="text" onmouseover="unlock();" onmouseout="lock();" id="inrl_3" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam3_IngressRate");%>" style="width:100%">
														</td>
														<td class="BG2-3">
															<input name="outrl_3" type="text" onmouseover="unlock();" onmouseout="lock();" id="outrl_3" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam3_EgressRate");%>" style="width:100%">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN4</td>
														<td class="BG2-3">
															<input name="inrl_4" type="text" onmouseover="unlock();" onmouseout="lock();" id="inrl_4" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam4_IngressRate");%>" style="width:100%">
														</td>
														<td class="BG2-3">
															<input name="outrl_4" type="text" onmouseover="unlock();" onmouseout="lock();" id="outrl_4" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam4_EgressRate");%>" style="width:100%">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">WAN</td>
														<td class="BG2-3">
															<input name="inrl_0" type="text" onmouseover="unlock();" onmouseout="lock();" id="inrl_0" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam0_IngressRate");%>" style="width:100%">
														</td>
														<td class="BG2-3">
															<input name="outrl_0" type="text" onmouseover="unlock();" onmouseout="lock();" id="outrl_0" maxlength="5" value="<% mcr_getCfgString("QosEtcCfgParam0_EgressRate");%>" style="width:100%">
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setRateLimit_New'); return false;"/>
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
