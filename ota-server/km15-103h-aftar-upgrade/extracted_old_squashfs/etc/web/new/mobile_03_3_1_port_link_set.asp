<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>

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
	background:#fff
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

function pause_set(id, val)
{
	var value = parseInt(val , 10 );
	if(value){
		$('#'+id).removeAttr("disabled");
	}else{
		$('#'+id).attr("disabled","disabled");
		$('#'+id).val("0");
	}
	$("#"+id).selectmenu("refresh");
}

function initValue(){
	p0_s = <% mcr_getLanPortStatus(0,6); %>;
	p1_s = <% mcr_getLanPortStatus(1,6); %>;
	p2_s = <% mcr_getLanPortStatus(2,6); %>;
	p3_s = <% mcr_getLanPortStatus(3,6); %>;
	p4_s = <% mcr_getLanPortStatus(4,6); %>;
	p0_f = <% mcr_getLanPortStatus(0,7); %>;
	p1_f = <% mcr_getLanPortStatus(1,7); %>;
	p2_f = <% mcr_getLanPortStatus(2,7); %>;
	p3_f = <% mcr_getLanPortStatus(3,7); %>;
	p4_f = <% mcr_getLanPortStatus(4,7); %>;

	p0_fm = <% mcr_getLanPortStatus(0,8); %>;
	p1_fm = <% mcr_getLanPortStatus(1,8); %>;
	p2_fm = <% mcr_getLanPortStatus(2,8); %>;
	p3_fm = <% mcr_getLanPortStatus(3,8); %>;
	p4_fm = <% mcr_getLanPortStatus(4,8); %>;

	document.form_portcfg.port0_an.options.selectedIndex = p0_s;
	document.form_portcfg.port1_an.options.selectedIndex = p1_s;
	document.form_portcfg.port2_an.options.selectedIndex = p2_s;
	document.form_portcfg.port3_an.options.selectedIndex = p3_s;
	document.form_portcfg.port4_an.options.selectedIndex = p4_s;

	document.form_portcfg.port0_fc.options.selectedIndex = p0_f;
	document.form_portcfg.port1_fc.options.selectedIndex = p1_f;
	document.form_portcfg.port2_fc.options.selectedIndex = p2_f;
	document.form_portcfg.port3_fc.options.selectedIndex = p3_f;
	document.form_portcfg.port4_fc.options.selectedIndex = p4_f;

	document.form_portcfg.port0_fcm.options.selectedIndex = p0_fm;
	document.form_portcfg.port1_fcm.options.selectedIndex = p1_fm;
	document.form_portcfg.port2_fcm.options.selectedIndex = p2_fm;
	document.form_portcfg.port3_fcm.options.selectedIndex = p3_fm;
	document.form_portcfg.port4_fcm.options.selectedIndex = p4_fm;

	pause_set("port0_fcm", p0_f);
	pause_set("port1_fcm", p1_f);
	pause_set("port2_fcm", p2_f);
	pause_set("port3_fcm", p3_f);
	pause_set("port4_fcm", p4_f);

	$("#port0_an").selectmenu("refresh");
	$("#port0_fc").selectmenu("refresh");
	$("#port0_fcm").selectmenu("refresh");
	$("#port1_an").selectmenu("refresh");
	$("#port1_fc").selectmenu("refresh");
	$("#port1_fcm").selectmenu("refresh");
	$("#port2_an").selectmenu("refresh");
	$("#port2_fc").selectmenu("refresh");
	$("#port2_fcm").selectmenu("refresh");
	$("#port3_an").selectmenu("refresh");
	$("#port3_fc").selectmenu("refresh");
	$("#port3_fcm").selectmenu("refresh");
	$("#port4_an").selectmenu("refresh");
	$("#port4_fc").selectmenu("refresh");
	$("#port4_fcm").selectmenu("refresh");

	setport0_reset('0');
	setport1_reset('0');
	setport2_reset('0');
	setport3_reset('0');
	setport4_reset('0');

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
	document.form_portcfg.action = "/goform/mcr_KTlogOut";
	document.form_portcfg.submit();
}

