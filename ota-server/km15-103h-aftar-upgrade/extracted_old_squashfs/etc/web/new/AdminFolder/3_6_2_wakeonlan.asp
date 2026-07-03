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

function selectMenu3rd(){
	$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}
	
function changeTableAdmin() 
{
	selectMenu3rd();
			
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function CheckValue()
{
	var count=0;
	var f=document.form_wolset;
	var i=0;
	var UserList = document.getElementById("maxinfo").value;

	for(i=0; i<UserList; i++){
		if(eval("f.chk_"+i).checked == true){
			count++;
		}
	}

	if(count >1){
		alert("1개만 선택해 주세요.");
		return false;
	}
	if(count == 0){
		alert("대상리스트를 선택해 주세요.");
		return false;
	}

	return true;
}

function form_act(url)
{
	if(url == '/goform/mcr_setWolSnd'){
		if(!CheckValue()){
			return false;
		}
	}
	form_wolset.action = url;
	form_wolset.submit();
	return false;
}

function validateOnSubmit()
{
	var mac = document.getElementById("wol_mac");
	var pc = document.getElementById("wol_pc");
	var UserList = document.getElementById("maxinfo").value;
	if ( isEmpty(mac.value) == true ) {
		alert("MAC 주소를 입력해 주세요");
		return false;
	}

	if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}
	if ( isEmpty(pc.value) == true){
		alert("PC이름을 입력해 주세요");
		return false;
	}
	if(UserList >= 16){
		alert("최대 설정 개수입니다");
		return false;
	}

	return true;
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function act(macaddr,pcname) {
	document.form.wol_mac.value = macaddr;
	document.form.wol_pc.value = pcname;
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

function act_pcmac(macaddr) {
	document.form_woladd.wol_mac.value = macaddr;
	
}

function check_pcmac() {
	var f=document.form_woladd;
	var UserList = document.getElementById("cur_wol").value;
	var obj = document.getElementById('wol_height');

	if(f.wol_pcmac.checked == true){
		if(UserList > 10){	
			obj.style.height = "220px";
		}
		$("#wolList").show();
	}else{
		$("#wolList").hide();
	}
}

</script>


</head>

<body onload="changeTableAdmin();">
<form name="form_woladd"  action="/goform/mcr_addWol" onSubmit="return validateOnSubmit()">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_6_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="50" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">스마트 부팅 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">타겟 MAC 주소</td>
											<td class="BG2-2" width="600">
												<input name="wol_mac" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="wol_mac" maxlength="17" value="" onFocus="on_focus_clear('wol_mac')" /> 
												<input name="wol_pcmac" type="checkbox" id="wol_pcmac" value="" onClick="check_pcmac();" /> 
												현재 LAN 포트 접속된 PC
											</td>
										</tr>
										<tr id="wolList" height="20" style="display:none">
											<td class="PD6" colspan="2">
												<table width="300" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
																<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																	<col width="30">
																	<col width="130">
																	<tr height="20">
																		<td class="BG1">
																			<p style="font-size:9pt; border-width:1px; border-style:none;">
																				선택
																			</p>
																		</td>
																		<td class="BG1">
																			<p>MAC 주소</p>
																		</td>
																	</tr>
																</table>
															</span>
														</td>
													</tr>
													<tr id="wol_height">
														<td width="100%" valign="top">
															<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
																<table class="TB" id="Grid_Table" width="300" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
																	<col width="30" align="center"> 
																	<col width="130">
																	<%
																		var i;
																		var rule_num = mcr_getLanConnectBindInfo(0,0);
		
																		write("<input type=hidden id=cur_wol value=");write(rule_num);write(">");
																		if (rule_num > 0) {
																			for ( i = 0; i < rule_num; i++ ){
																				write("<tr bgcolor=#FFFFFF>");
																				write("<td class=BG2-2 style='padding-left:0px;' align='middle'>");
																				write("<input name=DR type=radio onClick=act_pcmac(\""+mcr_getLanConnectBindInfo(1,i)+"\") >");
																				write("</td>");
		
																				write("<td class=BG2-2>");
																				write("<p>");write(mcr_getLanConnectBindInfo(1,i));write("</p>");
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
											<td height="25" class="BG2" style="width:140px;">PC 이름</td>
											<td class="BG2-2" width="600">
												<input name="wol_pc" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="wol_pc" maxlength="32" value="" onFocus="on_focus_clear('wol_pc')" />
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

	<tr style="display:none">
		<td>
			<input name="redirect_url" type="hidden" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_url" value="/new/AdminFolder/3_6_2_wakeonlan.asp"/>
		</td>
	</tr>
	<tr>
		<td>
			<table width="96%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="PD6">									
						<input name="Apply" type="image" src="/images/BTN/BTN_03.gif?Sp2" alt="" width="52" height="24" />
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>

<form name="form_wolset">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<table class="TB" width="98%" border="0">
		<tr id="wolMacList" style="display:inline">
			<td class="PD6">
				<table class="TB" width="100%" border="0" cellspacing="1" cellpadding="10">
					<tr height="20">
						<td width="100%" >
							<table class="TB" width="20%" border="0">
								<tr>
									<td height="25" class="BG2" style="width:140px;">대상 리스트</td>
								</tr>
								<br>
							</table>
							<table width="764" border="0" cellpadding="0" cellspacing="0" class="fix">
								<tr>
									<td>
										<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
											<table class="TB" width="100%" border="0" style="table-layout:fixed;">
												<col width="100">
												<col width="200">
												<col width="460">
												<tr height="20">
													<td class="BG1">
														<p style="font-size:9pt; border-width:1px; border-style:none;">
														선택
														</p>
													</td>
													<td class="BG1">
														<p>MAC 주소</p>
													</td>
													<td class="BG1">
														<p>PC 이름</p>
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
								<tr>
									<td width="100%" valign="top">
										<span id="Grid_data1" align="center" style="height:100%;width:100%;">
											<table class="TB" id="Grid_Table" width="100%" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
												<col width="100" align="center"> 
												<col width="200">
												<col width="460">

													<%
														var i;
														var rule_num = mcr_getWolMacInfoCount();
														write("<input type=hidden id=maxinfo value=");write(rule_num);write(">");
														if (rule_num > 0) {
															for ( i = 0; i < rule_num; i++ ){
																write("<tr bgcolor=#FFFFFF>");
										
																write("<td class=BG2-2>");
																write("<input type=checkbox name=chk_" + i + ">");
																write("</td>");
															
																write("<td class=BG2-2>");
																write("<p>");write(mcr_getWolMacListSnd(i,0));write("</p>");
																write("</td>");
											
																write("<td class=BG2-2>");
																write("<p>");write(mcr_getWolMacListSnd(i,1));write("</p>");
																write("</td>");
										
																write("</tr>\n");
															}
														}
														else {
															write("<tr bgcolor=#FFFFFF>");
															write("<td colspan=3 align='center'>");
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
				</table>
			</td>
		</tr>

		<tr style="display:none">
			<td>
				<input name="redirect_url" type="hidden" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_url" value="/new/AdminFolder/3_6_2_wakeonlan.asp"/>
			</td>
		</tr>
		<tr>
			<td>
				<table width="98%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td class="PD6">									
							<input name="Apply1" type="image" src="/images/BTN/BTN_pc_on.gif" alt="" width="71" height="24" onclick="form_act('/goform/mcr_setWolSnd'); return false;"/>
							<input name="Apply2" type="image" src="/images/BTN/BTN_02.gif?Sp2" alt="" width="52" height="24" onclick="form_act('/goform/mcr_delWol'); return false;"/>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</table>
</form>

</body>
</html>
