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
var opmode = <% mcr_getCfgString("SysOperMode_OperMode"); %>;
var netsel = <% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>;  

var beforId = "menu03";

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


function setLanCtl(arg){
	switch(arg){
		case '1':   
			$("#tr_1").show();
			if (opmode == 1 && netsel == 0) {
				$("#tr_3").show();
				$("#tr_1_1").show();
				$("#tr_1_2").hide();
			}
			else if(opmode == 1 && netsel == 1){
				$("#tr_1_1").hide();
				$("#tr_1_2").show();
				$("#tr_3").hide();
			}else{
				$("#tr_1_1").show();
				$("#tr_1_2").hide();
				$("#tr_3").hide();
			}
			$("#tr_2").show();
			break;
		case '0':	
			$("#tr_1").hide();
			$("#tr_3").hide();
			$("#tr_2").hide();
			$("#tr_1_1").hide();
			$("#tr_1_2").hide();
			break;
	}
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

function CheckValue() {
	if (opmode == 0){ 
		alert("브릿지 모드에서는 설정이 불가능한 기능입니다.");
		return false;
	}
	if (!checkIpAddr(document.form_lan.lanIp, false))
		return false;

	if (!checkIpAddr(document.form_lan.lanNetmask, true))
		return false;

	if (document.form_lan.lanDhcpType[0].checked == true) {
		if (!checkIpAddr(document.form_lan.dhcpStart, false))
			return false;
		if (!checkIpAddr(document.form_lan.dhcpEnd, false))
			return false;

		if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpStart.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpStart.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpStart.value, 3)) ) {
			alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
			return false;
		}
		if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpEnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpEnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpEnd.value, 3)) ) {
			alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
			return false;
		}

		if( (atoi(document.form_lan.lanIp.value,4) >= atoi(document.form_lan.dhcpStart.value, 4)) && (atoi(document.form_lan.lanIp.value,4) <= atoi(document.form_lan.dhcpEnd.value, 4)) ) {
			alert("LAN IP주소가 포함되지 않도록 입력해 주세요");
			return false;
		}

		if( (atoi(document.form_lan.dhcpStart.value, 1) > atoi(document.form_lan.dhcpEnd.value, 1)) 
				|| (atoi(document.form_lan.dhcpStart.value, 2) > atoi(document.form_lan.dhcpEnd.value, 2)) 
				|| (atoi(document.form_lan.dhcpStart.value, 3) > atoi(document.form_lan.dhcpEnd.value, 3)) 
				|| (atoi(document.form_lan.dhcpStart.value, 4) > atoi(document.form_lan.dhcpEnd.value, 4)) 
				|| (atoi(document.form_lan.dhcpStart.value, 4) < 1)
				|| (atoi(document.form_lan.dhcpEnd.value, 4) < 1) ) { 
			alert("DHCP 코넷 IP 범위 입력 오류입니다.");
			return false;
		}
		if (opmode == 1) {
			if( netsel == 0 && ((atoi(document.form_lan.dhcpStart.value, 4) > 127) 
						|| (atoi(document.form_lan.dhcpEnd.value, 4) > 127)) ) {
				alert("DHCP 코넷 IP 범위 입력 오류입니다.");
				return false;
			}
			else if( netsel !=0 && ((atoi(document.form_lan.dhcpStart.value, 4) > 252)
						|| (atoi(document.form_lan.dhcpEnd.value, 4) > 252)) ) {
				alert("DHCP 코넷 IP 범위 입력 오류입니다.");
				return false;
			}
		}

		if (opmode == 1 && netsel == 0) {
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpStartSnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpStartSnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpStartSnd.value, 3)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}
			if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.dhcpEndSnd.value, 1)) || (atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.dhcpEndSnd.value, 2)) || (atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.dhcpEndSnd.value, 3)) ) {
				alert("LAN IP주소와 같은 대역의 IP를 입력해 주세요");
				return false;
			}

			if( (atoi(document.form_lan.lanIp.value,4) >= atoi(document.form_lan.dhcpStartSnd.value, 4)) && (atoi(document.form_lan.lanIp.value,4) <= atoi(document.form_lan.dhcpEndSnd.value, 4)) ) {
				alert("LAN IP주소가 포함되지 않도록 입력해 주세요");
				return false;
			}

			if( (atoi(document.form_lan.dhcpStartSnd.value, 1) > atoi(document.form_lan.dhcpEndSnd.value, 1)) 
					|| (atoi(document.form_lan.dhcpStartSnd.value, 2) > atoi(document.form_lan.dhcpEndSnd.value, 2)) 
					|| (atoi(document.form_lan.dhcpStartSnd.value, 3) > atoi(document.form_lan.dhcpEndSnd.value, 3)) 
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) > atoi(document.form_lan.dhcpEndSnd.value, 4)) 
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) != 128) 
					|| (atoi(document.form_lan.dhcpEndSnd.value, 4) < 131) 
					|| (atoi(document.form_lan.dhcpStartSnd.value, 4) > 252) 
					|| (atoi(document.form_lan.dhcpEndSnd.value, 4) > 252) ) {
				alert("DHCP 프리미엄 IP 범위 입력 오류입니다.");
				return false;
			}
		}
	}
	return true;
}

