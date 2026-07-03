<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>

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
	document.form_ippolicy.action = "/goform/mcr_KTlogOut";
	document.form_ippolicy.submit();
}

var network = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>";
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";

var prevOpMode = -1;    

var sohoZoneMode = "<% mcr_getCfgString("SysOperMode_KTSOHOZoneMode"); %>";
var gProjectCode = <% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>;

var UserPrivilege = getUserPrivilege();
var clear = 0;

var wire_limit_val = "<% mcr_getCfgString("DhcpProxyCfgParam_wired_limit_count"); %>"
var wireless_limit_val = "<% mcr_getCfgString("DhcpProxyCfgParam_wireless_limit_count"); %>"

function mcr_getSystemIPPolicy(){
	var curOpMode;
	if(opmode == "1" && network == "0") {
		if( sohoZoneMode == '0' ){
			curOpMode = 0;
		}else if( sohoZoneMode == '1' ){
			curOpMode = 3;
		}else{
			curOpMode = 4;
		}
	}else{
		if( opmode == "1" ){
			if( waninterface == "0")
				curOpMode = 1;
			else if(waninterface =="1")
				curOpMode = 2;
			else
				curOpMode = 1;
		}else{
			curOpMode = 2;
		}
	}
	return curOpMode;
}


function mcr_getSelectedIPPolicy(){
	var curOpMode;
	curOpMode = $("#opmode").val();
	if( $("#opmode").val() == "3" ){
		curOpMode = 3;
	}else if( $("#opmode").val() == "4" ){
		curOpMode = 4;
	}
	return curOpMode;
}


function disable_ippolicy() {
	form_ippolicy.port1_policy.disabled = true;
	form_ippolicy.port2_policy.disabled = true;
	form_ippolicy.port3_policy.disabled = true;
	form_ippolicy.port4_policy.disabled = true;
	form_ippolicy.nespot_policy.disabled = true;
	form_ippolicy.show_policy.disabled = true;
	form_ippolicy.soip_policy.disabled = true;
	form_ippolicy.home_policy.disabled = true;
	$('#btn_apply1').attr("disabled",true);
}


function enable_ippolicy() {
	form_ippolicy.port1_policy.disabled = false;
	form_ippolicy.port2_policy.disabled = false;
	form_ippolicy.port3_policy.disabled = false;
	form_ippolicy.port4_policy.disabled = false;
	form_ippolicy.nespot_policy.disabled = false;
	form_ippolicy.show_policy.disabled = false;
	form_ippolicy.soip_policy.disabled = false;
	form_ippolicy.home_policy.disabled = false;
	$('#btn_apply1').attr("disabled","");
}


