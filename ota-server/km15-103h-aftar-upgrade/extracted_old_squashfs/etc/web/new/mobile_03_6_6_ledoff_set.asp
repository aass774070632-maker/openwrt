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
var arrData = new Array();

function remove_auth_cache() {
	if($.browser.msie) { 
		document.execCommand("ClearAuthenticationCache");
	}else{
		try{
			xml = new XMLHttpRequest();
			xml.open("GET", "PAGE FROM REALM TO LOGOUT", true, "", "logout"); 
			xml.send("");
			xml.abort();
		} catch(e) { return; }
	}
}

function logoff(){
	remove_auth_cache();
	document.form_ledoff.action = "/goform/mcr_KTlogOut";
	document.form_ledoff.submit();
}

function initValue(){
	var Enable = '<%mcr_getCfgString("LedOffCfgParam_Enable"); %>';

	if(Enable == '1'){
		$("input[id='m_ledoff_en1']").attr("checked", true).checkboxradio("refresh");
		$("#tr_1").show();
		$("#ManageList2").show();
		$("#ManageList2_1").show();
		$("#btn_apply3").show();
	}else{
		$("input[id='m_ledoff_en2']").attr("checked", true).checkboxradio("refresh");
		$("#tr_1").hide();
		$("#ManageList2").hide();
		$("#ManageList2_1").hide();
		$("#btn_apply3").hide();
	}

	changeLedOff();
}

function onClickAdd(){
	//var opmode = "<%mcr_getCfgString("SysOperMode_OperMode"); %>";
	var Enable = '<%mcr_getCfgString("LedOffCfgParam_Enable"); %>';
	var tStart_hour, tEnd_hour, tStart_min, tEnd_min;
	var ret = 0;

	if(form_ledoff.m_ledoff_en1.checked == true){
/*
		if(opmode == "0"){
			if(Enable == "0"){
				if(document.getElementById("m_ledoff_en1").value == "1"){
					alert("KT모드에서만 사용 가능합니다.");
					return false;
				}
			}
		}else
*/
		{
			tStart_hour = document.getElementById("timeStart_hour").value;
			tEnd_hour = document.getElementById("timeEnd_hour").value;
			tStart_min = document.getElementById("timeStart_min").value;
			tEnd_min = document.getElementById("timeEnd_min").value;

			ret = validateRangeById("timeStart_hour", 10, 0, 23, true);

			if(ret != 1){
				alert("설정 시간을 다시 확인해 주세요");
				return false;
			}else if(ret == 1){
				if(tStart_hour != "00"){
					if(tEnd_hour == "00" && tEnd_min == "00"){
						alert("시간 설정을 다시 확인해 주세요");
						return false;
					}
				}
			}
			ret = validateRangeById("timeEnd_hour", 10, 0, 24, true);
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			ret = validateRangeById("timeEnd_hour", 10, 0, 24, true);
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			ret = validateRangeById("timeStart_min", 10, 0, 59, true);
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			if(tEnd_hour == "24"){
				if((tStart_hour == "00") && (tStart_min == "00")){
					alert("시간 설정을 다시 확인해 주세요");
					return false;
				}
				ret = validateRangeById("timeEnd_min", 10, 0, 00, true);
				if(ret != 1){
					alert("시간 설정을 다시 확인해 주세요")
					return false;
				}
			}else{
				ret = validateRangeById("timeEnd_min", 10, 0, 59, true);
			}
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}

			tStart = parseInt(tStart_hour*60) + parseInt(tStart_min);
			tEnd = parseInt(tEnd_hour*60) + parseInt(tEnd_min);

		}
	}
	form_act('/goform/mcr_setLedOff');
	return false;
}

function form_act(url){
	if(CheckValue() == false){
		return false;
	}
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');

	 parent.mcrProgress.startProgressSimple("apply", 5);
	form_ledoff.action = url;
	form_ledoff.submit();
	return false;
}
function CheckValue(){
	return true;
}

