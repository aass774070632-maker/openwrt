<html>
<head>
<title>Mobile Mesh setting</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.ui-btn-up-a {
        border: 1px solid #bbb;
        background: #fff;
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



.ui-btn-active-a{
        border:1px solid #bbb;
        background:#bebebe;
        font-weight:bold;
        color:#333;
        cursor:pointer;
        text-shadow:0 0px 0px #fff;
        text-decoration:none;
        background-image:-webkit-gradient(linear,left top,left bottom,from(#bebebe),to(#9e9e9e));
        background-image:-webkit-linear-gradient(#bebebe,#9e9e9e);
        background-image:-moz-linear-gradient(#bebebe,#9e9e9e);
        background-image:-ms-linear-gradient(#bebebe,#9e9e9e);
        background-image:-o-linear-gradient(#bebebe,#9e9e9e);
        background-image:linear-gradient(#bebebe,#9e9e9e);
        font-family:Helvetica,Arial,sans-serif
}

.ui-btn-active-c{
border:1px solid #bbb;
background:#fff;
	   font-weight:bold;
color:#fff;
cursor:pointer;
       text-shadow:0 0px 0px #fff;
       text-decoration:none;
       background-image:-webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
       background-image:-webkit-linear-gradient(#f16045,#ec2427);
       background-image:-moz-linear-gradient(#f16045,#ec2427);
       background-image:-ms-linear-gradient(#f16045,#ec2427);
       background-image:-o-linear-gradient(#f16045,#ec2427);
       background-image:linear-gradient(#f16045,#ec2427);
       font-family:Helvetica,Arial,sans-serif
}
</style>

<script language="javascript" type="text/javascript">

var arrData = new Array();
var tableRule = null;
<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
<%
	var gWlanSSIDIndexEJ;
	if ( gWlanIfIndexEJ == '0' )
		gWlanSSIDIndexEJ = '1';
	else
		gWlanSSIDIndexEJ = '101';
%>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
var wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>'
var wlanSecurityMode_ser = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';

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
	document.form_wlanMesh.action = "/goform/mcr_wlan_simple_KTlogOut";
	document.form_wlanMesh.submit();
}

function validateOnSubmit(){
	return true;
}
function layoutStationList(strMsg){
	if( tableRule == null ){
		initTable();
	}
	if( tableRule != null ){
		if( strMsg ){
			tableRule.setRows(null);
			tableRule.setEmptyString(strMsg);
			tableRule.layout();
		}else{
			tableRule.setRows(arrData);
			tableRule.layout();
		}
	}
}
function FormValue(useDefault){
	if( useDefault == 1 ){
		if( arrData == null || arrData.length == 0 ){
			layoutStationList("정보가 없습니다.");
		}else{
			layoutStationList();
		}
	}
}
function replaceAll(content, before, after) {
	return content.split(before).join(after);
}
function Xss_desubstitution(content) {

	content = replaceAll(content, "&lt;", "\<");
	content = replaceAll(content, "&gt;", "\>");
	content = replaceAll(content, "&#40;", "\(");
	content = replaceAll(content, "&#41;", "\)");
	content = replaceAll(content, "&#35;", "\#");
	content = replaceAll(content, "&#38;", "\&");
	content = replaceAll(content, "&#39;", "\'");
	content = replaceAll(content, "&quot;", "\"");

	return content;

}
function initForm_WLAN_Basic(useDefault){
	var mesh_enable;
	var mesh_SSID;
	var mesh_Key;

	if( useDefault == 0 ){
		if(gWlanIfIndex == '0'){
			wlanSSIDIdx = 1;
		}else{
			wlanSSIDIdx = 101;
		}
		deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
		mesh_enable = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';
		if(deviceRole == '2'){
			mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_0", "-1"); %>';
			mesh_SSID = Xss_desubstitution(mesh_SSID);
			mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_0", "-1"); %>';
			mesh_Key = Xss_desubstitution(mesh_Key);
		}else{
			mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_1", "-1"); %>';
			mesh_SSID = Xss_desubstitution(mesh_SSID);
			mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_1", "-1"); %>';
			mesh_Key = Xss_desubstitution(mesh_Key);
		}
	}
	
	mesh_check(mesh_enable);
	initTextById("wlanMeshSSID", mesh_SSID);
	initTextById("wlanMeshPSKKey", mesh_Key);
	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
	$("#wlanSSIDIdx").val(wlanSSIDIdx);

}

function initForms(flag){
	if(flag == 0){
		initForm_WLAN_Basic(flag);
	}else{
		FormValue(flag);
	}
}
function initValue(){
	initForms(0);
}

function form_act(url)
{
	var mesh_enable = '<% mcr_getCfgWireless("Wlan_Enable_1", "-1"); %>';
	var value = $("#wlanMeshPSKKey").val();
	var num = value.search(/[0-9]/g);
	var eng = value.search(/[a-z]/ig);
	var checked = $("input[name='m_wlanMeshActivity']:checked").val();
	var mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_1", "-1"); %>';
	var mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_1", "-1"); %>';
	var security = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';

	var ssid = document.getElementById("wlanMeshSSID");
	var pwd = document.getElementById("wlanMeshPSKKey");

	if(url == "/goform/mcr_setWirelessMeshPush"){
/*
		if(checked == '1'){
			if(mesh_popup()){
				if(mesh_enable == '1' && checked == '1'){
					if(ssid.value == mesh_SSID && pwd.value == mesh_Key){
						alert("이미 적용되어 있습니다");
						return false;
					}
				}
*/
			if(mesh_popup()){
				if(security != '0'){
					if(num < 0 || eng < 0 || value.length < 10){
						alert("암호는 영문 대소문자와 숫자 조합으로 10자 이상이어야 합니다.");
						return false;
					}
				}
				
			}else{
				return false;
			}
/*
		}else{
			if(mesh_enable == '0' && checked != '1'){
				alert("이미 적용되어 있습니다");
				return false;
			}
		}
*/
	}
	parent.mcrProgress.startProgressSimple("apply",30);	
	form_wlanMesh.action = url;
	form_wlanMesh.submit();

	return false;
}
function mesh_popup(){
	var wlanSecurityMode_main = '<% mcr_getCfgWireless("Wlan_SecurityMode_0", "-1"); %>';
	var wlanEncType_main = '<% mcr_getCfgWireless("Wlan_EncryptType_0", "-1"); %>';
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	var wlanEncType_mesh = '<% mcr_getCfgWireless("Wlan_EncryptType_1", "-1"); %>';
	var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
	var checked = $("#m_wlanMeshActivity").val();
	
	if(checked == '1' && deviceRole != '2'){
		if(wlanSecurityMode_mesh != '0'){
			if(wlanSecurityMode_mesh == '3'){//WEP
				apply_flag = 1;
			}else{ //WPA - PSK
				if((wlanSecurityMode_mesh == '5' && (wlanEncType_mesh == '1' || wlanEncType_mesh == '2'))){ //WPA2 - AES/TKIP-AES
					apply_flag = 0;
				}else if((wlanSecurityMode_mesh == '6' && (wlanEncType_mesh == '1' || wlanEncType_mesh == '2'))){ //WPA-WPA2 - AES/TKIP-AES
					apply_flag = 0;
				}else{
					apply_flag = 1;
				}
			}
			if(apply_flag){
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}

		if(wlanSecurityMode_main != '0'){
			if(wlanSecurityMode_main == '3'){//WEP
				flag = 1;
			}else{ //WPA - PSK
				if((wlanSecurityMode_main == '5' && (wlanEncType_main == '1' || wlanEncType_main == '2'))){ //WPA2 - AES/TKIP-AES
					flag = 0;
				}else if((wlanSecurityMode_main == '6' && (wlanEncType_main == '1' || wlanEncType_main == '2'))){ //WPA-WPA2 - AES/TKIP-AES
					flag = 0;
				}else{
					flag = 1;
				}
			}
			if(flag){
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}
	}
	return true;
}
function mesh_check(value){
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	switch(value){
		case '0':
			mcr_clickradio_meshCheck('0');
			$("input[id='m_wlanMeshActivity0']").attr("checked", true).checkboxradio("refresh");
			$("#wlanMeshActivity").val('0');
			$("#view_menu").hide();
			$("#ssid_pskkey").hide();
			$("#wireless_wlanUIPSKKey").hide();
			$("#view_list").hide();
			$("#view_aplist").hide();
			$("#guard").hide();
			break;
		case '1':
			mcr_clickradio_meshCheck('1');
			$("input[id='m_wlanMeshActivity']").attr("checked", true).checkboxradio("refresh");
			$("#wlanMeshActivity").val('1');
			$("#view_menu").show();
			if(wlanSecurityMode_mesh == '0') {
				$("#ssid_pskkey").hide();
				$("#wireless_wlanUIPSKKey").hide();
			} else {
				$("#ssid_pskkey").show();
				$("#wireless_wlanUIPSKKey").show();
			}
			$("#view_list").show();
			$("#view_aplist").show();
			$("#guard").show();
			break;
		default:
			break;
	}
}

function mcr_clickradio_meshCheck(val){
        $('label[for=m_wlanMeshActivity]').removeClass('ui-btn-active');
        $('label[for=m_wlanMeshActivity0]').removeClass('ui-btn-active');
        switch(val){
                case '0':
                        $('label[for=m_wlanMeshActivity0]').addClass('ui-btn-active-c');
                        $('label[for=m_wlanMeshActivity]').removeClass('ui-btn-active-c');
			$("#ssid_name").hide();
                        break;
                case '1':
                        $('label[for=m_wlanMeshActivity]').addClass('ui-btn-active-c');
                        $('label[for=m_wlanMeshActivity0]').removeClass('ui-btn-active-c');
			$("#ssid_name").show();
                        break;
                default:
                        break;
        }

}
function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );

	arrCol[0] = items[0];
	arrCol[1] = items[1];

	return arrCol;
}

function initTable(){
	var strTableAttr = "class='TB TB-1' id='Grid_Table' width='100%' border='0' bgcolor='#FFFFFF'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "class='BG1'";
	var strTableTd = "class='BG2-2'";
	var strTableTd_nopadding = "class='BG2-2-2'";


	tableRule = new MCRTable("view_aplist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"AP 정보가 없습니다.", " ", parseData);
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "width='20%'", strTableTh, strTableTd_nopadding+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "RSSI", "width='20%'", strTableTh, strTableTd+" align='center'", "");
}


function processHttpResponse(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	for( var row=0; row < lineArr.length-rowOnly; row++){
		arrData[row] = lineArr[row];
	}
	initForms(1);
}

function onClickRefresh(){
        httpRequest("/goform/mcr_getRssiValue", "n/a", processHttpResponse);
}

$(document).ready(function(){	
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(2);
	});
	$("#wlanBtn").bind("click", function(){
		onClickRefresh();
		return false;
	});
});

</script>
</head>
<body onload="initValue()">
<form method="post" id="form_Mesh" name="form_wlanMesh" data-ajax="false">
<input type="hidden" name="wlanMeshActivity" id="wlanMeshActivity" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_2_15_mesh_set.asp">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<input type="button" value="로그아웃" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png">
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
					<img src="/images/kt_logo.png" style="width: 24px;">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					Mesh AP 설정
				</td>
			</tr>
		</table>
	</div>
	<hr style="border-width: 1px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>활성 여부</td>
				<td>
					<fieldset data-role="controlgroup" data-type="horizontal">
						<label for="m_wlanMeshActivity">　활성　</label>
						<input type="radio" name="m_wlanMeshActivity" id="m_wlanMeshActivity" value="1" onclick="mesh_check(this.value)">
						<label for="m_wlanMeshActivity0">　비활성　</label>
						<input type="radio" name="m_wlanMeshActivity" id="m_wlanMeshActivity0" value="0" onclick="mesh_check(this.value)">
					</fieldset>
				</td>		
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain" id="ssid_name" style="display:none;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>무선랜명</td>
				<td>
					<input type="text" name="wlanMeshSSID" id="wlanMeshSSID" size="32" maxlength="32" value="">
				</td>
			</tr>
			<tr id="ssid_pskkey" style="display:none">
				<td>암호키</td>
				<td>
					<input type="password" name="wlanMeshPSKKey" id="wlanMeshPSKKey" size="32" maxlength="64" value=""> 암호키보기
					<input type="checkbox" name="check_box" id="check_box" data-role="none">
				</td>
			</tr>
			<tr id="wireless_wlanUIPSKKey" style="display:none">
				<td></td>
				<td>
					<label for="text" valign="center">암호는 10자 이상 64자 이하여야 합니다.</label>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr id="view_menu" style="display:none">
				<td align="left" style="font-weight:bold;">
					연결 AP 신호 세기
				</td>
				<td align="left">
					<img src="/images/BTN/BTN_07.gif?Sp2" width="52" height="24" value="wlanBtn" id="wlanBtn" name="wlanBtn">
				</td>
			</tr>
		</table>
	</div>
	<hr id="guard" style="display:none" color="bebebe" style="width: 1px 0 0 0; margin:0px" width="100%">
	<div style="padding:5 5 0 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr id="view_list" style="display:none">
				<td>
					<div>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td align="center" width="20%">MAC 주소</td>
								<td align="center" width="20%">신호세기</td>
							</tr>
							
						</table>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td>
									<hr color="fff" style="width: 1px 0 0 0;" width="100%;">
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<div id="view_aplist" style="overflow:-moz-scrollbars-vertical; overflow-x:no; overflow-y:auto;"></div>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" onclick="form_act('/goform/mcr_setWirelessMeshPush')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>

</div>
</form>
</body>
</html>
