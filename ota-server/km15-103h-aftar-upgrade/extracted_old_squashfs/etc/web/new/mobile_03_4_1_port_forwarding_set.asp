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
</style>

<script language="javascript" type="text/javascript">
var arrData = new Array();
var MAX_RULES = 64;
var rules_num = <% mcr_getNatForwardRuleCount(2); %>;

function CheckValue() {
	var i;
	var strUserInput ="";
	var sFromPort;
	var sToPort;
	var eFromPort;
	var eToPort;
	var iFromPort;
	var iToPort;
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
	if (opmode == "0"){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}
	if(rules_num >= MAX_RULES ){
		alert("설정 정책이 초과되었습니다." + MAX_RULES +"." );
		return false;
	}
	if(document.port_forward.sip_address.value != ""){
		if (!checkIpAddr(document.port_forward.sip_address, false))
			return false;
	}
	if(document.port_forward.SfromPort.value != ""){
		sFromPort = parseInt(document.port_forward.SfromPort.value);

		if (!checkPort(document.port_forward.SfromPort,false))
			return false;
		if(document.port_forward.StoPort.value != ""){
			if (!checkPort(document.port_forward.StoPort,false))
				return false;
		}
		else
			document.port_forward.StoPort.value = document.port_forward.SfromPort.value;

		sToPort = parseInt(document.port_forward.StoPort.value);

		if(sToPort && (sToPort < sFromPort)){
			alert("소스 포트 입력 오류입니다.");
			return false;
		}
	}
	if(document.port_forward.EfromPort.value != ""){
		eFromPort = parseInt(document.port_forward.EfromPort.value);

		if (!checkPort(document.port_forward.EfromPort,false))
			return false;
		if(document.port_forward.EtoPort.value != ""){
			if (!checkPort(document.port_forward.EtoPort,false))
				return false;
		}
		else
			document.port_forward.EtoPort.value = document.port_forward.EfromPort.value;

		eToPort = parseInt(document.port_forward.EtoPort.value);

		if(eToPort && (eToPort < eFromPort)){
			alert("외부 포트 입력 오류입니다.");
			return false;
		}
	}
	else {
		alert("외부 포트를 입력해 주세요");
		return false;
	}
	if(document.port_forward.tip_address.value != ""){
		if (!checkIpAddr(document.port_forward.tip_address, false))
			return false;
	}
	else {
		alert("내부 IP 주소를 입력해 주세요");
		return false;
	}
	if(document.port_forward.IfromPort.value != ""){
		iFromPort = parseInt(document.port_forward.IfromPort.value);

		if (!checkPort(document.port_forward.IfromPort,false))
			return false;
		if(document.port_forward.ItoPort.value != ""){
			if (!checkPort(document.port_forward.ItoPort,false))
				return false;
		}
		else
			document.port_forward.ItoPort.value = document.port_forward.IfromPort.value;

		iToPort = parseInt(document.port_forward.ItoPort.value);
		if(iToPort && (iToPort < iFromPort)){
			alert("내부 포트 입력 오류입니다.");
			return false;
		}
	}
	if(document.port_forward.sip_address.value != "")
		strUserInput+= document.port_forward.sip_address.value +",";
	else
		strUserInput+= ",";
	if(document.port_forward.SfromPort.value != ""){
		if(sFromPort != sToPort)
			strUserInput+= sFromPort + ":" + sToPort + ",";
		else
			strUserInput+= sFromPort + ",";
	}
	else
		strUserInput+= ",";

	if(eFromPort != eToPort)
		strUserInput+= eFromPort + ":" + eToPort + ",";
	else
		strUserInput+= eFromPort + ",";
	strUserInput+= document.port_forward.tip_address.value +",";
	if(document.port_forward.IfromPort.value != "") {
		if(iFromPort != iToPort)
			strUserInput+= iFromPort + ":" + iToPort + ",";
		else
			strUserInput+= iFromPort + ",";
	}
	else
		strUserInput+= ",";

	if(document.port_forward.protocol.value == "1")
		strUserInput+= "TCP,";
	else if(document.port_forward.protocol.value == "2")
		strUserInput+= "UDP,";
	else
		strUserInput+= "ALL,";

	for(i=0;i<rules_num;i++) {
		if( arrData[i].toString().indexOf(strUserInput) == 0 ) {
			alert("이미 등록되어 있습니다.");
			return false;
		}
	}
	if(document.port_forward.Description.value=="") {
                alert("설명을 입력해 주세요");
                return false;
        }
	document.port_forward.SETNATFWD_FLAG.value = 1;
	return true;
}

function form_act(url){
	if(url == "/goform/mcr_setNatforward") {
		if(!CheckValue())
			return false;
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
		 parent.mcrProgress.startProgressSimple("apply",1);
	}else{
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
		 parent.mcrProgress.startProgressSimple("apply",5);
	}
	port_forward.action = url;
	port_forward.submit();
	return false;
}


function initValue() {
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
	document.port_forward.action = "/goform/mcr_KTlogOut";
	document.port_forward.submit();
}

