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

</style>

<script language="javascript" type="text/javascript">

var arrData = new Array();
var MAX_RULES = 32;
var rules_num = <% mcr_getIPPortFilterRuleCount(2); %>

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
	document.form_filter.action = "/goform/mcr_KTlogOut";
	document.form_filter.submit();
}

function form_act(url){
	 if((url == "/goform/mcr_setipportFilter") || (url == "/goform/mcr_chgipportFilter")) {
		if(!CheckValue())
		return false;
	}
	if(url =="/goform/mcr_setipportFilter"){
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
	}else if(url == "/goform/mcr_chgipportFilter"){
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	}else{
		$('a[name=btn_apply3]').removeClass('ui-btn-active');
		$('a[name=btn_apply3]').addClass('ui-btn-active-a');
	}
	parent.mcrProgress.startProgressSimple("apply",5);
	form_filter.action = url;
	form_filter.submit();
	return false;
}

function CheckValue() {
	var i;
	var strUserInput ="";
	var sFromPort;
	var sToPort;
	var dFromPort;
	var dToPort;

	if(rules_num >= MAX_RULES ){
		alert("설정 정책이 초과되었습니다." + MAX_RULES +"." );
		return false;
	}
	if( document.form_filter.sip_address.value == "" &&
			document.form_filter.dip_address.value == "" &&
			document.form_filter.SfromPort.value == "" &&
			document.form_filter.DfromPort.value == "" ) {
		alert("설정 오류입니다. 값을 입력해 주세요");
		return false;
	}
	if(document.form_filter.protocol.value == "4") {
		if(document.form_filter.SfromPort.value != "" ||
				document.form_filter.DfromPort.value != "" ) {
			alert("설정 오류입니다. 포트는 입력하시면 안됩니다.");
			return false;
		}
	}
	else {
		if(document.form_filter.SfromPort.value == "" &&
				document.form_filter.DfromPort.value == "" ) {
			alert("설정 오류입니다. 포트를 입력해 주세요");
			return false;
		}
	}

	if(document.form_filter.sip_address.value != ""){
		if (!checkIpAddr(document.form_filter.sip_address, false))
			return false;
		if(document.form_filter.sip_address2.value != ""){
			if (!checkIpAddr(document.form_filter.sip_address2, false))
				return false;
		}
		else
			document.form_filter.sip_address2.value = document.form_filter.sip_address.value;

		if( (atoi(document.form_filter.sip_address.value, 1) > atoi(document.form_filter.sip_address2.value, 1)) || (atoi(document.form_filter.sip_address.value, 2) > atoi(document.form_filter.sip_address2.value, 2)) || (atoi(document.form_filter.sip_address.value, 3) > atoi(document.form_filter.sip_address2.value, 3)) || (atoi(document.form_filter.sip_address.value, 4) > atoi(document.form_filter.sip_address2.value, 4)) ) {
			alert("소스 IP 범위 입력 오류입니다.");
			return false;
		}
	}
	if(document.form_filter.SfromPort.value != ""){
		sFromPort = parseInt(document.form_filter.SfromPort.value);

		if (!checkPort(document.form_filter.SfromPort,false))
			return false;
		if(document.form_filter.StoPort.value != ""){
			if (!checkPort(document.form_filter.StoPort,false))
				return false;
		}
		else
			document.form_filter.StoPort.value = document.form_filter.SfromPort.value;

		sToPort = parseInt(document.form_filter.StoPort.value);

		if(sToPort && (sToPort < sFromPort)){
			alert("소스 포트 입력 오류입니다.");
			return false;
		}
	}
	if(document.form_filter.dip_address.value != ""){
		if (!checkIpAddr(document.form_filter.dip_address, false))
			return false;
		if(document.form_filter.dip_address2.value != ""){
			if (!checkIpAddr(document.form_filter.dip_address2, false))
				return false;
		}
		else
			document.form_filter.dip_address2.value = document.form_filter.dip_address.value;

		if( (atoi(document.form_filter.dip_address.value, 1) > atoi(document.form_filter.dip_address2.value, 1)) || (atoi(document.form_filter.dip_address.value, 2) > atoi(document.form_filter.dip_address2.value, 2)) || (atoi(document.form_filter.dip_address.value, 3) > atoi(document.form_filter.dip_address2.value, 3)) || (atoi(document.form_filter.dip_address.value, 4) > atoi(document.form_filter.dip_address2.value, 4)) ) {
			alert("목적지 IP 범위 입력 오류입니다.");
			return false;
		}
	}
	if(document.form_filter.DfromPort.value != ""){
		dFromPort = parseInt(document.form_filter.DfromPort.value);

		if (!checkPort(document.form_filter.DfromPort,false))
			return false;
		if(document.form_filter.DtoPort.value != ""){
			if (!checkPort(document.form_filter.DtoPort,false))
				return false;
		}
		else
			document.form_filter.DtoPort.value = document.form_filter.DfromPort.value;

		dToPort = parseInt(document.form_filter.DtoPort.value);

		if(dToPort && (dToPort < dFromPort)){
			alert("목적지 포트 입력 오류입니다.");
			return false;
		}
	}

	if(document.form_filter.sip_address.value != "") {
		if(document.form_filter.sip_address.value != document.form_filter.sip_address2.value)
			strUserInput+= document.form_filter.sip_address.value + ":" + document.form_filter.sip_address2.value +",";
		else
			strUserInput+= document.form_filter.sip_address.value +",";
	}
	else
		strUserInput+= ",";
	if(document.form_filter.SfromPort.value != ""){
		if(sFromPort != sToPort)
			strUserInput+= sFromPort + ":" + sToPort + ",";
		else
			strUserInput+= sFromPort + ",";
	} else
		strUserInput+= ",";

	if(document.form_filter.dip_address.value != "") {
		if(document.form_filter.dip_address.value != document.form_filter.dip_address2.value)
			strUserInput+= document.form_filter.dip_address.value + ":" + document.form_filter.dip_address2.value +",";
		else
			strUserInput+= document.form_filter.dip_address.value +",";
	} else
		strUserInput+= ",";
	if(document.form_filter.DfromPort.value != ""){
		if(dFromPort != dToPort)
			strUserInput+= dFromPort + ":" + dToPort + ",";
		else
			strUserInput+= dFromPort + ",";
	} else
		strUserInput+= ",";

	if(document.form_filter.protocol.value == "1")
		strUserInput+= "TCP,";
	else if(document.form_filter.protocol.value == "2")
		strUserInput+= "UDP,";
	else
		strUserInput+= "ALL,";
	for(i=0;i<rules_num;i++) {
		if( arrData[i].toString().indexOf(strUserInput) == 0 ) {
			alert("이미 등록되어 있습니다.");
			return false;
		}
	}
	return true;
}

