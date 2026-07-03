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
	document.form_dos.action = "/goform/mcr_KTlogOut";
	document.form_dos.submit();
}

function initValue() {

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
	var selfloopdetect = '<% mcr_getDosCfg("SelfLoopDetect_T"); %>';

	$("#tr_self").hide();
	$("#Grid_Table").hide();
	setWholeSyn(syn);
	setWholeIcmp(icmp);
	setTraceRoute(tracerte);
	setIcmpSmurf(smurf);
	setSynFlood(synflood);
	setIPSpoof(ipspoof);
	setPingOfDeath(pingd);
	setTcpUdpPortScan(portscan);
	setWArpSpoof(warpspoof);
	setWormVirus(wormvirus);
	setSelfLoopDetect(selfloopdetect);

}

function setWholeSyn(WholeSyn){
	switch(WholeSyn){
		case '0':
			mcr_clickradio_WholeSyn('0');
			$("input[id='m_WholeSyn_T1']").attr("checked", true).checkboxradio("refresh");
			$("#WholeSyn_T").val("0");
			break;
		case '1':
			mcr_clickradio_WholeSyn('1');
			$("input[id='m_WholeSyn_T']").attr("checked", true).checkboxradio("refresh");
			$("#WholeSyn_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_WholeSyn(val){
	$('label[for=m_WholeSyn_T]').removeClass('ui-btn-active');
	$('label[for=m_WholeSyn_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_WholeSyn_T1]').addClass('ui-btn-active-c');
			$('label[for=m_WholeSyn_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_WholeSyn_T]').addClass('ui-btn-active-c');
			$('label[for=m_WholeSyn_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setWholeIcmp(WholeIcmp){
	switch(WholeIcmp){
		case '0':
			mcr_clickradio_WholeIcmp('0');
			$("input[id='m_WholeIcmp_T1']").attr("checked", true).checkboxradio("refresh");
			$("#WholeIcmp_T").val("0");
			break;
		case '1':
			mcr_clickradio_WholeIcmp('1');
			$("input[id='m_WholeIcmp_T']").attr("checked", true).checkboxradio("refresh");
			$("#WholeIcmp_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_WholeIcmp(val){
	$('label[for=m_WholeIcmp_T]').removeClass('ui-btn-active');
	$('label[for=m_WholeIcmp_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_WholeIcmp_T1]').addClass('ui-btn-active-c');
			$('label[for=m_WholeIcmp_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_WholeIcmp_T]').addClass('ui-btn-active-c');
			$('label[for=m_WholeIcmp_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setTraceRoute(TraceRoute){
	switch(TraceRoute){
		case '0':
			mcr_clickradio_TraceRoute('0');
			$("input[id='m_TraceRoute_T1']").attr("checked", true).checkboxradio("refresh");
			$("#TraceRoute_T").val("0");
			break;
		case '1':
			mcr_clickradio_TraceRoute('1');
			$("input[id='m_TraceRoute_T']").attr("checked", true).checkboxradio("refresh");
			$("#TraceRoute_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_TraceRoute(val){
	$('label[for=m_TraceRoute_T]').removeClass('ui-btn-active');
	$('label[for=m_TraceRoute_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_TraceRoute_T1]').addClass('ui-btn-active-c');
			$('label[for=m_TraceRoute_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_TraceRoute_T]').addClass('ui-btn-active-c');
			$('label[for=m_TraceRoute_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setIcmpSmurf(IcmpSmurf){
	switch(IcmpSmurf){
		case '0':
			mcr_clickradio_IcmpSmurf('0');
			$("input[id='m_IcmpSmurf_T1']").attr("checked", true).checkboxradio("refresh");
			$("#IcmpSmurf_T").val("0");
			break;
		case '1':
			mcr_clickradio_IcmpSmurf('1');
			$("input[id='m_IcmpSmurf_T']").attr("checked", true).checkboxradio("refresh");
			$("#IcmpSmurf_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_IcmpSmurf(val){
	$('label[for=m_IcmpSmurf_T]').removeClass('ui-btn-active');
	$('label[for=m_IcmpSmurf_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_IcmpSmurf_T1]').addClass('ui-btn-active-c');
			$('label[for=m_IcmpSmurf_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_IcmpSmurf_T]').addClass('ui-btn-active-c');
			$('label[for=m_IcmpSmurf_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setSynFlood(SynFlood){
	switch(SynFlood){
		case '0':
			mcr_clickradio_SynFlood('0');
			$("input[id='m_SynFlood_T1']").attr("checked", true).checkboxradio("refresh");
			$("#SynFlood_T").val("0");
			break;
		case '1':
			mcr_clickradio_SynFlood('1');
			$("input[id='m_SynFlood_T']").attr("checked", true).checkboxradio("refresh");
			$("#SynFlood_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_SynFlood(val){
	$('label[for=m_SynFlood_T]').removeClass('ui-btn-active');
	$('label[for=m_SynFlood_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_SynFlood_T1]').addClass('ui-btn-active-c');
			$('label[for=m_SynFlood_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_SynFlood_T]').addClass('ui-btn-active-c');
			$('label[for=m_SynFlood_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setIPSpoof(IPSpoof){
	switch(IPSpoof){
		case '0':
			mcr_clickradio_IPSpoof('0');
			$("input[id='m_IPSpoof_T1']").attr("checked", true).checkboxradio("refresh");
			$("#IPSpoof_T").val("0");
			break;
		case '1':
			mcr_clickradio_IPSpoof('1');
			$("input[id='m_IPSpoof_T1']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_IPSpoof_T']").attr("checked", true).checkboxradio("refresh");
			$("#IPSpoof_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_IPSpoof(val){
	$('label[for=m_IPSpoof_T]').removeClass('ui-btn-active');
	$('label[for=m_IPSpoof_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_IPSpoof_T1]').addClass('ui-btn-active-c');
			$('label[for=m_IPSpoof_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_IPSpoof_T]').addClass('ui-btn-active-c');
			$('label[for=m_IPSpoof_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setPingOfDeath(PingOfDeath){
	switch(PingOfDeath){
		case '0':
			mcr_clickradio_PingOfDeath('0');
			$("input[id='m_PingOfDeath_T1']").attr("checked", true).checkboxradio("refresh");
			$("#PingOfDeath_T").val("0");
			break;
		case '1':
			mcr_clickradio_PingOfDeath('1');
			$("input[id='m_PingOfDeath_T']").attr("checked", true).checkboxradio("refresh");
			$("#PingOfDeath_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_PingOfDeath(val){
	$('label[for=m_PingOfDeath_T]').removeClass('ui-btn-active');
	$('label[for=m_PingOfDeath_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_PingOfDeath_T1]').addClass('ui-btn-active-c');
			$('label[for=m_PingOfDeath_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_PingOfDeath_T]').addClass('ui-btn-active-c');
			$('label[for=m_PingOfDeath_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setTcpUdpPortScan(TcpUdpPortScan){
	switch(TcpUdpPortScan){
		case '0':
			mcr_clickradio_TcpUdpPortScan('0');
			$("input[id='m_TcpUdpPortScan_T1']").attr("checked", true).checkboxradio("refresh");
			$("#TcpUdpPortScan_T").val("0");
			break;
		case '1':
			mcr_clickradio_TcpUdpPortScan('1');
			$("input[id='m_TcpUdpPortScan_T']").attr("checked", true).checkboxradio("refresh");
			$("#TcpUdpPortScan_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_TcpUdpPortScan(val){
	$('label[for=m_TcpUdpPortScan_T]').removeClass('ui-btn-active');
	$('label[for=m_TcpUdpPortScan_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_TcpUdpPortScan_T1]').addClass('ui-btn-active-c');
			$('label[for=m_TcpUdpPortScan_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_TcpUdpPortScan_T]').addClass('ui-btn-active-c');
			$('label[for=m_TcpUdpPortScan_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setWArpSpoof(WArpSpoof){
	switch(WArpSpoof){
		case '0':
			mcr_clickradio_WArpSpoof('0');
			$("input[id='m_WArpSpoof_T1']").attr("checked", true).checkboxradio("refresh");
			$("#WArpSpoof_T").val("0");
			break;
		case '1':
			mcr_clickradio_WArpSpoof('1');
			$("input[id='m_WArpSpoof_T']").attr("checked", true).checkboxradio("refresh");
			$("#WArpSpoof_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_WArpSpoof(val){
	$('label[for=m_WArpSpoof_T]').removeClass('ui-btn-active');
	$('label[for=m_WArpSpoof_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_WArpSpoof_T1]').addClass('ui-btn-active-c');
			$('label[for=m_WArpSpoof_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_WArpSpoof_T]').addClass('ui-btn-active-c');
			$('label[for=m_WArpSpoof_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}
function setSelfLoopDetect(SelfLoopDetect){
        switch(SelfLoopDetect){
                case '0':
                        $("input[id='m_SelfLoopDetect_T1']").attr("checked", true).checkboxradio("refresh");
                        $("#Grid_Table").hide();
                        $("#SelfLoopDetect_T").val("0");
                        mcr_clickradio_SelfLoopDetect('0');

                        break;
                case '1':
                        $("input[id='m_SelfLoopDetect_T']").attr("checked", true).checkboxradio("refresh");
                        $("#Grid_Table").show();
                        $("#SelfLoopDetect_T").val("1");
                        mcr_clickradio_SelfLoopDetect('1');
                        break;
                default:
                        break;
        }
}
function mcr_clickradio_SelfLoopDetect(val){
        $('label[for=m_SelfLoopDetect_T]').removeClass('ui-btn-active');
        $('label[for=m_SelfLoopDetect_T1]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_SelfLoopDetect_T1]').addClass('ui-btn-active-c');
                        $('label[for=m_SelfLoopDetect_T]').removeClass('ui-btn-active-c');
                        $("input[id='m_SelfLoopDetect_T1']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_SelfLoopDetect_T]').addClass('ui-btn-active-c');
                        $('label[for=m_SelfLoopDetect_T1]').removeClass('ui-btn-active-c');
                        $("input[id='m_SelfLoopDetect_T']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}

function setWormVirus(WormVirus){
	switch(WormVirus){
		case '0':
			mcr_clickradio_WormVirus('0');
			$("input[id='m_WormVirus_T1']").attr("checked", true).checkboxradio("refresh");
			$("#WormVirus_T").val("0");
			break;
		case '1':
			mcr_clickradio_WormVirus('1');
			$("input[id='m_WormVirus_T']").attr("checked", true).checkboxradio("refresh");
			$("#WormVirus_T").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_WormVirus(val){
	$('label[for=m_WormVirus_T]').removeClass('ui-btn-active');
	$('label[for=m_WormVirus_T1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_WormVirus_T1]').addClass('ui-btn-active-c');
			$('label[for=m_WormVirus_T]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_WormVirus_T]').addClass('ui-btn-active-c');
			$('label[for=m_WormVirus_T1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function form_act(url){
	if(!CheckValue())
		return false;

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply", 5);
	form_dos.action = url;
	form_dos.submit();
	return false;
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
	return true;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form_dos" data-ajax="false">

<input type="hidden" name="WholeSyn_T" id="WholeSyn_T" value="">
<input type="hidden" name="WholeIcmp_T" id="WholeIcmp_T" value="">
<input type="hidden" name="TraceRoute_T" id="TraceRoute_T" value="">
<input type="hidden" name="IcmpSmurf_T" id="IcmpSmurf_T" value="">
<input type="hidden" name="SynFlood_T" id="SynFlood_T" value="">
<input type="hidden" name="IPSpoof_T" id="IPSpoof_T" value="">
<input type="hidden" name="PingOfDeath_T" id="PingOfDeath_T" value="">
<input type="hidden" name="TcpUdpPortScan_T" id="TcpUdpPortScan_T" value="">
<input type="hidden" name="WArpSpoof_T" id="WArpSpoof_T" value="">
<input type="hidden" name="WormVirus_T" id="WormVirus_T" value="">
<input type="hidden" name="SelfLoopDetect_T" id="SelfLoopDetect_T" value="">

<input type="hidden" name="SETDOS" value="/new/mobile_03_5_1_secure_func_set.asp">

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
					보안 기능 설정
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
							<td>TCP SYN Attack</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_WholeSyn_T">　활성　</label>
									<input type="radio" name="m_WholeSyn_T" id="m_WholeSyn_T" value="1" onclick="setWholeSyn(this.value)">
									<label for="m_WholeSyn_T1">　비활성　</label>
									<input type="radio" name="m_WholeSyn_T" id="m_WholeSyn_T1" value="0" onclick="setWholeSyn(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>SYN 패킷 개수 허용</td>
							<td>INPUT</td>
							<td>
								<input name="WholeSyn_pktlmt" type="text" id="WholeSyn_pktlmt" value="<% mcr_getCfgString("DosCfgParam_WSynPktCnt"); %>">
							</td>
							<td>
								/ sec
							</td>
						</tr>
						<tr>
							<td>ICMP Flood</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_WholeIcmp_T">　활성　</label>
									<input type="radio" name="m_WholeIcmp_T" id="m_WholeIcmp_T" value="1" onclick="setWholeIcmp(this.value)">
									<label for="m_WholeIcmp_T1">　비활성　</label>
									<input type="radio" name="m_WholeIcmp_T" id="m_WholeIcmp_T1" value="0" onclick="setWholeIcmp(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>PING 패킷 개수 허용</td>
							<td>EchoRequest</td>
							<td>
								<input name="WholeIcmp_pktlmt" type="text" id="WholeIcmp_pktlmt" value="<% mcr_getCfgString("DosCfgParam_WIcmpPktCnt"); %>">
							</td>
							<td>
								/ sec
							</td>
						</tr>
						<tr>
							<td>Trace Route 응답</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_TraceRoute_T">　활성　</label>
									<input type="radio" name="m_TraceRoute_T" id="m_TraceRoute_T" value="1" onclick="setTraceRoute(this.value)">
									<label for="m_TraceRoute_T1">　비활성　</label>
									<input type="radio" name="m_TraceRoute_T" id="m_TraceRoute_T1" value="0" onclick="setTraceRoute(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>Broadcast Ping 응답</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_IcmpSmurf_T">　활성　</label>
									<input type="radio" name="m_IcmpSmurf_T" id="m_IcmpSmurf_T" value="1" onclick="setIcmpSmurf(this.value)">
									<label for="m_IcmpSmurf_T1">　비활성　</label>
									<input type="radio" name="m_IcmpSmurf_T" id="m_IcmpSmurf_T1" value="0" onclick="setIcmpSmurf(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>SYN Flooding</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_SynFlood_T">　활성　</label>
									<input type="radio" name="m_SynFlood_T" id="m_SynFlood_T" value="1" onclick="setSynFlood(this.value)">
									<label for="m_SynFlood_T1">　비활성　</label>
									<input type="radio" name="m_SynFlood_T" id="m_SynFlood_T1" value="0" onclick="setSynFlood(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>IP Spoofing</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_IPSpoof_T">　활성　</label>
									<input type="radio" name="m_IPSpoof_T" id="m_IPSpoof_T" value="1" onclick="setIPSpoof(this.value)">
									<label for="m_IPSpoof_T1">　비활성　</label>
									<input type="radio" name="m_IPSpoof_T" id="m_IPSpoof_T1" value="0" onclick="setIPSpoof(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>Ping of Death</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_PingOfDeath_T">　활성　</label>
									<input type="radio" name="m_PingOfDeath_T" id="m_PingOfDeath_T" value="1" onclick="setPingOfDeath(this.value)">
									<label for="m_PingOfDeath_T1">　비활성　</label>
									<input type="radio" name="m_PingOfDeath_T" id="m_PingOfDeath_T1" value="0" onclick="setPingOfDeath(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>TCP Port Scan</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_TcpUdpPortScan_T">　활성　</label>
									<input type="radio" name="m_TcpUdpPortScan_T" id="m_TcpUdpPortScan_T" value="1" onclick="setTcpUdpPortScan(this.value)">
									<label for="m_TcpUdpPortScan_T1">　비활성　</label>
									<input type="radio" name="m_TcpUdpPortScan_T" id="m_TcpUdpPortScan_T1" value="0" onclick="setTcpUdpPortScan(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>무선 ARP Spoofing</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_WArpSpoof_T">　활성　</label>
									<input type="radio" name="m_WArpSpoof_T" id="m_WArpSpoof_T" value="1" onclick="setWArpSpoof(this.value)">
									<label for="m_WArpSpoof_T1">　비활성　</label>
									<input type="radio" name="m_WArpSpoof_T" id="m_WArpSpoof_T1" value="0" onclick="setWArpSpoof(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>웜 바이러스 차단</td>
							<td colspan="3">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_WormVirus_T">　활성　</label>
									<input type="radio" name="m_WormVirus_T" id="m_WormVirus_T" value="1" onclick="setWormVirus(this.value)">
									<label for="m_WormVirus_T1">　비활성　</label>
									<input type="radio" name="m_WormVirus_T" id="m_WormVirus_T1" value="0" onclick="setWormVirus(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="tr_self">
                                                        <td>SelfLoopDetect</td>
                                                        <td colspan="3">
                                                                <fieldset data-role="controlgroup" data-type="horizontal">
                                                                        <label for="m_SelfLoopDetect_T">　활성　</label>
                                                                        <input type="radio" name="m_SelfLoopDetect_T" id="m_SelfLoopDetect_T" value="1" onclick="setSelfLoopDetect(this.value)">
                                                                        <label for="m_SelfLoopDetect_T1">　비활성　</label>
                                                                        <input type="radio" name="m_SelfLoopDetect_T" id="m_SelfLoopDetect_T1" value="0" onclick="setSelfLoopDetect(this.value)">
                                                                </fieldset>
                                                        </td>
                                                </tr>
                                                <tr id="Grid_Table" style="display:none;">
							<td></td>
                                                        <td colspan="3">
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
                                                                        <tr>
                                                                                <td width="10%" align="center" style="word-break:break-all"><p>Port</p></td>
                                                                                <td width="10%" align="center" style="word-break:break-all"><p>Block</p></td>
                                                                        </tr>
                                                                        <script language="JavaScript" type="text/javascript">
                                                                                var i;
                                                                                var entries = new Array();
                                                                                var all_str = "<% mcr_get_SelfLoopDetectStatus(); %>";

                                                                                entries = all_str.split(":");
                                                                                if(all_str.length >0) {
                                                                                        for(i=0; i<entries.length; i++) {
                                                                                                document.write("<tr>");
                                                                                                document.write("<td class=BG2-2 align=center>");
                                                                                                document.write("LAN");
                                                                                                document.write(entries[i]);
                                                                                                document.write("</td>");
                                                                                                document.write("<td class=BG2-2 align=center>");
                                                                                                document.write("blocked");
                                                                                                document.write("</td>");
                                                                                                document.write("</tr>\n");
                                                                                        }
                                                                                }
                                                                                else{
                                                                                        document.write("<tr>");
                                                                                        document.write("<td colspan=2 id=vPortBlkNone align=center> 차단된 Port 리스트가 없습니다. </td>");
                                                                                        document.write("<tr>");
                                                                                }
                                                                        </script>
								</table>
                                                        </td>
                                                </tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setDos')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#ninthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
