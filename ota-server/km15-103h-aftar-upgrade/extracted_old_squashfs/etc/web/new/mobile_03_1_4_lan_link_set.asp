<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>

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

var opmode = <% mcr_getCfgString("SysOperMode_OperMode"); %>;
var wifirly = <% mcr_getCfgString("SysConfDb_WiFi_Relay"); %>;
var netsel = <% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>;  
var sohoZoneMode = <% mcr_getCfgString("SysOperMode_KTSOHOZoneMode"); %>;

function CheckValue() {
	if (opmode == 0){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}
	if (!checkIpAddr(document.form_lan.lanIp, false))
		return false;

	if (!checkIpAddr(document.form_lan.lanNetmask, true))
		return false;

	if ($("#lanDhcpType").val() == "1") {
		if (!checkIpAddr(document.form_lan.dhcpStart, false))
			return false;
		if (!checkIpAddr(document.form_lan.dhcpEnd, false))
			return false;

		if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpStart.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpStart.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpStart.value, 3)) ) {
			alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
			return false;
		}
		if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpEnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpEnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpEnd.value, 3)) ) {
			alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
			return false;
		}

		if( (atoi(document.form_lan.lanIp.value,4) >= atoi(document.form_lan.dhcpStart.value, 4)) && (atoi(document.form_lan.lanIp.value,4) <= atoi(document.form_lan.dhcpEnd.value, 4)) ) {
			alert("LAN IP주소가 포함되지 않도록 입력해 주세요");
			return false;
		}

		if( (atoi(document.form_lan.dhcpStart.value, 1) > atoi(document.form_lan.dhcpEnd.value, 1))
				|| (atoi(document.form_lan.dhcpStart.value, 2) > atoi(document.form_lan.dhcpEnd.value, 2))
				|| (atoi(document.form_lan.dhcpStart.value, 3) > atoi(document.form_lan.dhcpEnd.value, 3))
				|| (atoi(document.form_lan.dhcpStart.value, 4) > atoi(document.form_lan.dhcpEnd.value, 4))
				|| (atoi(document.form_lan.dhcpStart.value, 4) < 1)
				|| (atoi(document.form_lan.dhcpEnd.value, 4) < 1)
				|| (atoi(document.form_lan.dhcpStart.value, 4) > 127)
				|| (atoi(document.form_lan.dhcpEnd.value, 4) > 127) ) {
			alert("DHCP 코넷 IP 범위 입력 오류입니다.");
			return false;
		}
		if (opmode == 1 && netsel == 0) {
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpStartSnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpStartSnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpStartSnd.value, 3)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpEndSnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpEndSnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpEndSnd.value, 3)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}

			if( (atoi(document.form_lan.lanIp.value,4) >= atoi(document.form_lan.dhcpStartSnd.value, 4)) && (atoi(document.form_lan.lanIp.value,4) <= atoi(document.form_lan.dhcpEndSnd.value, 4)) ) {
				alert("LAN IP주소가 포함되지 않도록 입력해 주세요");
				return false;
			}

			if( (atoi(document.form_lan.dhcpStartSnd.value, 1) > atoi(document.form_lan.dhcpEndSnd.value, 1))
					|| (atoi(document.form_lan.dhcpStartSnd.value, 2) > atoi(document.form_lan.dhcpEndSnd.value, 2))
					|| (atoi(document.form_lan.dhcpStartSnd.value, 3) > atoi(document.form_lan.dhcpEndSnd.value, 3))
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) > atoi(document.form_lan.dhcpEndSnd.value, 4))
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) != 128)
					|| (atoi(document.form_lan.dhcpEndSnd.value, 4) < 131)
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) > 252)
					|| (atoi(document.form_lan.dhcpEndSnd.value, 4) > 252) ) {
				alert("DHCP 프리미엄 IP 범위 입력 오류입니다.");
				return false;
			}
		}

		if(wifirly == 1 && sohoZoneMode != 0) {
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpStartThrd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpStartThrd.value, 2)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpEndThrd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpEndThrd.value, 2)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}
			if( (atoi(document.form_lan.dhcpStartThrd.value, 1) > atoi(document.form_lan.dhcpEndThrd.value, 1))
					|| (atoi(document.form_lan.dhcpStartThrd.value, 2) > atoi(document.form_lan.dhcpEndThrd.value, 2))
					|| (atoi(document.form_lan.dhcpStartThrd.value, 3) > atoi(document.form_lan.dhcpEndThrd.value, 3))
					|| (atoi(document.form_lan.dhcpStartThrd.value, 4) > atoi(document.form_lan.dhcpEndThrd.value, 4))
					|| (atoi(document.form_lan.dhcpStartThrd.value, 4) < 1)
					|| (atoi(document.form_lan.dhcpEndThrd.value, 4) > 252) ) {
				alert("DHCP Relay IP 범위 입력 오류입니다.");
				return false;
			}
		}
	}
	return true;
}

