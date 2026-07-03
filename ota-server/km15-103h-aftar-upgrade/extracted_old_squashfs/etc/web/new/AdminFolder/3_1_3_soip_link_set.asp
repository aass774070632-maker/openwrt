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

var beforId = "menu02";
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

function setSearchCtl(arg){
	switch(arg){
		case '2':       
			$("#tr_dhcpSetInfo").show();
			$("#tr_staticSetInfo").hide();
			$("#tr_dhcpConnInfo").show();
			break;
		case '1':       
			if(document.form.dns2ip_1.value = "0.0.0.0") {
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

function setWan(url) {
	$("input[name='dns1ip']").val($("input[name='dns1ip_1']").val());	
	$("input[name='dns2ip']").val($("input[name='dns2ip_1']").val());
	if(CheckValue()){
		runable(url);
	}
	return false;
}

function runable(url){
	parent.mcrProgress.startProgressSimple("apply", 15);
	form.action = url;
	form.submit();
}

function CheckValue()
{
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
	}
	else
		return false;

	return true;
}


function initApp(){
	$("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	parent.mcrProgress.stopProgress();
	
	{
		var contype = "<% mcr_getCfgInterface("SecondWanDevice_WanConnType"); %>";
		var dnstype = "<% mcr_getCfgString("DnsCfgParam_Enable"); %>";

		var wanopt60_en = "<% mcr_getCfgString("SecondWanDevice_Dhcp_Option60_Enable"); %>";
		var wanopt77_en = "<% mcr_getCfgString("SecondWanDevice_Dhcp_Option77_Enable"); %>";

		if( contype == "DHCP" ) {
			document.form.connectionType[0].checked = true;
			setSearchCtl("2");
		}
		else {
			document.form.connectionType[1].checked = true;
			setSearchCtl("1");
		}

		if( wanopt60_en == "1" ) {
			document.form.wanOpt60_en[0].checked = true;
			setOpt60Ctl("1");
		}
		else {
			document.form.wanOpt60_en[1].checked = true;
			setOpt60Ctl("0");
		}

		if( wanopt77_en == "1" ) {
			document.form.wanOpt77_en[0].checked = true;
			setOpt77Ctl("1");
		}
		else {
			document.form.wanOpt77_en[1].checked = true;
			setOpt77Ctl("0");
		}

		if (opmode == "1" && netsel == "1") {
			$("#tr_1").hide();
			$("#tr_2").hide();
		}
	}
	
	{
		var Dns_en = "<% mcr_getCfgString("UserManage_DnsCheck"); %>";
		switch(Dns_en){
			case '0':
				$("input[name='dns1ip_1']").attr('disabled',false);
				$("input[name='dns2ip_1']").attr('disabled',false);
				$("#dnsstate").text("");
				break;
			case '1':
				$("input[id='connectionType1']").attr('disabled', true);
				$("input[name='dns1ip_1']").attr('disabled',true);
				$("input[name='dns2ip_1']").attr('disabled',true);
				$("#dnsstate").text("※ DNS 값을 변경하시려면 유선으로 접속해 주시기 바랍니다.");

				break;
			default:
				break;
		}
	}

	changeTable();
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
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_1_menu3rd.asp');%>
		</td>
	</tr>
 
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td height="146" valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> 프리미엄 인터넷 연결설정</td>
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
												<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="229">
													<tr>
														<td width="114">
															<input type="radio" name="connectionType" id="connectionType" value="2"  OnClick="setSearchCtl(this.value)">
															DHCP
														</td>
														<td id="td_staticip" style="display:inline float:left" width="114">
															<input name="connectionType" type="radio" id="connectionType1" value="1" OnClick="setSearchCtl(this.value)">
															고정 IP
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="tr_dhcpSetInfo">
								<td height="130" valign="top">
									<table class="TB" width="100%" border="0">
                                        <tr >
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
										<tr id = "tr_1">
											<td class="BG2" style="width:140px;">OPTION 60</td>
											<td class="BG2-2" width="600"><input name="option60" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="option60" value="<% mcr_getCfgString("SecondWanDevice_Dhcp_Option60"); %>" size="21" />
											ex)KT_PR_HH_MERCURY_MODEL.
											</td>
										</tr>
                                        <tr >
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
										<tr id = "tr_2">
											<td class="BG2" style="width:140px;">OPTION 77</td>
											<td class="BG2-2" width="600">
											<input name="option77" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="option77" value="<% mcr_getCfgString("SecondWanDevice_Dhcp_Option77"); %>" />
											ex)KT_PR_HH_D
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
											<td class="BG2-2">
												<input name="staticIp" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticIp" value=<% mcr_getCfgInterface("SecondWanDevice_IpAddress"); %> />
												ex)192.168.10.32
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">서브넷마스크</td>
											<td class="BG2-2">
											<input name="staticNetmask" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticNetmask" value=<% mcr_getCfgInterface("SecondWanDevice_SubNetMask"); %> />
												ex)255.255.255.0
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게이트웨이</td>
											<td class="BG2-2">
											<input name="staticGateway" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="staticGateway" value=<% mcr_getCfgInterface("SecondWanDevice_DefaultGw"); %> />
											ex)192.168.10.254</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">기본 DNS</td>
											<td class="BG2-2">
											<input name="dns1ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns1ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Primary"); %> />
											ex)168.126.63.1　　　　　<label id="dnsstate"></label>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">보조 DNS</td>
											<td class="BG2-2">
											<input name="dns2ip_1" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="dns2ip_1" value=<% mcr_getCfgInterface("DnsCfgParam_Secondary"); %> />
											ex)168.126.63.1</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><p align="right">&nbsp;<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onclick="return setWan('/goform/mcr_setSndWan')" />
								</td>
								<td width="2%">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id = "tr_3">
					<td valign="top">
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
											<td class="BG2" style="width:140px;">IP 주소</td>
											<td colspan="3" class="BG2-2"><% mcr_getCfgInterface("SecondWanDevice_IpAddress"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">서브넷마스크</td>
											<td width="25%" class="BG2-2"><% mcr_getCfgInterface("SecondWanDevice_SubNetMask"); %></td>
											<td class="BG2" style="width:140px;">기본 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("DnsCfgParam_Primary"); %></td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">게이트웨이</td>
											<td class="BG2-2"><% mcr_getCfgInterface("SecondWanDevice_DefaultGw"); %></td>
											<td class="BG2" style="width:140px;">보조 DNS</td>
											<td class="BG2-2"><% mcr_getCfgInterface("DnsCfgParam_Secondary"); %></td>
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
                        <input name="redirect_admSecondWanSet" type="text" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_admSecondWanSet" value="/new/AdminFolder/3_1_3_soip_link_set.asp"/>
                </td>
        </tr>
</table>
</form>
</body>
</html>