function act(index){
	var entries;

	entries = arrData[index][0].split(":");
	if(entries.length == 1) {
		document.form_filter.sip_address.value = entries[0];
		document.form_filter.sip_address2.value = "";
	}
	else if(entries.length == 2) {
		document.form_filter.sip_address.value = entries[0];
		document.form_filter.sip_address2.value = entries[1];
	}
	else {
		document.form_filter.sip_address.value = "";
		document.form_filter.sip_address2.value = "";
	}
	entries = arrData[index][1].split(":");
	if(entries.length == 1) {
		document.form_filter.SfromPort.value = entries[0];
		document.form_filter.StoPort.value = "";
	}
	else if(entries.length == 2) {
		document.form_filter.SfromPort.value = entries[0];
		document.form_filter.StoPort.value = entries[1];
	}
	else {
		document.form_filter.SfromPort.value = "";
		document.form_filter.StoPort.value = "";
	}
	entries = arrData[index][2].split(":");
	if(entries.length == 1) {
		document.form_filter.dip_address.value = entries[0];
		document.form_filter.dip_address2.value = "";
	}
	else if(entries.length == 2) {
		document.form_filter.dip_address.value = entries[0];
		document.form_filter.dip_address2.value = entries[1];
	}
	else {
		document.form_filter.dip_address.value = "";
		document.form_filter.dip_address2.value = "";
	}
	entries = arrData[index][3].split(":");
	if(entries.length == 1) {
		document.form_filter.DfromPort.value = entries[0];
		document.form_filter.DtoPort.value = "";
	}
	else if(entries.length == 2) {
		document.form_filter.DfromPort.value = entries[0];
		document.form_filter.DtoPort.value = entries[1];
	}
	else {
		document.form_filter.DfromPort.value = "";
		document.form_filter.DtoPort.value = "";
	}

	if(arrData[index][4] == "TCP")
		document.form_filter.protocol.value = "1";
	else if(arrData[index][4] == "UDP")
		document.form_filter.protocol.value = "2";
	else
		document.form_filter.protocol.value = "4";

	if(arrData[index][5] == "차단")
		document.form_filter.Action.value = "1";
	else
		document.form_filter.Action.value = "2";

	document.form_filter.CHGACL.value = arrData[index][6];
}

