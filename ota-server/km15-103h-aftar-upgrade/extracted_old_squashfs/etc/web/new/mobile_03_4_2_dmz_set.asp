<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">
<%include('new/script.asp');%>

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

var MAX_RULES = 16;
var rules_num = <% mcr_getDmzExtRuleCount(2); %>;
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
var sdmz = <% mcr_getCfgString("NatTwinIpCfgParam_Enable"); %>;
var check_apply_dmz=0;

function CheckValue(){
	var sdmzcheck = <% mcr_getCfgString("NatTwinIpCfgParam_Enable"); %>;
	var GW_ip = "<% mcr_getCfgString("LanDevice_IpAddress"); %>";
	var dmz_ip = $("#dmzIp").val();

	if ($("#natDmz").val() == 1) { 
		if (opmode == "0"){ 
			alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
			return false;
		}
		if (!checkIpAddr(document.form_dmz.dmzIp, false))
			return false;
		if(dmz_ip == GW_ip){
			alert("G/W IP를 DMZ로 설정 할 수 없습니다.");
			return false;
		}
		if(sdmzcheck == "1"){
			var confirmed = confirm("설정 적용을 위해 리부팅 합니다. 리부팅 하시겠습니까?");
			if(!confirmed)
				return false;
			check_apply_dmz=1;
		}
	}
	else if ($("#natDmz").val() == 2) { 
		if (opmode == "0"){ 
			alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
			return false;
		}
		if (!CheckMac())
			return false;
		var confirmed = confirm("설정 적용을 위해 리부팅 합니다. 리부팅 하시겠습니까?");
		if(!confirmed)
			return false;
		check_apply_dmz=1;
	}
	else {
		if (opmode == "0"){ 
			alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
			return false;
		}

		if(sdmzcheck == "1"){
			var confirmed = confirm("설정 적용을 위해 리부팅 합니다. 리부팅 하시겠습니까?");
			if(!confirmed)
				return false;
			check_apply_dmz=1;
		}
	}


	return true;
}

