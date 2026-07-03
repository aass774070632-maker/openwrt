<html>
<head>
<%include('new/metatag.asp');%>
<title>DMZ 설정</title>
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

var MAX_RULES = 16;
var rules_num = <% mcr_getDmzExtRuleCount(2); %>;
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";

var beforId = "menu01";
var sdmz = <% mcr_getCfgString("NatTwinIpCfgParam_Enable"); %>;

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

function CheckMac()
{
	var mac = document.getElementById("sdmzMac");
	if ( isEmpty(mac.value) == true ) {
		alert("타겟 MAC 주소를 입력해 주세요");
		return false;
	}

	if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}

	return true;
}

function CheckValue()
{
	var sdmzcheck = <% mcr_getCfgString("NatTwinIpCfgParam_Enable"); %>;	
	var GW_ip = "<% mcr_getCfgString("LanDevice_IpAddress"); %>";
	var dmz_ip = $("#dmzIp").val();

	if (document.form_dmz.natDmz[1].checked) { 
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
			if(!confirmed) {
				return false;
			}
			parent.mcrProgress.startProgressSimple("apply", 50);
		}else{
			parent.mcrProgress.startProgressSimple("apply", 15);
		}
	}
	else if (document.form_dmz.natDmz[2].checked) { 
		if (opmode == "0"){ 
			alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
			return false;
		}
		if (!CheckMac())
			return false;
		var confirmed = confirm("설정 적용을 위해 리부팅 합니다. 리부팅 하시겠습니까?");
		if(!confirmed)
			return false;
		parent.mcrProgress.startProgressSimple("apply", 50);
	}
	else {
		if(opmode == "0"){ 
			alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
			return false;
		}

		if(sdmzcheck == "1"){
			var confirmed = confirm("설정 적용을 위해 리부팅 합니다. 리부팅 하시겠습니까?");
			if(!confirmed)
				return false;
			parent.mcrProgress.startProgressSimple("apply", 50);
		} else {
			parent.mcrProgress.startProgressSimple("apply", 15);
		}
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

	if (document.form_dmz.natDmz[1].checked) { 
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

function initValue(){
	$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	var dmz = <% mcr_getCfgString("NatDmzCfgParam_Enable"); %>;
	parent.mcrProgress.stopProgress();
	changeTable();	
	if(opmode == "0"){
		$("input[id='natDmz0']").attr('disabled',true);
		$("input[id='natDmz1']").attr('disabled',true);
		$("input[id='natDmz2']").attr('disabled',true);
	}
	else{ 
		if(dmz == 1) {
			document.form_dmz.natDmz[1].checked = true;
		}
		else if(sdmz == 1) {
			document.form_dmz.natDmz[2].checked = true;
		}
		else
			document.form_dmz.natDmz[0].checked = true;
	}
	changeDmz();
}

function form_act(url){
	if(url == "/goform/mcr_setNatDmz") {
		if(!CheckValue())
			return false;
	}
	else if(url == "/goform/mcr_addNatExtPort") {
		if(!CheckValue2())
			return false;
	}

	form_dmz.action = url;
	form_dmz.submit();
	return false;
}

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function changeDmz(){
	if(form_dmz.natDmz[1].checked) {
		$("#tr_1").show();
		$("#tr_2").show();
		$("#tr_3").show();
		$("#tr_4").hide();
		$("#tr_5").hide();
		$("#tr_6").hide();
		$("input:radio[name='DR']").removeAttr("checked");
		if(sdmz != 1)
			$("#sdmzMac").val("00:00:00:00:00:00");
	}
	else if(form_dmz.natDmz[2].checked) {
		$("#tr_1").hide();
		$("#tr_2").hide();
		$("#tr_3").hide();
		$("#tr_4").show();
		$("#tr_5").show();
		$("#tr_6").show();
	}
	else if(form_dmz.natDmz[0].checked) {
		$("#tr_1").hide();
		$("#tr_2").hide();
		$("#tr_3").hide();
		$("#tr_4").hide();
		$("#tr_5").hide();
		$("#tr_6").hide();
		$("input:radio[name='DR']").removeAttr("checked");
		if(sdmz != 1)
			$("#sdmzMac").val("00:00:00:00:00:00");
	}
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function act(macaddr) {
	document.form_dmz.sdmzMac.value = macaddr;
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

<body onload="initValue();">
<form name="form_dmz">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETDMZ value="/new/AdminFolder/3_4_2_dmz_set.asp" />
			<table width="800" height="600" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td valign="top">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">DMZ 설정</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table width="100%" border="0" cellpadding="0" cellspacing="0">
													<tr>
														<td>
															<input name="natDmz" type="radio" id="natDmz0" value="0" OnClick="changeDmz()">
															비활성 
														</td>
														<td>
															<input type="radio" name="natDmz" id="natDmz1" value="1" OnClick="changeDmz()">
															DMZ 활성
														</td>
														<td>
															<input type="radio" name="natDmz" id="natDmz2" value="2" OnClick="changeDmz()">
															SuperDMZ 활성
														</td>
													</tr>
												</table>
											</td>
										</tr>

										<tr id = "tr_1" style="display:none">
											<td class="PD6">
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG2" width="200">DMZ 호스트 IP 주소</td>
														<td class="BG2-2" width="600">
															<table  border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="191"><input name="dmzIp" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dmzIp" maxlength="16" value=<% mcr_getCfgFirewall("NatDmzCfgParam_DestIp"); %> /></td>
																	<td >&nbsp;</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>

										<tr id = "tr_4" style="display:none">
											<td>
												<table class="TB" width="100%" border="0">
													<tr>
														<td height="25" class="BG2" width="200">타겟 MAC 주소</td>
														<td class="BG2-2" width="600">
															<input name="sdmzMac" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="sdmzMac" maxlength="17" style="width:120px;" value="<% mcr_getCfgFirewall("NatTwinIpCfgParam_TwinMac"); %>" />
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id = "tr_5" style="display:none">
											<td>
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr id="sdmzMacList">
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
															<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																<col width="50">
																<col width="240">
																<col width="200">
																<col width="200">
																<col width="70">
																<tr height="20">
																	<td class="BG1">
																		<p style="font-size:9pt; border-width:1px; border-style:none;">
																		선택
																		</p>
																	</td>
																	<td class="BG1">
																		<p>PC 이름</p>
																	</td>
																	<td class="BG1">
																		<p>IP 주소</p>
																	</td>
																	<td class="BG1">
																		<p>MAC 주소</p>
																	</td>
																	<td class="BG1">
																		<p>상태</p>
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
										<tr id = "tr_6" height="106" style="display:none">
											<td valign="top">
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_data1" align="center" style="height:400;width:100%; overflow:-moz-scrollbars-vertical; overflow-x:hidden; overflow-y:auto">
															<table class="TB" id="Grid_Table" width="760" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
																<col width="50" align="center"> 
																<col width="240">
																<col width="200">
																<col width="200">
																<col width="70" align="center"> 

																<%
																	var i;
																	var rule_num = mcr_getMacInfoCount(3);

																				if (rule_num > 0) {
																					for ( i = 0; i < rule_num; i++ ){
																						write("<tr bgcolor=#FFFFFF>");
														
																						write("<td class=BG2-2 style='padding-left:0px;' align='center'>");
																						write("<input name=DR type=radio onClick=act(\""+mcr_getMacInfoList(i,2)+"\") >");
																						write("</td>");
																		
																						write("<td class=BG2-2 style='padding-left:0px;' align='center'>");
																						write("<p>");write(mcr_getMacInfoList(i,0));write("</p>");
																						write("</td>");
																		
																						write("<td class=BG2-2 style='padding-left:0px;' align='center'>");
																						write("<p>");write(mcr_getMacInfoList(i,1));write("</p>");
																						write("</td>");
																		
																						write("<td class=BG2-2 style='padding-left:0px;' align='center'>"); 
																						write("<p>");write(mcr_getMacInfoList(i,2));write("</p>"); 
																						write("</td>");
															
																						write("<td class=BG2-2 style='padding-left:0px;' align='center'>"); 
																						write("<p>");write(mcr_getMacInfoList(i,3));write("</p>"); 
																						write("</td>");
																						write("</tr>\n");
																					}
																				}
																				else {
																					write("<tr bgcolor=#FFFFFF>");
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
											</td>
										</tr>

										<tr>
											<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setNatDmz'); return false;"/></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id = "tr_2" style="display:none">
								<td valign="top">
									<input type=hidden name=ADDEXTDMZ value="/new/AdminFolder/3_4_2_dmz_set.asp" />
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">DMZ 예외 포트</td>
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
														<td class="BG2" width="200">DMZ 예외 포트 추가</td>
														<td class="BG2-2" width="600">
															<table  border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="110">
																		<select name="extProto" class="input2" id="extProto">
																			<option value="1">TCP</option>
																			<option value="2">UDP</option>
																			<option value="3">ALL</option>
																		</select>
																	</td>
																	<td width="110" ><input name="extPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="extPort" /></td>
																	<td><input name="Apply1" type="image" src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_addNatExtPort'); return false;"/></td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td>　</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id = "tr_3" style="display:none">
								<td valign="top">
									<input type=hidden name=DELEXTDMZ value="/new/AdminFolder/3_4_2_dmz_set.asp" />
									<table class="TB" width="100%" border="0">
										<tr>
											<td class="BG1" width="46">선택</td>
											<td width="49%" class="BG1">프로토콜</td>
											<td width="45%" class="BG1">포트 번호</td>
										</tr>

										<script language="JavaScript" type="text/javascript">
											var i,j;
											var all_str = "<% mcr_getNatDmzExtTable(); %>";

											if (all_str == "") {
												document.write("<tr bgcolor=#FFFFFF>");
												document.write("<td colspan=3 align=center id=vNatDmzListNone> DMZ 예외포트 리스트가 없습니다 </td>");
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

													for(j=0;j<2;j++) {
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
									
									<div  align="right"><input name="Apply2" type="image" src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_delNatExtPort'); return false;"/></div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td valign="top">　</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