function staticlease_checkIpAddr(field, ismask) {
	if (isAllNum(field.value) == 0) {
		field.value = field.defaultValue;
		field.focus();
		return false;
	}

	if (ismask) {
		if ((!checkRange(field.value, 1, 0, 256)) ||
				(!checkRange(field.value, 2, 0, 256)) ||
				(!checkRange(field.value, 3, 0, 256)) ||
				(!checkRange(field.value, 4, 0, 256)))
		{
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	else {
		if ((!checkRange(field.value, 1, 0, 255)) ||
				(!checkRange(field.value, 2, 0, 255)) ||
				(!checkRange(field.value, 3, 0, 255)) ||
				(!checkRange(field.value, 4, 1, 254)))
		{
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	return true;
}

function ip_alloc_check()
{
	var ip3 = atoi(document.form_lan.staticlease_ip.value, 4);

	if (!staticlease_checkIpAddr(document.form_lan.staticlease_ip, false)) {
		return false;
	}

	if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.staticlease_ip.value, 1)) ||
		(atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.staticlease_ip.value, 2)) ||
		(atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.staticlease_ip.value, 3)) )
	{
		return false;
	}

	if(atoi(document.form_lan.lanIp.value, 4) == atoi(document.form_lan.staticlease_ip.value, 4)) {
		return false;
	}

	if (opmode == 1 && netsel == 0) {
		if( ((atoi(document.form_lan.dhcpStart.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEnd.value, 4))) ||
			((atoi(document.form_lan.dhcpStartSnd.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEndSnd.value, 4))))
		{
			;
		} else {
			return false;
		}


	} else {
		if((atoi(document.form_lan.dhcpStart.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEnd.value, 4))) {
			;
		} else {
			return false;
		}
	}

	return true;
}

function CheckStaticValue() {
	var mac = document.getElementById("staticlease_mac");
	var StaticMacCount = document.getElementById("maxinfo").value;
	var desc = document.getElementById("Description");

	if ( isEmpty(mac.value) == true ) {
		alert("MAC 주소를 입력해 주세요");
		return false;
	}

	if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}

	if(!ip_alloc_check()) {
		alert("IP 할당을 확인해 주세요.");
		return false;
	}


	if(StaticMacCount >= 10){
		alert("최대 설정 개수입니다");
		return false;
	}

	return true;
}

