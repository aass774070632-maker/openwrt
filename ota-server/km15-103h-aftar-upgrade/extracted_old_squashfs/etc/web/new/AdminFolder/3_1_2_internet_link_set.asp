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
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
var netsel = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>"; 

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


function act(macaddr) {
	document.form.macCloneMac.value = macaddr;
}

function setSearchCtl(arg){
	switch(arg){
		case '2':	
			$("#tr_dhcpSetInfo").show();
			$("#tr_staticSetInfo").hide();
			$("#tr_dhcpConnInfo").show();
			break;
		case '1':	
			if(document.form.dns2ip_1.value == "0.0.0.0") {
				document.form.dns2ip_1.value = "168.126.63.2";
			}
			$("#tr_dhcpSetInfo").hide();
			$("#tr_staticSetInfo").show();
			$("#tr_dhcpConnInfo").hide();
			break;
	}
}

function setOpt60Ctl(arg){
	switch(arg){
		case '0':
			$("#tr_1").hide();
			break;
		case '1':
			$("#tr_1").show();
			break;
	}
}
function setOpt77Ctl(arg){
	switch(arg){
		case '0':
			$("#tr_2").hide();
			break;
		case '1':
			$("#tr_2").show();
			break;
	}
}

function setDnsCtl(arg){
	switch(arg){
		case '0':	
			$("#tr_dnsSetInfo1").hide();
			$("#tr_dnsSetInfo2").hide();
			break;
		case '1':	
			if(document.form.dns4ip_1.value == "0.0.0.0") {
				document.form.dns4ip_1.value = "168.126.63.2";
			}
			$("#tr_dnsSetInfo1").show();
			$("#tr_dnsSetInfo2").show();
			break;
	}
}

function setMacCtl(arg){
	switch(arg){
		case '1':	
			$("#view_macClone").show();
			$("#tr_macCloneMacRow").show();
			$("#tr_macCloneTitle").show();
			$("#tr_macCloneList").show();
			$("#MacCloneBnt").show();
			break;
		case '0':	
			$("#view_macClone").show();
			$("#tr_macCloneMacRow").hide();
			$("#tr_macCloneTitle").hide();
			$("#tr_macCloneList").hide();
			break;
	}
	changeTable();
}

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=760;
		parent.document.getElementById("menu").style.height=760;
	}
}

function setMacClone(url) {

	if(opmode == "0"){
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}
	if ( document.form.macCloneEnbl[0].checked == true)
	{
		if (document.form.macCloneMac.value != "") {
			var re = /[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}:[A-Fa-f0-9]{2}/;
			if (re.test(document.form.macCloneMac.value)) 
				runable(url);
			else {
				alert("Mac 입력형식 오류입니다");
				return false;
			}
		}
		else {
			alert("리스트에서 대상을 선택해 주세요");
			return false;
		}
	}
	else {
		runable(url);
	}
}

function CheckValue()
{
	$("input[name='dns1ip']").val($("input[name='dns1ip_1']").val());
	$("input[name='dns2ip']").val($("input[name='dns2ip_1']").val());
	$("input[name='dns3ip']").val($("input[name='dns3ip_1']").val());
	$("input[name='dns4ip']").val($("input[name='dns4ip_1']").val());

	if (document.form.connectionType[1].checked == true) {      
		if (!checkIpAddr(document.form.staticIp, false))
			return false;
		if (!checkIpAddr(document.form.staticNetmask, true))
			return false;
		if (!checkIpAddr(document.form.staticGateway, false))
			return false;
		if (document.form.dns1ip.value != "")
			if (!checkIpAddr(document.form.dns1ip, true))
				return false;
		if (document.form.dns2ip.value != "")
			if (!checkIpAddr(document.form.dns2ip, true))
				return false;
	}
	else if (document.form.connectionType[0].checked == true) { 
		if (document.form.option60.value != "") { 
			if (document.form.option60.value.length > 32) {
				alert("OPTION60 입력값을 32자 이내로 설정해 주세요");
				document.form.option60.focus();
				return false;
			}
		}
		if (document.form.option77.value != "") { 
			if (document.form.option77.value.length > 32) {
				alert("OPTION77 입력값을 32자 이내로 설정해 주세요");
				document.form.option77.focus();
				return false;
			}
		}
		if (document.form.wanDnsType[1].checked == true) {
			if (document.form.dns3ip.value != "")
				if (!checkIpAddr(document.form.dns3ip, true))
					return false;
			if (document.form.dns4ip.value != "")
				if (!checkIpAddr(document.form.dns4ip, true))
					return false;
		}
	}
	else
		return false;

	return true;
}

