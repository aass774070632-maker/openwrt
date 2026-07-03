<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<%include('new/script.asp');%>
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
var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
var usbprio = "<% mcr_getCfgString("UsbTetheringInfo_Priority"); %>";

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function form_act(url){
	
	parent.mcrProgress.startProgressSimple("apply", 80);	
	fwsw.action = url;
	fwsw.submit();
	
	return false;
}
	
function initValue()
{
	var netsel = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>";  
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
	var current_pkg = "<% mcr_getCfgString("UpgradeCfgParam_Pkg_act"); %>"; 
	var pkg_build_time = "ImageBuildTime : <% mcr_getSysBuildTime(); %>";
	var sw_version = "<% mcr_getCfgString("DeviceInfo_SoftwareVersion"); %>";
	var e = document.getElementById("lbl_selKtNetwork");
	var pkg1ver, pkg2ver;

	if(current_pkg == '2'){	
		document.fwsw.fwradio[1].checked = true;
	}
	else{
		document.fwsw.fwradio[0].checked = true;
	}
	var sohoZoneMode = 0;
	
	if( parent.mcrProgress != null )
		parent.mcrProgress.stopProgress();

	if (opmode == "1" && netsel == "0") {
		if( e != null ){
			if( sohoZoneMode == "0" ){
				e.innerHTML = "kt 모드";
			}else if( sohoZoneMode == "1" ){
				e.innerHTML = "kt 모드";
			}
			$("#tr_lan_ip_address").show();
			$("#tr_lan_subnet_mask").show();
			$("#tr_lan_kornet_ip_range").show();
			$("#tr_primium_dhcp_ip_range").show();
			$("#tr_dhcp_lease_time").show();
		}
	} else {
		if (opmode == "1"){
			if(e != null) {
				e.innerHTML = "공유기 모드";
				$("#tr_lan_ip_address").show();
				$("#tr_lan_subnet_mask").show();
				$("#tr_lan_kornet_ip_range").show();
				$("#tr_primium_dhcp_ip_range").hide();
				$("#tr_dhcp_lease_time").show();
				$('#tbl_lan_info').append('<tr><td style=\"height:22px;\">&nbsp;</td><td style=\"height:22px;\">&nbsp;</td></tr>');

			}
		} else {
			if(e != null) {
				if(waninterface == "0")
					e.innerHTML = "브릿지 모드";
				else
					e.innerHTML = "리피터 모드";
				$("#tr_lan_ip_address").hide();
				$("#tr_lan_subnet_mask").hide();
				$("#tr_lan_kornet_ip_range").hide();
				$("#tr_primium_dhcp_ip_range").hide();
				$("#tr_dhcp_lease_time").hide();
				for(var i=0; i<5; i++)
					$('#tbl_lan_info').append('<tr><td style=\"height:22px;\">&nbsp;</td><td style=\"height:22px;\">&nbsp;</td></tr>');
			}
		}
	}

	if(usbprio == 1){
		var usbWanIpAddr = '<% mcr_getCfgInterface("UsbWanDevice_IpAddress"); %>';
		var usbSubNetMask = '<% mcr_getCfgInterface("UsbWanDevice_SubNetMask"); %>';
		var usbDefaultGw = '<% mcr_getCfgInterface("UsbWanDevice_DefaultGw"); %>';

		document.getElementById("lbl_WanIpAddr").innerHTML = usbWanIpAddr;
		document.getElementById("lbl_SubNetMask").innerHTML = usbSubNetMask;
		document.getElementById("lbl_DefaultGw").innerHTML = usbDefaultGw;
	} else {
		var WanIpAddr = '<% mcr_getCfgInterface("WanDevice_IpAddress"); %>';
		var WanSubNetMask = '<% mcr_getCfgInterface("WanDevice_SubNetMask"); %>';
		var WanDefaultGw = '<% mcr_getCfgInterface("WanDevice_DefaultGw"); %>';

		document.getElementById("lbl_WanIpAddr").innerHTML = WanIpAddr;
		document.getElementById("lbl_SubNetMask").innerHTML = WanSubNetMask;
		document.getElementById("lbl_DefaultGw").innerHTML = WanDefaultGw;
	}

	if(opmode == 1 && netsel == 0){ 
		var sndWanMacAddr = '<% mcr_getCfgInterface("SecondWanDevice_MacAddress"); %>';
		document.getElementById("lbl_WanMacAddr").innerHTML = sndWanMacAddr;
	} else {
		var WanMacAddr = '<% mcr_getCfgInterface("WanDevice_MacAddress"); %>';
		document.getElementById("lbl_WanMacAddr").innerHTML = WanMacAddr;
	}

	pkg1ver = '<% mcr_getCfgCommon("UpgradeCfgParam_Pkgver1"); %>';
	pkg2ver = '<% mcr_getCfgCommon("UpgradeCfgParam_Pkgver2"); %>'; 
	if(current_pkg == 1) {
		document.getElementById("lbl_imgVersion0").innerHTML = "ImageVersion : "+ pkg1ver;
		document.getElementById("lbl_imgVersion1").innerHTML = "ImageVersion : "+ pkg2ver;
		document.getElementById("lbl_imgBuildTime0").innerHTML = pkg_build_time;
		document.getElementById("lbl_imgBuildTime1").innerHTML = "";
	} else if (current_pkg == 2) {
		document.getElementById("lbl_imgVersion0").innerHTML = "ImageVersion : "+ pkg1ver;
		document.getElementById("lbl_imgVersion1").innerHTML = "ImageVersion : "+ pkg2ver;
		document.getElementById("lbl_imgBuildTime0").innerHTML = "";
		document.getElementById("lbl_imgBuildTime1").innerHTML = pkg_build_time;
	}

	if ( opmode == 1) {
		var dhcps = "<% mcr_getCfgCommon("DhcpsCfgParam_Enable"); %>";
		if ( dhcps == "1" ) {
			document.getElementById("landhcp").innerHTML = "활성";
		}
		else {
			document.getElementById("landhcp").innerHTML = "비활성";
		}
	} else {
		document.getElementById("landhcp").innerHTML = "비활성";
	}
		
	changeTable();
}

