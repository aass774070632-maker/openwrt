<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
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
var UserPrivilege = getUserPrivilege();
var Privilege = parseInt(UserPrivilege, 10);
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

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
	document.form.action = "/goform/mcr_KTlogOut";
	document.form.submit();
}

function setSearchCtl(arg){
	switch(arg){
		case '2':       
			$("#tr_dhcpSetInfo").show();
			$("#tr_staticSetInfo").hide();
			$("#tr_dhcpConnInfo").show();
			$("#connectionType").val("2");
			mcr_clickradio_SearchCtl('2');
			break;
		case '1':       
			$("#tr_dhcpSetInfo").hide();
			$("#tr_staticSetInfo").show();
			$("#tr_dhcpConnInfo").hide();
			$("#connectionType").val("1");
			mcr_clickradio_SearchCtl('1');
			break;
	}
}

function mcr_clickradio_SearchCtl(val){
	$('label[for=m_connectionType]').removeClass('ui-btn-active');
	$('label[for=m_connectionType1]').removeClass('ui-btn-active');
	switch(val){
		case '2':
			$('label[for=m_connectionType]').addClass('ui-btn-active-c');
			$('label[for=m_connectionType1]').removeClass('ui-btn-active-c');
			$("input[id='m_connectionType']").attr("checked", true).checkboxradio("refresh");
			break;
		case '1':
			$('label[for=m_connectionType1]').addClass('ui-btn-active-c');
			$('label[for=m_connectionType]').removeClass('ui-btn-active-c');
			$("input[id='m_connectionType1']").attr("checked", true).checkboxradio("refresh");
			break;
		default:
			break;
	}

}

function setOpt60Ctl(arg){
	switch(Privilege){
		case 3:
			$("#tr_1").hide();
			break;
		case 7:
			switch(arg){
				case '0':
					$("#tr_1").hide();
					$("#wanOpt60_en").val("0");
					mcr_clickradio_Opt60Ctl('0');
					break;
				case '1':
					$("#tr_1").show();
					$("#wanOpt60_en").val("1");
					mcr_clickradio_Opt60Ctl('1');
					break;
			}
			break;
		default:
			break;
	}
}

function mcr_clickradio_Opt60Ctl(val){
        $('label[for=m_wanOpt60_en]').removeClass('ui-btn-active');
        $('label[for=m_wanOpt60_en1]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_wanOpt60_en1]').addClass('ui-btn-active-c');
                        $('label[for=m_wanOpt60_en]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanOpt60_en1']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_wanOpt60_en]').addClass('ui-btn-active-c');
                        $('label[for=m_wanOpt60_en1]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanOpt60_en']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}


function setOpt77Ctl(arg){
	switch(Privilege){
		case 3:
			$("#tr_2").hide();
			break;
		case 7:
			switch(arg){
				case '0':
					$("#tr_2").hide();
					$("#wanOpt77_en").val("0");
					mcr_clickradio_Opt77Ctl('0');
					break;
				case '1':
					$("#tr_2").show();
					$("#wanOpt77_en").val("1");
					mcr_clickradio_Opt77Ctl('1');
					break;
			}
			break;
		default:
			break;
	}
}

function mcr_clickradio_Opt77Ctl(val){
        $('label[for=m_wanOpt77_en]').removeClass('ui-btn-active');
        $('label[for=m_wanOpt77_en1]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_wanOpt77_en1]').addClass('ui-btn-active-c');
                        $('label[for=m_wanOpt77_en]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanOpt77_en1']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_wanOpt77_en]').addClass('ui-btn-active-c');
                        $('label[for=m_wanOpt77_en1]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanOpt77_en']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}

function setDnsCtl(arg){
	switch(arg){
		case '0':       
			$("#tr_dnsSetInfo1").hide();
			$("#tr_dnsSetInfo2").hide();
			$("#wanDnsType").val("0");
			mcr_clickradio_DnsCtl('0');
			break;
		case '1':       
			$("#tr_dnsSetInfo1").show();
			$("#tr_dnsSetInfo2").show();
			$("#wanDnsType").val("1");
			mcr_clickradio_DnsCtl('1');
			break;
	}
}

