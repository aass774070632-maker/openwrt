<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>
<%include('new/script.asp');%>
<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
a { font-style:normal; font-weight:normal; text-decoration:none; }
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	background-color: #ffffff;
}
-->
</style>
<script>
var arrData = new Array();
var MAX_RULES = 32;
var rules_num = <% mcr_getIPPortFilterRuleCount(2); %>;

var beforId = "menu01";

function mouseover(clickId){
	var obj = document.getElementById(clickId);
	obj.className="menu3rdMouse";

}

function mouseout(clickId)
{
	var obj = document.getElementById(clickId);
	if(beforId == clickId)
	{
		obj.className="menu3rdSelect";
	}
	else
	{
		obj.className="menu3rdNormal";
	}
}

function act(index)
{
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

function form_act(url){
	if((url == "/goform/mcr_setipportFilter") || (url == "/goform/mcr_chgipportFilter")) {
		if(!CheckValue())
			return false;
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	form_filter.action = url;
	form_filter.submit();
	return false;
}

function changeTableAdmin() {
	$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	parent.mcrProgress.stopProgress();				
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

var disable_tags=["input", "textarea", "select"];

disable_tags=disable_tags.join("|");

function disable_select(e){
	if (disable_tags.indexOf(e.target.tagName.toLowerCase())==-1)
		return false;
}

function reEnable(){
	return true;
}

if (typeof document.onselectstart!="undefined")
document.onselectstart=new Function ("return false;")
else{
	document.onmousedown=disable_select;
	document.onmouseup=reEnable;
}


document.oncontextmenu = function() {return false;};
document.onselectstart = function() {return false;};
document.ondragstart = function() {return false;};

function unlock() {
        document.oncontextmenu = null;
        document.onselectstart = null;
        document.ondragstart = null;
}

function lock() {
        document.oncontextmenu = function() {return false;};
        document.onselectstart = function() {return false;};
        document.ondragstart = function() {return false;};
}

</script>
</head>

<body onload="changeTableAdmin();">
<form method="post" name="form_filter">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_5_menu3rd.asp');%>
			</td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<input type="hidden" name="SETACL" value="/new/UserFolder/3_5_2_packet_filter_set.asp">
			<input type="hidden" name="CHGACL" value="">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">패킷 필터 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td class="BG2" style="width:140px;">소스 IP 주소</td>
											<td class="BG2-2" width="600">
												<input name="sip_address" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="sip_address" maxlength="15/">
												~
												<input name="sip_address2" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="sip_address2" maxlength="15/">
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">소스포트</td>
											<td class="BG2-2" width="600">
												<input name="SfromPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="SfromPort" maxlength="5/">
												~
												<input name="StoPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="StoPort" maxlength="5/">
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">목적지 IP 주소</td>
											<td class="BG2-2" width="600">
												<input name="dip_address" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dip_address" maxlength="15/">
												~
												<input name="dip_address2" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dip_address2" maxlength="15/">
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">목적지포트</td>
											<td class="BG2-2" width="600">
												<input name="DfromPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="DfromPort" maxlength="5/">
												~
												<input name="DtoPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="DtoPort" maxlength="5/">
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">프로토콜</td>
											<td class="BG2-2" width="600">
												<select name="protocol" class="input2" id="protocol">
													<option value="1">TCP</option>
													<option value="2">UDP</option>
													<option value="4">ALL</option>
												</select>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">허용/차단</td>
											<td class="BG2-2" width="600">
												<select name="Action" class="input2" id="Action">
													<option value="2">허용</option>
													<option value="1">차단</option>
												</select>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6">
						<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setipportFilter'); return false;"> 
							&nbsp;<input name="Apply1" type="image" src="/images/BTN/BTN_06.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_chgipportFilter'); return false;">
					</td>
				</tr>
				<tr>
					<td class="PD5">
						<p>&nbsp;</p>
					</td>
				</tr>
				<tr>
					<td class="PD5">
						<input type="hidden" name="DELACL" value="/new/UserFolder/3_5_2_packet_filter_set.asp">
						<table class="TB" width="98%" border="0">
							<tr height="20">
								<td width="100%">
									
									<table width="760" border="0" cellpadding="0" cellspacing="0" class="fix">
										<tr>
											<td>
											<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
											<table class="TB" width="100%" border="0" style="table-layout:fixed;">
											<col width="35">
											<col width="40"><!--번호-->
											<col width="190"><!--소스 IP 주소-->
											<col width="80"><!--소스포트-->
											<col width="190"><!--목적지 IP 주소-->
											<col width="80"><!--목적지포트-->
											<col width="70"><!--프로토콜-->
											<col width="70"><!--허용/차단-->
											<tr height="20">
													<tr height="20">
														<td class="BG1"><p style="font-size:9pt; border-width:1px; border-style:none;">선택</p></td>
														<td class="BG1">번호</td>
														<td class="BG1">소스 IP 주소</td>
														<td class="BG1">소스포트</td>
														<td class="BG1">목적지 IP 주소</td>
														<td class="BG1">목적지포트</td>
														<td class="BG1">프로토콜</td>
														<td class="BG1">허용/차단</td>
													</tr>
												</table>
												</span>
											</td>
											<td id="lastTD" style="display:none;">
												<table width="100%" border="0" cellpadding="0" cellspacing="0" style="table-layout:fixed;">
													<tr height="20" width="100%">
														<td class="BG1">&nbsp;</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
									
								</td>
							</tr>

							<tr height="210">
								<td width="100%" valign="top">
									<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<table class="TB" id="Grid_Table" width="760" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
									<col width="35">
									<col width="40"><!--번호-->
									<col width="190"><!--소스 IP 주소-->
									<col width="80"><!--소스포트-->
									<col width="190"><!--목적지 IP 주소-->
									<col width="80"><!--목적지포트-->
									<col width="70"><!--프로토콜-->
									<col width="70"><!--허용/차단-->

										<script language="JavaScript" type="text/javascript">
											var i,j;
											var all_str = "<% mcr_getIPPortFilterTable(); %>";

											if (all_str == "") {
												document.write("<tr bgcolor=#FFFFFF>");
												document.write("<td align=center colspan=8 id=portCurrentFilterNone> 리스트가 없습니다 </td>");
												document.write("</tr>\n");
											}
											else {
												var entries = all_str.split(";");
												for(i=0; i<entries.length; i++){
													arrData[i] = entries[i].split(",");
												}

												for(i=0; i<entries.length; i++){
													document.write("<tr bgcolor=#FFFFFF>");
													document.write("<td class=BG2-2>");
													document.write("<input type=checkbox name=del_" + arrData[i][6] + " id=del_" + i + " onClick=act("+i+")>");
													document.write("</td>");
													document.write("<td class=BG2-2 style=\"text-align: center; padding-left: 1px\">");
													document.write(i+1);
													document.write("</td>");

													for(j=0;j<6;j++) {
														document.write("<td class=BG2-2 style=\"text-align: center; padding-left: 1px\">"); document.write(arrData[i][j]); document.write("</td>");
													}
													document.write("</tr>\n");
												}
											}
										</script>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6">
						<p align="right"><input name="Apply2" type="image" src="/images/BTN/BTN_02.gif?Sp2" alt="" width="52" height="24" onclick="form_act('/goform/mcr_deleteipportFilter'); return false;">
					</td>
				</tr>
				<tr>
					<td class="PD5">
						<p align="right">　</p>
						<p>&nbsp;</p>
						<p align="right">&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</form>
</body>
</html>