</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onLoad="initValue();">
<table width="800" border="0" cellspacing="0" cellpadding="10">
	<tr>
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">시스템정보</td>
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
								<td class="BG2" width="140">장비명</td>
								<td class="BG2-2" width="617">홈허브</td>
							</tr>
							<tr>
								<td class="BG2" width="140">모델명/제조사</td>
								<td class="BG2-2" width="617"><% mcr_getCfgString("Tr069CfgParam_DeviceInfo_ModelName");%>/<% mcr_getCfgString("Tr069CfgParam_DeviceInfo_Manufacturer"); %> </td>
							</tr>
							<tr>
								<td class="BG2" width="140">버전</td>
								<td class="BG2-2" width="617"><% mcr_getCfgString("DeviceInfo_SoftwareVersion"); %></td>
							</tr>
							<tr>
								<td class="BG2" width="140">날짜/시간</td>
								<td class="BG2-2" width="617"><% mcr_getSysUptime(); %> </td>
							</tr>
							<tr>
								<td class="BG2" width="140">시스템업타임</td>
								<td class="BG2-2" width="617"><% mcr_getSysBoottime(); %> </td>
							</tr>
							<tr>
								<td class="BG2" width="140">메모리사용량</td>
								<td class="BG2-2" width="617"><% mcr_getSysMemUsage(); %>%</td>
							</tr>
							<tr>
								<td class="BG2" width="140">CPU 사용량</td>
								<td class="BG2-2" width="617">5Sec:<% mcr_getSysCpuUsage(0,1); %>% / 1Min: <% mcr_getSysCpuUsage(0,2); %>% / 10Min:<% mcr_getSysCpuUsage(0,3); %>% </td>
							</tr>
							<tr>
								<td class="BG2" width="140">대표 MAC 주소</td>
								<td class="BG2-2"width="617" ><label id="lbl_WanMacAddr"></label></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr id="bank">
		<td colspan="2">
			<form name="fwsw">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5"> 이미지정보</td>
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
								<td width="50%" bgcolor="RED" align="center" style="font-weight:bold;"><input type="radio" name="fwradio" value="0">Bank0 </td>
								<td bgcolor="RED" align="center" style="font-weight:bold;"><input type="radio" name="fwradio" value="1">Bank1 </td>
							</tr>
							<tr>
								<td class="BG2-2"><label id="lbl_imgVersion0"></label></td>
								<td class="BG2-2"><label id="lbl_imgVersion1"></label></td>
							</tr>
							<tr>
								<td class="BG2-2"><label id="lbl_imgBuildTime0"></label></td>
								<td class="BG2-2"><label id="lbl_imgBuildTime1"></label></td>
							</tr>     
						</table>
							
					</td>
				</tr>
				<tr>
					<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setfwimage'); return false;"/></td>
				</tr>
			</table>
			</form>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">인터넷 연결정보</td>
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
								<td class="BG2" style="width:140px;">인터페이스</td>
								<script language="JavaScript" type="text/javascript">
									if(usbprio == "1")
										document.write("<td class='BG2-2'>WAN(USB)</td>");
									else if(waninterface == "0")
										document.write("<td class='BG2-2'>WAN</td>");
									else
										document.write("<td class='BG2-2'>WLAN</td>");
								</script>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">IP 할당 방식</td>
								<td class="BG2-2"><% mcr_getCfgInterface("WanDevice_WanConnType"); %> </td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">IP주소</td>
								<td class="BG2-2"><label id="lbl_WanIpAddr"></label></td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">서브넷마스크</td>
								<td class="BG2-2"><label id="lbl_SubNetMask"></label></td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">게이트웨이</td>
								<td class="BG2-2"><label id="lbl_DefaultGw"></label></td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">기본 DNS</td>
								<td class="BG2-2"><% mcr_getCfgInterface("WanDevice_Dns1"); %> </td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">보조 DNS</td>
								<td class="BG2-2"><% mcr_getCfgInterface("WanDevice_Dns2"); %> </td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="font5">LAN 연결 정보</td>
				</tr>
				<tr>
					<td class="PD4"></td>
				</tr>
				<tr>
					<td class="PD5"></td>
				</tr>
				<tr>
					<td valign=top>
						<table class="TB" width="100%" border="0" id="tbl_lan_info">
							<tr>
								<td class="BG2" style="width:140px;">IP 할당 정책</td>
								<td class="BG2-2"><label id="lbl_selKtNetwork"></label> </td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">DHCP 서버</td>
								<td class="BG2-2" name="landhcp" id="landhcp" value="">
							</tr>
							<tr id="tr_lan_ip_address">
								<td class="BG2" style="width:140px;">IP 주소</td>
								<td class="BG2-2"><% mcr_getCfgInterface("LanDevice_IpAddress"); %> </td>
							</tr>
							<tr id="tr_lan_subnet_mask">
								<td class="BG2" style="width:140px;">서브넷마스크</td>
								<td class="BG2-2"><% mcr_getCfgInterface("LanDevice_SubNetMask"); %> </td>
							</tr>
							<tr id="tr_lan_kornet_ip_range">
								<td class="BG2"  style="width:140px;">코넷 DHCP IP 범위</td>
								<td class="BG2-2">
									<input name="dhcpStart" type="text" class="input2" id="dhcpStart" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp"); %>" /> 
									~ 
									<input name="dhcpEnd" type="text" class="input2" id="dhcpEnd" value="<% mcr_getCfgInterface("DhcpsCfgParam_EndIp"); %>" />
								</td>
							</tr>
							<tr id="tr_primium_dhcp_ip_range">
								<td class="BG2" style="width:140px;">프리미엄 DHCP IP 범위</td>
								<td class="BG2-2">
									<input name="dhcpStartSnd" type="text" class="input2" id="dhcpStartSnd" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Snd"); %>" /> 
									~ 
									<input name="dhcpEndSnd" type="text" class="input2" id="dhcpEndSnd" value="<% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Snd"); %>" />
								</td>
							</tr>
							<tr id="tr_dhcp_lease_time">
								<td class="BG2" style="width:140px;">DHCP 임대시간(sec)</td>
								<td class="BG2-2"><% mcr_getCfgString("DhcpsCfgParam_Lease_time"); %> </td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
</body>
</html>
