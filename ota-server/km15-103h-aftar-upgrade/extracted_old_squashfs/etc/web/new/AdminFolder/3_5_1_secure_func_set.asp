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
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function CheckValue() {
	if (isAllNum(document.form_dos.WholeSyn_pktlmt.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력하세요.");
		return false;
	}
	if (!checkRange(document.form_dos.WholeSyn_pktlmt.value, 1, 0, 2000)) {
		alert("입력오류입니다.입력 값이 범위를 초과했습니다.(1~2000)");
		return false;
	}
	if (isAllNum(document.form_dos.WholeIcmp_pktlmt.value) == 0) {
		alert("입력오류입니다.[0-9] 숫자를 입력하세요.");
		return false;
	}
	if (!checkRange(document.form_dos.WholeIcmp_pktlmt.value, 1, 0, 2000)) {
		alert("입력오류입니다.입력 값이 범위를 초과했습니다.(1~2000)");
		return false;
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	return true;
}

function initValue() {
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	parent.mcrProgress.stopProgress();
	var syn = '<% mcr_getDosCfg("WholeSyn_T"); %>';
	var icmp = '<% mcr_getDosCfg("WholeIcmp_T"); %>';
	var tracerte = '<% mcr_getDosCfg("TraceRoute_T"); %>';
	var smurf = '<% mcr_getDosCfg("IcmpSmurf_T"); %>';
	var synflood = '<% mcr_getDosCfg("SynFlood_T"); %>';
	var ipspoof = '<% mcr_getDosCfg("IPSpoof_T"); %>';
	var pingd = '<% mcr_getDosCfg("PingOfDeath_T"); %>';
	var portscan = '<% mcr_getDosCfg("TcpUdpPortScan_T"); %>';
	var warpspoof = '<% mcr_getDosCfg("WArpSpoof_T"); %>';
	var wormvirus = '<% mcr_getDosCfg("WormVirus_T"); %>';

	initRadioByName("WholeSyn_T", syn);
	initRadioByName("WholeIcmp_T", icmp);
	initRadioByName("TraceRoute_T", tracerte);
	initRadioByName("IcmpSmurf_T", smurf);
	initRadioByName("SynFlood_T", synflood);
	initRadioByName("IPSpoof_T", ipspoof);
	initRadioByName("PingOfDeath_T", pingd);
	initRadioByName("TcpUdpPortScan_T", portscan);
	initRadioByName("WArpSpoof_T", warpspoof);
	initRadioByName("WormVirus_T", wormvirus);

	changeTableAdmin();
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
<form name="form_dos" id="form_dos" action="/goform/mcr_setDos" onSubmit="return CheckValue()">
<input type=hidden name=SETDOS value="/new/AdminFolder/3_5_1_secure_func_set.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_5_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">보안 기능 설정</td>
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
											<td class="BG2" style="width:140px;">TCP SYN Attack</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="WholeSyn_T" id="WholeSyn_T" value="1" />
															활성
														</td>
														<td>
															<input name="WholeSyn_T" type="radio" id="WholeSyn_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">SYN 패킷 개수 허용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110"><label> INPUT </label></td>
														<td>
															<input name="WholeSyn_pktlmt" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="WholeSyn_pktlmt" value="<% mcr_getCfgString("DosCfgParam_WSynPktCnt"); %>"/> 
															/ sec
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">
												<p>ICMP Flood </p>
											</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="WholeIcmp_T" type="radio" id="WholeIcmp_T" value="1" />
															활성
														</td>
														<td>
															<input name="WholeIcmp_T" type="radio" id="WholeIcmp_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">PING 패킷 개수 허용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110"><label> EchoRequest</label></td>
														<td>
															<input name="WholeIcmp_pktlmt" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="WholeIcmp_pktlmt" value="<% mcr_getCfgString("DosCfgParam_WIcmpPktCnt"); %>"/>
															/ sec
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">
												<p>Trace Route 응답</p>
											</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="TraceRoute_T" type="radio" id="TraceRoute_T" value="1" />
															활성
														</td>
														<td>
															<input name="TraceRoute_T" type="radio" id="TraceRoute_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">
												<p>Broadcast Ping 응답</p>
											</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="IcmpSmurf_T" type="radio" id="IcmpSmurf_T" value="1" />
															활성
														</td>
														<td>
															<input name="IcmpSmurf_T" type="radio" id="IcmpSmurf_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">SYN Flooding</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="SynFlood_T" id="SynFlood_T" value="1" />
															활성
														</td>
														<td>	
															<input name="SynFlood_T" type="radio" id="SynFlood_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">IP Spoofing</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="IPSpoof_T" id="IPSpoof_T" value="1" />
															활성
														</td>
														<td>
															<input name="IPSpoof_T" type="radio" id="IPSpoof_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">Ping of Death</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="PingOfDeath_T" id="PingOfDeath_T" value="1" />
															활성
														</td>
														<td>
															<input name="PingOfDeath_T" type="radio" id="PingOfDeath_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">TCP Port Scan</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="TcpUdpPortScan_T" id="TcpUdpPortScan_T" value="1" />
															활성
														</td>
														<td>
															<input name="TcpUdpPortScan_T" type="radio" id="TcpUdpPortScan_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">무선 ARP Spoofing</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="WArpSpoof_T" id="WArpSpoof_T" value="1" />
															활성
														</td>
														<td>
															<input name="WArpSpoof_T" type="radio" id="WArpSpoof_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">웜 바이러스 차단</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="WormVirus_T" id="WormVirus_T" value="1" />
															활성
														</td>
														<td>
															<input name="WormVirus_T" type="radio" id="WormVirus_T1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply"onclick="form_act('/goform/mcr_setDos')"/></td>
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