function changeIpSeting() {

	if(($("#opmode").val() == "0") || ($("#opmode").val() == "3") || ($("#opmode").val() == "4")){
		$("#policy_ip_per_port").hide();
		$("#btn_check").show();
		$("#WDS_en").hide();
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");

		if(waninterface == "0"){
			mcr_clickradio_repeater_en('2');
			$("input[id='m_repeater_en']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("2");
		}
		else{
			mcr_clickradio_repeater_en('1');
			$("input[id='m_repeater_en1']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("1");
		}

		var lan1 = <% mcr_getDhcpProxyString("lan1_proxy"); %>;
		var lan2 = <% mcr_getDhcpProxyString("lan2_proxy"); %>;
		var lan3 = <% mcr_getDhcpProxyString("lan3_proxy"); %>;
		var lan4 = <% mcr_getDhcpProxyString("lan4_proxy"); %>;
		var wlan1 = <% mcr_getDhcpProxyString("wlan1_proxy"); %>;
		var wlan2 = <% mcr_getDhcpProxyString("wlan2_proxy"); %>;
		var wlan3 = <% mcr_getDhcpProxyString("wlan3_proxy"); %>;
		var wlan4 = <% mcr_getDhcpProxyString("wlan4_proxy"); %>;

		form_ippolicy.port1_policy.selectedIndex = lan1;
		form_ippolicy.port2_policy.selectedIndex = lan2;
		form_ippolicy.port3_policy.selectedIndex = lan3;
		form_ippolicy.port4_policy.selectedIndex = lan4;
		form_ippolicy.nespot_policy.selectedIndex = wlan3;
		form_ippolicy.show_policy.selectedIndex = wlan4;
		form_ippolicy.soip_policy.selectedIndex = wlan2;
		form_ippolicy.home_policy.selectedIndex = wlan1;

		$('select#port1_policy').selectmenu('refresh'); 
		$('select#port2_policy').selectmenu('refresh'); 
		$('select#port3_policy').selectmenu('refresh'); 
		$('select#port4_policy').selectmenu('refresh'); 
		$('select#nespot_policy').selectmenu('refresh'); 
		$('select#show_policy').selectmenu('refresh'); 
		$('select#soip_policy').selectmenu('refresh'); 
		$('select#home_policy').selectmenu('refresh'); 

		if( (gProjectCode & 0x10000) == 0x10000 ) {
			disable_ippolicy();
		} else {
			enable_ippolicy();
		}
	} else if($("#opmode").val() == "1") {
		$("#policy_ip_per_port").hide();
		$("#btn_check").show();
		$("#WDS_en").hide();
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");

		if(waninterface == "0"){
			mcr_clickradio_repeater_en('2');
			$("input[id='m_repeater_en']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("2");
		}
		else{
			mcr_clickradio_repeater_en('1');
			$("input[id='m_repeater_en1']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("1");
		}

		form_ippolicy.port1_policy.selectedIndex = 2;
		form_ippolicy.port2_policy.selectedIndex = 2;
		form_ippolicy.port3_policy.selectedIndex = 2;
		form_ippolicy.port4_policy.selectedIndex = 2;
		form_ippolicy.nespot_policy.selectedIndex = 2;
		form_ippolicy.show_policy.selectedIndex = 2;
		form_ippolicy.soip_policy.selectedIndex = 2;
		form_ippolicy.home_policy.selectedIndex = 2;

		$('select#port1_policy').selectmenu('refresh'); 
		$('select#port2_policy').selectmenu('refresh'); 
		$('select#port3_policy').selectmenu('refresh'); 
		$('select#port4_policy').selectmenu('refresh'); 
		$('select#nespot_policy').selectmenu('refresh'); 
		$('select#show_policy').selectmenu('refresh'); 
		$('select#soip_policy').selectmenu('refresh'); 
		$('select#home_policy').selectmenu('refresh'); 

		disable_ippolicy();
	} else if($("#opmode").val() == "2") {
		$("#btn_check").show();
		$("#WDS_en").hide(); 
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");
		$("#wirelessOperMode").val( '0' );
	}

	var curOpMode = mcr_getSelectedIPPolicy();

	if( $("input[name='opmode']").val() == "3" ){
		$("#opmode_sohozone").val("1");

		$("#lbl_wireless_ippolicy_ollehbasic").text("ollehWiFi(Basic)");
	}else if( $("input[name='opmode']").val() == "4" ){
		$("#opmode_sohozone").val("2");

		$("#lbl_wireless_ippolicy_ollehbasic").text("olleh NAVER");
	}else{
		$("#opmode_sohozone").val("0");

		$("#lbl_wireless_ippolicy_ollehbasic").text("ollehWiFi(Basic)");
	}
	prevOpMode = curOpMode;
	changeLimitCnt();
}

function changeLimitCnt() {
	var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";

	if($("#opmode").val() == "2" || opmode == "0") {
		$("#wired_limit").attr('disabled',true);
		$("#wireless_limit").attr('disabled',true);
		$("#btn_apply6").hide();
		$("#btn_apply7").hide();
	} else {
		if(limit_cnt_en == "0") {
			$("#wired_limit").attr('disabled',true);
			$("#wireless_limit").attr('disabled',true);
			$("#btn_apply6").hide();
			$("#btn_apply7").hide();
			$("#m_opmode2").attr('disabled',true).checkboxradio("refresh");
		}
		else {
			$("#wired_limit").attr('disabled',false);
			$("#wireless_limit").attr('disabled',false);
			$("#btn_apply6").show();
			$("#btn_apply7").show();
			$("#m_opmode2").attr('disabled',false).checkboxradio("refresh");
		}
	}
}


function CheckValue()
{
	w = parseInt(document.form_ippolicy.wired_limit.value, 10);
	if(w < 0 || (253 < w && w < 255) || w > 255) {
		alert("유선단말 접속제한은 0~255에 해당하는 숫자를 입력해 주세요");
		return false;
	}
	var w2 = parseInt(document.form_ippolicy.wireless_limit.value, 10);
	if(w2 < 0 || (253 < w2 && w2 < 255) || w2 > 255) {
		alert("무선단말 접속제한은 0~255에 해당하는 숫자를 입력해 주세요");
		return false;
	}
	if((w!=255 && w2!=255) && ((w+w2) > 252)) {
		alert("단말 접속 수 제한은 유선,무선 합쳐서 252개를 넘어서는 안됩니다.");
		return false;
	}
	if((w==0) && (w2==0)) {
		alert("유선단말과 Home WLAN 단말 설정이 잘못되었습니다.");
		return false;
	}

	if ( isEmpty(wired_limit.value) == true  || isEmpty(wireless_limit.value) == true ) {
		alert("접속 수 제한 갯수를 입력해 주세요.");
		return false;
	}
	return true;
}


function form_act(url){
	var check_apply_policy=0;
	if(url == "/goform/mcr_setOpMode") {
		if(waninterface == "1"){
			var confirmed = confirm("리피터 모드를 해지하려면 재부팅이 필요합니다. 모드를 변경하시겠습니까? ");
		}else{
			var confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
		}

		$('a[name=btn_apply3]').removeClass('ui-btn-active');
		$('a[name=btn_apply3]').addClass('ui-btn-active-a');
		if (!confirmed)
			return false;
		if($("#opmode").val() == "3"){
			$("#opmode").val('0');
		}
		check_apply_policy=1;
	}
	else if(url == "/goform/mcr_setdhcpProxy"){
		$('a[name=btn_apply1]').removeClass('ui-btn-active');
		$('a[name=btn_apply1]').addClass('ui-btn-active-a');
		return false;
	}
	else if(url == "/goform/mcr_setdhcpProxyLimit") {
		if(!CheckValue())
			return false;

		if(opmode == "0") {
			var chg_flag = false;

			if(parseInt(wire_limit_val, 10) != parseInt(document.form_ippolicy.wired_limit.value, 10)) {
				chg_flag = true;
			}

			if(parseInt(wireless_limit_val, 10) != parseInt(document.form_ippolicy.wireless_limit.value, 10)) {
				chg_flag = true;
			}

			if(chg_flag) {
				confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");

				if (!confirmed)
					return false;
				check_apply_policy=1;
			} else {
				alert("접속 수 제한 설정이 변경되지 않았습니다.");
				return false;
			}
		}

		$('a[name=btn_apply6]').removeClass('ui-btn-active');
		$('a[name=btn_apply6]').addClass('ui-btn-active-a');
		
	}
	else if(url == "/goform/mcr_setSimpleConfig") {
		var ssidlen = getByteLength($("#ssid_client").val());
		if( ssidlen == 0 ){
			alert("리피터 모드로 동작합니다. SSID 가 없으므로 WPS 버튼을 이용하여 접속하셔야 합니다.\n리피터 모드로 동작할 경우, OTN 서비스와 IPTV 서비스가 불가하고, Host AP를 통한 WiFi 속도 저하가 될 수 있습니다.");
		}else
			alert("리피터 모드로 동작할 경우, OTN 서비스와 IPTV 서비스가 불가하고, Host AP를 통한 WiFi 속도 저하가 될 수 있습니다.");
		var confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");

		if (!confirmed)
			return false;
		check_apply_policy=1;
		$('a[name=wlanBtnSecurity]').removeClass('ui-btn-active');
		$('a[name=wlanBtnSecurity]').addClass('ui-btn-active-a');
	}
	if(check_apply_policy=="1")
                parent.mcrProgress.startProgressSimple("apply",50);
        else
                parent.mcrProgress.startProgressSimple("apply",5);

	form_ippolicy.action = url;
	form_ippolicy.submit();
	return false;
}


function CheckCancel(wired, wireless)
{
	document.getElementById(wired).value = wire_limit_val;
	document.getElementById(wireless).value = wireless_limit_val;
	$('a[name=btn_apply7]').removeClass('ui-btn-active');
	$('a[name=btn_apply7]').addClass('ui-btn-active-a');
	return false;
}


function initValue() {
	var opt60_en = "<% mcr_getCfgString("DhcpProxyCfgParam_option60_enable"); %>";
	var opt77_en = "<% mcr_getCfgString("DhcpProxyCfgParam_option77_enable"); %>";
	var Check_GHz = "<% mcr_getCfgString("SysOperMode_Check_GHz"); %>";

	if(opmode == "1" && network == "0") {
		if( sohoZoneMode == "0" ){
			setopmode('0');
		}else if( sohoZoneMode == "1" ){
			setopmode('3');
		}else{
			setopmode('4');
		}
		$("#opmode_sohozone").val(sohoZoneMode);
	}
	else {
		if(opmode == "1"){
			if(waninterface == "0")
				setopmode('1');
			else if(waninterface =="1")
				setopmode('2');
			else
				setopmode('1');
		}
		else
				setopmode('2');
	}

	if(opt60_en == "1")
		$("#option60_en").val('1');
	else
		$("#option60_en").val('0');

	if(opt77_en == "1")
		$("#option77_en").val('1');
	else
		$("#option77_en").val('0');

	if(waninterface == "0")
		setrepeater_en('2');
	else
		setrepeater_en('1');

	setcheck_GHz('0');

	prevOpMode = mcr_getSystemIPPolicy();
	initForms(0);
	changeIpSeting();

	document.form_ippolicy.wired_limit.value = wire_limit_val;
	document.form_ippolicy.wireless_limit.value = wireless_limit_val;

	onClickNext("empty");
	$("#wlanRedirectPage").val("/new/mobile_03_1_1_ip_assign_policy.asp");
}

</script>

<script language="javascript" type="text/javascript">



var gIsMobile = '1';
var gCurPage = "empty";

var tableRule = null;


function parseData_pc_channel(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;

	arrCol[0] = items[4];
	arrCol[1] = items[0];
	arrCol[2] = items[1];
	arrCol[3] = items[2];
	arrCol[4] = items[3];
	arrCol[5] = items[5];
	arrCol[6] = items[7];
	arrCol[7] = '<input type="radio" name="sel" value="'+nRow+'" onclick="onClickSelect_channel()"></input>';

	return arrCol;
}


function initTable_pc_channel(){
	var strTableAttr = "id='Grid_Table' align='center' border='0''cellspacing='0' cellpadding='0' width='100%' valign='middle' style='table-layout:fixed;'";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "style=word-break:break-all";
	var strTableTd_nopadding = "style=word-break:break-all";


	tableRule = new MCRTable("view_aplist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"AP 정보가 없습니다.", "\r", parseData_pc_channel );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "신호", "width='8%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선 LAN 이름", "width='20%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "BSSID", "width='20%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "채널", "width='8%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "모드", "width='8%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "EncType", "width='20%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "NET", "width='8%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "선택", "width='8%'", strTableTh, strTableTd+" align='center'", "");

}


function onClickNext(curPage){
	var nextPage = "";

	if( curPage == "empty" ){
		nextPage = "wan";
	}else if( curPage == "wan" ){
		if( $("input[name='rdoOperModeWan']").val() == '1'){
			nextPage = "repeater";
		}else{
			nextPage = "dhcp";
		}
	}else if( curPage == "repeater" ){
		if( validateClientMode() ){
			nextPage = "dhcp";
		}else{
			return false;
		}
	}else if( curPage == "next_site" ){
		nextPage = "repeater";
		initValue_channel();
	}
	else if( curPage == "dhcp" ){
		if( validateOnSubmit_dhcp() ){
			if(validateClientMode()==false){
				  alert($("input[name='is_mobile']").val());
				  alert($("input[name='rdoOperModeWan']").val());
				  alert($("input[name='wlanIfIndex']").val());
				  alert($("input[name='wlanRedirectPage']").val());
				  alert($("input[name='wirelessOperMode']").val());
				  alert($("input[name='channel']").val());
				  alert($("input[name='chBandWidth']").val());
				  alert($("input[name='chExtension']").val());
				  alert($("input[name='ssid_client']").val());
				  alert($("select[name='securityMode']").val());
				  alert($("select[name='wepKeyType']").val());
				  alert($("select[name='encType']").val());
				  alert($("input[name='encKey']").val());
				  alert($("input[name='sel_connectionType']").val());
				return false;
			}
			else
				nextPage = "finish";
		}else{
			return false;
		}
	}

	if( nextPage == "wan" ){
		gCurPage = nextPage;
	}else if( nextPage == "repeater" ){
		gCurPage = nextPage;
	}else if( nextPage == "dhcp" ){
		gCurPage = nextPage;
	}
	else if( nextPage == "finish" ){
		gCurPage = nextPage;
		form_act('/goform/mcr_setSimpleConfig');
	}

	return true;

}


function channel_check(){
	if($("#check_GHz").val() == "1") {
		gWlanIfIndex=100;
		$("input[name='wlanIfIndex']").val("100");
		$("#ssid_client").val("");
		$("#encKey").val("");
		$("#view_aplist").hide();
		document.form_ippolicy.securityMode.selectedIndex=0;
		clear = 1;
		onChangeSecurityMode();
	}
	else if($("#check_GHz").val() == "0") {
		gWlanIfIndex=0;
		$("input[name='wlanIfIndex']").val("0");
		$("#ssid_client").val("");
		$("#encKey").val("");
		$("#view_aplist").hide();
		document.form_ippolicy.securityMode.selectedIndex=0;
		clear = 1;
		onChangeSecurityMode();
	}
	else if($("#check_GHz").val() == "2") {
		gWlanIfIndex=1000;
		$("input[name='wlanIfIndex']").val("1000");
		$("#ssid_client").val("");
		$("#encKey").val("");
		$("#view_aplist").hide();
		document.form_ippolicy.securityMode.selectedIndex=0;
		clear = 1;
		onChangeSecurityMode();
	}
	$('select#securityMode').selectmenu('refresh'); 
}


function checkGhz(){
	var wlanActFlag24, wlanActFlag5;
	var wlanflag;

	if($("#check_GHz").val() == "1") {
		wlanActFlag24 = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';
		if(wlanActFlag24 == 0){
			alert("2.4Ghz 무선을 활성화 시켜주세요");
			return false;
		}
		else return true;
	}
	else if($("#check_GHz").val() == "0") {
		wlanActFlag5 = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
		if(wlanActFlag5 == 0){
			alert("5Ghz 무선을 활성화 시켜주세요");
			return false;
		}
		else return true;
	}
	else if($("#check_GHz").val() == "2") {
		wlanActFlag24 = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';
		wlanActFlag5 = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
		if((wlanActFlag24 == 0) || (wlanActFlag5 == 0)){
			alert("2.4Ghz 와 5Ghz 무선을 활성화 시켜주세요");
			return false;
		}
		else return true;
	}
}


$(document).ready(function(){
		$("input[name='check_box']").bind( "click", function(){
			return onClick_WLAN_SecurityPasswordEnable(4);
		});
		$("#wlanBtnSearch").bind( "click", function(){
			if(checkGhz() == false){
				return false;
			}
			$("#view_aplist").show();

			$('a[name=wlanBtnSearch]').removeClass('ui-btn-active');
			$('a[name=wlanBtnSearch]').addClass('ui-btn-active-a');
			onClickNext('next_site');
			return false;
		}); 

		$("#wlanBtnSecurity").bind( "click", function(){
			$("input[name='sel_connectionType']").val("2");
			
			onClickNext('dhcp');
			return false;
		}); 

});


function setopmode(opmodeval){
	switch(opmodeval){
		case '0':
			mcr_clickradio_opmode('0');
			$("input[id='m_opmode']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("0");
			break;
		case '1':
			mcr_clickradio_opmode('1');
			$("input[id='m_opmode1']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("1");
			break;
		case '2':
			mcr_clickradio_opmode('2');
			$("input[id='m_opmode2']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("2");
			break;
		case '3':
			mcr_clickradio_opmode('3');
			$("input[id='m_opmode3']").attr("checked", true).checkboxradio("refresh");
			$("#opmode").val("3");
			break;
		default:
			break;
	}
		changeIpSeting();		
}

function mcr_clickradio_opmode(val){
	$('label[for=m_opmode]').removeClass('ui-btn-active');
	$('label[for=m_opmode1]').removeClass('ui-btn-active');
	$('label[for=m_opmode2]').removeClass('ui-btn-active');
	$('label[for=m_opmode3]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_opmode]').addClass('ui-btn-active-c');
			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_opmode1]').addClass('ui-btn-active-c');
			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_opmode2]').addClass('ui-btn-active-c');
			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode3]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_opmode3]').addClass('ui-btn-active-c');
			$('label[for=m_opmode]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode1]').removeClass('ui-btn-active-c');
			$('label[for=m_opmode2]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setrepeater_en(repeaterval){
	switch(repeaterval){
		case '1':
			$("#repeater_en").val("1");
			break;
		case '2':
			$("#repeater_en").val("2");
			break;
		default:
			break;
	}
	changeIpSeting();
}

function setrepeater_en1(repeaterval){
	switch(repeaterval){
		case '1':
			mcr_clickradio_repeater_en('1');
			$("input[id='m_repeater_en1']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("1");
			break;
		case '2':
			mcr_clickradio_repeater_en('2');
			$("input[id='m_repeater_en']").attr("checked", true).checkboxradio("refresh");
			$("#repeater_en").val("2");
			break;
		default:
			break;
	}
	changeIpSeting();
}

function mcr_clickradio_repeater_en(val){
	$('label[for=m_repeater_en]').removeClass('ui-btn-active');
	$('label[for=m_repeater_en1]').removeClass('ui-btn-active');
	switch(val){
		case '1':
			$('label[for=m_repeater_en1]').addClass('ui-btn-active-c');
			$('label[for=m_repeater_en]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_repeater_en]').addClass('ui-btn-active-c');
			$('label[for=m_repeater_en1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setcheck_GHz(check_GHzval){
	switch(check_GHzval){
		case '0':
			mcr_clickradio_check_GHz('0');
			$("input[id='m_check_5']").attr("checked", true).checkboxradio("refresh");
			$("#check_GHz").val("0");
			break;
		case '1':
			mcr_clickradio_check_GHz('1');
			$("input[id='m_check_24']").attr("checked", true).checkboxradio("refresh");
			$("#check_GHz").val("1");
			break;
		case '2':
			mcr_clickradio_check_GHz('2');
			$("input[id='m_check_24_5']").attr("checked", true).checkboxradio("refresh");
			$("#check_GHz").val("2");
			break;
		default:
			break;
	}
	channel_check();
}

function mcr_clickradio_check_GHz(val){
	$('label[for=m_check_5]').removeClass('ui-btn-active');
	$('label[for=m_check_24]').removeClass('ui-btn-active');
	$('label[for=m_check_24_5]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_check_5]').addClass('ui-btn-active-c');
			$('label[for=m_check_24]').removeClass('ui-btn-active-c');
			$('label[for=m_check_24_5]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_check_24]').addClass('ui-btn-active-c');
			$('label[for=m_check_5]').removeClass('ui-btn-active-c');
			$('label[for=m_check_24_5]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_check_24_5]').addClass('ui-btn-active-c');
			$('label[for=m_check_5]').removeClass('ui-btn-active-c');
			$('label[for=m_check_24]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

</script>

<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';


var maxChannelCount = 0;

var arrData = new Array();
var tableRule = null;   

var ckData = new Array();
var arrClientInfo = new Array();


function validate_wepkey(){
	var ret = 0;
	var wepKey = document.getElementById("encKey");
	var wepKeyType = document.getElementById("wepKeyType");
	var wepKeyTypeValue = parseInt( wepKeyType.value , 10 );

	if( isEmpty( wepKey.value ) == false ){
		switch(wepKeyTypeValue){
		case 0: 
			if( wepKey.value.length == 10 ) ret = 1;
			break;
		case 1: 
			if( wepKey.value.length == 10 ){
				ret = ( isHex( wepKey.value ) ) ? 1 : -1;
			} else {
				ret = -2;
			}
			break;
		}
	}

	if( ret == 1 ){
		return true;
	}else{
		if( ret == 0 ){
			alert("암호는 10자입니다.");
		} else if (ret == -2) {
			alert("암호는 10자입니다.");
		} else {
			alert("입력된 Key가 HEX 형태가 아닙니다\n");
		}
		wepKey.focus();
		return false;
	}
}


function validate_psk(){
	var ret = false;
	var pskKey = document.getElementById("encKey");

	if( isEmpty( pskKey.value ) == false ){
		if( pskKey.value.length == 64 ){        
			if( isHex( pskKey.value ) == true ){
				ret = true;
			}
		}else if( pskKey.value.length >=10 && pskKey.value.length < 64 ) 
			ret = true;
	}
	if( ret == false ){
		alert("암호는 10자 이상 64자 이하여야 합니다.");
		pskKey.focus();
	}
	return ret;
}


function validate_security(){
	var ret = false;
	var bWebKeyEnable = 0;
	var bPSKEnable = 0;

	var securityMode = document.getElementById("securityMode");
	var securityModeValue = securityMode[securityMode.selectedIndex].value;
	var encTypeIndex = document.getElementById("encType").selectedIndex;

	switch( securityModeValue ){
		case '0':       
			ret = true;
			break;
		case '3':       
			bWebKeyEnable = true;
			break;
		case '4':       
			bPSKEnable = true;
			break;
		case '5':       
			bPSKEnable = true;
			break;
		case '13': /* WPA3-PSK */
			bPSKEnable = true;
			break;
		default:
			alert("Not Supported encType");
			break;
	}

	if( bWebKeyEnable ){
		ret = validate_wepkey();
		if( ret == false ) return ret;
	}
	if( bPSKEnable ){
		ret = validate_psk();
		if( ret == false ) return ret;
	}
	return ret;
}


function validateClientMode(){
	var ret = false;
	var ssidlen = 0;
	var wanIfIndex, wanPhyIndex, wanVapIndex;
	var curIfIndex, curPhyIndex, curVapIndex;
	var strMsg = "", strFreq = "", strOperMode ="";

	ssidlen = getByteLength($("#ssid_client").val());
	if( ssidlen > 32 ){
		alert("SSID 길이가 32 bytes를 초과할 수 없습니다");
		$("#ssid_client").focus();
		return false;
	}

	ret = validate_security();
	return ret;
}


function onClickSelect_channel(){
	var ret = false;
	var strRow = null;
	var items = null;

	var row = $("input[name='sel']:checked").val();

	if( arrData != null && row != null ){
		strRow = arrData[row];
		items = strRow.split('\r');

		if( items[5].indexOf('1X') != -1 ){
			alert("802.1X 암호화 방식은 선택할 수 없습니다");
		}else if( items[7] == 'Adhoc' ){
			alert("ADHOC 장치는 선택할 수 없습니다");
		}else{
			ret = true;
		}
	}

	if(items[2] < 15){
		$("input[name='wlanIfIndex']").val("100");
	}else{
		$("input[name='wlanIfIndex']").val("0");
	}

	if( ret ){
		ckData.length = 7;
		ckData[0] = 7;                          
		ckData[1] = items[0];           
		ckData[2] = items[1];           
		ckData[3] = items[3];           
		ckData[4] = items[8];           
		ckData[5] = items[5];           
		ckData[6] = items[6];           
		$("#securityMode_AP").val(items[5]);
		$("#encType_AP").val(items[6]);
		onClickRedirect_channel();
	}else{
		ckData.length = 0;
		$("input[name='sel']:checked").attr("checked", false);
	}

}


function client_ss_convert(){
	var cookieName = "";
	var chBandWidth, channel, chExtension;
	var securityMode, encType;
	var rate = 0;

	var items = ckData;             

	if( items[4].indexOf('+') == -1 ){
		chBandWidth = '0';      
		channel = parseInt(items[4], 10);
		chExtension = '0';
	}else{
		var channelEx = items[4].split("+");
		chBandWidth = '1';      
		channel = parseInt(channelEx[0], 10);
		chExtension = parseInt(channelEx[1], 10);
	}

	if( items[5] == '-' ){          
		securityMode = '0';
		encType = '0';                  
	}else{
		if( items[5].indexOf('WPA2/WPA3') != -1 ){
			// TODO 
			securityMode = '5';
		} else if( items[5].indexOf('WPA3') != -1 ){
			securityMode = '13';
		} else if( items[5].indexOf('WPA2') != -1 ){
			securityMode = '5';
		}else if( items[5].indexOf('WPA') != -1 ){
			securityMode = '4';
		}else if( items[5].indexOf('WEP') != -1 ){
			securityMode = '3';
			encType = '0';                  
		}

		if( securityMode =='5' || securityMode =='4' || securityMode =='13' ){
			if( items[6].indexOf('AES') != -1 ){
				encType = '1';
			}else if( items[6].indexOf('TKIP') != -1 ){
				encType = '0';
			}
		}
	}
	if( items[3].indexOf('B') != -1 ){      rate += 1;      }
	if( items[3].indexOf('G') != -1 ){      rate += 2;      }
	if( items[3].indexOf('N') != -1 ){      rate += 4;      }
	if( items[3].indexOf('A') != -1 ){      rate += 8;      }

	arrClientInfo.length = 9;
	arrClientInfo[0] = arrClientInfo.length;        
	arrClientInfo[1] = items[1];                            
	arrClientInfo[2] = items[2];                            
	arrClientInfo[3] = rate;                                        
	arrClientInfo[4] = chBandWidth;                         
	arrClientInfo[5] = channel;                                     
	if( chExtension == '0' ){
		arrClientInfo[6] = null;                                
	}else{
		arrClientInfo[6] = chExtension;                 
	}
	arrClientInfo[7] = securityMode;                        
	arrClientInfo[8] = encType;                                     

	return 1;
}


function onClickRedirect_channel(){
	client_ss_convert();
	initForms(1);
}


function onClickRefresh_channel(){
	layoutStationList("AP 정보 갱신중입니다.....");
	httpRequest("/goform/mcr_getWirelessChannel?wlanIfIndex="+gWlanIfIndex, "n/a", processHttpResponse);
	clear=1;
}


function initForms_channel(flag){
	var channel, chExtension;
	if( flag == 0 ){
		onClickRefresh_channel();
	}else if( flag == 1 ){
		updateFormValue_channel(flag);
	}

	ckData.length = 0;
}


function initValue_channel(){
	initForms_channel(0);
}


function updateFormValue_channel(useDefault){
	if( useDefault == 1 ){
		if( arrData == null || arrData.length == 0 ){
			layoutStationList("AP 정보가 없습니다.");
		}else{
			layoutStationList();
		}
	}
}


function layoutStationList(strMsg){
	if( tableRule == null ){
		initTable_pc_channel();
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


function processHttpResponse(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	arrData.length = 0;

	maxChannelCount = parseInt(lineArr[0], 10);
	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 0 ){
			arrData[row] = lineArr[row+rowOnly];
		}
	}
	initForms_channel(1);
}

function updateClientSecurity(ssid, security, encType, encKey, wepKeyType){
	var securityMode = '0';
	var encTypeVal = '0';

	if( security == '1' || security == '2' || security == '3' ){
		securityMode = '3';     
	}else if( security == '4' ){
		securityMode = '4';
		if( encType == '2' || encType == '1' ){ 
			encTypeVal = '1';       
		}else{
			encTypeVal = '0';       
		}
	}else if( security == '5' || security == '6' ){
		securityMode = '5';
		if( encType == '2' || encType == '1' ){ 
			encTypeVal = '1';       
		}else{
			encTypeVal = '0';       
		}
	} else if( security == '13' || security == '14' ){
		//wpa3-psk, wpa2/wpa3-psk
		securityMode = '13';
		if( encType == '2' || encType == '1' ){ //TKIP/AES, AES
			encTypeVal = '1';   //AES
		}else{
			encTypeVal = '0';   //TKIP
		}
	}

	initTextById("ssid_client", ssid);
	initTextById("encKey", encKey);
	initComboById("securityMode", securityMode);
	initComboById("encType", encTypeVal);
	initComboById("wepKeyType", wepKeyType);

	if( gIsMobile == '1' ){
		$('select#securityMode').selectmenu('refresh'); 
		$('select#encType').selectmenu('refresh'); 
		$('select#wepKeyType').selectmenu('refresh'); 
	}

}


function onChangeSecurityMode(){
	var securityMode = document.getElementById("securityMode");
	var encType = document.getElementById("encType");
	var securityModeValue = securityMode[securityMode.selectedIndex].value;

	switch( securityModeValue ){
		case '0': /* Open */ 
			$("#view_encType").hide();
			$("#view_encKey").hide();
			$("#view_webKeyType").hide();
			break;
		case '3': /* WEP */
			$("#view_encType").hide();
			$("#view_encKey").show();
			$("#view_webKeyType").show();
			break;
		case '4': /* WPA-PSK */ 
		case '5': /* WPA2-PSK */
		case '13': /* WPA3-PSK */
			$("#view_encType").show();
			$("#view_encKey").show();
			$("#view_webKeyType").hide();
			break;
		default:
			alert("Not Supported SecurityMode");
			break;
	}
}

function validateOnSubmit_dhcp(){
	var dns1, dns2;

	if( $("#sel_connectionType").val() == 1 ){
		if (!checkIpAddr(document.getElementById('txt_staticIp'), "IP 주소를 ", 1)) return false;
		if (!checkIpAddr(document.getElementById('txt_staticNetmask'), "서브넷 마스크를 ", 2)) return false;
		if (!checkIpAddr(document.getElementById('txt_staticGateway'), "게이트웨이 주소를 ", 0)) return false;

		dns1 = document.getElementById('txt_staticDnsAddr1');
		dns2 = document.getElementById('txt_staticDnsAddr2');
		if (!checkIpAddr( dns1, "기본 DNS 주소를 ", 1)) return false;
		if (dns2.value.length > 0) {    
			if (!checkIpAddr(dns2, "보조 DNS 주소를 ", 1)) return false;
		}
	}else{
		if( $("input[name='rdo_dhcpDnsType']").val() == 1 ){
			dns1 = document.getElementById('txt_dhcpDnsAddr1');
			dns2 = document.getElementById('txt_dhcpDnsAddr2');
			if (!checkIpAddr( dns1, "기본 DNS 주소를 ", 1)) return false;
			if (dns2.value.length > 0) {    
				if (!checkIpAddr(dns2, "보조 DNS 주소를 ", 1)) return false;
			}
		}
	}

	return true;
}


function onClickWanType(){
	initForms(1);
}

function initForms(useDefault){
	if( useDefault == 0 ){
		gOperModeWan =          '<% mcr_getCfgCommon("SysOperMode_WanInterface"); %>';
		gWirelessOperMode =     '<% mcr_getCfgWireless("Wlan_WirelessOperMode",         gWlanIfIndexEJ); %>';
		gClient_ssid =          '<% mcr_getCfgWireless("Wlan_SSID",                     gWlanIfIndexEJ+'4'); %>';
		gClient_security =      '<% mcr_getCfgWireless("Wlan_SecurityMode",     gWlanIfIndexEJ+'4'); %>';
		gClient_encType =       '<% mcr_getCfgWireless("Wlan_EncryptType",              gWlanIfIndexEJ+'4'); %>';
		gClient_encKey =        '<% mcr_getCfgWireless("Wlan_WEPPSKKey",                gWlanIfIndexEJ+'4'); %>';
		gClient_keyType =       '<% mcr_getCfgWireless("Wlan_KeyType",                  gWlanIfIndexEJ+'4'); %>';

		gChannel =                      '<% mcr_getCfgWireless("Wlan_Channel",                  gWlanIfIndexEJ); %>';
		gChBandWidth =          '<% mcr_getCfgWireless("Wlan_ChannelBandWidth", gWlanIfIndexEJ); %>';
		gChExtension =          '<% mcr_getCfgWireless("Wlan_ChannelExtension", gWlanIfIndexEJ); %>';

		gWanConnType =          '<% mcr_getCfgCommon("WanDevice_WanConnType"); %>';

		$("input[name='rdoOperModeWan']").val([ gOperModeWan ]);
		$("#sel_connectionType").val('2');
	}
	if( $("input[name='rdoOperModeWan']").val() == '1' ){
		gOperModeWan = '1';
		gWirelessOperMode = '4';        
	}else{
		gOperModeWan = '0';
		gWirelessOperMode = '0';        
	}

	if( arrClientInfo.length != 0 ){
		gClient_ssid            = arrClientInfo[1];
		gChBandWidth            = arrClientInfo[4];
		gChannel                = arrClientInfo[5];
		gChExtension            = arrClientInfo[6];
		gClient_security        = arrClientInfo[7];
		gClient_encType         = arrClientInfo[8];
		gClient_keyType         = '0';                                  

		gOperModeWan = '1';
		gWirelessOperMode = '4';        
	}

	if( gOperModeWan == '0' ){      
		updateClientSecurity('', '0', '0', '', '0');
	}else{                                          
		if(clear == "1"){
			updateClientSecurity(gClient_ssid, gClient_security, gClient_encType, '', gClient_keyType);
		}else
			updateClientSecurity(gClient_ssid, gClient_security, gClient_encType, gClient_encKey, gClient_keyType);
	}

	$("input[name='wirelessOperMode']").val( gWirelessOperMode );
	$("input[name='channel']").val( gChannel );
	$("input[name='chBandWidth']").val( gChBandWidth );
	$("input[name='chExtension']").val( gChExtension );

	$("input[name='rdoOperModeWan']").val([ gOperModeWan ]);

	$("input[name='is_mobile']").val("1");  

	onChangeSecurityMode();
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form_ippolicy" data-ajax="false">

<input type="hidden" id="opmode_sohozone" name="opmode_sohozone" value="0">


<input type="hidden" id="is_mobile" name="is_mobile" value="">
<input type="hidden" id="rdoOperModeWan" name="rdoOperModeWan" value="">
<input type="hidden" id="wirelessOperMode" name="wirelessOperMode" value="">
<input type="hidden" id="channel" name="channel" value="0">
<input type="hidden" id="chBandWidth" name="chBandWidth" value="0">
<input type="hidden" id="chExtension" name="chExtension" value="0">


<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="0">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="">

<input type="hidden" id="securityMode_AP" name="securityMode_AP" value="">
<input type="hidden" id="encType_AP" name="encType_AP" value="">

<input type="hidden" id="opmode" name="opmode" value="">
<input type="hidden" id="option60_en" name="option60_en" value="">
<input type="hidden" id="option77_en" name="option77_en" value="">
<input type="hidden" id="repeater_en" name="repeater_en" value="">
<input type="hidden" id="check_GHz" name="check_GHz" value="">
<input type="hidden" id="sel_connectionType" name="sel_connectionType" value="2">
<input type="hidden" id="rdo_dhcpDnsType" name="rdo_dhcpDnsType" value="0">

<input type="hidden" name="SETIPMODE" value="/new/mobile_03_1_1_ip_assign_policy.asp">
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그 아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
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
					IP 할당정책
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
				<td>IP 할당정책</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_opmode">kt 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode" value="0" onclick="setopmode(this.value)">
									<label for="m_opmode1">공유기 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode1" value="1" onclick="setopmode(this.value)">
									<label for="m_opmode2">브릿지 모드</label>
									<input type="radio" name="m_opmode" id="m_opmode2" value="2" onclick="setopmode(this.value)">
									
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="btn_check" style="display:none;">
				<td colspan="2">
					<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="form_act('/goform/mcr_setOpMode')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				<td>
			</tr>
		</table>
	</div>	
	<div id="WDS_en" style="padding:0 5 12 5px; display:none;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>WDS 기능</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>동작설정</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_repeater_en">　중단　</label>
									<input type="radio" name="m_repeater_en" id="m_repeater_en" value="2" onclick="setrepeater_en1(this.value)">
									<label for="m_repeater_en1">　리피터 모드　</label>
									<input type="radio" name="m_repeater_en" id="m_repeater_en1" value="1" onclick="setrepeater_en1(this.value)">
								</fieldset>
							</td>
						<tr>
					</table>
				</td>
			</tr>
			<tr id="B_mode" style="display:none;">
				<td>
					<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="form_act('/goform/mcr_setOpMode')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				<td>
			</tr>
		</table>
	</div>
	<div id="Multipoint_Brigde" style="padding:0 5 12 5px; display:none;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>리피터 설정 대역</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_check_24">2.4GHz</label>
									<input type="radio" name="m_check_GHz" id="m_check_24" value="1" onclick="setcheck_GHz(this.value)">
									<label for="m_check_5">5GHz</label>
									<input type="radio" name="m_check_GHz" id="m_check_5" value="0" onclick="setcheck_GHz(this.value)">
									<label for="m_check_24_5">2.4Ghz+5GHz</label>
									<input type="radio" name="m_check_GHz" id="m_check_24_5" value="2" onclick="setcheck_GHz(this.value)">
								</fieldset>
							</td>
							<td>
								<a href="javascript:;" id="wlanBtnSearch" name="wlanBtnSearch" data-theme="a" data-role="button" data-mini="false" data-ajax="false">검색</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<div>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="8%" style="word-break:break-all">신호</td>
								<td width="20%" style="word-break:break-all">무선 LAN 이름</td>
								<td width="20%" style="word-break:break-all">BSSID</td>
								<td width="8%" style="word-break:break-all">채널</td>
								<td width="8%" style="word-break:break-all">모드</td>
								<td width="20%" style="word-break:break-all">EncType</td>
								<td width="8%" style="word-break:break-all">NET</td>
								<td width="8%" style="word-break:break-all">선택</td>
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
	<div id="security_check" style="padding:0 5 12 5px; display:none;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr id="view_ssid_client">
							<td id="lbl_ssid_client" nowrap="nowrap">네트워크 이름(SSID)</td>
							<td nowrap="nowrap">
								<input type="text" id="ssid_client" name="ssid_client" size="32" maxlength="32" value="">
							</td>
						</tr>
						<tr id="view_securityMode">
							<td id="lbl_securityMode" nowrap="nowrap">인증 보안 방식</td>
							<td nowrap="nowrap">
								<select id="securityMode" name="securityMode" onchange="onChangeSecurityMode()" data-mini="true">
									<option value="0">Open</option>
									<option value="3">WEP</option>
									<option value="4">WPA-PSK</option>
									<option value="5">WPA2-PSK</option>
									<option value="13">WPA3-PSK</option>
								</select>
							</td>
						</tr>
						<tr id="view_webKeyType">
							<td id="lbl_wepKeyType" nowrap="nowrap">Key Type</td>
							<td nowrap="nowrap">
								<select id="wepKeyType" name="wepKeyType" data-mini="true">
									<option value="0">ASCII</option>
									<option value="1">HEX</option>
								</select>
							</td>
						</tr>
						<tr id="view_encType">
							<td id="lbl_encType" nowrap="nowrap">암호화 방식</td>
							<td nowrap="nowrap">
								<select id="encType" name="encType" onchange="onChangeEncType()" data-mini="true">
									<option value="0">TKIP</option>
									<option value="1">AES</option>
								</select>
							</td>
						</tr>
						
						<tr id="view_encKey">
							<td id="lbl_key" nowrap="nowrap">네트워크 암호</td>
							<td nowrap="nowrap">
								<input type="password" autocomplete="off" id="encKey" name="encKey" size="32" maxlength="64" value=""></input> 암호키보기
								<input type="checkbox" name="check_box" id="check_box" data-role="none">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:;" id="wlanBtnSecurity" name="wlanBtnSecurity" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				<td>

			</tr>
		</table>
	</div>
	<div id="policy_ip_per_port" style="padding:0 5 12 5px; display:none;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>포트별 IP 할당정책</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>PORT</td>
							<td>할당정책</td>
							<td>PORT</td>
							<td>할당정책</td>
						</tr>
						<tr>
							<td>LAN1</td>
							<td>
								<select name="port1_policy" id="port1_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
							<td><label id="lbl_wireless_ippolicy_ollehbasic">ollehWiFi(Basic)</label></td>
							<td>
								<select name="nespot_policy" id="nespot_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
						</tr>
						<tr>
							<td>LAN2</td>
							<td>
								<select name="port2_policy" id="port2_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
							<td>ollehWiFi</td>
							<td>
								<select name="show_policy" id="show_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
						</tr>
						<tr>
							<td>LAN3</td>
							<td>
								<select name="port4_policy" id="port4_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
							<td>Home WLAN</td>
							<td>
								<select name="home_policy" id="home_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
						</tr>
						<tr id="Soip_del">
							<td>LAN4</td>
							<td>
								<select name="port3_policy" id="port3_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
							<td></td>
							<td>
								<select name="soip_policy" id="soip_policy" data-mini="true">
									<option selected="selected" value="2"> 다이나믹 </option>
									<option value="3"> 공인 </option>
									<option value="4"> 사설 </option>
								</select>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="form_act('/goform/mcr_setdhcpProxy'); return false;" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				<td>
			</tr>

		</table>
	</div>
	<div id="access_limit" style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>접속 수 제한</td>
			</tr>
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>유선 단말</td>
							<td>
								<input name="wired_limit" type="text" id="wired_limit">
							</td>
						</tr>
						<tr>
							<td>무선 단말</td>
							<td>
								<input name="wireless_limit" type="text" id="wireless_limit">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply6" name="btn_apply6" onclick="form_act('/goform/mcr_setdhcpProxyLimit'); return false;" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
				<td>
					<a href="javascript:;" id="btn_apply7" name="btn_apply7" onclick="return CheckCancel('wired_limit', 'wireless_limit')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">취소</a>
				<td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
