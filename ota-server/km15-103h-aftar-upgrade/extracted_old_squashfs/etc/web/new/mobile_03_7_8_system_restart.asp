<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language='JavaScript' type='text/javascript' src='/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>

<style type="text/css">

.ui-btn-up-b {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #fff;
	text-shadow: 0 0px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
	background-image: -webkit-linear-gradient(#f16045,#ec2427);
	background-image: -moz-linear-gradient(#f16045,#ec2427);
	background-image: -ms-linear-gradient(#f16045,#ec2427);
	background-image: -o-linear-gradient(#f16045,#ec2427);
	background-image: linear-gradient(#f16045,#ec2427);
}

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
	document.sysRestart.action = "/goform/mcr_KTlogOut";
	document.sysRestart.submit();
}

function form_act(url){
	sysRestart.action = url;
	sysRestart.submit();
	return false;
}


function set_auto_restart(arg){
	changeAsr( arg )
	switch(arg){
		case '1':  
			mcr_clickradio__auto_restart('1');
			$("#Enable").val("1");
			break;
		case '0': 
			mcr_clickradio__auto_restart('0');
			$("#Enable").val("0");
			break;
	}
}

function mcr_clickradio__auto_restart(val){
	$('label[for=m_cycleenable1]').removeClass('ui-btn-active');
	$('label[for=m_cycleenable0]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_cycleenable0]').addClass('ui-btn-active-c');
			$('label[for=m_cycleenable1]').removeClass('ui-btn-active-c');
			$("input[id='m_cycleenable0']").attr("checked", true).checkboxradio("refresh");
			break;
		case '1':
			$('label[for=m_cycleenable1]').addClass('ui-btn-active-c');
			$('label[for=m_cycleenable0]').removeClass('ui-btn-active-c');
			$("input[id='m_cycleenable1']").attr("checked", true).checkboxradio("refresh");
			break;
		default:
			break;
	}
}

function initValue(){
	var resetEnable;
	resetEnable = '<% mcr_getCfgString("X_KT_PeriodicReset_Enable"); %>';
	set_auto_restart(resetEnable);
}

function form_act2(url){
	if(!CheckValue())
		return false;

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",5);
	form_asr.action = url;
	form_asr.submit();
	return false;
}

function CheckValue()
{
	if($("#Enable").val() == "1") {
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

	return true;
}

function changeAsr(enable) {
	if(enable == "1"){
		$("#AsrInterval").show();
		$("#AsrStartTime").show();
		$("#AsrDuringTime").show();
		$("#AsrUserExist").hide();
		$("#AsrUniCast").hide();
		$("#AsrSetTopUniCast").hide();
		$("#AsrSetTopIgmp").hide();
		$("#AsrWlanPacket").hide();
	}else{
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


$(document).ready(function(){
	initValue();
});

</script>

</head>
<body >
<form method="post" name="sysRestart" data-ajax="false">
<input type=hidden name=redirect_url value="/mobile_login.asp" />
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					시스템 재시동
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
		<a href="javascript:;" id="btn_apply3"  name="btn_apply3" onClick="form_act('/goform/mcr_setRestart'); return false;" data-theme="b" data-role="button"  data-mini="false" data-ajax="false">시스템 재시동</a>
	</div>
</form>	
<form method="post" name="form_asr" data-ajax="false">
	<input type=hidden name=redirect_url value="/new/mobile_03_7_8_system_restart.asp" />
	<input type="hidden" id="Enable" name="Enable" value=""/>

	<div style="padding:10px 0 0 0;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>자동 재시동</td>
				<td>
				<fieldset data-role="controlgroup" data-type="horizontal">
					<label for="m_cycleenable1">　활성　</label>
					<input name="m_cycleenable" type="radio" id="m_cycleenable1" value="1" OnClick="set_auto_restart(this.value)"/>
					<label for="m_cycleenable0">　비활성　</label>
					<input name="m_cycleenable" type="radio" id="m_cycleenable0" value="0" OnClick="set_auto_restart(this.value)"/>
				</fieldset>
				</td>
			</tr>
			<tr id = "AsrInterval" style="display:none">
				<td>재시동 주기(시간마다)</td>
				<td>
					<input name="Interval" type="text" id="Interval" size=10 value="<% mcr_getCfgString("X_KT_PeriodicReset_IntervalTime"); %>"/>
				</td>
			</tr>
			<tr id = "AsrStartTime" style="display:none">
				<td>재시동 시작 시간(시)</td>
				<td>
					<input name="StartTime" type="text" id="StartTime" maxlength="2" size="7" value="<% mcr_getCfgString("X_KT_PeriodicReset_StartTime"); %>"/>
				</td>
			</tr>
			<tr id = "AsrDuringTime" style="display:none">
				<td>재시동 시도 시간(시간마다)</td>
				<td>
					<input name="DuringTime" type="text" id="DuringTime" maxlength="2" size="7" value="<% mcr_getCfgString("X_KT_PeriodicReset_DuringTime"); %>"/>
				</td>
			</tr>
			<tr id = "AsrUserExist" style="display:none">
				<td>사용자 확인</td>
				<td>
					<input name="UserExist" type="text" id="UserExist" maxlength="1" size="7" value="<% mcr_getCfgString("X_KT_PeriodicReset_CpeStatusCondition"); %>"/>
				</td>
			</tr>
			<tr id = "AsrUniCast" style="display:none">
				<td>유선 UNICAST 사용 기준</td>
				<td>
					<input name="UniCast" type="text" id="UniCast" size="10" value="<% mcr_getCfgString("X_KT_PeriodicReset_Unicast_MAX"); %>"/>
				</td>
			</tr>
			<tr id = "AsrSetTopUniCast" style="display:none">
				<td>SETTOP UNICAST  사용 기준</td>
				<td>
					<input name="SetTopUniCast" type="text" id="SetTopUniCast" size="10" value="<% mcr_getCfgString("X_KT_PeriodicReset_Settop_MAX"); %>"/>
				</td>
			</tr>
			<tr id = "AsrSetTopIgmp" style="display:none">
				<td>SETTOP IGMP 사용 기준</td>
				<td>
					<input name="SetTopIgmp" type="text" id="SetTopIgmp" size="10" value="<% mcr_getCfgString("X_KT_PeriodicReset_Igmp_Count"); %>"/>
				</td>
			</tr>
			<tr id = "AsrWlanPacket" style="display:none">
				<td>무선 PACKET 사용 기준</td>
				<td>
					<input name="WlanPacket" type="text" id="WlanPacket" size="10" value="<% mcr_getCfgString("X_KT_PeriodicReset_Wireless_MAX"); %>"/>
				</td>
			</tr>
		</table>
	</div>
    	<div style="padding:0 0 0 0;">
		<a href="javascript:;" id="btn_apply2"  name="btn_apply2" onClick="return form_act2('/goform/mcr_setAsrConfig')" data-theme="a" data-role="button"  data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eleventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
