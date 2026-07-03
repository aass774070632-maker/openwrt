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
</style>

<script language="javascript" type="text/javascript">

var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";
var usbprio = "<% mcr_getCfgString("UsbTetheringInfo_Priority"); %>";

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
	document.form.action = "/goform/mcr_KTlogOut";
	document.form.submit();
}

function initValue()
{
	var netsel = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>";  
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
	var wifirly = "<% mcr_getCfgString("SysConfDb_WiFi_Relay"); %>";
	var current_pkg = "<% mcr_getCfgString("UpgradeCfgParam_Pkg_act"); %>"; 
	var pkg_build_time = "ImageBuildTime : <% mcr_getSysBuildTime(); %>";
	var sw_version = "<% mcr_getCfgString("DeviceInfo_SoftwareVersion"); %>";
	var e = document.getElementById("lbl_selKtNetwork");
	var pkg1ver, pkg2ver;
	var sohoZoneMode = "<% mcr_getCfgString("SysOperMode_KTSOHOZoneMode"); %>";

	if (opmode == "1" && netsel == "0") {
		if( e != null ){
			if( sohoZoneMode == "0" ){
				$("#lbl_selKtNetwork").val("KT 모드");
				$("#tr_relay_dhcp_ip_range").hide();
				$("#tr_1").hide();
			}else if( sohoZoneMode == "1" ){
				$("#lbl_selKtNetwork").val("소호존 모드");
				$("#tr_relay_dhcp_ip_range").hide();
				$("#tr_1").hide();
				if( wifirly == "1" ) {
					$("#tr_relay_dhcp_ip_range").show();
					$("#tr_1").show();
				}
			}else{
				$("#lbl_selKtNetwork").val("광고존 모드");
				$("#tr_relay_dhcp_ip_range").hide();
				$("#tr_1").hide();
				if( wifirly == "1" ) {
					$("#tr_relay_dhcp_ip_range").show();
					$("#tr_1").show();
				}
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
				$("#lbl_selKtNetwork").val("공유기 모드");
				$("#tr_lan_ip_address").show();
				$("#tr_lan_subnet_mask").show();
				$("#tr_lan_kornet_ip_range").show();
				$("#tr_primium_dhcp_ip_range").hide();
				$("#tr_relay_dhcp_ip_range").hide();
				$("#tr_dhcp_lease_time").show();
				$("#tr_1").hide();
				$('#tbl_lan_info').append('<tr><td style=\"height:22px;\">&nbsp;</td><td style=\"height:22px;\">&nbsp;</td></tr>');

			}
		} else {
			if(e != null) {
				if(waninterface == "0")
					$("#lbl_selKtNetwork").val("브릿지 모드");
				else
					$("#lbl_selKtNetwork").val("리피터 모드");
				$("#tr_lan_ip_address").hide();
				$("#tr_lan_subnet_mask").hide();
				$("#tr_lan_kornet_ip_range").hide();
				$("#tr_primium_dhcp_ip_range").hide();
				$("#tr_relay_dhcp_ip_range").hide();
				$("#tr_dhcp_lease_time").hide();
				$("#tr_1").hide();
				for(var i=0; i<5; i++)
					$('#tbl_lan_info').append('<tr><td style=\"height:22px;\">&nbsp;</td><td style=\"height:22px;\">&nbsp;</td></tr>');
			}
		}
	}

	if(usbprio == 1){
		var usbWanIpAddr = '<% mcr_getCfgInterface("UsbWanDevice_IpAddress"); %>';
		var usbSubNetMask = '<% mcr_getCfgInterface("UsbWanDevice_SubNetMask"); %>';
		var usbDefaultGw = '<% mcr_getCfgInterface("UsbWanDevice_DefaultGw"); %>';

		$("#lbl_WanIpAddr").val(usbWanIpAddr);
		$("#lbl_SubNetMask").val(usbSubNetMask);
		$("#lbl_DefaultGw").val(usbDefaultGw);
	} else {
		var WanIpAddr = '<% mcr_getCfgInterface("WanDevice_IpAddress"); %>';
		var WanSubNetMask = '<% mcr_getCfgInterface("WanDevice_SubNetMask"); %>';
		var WanDefaultGw = '<% mcr_getCfgInterface("WanDevice_DefaultGw"); %>';

		$("#lbl_WanIpAddr").val(WanIpAddr);
		$("#lbl_SubNetMask").val(WanSubNetMask);
		$("#lbl_DefaultGw").val(WanDefaultGw);
	}

	if(opmode == 1 && netsel == 0){
		var sndWanMacAddr = '<% mcr_getCfgInterface("SecondWanDevice_MacAddress"); %>';
		$("#lbl_WanMacAddr").val(sndWanMacAddr);
	} else {
		var WanMacAddr = '<% mcr_getCfgInterface("WanDevice_MacAddress"); %>';
		$("#lbl_WanMacAddr").val(WanMacAddr);
	}

	if ( opmode == 1) {
		var dhcps = "<% mcr_getCfgCommon("DhcpsCfgParam_Enable"); %>";
		if ( dhcps == "1" ) {
			$("#landhcp").val("활성");
		}
		else {
			$("#landhcp").val("비활성");
		}
	} else {
			$("#landhcp").val("비활성");
	}
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form" action="" data-ajax="false">
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<input type="button" value="로그아웃" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<input type="button" value="새로고침" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-mini="false" data-ajax="false">
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
					시스템 정보
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

	<div style="padding:0 5 12 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="35%">장비명:</td>
				<td>
					<input id="DeviceName" name="DeviceName" style="width:100%" class="input_r_t" value="홈허브" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">모델명/제조사:</td>
				<td>
					<input id="ModelName" name="ModelName" style="width:100%" class="input_r_t" value="<% mcr_getCfgString("Tr069CfgParam_DeviceInfo_ModelName");%>/<% mcr_getCfgString("Tr069CfgParam_DeviceInfo_Manufacturer"); %>" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">버전:</td>
				<td>
					<input id="Version" name="Version" style="width:100%" class="input_r_t" value="<% mcr_getCfgString("DeviceInfo_SoftwareVersion"); %>" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">날짜/시간:</td>
				<td>
					<input id="DateTime" name="DateTime" style="width:100%" class="input_r_t" value="<% mcr_getSysUptime(); %>" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">시스템업타임:</td>
				<td>
					<input id="SysUpTime" name="SysUpTime" style="width:100%" class="input_r_t" value="<% mcr_getSysBoottime(); %>" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">메모리사용량:</td>
				<td>
					<input id="MemoryRate" name="MemoryRate" style="width:100%" class="input_r_t" value="<% mcr_getSysMemUsage(); %>%" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">CPU 사용량:</td>
				<td>
					<input id="CpuRate" name="CpuRate" style="width:100%" class="input_r_t" value="5Sec:<% mcr_getSysCpuUsage(0,1); %>% / 1Min: <% mcr_getSysCpuUsage(0,2); %>% / 10Min:<% mcr_getSysCpuUsage(0,3); %>%" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td width="35%">대표 MAC 주소:</td>
				<td>
					<input id="lbl_WanMacAddr" name="lbl_WanMacAddr" style="width:100%" class="input_r_t" readonly="readonly">
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td align="left">인터넷 연결정보</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">인터페이스</td>
							<script language="JavaScript" type="text/javascript">
								if(usbprio == "1")
									document.write("<td class='input_r_t' style='width:100%'>WAN(USB)</td>");
								else if(waninterface == "0")
									document.write("<td class='input_r_t' style='width:100%'>WAN</td>");
								else
									document.write("<td class='input_r_t' style='width:100%'>WLAN</td>");
							</script>
						</tr>
						<tr>
							<td width="35%">IP 할당방식:</td>
							<td>
								<input id="IpAssign" name="IpAssign" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("WanDevice_WanConnType"); %>" readonly="readonly">
							</td>
						</tr>
						<tr>
							<td width="35%">IP 주소:</td>
							<td>
								<input id="lbl_WanIpAddr" name="lbl_WanIpAddr" style="width:100%" class="input_r_t" readonly="readonly">
							</td>
						</tr>
						<tr>
							<td width="35%">서브넷마스크:</td>
							<td>
								<input id="lbl_SubNetMask" name="lbl_SubNetMask" style="width:100%" class="input_r_t" readonly="readonly">
							</td>
						</tr>
						<tr>
							<td width="35%">게이트웨이:</td>
							<td>
								<input id="lbl_DefaultGw" name="lbl_DefaultGw" style="width:100%" class="input_r_t" readonly="readonly">
						</tr>
						<tr>
							<td width="35%">기본 DNS:</td>
							<td>
								<input id="DefaultDns" name="DefaultDns" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("WanDevice_Dns1"); %>" readonly="readonly">
							</td>
						</tr>
						<tr>
							<td width="35%">보조 DNS:</td>
							<td>
								<input id="AssiDns" name="AssiDns" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("WanDevice_Dns2"); %>" readonly="readonly">
							</td>
						</tr>
					</table>
				</td>
			<tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td align="left">LAN 연결 정보</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td width="35%">IP 할당 정책:</td>
							<td>
								<input id="lbl_selKtNetwork" name="lbl_selKtNetwork" style="width:100%" class="input_r_t" value="" readonly="readonly">
							</td>
						</tr>
						<tr>
							<td width="35%">DHCP 서버:</td>
							<td>
								<input id="landhcp" name="landhcp" style="width:100%" class="input_r_t" value="" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_lan_ip_address">
							<td width="35%">IP 주소:</td>
							<td>
								<input id="IpAddress" name="IpAddress" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("LanDevice_IpAddress"); %>" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_lan_subnet_mask">
							<td width="35%">서브넷마스크:</td>
							<td>
								<input id="SubNetMask" name="SubNetMask" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("LanDevice_SubNetMask"); %>" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_lan_kornet_ip_range">
							<td width="35%">코넷 DHCP <br>IP 범위:<br></td>
							<td>
								<input id="KornetIp" name="KornetIp" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp"); %> ~ <% mcr_getCfgInterface("DhcpsCfgParam_EndIp"); %>" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_primium_dhcp_ip_range">
							<td width="35%">프리미엄 DHCP <br>IP 범위:<br></td>
							<td>
								<input id="PreIp" name="PreIp" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Snd"); %> ~ <% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Snd"); %>" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_relay_dhcp_ip_range">
							<td width="35%">릴레이 DHCP <br>IP 범위:<br></td>
							<td>
								<input id="PreIp" name="PreIp" style="width:100%" class="input_r_t" value="<% mcr_getCfgInterface("DhcpsCfgParam_StartIp_Thrd"); %> ~ <% mcr_getCfgInterface("DhcpsCfgParam_EndIp_Thrd"); %>" readonly="readonly">
							</td>
						</tr>
						<tr id="tr_dhcp_lease_time">
							<td width="35%">DHCP 임대시간<br>(sec):<br></td>
							<td>
								<input id="DhcpSec" name="DhcpSec" style="width:100%" class="input_r_t" value="<% mcr_getCfgString("DhcpsCfgParam_Lease_time"); %>" readonly="readonly">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="/mobile.asp#secondPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
