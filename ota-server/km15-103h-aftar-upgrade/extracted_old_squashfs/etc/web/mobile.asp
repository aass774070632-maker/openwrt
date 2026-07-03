<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">
<script language="javascript" type="text/javascript" src="/script/jquery-1.7.1.min.js"></script>
<script language="javascript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common_kt.js"></script>
<style type="text/css">
.ui-btn-up-a {
	border: 1px solid #bbb;
	background: #bebebe;
	font-weight: bold;
	color: #333;
	text-shadow: 0 1px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#dedede),to(#bebebe));
	background-image: -webkit-linear-gradient(#dedede,#bebebe);
	background-image: -moz-linear-gradient(#dedede,#bebebe);
	background-image: -ms-linear-gradient(#dedede,#bebebe);
	background-image: -o-linear-gradient(#dedede,#bebebe);
	background-image: linear-gradient(#dedede,#bebebe);
}

</style>
<script>
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

function changeWirelessMobileSubMenu(pageUrl, redirectURL, wlanIfIndex){
	WirelessSetFormElement(document, "redirect-url", "/new/"+redirectURL);
	WirelessSetFormElement(document, "wlanIfIndex", wlanIfIndex);

	changePage(pageUrl);
}

function changeDnsPage(pageUrl, redirectURL){
	WirelessSetFormElement(document, "redirect-url", "/new/"+redirectURL);
	changePage(pageUrl);
}

function WirelessSetFormElement(doc, name, value){
        var e = doc.getElementById(name);
        if( e == null ){
                var input = doc.createElement("input");
                input.type = 'hidden';
                input.id = name;
                input.name = name;
                input.value = ( (value == null) ? "" : value );
                doc.form.appendChild( input );
                input = null;
        }else{
                e.value = ( (value == null) ? "" : value );
        }
}

function changePage(pageUrl){
	form.action = pageUrl;
	form.submit();
}

</script>
</head>

<body>
<form name="form">
<div data-role="page" data-theme="d" id="firstPage">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 24px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					GiGA WiFi home 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">
	<div>
		<table>
			<tr height="20">
			</tr>
		</table>
		
		<a href="new/mobile_00_1_wlan_simple.asp" data-role="button" data-ajax="false" data-transition="pop"> 비밀번호 설정 </a>
		<a href="#secondPage" data-role="button" data-ajax="false" data-transition="pop"> 상태 정보 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_02_simple_open_set.asp', '100')" data-role="button" data-ajax="false" data-transition="pop"> 간편개통설정(2.4GHz) </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_02_simple_open_set.asp', '0')" data-role="button" data-ajax="false" data-transition="pop"> 간편개통설정(5GHz) </a>
		<a href="#thirdPage" data-role="button" data-ajax="false" data-transition="pop"> 장치설정 </a>
		<a href="javascript:;" onclick="changeDnsPage('/goform/mcr_DnsCheck','mobile_agent_setup.asp')" data-role="button" data-ajax="false" data-transition="pop"> MESH 설정 </a>
	</div>
</div>

<div data-role="page" data-theme="d" id="secondPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					상태 정보
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_01_1_status_info.asp" data-ajax="false" data-role="button"> 시스템 정보 </a>
		<a href="/new/mobile_01_2_cwlink_info.asp" data-ajax="false" data-role="button"> 유무선 연결 정보 </a>
		<a href="/new/mobile_01_3_cwterminal_info.asp" data-ajax="false" data-role="button"> 유무선 단말 정보 </a>
		<a href="/new/mobile_01_4_log_info.asp" data-ajax="false" data-role="button"> 로그 정보 </a>
	</div>
		<a href="#firstPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="thirdPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그 아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="widtg: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					장치 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="#fourthPage" data-role="button" data-ajax="false" data-transition="pop"> 네트워크 관리 </a>
		<a href="#fifthPage" data-role="button" data-ajax="false" data-transition="pop"> 무선 관리(2.4GHz) </a>
		<a href="#sixthPage" data-role="button" data-ajax="false" data-transition="pop"> 무선 관리(5GHz) </a>
		<a href="#seventhPage" data-role="button" data-ajax="false" data-transition="pop"> 스위치 관리 </a>
		<a href="#eighthPage" data-role="button" data-ajax="false" data-transition="pop"> 트래픽 관리 </a>
		<a href="#ninthPage" data-role="button" data-ajax="false" data-transition="pop"> 보안 기능 </a>
		<a href="#tenthPage" data-role="button" data-ajax="false" data-transition="pop"> 부가 기능 </a>
		<a href="#eleventhPage" data-role="button" data-ajax="false" data-transition="pop"> 시스템 관리 </a>
	</div>
		<a href="#firstPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>
<div data-role="page" data-theme="d" id="fourthPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width:30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					네트워크 관리
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_1_1_ip_assign_policy.asp" data-ajax="false" data-role="button"> IP 할당정책 </a>
		<a href="javascript:;" onclick="changeDnsPage('/goform/mcr_DnsCheck', 'mobile_03_1_2_internet_link_set.asp')" data-ajax="false" data-role="button"> 인터넷 연결설정 </a>
		<a href="/new/mobile_03_1_4_lan_link_set.asp" data-ajax="false" data-role="button"> LAN 연결설정 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="fifthPage">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					무선관리(2.4GHz)
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_1_wireless_common_set.asp', '100')" data-ajax="false" data-role="button"> 무선 공통 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_2_wps_set.asp', '100')" data-ajax="false" data-role="button"> WPS 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_10_wmac_filtering_set.asp', '100')" data-ajax="false" data-role="button"> 무선 MAC 필터링 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_7_soip_connect_set.asp','100')" data-ajax="false" data-role="button"> Mesh WLAN 접속 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_8_home_wlan_connection.asp','100')" data-ajax="false" data-role="button"> Home WLAN 접속 설정 </a>
		<script language="JavaScript" type="text/javascript">
			var gKTSOHOZone ='<% mcr_getCfgWireless("SysOperMode_KTSOHOZoneMode"); %>';
			if ( gKTSOHOZone == '1' ) {
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_4_nespot_connect_set.asp','100') data-ajax=false data-role=button> ollehWiFi(Basic) 접속 설정 </a>\r\n");
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_6_qooknshow_connect_set.asp','100') data-ajax=false data-role=button> ollehWiFi 접속 설정 </a>\r\n");
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_9_wconnect_terminal_manage.asp','100') data-ajax=false data-role=button> 무선 접속 단말 관리 </a>\r\n");
			}
			else{
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_9_wconnect_terminal_manage.asp','100') data-ajax=false data-role=button> 무선 접속 단말 관리 </a>\r\n");
			}
		</script>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="sixthPage">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width:30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					무선관리(5GHz)
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_1_wireless_common_set.asp', '0')" data-ajax="false" data-role="button"> 무선 공통 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_2_wps_set.asp', '0')" data-ajax="false" data-role="button"> WPS 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect', 'mobile_03_2_10_wmac_filtering_set.asp', '0')" data-ajax="false" data-role="button"> 무선 MAC 필터링 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_7_soip_connect_set.asp','0')" data-ajax="false" data-role="button"> Mesh WLAN 접속 설정 </a>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_8_home_wlan_connection.asp','0')" data-ajax="false" data-role="button"> Home WLAN 접속 설정 </a>
		<script language="JavaScript" type="text/javascript">
			var gKTSOHOZone ='<% mcr_getCfgWireless("SysOperMode_KTSOHOZoneMode"); %>';
			if ( gKTSOHOZone == '1' ) {
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_4_nespot_connect_set.asp','0') data-ajax=false data-role=button> ollehWiFi(Basic) 접속 설정 </a>\r\n");
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_6_qooknshow_connect_set.asp','0') data-ajax=false data-role=button> ollehWiFi 접속 설정 </a>\r\n");
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_9_wconnect_terminal_manage.asp','0') data-ajax=false data-role=button> 무선 접속 단말 관리 </a>\r\n");
			}
			else{
				document.write("<a href=javascript:; onclick=changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_9_wconnect_terminal_manage.asp','0') data-ajax=false data-role=button> 무선 접속 단말 관리 </a>\r\n");
			}
		</script>
		<a href="javascript:;" onclick="changeWirelessMobileSubMenu('/goform/mcr_getWirelessFormRedirect','mobile_03_2_15_mesh_set.asp','0')" data-ajax="false" data-role="button"> Mesh 설정 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="seventhPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width:30ox;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					스위치 관리
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_3_1_port_link_set.asp" data-ajax="false" data-role="button"> 포트 링크 설정 </a>
		<a href="/new/mobile_03_3_2_port_mirroring_set.asp" data-ajax="false" data-role="button"> 포트 미러링 설정 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>