function initValue() {
	var dhcp_en, dns_proxy, mdimdix, passthru_en;
	dns_proxy = '<% mcr_getCfgString("DnsProxyCfgParam_Enable"); %>';
	mdimdix = '<% mcr_getCfgString("LoopDetectParam_Enable"); %>';
	passthru_en = "<% mcr_getCfgString("IPv6CfgParam_Passthru"); %>";
	dhcp_en = '<% mcr_getCfgString("DhcpsCfgParam_Enable"); %>';
	setdnsproxyenable(dns_proxy);
	setLanCtl(dhcp_en);

	switch(mdimdix){
		case '0':
			$("input[id='m_mdi_mdix1']").attr("checked", true).checkboxradio("refresh");
			setMdiCtl("0");
			break;
		case '1':
			$("input[id='m_mdi_mdix']").attr("checked", true).checkboxradio("refresh");
			setMdiCtl("1");
			break;
		default:
			break;
	}	

	switch(passthru_en){
		case '0':
			$("input[id='m_btn_IPv6_Passsthru_Disable']").attr("checked", true).checkboxradio("refresh");
			setIPv6Ctl("0");
			break;
		case '1':
			$("input[id='m_btn_IPv6_Passsthru_Enable']").attr("checked", true).checkboxradio("refresh");
			setIPv6Ctl("1");
			break;
		default:
			break;
	}	

	switch(dhcp_en){
		case '0':
			$("input[id='m_btn_IPv6_Passsthru_Disable']").attr("checked", true).checkboxradio("refresh");
			setIPv6Ctl("0");
			break;
		case '1':
			$("input[id='m_btn_IPv6_Passsthru_Enable']").attr("checked", true).checkboxradio("refresh");
			setIPv6Ctl("1");
			break;
		default:
			break;
	}

	if(dhcp_en == "1") {
		$("#staticlease").show();
		$("#staticlease_list").show();
		$("#btn_apply5").show();
		$("#btn_apply6").show();
	} else {
		$("#staticlease").hide();
		$("#staticlease_list").hide();
		$("#btn_apply5").hide();
		$("#btn_apply6").hide();
	}
}

function form_act(url){
	if(url == "/goform/mcr_setLan") {
		if(!CheckValue())
			return false;
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	}else if(url == "/goform/mcr_setLoopDetect"){
		$('a[name=btn_apply3]').removeClass('ui-btn-active');
		$('a[name=btn_apply3]').addClass('ui-btn-active-a');
	}else if(url == "/goform/mcr_setIPv6Passthru"){
		$('a[name=btn_apply4]').removeClass('ui-btn-active');
		$('a[name=btn_apply4]').addClass('ui-btn-active-a');
	}else if (url == "/goform/mcr_addStaticLeases") {
		if(!CheckStaticValue())
			return false;
		$('a[name=btn_apply5]').removeClass('ui-btn-active');
		$('a[name=btn_apply5]').addClass('ui-btn-active-a');
	}else if (url == "/goform/mcr_delStaticLeases") {
		$('a[name=btn_apply6]').removeClass('ui-btn-active');
		$('a[name=btn_apply6]').addClass('ui-btn-active-a');
	}
	 parent.mcrProgress.startProgressSimple("apply",30);
	form_lan.action = url;
	form_lan.submit();
	return false;
}

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
	document.form_lan.action = "/goform/mcr_KTlogOut";
	document.form_lan.submit();
}

function setMdiCtl(arg){
	switch(arg){
		case '1':
			$("#mdi_mdix").val("1");
			mcr_clickradio_MdiCtl('1');
			break;
		case '0':
			$("#mdi_mdix").val("0");
			mcr_clickradio_MdiCtl('0');
			break;
	}
}

function mcr_clickradio_MdiCtl(val){
	$('label[for=m_mdi_mdix]').removeClass('ui-btn-active');
	$('label[for=m_mdi_mdix1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_mdi_mdix1]').addClass('ui-btn-active-c');
			$('label[for=m_mdi_mdix]').removeClass('ui-btn-active-c');
			$("input[id='m_mdi_mdix1']").attr("checked", true).checkboxradio("refresh");
			break;
		case '1':
			$('label[for=m_mdi_mdix]').addClass('ui-btn-active-c');
			$('label[for=m_mdi_mdix1]').removeClass('ui-btn-active-c');
			$("input[id='m_mdi_mdix']").attr("checked", true).checkboxradio("refresh");
			break;
		default:
			break;
	}

}

function setIPv6Ctl(arg){
	switch(arg){
		case '1':
			$("#IPv6_Passthru_Enbable").val("1");
			mcr_clickradio_IPv6Ctl('1');
			break;
		case '0':
			$("#IPv6_Passthru_Enbable").val("0");
			mcr_clickradio_IPv6Ctl('0');
			break;
	}
}