function CheckMac(){
	var mac = $("#sdmzMac").val();
	if ( isEmpty(mac) == true ) {
		alert("타겟 MAC 주소를 입력해 주세요");
		return false;
	}

	if ( (isMacAddress(mac) == false) || (mac == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}
	return true;
}

function CheckValue2()
{
	var strUserInput ="";

	if (opmode == "0"){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}
	if (document.form_dmz.m_natDmz[1].checked) { 
		if(rules_num >= MAX_RULES ){
			alert("설정 정책이 초과되었습니다." + MAX_RULES +"." );
			return false;
		}
		if(document.form_dmz.extPort.value != "") {
			if (!checkPort(document.form_dmz.extPort,false))
				return false;
		}
		else {
			alert("포트를 입력해 주세요");
			return false;
		}

		if(document.form_dmz.extProto.value == "1")
			strUserInput+= "TCP,";
		else if(document.form_dmz.extProto.value == "2")
			strUserInput+= "UDP,";
		else if(document.form_dmz.extProto.value == "3")
			strUserInput+= "ALL,";

		if(document.form_dmz.extPort.value != "")
			strUserInput+= document.form_dmz.extPort.value +",";

		for(i=0;i<rules_num;i++) {
			if( arrData[i].toString().indexOf(strUserInput) == 0 ) {
				alert("이미 등록되어 있습니다.");
				return false;
			}
		}
	}
	return true;
}

function form_act(url){
	if(url == "/goform/mcr_setNatDmz") {
		if(!CheckValue())
			return false;
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
	}
	else if(url == "/goform/mcr_addNatExtPort") {
		if(!CheckValue2())
			return false;
		$('a[name=Apply1]').removeClass('ui-btn-active');
		$('a[name=Apply1]').addClass('ui-btn-active-a');
		check_apply_dmz=2;
	}else{
		$('a[name=Apply2]').removeClass('ui-btn-active');
		$('a[name=Apply2]').addClass('ui-btn-active-a');
		check_apply_dmz=2;
	}
	if(check_apply_dmz=="1")
                parent.mcrProgress.startProgressSimple("apply",50);
	else if(check_apply_dmz=="2")
                parent.mcrProgress.startProgressSimple("apply",10);
        else
                parent.mcrProgress.startProgressSimple("apply",5);

	form_dmz.action = url;
	form_dmz.submit();
	return false;
}

function act(macaddr) {
	document.form_dmz.sdmzMac.value = macaddr;
}

function changeDmz(){
	var nCheck = $(":input:radio[name=m_natDmz]:checked").val();

	if(nCheck == "1"){
		mcr_clickradio_Dmz('1');
		$("#tr_1").show();
		$("#tr_2").hide();
		$("#tr_4").hide();
		$("input:radio[name='DR']").removeAttr("checked");
		if(sdmz != 1)
			$("#sdmzMac").val("00:00:00:00:00:00");
		$("#natDmz").val("1");
	}else if(nCheck =="0"){
		mcr_clickradio_Dmz('0');
		$("#tr_1").hide();
		$("#tr_2").show();
		$("#tr_4").hide();
		$("input:radio[name='DR']").removeAttr("checked");
		if(sdmz != 1)
			$("#sdmzMac").val("00:00:00:00:00:00");
		$("#natDmz").val("0");
	}else{
		mcr_clickradio_Dmz('2');
		$("#tr_1").hide();
		$("#tr_2").show();
		$("#tr_4").show();
		$("#natDmz").val("2");

	}
}

function mcr_clickradio_Dmz(val){
	$('label[for=m_natDmz0]').removeClass('ui-btn-active');
	$('label[for=m_natDmz1]').removeClass('ui-btn-active');
	$('label[for=m_natDmz2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_natDmz0]').addClass('ui-btn-active-c');
			$('label[for=m_natDmz1]').removeClass('ui-btn-active-c');
			$('label[for=m_natDmz2]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_natDmz1]').addClass('ui-btn-active-c');
			$('label[for=m_natDmz0]').removeClass('ui-btn-active-c');
			$('label[for=m_natDmz2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_natDmz2]').addClass('ui-btn-active-c');
			$('label[for=m_natDmz0]').removeClass('ui-btn-active-c');
			$('label[for=m_natDmz1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function bridge_check(){
	if (opmode == "0"){ 
		$("input[id='m_natDmz0']").attr('disabled',true).checkboxradio("refresh");
		$("input[id='m_natDmz1']").attr('disabled',true).checkboxradio("refresh");
		$("input[id='m_natDmz2']").attr('disabled',true).checkboxradio("refresh");
		return true;
	}
	return false;
}

function initValue(){
	var dmz = <% mcr_getCfgString("NatDmzCfgParam_Enable"); %>;
	if(!bridge_check()){
		if(dmz == 1) {
			$("input[id='m_natDmz1']").attr("checked", true).checkboxradio("refresh");
		}
		else if(sdmz == 1){
			$("input[id='m_natDmz2']").attr("checked", true).checkboxradio("refresh");
		}else{
			$("input[id='m_natDmz0']").attr("checked", true).checkboxradio("refresh");
		}
	}
	changeDmz();
	
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
	document.form_dmz.action = "/goform/mcr_KTlogOut";
	document.form_dmz.submit();
}

</script>
</head>
<body onload="initValue()">
<form method="post" name="form_dmz" data-ajax="false">
<input type="hidden" name="SETDMZ" value="/new/mobile_03_4_2_dmz_set.asp">
<input type="hidden" name="ADDEXTDMZ" value="/new/mobile_03_4_2_dmz_set.asp">
<input type="hidden" name="DELEXTDMZ" value="/new/mobile_03_4_2_dmz_set.asp">

<input type="hidden" id="natDmz" name="natDmz" value="">

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
					DMZ 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px;" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>
	<div style="padding:0 5 5 5px;" data-role="fieldcontain">
		<fieldset data-role="controlgroup" data-type="horizontal">
			<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td>
						<label for="m_natDmz0"> 비활성</label>
						<input type="radio" name="m_natDmz" id="m_natDmz0" value="0" onclick="changeDmz()">
						<label for="m_natDmz1"> DMZ 활성</label>
						<input type="radio" name="m_natDmz" id="m_natDmz1" value="1" onclick="changeDmz()">
						<label for="m_natDmz2"> SuperDMZ 활성</label>
						<input type="radio" name="m_natDmz" id="m_natDmz2" value="2" onclick="changeDmz()">
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div id="tr_1" style="display:none; padding:0 5 5 5px;" data-role="fieldcontain">
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr height="10">
				<td colspan="2">
				</td>
			</tr>
			<tr>
				<td>DMZ 호스트 IP 주소</td>
				<td>
					<input name="dmzIp" type="text" id="dmzIp" maxlength="16" value="<% mcr_getCfgFirewall("NatDmzCfgParam_DestIp"); %>">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return form_act('/goform/mcr_setNatDmz')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
			</tr>
			<tr>
				<td>DMZ 예외 포트 추가</td>
				<td>
					<select id="extProto" name="extProto" data-mini="true">
						<option value="1">TCP</option>
						<option value="2">UDP</option>
						<option value="3">ALL</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input name="extPort" type="text" id="extPort" width="100%" maxlength="16" value="">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:;" id="Apply1" name="Apply1" onclick="return form_act('/goform/mcr_addNatExtPort')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
				</td>
			</tr>
		</table>
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>선택</td>
				<td>프로토콜</td>
				<td>포트 번호</td>
			</tr>
			<tr>
				<script language="JavaScript" type="text/javascript">
					var i,j;
					var all_str = "<% mcr_getNatDmzExtTable(); %>";

					if (all_str == "") {
						document.write("<tr>");
						document.write("<td colspan=3 align=center id=vNatDmzListNone> DMZ 예외포트 리스트가 없습니다 </td>");
						document.write("</tr>\n");
					}
					else {
						var entries = all_str.split(";");
						for(i=0; i<entries.length; i++){
							arrData[i] = entries[i].split(",");
						}

						for(i=0; i<entries.length; i++){
							document.write("<tr>");
							document.write("<td>");
							document.write("<input type=checkbox name=del_" + i + " data-role=none>");
							document.write("</td>");

							for(j=0;j<2;j++) {
								document.write("<td>");
								if( arrData[i][j] == null || arrData[i][j].length == 0 ){
									document.write("");
								}else{
									document.write(arrData[i][j]);
								}
									document.write("</td>");
							}
							document.write("</tr>\n");
						}
					}
				</script>
			</tr>
			<tr>
				<td colspan="3">
					<a href="javascript:;" id="Apply2" name="Apply2" onclick="return form_act('/goform/mcr_delNatExtPort')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
				</td>
			</tr>
		</table>
	</div>
	<div id="tr_4" style="display:none; padding:0 5 5 5px;" data-role="fieldcontain">
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>타겟 MAC 주소</td>
				<td>
					<input name="sdmzMac" type="text" id="sdmzMac" maxlength="17" value="<% mcr_getCfgFirewall("NatTwinIpCfgParam_TwinMac"); %>">
				</td>
			</tr>
		</table>
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr id="sdmzMacList">
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<col>
									<col>
									<col> 
									<tr>
										<td width="20%" align="center">
											<p>선택</p>
										</td>
										<td width="20%" align="center">
											<p>PC 이름</p>
										</td>
										<td width="20%" align="center">
											<p>IP 주소</p>
										</td>
										<td width="20%" align="center">
											<p>MAC 주소</p>
										</td>
										<td width="20%" align="center">
											<p>상태</p>
										</td>
									</tr>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col align="center"> 
									<col>
									<col>
									<col>
									<col align="center">

									<%
										var i;
										var rule_num = mcr_getMacInfoCount(3);

										if (rule_num > 0) {
											for ( i = 0; i < rule_num; i++ ){
												write("<tr>");

												write("<td align='center' width=20% style=word-break:break-all>");
												write("<input name=DR type=radio onClick=act(\""+mcr_getMacInfoList(i,2)+"\") data-role=none>");
												write("</td>");

												write("<td align='center' width=20% style=word-break:break-all>");
												write("<p>");write(mcr_getMacInfoList(i,0));write("</p>");
												write("</td>");

												write("<td align='center' width=20% style=word-break:break-all>");
												write("<p>");write(mcr_getMacInfoList(i,1));write("</p>");
												write("</td>");

												write("<td align='center' width=20% style=word-break:break-all>");
												write("<p>");write(mcr_getMacInfoList(i,2));write("</p>");
												write("</td>");

												write("<td align='center' width=20% style=word-break:break-all>");
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
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div id="tr_2" style="display:none; padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setNatDmz')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>

</form>
</body>
</html>