function staticlease_checkIpAddr(field, ismask) {
	if (isAllNum(field.value) == 0) {
		field.value = field.defaultValue;
		field.focus();
		return false;
	}

	if (ismask) {
		if ((!checkRange(field.value, 1, 0, 256)) ||
				(!checkRange(field.value, 2, 0, 256)) ||
				(!checkRange(field.value, 3, 0, 256)) ||
				(!checkRange(field.value, 4, 0, 256)))
		{
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	else {
		if ((!checkRange(field.value, 1, 0, 255)) ||
				(!checkRange(field.value, 2, 0, 255)) ||
				(!checkRange(field.value, 3, 0, 255)) ||
				(!checkRange(field.value, 4, 1, 254)))
		{
			field.value = field.defaultValue;
			field.focus();
			return false;
		}
	}
	return true;
}

function ip_alloc_check()
{
	var ip3 = atoi(document.form_lan.staticlease_ip.value, 4);

	if (!staticlease_checkIpAddr(document.form_lan.staticlease_ip, false)) {
		return false;
	}

	if( (atoi(document.form_lan.lanIp.value, 1) != atoi(document.form_lan.staticlease_ip.value, 1)) || 
		(atoi(document.form_lan.lanIp.value, 2) != atoi(document.form_lan.staticlease_ip.value, 2)) || 
		(atoi(document.form_lan.lanIp.value, 3) != atoi(document.form_lan.staticlease_ip.value, 3)) ) 
	{
		return false;
	}

	if(atoi(document.form_lan.lanIp.value, 4) == atoi(document.form_lan.staticlease_ip.value, 4)) {
		return false;
	}

	if (opmode == 1 && netsel == 0) {
		if( ((atoi(document.form_lan.dhcpStart.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEnd.value, 4))) || 
			((atoi(document.form_lan.dhcpStartSnd.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEndSnd.value, 4)))) 
		{
			;
		} else {
			return false;
		}


	} else {
		if((atoi(document.form_lan.dhcpStart.value, 4) <= ip3) && (ip3 <= atoi(document.form_lan.dhcpEnd.value, 4))) {
			;
		} else {
			return false;
		}
	}

	return true;
}

function CheckStaticValue() {
	var mac = document.getElementById("staticlease_mac");
	var StaticMacCount = document.getElementById("maxinfo").value;
	var desc = document.getElementById("Description");

	if ( isEmpty(mac.value) == true ) {
		alert("MAC 주소를 입력해 주세요");
		return false;
	}
	if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}

	if(!ip_alloc_check()) {
		alert("IP 할당을 확인해 주세요.");
		return false;
	}

	if(StaticMacCount >= 10){
		alert("최대 설정 개수입니다");
		return false;
	}

	if ( isEmpty(desc.value) == true ) {
		alert("설명을 입력해 주세요.");
		return false;
	}

	return true;
}

function change_range(change_id, set_id){
	var i, rename;
	for(i=0; i<3; i++){
		rename=change_id+i;
		document.getElementById(rename).value = document.getElementById(set_id+i).value;
	}
}

function form_act(url){
	if(url == "/goform/mcr_setLan") {
		if(($("#lanIp0").val() != $("#dhcpStart0").val()) || ($("#lanIp1").val() != $("#dhcpStart1").val()) || ($("#lanIp2").val() != $("#dhcpStart2").val())){
			alert($("#lanIp0").val() + "." + $("#lanIp1").val() + "." + $("#lanIp2").val() + "대역으로 변경됩니다.");

			change_range("dhcpStart", "lanIp");
			change_range("dhcpEnd", "lanIp");
			change_range("dhcpStartSnd", "lanIp");
			change_range("dhcpEndSnd", "lanIp");
		}

		$("#lanIp").val($("#lanIp0").val() + "." + $("#lanIp1").val() + "." + $("#lanIp2").val() + "." + $("#lanIp3").val());
		$("#lanNetmask").val($("#lanNetmask0").val() + "." + $("#lanNetmask1").val() + "." + $("#lanNetmask2").val() + "." + $("#lanNetmask3").val());
		$("#dhcpStart").val($("#dhcpStart0").val() + "." + $("#dhcpStart1").val() + "." + $("#dhcpStart2").val() + "." + $("#dhcpStart3").val());
		$("#dhcpEnd").val($("#dhcpEnd0").val() + "." + $("#dhcpEnd1").val() + "." + $("#dhcpEnd2").val() + "." + $("#dhcpEnd3").val());
		$("#dhcpStartSnd").val($("#dhcpStartSnd0").val() + "." + $("#dhcpStartSnd1").val() + "." + $("#dhcpStartSnd2").val() + "." + $("#dhcpStartSnd3").val());
		$("#dhcpEndSnd").val($("#dhcpEndSnd0").val() + "." + $("#dhcpEndSnd1").val() + "." + $("#dhcpEndSnd2").val() + "." + $("#dhcpEndSnd3").val());

		if(!CheckValue())
			return false;
	}
	if (url == "/goform/mcr_addStaticLeases") {
		$("#lanIp").val($("#lanIp0").val() + "." + $("#lanIp1").val() + "." + $("#lanIp2").val() + "." + $("#lanIp3").val());
		$("#dhcpStart").val($("#dhcpStart0").val() + "." + $("#dhcpStart1").val() + "." + $("#dhcpStart2").val() + "." + $("#dhcpStart3").val());
		$("#dhcpEnd").val($("#dhcpEnd0").val() + "." + $("#dhcpEnd1").val() + "." + $("#dhcpEnd2").val() + "." + $("#dhcpEnd3").val());
		$("#dhcpStartSnd").val($("#dhcpStartSnd0").val() + "." + $("#dhcpStartSnd1").val() + "." + $("#dhcpStartSnd2").val() + "." + $("#dhcpStartSnd3").val());
		$("#dhcpEndSnd").val($("#dhcpEndSnd0").val() + "." + $("#dhcpEndSnd1").val() + "." + $("#dhcpEndSnd2").val() + "." + $("#dhcpEndSnd3").val());
		$("#staticlease_ip").val($("#staticlease_ip0").val() + "." + $("#staticlease_ip1").val() + "." + $("#staticlease_ip2").val() + "." + $("#staticlease_ip3").val());
		if(!CheckStaticValue()) {
			return false;
		}
	}

	parent.mcrProgress.startProgressSimple("apply", 30);
	form_lan.action = url;
	form_lan.submit();
	return false;
}

function ip_range_comment() {
	var kornet_ip = "<% mcr_getCfgInterface("DhcpsCfgParam_StartIp"); %>";
	var primium_ip = "<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Snd"); %>";
	var ipsub = new Array();
	var sub0, sub1, sub2;

	ipsub = kornet_ip.split(".");
	sub0 = parseInt(ipsub[0]);
	sub1 = parseInt(ipsub[1]);
	sub2 = parseInt(ipsub[2]);
	if (opmode == 1) {
		if(netsel == 0) 
			$('#kornet_ip_comment').html('최대 사용범위 : '+sub0+'.'+sub1+'.'+sub2+'.'+'1'+ ' ~ '+sub0+'.'+sub1+'.'+sub2+'.'+'127');
		else
			$('#kornet_ip_comment').html('최대 사용범위 : '+sub0+'.'+sub1+'.'+sub2+'.'+'1'+ ' ~ '+sub0+'.'+sub1+'.'+sub2+'.'+'252');
	}

	ipsub = primium_ip.split(".");
	sub0 = parseInt(ipsub[0]);
	sub1 = parseInt(ipsub[1]);
	sub2 = parseInt(ipsub[2]);
	$('#primium_ip_comment').html('최대 사용범위 : '+sub0+'.'+sub1+'.'+sub2+'.'+'128'+ ' ~ '+sub0+'.'+sub1+'.'+sub2+'.'+'252');
}