function mcr_clickradio_DnsCtl(val){
        $('label[for=m_wanDnsType]').removeClass('ui-btn-active');
        $('label[for=m_wanDnsType1]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_wanDnsType]').addClass('ui-btn-active-c');
                        $('label[for=m_wanDnsType1]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanDnsType']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_wanDnsType1]').addClass('ui-btn-active-c');
                        $('label[for=m_wanDnsType]').removeClass('ui-btn-active-c');
                        $("input[id='m_wanDnsType1']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}

function setMacCtl(arg){
	var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";
	var repeater_en = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
	switch(arg){
		case '1':       
			if((opmode == 0) || (limit_cnt_en == "0") || (repeater_en != 0)){        
				$("#view_macClone").show();
				$("#tr_macCloneMacRow").hide();
				$("#tr_macCloneTitle").hide();
				$("#tr_macCloneList").hide();
				$("#btn_apply2").hide();
				$("#macCloneEnbl").val("1");
				mcr_clickradio_MacCtl('1');
				$("input[id='m_macCloneEnbl']").attr('disabled',true).checkboxradio("refresh");
			}else{
				$("#view_macClone").show();
				$("#tr_macCloneMacRow").show();
				$("#tr_macCloneTitle").show();
				$("#tr_macCloneList").show();
				$("#btn_apply2").show();
				$("#macCloneEnbl").val("1");
				mcr_clickradio_MacCtl('1');
				$("input[id='m_macCloneEnbl']").attr('disabled',false).checkboxradio("refresh");
			}
			break;
		case '0':       
			if((opmode == 0) || (limit_cnt_en == "0") || (repeater_en != 0)){        
				$("#view_macClone").show();
				$("#tr_macCloneMacRow").hide();
				$("#tr_macCloneTitle").hide();
				$("#tr_macCloneList").hide();
				$("#btn_apply2").hide();
				$("#macCloneEnbl").val("0");
				mcr_clickradio_MacCtl('0');
				$("input[id='m_macCloneEnbl']").attr('disabled',true).checkboxradio("refresh");
			}else{
				$("#view_macClone").show();
				$("#tr_macCloneMacRow").hide();
				$("#tr_macCloneTitle").hide();
				$("#tr_macCloneList").hide();
				$("#btn_apply2").show();
				$("#macCloneEnbl").val("0");
				mcr_clickradio_MacCtl('0');
				$("input[id='m_macCloneEnbl']").attr('disabled',false).checkboxradio("refresh");
			}
			break;
	}
}

function mcr_clickradio_MacCtl(val){
        $('label[for=m_macCloneEnbl]').removeClass('ui-btn-active');
        $('label[for=m_macCloneEnbl1]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_macCloneEnbl1]').addClass('ui-btn-active-c');
                        $('label[for=m_macCloneEnbl]').removeClass('ui-btn-active-c');
                        $("input[id='m_macCloneEnbl1']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_macCloneEnbl]').addClass('ui-btn-active-c');
                        $('label[for=m_macCloneEnbl1]').removeClass('ui-btn-active-c');
                        $("input[id='m_macCloneEnbl']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}

function setVocCtl(arg){
	switch(arg){
		case '1':
			$("#voclocalenable").val("1");
			mcr_clickradio_VocCtl('1');
			break;
		case '0':
			$("#voclocalenable").val("0");
			mcr_clickradio_VocCtl('0');
			break;
	}
}

function mcr_clickradio_VocCtl(val){
        $('label[for=m_voclocalenable1]').removeClass('ui-btn-active');
        $('label[for=m_voclocalenable0]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_voclocalenable0]').addClass('ui-btn-active-c');
                        $('label[for=m_voclocalenable1]').removeClass('ui-btn-active-c');
                        $("input[id='m_voclocalenable0']").attr("checked", true).checkboxradio("refresh");
                        break;
                case '1':
                        $('label[for=m_voclocalenable1]').addClass('ui-btn-active-c');
                        $('label[for=m_voclocalenable0]').removeClass('ui-btn-active-c');
                        $("input[id='m_voclocalenable1']").attr("checked", true).checkboxradio("refresh");
                        break;
                default:
                        break;
        }
}

function initApp(){
	var Dns_en = "<% mcr_getCfgString("UserManage_DnsCheck"); %>";

	switch(Privilege){
		case 3:
			$("#option_60").hide();
			$("#option_77").hide();
			break;
		case 7:
			$("#option_60").show();
			$("#option_77").show();
			break;
		default:
			break;
	}

	{
		var usbprio = "<% mcr_getCfgString("UsbTetheringInfo_Priority"); %>";

		if (usbprio != "0") {
			$("#tr_usbConnInfo").show();
		} else {
			$("#tr_usbConnInfo").hide();
		}
	}
	
	{
		var contype = "<% mcr_getCfgInterface("WanDevice_WanConnType"); %>";
		var dnstype = "<% mcr_getCfgString("DnsCfgParam_Enable"); %>";
		var netsel = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>"; 
		var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

		var wanopt60_en = "<% mcr_getCfgString("WanDevice_Dhcp_Option60_Enable"); %>";
		var wanopt77_en = "<% mcr_getCfgString("WanDevice_Dhcp_Option77_Enable"); %>";

		switch(contype){
			case "DHCP":
				$("input[id='m_connectionType']").attr("checked", true).checkboxradio("refresh");
				setSearchCtl("2");
			break;
			case "STATIC":
				$("input[id='m_connectionType1']").attr("checked", true).checkboxradio("refresh");
				setSearchCtl("1");
			break;
			default:
			break;
		}

		switch(wanopt60_en){
			case '0':
				$("input[id='m_wanOpt60_en1']").attr("checked", true).checkboxradio("refresh");
				setOpt60Ctl("0");
				break;
			case '1':
				$("input[id='m_wanOpt60_en']").attr("checked", true).checkboxradio("refresh");
				setOpt60Ctl("1");
				break;
			default:
				break;
		}

		switch(wanopt77_en){
			case '0':
				$("input[id='m_wanOpt77_en1']").attr("checked", true).checkboxradio("refresh");
				setOpt77Ctl("0");
				break;
			case '1':
				$("input[id='m_wanOpt77_en']").attr("checked", true).checkboxradio("refresh");
				setOpt77Ctl("1");
				break;
			default:
				break;
		}

		switch(dnstype){
			case '0':
				$("input[id='m_wanDnsType']").attr("checked", true).checkboxradio("refresh");
				setDnsCtl("0");
				break;
			case '1':
				switch(contype){
					case "DHCP":
						$("input[id='m_wanDnsType1']").attr("checked", true).checkboxradio("refresh");
						setDnsCtl("1");
					break;
					case "STATIC":
						$("input[id='m_wanDnsType']").attr("checked", true).checkboxradio("refresh");
						setDnsCtl("0");
					break;
					default:
					break;
				}
				break;
			default:
				break;
		}

		if (opmode == "1" && netsel == "1") {
			$("#tr_1").hide();
			$("#tr_2").hide();
		}

	}

	
	{
		var clone = "<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>";

		switch(clone){
			case '0':
				document.form.macCloneMac.value = "";
				$("input[id='m_macCloneEnbl1']").attr("checked", true).checkboxradio("refresh");
				setMacCtl("0");
				break;
			case '1':
				$("input[id='m_macCloneEnbl']").attr("checked", true).checkboxradio("refresh");
				setMacCtl("1");
				break;
			default:
				break;
		}

	}

	
	{
		var vocenble = "<% mcr_getCfgString("VocCfgParam_Enable"); %>";

		switch(vocenble){
			case '0':
				$("input[id='m_voclocalenable0']").attr("checked", true).checkboxradio("refresh");
				setVocCtl("0");
				break;
			case '1':
				$("input[id='m_voclocalenable1']").attr("checked", true).checkboxradio("refresh");
				setVocCtl("1");
				break;
			default:
				break;
		}
	}

	
	{
		switch(Dns_en){
			case '0':
				$("input[id='m_wanDnsType']").attr('disabled',false).checkboxradio("refresh");
				$("input[id='m_wanDnsType1']").attr('disabled',false).checkboxradio("refresh");
				$("input[name='dns1ip_1']").attr('disabled',false).checkboxradio("refresh");
				$("input[name='dns2ip_1']").attr('disabled',false).checkboxradio("refresh");
				$("input[name='dns3ip_1']").attr('disabled',false).checkboxradio("refresh");
				$("input[name='dns4ip_1']").attr('disabled',false).checkboxradio("refresh");
				break;
			case '1':
				$("input[id='m_connectionType1']").attr('disabled', true).checkboxradio("refresh");
				$("input[id='m_wanDnsType']").attr('disabled', true).checkboxradio("refresh");
				$("input[id='m_wanDnsType1']").attr('disabled', true).checkboxradio("refresh");
				$("input[name='dns1ip_1']").attr('disabled', true).checkboxradio("refresh");
				$("input[name='dns2ip_1']").attr('disabled', true).checkboxradio("refresh");
				$("input[name='dns3ip_1']").attr('disabled', true).checkboxradio("refresh");
				$("input[name='dns4ip_1']").attr('disabled', true).checkboxradio("refresh");
				break;
			default:
				break;
		}
	}

}

function CheckValue()
{

	$("input[name='dns1ip']").val($("input[name='dns1ip_1']").val());
	$("input[name='dns2ip']").val($("input[name='dns2ip_1']").val());
	$("input[name='dns3ip']").val($("input[name='dns3ip_1']").val());
	$("input[name='dns4ip']").val($("input[name='dns4ip_1']").val());

	if ($("#connectionType").val() == 1 ) {      
		if (!checkIpAddr(document.form.staticIp, false))
			return false;
		if (!checkIpAddr(document.form.staticNetmask, true))
			return false;
		if (!checkIpAddr(document.form.staticGateway, false))
			return false;
		if (document.form.dns1ip.value != "")
			if (!checkIpAddr(document.form.dns1ip, true))
				return false;
		if (document.form.dns2ip.value != "")
			if (!checkIpAddr(document.form.dns2ip, true))
				return false;
	}
	else if ($("#connectionType").val() == 2) { 
		if (document.form.option60.value != "") {
			if (document.form.option60.value.length > 32) {
				alert("OPTION60 입력값을 32자 이내로 설정해 주세요");
				document.form.option60.focus();
				return false;
			}
		}
		if (document.form.option77.value != "") {
			if (document.form.option77.value.length > 32) {
				alert("OPTION77 입력값을 32자 이내로 설정해 주세요");
				document.form.option77.focus();
				return false;
			}
		}
		if ($("#wanDnsType").val() == 1) {	
			if (document.form.dns3ip.value != "")
				if (!checkIpAddr(document.form.dns3ip, true))
					return false;
			if (document.form.dns4ip.value != "")
				if (!checkIpAddr(document.form.dns4ip, true))
					return false;
		}
	}
	else
		return false;
	return true;
}

function act(macaddr) {
	document.form.macCloneMac.value = macaddr;
}

function setWan(url) {
	if (CheckValue()) {
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
		form_act(url);
	}
	return false;
}

function form_act(url){
	if(url == "/goform/mcr_setMacClone"){
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	}else{
		$('a[name=btn_apply3]').removeClass('ui-btn-active');
		$('a[name=btn_apply3]').addClass('ui-btn-active-a');
	}
	parent.mcrProgress.startProgressSimple("apply",20);

	form.action = url;
	form.submit();
	return false;
}

</script>

</head>
<body onload="initApp()">
<form method="post" name="form" data-ajax="false">

<input type="hidden" id="connectionType" name="connectionType" value="">
<input type="hidden" id="wanOpt60_en" name="wanOpt60_en" value="">
<input type="hidden" id="wanOpt77_en" name="wanOpt77_en" value="">
<input type="hidden" id="wanDnsType" name="wanDnsType" value="">
<input type="hidden" id="macCloneEnbl" name="macCloneEnbl" value="">
<input type="hidden" id="voclocalenable" name="voclocalenable" value="">
<input type="hidden" id="redirect_admWanSet" name="redirect_admWanSet" value="/new/mobile_03_1_2_internet_link_set.asp">

<input type="hidden" id="dns1ip" name="dns1ip" value="">       
<input type="hidden" id="dns2ip" name="dns2ip" value="">
<input type="hidden" id="dns3ip" name="dns3ip" value="">
<input type="hidden" id="dns4ip" name="dns4ip" value="">

<div data-role="page" data-theme="d">
        <div data-role="header" data-theme="d">
                <table width="100%">
                        <tr>
                                <td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그 아웃</a>
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
                                        인터넷 연결 설정
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

	<div style="padding:10px 0 0 0;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">연결 설정</td>
				<td>
				<fieldset data-role="controlgroup" data-type="horizontal">
					<label for="m_connectionType">　DHCP　</label>
					<input name="m_connectionType" type="radio" id="m_connectionType" value="2" onclick="setSearchCtl(this.value)">
					<label for="m_connectionType1">　고정 IP　</label>
					<input name="m_connectionType" type="radio" id="m_connectionType1" value="1" onclick="setSearchCtl(this.value)">
				</fieldset>
				</td>
			</tr>
			<tr id="tr_dhcpSetInfo">
				<td colspan="2">
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr id="option_60" style="display:none">
							<td width="35%">OPTION 60사용</td>
							<td>
							<fieldset data-role="controlgroup" data-type="horizontal">
								<label for="m_wanOpt60_en">　활성　</label>
								<input type="radio" name="m_wanOpt60_en" id="m_wanOpt60_en" value="1" onclick="setOpt60Ctl(this.value)">
								<label for="m_wanOpt60_en1">　비활성　</label>
								<input type="radio" name="m_wanOpt60_en" id="m_wanOpt60_en1" value="0" onclick="setOpt60Ctl(this.value)">
							</fieldset>
							</td>
						</tr>
						<tr id="tr_1" style="display:none">
							<td width="35%">OPTION 60</td>
							<td><input name="option60" type="text" id="option60" value="<% mcr_getCfgString("WanDevice_Dhcp_Option60"); %>" size="21">
							ex)KT_DE_HH_MERCURY_MODEL.
							</td>
						</tr>
						<tr id="option_77" style="display:none">
							<td width="35%">OPTION 77사용</td>
							<td>
							<fieldset data-role="controlgroup" data-type="horizontal">
								<label for="m_wanOpt77_en">　활성　</label>
								<input type="radio" name="m_wanOpt77_en" id="m_wanOpt77_en" value="1" onclick="setOpt77Ctl(this.value)">
								<label for="m_wanOpt77_en1">　비활성　</label>
								<input type="radio" name="m_wanOpt77_en" id="m_wanOpt77_en1" value="0" onclick="setOpt77Ctl(this.value)">
							</fieldset>
							</td>
						</tr>
						<tr id="tr_2" style="display:none">
							<td width="35%">OPTION 77</td>
							<td><input name="option77" type="text" id="option77" value="<% mcr_getCfgString("WanDevice_Dhcp_Option77"); %>">
							ex)KT_PR_SI_D
							</td>
						</tr>
						<tr id="tr_dnsInfo">
							<td width="35%">DNS 선택</td>
							<td>
							<fieldset data-role="controlgroup" data-type="horizontal">
								<label for="m_wanDnsType">　자동　</label>
								<input type="radio" name="m_wanDnsType" id="m_wanDnsType" value="0" onclick="setDnsCtl(this.value)">
								<label for="m_wanDnsType1">　수동　</label>
								<input type="radio" name="m_wanDnsType" id="m_wanDnsType1" value="1" onclick="setDnsCtl(this.value)">
							</fieldset>
							</td>
						</tr>
						<tr id="tr_dnsSetInfo1">
							<td width="35%">기본 DNS</td>
							<td>
								<input name="dns3ip_1" type="text" id="dns3ip_1" value="<% mcr_getCfgInterface("DnsCfgParam_Primary"); %> ">
								ex)168.126.63.1
							</td>
						</tr>
						<tr id="tr_dnsSetInfo2">
							<td width="35%">보조 DNS</td>
							<td>
								<input name="dns4ip_1" type="text" id="dns4ip_1" value="<% mcr_getCfgInterface("DnsCfgParam_Secondary"); %> ">
								ex)168.126.63.2
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="tr_staticSetInfo">
				<td colspan="2">
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IP 주소</td>
							<td>
								<input name="staticIp" type="text" id="staticIp" value="<% mcr_getCfgInterface("WanDevice_IpAddress"); %> ">
								ex)192.168.10.32
							</td>
						</tr>
						<tr>
							<td width="35%">서브넷마스크</td>
							<td>
								<input name="staticNetmask" type="text" id="staticNetmask" value="<% mcr_getCfgInterface("WanDevice_SubNetMask"); %> ">
								ex)255.255.255.0
							</td>
						</tr>
						<tr>
							<td width="35%">게이트웨이</td>
							<td>
								<input name="staticGateway" type="text" id="staticGateway" value="<% mcr_getCfgInterface("WanDevice_DefaultGw"); %> ">
								ex)192.168.10.254
							</td>
						</tr>
						<tr>
							<td width="35%">기본 DNS</td>
							<td>
								<input name="dns1ip_1" type="text" id="dns1ip_1" value="<% mcr_getCfgInterface("DnsCfgParam_Primary"); %> ">
								ex)168.126.63.1
							</td>
						</tr>
						<tr>
							<td width="35%">보조 DNS</td>
							<td>
								<input name="dns2ip_1" type="text" id="dns2ip_1" value="<% mcr_getCfgInterface("DnsCfgParam_Secondary"); %> ">
								ex)168.126.63.1
							</td>
						</tr>
					</table>
				</td>
			</tr>				
		</table>
	</div>
    <div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return setWan('/goform/mcr_setWan')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
    <div style="padding:0 5 12 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td align="center">DHCP 연결정보</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IP 주소</td>
							<td><% mcr_getCfgInterface("WanDevice_IpAddress"); %></td>
						</tr>
						<tr>
							<td width="35%">서브넷마스크</td>
							<td><% mcr_getCfgInterface("WanDevice_SubNetMask"); %></td>
						</tr>
						<tr>
							<td width="35%">게이트웨이</td>
							<td><% mcr_getCfgInterface("WanDevice_DefaultGw"); %></td>
						</tr>
						<tr>
							<td width="35%">기본 DNS</td>
							<td><% mcr_getCfgInterface("DnsCfgParam_Primary"); %></td>
						</tr>
						<tr>
							<td width="35%">보조 DNS</td>
							<td><% mcr_getCfgInterface("DnsCfgParam_Secondary"); %></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td align="center">MAC Clone</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">MAC Clone</td>
							<td id="view_macClone">
							<fieldset data-role="controlgroup" data-type="horizontal">
								<label for="m_macCloneEnbl">　활성　</label>
									<input type='radio' name='m_macCloneEnbl' id='m_macCloneEnbl' value='1' onclick="setMacCtl(this.value)">
								<label for="m_macCloneEnbl1">　비활성　</label>
									<input type="radio" name="m_macCloneEnbl" id="m_macCloneEnbl1" value="0" onclick="setMacCtl(this.value)">
							</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="tr_macCloneMacRow" style="display:none">
				<td align="left">
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">MAC  Clone 주소</td>
							<td>
								<input name="macCloneMac" type="text" id="macCloneMac" value="<% mcr_getCfgInterface("MacCloneCfgParam_LanMac"); %>">
							</td>
						</tr>
					</table>
				</td>
			</tr>			
			<tr id="tr_macCloneTitle" style="display:none">
				<td>
					
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<colgroup><col>
										<col>
										<col>
										<col>
										<col> 
										<tr>
											<td>
												
												<p>
													선택
												</p>
											</td>
											<td>
												<p>PC 이름</p>
											</td>
											<td>
												<p>IP 주소</p>
											</td>
											<td>
												<p>MAC 주소</p>
											</td>
											<td>
												<p>상태</p>
											</td>
										</tr>
									</table>
								</span>
							</td>
							<td id="lastTD" style="display:none;">
								<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td>&nbsp;</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				
				</td>
			</tr>
			<tr id="tr_macCloneList" style="display:none">
				<td width="100%" valign="top">
					<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<col align="center"> 
							<col>
							<col>
							<col>
							<col align="center">
							<%
								var i;
								var rule_num = mcr_getMacInfoCount(0);

								if (rule_num > 0) {
									for ( i = 0; i < rule_num; i++ ){
										write("<tr>");
	
										write("<td style='padding-left:0px;' align='center'>");
										write("<input name=DR type=radio onClick=act(\""+mcr_getMacInfoList(i,2)+"\") data-role='none' >");
										write("</td>");

										write("<td style='word-break:break-all'>");
										write("<p>");write(mcr_getMacInfoList(i,0));write("</p>");
										write("</td>");

										write("<td>");
										write("<p>");write(mcr_getMacInfoList(i,1));write("</p>");
										write("</td>");
	
										write("<td>");
										write("<p>");write(mcr_getMacInfoList(i,2));write("</p>");
										write("</td>");

										write("<td>");
										write("<p>");write(mcr_getMacInfoList(i,3));write("</p>");
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
	</div>
    <div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setMacClone')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">인터넷 장애 알림</td>
				<td>
				<fieldset data-role="controlgroup" data-type="horizontal">
					<label for="m_voclocalenable1">　활성　</label>
					<input name="m_voclocalenable" type="radio" id="m_voclocalenable1" value="1" onclick="setVocCtl(this.value)">
					<label for="m_voclocalenable0">　비활성　</label>
					<input name="m_voclocalenable" type="radio" id="m_voclocalenable0" value="0" onclick="setVocCtl(this.value)">
				</fieldset>
				</td>
			</tr>
		</table>
	</div>
        <div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="return form_act('/goform/mcr_setVocLocal')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:0 5 12 5px;">
		<table id="tr_usbConnInfo" align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td align="center">USB WAN 연결정보</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IP 주소</td>
							<td><% mcr_getCfgInterface("UsbWanDevice_IpAddress"); %></td>
						</tr>
						<tr>
							<td width="35%">서브넷마스크</td>
							<td><% mcr_getCfgInterface("UsbWanDevice_SubNetMask"); %></td>
						</tr>
						<tr>
							<td width="35%">게이트웨이</td>
							<td><% mcr_getCfgInterface("UsbWanDevice_DefaultGw"); %></td>
						</tr>
						<tr>
							<td width="35%">기본 DNS</td>
							<td><% mcr_getCfgInterface("UsbWanDevice_Dns1"); %></td>
						</tr>
						<tr>
							<td width="35%">보조 DNS</td>
							<td><% mcr_getCfgInterface("UsbWanDevice_Dns2"); %></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