</script>
</head>
<body onload="initValue()">
<form method="post" name="port_forward" data-ajax="false">
<input type="hidden" name="SETNATFWD" value="/new/mobile_03_4_1_port_forwarding_set.asp">
<input type="hidden" name="DELNATFWD" value="/new/mobile_03_4_1_port_forwarding_set.asp">
<input type="hidden" name="SETNATFWD_FLAG" value="">

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
					포트 포워딩 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div style="padding: 0 5 0 5px;">
		<table>
			<tr height="5"></tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<fieldset data-role="controlgroup">
			<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td width="30%">소스 IP 주소:</td>
					<td colspan="3">
						<input type="text" id="sip_address" name="sip_address" style="width:100%" class="input_r_t" value="" maxlength="15">
					</td>
				</tr>
				<tr>
					<td width="30%">소스 포트:</td>
					<td>
						<input type="text" id="SfromPort" name="SfromPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
					<td>~</td>
					<td>
						<input type="text" id="StoPort" name="StoPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
				</tr>
				<tr>
					<td width="30%">외부 포트:</td>
					<td>
						<input type="text" id="EfromPort" name="EfromPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
					<td>~</td>
					<td>
						<input type="text" id="EtoPort" name="EtoPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
				</tr>
				<tr>
					<td width="30%">내부 IP 주소:</td>
					<td colspan="3">
						<input type="text" id="tip_address" name="tip_address" style="width:100%" class="input_r_t" value="" maxlength="15">
					</td>
				</tr>
				<tr>
					<td width="30%">내부 포트:</td>
					<td>
						<input type="text" id="IfromPort" name="IfromPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
					<td>~</td>
					<td>
						<input type="text" id="ItoPort" name="ItoPort" style="width:100%" class="input_r_t" value="" maxlength="5">
					</td>
				</tr>
				<tr>
					<td width="30%">프로토콜:</td>
					<td colspan="3">
						<select id="protocol" name="protocol" data-mini="true"> 
							<option value="1">TCP</option>
							<option value="2">UDP</option>
							<option value="3">ALL</option>
						</select>
					</td>
				</tr>
				<tr>
					<td width="30%">설명:</td>
					<td colspan="3">
						<input type="text" id="Description" name="Description" style="width:100%" class="input_r_t" value="">
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return form_act('/goform/mcr_setNatforward')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<col>
									<col>
	
									<tr>
										<td width="25%" align="center" style="word-break:break-all">
											<p>
												선택
											</p>
										</td>
										<td width="25%" align="center" style="word-break:break-all">
											<p>소스 IP 주소</p>
										</td>
										<td width="25%" align="center" style="word-break:break-all">
											<p>소스포트</p>
										</td>
										<td width="25%" align="center" style="word-break:break-all">
											<p>외부포트</p>
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
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col>
									<col>
									<col>
									<col>

									<script language="JavaScript" type="text/javascript">
										var i,j;
										var all_str = "<% mcr_getNatForwardTable(); %>";
	
										if (all_str == "") {
											document.write("<tr>");
											document.write("<td align=center colspan=5 id=vNatFwdListNone> <p>리스트가 없습니다</p> </td>");
											document.write("</tr>\n");
										}
										else {
											var entries = all_str.split(";");
											for(i=0; i<entries.length; i++){
												arrData[i] = entries[i].split(",");
											}
	
											for(i=0; i<entries.length; i++){
												document.write("<tr>");
												document.write("<td width=25% align=center style=word-break:break-all>");
												document.write("<input type=checkbox name=del_" + i + " data-role=none>");
												document.write("</td>");
					
												for(j=0;j<3;j++) {
													document.write("<td width=25% align=center style=word-break:break-all>");
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
								</span>
							</td>
						</tr>
					</table>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title2" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<col>
									<col>
	
									<tr>
										<td width="20%" align="center" style="word-break:break-all">
											<p>내부 IP 주소</p>
										</td>
										<td width="20%" align="center" style="word-break:break-all">
											<p>내부 포트</p>
										</td>
										<td width="20%" align="center" style="word-break:break-all">
											<p>프로토콜</p>
										</td>
										<td width="20%" align="center" style="word-break:break-all">
											<p>설명</p>
										</td>
										<td width="20%" align="center" style="word-break:break-all">
											<p>플래그</p>
										</td>
									</tr>
								</span>
							</td>
						</tr>
					</table>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_data2" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col>
									<col>
									<col>
									<col>
									<col>

									<script language="JavaScript" type="text/javascript">
	
										if (all_str == "") {
											document.write("<tr>");
											document.write("<td align=center colspan=4> <p></p> </td>");
											document.write("</tr>\n");
										}
										else {
											for(i=0; i<entries.length; i++){
												document.write("<tr>");

												for(;j<7;j++) {
													document.write("<td width=20% align=center style=word-break:break-all>");
													if( arrData[i][j] == null || arrData[i][j].length == 0 ){
														document.write("");
													}else{
														document.write(arrData[i][j]);
													}
													document.write("</td>");
												}
												document.write("<td width=20% align=center style=word-break:break-all>");
												document.write(arrData[i][7]);
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
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_deleteNatforward')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
<form>
</body>
</html>
