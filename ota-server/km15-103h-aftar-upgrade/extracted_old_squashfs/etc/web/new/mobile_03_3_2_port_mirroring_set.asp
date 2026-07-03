<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
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
	document.form_mirror.action = "/goform/mcr_KTlogOut";
	document.form_mirror.submit();
}

function setPortCtl(arg){
	switch(arg){
		case '1':
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").hide();
			$("#tr_5").show();
			mir_en("1");
			break;
		case '0':
			$("#tr_1").hide();
			$("#tr_2").hide();
			$("#tr_3").hide();
			$("#tr_4").hide();
			$("#tr_5").hide();
			mir_en("0");
			break;
	}
}

function setModeCtl(arg){
	switch(arg){
		case '1':
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").hide();
			$("#tr_5").show();
			mir_mode("1");
			break;
		case '2':
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").hide();
			$("#tr_4").show();
			$("#tr_5").show();
			mir_mode("2");
			break;
		case '3':
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").show();
			$("#tr_5").show();
			mir_mode("3");
			break;

	}
}

function CheckValue()
{

	var mode = $("input[name='m_mirror_mode']:checked").val();
	var rxport = $("input[name='mirror_rx']:checked").val();
	var txport = $("input[name='mirror_tx']:checked").val();
	var monport = $("input[name='monitor']:checked").val();

	var mir_enable = $("#mirror_en").val();
	if(mir_enable == "0")
		return true;

	if(monport == "0") {
		if(mode == "1") {
			if( rxport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "0" || txport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "1") {
		if(mode == "1") {
			if( rxport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "1" || txport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "2") {
		if(mode == "1") {
			if( rxport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "2" || txport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "3") {
		if(mode == "1") {
			if( rxport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "3" || txport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	return true;
}

function mir_en(m_en){
	if(m_en =="0"){
		mcr_clickradio_mir_en('0');
		$("input[id='m_mirror_en2']").attr("checked", true).checkboxradio("refresh");
		$("#mirror_en").val("0");
	}
	else{
		mcr_clickradio_mir_en('1');
		$("input[id='m_mirror_en1']").attr("checked", true).checkboxradio("refresh");
		$("#mirror_en").val("1");
	}
}

function mcr_clickradio_mir_en(val){
	$('label[for=m_mirror_en1]').removeClass('ui-btn-active');
	$('label[for=m_mirror_en2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_mirror_en2]').addClass('ui-btn-active-c');
			$('label[for=m_mirror_en1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_mirror_en1]').addClass('ui-btn-active-c');
			$('label[for=m_mirror_en2]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function mir_mode(m_mode){
	if(m_mode =="1"){
		mcr_clickradio_mir_mode('1');
		$("input[id='m_mirror_mode0']").attr("checked", true).checkboxradio("refresh");
		$("#mirror_mode").val("1");
	}
	else if(m_mode=="2"){
		mcr_clickradio_mir_mode('2');
		$("input[id='m_mirror_mode1']").attr("checked", true).checkboxradio("refresh");
		$("#mirror_mode").val("2");
	}
	else{
		mcr_clickradio_mir_mode('3');
		$("input[id='m_mirror_mode2']").attr("checked", true).checkboxradio("refresh");
		$("#mirror_mode").val("3");
	}
}

function mcr_clickradio_mir_mode(val){
	$('label[for=m_mirror_mode0]').removeClass('ui-btn-active');
	$('label[for=m_mirror_mode1]').removeClass('ui-btn-active');
	$('label[for=m_mirror_mode2]').removeClass('ui-btn-active');
	switch(val){
		case '1':
			$('label[for=m_mirror_mode0]').addClass('ui-btn-active-c');
			$('label[for=m_mirror_mode1]').removeClass('ui-btn-active-c');
			$('label[for=m_mirror_mode2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_mirror_mode1]').addClass('ui-btn-active-c');
			$('label[for=m_mirror_mode0]').removeClass('ui-btn-active-c');
			$('label[for=m_mirror_mode2]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_mirror_mode2]').addClass('ui-btn-active-c');
			$('label[for=m_mirror_mode0]').removeClass('ui-btn-active-c');
			$('label[for=m_mirror_mode1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function initValue(){
	var m_en, m_mode, m_rx, m_tx, m_mon;

	m_en = '<% mcr_getCfgString("PortMirrorParam_Enable"); %>';
	m_mode = '<% mcr_getCfgString("PortMirrorParam_Mode"); %>';
	m_rx = '<% mcr_getCfgString("PortMirrorParam_RxPort"); %>';
	m_tx = '<% mcr_getCfgString("PortMirrorParam_TxPort"); %>';
	m_mon = '<% mcr_getCfgString("PortMirrorParam_MPort"); %>';


	mir_en(m_en);	

	if(m_mode == '0')
		m_mode = '1';

	mir_mode(m_mode);	

	initRadioByName("mirror_rx", m_rx);
	initRadioByName("mirror_tx", m_tx);
	initRadioByName("monitor", m_mon);

	if(m_en=='1')
		setModeCtl(m_mode);

}

function form_act(url){
	if(CheckValue() == false){
		return false;
	}
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",5);
	form_mirror.action = url;
	form_mirror.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form name="form_mirror" data-ajax="false">

<input type="hidden" id="mirror_en" name="mirror_en" value="">
<input type="hidden" id="mirror_mode" name="mirror_mode" value="">

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
                                        <img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px">
                                </td>
                                <td align="left" width="90%" style="font-weight:bold;">
                                        포트 미러링 설정
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
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td width="35%">포트미러링</td>
					<td>
						<label for="m_mirror_en1"> 　활성　</label>
						<input type="radio" name="m_mirror_en" id="m_mirror_en1" value="1" data-mini="true" onclick="setPortCtl(this.value)">
						<label for="m_mirror_en2"> 　비활성　</label>
						<input type="radio" name="m_mirror_en" id="m_mirror_en2" value="0" data-mini="true" onclick="setPortCtl(this.value)">
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr id="tr_1" style="display:none">
					<td width="35%">모드</td>
					<td colspan="4">
						<label for="m_mirror_mode0">　Rx　</label>
						<input type="radio" name="m_mirror_mode" id="m_mirror_mode0" value="1" data-mini="true" onclick="setModeCtl(this.value)">
						<label for="m_mirror_mode1">　Tx　</label>
						<input type="radio" name="m_mirror_mode" id="m_mirror_mode1" value="2" data-mini="true" onclick="setModeCtl(this.value)">
						<label for="m_mirror_mode2">　Rx and Tx　</label>
						<input type="radio" name="m_mirror_mode" id="m_mirror_mode2" value="3" data-mini="true" onclick="setModeCtl(this.value)">
					</td>
				</tr>

				<tr id="tr_2" style="display:none;" height="50">
					<td>　</td>
					<td align="center">LAN1</td>
					<td align="center">LAN2</td>
					<td align="center">LAN3</td>
					<td align="center">LAN4</td>
				</tr>
				<tr id="tr_3" style="display:none">
					<td valign="middle">Rx포트</td>
					<td align="center"><input type="radio" name="mirror_rx" id="mirror_rx" value="0" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_rx" id="mirror_rx1" value="1" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_rx" id="mirror_rx2" value="2" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_rx" id="mirror_rx3" value="3" data-role="none"></td>
				</tr>
				<tr id="tr_4" style="display:none">
					<td valign="middle">Tx포트</td>
					<td align="center"><input type="radio" name="mirror_tx" id="mirror_tx" value="0" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_tx" id="mirror_tx1" value="1" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_tx" id="mirror_tx2" value="2" data-role="none"></td>
					<td align="center"><input type="radio" name="mirror_tx" id="mirror_tx3" value="3" data-role="none"></td>
				</tr>
				<tr id="tr_5" style="display:none">
					<td valign="middle">미러 포트</td>
					<td align="center"><input type="radio" name="monitor" id="monitor" value="0" data-role="none"></td>
					<td align="center"><input type="radio" name="monitor" id="monitor1" value="1" data-role="none"></td>
					<td align="center"><input type="radio" name="monitor" id="monitor2" value="2" data-role="none"></td>
					<td align="center"><input type="radio" name="monitor" id="monitor3" value="3" data-role="none"></td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setPortMirror')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#seventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
