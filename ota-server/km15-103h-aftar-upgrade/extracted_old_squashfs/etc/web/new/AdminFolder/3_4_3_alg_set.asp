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

var beforId = "menu02";

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

function DuplPortCheck(field, field1)
{
	if((atoi(field.value, 1) != 0)  && (atoi(field1.value, 1) != 0)) {
		if(atoi(field.value, 1) == atoi(field1.value, 1)) {
			alert("포트를 중복으로 입력하실 수 없습니다.");
			field1.value = field1.defaultValue;
			field1.focus();
			return false;
		}
	}

	return true;
}

function CheckValue()
{
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

	if (opmode == "0"){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}

	if(form_alg.nStdFtp[0].checked) {
		if (!checkPort(document.form_alg.nFtpPort0,true))
			return false;
		if (!checkPort(document.form_alg.nFtpPort1,true))
			return false;
		if (!checkPort(document.form_alg.nFtpPort2,true))
			return false;

		if (!DuplPortCheck(document.form_alg.nFtpPort0, document.form_alg.nFtpPort1))
			return false;
		
		if (!DuplPortCheck(document.form_alg.nFtpPort1, document.form_alg.nFtpPort2))
			return false;

		if (!DuplPortCheck(document.form_alg.nFtpPort0, document.form_alg.nFtpPort2))
			return false;
	}
	return true;
}

function form_act(url) {
	if(!CheckValue())
		return false;

	parent.mcrProgress.startProgressSimple("apply", 5);
	form_alg.action = url;
	form_alg.submit();
	return false;
}

function changeFtp() {
	if(form_alg.nStdFtp[0].checked) {
		$("#tr_1").show();
	} else if(form_alg.nStdFtp[1].checked) {
		$("#tr_1").hide();
	}
}

function initValue(){
	$("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	changeTable();

	var nftp, msn, batnet,p2p,ipsec,pptp;
	parent.mcrProgress.stopProgress();
	nftp = '<% mcr_getCfgString("NatAlgCfgParam_nftpEnable"); %>';         
	msn = '<% mcr_getCfgString("NatAlgCfgParam_messenger"); %>';         
	batnet = '<% mcr_getCfgString("NatAlgCfgParam_battlenet"); %>';         
	p2p = '<% mcr_getCfgString("NatAlgCfgParam_p2p"); %>';         
	ipsec = '<% mcr_getCfgString("NatAlgCfgParam_ipsec"); %>';         
	pptp = '<% mcr_getCfgString("NatAlgCfgParam_pptp"); %>';         

	initRadioByName("nStdFtp", nftp);
	initRadioByName("nMsn", msn);
	initRadioByName("nBattleNet", batnet);
	initRadioByName("nP2p", p2p);
	initRadioByName("nIpSec", ipsec);
	initRadioByName("nPptp", pptp);

	changeFtp();
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
<form method="post" class="form_layout" id="form_alg" name="form_alg">
<input type=hidden name=SETALG value="/new/AdminFolder/3_4_3_alg_set.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">ALG 설정</td>
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
											<td class="BG2" style="width:140px;">FTP(비정규 포트)</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nStdFtp" id="nStdFtp" value="1" OnClick="changeFtp()">
															활성</td>
														<td width="110">
															<input name="nStdFtp" type="radio" id="nStdFtp" value="0" OnClick="changeFtp()">
															비활성 
														</td>
														<td width="110"> </td>
													</tr>
													<tr id = "tr_1"  style="display:none">
														<td><input name="nFtpPort0" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="nFtpPort0" maxlength=5 size=7 value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort0"); %>"/></td>
														<td><input name="nFtpPort1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="nFtpPort1" maxlength=5 size=7 value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort1"); %>"/></td>
														<td><input name="nFtpPort2" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="nFtpPort2" maxlength=5 size=7 value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort2"); %>"/></td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">메신저(MSN,NateOn)</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nMsn" id="nMsn" value="1" />
															활성</td>
														<td>
															<input name="nMsn" type="radio" id="nMsn1" value="0"  />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게임(Battle Net)</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nBattleNet" id="nBattleNet" value="1" />
															활성
														</td>
														<td>
															<input name="nBattleNet" type="radio" id="nBattleNet1" value="0"  />
															비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">P2P(e-Donkey)</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nP2p" id="nP2p" value="1" />
															활성
														</td>
														<td>
															<input name="nP2p" type="radio" id="nP2p1" value="0"  />
															비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">IPSec</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nIpSec" id="nIpSec" value="1" />
															활성
														</td>
														<td>
															<input name="nIpSec" type="radio" id="nIpSec1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">PPTP</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="nPptp" id="nPptp" value="1" />
															활성
														</td>
														<td>
															<input name="nPptp" type="radio" id="nPptp1" value="0" />
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
								<td class="PD6">
									<input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply" onclick="form_act('/goform/mcr_setAlg_New'); return false;"></td>
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