function setWan(url) {
	if (CheckValue()) {
		runable(url);	
	}
	return false;
}

function runable(url) {
	parent.mcrProgress.startProgressSimple("apply", 20);
	form.action = url;
	form.submit();
}

function initApp(){
	$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	var Dns_en = "<% mcr_getCfgString("UserManage_DnsCheck"); %>";
	var usbprio = "<% mcr_getCfgString("UsbTetheringInfo_Priority"); %>";

	parent.mcrProgress.stopProgress();

	{
		var contype = "<% mcr_getCfgInterface("WanDevice_WanConnType"); %>";
		var dnstype = "<% mcr_getCfgString("DnsCfgParam_Enable"); %>";

		var wanopt60_en = "<% mcr_getCfgString("WanDevice_Dhcp_Option60_Enable"); %>";
		var wanopt77_en = "<% mcr_getCfgString("WanDevice_Dhcp_Option77_Enable"); %>";

		switch(contype){
		case "DHCP":
			document.form.connectionType[0].checked = true;
			setSearchCtl("2");
			break;
		case "STATIC":
			document.form.connectionType[1].checked = true;
			setSearchCtl("1");
			break;
		default:
			break;
		}

		switch(wanopt60_en){
		case '0':
			document.form.wanOpt60_en[1].checked = true;
			setOpt60Ctl("0");
			break;
		case '1':
			document.form.wanOpt60_en[0].checked = true;
			setOpt60Ctl("1");
			break;
		default:
			break;
		}

		switch(wanopt77_en){
		case '0':
			document.form.wanOpt77_en[1].checked = true;
			setOpt77Ctl("0");
			break;
		case '1':
			document.form.wanOpt77_en[0].checked = true;
			setOpt77Ctl("1");
			break;
		default:
			break;
		}

		switch(dnstype){
		case '0':
			document.form.wanDnsType[0].checked = true;
			setDnsCtl("0");
			break;
		case '1':
			switch(contype){
			case "DHCP":
				document.form.wanDnsType[1].checked = true;
				setDnsCtl("1");
				break;
			case "STATIC":
				document.form.wanDnsType[0].checked = true;
				setDnsCtl("0");
				break;
			default:
				break;
			}
			break;
		default:
			break;
		}

		if (opmode == "1" && netsel == "1") {
			$("#tr_1").hide();
			$("#tr_2").hide();
		}
	}
	
	{
		var clone = "<% mcr_getCfgString("MacCloneCfgParam_Enable"); %>";
		var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";
		var repeater_en = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
		if ((opmode == "0") || (limit_cnt_en == "0") || (repeater_en != 0)) {
			$("input[id='macCloneEnbl']").attr('disabled',true);
			document.form.macCloneEnbl[1].checked = true;
			setMacCtl("0");	
		}else{	
			if(clone == "0") {
				document.form.macCloneEnbl[1].checked = true;
				document.form.macCloneMac.value = "";
				setMacCtl("0");	
			} else {
				document.form.macCloneEnbl[0].checked = true;
				setMacCtl("1");
			}
		}
	}
	
	{
		var vocenble = "<% mcr_getCfgString("VocCfgParam_Enable"); %>";

		switch(vocenble){
		case '0':
			document.form.voclocalenable[1].checked = true;
			break;
		case '1':
			document.form.voclocalenable[0].checked = true;
			break;
		default:
			break;
		}
	}
	
	{
		switch(Dns_en){
		case '0':
			$("input[id='wanDnsType']").attr('disabled',false);
			$("input[id='wanDnsType1']").attr('disabled',false);
			$("input[name='dns1ip_1']").attr('disabled',false);
			$("input[name='dns2ip_1']").attr('disabled',false);
			$("input[name='dns3ip_1']").attr('disabled',false);
			$("input[name='dns4ip_1']").attr('disabled',false);
			$("#dnsstate").text("");
			$("#dnsstate2").text("");
			break;
		case '1':
			$("input[id='connectionType1']").attr('disabled', true);
			$("input[id='wanDnsType']").attr('disabled', true);
			$("input[id='wanDnsType1']").attr('disabled', true);
			$("input[name='dns1ip_1']").attr('disabled', true);
			$("input[name='dns2ip_1']").attr('disabled', true);
			$("input[name='dns3ip_1']").attr('disabled', true);
			$("input[name='dns4ip_1']").attr('disabled', true);
			$("#dnsstate").text("※ DNS 값을 변경하시려면 유선으로 접속해 주시기 바랍니다.");
			$("#dnsstate2").text("※ DNS 값을 변경하시려면 유선으로 접속해 주시기 바랍니다.");
			break;
		default:
			break;
		}
	}

	if (usbprio != "0") {
		$("#tr_usbConnInfo").show();
	} else {
		$("#tr_usbConnInfo").hide();
	}

	changeTable();
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

<body onLoad="initApp()">
<form name="form">
<input type="hidden" id="dns1ip" name="dns1ip" value=""/>
<input type="hidden" id="dns2ip" name="dns2ip" value=""/>
<input type="hidden" id="dns3ip" name="dns3ip" value=""/>
<input type="hidden" id="dns4ip" name="dns4ip" value=""/>
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_1_menu3rd.asp');%>
		</td>
	</tr>
 
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top" >
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class='font5'> 코넷 인터넷 연결설정</td>
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
											<td colspan="2">
												<table border="0" cellpadding="0" cellspacing="0" class="font1" width="229">
													<tr>
														<td width="114">
															<input name="connectionType" type="radio" id="connectionType" value="2" OnClick="setSearchCtl(this.value)" />DHCP
														</td>
														<td id="td_staticip" style="display:inline float:left" width="114">
															<input name="connectionType" type="radio" id="connectionType1" value="1" OnClick="setSearchCtl(this.value)" />고정 IP
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id='tr_dhcpSetInfo' style="display:none">
								<td height="130" valign="top">
									<table class="TB" width="100%" border="0"> 
										<tr id="option_60" style="display:inline float:left">
											<td class="BG2" style="width:140px;">OPTION 60사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="wanOpt60_en" id="wanOpt60_en" value="1" OnClick="setOpt60Ctl(this.value)" />
															활성
														</td>
														<td>
															<input  type="radio" name="wanOpt60_en" id="wanOpt60_en1" value="0"  OnClick="setOpt60Ctl(this.value)" />
															비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tr_1">
											<td class="BG2" style="width:140px;">OPTION 60</td>
											<td class="BG2-2" width="600"><input name="option60" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="option60" value="<% mcr_getCfgString("WanDevice_Dhcp_Option60"); %>" size="21" />
											ex)KT_DE_HH_MERCURY_MODEL.
											</td>
										</tr>
										<tr id="option_77" style="display:inline float:left">
											<td class="BG2" style="width:140px;">OPTION 77사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="wanOpt77_en" id="wanOpt77_en" value="1" OnClick="setOpt77Ctl(this.value)" />
															활성
														</td>
														<td>
															<input  type="radio" name="wanOpt77_en" id="wanOpt77_en1" value="0"  OnClick="setOpt77Ctl(this.value)" />
															비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tr_2" style="display:none">
											<td class="BG2" style="width:140px;">OPTION 77 </td>
											<td class="BG2-2" width="600"><input name="option77" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="option77" value="<% mcr_getCfgString("WanDevice_Dhcp_Option77"); %>" />						
											ex)KT_DE_HH_D
											</td>
										</tr>
										<tr id = "tr_dnsInfo" style="display:inline float:left" >
											<td class="BG2" style="width:140px;">DNS 선택</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="wanDnsType" id="wanDnsType" value="0" OnClick="setDnsCtl(this.value)" />
															자동
														</td>
														<td>
															<input  type="radio" name="wanDnsType" id="wanDnsType1" value="1"  OnClick="setDnsCtl(this.value)" />
															수동　　　　　　　<label id="dnsstate"></label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
								  
										<tr ID ="tr_dnsSetInfo1" style="display:none">
											<td style="width:140px" height="10" class="BG2">기본 DNS</td>
											<td class="BG2-2" width="600">
												<input name="dns3ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns3ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Primary"); %> />
												ex)168.126.63.1
											</td>
										</tr>
										<tr ID ="tr_dnsSetInfo2" style="display:none">
											<td style="width:140px" height="10" class="BG2">보조 DNS</td>
											<td class="BG2-2" width="600"><input name="dns4ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns4ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Secondary"); %> />
											  ex)168.126.63.2
											</td>
										</tr>
									</table>					
								</td>
							</tr> 
							  
							<tr id="tr_staticSetInfo" style="display:none">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td class="BG2" style="width:140px;">IP 주소</td>
											<td class="BG2-2"><input name="staticIp" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticIp" value=<% mcr_getCfgInterface("WanDevice_IpAddress"); %> />
											  ex)192.168.10.32</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">서브넷마스크</td>
											<td class="BG2-2"><input name="staticNetmask" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticNetmask" value=<% mcr_getCfgInterface("WanDevice_SubNetMask"); %> />
											  ex)255.255.255.0</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게이트웨이</td>
											<td class="BG2-2"><input name="staticGateway" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticGateway" value=<% mcr_getCfgInterface("WanDevice_DefaultGw"); %> />
											  ex)192.168.10.254</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">기본 DNS</td>
											<td class="BG2-2"><input name="dns1ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns1ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Primary"); %> />
											  ex)168.126.63.1　　　　<label id="dnsstate2"></label>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">보조 DNS</td>
											<td class="BG2-2"><input name="dns2ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns2ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Secondary"); %> />
											  ex)168.126.63.1</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<p align="right">&nbsp;<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onclick="return setWan('/goform/mcr_setWan')" /></p></td>
								<td width="2%">
								</td>	
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td height="100">
						<table width="98%" border="0" cellspacing="0" cellpadding="0" id="tr_dhcpConnInfo">
							<tr>
								<td class="font5"> DHCP 연결정보</td>
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
											<td style="width:140px" class="BG2">IP 주소</td>
											<td colspan="3" class="BG2-2"><% mcr_getCfgInterface("WanDevice_IpAddress"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">서브넷마스크</td>
											<td width="25%" class="BG2-2"><% mcr_getCfgInterface("WanDevice_SubNetMask"); %></td>
											<td style="width:140px" class="BG2">기본 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("DnsCfgParam_Primary"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게이트웨이</td>
											<td class="BG2-2"><% mcr_getCfgInterface("WanDevice_DefaultGw"); %></td>
											<td class="BG2" style="width:140px;">보조 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("DnsCfgParam_Secondary"); %></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="470">
									<table width="98%" height="83" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">MAC Clone</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr id="view_macClone" style="display:none;">
														<td width="110">
															<input type='radio' name='macCloneEnbl' id='macCloneEnbl' value='1' OnClick="setMacCtl(this.value)" /> 활성
														</td>
														<td>
															<input type="radio" name="macCloneEnbl" id="macCloneEnbl1" value="0" OnClick="setMacCtl(this.value)" /> 비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td align="left">
												<table class="TB" width="438" border="0">       
													<tr id="tr_macCloneMacRow" style="display:none">
														<td width="102" class="BG2">
															<p>MAC  Clone 주소</p>
														</td>
														<td>
															<input type="text" id="macclone_fake" name="macclone_id_fake" autocomplete="off" style="display: none;">
															<input name="macCloneMac" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="macCloneMac" value="<% mcr_getCfgInterface("MacCloneCfgParam_LanMac"); %>" />
                                						</td>
													</tr>
												</table>
											</td>
										</tr>

										<tr id = "tr_macCloneTitle" style="display:none">
											<td>
												<table width="432" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
															<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																<col width="32">
																<col width="130">
																<col width="110">
																<col width="125">
																<col width="35">
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

										<tr id = "tr_macCloneList" height="106" style="display:none">
											<td width="100%" valign="top">
												<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
												<table class="TB" id="Grid_Table" width="432" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
													<col width="32" align="center">
													<col width="130">
													<col width="110">
													<col width="125">
													<col width="35" align="center">
													<%
														var i;
														var rule_num = mcr_getMacInfoCount(0);

														if (rule_num > 0) {
															for ( i = 0; i < rule_num; i++ ){
																write("<tr bgcolor=#FFFFFF>");
										
																write("<td class=BG2-2 style='padding-left:0px;' align='center'>");
																write("<input name=DR type=radio onClick=act(\""+mcr_getMacInfoList(i,2)+"\") >");
																write("</td>");
											
																write("<td class=BG2-2 style='word-break:break-all' align='center'>");
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
											</td>
										</tr>
										<tr id="MacCloneBnt">
											<td class="PD6">
												<p align="right">
													<input name='Apply' type='image' src='/images/BTN/BTN_01.gif?Sp2' alt='' width='52' height='24' onclick="setMacClone('/goform/mcr_setMacClone'); return false;">
												</p>
											</td>
										</tr>
									</table>
								</td>
								<td align="right" valign="top">
									<table width="98%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">인터넷 장애알림</td>
										</tr>
										<tr>
											<td class="PD4"></td>
										</tr>
										<tr>
											<td class="PD5"></td>
										</tr>
										<tr>
											<td>
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="voclocalenable" type="radio" id="voclocalenable1" value="1" />
															활성
														</td>
														<td>
															<input name="voclocalenable" type="radio" id="voclocalenable0" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="PD6">
												<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onclick="runable('/goform/mcr_setVocLocal');return false;" /></p>
											</td>
											<td width="4%">
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td height="100">
						<table width="98%" border="0" cellspacing="0" cellpadding="0" id="tr_usbConnInfo">
							<tr>
								<td class="font5"> USB WAN 연결정보</td>
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
											<td style="width:140px" class="BG2">IP 주소</td>
											<td colspan="3" class="BG2-2"><% mcr_getCfgInterface("UsbWanDevice_IpAddress"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">서브넷마스크</td>
											<td width="25%" class="BG2-2"><% mcr_getCfgInterface("UsbWanDevice_SubNetMask"); %></td>
											<td style="width:140px" class="BG2">기본 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("UsbWanDevice_Dns1"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게이트웨이</td>
											<td class="BG2-2"><% mcr_getCfgInterface("UsbWanDevice_DefaultGw"); %></td>
											<td class="BG2" style="width:140px;">보조 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("UsbWanDevice_Dns2"); %></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6">&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr style="display:none">
		<td>
			<input name="redirect_admWanSet" type="text" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_admWanSet" value="/new/AdminFolder/3_1_2_internet_link_set.asp"/>
		<td>
	</tr>
</table>
</form>
</body>
</html>