function ip_address_comment(ipaddress, name){
	var ipsub = new Array();
	var i,rename;

	ipsub = ipaddress.split(".");

	for(i=0; i<4; i++){
		rename=name+i;
		document.getElementById(rename).value = ipsub[i];
	}
}

function initValue() {
	var dhcp_en, dns_proxy, passthru_en;
	var ipaddress = "<% mcr_getCfgInterface("LanDevice_IpAddress"); %>";
	var subnetMask = "<% mcr_getCfgInterface("LanDevice_SubNetMask"); %>";
	var dhcpstart = "<% mcr_getCfgInterface("DhcpsCfgParam_StartIp"); %>";
	var dhcpend = "<% mcr_getCfgInterface("DhcpsCfgParam_EndIp"); %>";
	var dhcpstartsnd = "<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Snd"); %>";
	var dhcpendsnd = "<% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Snd"); %>";


	$("#menu03").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	parent.mcrProgress.stopProgress();

	dhcp_en = '<% mcr_getCfgString("DhcpsCfgParam_Enable"); %>';
	dns_proxy = '<% mcr_getCfgString("DnsProxyCfgParam_Enable"); %>';

	if(netsel == 1 && opmode == 0){
		document.form_lan.lanDhcpType[1].checked = true;
	}else{
		initRadioByName("lanDhcpType", dhcp_en);
	}
	initRadioByName("dnsproxyenable", dns_proxy);

	setLanCtl(dhcp_en);

	
	ip_address_comment(ipaddress, "lanIp");
	ip_address_comment(subnetMask, "lanNetmask");
	ip_address_comment(dhcpstart, "dhcpStart");
	ip_address_comment(dhcpend, "dhcpEnd");
	ip_address_comment(dhcpstartsnd, "dhcpStartSnd");
	ip_address_comment(dhcpendsnd, "dhcpEndSnd");
	change_range("staticlease_ip", "lanIp");
	document.getElementById("staticlease_ip3").value = "";

	if(dhcp_en == "1") {
		$("#staticlease").show();
	} else {
		$("#staticlease").hide();
	}

	changeTable();
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function act_mac(macaddr) {
	document.form_lan.staticlease_mac.value = macaddr;
}