function mcr_clickradio_IPv6Ctl(val){
	$('label[for=m_btn_IPv6_Passsthru_Enable]').removeClass('ui-btn-active');
	$('label[for=m_btn_IPv6_Passsthru_Disable]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_btn_IPv6_Passsthru_Disable]').addClass('ui-btn-active-c');
			$('label[for=m_btn_IPv6_Passsthru_Enable]').removeClass('ui-btn-active-c');
			$("input[id='m_btn_IPv6_Passsthru_Disable']").attr("checked", true).checkboxradio("refresh");
			break;
		case '1':
			$('label[for=m_btn_IPv6_Passsthru_Enable]').addClass('ui-btn-active-c');
			$('label[for=m_btn_IPv6_Passsthru_Disable]').removeClass('ui-btn-active-c');
			$("input[id='m_btn_IPv6_Passsthru_Enable']").attr("checked", true).checkboxradio("refresh");
			break;
		default:
			break;
	}

}

function setdnsproxyenable(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_dnsproxyenable('1');
			$("input[id='m_dnsproxyenable']").attr("checked", true).checkboxradio("refresh");

			$("#dnsproxyenable").val("1");
			break;
		case '0':       
			mcr_clickradio_dnsproxyenable('0');
			$("input[id='m_dnsproxyenable1']").attr("checked", true).checkboxradio("refresh");

			$("#dnsproxyenable").val("0");
			break;
	}
}