<div data-role="page" data-theme="d" id="eighthPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					트래픽 관리
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_4_1_port_forwarding_set.asp" data-ajax="false" data-role="button"> 포트 포워딩 설정 </a>
		<a href="/new/mobile_03_4_2_dmz_set.asp" data-ajax="false" data-role="button"> DMZ 설정 </a>
		<a href="/new/mobile_03_4_3_alg_set.asp" data-ajax="false" data-role="button"> ALG 설정 </a>
		<a href="/new/mobile_03_4_7_port_statistics.asp" data-ajax="false" data-role="button"> 포트 통계 정보 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="ninthPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					보안 기능
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_5_1_secure_func_set.asp" data-ajax="false" data-role="button"> 보안 기능 설정 </a>
		<a href="/new/mobile_03_5_2_packet_filter_set.asp" data-ajax="false" data-role="button"> 패킷 필터 설정 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="tenthPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					부가 기능
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_6_1_ddns_set.asp" data-ajax="false" data-role="button"> DDNS 설정 </a>
		<a href="/new/mobile_03_6_2_wakeonlan.asp" data-ajax="false" data-role="button"> 스마트 부팅 설정 </a>
		<a href="/new/mobile_03_6_3_home_network_set.asp" data-ajax="false" data-role="button"> 홈 네트워크 설정 </a>
		<a href="/new/mobile_03_6_6_ledoff_set.asp" data-ajax="false" data-role="button"> LED OFF 시간 설정 </a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>

<div data-role="page" data-theme="d" id="eleventhPage">

	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 30px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					시스템 관리
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">

	<div class="ui-grid-a" style="padding: 0 0 1" data-theme="d" data-role="fieldcontain">
		<table>
			<tr height="20">
			</tr>
		</table>
		<a href="/new/mobile_03_7_2_mange_account_set.asp" data-ajax="false" data-role="button"> 관리 계정 설정</a>
		<a href="/new/mobile_03_7_3_set_file_manage.asp" data-ajax="false" data-role="button"> 설정 파일 관리</a>
		<a href="/new/mobile_03_7_8_system_restart.asp" data-ajax="false" data-role="button"> 시스템 재시동</a>
	</div>
		<a href="#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
</div>
</form>
</body>
</html>