function check_mac() {
	var f=document.form_lan;
	var UserList = document.getElementById("cur_staticlease").value;
	var obj = document.getElementById("staticlease_height");

	if(f.staticlease_pcmac.checked == true){
		if(UserList > 10){
			obj.style.height = "220px";
		}
		$("#pcList").show();
	}else{
		$("#pcList").hide();
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


<body onload="initValue()">
<form name="form_lan" id="form_lan">
<input type="hidden" name="SETLAN" value="/new/UserFolder/3_1_4_lan_link_set.asp">
<input type="hidden" id="lanIp" name="lanIp" value="">
<input type="hidden" id="lanNetmask" name="lanNetmask" value="">
<input type="hidden" id="dhcpStart" name="dhcpStart" value="">
<input type="hidden" id="dhcpEnd" name="dhcpEnd" value="">
<input type="hidden" id="dhcpStartSnd" name="dhcpStartSnd" value="">
<input type="hidden" id="dhcpEndSnd" name="dhcpEndSnd" value="">
<input type="hidden" id="staticlease_ip" name="staticlease_ip" value="" />

<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_1_menu3rd.asp');%>
            		</td>
	</tr>
 
	<tr>
		<td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="100%" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td> 
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td> 
									<table width="98%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td colspan="2" class="font5"> LAN 연결 설정</td>
										</tr>
										<tr>
											<td colspan="2" class="PD4"></td>
										</tr>
										<tr>
											<td colspan="2" class="PD5"></td>
										</tr>
										<tr>
											<td colspan="2">
												
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG2" style="width:160px;">IP 주소</td>
														<td class="BG2-2" width="600">
<input name="lanIp0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanIp0">.
<input name="lanIp1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanIp1">.
<input name="lanIp2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanIp2">.
<input name="lanIp3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanIp3">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:160px;">서브넷마스크</td>
														<td class="BG2-2" width="600">
<input name="lanNetmask0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanNetmask0" disabled>.
<input name="lanNetmask1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanNetmask1" disabled>.
<input name="lanNetmask2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanNetmask2" disabled>.
<input name="lanNetmask3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="lanNetmask3">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:160px;">DHCP 서버</td>
														<td class="BG2-2" width="600">
															<table border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="110">
																		<input type="radio" name="lanDhcpType" id="lanDhcpType" value="1" onclick="setLanCtl(this.value)">
																		활성
																	</td>
																	<td>
																		<input name="lanDhcpType" type="radio" id="lanDhcpType1" value="0" onclick="setLanCtl(this.value)">
																		비활성 
																	</td>
																</tr>
															</table>
														</td>
													</tr>
													<tr id="tr_1">
														<td class="BG2" style="width:160px;">DHCP 코넷 IP 사용범위</td>
														<td>
															<table border="0" cellspacing="0" cellpadding="0" bgcolor="#EEECE1" width="100%">
																<tr>
																	<td class="BG2-2">
																		<input name="dhcpStart0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStart0" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStart1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStart1" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStart2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStart2" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStart3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStart3"> 
																	</td>
																	<td class="BG2-2">~</td>
																	<td class="BG2-2">
																		<input name="dhcpEnd0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEnd0" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEnd1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEnd1" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEnd2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEnd2" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEnd3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEnd3">
																	</td>
																	<td>
																	</td>
																</tr>
																<tr id="tr_1_1">
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">1~</td>
																	<td class="BG2-2"></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">~127</td>
																	<td width="100%"></td>
                                                                                                                                </tr>
																<tr id="tr_1_2">
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">1~</td>
																	<td class="BG2-2"></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">~252</td>
																	<td width="100%"></td>
                                                                                                                                </tr>
															</table>
														</td>
													</tr>
													<tr id="tr_3">
														<td class="BG2" style="width:160px;">DHCP 프리미엄 IP 사용범위</td>
														<td>
															<table border="0" cellspacing="0" cellpadding="0" bgcolor="#EEECE1" width="100%">
																<tr>
																	<td class="BG2-2">
																		<input name="dhcpStartSnd0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStartSnd0" disabled> 
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStartSnd1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStartSnd1" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStartSnd2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStartSnd2" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpStartSnd3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpStartSnd3"> 
																	</td>
																	<td class="BG2-2">~</td>
																	<td class="BG2-2">
																		<input name="dhcpEndSnd0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEndSnd0" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEndSnd1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEndSnd1" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEndSnd2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEndSnd2" disabled>
																	</td>
																	<td>.</td>
																	<td class="BG2-2">
																		<input name="dhcpEndSnd3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpEndSnd3">
																	</td>
																</tr>
																<tr>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">128~</td>
																	<td class="BG2-2"></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2"></td>
																	<td></td>
																	<td class="BG2-2">~252</td>
																	<td width="100%"></td>
																</tr>
															</table>
														</td>
													</tr>
													<tr id="tr_2">
														<td class="BG2" style="width:160px;">DHCP 임대시간</td>
														<td class="BG2-2" width="600" colspan="8">
															<input name="dhcpLease" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dhcpLease" value="<% mcr_getCfgString("DhcpsCfgParam_Lease_time"); %>"> 
															(sec)
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:160px;">DNS Proxy</td>
														<td class="BG2-2" width="600" colspan="8">
															<table border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="110">
																		<input type="radio" name="dnsproxyenable" id="dnsproxyenable" value="1">
																		활성
																	</td>
																	<td>
																		<input name="dnsproxyenable" type="radio" id="dnsproxyenable1" value="0">
																		비활성 
																	</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="font1" align="left"></td>
											<td class="PD6">	
												<p align="right"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply" onclick="form_act('/goform/mcr_setLan'); return false;">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id='staticlease' style="display:none;">
								<td>
									<table width="98%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td colspan=2 class="font5"> 수동 IP 할당 설정</td>
										</tr>
										<tr>
											<td colspan=2 class="PD4"></td>
										</tr>
										<tr>
											<td colspan=2 class="PD5"></td>
										</tr>
										<tr>
											<td colspan=2>
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG2" style="width:160px;">타겟 MAC 주소</td>
														<td class="BG2-2" width="600">
															<input name="staticlease_mac" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="staticlease_mac" maxlength="17" value="" onFocus="on_focus_clear('staticlease_mac')" />
															<input name="staticlease_pcmac" type="checkbox" id="staticlease_pcmac" value="" onClick="check_mac();" />
															현재 LAN 포트 접속된 PC
														</td>
													</tr>
													<tr id="pcList" height="20" style="display:none">
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
																<tr id="staticlease_height">
																	<td width="100%" valign="top">
																		<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
																			<table class="TB" id="Grid_Table" width="300" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
																			<col width="30" align="center">
																			<col width="130">
																			<%
																				var i;
																				var rule_num = mcr_getLanConnectBindInfo(0,0);

																				write("<input type=hidden id=cur_staticlease value=");write(rule_num);write(">");
																				if (rule_num > 0) {
																					for (i = 0; i < rule_num; i++){
																						write("<tr bgcolor=#FFFFFF>");
																						write("<td class=BG2-2 style='padding-left:0px;' align='middle'>");
																						write("<input name=DR type=radio onClick=act_mac(\""+mcr_getLanConnectBindInfo(1,i)+"\") >");
																						write("</td>");
																						write("<td class=BG2-2>");
																						write("<p>");
																						write(mcr_getLanConnectBindInfo(1,i));
																						write("</p>");
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
														<td class="BG2" style="width:160px;">할당 IP</td>
														<td class="BG2-2" width="600">
														<input name="staticlease_ip0" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticlease_ip0">.
														<input name="staticlease_ip1" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticlease_ip1">.
														<input name="staticlease_ip2" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticlease_ip2">.
														<input name="staticlease_ip3" type="text" style="width:30;" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticlease_ip3">
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:160px;">설명</td>
														<td class="BG2-2" width="600"><input name="Description" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="Description" maxlength="22" /></td>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="PD6">
												<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_addStaticLeases'); return false;"/>
											</td>
										</tr>
									</table>
									<table class="TB" border="0">
										<tr>
											<td height="25" class="BG2" style="width:150px;">IP 할당 리스트</td>
											<td></td>
										</tr>
									</table>
									<table width="764" border="0" cellpadding="0" cellspacing="0" class="fix">
										<tr>
											<td>
												<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
													<table class="TB" width="100%" border="0" style="table-layout:fixed;">
														<col width="100">
														<col width="200">
														<col width="200">
														<col width="200">
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
																<p>할당 IP</p>
															</td>
															<td class="BG1">
																<p>설명</p>
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
														<col width="200">
														<col width="200">
														<%
															var i;
															var rule_num = mcr_getStaticMacInfoCount();
															write("<input type=hidden id=maxinfo value=");write(rule_num);write(">");
															if (rule_num > 0) {
																for (i = 0; i < rule_num; i++){
																	write("<tr bgcolor=#FFFFFF>");

																	write("<td class=BG2-2>");
																	write("<input type=checkbox name=chk_" + i + ">");
																	write("</td>");

																	write("<td class=BG2-2>");
																	write("<p>");write(mcr_getStaticMacList(i,0));write("</p>");
																	write("</td>");

																	write("<td class=BG2-2>");
																	write("<p>");write(mcr_getStaticMacList(i,1));write("</p>");
																	write("</td>");

																	write("<td class=BG2-2>");
																	write("<p>");write(mcr_getStaticMacList(i,2));write("</p>");
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
										<tr>
											<td class="PD6">
												<p align="right"><input name="Apply1" type="image" src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_delStaticLeases'); return false;" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6"> 	<p align="right"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