$(document).ready(function(){
	$("#port_name").change(function(){
		if(document.form_portcfg.port_name.value == "1"){
			$("#port_set_1").show();
			$("#port_set_2").hide();
			$("#port_set_3").hide();
			$("#port_set_4").hide();
			$("#port_set_5").hide();
		}
		if(document.form_portcfg.port_name.value == "2"){
			$("#port_set_1").hide();
			$("#port_set_2").show();
			$("#port_set_3").hide();
			$("#port_set_4").hide();
			$("#port_set_5").hide();
		}
		if(document.form_portcfg.port_name.value == "3"){
			$("#port_set_1").hide();
			$("#port_set_2").hide();
			$("#port_set_3").show();
			$("#port_set_4").hide();
			$("#port_set_5").hide();
		}
		if(document.form_portcfg.port_name.value == "4"){
			$("#port_set_1").hide();
			$("#port_set_2").hide();
			$("#port_set_3").hide();
			$("#port_set_4").show();
			$("#port_set_5").hide();
		}
		if(document.form_portcfg.port_name.value == "5"){
			$("#port_set_1").hide();
			$("#port_set_2").hide();
			$("#port_set_3").hide();
			$("#port_set_4").hide();
			$("#port_set_5").show();
		}
	});

});

function form_act(url){
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",20);
	form_portcfg.action = url;
	form_portcfg.submit();
	return false;
}

function setport1_reset(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_port1_reset('1');
			$("input[id='m_port1_reset']").attr("checked", true).checkboxradio("refresh");

			$("#port1_reset").val("1");
			break;
		case '0':       
			mcr_clickradio_port1_reset('0');
			$("input[id='m_port1_reset1']").attr("checked", true).checkboxradio("refresh");

			$("#port1_reset").val("0");
			break;
	}
}

function mcr_clickradio_port1_reset(val){
	$('label[for=m_port1_reset]').removeClass('ui-btn-active');
	$('label[for=m_port1_reset1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_port1_reset1]').addClass('ui-btn-active-c');
			$('label[for=m_port1_reset]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_port1_reset]').addClass('ui-btn-active-c');
			$('label[for=m_port1_reset1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setport2_reset(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_port2_reset('1');
			$("input[id='m_port2_reset']").attr("checked", true).checkboxradio("refresh");

			$("#port2_reset").val("1");
			break;
		case '0':       
			mcr_clickradio_port2_reset('0');
			$("input[id='m_port2_reset1']").attr("checked", true).checkboxradio("refresh");

			$("#port2_reset").val("0");
			break;
	}
}

function mcr_clickradio_port2_reset(val){
	$('label[for=m_port2_reset]').removeClass('ui-btn-active');
	$('label[for=m_port2_reset1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_port2_reset1]').addClass('ui-btn-active-c');
			$('label[for=m_port2_reset]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_port2_reset]').addClass('ui-btn-active-c');
			$('label[for=m_port2_reset1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setport3_reset(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_port3_reset('1');
			$("input[id='m_port3_reset']").attr("checked", true).checkboxradio("refresh");

			$("#port3_reset").val("1");
			break;
		case '0':       
			mcr_clickradio_port3_reset('0');
			$("input[id='m_port3_reset1']").attr("checked", true).checkboxradio("refresh");

			$("#port3_reset").val("0");
			break;
	}
}

function mcr_clickradio_port3_reset(val){
	$('label[for=m_port3_reset]').removeClass('ui-btn-active');
	$('label[for=m_port3_reset1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_port3_reset1]').addClass('ui-btn-active-c');
			$('label[for=m_port3_reset]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_port3_reset]').addClass('ui-btn-active-c');
			$('label[for=m_port3_reset1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setport4_reset(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_port4_reset('1');
			$("input[id='m_port4_reset']").attr("checked", true).checkboxradio("refresh");

			$("#port4_reset").val("1");
			break;
		case '0':       
			mcr_clickradio_port4_reset('0');
			$("input[id='m_port4_reset1']").attr("checked", true).checkboxradio("refresh");

			$("#port4_reset").val("0");
			break;
	}
}

