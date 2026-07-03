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

<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var arrData = new Array();
var tableRule = null;
function changeTableAdmin()
{

	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function convRSSI_to_sign( strValue ){
        return ( '' + (0 - parseInt( strValue )) );
}

function convRSSI_to_abs( strLabel ){
        var strValue = $("#"+strLabel).val();
        var nValue = parseInt( strValue );
        var nABSValue = Math.abs(nValue);
        return ( '' + nABSValue );
}
function validateOnSubmitDbg(){
	form_act('/goform/mcr_setWirelessMeshPush');
	parent.mcrProgress.startProgressSimple('apply', 20);
	return true;
}

function CheckValue(){
	var ret = 0;
        var rssi = 0;
        ret = validateRangeById("ui_roaming_RSSITH_Master", 10, -99, -1, true);
        if( ret!= 1 ){
                alert( "범위 초과(-99 ~ -1)" );
                return false;
        }
        ret = validateRangeById("ui_roaming_RSSITH_Slave", 10, -99, -1, true);
        if( ret!= 1 ){
                alert( "범위 초과(-99 ~ -1)" );
                return false;
        }
        rssi = convRSSI_to_abs("ui_roaming_RSSITH_Master");
        $("#roaming_RSSITH_Master").val( rssi );
        rssi = convRSSI_to_abs("ui_roaming_RSSITH_Slave");
        $("#roaming_RSSITH_Slave").val( rssi );

	return true;
}
function form_act(url)
{
	var value = $("#wlanMeshPSKKey").val();
	var num = value.search(/[0-9]/g);
	var eng = value.search(/[a-z]/ig);
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	
	if(form_wlanMesh.wlanMeshActivity[1].checked == true){ // disabled
		parent.mcrProgress.startProgressSimple('apply', 50);
	} else if(form_wlanMesh.wlanMeshActivity[0].checked == true){ // enabled
		if(url == "/goform/mcr_setWirelessMeshPush") {
			if(mesh_popup()) {
				if(wlanSecurityMode_mesh != '0' ) {
					if(num < 0 || eng < 0 || value.length < 10) {
						alert("암호는 영문 대소문자와 숫자 조합으로 10자 이상이어야 합니다");
						return false;
					}
				}
			} else {
				return false;
			}
			parent.mcrProgress.startProgressSimple('apply', 60);
		} else {
			if(!CheckValue())
				return false;
			parent.mcrProgress.startProgressSimple('apply', 60);
		}
	}
	form_wlanMesh.action = url;
	form_wlanMesh.submit();

	return false;
}
function mesh_popup(){
	var mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
	var wlanSecurityMode_main = '<% mcr_getCfgWireless("Wlan_SecurityMode_0", "-1"); %>';
	var wlanEncType_main = '<% mcr_getCfgWireless("Wlan_EncryptType_0", "-1"); %>';
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	var wlanEncType_mesh = '<% mcr_getCfgWireless("Wlan_EncryptType_1", "-1"); %>';
	var deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
	var active = $("#wlanMeshActivity").val();
	var apply_flag = 0;
	var flag = 0;

	if( active == '1' && deviceRole != '2'){
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
function initForms(flag){
	if(flag == 0){
		initForm_WLAN_Basic(flag);
	}else{
		FormValue(flag);
	}
	changeTableAdmin();
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
	var mesh_PSKKey;
	var mesh_SSID_new;
	var mesh_PSKKey_new;
	var roaming_RSSITH_Master;
	var roaming_RSSITH_Master_delta;
	var roaming_RSSITH_Slave;
	var roaming_RSSITH_Slave_delta;

	$("#wlanUIMenu23").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	if( useDefault == 0 ){
		if(gWlanIfIndex == '0'){
			wlanSSIDIdx = 1;
		}else{
			wlanSSIDIdx = 101;
		}
		deviceRole = '<% mcr_getCfgWireless("Wlan_DeviceRole", "-1"); %>';
		mesh_enable = '<% mcr_getCfgWireless("Wlan_MapEnable", "-1"); %>';
		if (deviceRole == 2) {
			mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_0", "-1"); %>';
			mesh_SSID = Xss_desubstitution(mesh_SSID);
			mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_0", "-1"); %>';
			mesh_Key = Xss_desubstitution(mesh_Key);
		} else {
			mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_1", "-1"); %>';
			mesh_SSID = Xss_desubstitution(mesh_SSID);
			mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_1", "-1"); %>';		
			mesh_Key = Xss_desubstitution(mesh_Key);
		}

		roaming_RSSITH_Master = '<% mcr_getCfgWireless("Wlan_Mesh_Roaming_RSSITH_Master", "-1"); %>';
		roaming_RSSITH_Master_delta = '<% mcr_getCfgWireless("Wlan_Mesh_Roaming_RSSITH_Master_delta", "-1"); %>';
		roaming_RSSITH_Slave = '<% mcr_getCfgWireless("Wlan_Mesh_Roaming_RSSITH_Slave", "-1"); %>';
		roaming_RSSITH_Slave_delta = '<% mcr_getCfgWireless("Wlan_Mesh_Roaming_RSSITH_Slave_delta", "-1"); %>';

		ui_roaming_RSSITH_Master = convRSSI_to_sign(roaming_RSSITH_Master);
		ui_roaming_RSSITH_Slave = convRSSI_to_sign(roaming_RSSITH_Slave);
	}

	$("#wlanSSIDIdx").val(wlanSSIDIdx);

	$("input[name='wlanMeshActivity']").val([mesh_enable]);
	initTextById("wlanMeshSSID", mesh_SSID);
	initTextById("wlanMeshPSKKey", mesh_Key);
	mesh_check(mesh_enable);

	$("#lbl_wireless_wlanUIPSKKey").text("암호는 10자 이상 64자 이하여야 합니다.");
	$("#lbl_wlanMeshActivity").text("활성 시 IPTV 서비스는 이용할 수 없습니다.");


        initTextById("ui_roaming_RSSITH_Master",                ui_roaming_RSSITH_Master);
        initTextById("ui_roaming_RSSITH_Slave",                 ui_roaming_RSSITH_Slave);
        initTextById("roaming_RSSITH_Master_delta",     roaming_RSSITH_Master_delta);
        initTextById("roaming_RSSITH_Slave_delta",              roaming_RSSITH_Slave_delta);

	$("#ap_test").hide();

}
function initValue(){
	parent.mcrProgress.stopProgress();
	initForms(0);
}


function mesh_check(value){
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	if(value == "0"){
		$("#ssid_name").hide();
		$("#ssid_pskkey").hide();
		$("#slave_list").hide();
		$("#master_list").hide();
		$("#list_apply").hide();
		$("#view_menu").hide();
		$("#view_list").hide();
		$("#view_list1").hide();
	}else{
		$("#ssid_name").show();
		if( wlanSecurityMode_mesh == '0') {
			$("#ssid_pskkey").hide();
		} else {
			$("#ssid_pskkey").show();
		}
		$("#slave_list").show();
		$("#master_list").show();
		$("#list_apply").show();
		$("#view_menu").show();
		$("#view_list").show();
		$("#view_list1").show();
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


	tableRule = new MCRTable("view_aplist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"AP 정보가 없습니다.", " ", parseData);
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "width='40%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "RSSI", "width='40%'", strTableTh, strTableTd+ " align='center'", "");
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
	$("#wlanBtn").bind("click", function(){
		onClickRefresh();
		return false;
	});
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(2);
	});

});
</script>
</head>

<body class="wbody" onLoad="initValue()">
<form method="post" class="form_layout" id="form_Mesh" name="form_wlanMesh">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/AdminFolder/3_2_15_mesh_set.asp"/>
<input type="hidden" id="roaming_RSSITH_Master" name="roaming_RSSITH_Master" value=""/>
<input type="hidden" id="roaming_RSSITH_Slave" name="roaming_RSSITH_Slave" value=""/>
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_2_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr id="lbl_Mesh">
								<td class="font5">Mesh 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">활성 여부</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="wlanMeshActivity" id="wlanMeshActivity" value="1" Onclick="mesh_check(this.value)">활성
														</td>
														<td>
															<input name="wlanMeshActivity" type="radio" id="wlanMeshActivity0" value="0" Onclick="mesh_check(this.value)">비활성
															&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
															<label id="lbl_wlanMeshActivity"></label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="ssid_name" style="display:none;">
										 	<td height="25" class="BG2" style="width:140px;">무선랜명(SSID)</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td>
															<input type="text" name="wlanMeshSSID" id="wlanMeshSSID" size="32" maxlength="33" value=""/>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="ssid_pskkey" style="display:none;">
											<td height="25" class="BG2" style="width:140px;" rowspan="2">암호키</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td>
															<input type="password" name="wlanMeshPSKKey" id="wlanMeshPSKKey" size="32" maxlength="64" value=""/> 암호키보기
															<input type="checkbox" name="check_box" name="check_box" tabindex="4" value="1"/>
														</td>
													</tr>
													<tr id="wireless_wlanUIPSKKey">
														<td>
															<label id="lbl_wireless_wlanUIPSKKey"></label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="apply_btn">
								<td class="PD6" colspan="3">
									<input type="image" src="/images/BTN/BTN_01.gif" id="btn_apply" name="btn_apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessMeshPush'); return false;"/></input>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr id="view_menu" style="display:none">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">연결 AP 신호세기</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="image" src="/images/BTN/BTN_07.gif?Sp2" width="52" height="24" value="wlanBtn" id="wlanBtn" name="wlanBtn">
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="view_list" style="display:none">
								<td width="670">
									<div>
										<table class='TB TB-1' id='Grid_Table' width='100%' border='0' style='table-layout:fixed;' bgcolor='#FFFFFF'>
											<tr height="20">
												<td class="BG1" width="40%">MAC 주소</td>
												<td class="BG1" width="40%">RSSI(dBm)</td>
											</tr>
										</table>
									</div>
								</td>
							</tr>
							<tr height="120" id="view_list1" style="display:none">
								<td width="670" valign="top">
									<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<div id="view_aplist"></div>
								</td>
							</tr>
						</table>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr id="ap_test" style="display:none">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">연결 AP 테스트</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="image" src="/images/BTN/BTN_07.gif?Sp2" width="52" height="24" id="apply1" name="apply1" onclick="form_act('/goform/mcr_mesh_ConnectAP_Conut'); return false;"/>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
							<tr id="slave_list" style="display:none;">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:100px;">Slave AP로 이동 조건</td>
										</tr>
										<tr height="20">
											<td height="25" class="BG1" style="width:140px;">구분</td>
											<td height="25" class="BG1" style="width:140px;">설정값</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;" id="lbl_mesh_ssid">Master AP RSSI</td>
											<td height="25" class="BG2-2" style="width:140px;">
											<input class="input2-1" type="text" id="ui_roaming_RSSITH_Master" name="roaming_RSSITH_Master" size="5" maxlength="5" value=""></input>
											<label>dBm 이하</label>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;" id="lbl_mesh_ssid">Slave AP RSSI - Master AP RSSI 차이</td>
											<td height="25" class="BG2-2" style="width:140px;">
											<input class="input2-1" type="text" id="roaming_RSSITH_Master_delta" name="roaming_RSSITH_Master_delta" size="5" maxlength="5i" value=""></input>
											<label>dB 이상</label>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="master_list" style="display:none;">
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:100px;">Master AP로 이동 조건</td>
										</tr>
										<tr height="20">
											<td height="25" class="BG1" style="width:140px;">구분</td>
											<td height="25" class="BG1" style="width:140px;">설정값</td>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;" id="lbl_mesh_ssid">Slave AP RSSI</td>
											<td height="25" class="BG2-2" style="width:140px;">
											<input class="input2-1" type="text" id="ui_roaming_RSSITH_Slave" name="roaming_RSSITH_Slave" size="5" maxlength="5" value=""></input>
											<label>dBm 이하</label>
										</tr>
										<tr>
											<td height="25" class="BG2-2" style="width:140px;" id="lbl_mesh_ssid">Master AP RSSI - Slave AP RSSI 차이</td>
											<td height="25" class="BG2-2" style="width:140px;">
											<input class="input2-1" type="text" id="roaming_RSSITH_Slave_delta" name="roaming_RSSITH_Slave_delta" size="5" maxlength="5" value=""></input>
											<label>dB 이상</label>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="list_apply" style="display:none;">
								<td class="PD6" colspan="3">
									<input type="image" src="/images/BTN/BTN_01.gif" id="apply" name="apply" height="24" width="52" onclick="form_act('/goform/mcr_setWirelessMeshPushRoaming'); return false;"/></input>
								</td>
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
