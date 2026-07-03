<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.ui-btn-up-a {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #333;
	text-shadow: 0 1px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#dedede),to(#bebebe));
	background-image: -webkit-linear-gradient(#dedede,#bebebe);
	background-image: -moz-linear-gradient(#dedede,#bebebe);
	background-image: -ms-linear-gradient(#dedede,#bebebe);
	background-image: -o-linear-gradient(#dedede,#bebebe);
	background-image: linear-gradient(#dedede,#bebebe);
}



.ui-btn-active-a{
	border:1px solid #bbb;
	background:#bebebe;
	font-weight:bold;
	color:#333;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#bebebe),to(#9e9e9e));
	background-image:-webkit-linear-gradient(#bebebe,#9e9e9e);
	background-image:-moz-linear-gradient(#bebebe,#9e9e9e);
	background-image:-ms-linear-gradient(#bebebe,#9e9e9e);
	background-image:-o-linear-gradient(#bebebe,#9e9e9e);
	background-image:linear-gradient(#bebebe,#9e9e9e);
	font-family:Helvetica,Arial,sans-serif
}


.ui-btn-active-c{
	border:1px solid #bbb;
	background:#fff;
	font-weight:bold;
	color:#fff;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
	background-image:-webkit-linear-gradient(#f16045,#ec2427);
	background-image:-moz-linear-gradient(#f16045,#ec2427);
	background-image:-ms-linear-gradient(#f16045,#ec2427);
	background-image:-o-linear-gradient(#f16045,#ec2427);
	background-image:linear-gradient(#f16045,#ec2427);
	font-family:Helvetica,Arial,sans-serif
}
</style>

<script language="javascript" type="text/javascript">

function remove_auth_cache() {
	if($.browser.msie) { 
		document.execCommand("ClearAuthenticationCache");
	}else{
		try {
			xml = new XMLHttpRequest();
			xml.open("GET", "PAGE FROM REALM TO LOGOUT", true, "", "logout"); 
			xml.send("");
			xml.abort();
		} catch(e) { return; }
	}
}

function logoff(){
	remove_auth_cache();
	document.form_alg.action = "/goform/mcr_KTlogOut";
	document.form_alg.submit();
}

function initValue(){

	var nftp, msn, batnet,p2p,ipsec,pptp;

	nftp = '<% mcr_getCfgString("NatAlgCfgParam_nftpEnable"); %>';         
	msn = '<% mcr_getCfgString("NatAlgCfgParam_messenger"); %>';         
	batnet = '<% mcr_getCfgString("NatAlgCfgParam_battlenet"); %>';         
	p2p = '<% mcr_getCfgString("NatAlgCfgParam_p2p"); %>';         
	ipsec = '<% mcr_getCfgString("NatAlgCfgParam_ipsec"); %>';         
	pptp = '<% mcr_getCfgString("NatAlgCfgParam_pptp"); %>';         

	setnStdFtp(nftp);
	setMsn(msn);
	setBattleNet(batnet);
	setP2p(p2p);
	setIpSec(ipsec);
	setpptp(pptp);
}

function setpptp(pptp){
	switch(pptp){
		case '0':
			mcr_clickradio_pptp('0');
			$("input[id='m_nPptp1']").attr("checked", true).checkboxradio("refresh");
			$("#nPptp").val("0");
			break;
		case '1':
			mcr_clickradio_pptp('1');
			$("input[id='m_nPptp']").attr("checked", true).checkboxradio("refresh");
			$("#nPptp").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_pptp(val){
	$('label[for=m_nPptp]').removeClass('ui-btn-active');
	$('label[for=m_nPptp1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nPptp1]').addClass('ui-btn-active-c');
			$('label[for=m_nPptp]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nPptp]').addClass('ui-btn-active-c');
			$('label[for=m_nPptp1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setIpSec(IpSec){
	switch(IpSec){
		case '0':
			mcr_clickradio_IpSec('0');
			$("input[id='m_nIpSec1']").attr("checked", true).checkboxradio("refresh");
			$("#nIpSec").val("0");
			break;
		case '1':
			mcr_clickradio_IpSec('1');
			$("input[id='m_nIpSec']").attr("checked", true).checkboxradio("refresh");
			$("#nIpSec").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_IpSec(val){
	$('label[for=m_nIpSec]').removeClass('ui-btn-active');
	$('label[for=m_nIpSec1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nIpSec1]').addClass('ui-btn-active-c');
			$('label[for=m_nIpSec]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nIpSec]').addClass('ui-btn-active-c');
			$('label[for=m_nIpSec1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setP2p(P2p){
	switch(P2p){
		case '0':
			mcr_clickradio_P2p('0');
			$("input[id='m_nP2p1']").attr("checked", true).checkboxradio("refresh");
			$("#nP2p").val("0");
			break;
		case '1':
			mcr_clickradio_P2p('1');
			$("input[id='m_nP2p']").attr("checked", true).checkboxradio("refresh");
			$("#nP2p").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_P2p(val){
	$('label[for=m_nP2p]').removeClass('ui-btn-active');
	$('label[for=m_nP2p1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nP2p1]').addClass('ui-btn-active-c');
			$('label[for=m_nP2p]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nP2p]').addClass('ui-btn-active-c');
			$('label[for=m_nP2p1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setBattleNet(BattleNet){
	switch(BattleNet){
		case '0':
			mcr_clickradio_BattleNet('0');
			$("input[id='m_nBattleNet1']").attr("checked", true).checkboxradio("refresh");
			$("#nBattleNet").val("0");
			break;
		case '1':
			mcr_clickradio_BattleNet('1');
			$("input[id='m_nBattleNet']").attr("checked", true).checkboxradio("refresh");
			$("#nBattleNet").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_BattleNet(val){
	$('label[for=m_nBattleNet]').removeClass('ui-btn-active');
	$('label[for=m_nBattleNet1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nBattleNet1]').addClass('ui-btn-active-c');
			$('label[for=m_nBattleNet]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nBattleNet]').addClass('ui-btn-active-c');
			$('label[for=m_nBattleNet1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setMsn(Msn){
	switch(Msn){
		case '0':
			mcr_clickradio_Msn('0');
			$("input[id='m_nMsn1']").attr("checked", true).checkboxradio("refresh");
			$("#nMsn").val("0");
			break;
		case '1':
			mcr_clickradio_Msn('1');
			$("input[id='m_nMsn']").attr("checked", true).checkboxradio("refresh");
			$("#nMsn").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_Msn(val){
	$('label[for=m_nMsn]').removeClass('ui-btn-active');
	$('label[for=m_nMsn1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nMsn1]').addClass('ui-btn-active-c');
			$('label[for=m_nMsn]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nMsn]').addClass('ui-btn-active-c');
			$('label[for=m_nMsn1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setnStdFtp(nFtp){
	switch(nFtp){
		case '0':
			mcr_clickradio_nFtp('0');
			$("input[id='m_nStdFtp1']").attr("checked", true).checkboxradio("refresh");
			$("#tr_1").hide();
			$("#nStdFtp").val("0");
			break;
		case '1':
			mcr_clickradio_nFtp('1');
			$("input[id='m_nStdFtp']").attr("checked", true).checkboxradio("refresh");
			$("#tr_1").show();
			$("#nStdFtp").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_nFtp(val){
	$('label[for=m_nStdFtp]').removeClass('ui-btn-active');
	$('label[for=m_nStdFtp1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_nStdFtp1]').addClass('ui-btn-active-c');
			$('label[for=m_nStdFtp]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_nStdFtp]').addClass('ui-btn-active-c');
			$('label[for=m_nStdFtp1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
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

function CheckValue(){
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

	if (opmode == "0"){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}

	if($("#nStdFtp").val() == 1) {
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

function form_act(url){
	if(!CheckValue())
		return false;

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",5);
	form_alg.action = url;
	form_alg.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form_alg" data-ajax="false">

<input type="hidden" name="nStdFtp" id="nStdFtp" value="">
<input type="hidden" name="nMsn" id="nMsn" value="">
<input type="hidden" name="nBattleNet" id="nBattleNet" value="">
<input type="hidden" name="nP2p" id="nP2p" value="">
<input type="hidden" name="nIpSec" id="nIpSec" value="">
<input type="hidden" name="nPptp" id="nPptp" value="">

<input type="hidden" name="SETALG" value="/new/mobile_03_4_3_alg_set.asp">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					ALG 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>

	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">FTP(비정규 포트)</td>
							<td colspan="2">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nStdFtp">　활성　</label>
									<input type="radio" name="m_nStdFtp" id="m_nStdFtp" value="1" onclick="setnStdFtp(this.value)">
									<label for="m_nStdFtp1">　비활성　</label>
									<input type="radio" name="m_nStdFtp" id="m_nStdFtp1" value="0" onclick="setnStdFtp(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="tr_1" style="display:none">
							<td>
								<input name="nFtpPort0" type="text" id="nFtpPort0" maxlength="5" size="7" value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort0"); %>">
							</td>
							<td>
								<input name="nFtpPort1" type="text" id="nFtpPort1" maxlength="5" size="7" value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort1"); %>">
							</td>
							<td>
								<input name="nFtpPort2" type="text" id="nFtpPort2" maxlength="5" size="7" value="<% mcr_getCfgString("NatAlgCfgParam_nFtpPort2"); %>">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">메신저(MSN,NateON)</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nMsn">　활성　</label>
									<input type="radio" name="m_nMsn" id="m_nMsn" value="1" onclick="setMsn(this.value)">
									<label for="m_nMsn1">　비활성　</label>
									<input type="radio" name="m_nMsn" id="m_nMsn1" value="0" onclick="setMsn(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">게임(Battle Net)</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nBattleNet">　활성　</label>
									<input type="radio" name="m_nBattleNet" id="m_nBattleNet" value="1" onclick="setBattleNet(this.value)">
									<label for="m_nBattleNet1">　비활성　</label>
									<input type="radio" name="m_nBattleNet" id="m_nBattleNet1" value="0" onclick="setBattleNet(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">P2P(e-Donkey)</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nP2p">　활성　</label>
									<input type="radio" name="m_nP2p" id="m_nP2p" value="1" onclick="setP2p(this.value)">
									<label for="m_nP2p1">　비활성　</label>
									<input type="radio" name="m_nP2p" id="m_nP2p1" value="0" onclick="setP2p(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IPSec</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nIpSec">　활성　</label>
									<input type="radio" name="m_nIpSec" id="m_nIpSec" value="1" onclick="setIpSec(this.value)">
									<label for="m_nIpSec1">　비활성　</label>
									<input type="radio" name="m_nIpSec" id="m_nIpSec1" value="0" onclick="setIpSec(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">PPTP</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_nPptp">　활성　</label>
									<input type="radio" name="m_nPptp" id="m_nPptp" value="1" onclick="setpptp(this.value)">
									<label for="m_nPptp1">　비활성　</label>
									<input type="radio" name="m_nPptp" id="m_nPptp1" value="0" onclick="setpptp(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setAlg_New')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
