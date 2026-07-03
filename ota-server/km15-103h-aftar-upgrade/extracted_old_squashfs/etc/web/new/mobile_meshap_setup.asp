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
.ui-block-a{
    border: 1px solid;
    width: 120px;
   text-align: left;
}
.ui-btn-up-b {
        border: 1px solid;
        background: #FF0000;
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
.ui-btn-inner {
    display: block;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
    position: relative;
    zoom: 1;
}
.ui-btn-inner {
    
    border-color: rgba(255,255,255,.3);
}
.ui-checkbox .ui-btn-icon-left .ui-btn-inner, .ui-radio .ui-btn-icon-left .ui-btn-inner {
    
}
.row{ 
  width: 100%;
  display: block;
  line-height: 60px;
  text-align: center;	
}

input[type="checkbox"] {
}
input[type="checkbox"] + label {
  display: inline-block;
  width: 40px;
  height: 20px;
  position: relative;
  -webkit-transition: 0.3s;
  transition: 0.3s;
  margin: 0px 20px;
  box-sizing: border-box;
}
input[type="checkbox"] + label:after {
  content: '';
  display: block;
  position: absolute;
  left: 0px;
  top: 0px;
  width: 20px;
  height: 20px;
  -webkit-transition: 0.3s;
  transition: 0.3s;
  cursor: pointer;
}
#m_wlanMeshActivity:checked + label.red
{
  background: #ECA9A7;
}

#m_wlanMeshActivity:checked + label.red:after
{
  background: #D9534F;
}

#m_wlanMeshActivity:checked + label.green
{
  background: #99e299;
}

#m_wlanMeshActivity:checked + label.green:after
{
  background: #fff;
}

#m_wlanMeshActivity:checked + label:after
{
  left: calc(100% - 20px);
}

#m_wlanMeshActivity + label
{
  background: #000;
  border-radius: 20px;
  height: 10px;
}

#m_wlanMeshActivity + label:after
{
  background: #fff;
  border-radius: 50%;
  top: -5px;
  box-shadow: 0px 0px 3px #aaa;
}

input[type=text1]{
	width: 100%;
	margin:8px 0;
	box-sizing: border-box;
	border: none;
	border-bottom: 1px solid black;
}
.ui-btn-icon-left .ui-icon, .ui-btn-icon-right .ui-icon {
    position: relative; 
    top: 50%;
    margin-top: -9px;
}
.ui-btn-inner {
    display: block;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
    position: relative;
    zoom: 1;
}
.ui-btn-inner {
    border-color: rgba(255,255,255,.3);
}
</style>

<script language="javascript" type="text/javascript">
<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
<%
	var gWlanSSIDIndexEJ;
	if ( gWlanIfIndexEJ == '0' )
		gWlanSSIDIndexEJ = '1';
	else
		gWlanSSIDIndexEJ = '101';
%>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var mesh_enable = '<% mcr_getCfgWireless("Wlan_Mesh_Enable", "-1"); %>';
var mesh_index = '<% mcr_getCfgWireless("Wlan_Mesh_VapIndex", "-1"); %>';
var wlanSecurityMode = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
var wlanEncType = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>';

var arrData = new Array();
var tableRule = null;

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
		if(deviceRole == 2){
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

	initTextById("wlanMeshSSID", mesh_SSID);
	initTextById("wlanMeshPSKKey", mesh_Key);
	if(mesh_enable == 1){
		$("#m_wlanMeshActivity").prop("checked", true);
	}else{
		$("#m_wlanMeshActivity").prop("checked", false);
	}
	onClickList();

	layoutStationList();
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

function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	arrCol[0] = items[0];
	arrCol[1] = items[1];
	
	if((-70 >= arrCol[1]) && (arrCol[1] >=  -80)){
		arrCol[2] = '<p><img src="/images/color_g.png" width="22" height="20"></p>'
	}else if((-80 >= arrCol[1]) && (arrCol[1] >= -99)){
		arrCol[2] = '<p><img src="/images/color_r.png" width="22" height="20"></p>'
	}else if((0 >= arrCol[1]) && (arrCol[1] > -70)){
		arrCol[2] = '<p><img src="/images/color_y.png" width="22" height="20"></p>'
	}
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
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "", "width='20%'", strTableTh, strTableTd_nopadding, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "", "width='20%'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "", "width='20%'", strTableTh, strTableTd, "");
}

function form_act(url)
{

	var mesh_enable = '<% mcr_getCfgWireless("Wlan_Enable", gWlanSSIDIndexEJ); %>';
	var e = document.getElementById("m_wlanMeshActivity");
	var value = $("#wlanMeshPSKKey").val();
	var num = value.search(/[0-9]/g);
	var eng = value.search(/[a-z]/ig);
	var mesh_SSID = '<% mcr_getCfgWireless("Wlan_SSID_1", "-1"); %>';
	mesh_SSID = Xss_desubstitution(mesh_SSID);	
	var mesh_Key = '<% mcr_getCfgWireless("Wlan_WEPPSKKey_1", "-1"); %>';
	mesh_Key = Xss_desubstitution(mesh_Key);

	var ssid = document.getElementById("wlanMeshSSID");
	var pwd = document.getElementById("wlanMeshPSKKey");

	if(e.checked){
		if(onClick_MeshPopUpSet()){
			if(mesh_enable == 1 && e.checked == true){
				if(ssid.value == mesh_SSID && pwd.value == mesh_Key){
					alert("이미 적용되어 있습니다");
					return false;
				}
			}
			if(num < 0 || eng < 0 || value.length < 10){
				alert("비밀번호는 영문 대소문자와 숫자 조합으로 10자 이상이어야 합니다.");
				return false;
			}
			$("#wlanMeshActivity").val("1");
			alert("Mesh 설정이 적용 되었습니다. 인터넷 연결이 끊어집니다");
			
		}else{
			return false;
		}
	}else{
		$("#wlanMeshActivity").val("0");
		alert("Mesh 설정이 비활성 되었습니다. 재부팅 동작이 이루어집니다");
	}

	
	form_wlanMesh.action = url;
	form_wlanMesh.submit();

	return false;
}
function onClick_MeshPopUpSet(){
	var wlanSecurityMode_main = '<% mcr_getCfgWireless("Wlan_SecurityMode_0", "-1"); %>';
	var wlanEncType_main = '<% mcr_getCfgWireless("Wlan_EncryptType_0", "-1"); %>';
	var wlanSecurityMode_mesh = '<% mcr_getCfgWireless("Wlan_SecurityMode_1", "-1"); %>';
	var wlanEncType_mesh = '<% mcr_getCfgWireless("Wlan_EncryptType_1", "-1"); %>';

	if(deviceRole == '0' || deviceRole == '1'){
		if(wlanSecurityMode_mesh != '5' && wlanSecurityMode_mesh != '0'){
			alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
			return false;
		}
		if(wlanSecurityMode_mesh != '0'){
			if(wlanEncType_mesh != '1'){
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}
		if(((wlanSecurityMode_main != '0') && (wlanSecurityMode_main != '5')) || (wlanEncType_main != '1')){
			if(!(wlanSecurityMode_main == '6' && wlanEncType_main == '2')){
				alert("모든 무선랜의 인증보안방식을 WPA2/AES로 변경해 주세요.");
				return false;
			}
		}
	
	}
	return true;
}
function onClickList(){
	var e = document.getElementById("m_wlanMeshActivity");
	if(e.checked == true){
		$("#ssid_name").show();
		$("#ssid_name_1").show();
		$("#ssid_pskkey").show();
		$("#ssid_pskkey_1").show();
		$("#ssid_pskkey_2").show();
		$("#menu_title").show();
		$("#signal").show();
		$("#signal_explain").show();
		$("#bar").show();
		$("#rssi_info").show();
		$("#list").show();
		$("#guard").show();
		$("#guard1").show();
	}else if(e.checked == false){
		$("#ssid_name").hide();
		$("#ssid_name_1").hide();
		$("#ssid_pskkey").hide();
		$("#ssid_pskkey_1").hide();
		$("#ssid_pskkey_2").hide();
		$("#menu_title").hide();
		$("#signal").hide();
		$("#signal_explain").hide();
		$("#bar").hide();
		$("#rssi_info").hide();
		$("#list").hide();
		$("#guard").hide();
		$("#guard1").hide();
	}
}




function processHttpResponse(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	for( var row=0; row < lineArr.length-rowOnly; row++){
		arrData[row] = lineArr[row];
	}
	if( lineArr.length-rowOnly == 0 ){
		arrData = [];	
		tableRule.setEmptyImage('<p><img src="/images/mesh.png" width="100%"></p>');
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
<body onload="initValue()">
<form method="post" name="form_wlanMesh" data-ajax="false">

<input type="hidden" name="wlanMeshActivity" id="wlanMeshActivity" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_meshap_setup.asp">
<div data-role="page" data-theme="d">
	<div class="row" data-ajax="false">
		
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" style="background-color:EAEAEA;height:40px; width=100%">
			<tr>
				<td width="2%"></td>
				<td width="82%">Mesh 설정</td>
				<td>
					<input type="checkbox" id="m_wlanMeshActivity" name="m_wlanMeshActivity" onclick="return onClickList();">
					<label for="m_wlanMeshActivity" class="green"></label>
				</td>
			</tr>
		</table>
	</div>
	<div data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<img src="/images/explain_4.png" width="100%" border="0">
				</td>
			</tr>
		</table>
	</div>
	<div data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" style="background-color:EAEAEA;height:40px; width=100%">
			<tr id="menu_title" style="display:none">
				<td width="2%"></td>
				<td>Mesh 무선랜 관리</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="98%" valign="middle">
			<tr id="ssid_name" style="display:none">
				<td>이름</td>
				<td>
				</td>
			</tr>
			<tr id="ssid_name_1" style="display:none">
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<input type="text" name="wlanMeshSSID" id="wlanMeshSSID" size="32" maxlength="32" value="">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="ssid_pskkey" style="display:none">
				<td>비밀번호</td>
			</tr>
			<tr id="ssid_pskkey_1" style="display:none">
				<td>
					<input type="password" name="wlanMeshPSKKey" id="wlanMeshPSKKey" size="32" maxlength="64" value=""> 암호키보기
					<input type="checkbox" name="check_box" id="check_box" data-role="none">
				</td>
			</tr>
			<tr id="ssid_pskkey_2" style="display:none">
				<td>
					<label for="text">비밀번호는 10자 이상 64자 이하여야 합니다.(초기값은 기본 설정값임)</label>
				</td>
			</tr>
		</table>
		<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" onclick="form_act('/goform/mcr_setWirelessMeshPush')" data-theme="c" data-corners="false" data-role="button" data-mini="false" data-ajax="false"> 적용 </a>
	</div>
	<div data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" style="background-color:EAEAEA;height:40px; width=100%">
			<tr id="signal" style="display:none" width="98%">
				<td width="2%"></td>
				<td> 연결된 공유기 신호 세기</td>
			</tr>
		</table>
		<table align="center" cellspacing="0" cellpadding="0" width="90%" valign="middle">
			<tr>
			</tr>
			<tr id="signal_explain" style="display:none">
				<td height="40" valign="center">
					<label for="text" valign="center">새로고침을 눌러서 연결 정보를 확인하세요</label>
				</td>
				<td height="40" valign="center">
					<img src="/images/rssi_refresh.png" width="28" height="35" value="wlanBtn" id="wlanBtn" name="wlanBtn" align="right">
				</td>
			</tr>
		</table>
		<hr id="guard1" color="bebebe" style="border-width: 1px 0 0 0; margin:0px" width="98%">
	</div>
	<div>
		<table align="center" cellspacing="0" cellpadding="0" width="90%" valign="middle">
			<tr>
				<td>
					<div>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="20%"></td>
								<td width="20%"></td>
								<td width="20%"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			
			<tr id="list" style="display:none">
				<td>
					<div id="view_aplist" style="overflow:-moz-scrollbars-vertical; overflow-x:no; overflow-y:auto;"></div>
				</td>
			</tr>
		</table>
		<hr id="guard" color="bebebe" style="border-width: 1px 0 0 0; margin:0px" width="98%">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr id="rssi_info" style="display:none">
				<td>
				</td>
				<td>
					<img src="/images/rssi_value.png" width="98%">
				</td>
			</tr>
		</table>
		
	</div>
	<div data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" style="background-color:EAEAEA;height:40px; width=100%">
			<tr style="font-color:#bebebe" width="100%">
				<td width="2%"></td>
				<td> 설치 가이드</td>
				<td>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-ajax="false">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<img src="/images/install_guide1.png" width="100%" border="0">
				</td>
			</tr>
		</table>
	</div>
</div> 
</form>
</body>
</html>