function mcr_clickradio_dnsproxyenable(val){
	$('label[for=m_dnsproxyenable]').removeClass('ui-btn-active');
	$('label[for=m_dnsproxyenable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_dnsproxyenable1]').addClass('ui-btn-active-c');
			$('label[for=m_dnsproxyenable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_dnsproxyenable]').addClass('ui-btn-active-c');
			$('label[for=m_dnsproxyenable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setLanCtl(arg){
	switch(arg){
	case '1':
		$("#tr_1").show();
		if (opmode == 1 && netsel == 0) {
			$("#tr_3").show();
			$("#tr_4").hide();
			if(wifirly == 1 && sohoZoneMode != 0) {
				$("#tr_4").show();
			}
		}
		else {
			$("#tr_3").hide();
			$("#tr_4").hide();
		}
		$("#tr_2").show();
		mcr_clickradio_setLanCtl('1');

		$("#lanDhcpType").val("1");
		break;
	case '0':
		$("#tr_1").hide();
		$("#tr_3").hide();
		$("#tr_4").hide();
		$("#tr_2").hide();
		mcr_clickradio_setLanCtl('0');

		$("#lanDhcpType").val("0");
		break;
	}
}
function mcr_clickradio_setLanCtl(val){
	$('label[for=lanDhcpType]').removeClass('ui-btn-active');
	$('label[for=lanDhcpType1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=lanDhcpType1]').addClass('ui-btn-active-c');
			$('label[for=lanDhcpType]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=lanDhcpType]').addClass('ui-btn-active-c');
			$('label[for=lanDhcpType1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function on_focus_clear(id){
	    document.getElementById(id).value="";
}

function act_mac(macaddr) {
	document.form_lan.staticlease_mac.value = macaddr;
}

function check_mac() {
	var f=document.form_lan;

	if(f.staticlease_pcmac.checked == true){
		$("#pcList").show();
	}else{
		$("#pcList").hide();
	}
}
</script>
</head>
<body onload="initValue()">
<form method="post" name="form_lan" action="/goform/mcr_setLan" data-ajax="false">

<input type="hidden" name="SETLAN" value="/new/mobile_03_1_4_lan_link_set.asp">
<input type="hidden" name="lanDhcpType" id="lanDhcpType" value="1">	

<input type="hidden" name="mdi_mdix" id="mdi_mdix" value="">
<input type="hidden" name="dnsproxyenable" id="dnsproxyenable" value="">
<input type="hidden" name="IPv6_Passthru_Enbable" id="IPv6_Passthru_Enbable" value="">

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
					LAN 연결 설정
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

	<div style="padding:0 5 12 5px;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">IP 주소:</td>
				<td>
					<input type="text" id="lanIp" name="lanIp" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("LanDevice_IpAddress"); %>">
				</td>
			</tr>
			<tr>
				<td width="35%">서브넷마스크:</td>
				<td>
					<input type="text" id="lanNetmask" name="lanNetmask" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("LanDevice_SubNetMask");%>">
				</td>
			</tr>
		</table>
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">DHCP 서버:</td>
				<td colspan="2">
					<fieldset data-role="controlgroup" data-type="horizontal">
						<label for="lanDhcpType">　활성　</label>
						<input type="radio" name="lanDhcpType" id="lanDhcpType" value="1" onclick="setLanCtl(this.value)">
						<label for="lanDhcpType1">　비활성　</label>
						<input type="radio" name="lanDhcpType" id="lanDhcpType1" value="0" onclick="setLanCtl(this.value)">
					</fieldset>
				</td>
			</tr>
			<tr id="tr_1">
				<td width="35%">DHCP 코넷 IP <br>사용범위:<br></td>
				<td>
					<input type="text" id="dhcpStart" name="dhcpStart" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp"); %>">
				</td>
				<td>~</td>
				<td>
					<input type="text" id="dhcpEnd" name="dhcpEnd" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_EndIp"); %>">
				</td>
			</tr>
			<tr id="tr_3">
				<td width="35%">DHCP 프리미엄 IP <br>사용범위:<br></td>
				<td>
					<input type="text" id="dhcpStartSnd" name="dhcpStartSnd" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Snd"); %>">
				</td>
				<td>~</td>
				<td>
					<input type="text" id="dhcpEndSnd" name="dhcpEndSnd" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Snd"); %>">
				</td>
			</tr>
			<tr id="tr_2">
				<td width="35%">DHCP 임대시간:</td>
				<td>
					<input type="text" id="dhcpLease" name="dhcpLease" style="width:100%" class="input_r_t" value="<% mcr_getCfgString("DhcpsCfgParam_Lease_time"); %>">
				</td>
				<td>(sec)</td>
			</tr>
			<tr>
				<td width="35%">DNS Proxy:</td>
				<td align="right" colspan="2">
					<fieldset data-role="controlgroup" data-type="horizontal">
						<label for="m_dnsproxyenable">　활성　</label>
						<input name="m_dnsproxyenable" type="radio" id="m_dnsproxyenable" value="1" onclick="setdnsproxyenable(this.value)">
						<label for="m_dnsproxyenable1">　비활성　</label>
						<input name="m_dnsproxyenable" type="radio" id="m_dnsproxyenable1" value="0" onclick="setdnsproxyenable(this.value)">
					</fieldset>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setLan')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:0 5 12 5px; display:none;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>MDI/MDIX auto 설정</td>
				<td colspan="2">
					<fieldset data-role="controlgroup" data-type="horizontal">
						<label for="m_mdi_mdix">　활성　</label>
						<input name="m_mdi_mdix" type="radio" id="m_mdi_mdix" value="1" onclick="setMdiCtl(this.value)">
						<label for="m_mdi_mdix1">　비활성　</label>
						<input name="m_mdi_mdix" type="radio" id="m_mdi_mdix1" value="0" onclick="setMdiCtl(this.value)">
					</fieldset>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px; display:none;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="return form_act('/goform/mcr_setLoopDetect')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	
	<div style="padding:0 5 12 5px; display:none;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>IPv6 Passthru 설정</td>
				<td colspan="2">
					<fieldset data-role="controlgroup" data-type="horizontal">
						<label for="m_btn_IPv6_Passsthru_Enable">　활성　</label>
						<input name="m_IPv6_Passthru_Enbable" type="radio" id="m_btn_IPv6_Passsthru_Enable" value="1" onclick="setIPv6Ctl(this.value)">
						<label for="m_btn_IPv6_Passsthru_Disable">　비활성　</label>
						<input name="m_IPv6_Passthru_Enbable" type="radio" id="m_btn_IPv6_Passsthru_Disable" value="0" onclick="setIPv6Ctl(this.value)">
					</fieldset>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px; display:none;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply4" name="btn_apply4" onclick="return form_act('/goform/mcr_setIPv6Passthru')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>

	<div id="staticlease" style="padding:10px 0 0 0;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">수동 IP 할당 설정</td>
			</tr>
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td style="font-weight:bold;">타겟 MAC 주소</td>
							<td>
								<input name="staticlease_mac" type="text" id="staticlease_mac" maxlength="17" value="" onfocus="on_focus_clear('staticlease_mac')">
							</td>
						</tr>
						<tr>
							<td></td>
							<td>
								<input type="checkbox" name="staticlease_pcmac" id="staticlease_pcmac" value="" data-role="none" onclick="check_mac();">
								<label for="staticlease_pcmac"></label>
								현재 LAN 포트 접속된 PC
							</td>
						</tr>
						<tr id="pcList" style="display:none">
							<td colspan="2">
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" class="fix">
									<tr>
										<td>
											<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
												<table class="TB" width="100%" border="0" style="table-layout:fixed;">
													<col>
													<col>
													<tr>
														<td align="center">선택</td>
														<td align="center">MAC 주소</td>
													</tr>
												</table>
											</span>
										</td>
									</tr>
									<tr id="staticlease_height">
										<td width="100%">
											<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
												<table class="TB" id="Grid_Table" border="0" style="table-layout:fixed">
													<col align="center">
													<col align="center">
													<%
														var i;
														var rule_num = mcr_getLanConnectBindInfo(0,0);
														write("<input type=hidden id=cur_staticlease value=");write(rule_num);write(">");

														if (rule_num > 0) {
															for ( i = 0; i < rule_num; i++ ){
																write("<tr>");
																write("<td style='padding-left:0px;' align='middle'>");
																write("<input name=DR type=checkbox onClick=act_mac(\""+mcr_getLanConnectBindInfo(1,i)+"\") data-role=none>");
																write("</td>");

																write("<td style=word-break:break-all>");
																write("<p>");write(mcr_getLanConnectBindInfo(1,i));write("</p>");
																write("</td>");
																write("</tr>\n");
															}
														}
														else {
															write("<tr>");
															write("<td colspan=5 align='center'>");
															write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
															write("</td>");
															write("</tr>\n");
														}
													%>
												</table>
											</span>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td style="font-weight:bold;">할당 IP</td>
							<td>
								<input type="text" id="staticlease_ip" name="staticlease_ip" style="width:100%" class="input_r_t">
							</td>
						</tr>
						<tr>
							<td style="font-weight:bold;">설명</td>
							<td>
								<input name="Description" type="text" id="Description" maxlength="17" value="">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply5" name="btn_apply5" onclick="return form_act('/goform/mcr_addStaticLeases');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
	</div>
	<div id="staticlease_list" style="padding:0 5 12 5px;" class="ui-field-contain" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td style="font-weight:bold;">IP 할당 리스트</td>
			</tr>
		</table>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" valign="middle">
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col align="middle">
									<col align="middle">
									<col align="middle">
									<col align="middle">
									<tr>
										<td>선택</td>
										<td>MAC 주소</td>
										<td>할당 IP</td>
										<td>설명</td>
									</tr>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" valign="middle">
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
								<col>
								<col>
								<col>
								<col>
									<%
										var i;
										var rule_num = mcr_getStaticMacInfoCount();
										write("<input type=hidden id=maxinfo value=");write(rule_num);write(">");
										if (rule_num > 0) {
											for ( i = 0; i < rule_num; i++ ){
												write("<tr>");

												write("<td align='middle'>");
												write("<input type=checkbox name=chk_" + i + " id=chk_"+i+" data-role='none'>");
												write("</td>");
	
												write("<td style='word-break:break-all' align='center'>");
												write("<p>");write(mcr_getStaticMacList(i,0));write("</p>");
												write("</td>");

												write("<td align='center'>");
												write("<p>");write(mcr_getStaticMacList(i,1));write("</p>");
												write("</td>");
												write("</tr>\n");

												write("<td align='center'>");
												write("<p>");write(mcr_getStaticMacList(i,2));write("</p>");
												write("</td>");
												write("</tr>\n");
											}
										}
										else {
											write("<tr>");
											write("<td colspan=3 align='center'>");
											write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
											write("</td>");
											write("</tr>\n");
										}
									%>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="javascript:;" id="btn_apply6" name="btn_apply6" alt="" onclick="return form_act('/goform/mcr_delStaticLeases');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>

</form>
</body>
</html>
