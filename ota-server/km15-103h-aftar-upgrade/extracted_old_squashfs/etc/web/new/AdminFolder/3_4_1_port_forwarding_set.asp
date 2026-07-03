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

var MAX_RULES = 64;
var rules_num = <% mcr_getNatForwardRuleCount(2); %>;

var beforId = "menu00";

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

function onClickSelectAll(){
	for( var row = 0; row < rules_num; row++ ){
		var strElementName = "del_"+row;
		initCheckboxById(strElementName, "1");
	}
}

function CheckValue() {
	var i;
	var strUserInput ="";
	var sFromPort;
	var sToPort;
	var eFromPort;
	var eToPort;
	var iFromPort;
	var iToPort;
	var inerIp;
	var sndIp;
	var sndEndIp;
	var sndEndPort;
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
	var Endip = "<% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Snd");%>";
	var ip_add = "<%  mcr_getCfgInterface("LanDevice_IpAddress");%>";

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
		
		if(document.port_forward.tip_address.value == ip_add){
			alert("내부 IP주소 입력 오류입니다.");
			return false;
		}
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
		inerIp = document.port_forward.tip_address.value;
		sndIp = inerIp.split(".");
		sndEndIp = Endip.split(".");
		sndEndPort = parseInt(sndEndIp[3])+11000;
		if(sndIp[3] >= 128 ){
			if(document.port_forward.IfromPort.value >= 11131 && (document.port_forward.IfromPort.value < sndEndPort+1)){
				alert("SERVER를 위해 사용 중인 포트 입니다.(11131 ~"+ sndEndPort +")");
				return false;
			}
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
	document.port_forward.SETNATFWD_FLAG.value = 2;
	return true;
}

function form_act(url){
	if(url == "/goform/mcr_setNatforward") {
		if(!CheckValue())
			return false;
	}	
	port_forward.action = url;
	port_forward.submit();
	return false;
}

function changeBlur(chnagObj){
	chnagObj.parentElement.childNodes.item(2).value = chnagObj.parentElement.childNodes.item(0).value;
}

function changeTableAdmin() {
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");

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
<form method=post name="port_forward">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETNATFWD value="/new/AdminFolder/3_4_1_port_forwarding_set.asp" />
			<input type=hidden name=SETNATFWD_FLAG value="" />
			<table width="800" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table width="98%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5"> 포트 포워딩 설정</td>
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
														<td class="BG2" style="width:140px;">
															<p>소스 IP 주소</p>
														</td>
														<td class="BG2-2" width="600">
															<input name="sip_address" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="sip_address" maxlength=15/>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">
															<p>소스 포트</p>
														</td>
														<td class="BG2-2" width="600">
															<input name="SfromPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="SfromPort" maxlength=5 onblur="changeBlur(this)"/> 
															&nbsp;~ &nbsp;<input name="StoPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="StoPort" maxlength=5/>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">
															<p>외부 포트</p>
														</td>
														<td class="BG2-2" width="600">
															<input name="EfromPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="EfromPort" maxlength=5 onblur="changeBlur(this)"/> 
															&nbsp;~ &nbsp;<input name="EtoPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="EtoPort" maxlength=5/>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">
															<p>내부 IP 주소</p>
														</td>
														<td class="BG2-2" width="600">
															<input name="tip_address" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="tip_address" maxlength=15/> 
														</td>
													</tr>
											  		<tr>
														<td class="BG2" style="width:140px;">
															<p>내부 포트</p>
														</td>
														<td class="BG2-2" width="600">
															<input name="IfromPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="IfromPort" maxlength=5 onblur="changeBlur(this)"/> 
															&nbsp;~ &nbsp;<input name="ItoPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="ItoPort" maxlength=5/>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">
															<p>프로토콜</p>
														</td>
														<td class="BG2-2" width="600"><select name="protocol" class="input2" id="protocol">
															<option value="1">TCP</option>
															<option value="2">UDP</option>
															<option value="3">ALL</option>
															</select>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">
															<p>설명</p>
														</td>
														<td class="BG2-2" width="600"><input name="Description" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="Description" maxlength="22" /></td>
													</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td class="PD6">
												<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setNatforward'); return false;"/>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td><p align="right"></td>
							</tr>
							<tr>
								<td>

									<input type=hidden name=DELNATFWD value="/new/AdminFolder/3_4_1_port_forwarding_set.asp" />
									<table class="TB" width="98%" border="0">       
										<tr height="20">
											<td width="100%" >
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
															<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																<col width="35">
																<col width="90">
																<col width="80">
																<col width="80">
																<col width="90">
																<col width="80">
																<col width="80">
																<col width="155">
																<col>
		 
																<tr height="20">
																	<td class="BG1">
																		<p style="font-size:9pt; border-width:1px; border-style:none;">
																			선택
																		</p>
																	</td>
																	<td class="BG1">
																		<p>소스 IP 주소</p>
																	</td>
																	<td class="BG1">
																		<p>소스포트</p>
																	</td>
																	<td class="BG1">
																		<p>외부포트</p>
																	</td>
																	<td class="BG1">
																		<p>내부 IP 주소</p>
																	</td>
																	<td class="BG1">
																		<p>내부 포트</p>
																	</td>
																	<td class="BG1">
																		<p>프로토콜</p>
																	</td>
																	<td class="BG1">
																		<p>설명</p>
																	</td>
																	<td class="BG1">
																		<p>플래그</p>
																	</td>
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
											<td width="98%" valign="top">
												<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
												<table class="TB" id="Grid_Table" width="100%" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
													<col width="35">
													<col width="90">
													<col width="80">
													<col width="80">
													<col width="90">
													<col width="80">
													<col width="80">
													<col width="155">
													<col>

													<script language="JavaScript" type="text/javascript">
														var i,j;
														var all_str = "<% mcr_getNatForwardTable(); %>";

														if (all_str == "") {
															document.write("<tr bgcolor=#FFFFFF>");
															document.write("<td align=center colspan=8 id=vNatFwdListNone> <p>리스트가 없습니다</p> </td>");
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
																document.write("<input type=checkbox name=del_" + i + ">");
																document.write("</td>");

																for(j=0;j<8;j++) {
																	document.write("<td class=BG2-2>"); 
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
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="98%" border="0">
										<tr>			
											<td class="PD6">
												<p align="right"><input name="Apply1" type="image" src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_deleteNatforward'); return false;" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