</script>

</head>
<body>
<form method="post" name="form_filter" data-ajax="false">

<input type="hidden" name="SETACL" value="/new/mobile_03_5_2_packet_filter_set.asp">
<input type="hidden" name="DELACL" value="/new/mobile_03_5_2_packet_filter_set.asp">

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
					패킷 필터 설정
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
							<td>소스 IP 주소</td>
							<td>
								<input name="sip_address" type="text" id="sip_address" maxlength="15/">
							</td>
							<td> ~ </td>
							<td>
								<input name="sip_address2" type="text" id="sip_address2" maxlength="15/">
							</td>
						</tr>
						<tr>
							<td>소스포트</td>
							<td>
								<input name="SfromPort" type="text" id="SfromPort" maxlength="5/">
							</td>
							<td> ~ </td>
							<td>
								<input name="StoPort" type="text" id="StoPort" maxlength="5/">
							</td>
						</tr>
						<tr>
							<td>목적지 IP 주소</td>
							<td>
								<input name="dip_address" type="text" id="dip_address" maxlength="15/">
							</td>
							<td> ~ </td>
							<td>
								<input name="dip_address2" type="text" id="dip_address2" maxlength="15/">
							</td>
						</tr>
						<tr>
							<td>목적지포트</td>
							<td>
								<input name="DfromPort" type="text" id="DfromPort" maxlength="5/">
							</td>
							<td> ~ </td>
							<td>
								<input name="DtoPort" type="text" id="DtoPort" maxlength="5/">
							</td>
						</tr>
						<tr>
							<td>프로토콜</td>
							<td colspan="3">
								<select name="protocol" id="protocol" data-mini="true">
									<option value="1">TCP</option>
									<option value="2">UDP</option>
									<option value="4">ALL</option>
								</select>
							</td>
						</tr>
						<tr>
							<td>허용/차단</td>
							<td colspan="3">
								<select name="Action" id="Action" data-mini="true">
									<option value="2">허용</option>
									<option value="1">차단</option>
								</select>
							</td>
						</tr>
						<tr>
							<td colspan="2">
								<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return form_act('/goform/mcr_setipportFilter')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
							</td>
							<td colspan="2">
								<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_chgipportFilter')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">수정</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<col>
									<col>
									<tr>
										<td>선택</td>
										<td>번호</td>
										<td>소스 IP 주소</td>
										<td>소스포트</td>
									</tr>
								</span>
							</td>
						</tr>
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col>
									<col>
									<col>
									<col>
									<script language="JavaScript" type="text/javascript">
										var i,j;
										var all_str = "<% mcr_getIPPortFilterTable(); %>";

										if (all_str == "") {
											document.write("<tr>");
											document.write("<td align=center colspan=8 id=portCurrentFilterNone> 리스트가 없습니다 </td>");
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
												document.write("<input type=checkbox name=del_" + arrData[i][6] + " id=del_" + i + " onClick=act("+i+") data-role=none>");
												document.write("</td>");
												document.write("<td>");
												document.write(i+1);
												document.write("</td>");

												for(j=0;j<2;j++) {
													document.write("<td>"); document.write(arrData[i][j]); document.write("</td>");
												}
												document.write("</tr>\n");
											}
										}
									</script>
								</span>
							</td>
						</tr>
					</table>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title2" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<col>
									<col>
									<tr>
										<td>목적지 IP 주소</td>
										<td>목적지포트</td>
										<td>프로토콜</td>
										<td>허용/차단</td>
									</tr>
								</span>
							</td>
						</tr>
						<tr>
							<td>
								<span id="Grid_data2" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col>
									<col>
									<col>
									<col>
									<script language="JavaScript" type="text/javascript">
										var i,j;
										var all_str = "<% mcr_getIPPortFilterTable(); %>";

										if (all_str == "") {
											document.write("");
										}
										else {
											var entries = all_str.split(";");
											for(i=0; i<entries.length; i++){
												arrData[i] = entries[i].split(",");
											}

											for(i=0; i<entries.length; i++){
												document.write("<tr>");

												for(j=2;j<6;j++) {
													document.write("<td>"); document.write(arrData[i][j]); document.write("</td>");
												}
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
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="return form_act('/goform/mcr_deleteipportFilter')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="/mobile.asp#ninthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