function changeLedOff(){
	var nCheck = $(":input:radio[name=m_ledoff_en]:checked").val();

	$('label[for=m_ledoff_en1]').removeClass('ui-btn-active');
	$('label[for=m_ledoff_en2]').removeClass('ui-btn-active');
	
	if(nCheck == "1"){
		$('label[for=m_ledoff_en1]').addClass('ui-btn-active-c');
		$('label[for=m_ledoff_en2]').removeClass('ui-btn-active-c');
		$("#ledoff_en").val("1");
		$("#tr_1").show();
		$("#ManageList2").show();
		$("#ManageList2_1").show();
		$("#btn_apply3").show();
	}else{
		$('label[for=m_ledoff_en2]').addClass('ui-btn-active-c');
		$('label[for=m_ledoff_en1]').removeClass('ui-btn-active-c');
		$("#ledoff_en").val("0");
		$("#tr_1").hide();
		$("#ManageList2").hide();
		$("#ManageList2_1").hide();
		$("#btn_apply3").hide();
	}
		
}

function onClickDel(){
	form_act('/goform/mcr_delLedOff');
	return false;
}
</script>
</head>

<body onload="initValue()">
<form method="post" name="form_ledoff" data-ajax="false" action="/goform/mcr_setLedOff">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_6_6_ledoff_set.asp">

<input type="hidden" id="ledoff_en" name="ledoff_en" value="">

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
					LED OFF 시간 설정 
				</td>
				<td>
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
					<td width="30%">LED OFF 시간 설정</td>
					<td>
						<label for="m_ledoff_en1"> 　활성　</label>
						<input type="radio" name="m_ledoff_en" id="m_ledoff_en1" value="1" onclick="changeLedOff()">
						<label for="m_ledoff_en2"> 　비활성　</label>
						<input type="radio" name="m_ledoff_en" id="m_ledoff_en2" value="0" onclick="changeLedOff()">
					</td>
				</tr>
			</table>
		</fieldset>
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr id="tr_1">
					<td width="30%">시간 설정</td>
					<td>
						<input type="text" id="timeStart_hour" name="timeStart_hour" style="width:100%" class="input_r_t" value="" maxlength="2">
					</td>
					<td>:</td>
					<td>
						<input type="text" id="timeStart_min" name="timeStart_min" style="width:100%" class="input_r_t" value="" maxlength="2">
					</td>
					<td> ~ </td>
					<td>
						<input type="text" id="timeEnd_hour" name="timeEnd_hour" style="width:100%" class="input_r_t" value="" maxlength="2">
					</td>
					<td>:</td>
					<td>
						<input type="text" id="timeEnd_min" name="timeEnd_min" style="width:100%" class="input_r_t" value="" maxlength="2">
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return onClickAdd();" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				
				<tr>
					<td></td>
				</tr>
			</table>
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr id="ManageList2">
					<td style="font-weight:bold;">관리 리스트</td>
				</tr>
			</table>
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr id="ManageList2_1">
					<td>
						<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td>
									<span id="Grid_title1" align="center" style="width:100%; height=100%; overflow-x:hidden; overflow-y:hidden">
										<col>
										<col>
										<tr>
											<td width="30%">선택</td>
											<td width="70%">설정시간</td>
										</tr>
									</span>
								</td>
							</tr>
							<tr>
								<td>
									<span id="Grid_data1" align="center" style="height:100%; width:100%; overflow-x:no; overflow-y:auto">
										<col>
										<col>
										<script language="JavaScript" type="text/javascript">
											var i,j;
											var all_str = "<%mcr_getLedOff(); %>";
											var str=""
		
											if(all_str == ""){
												document.write("<tr>");
												document.write("<td align=center colspan=8 id=LedOffListNone> <p>리스트가 없습니다</p> </td>");
												document.write("</tr>\n");
											}else{
												var entries = all_str.split(";");
												for(i=0; i<entries.length-1; i++){
													arrData[i] = entries[i].split(",");
												}
												for(i=0; i<entries.length-1; i++){
													document.write("<tr>");
													document.write("<td>");
													document.write("<input type=checkbox name=del_" + i + " data-role=none>");
													document.write("</td>");
													document.write("<td>");
													
													for(j=0;j<4;j++) {
														if( arrData[i][j+1] == null || arrData[i][j+1].length == 0 ){
															document.write("");
														}else{
															str = str + arrData[i][j+1];
															if(j==0) str = str + ":";
															else if(j==1) str = str + " ~ ";
															else if(j==2) str = str + ":";
														}
													}
													document.write(str);
													document.write("</td>");
													document.write("</tr>\n");
												}
											}
										</script>
									</span>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="return form_act('/goform/mcr_delLedOff')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#seventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>

</div>
</form>
</body>
</html>