function mcr_clickradio_port4_reset(val){
	$('label[for=m_port4_reset]').removeClass('ui-btn-active');
	$('label[for=m_port4_reset1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_port4_reset1]').addClass('ui-btn-active-c');
			$('label[for=m_port4_reset]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_port4_reset]').addClass('ui-btn-active-c');
			$('label[for=m_port4_reset1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setport0_reset(arg){
	switch(arg){
		case '1':       
			mcr_clickradio_port0_reset('1');
			$("input[id='m_port0_reset']").attr("checked", true).checkboxradio("refresh");

			$("#port0_reset").val("1");
			break;
		case '0':       
			mcr_clickradio_port0_reset('0');
			$("input[id='m_port0_reset1']").attr("checked", true).checkboxradio("refresh");

			$("#port0_reset").val("0");
			break;
	}
}

function mcr_clickradio_port0_reset(val){
	$('label[for=m_port0_reset]').removeClass('ui-btn-active');
	$('label[for=m_port0_reset1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_port0_reset1]').addClass('ui-btn-active-c');
			$('label[for=m_port0_reset]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_port0_reset]').addClass('ui-btn-active-c');
			$('label[for=m_port0_reset1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

</script>

</head>
<body onload="initValue()">
<form name="form_portcfg" data-ajax="false">

<input type="hidden" id="port0_reset" name="port0_reset" value="">
<input type="hidden" id="port1_reset" name="port1_reset" value="">
<input type="hidden" id="port2_reset" name="port2_reset" value="">
<input type="hidden" id="port3_reset" name="port3_reset" value="">
<input type="hidden" id="port4_reset" name="port4_reset" value="">

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
                                        포트 링크 설정
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
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td colspan="4" align="center">현재 상태</td>
			</tr>
			<tr>
				<td>포트이름</td>
				<td>Link</td>
				<td>Speed</td>
				<td>Duplex</td>
			</tr>
			<tr>
				<td>LAN1</td>
				<td><% mcr_getLanPortStatus(1,2); %></td>
				<td><% mcr_getLanPortStatus(1,4); %></td>
				<td><% mcr_getLanPortStatus(1,5); %></td>
			</tr>
			<tr>
				<td>LAN2</td>
				<td><% mcr_getLanPortStatus(2,2); %></td>
				<td><% mcr_getLanPortStatus(2,4); %></td>
				<td><% mcr_getLanPortStatus(2,5); %></td>
			</tr>
			<tr>
				<td>LAN3</td>
				<td><% mcr_getLanPortStatus(3,2); %></td>
				<td><% mcr_getLanPortStatus(3,4); %></td>
				<td><% mcr_getLanPortStatus(3,5); %></td>
			</tr>
			<tr>
				<td>LAN4</td>
				<td><% mcr_getLanPortStatus(4,2); %></td>
				<td><% mcr_getLanPortStatus(4,4); %></td>
				<td><% mcr_getLanPortStatus(4,5); %></td>
			</tr>
			<tr>
				<td>WAN</td>
				<td><% mcr_getLanPortStatus(0,2); %></td>
				<td><% mcr_getLanPortStatus(0,4); %></td>
				<td><% mcr_getLanPortStatus(0,5); %></td>
			</tr>
		</table>
	</div>
        <div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
	
			<tr>
				<td colspan="2" align="center">설정 상태</td>
			</tr>
			<tr id="PortName">
				<td align="left" width="35%">포트이름 선택</td>
				<td>
					<select name="port_name" class="input2" id="port_name" data-mini="true">
						<option selected="selected" value="1">LAN1</option>
						<option value="2">LAN2</option>
						<option value="3">LAN3</option>
						<option value="4">LAN4</option>
						<option value="5">WAN</option>
					</select>
				</td>
			</tr>
		</table>
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr id="port_set_1">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="left" width="35%">포트설정</td>
							<td>
								<select name="port1_an" class="input2" id="port1_an" data-mini="true">
									<option value="0">Port disable</option>
									<option selected="selected" value="1">Auto nego</option>
									<option value="2">1G full</option>
									<option value="3">100M full</option>
									<option value="4">100M half</option>
									<option value="5">10M full</option>
									<option value="6">10M half</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause설정</td>
							<td>
								<select name="port1_fc" class="input2" id="port1_fc" data-mini="ture" onchange="pause_set('port1_fcm',this.value);">
									<option selected="selected" value="0">비활성</option>
									<option value="1">활성</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause모드</td>
							<td>
								<select name="port1_fcm" class="input2" id="port1_fcm" data-mini="ture">
									<option selected="selected" value="0">없음</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
									<option value="3">수발신</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">포트 리셋</td>
							<td align="right">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_port1_reset">　활성　</label>
									<input type="radio" name="m_port1_reset" id="m_port1_reset" value="1" onclick="setport1_reset(this.value)">
									<label for="m_port1_reset1">　비활성　</label>
									<input type="radio" name="m_port1_reset" id="m_port1_reset1" value="0" checked="checked" onclick="setport1_reset(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="port_set_2" style="display:none">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="left" width="35%">포트설정</td>
							<td>
								<select name="port2_an" class="input2" id="port2_an" data-mini="true">
									<option value="0">Port disable</option>
									<option selected="selected" value="1">Auto nego</option>
									<option value="2">1G full</option>
									<option value="3">100M full</option>
									<option value="4">100M half</option>
									<option value="5">10M full</option>
									<option value="6">10M half</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause설정</td>
							<td>
								<select name="port2_fc" class="input2" id="port2_fc" data-mini="ture" onchange="pause_set('port2_fcm',this.value);">
									<option selected="selected" value="0">비활성</option>
									<option value="1">활성</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause모드</td>
							<td>
								<select name="port2_fcm" class="input2" id="port2_fcm" data-mini="ture">
									<option selected="selected" value="0">없음</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
									<option value="3">수발신</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">포트 리셋</td>
							<td align="right">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_port2_reset">　활성　</label>
									<input type="radio" name="m_port2_reset" id="m_port2_reset" value="1" onclick="setport2_reset(this.value)">
									<label for="m_port2_reset1">　비활성　</label>
									<input type="radio" name="m_port2_reset" id="m_port2_reset1" checked="checked" value="0" onclick="setport2_reset(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="port_set_3" style="display:none">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="left" width="35%">포트설정</td>
							<td>
								<select name="port3_an" class="input2" id="port3_an" data-mini="true">
									<option value="0">Port disable</option>
									<option selected="selected" value="1">Auto nego</option>
									<option value="2">1G full</option>
									<option value="3">100M full</option>
									<option value="4">100M half</option>
									<option value="5">10M full</option>
									<option value="6">10M half</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause설정</td>
							<td>
								<select name="port3_fc" class="input2" id="port3_fc" data-mini="ture" onchange="pause_set('port3_fcm',this.value);">
									<option selected="selected" value="0">비활성</option>
									<option value="1">활성</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause모드</td>
							<td>
								<select name="port3_fcm" class="input2" id="port3_fcm" data-mini="ture">
									<option selected="selected" value="0">없음</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
									<option value="3">수발신</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">포트 리셋</td>
							<td align="right">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_port3_reset">　활성　</label>
									<input type="radio" name="m_port3_reset" id="m_port3_reset" value="1" onclick="setport3_reset(this.value)">
									<label for="m_port3_reset1">　비활성　</label>
									<input type="radio" name="m_port3_reset" id="m_port3_reset1" checked="checked" value="0" onclick="setport3_reset(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="port_set_4" style="display:none">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="left" width="35%">포트설정</td>
							<td>
								<select name="port4_an" class="input2" id="port4_an" data-mini="true">
									<option value="0">Port disable</option>
									<option selected="selected" value="1">Auto nego</option>
									<option value="2">1G full</option>
									<option value="3">100M full</option>
									<option value="4">100M half</option>
									<option value="5">10M full</option>
									<option value="6">10M half</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause설정</td>
							<td>
								<select name="port4_fc" class="input2" id="port4_fc" data-mini="ture" onchange="pause_set('port4_fcm',this.value);">
									<option selected="selected" value="0">비활성</option>
									<option value="1">활성</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause모드</td>
							<td>
								<select name="port4_fcm" class="input2" id="port4_fcm" data-mini="ture">
									<option selected="selected" value="0">없음</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
									<option value="3">수발신</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">포트 리셋</td>
							<td align="right">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_port4_reset">　활성　</label>
									<input type="radio" name="m_port4_reset" id="m_port4_reset" value="1" onclick="setport4_reset(this.value)">
									<label for="m_port4_reset1">　비활성　</label>
									<input type="radio" name="m_port4_reset" id="m_port4_reset1" checked="checked" value="0" onclick="setport4_reset(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="port_set_5" style="display:none">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="left" width="35%">포트설정</td>
							<td>
								<select name="port0_an" class="input2" id="port0_an" data-mini="true">
									<option value="0">Port disable</option>
									<option selected="selected" value="1">Auto nego</option>
									<option value="2">1G full</option>
									<option value="3">100M full</option>
									<option value="4">100M half</option>
									<option value="5">10M full</option>
									<option value="6">10M half</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause설정</td>
							<td>
								<select name="port0_fc" class="input2" id="port0_fc" data-mini="ture" onchange="pause_set('port0_fcm',this.value);">
									<option selected="selected" value="0">비활성</option>
									<option value="1">활성</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">Pause모드</td>
							<td>
								<select name="port0_fcm" class="input2" id="port0_fcm" data-mini="ture">
									<option selected="selected" value="0">없음</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
									<option value="3">수발신</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="left" width="35%">포트 리셋</td>
							<td align="right">
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_port0_reset">　활성　</label>
									<input type="radio" name="m_port0_reset" id="m_port0_reset" value="1" onclick="setport0_reset(this.value)">
									<label for="m_port0_reset1">　비활성　</label>
									<input type="radio" name="m_port0_reset" id="m_port0_reset1" checked="checked" value="0" onclick="setport0_reset(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>

	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setPortLan')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#seventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
