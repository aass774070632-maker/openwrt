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

.TB-1{
	width:730px;  
	table-layout:fixed;
}
-->
</style>
<script>
<%include('new/simpleconfig_common.asp');%>
var netsel = "<% mcr_getCfgString("PreservedConfig_KTSubscriberOperMode"); %>";
var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";
var waninterface = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";

var prevOpMode = -1;

var beforId = "menu00";
var clear = 0;

var wire_limit_val = "<% mcr_getCfgString("DhcpProxyCfgParam_wired_limit_count"); %>"
var wireless_limit_val = "<% mcr_getCfgString("DhcpProxyCfgParam_wireless_limit_count"); %>"

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

function mcr_getSystemIPPolicy(){
	var curOpMode;
	if(opmode == "1" && netsel == "0") {
		curOpMode = 0;
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
	curOpMode = $("input[name='opmode']:checked").val();
	
	return curOpMode;
}

function changeIpSeting() {
	if(form_ippolicy.opmode[0].checked) {
		$("#btn_check").show();
		$("#WDS_en").hide();
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");

		form_ippolicy.repeater_en[0].checked = true;
		$("#wirelessOperMode").val( '0' );

		parent.document.getElementById("main").style.height=724;
		parent.document.getElementById("menu").style.height=724;
	} else if(form_ippolicy.opmode[1].checked) {
		$("#btn_check").show();
		$("#WDS_en").hide();
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");

		form_ippolicy.repeater_en[0].checked = true;
		$("#wirelessOperMode").val( '0' );

		parent.document.getElementById("main").style.height=724;
		parent.document.getElementById("menu").style.height=724;
	} else if(form_ippolicy.opmode[2].checked) {
		$("#btn_check").show();
		$("#WDS_en").hide();
		$("#Multipoint_Brigde").hide();
		$("#security_check").hide();
		$("input[name='rdoOperModeWan']").val("0");
		$("#wirelessOperMode").val( '0' );
	}	

	var curOpMode = mcr_getSelectedIPPolicy();

	prevOpMode = curOpMode;
	changeLimitCnt();
	changeTable();
}

function changeLimitCnt() {
	var limit_cnt_en = "<% mcr_getCfgString("DhcpProxyCfgParam_limit_count_enable"); %>";

	if(form_ippolicy.opmode[2].checked || opmode == 0) {
		$("#wired_limit").attr('disabled',true);
		$("#wireless_limit").attr('disabled',true);
		$("#btn_apply3").hide();
		$("#Cancel").hide();
	} else {
		if(limit_cnt_en == "0") {
			$("#wired_limit").attr('disabled',true);
			$("#wireless_limit").attr('disabled',true);
			$("#btn_apply3").hide();
			$("#Cancel").hide();
			$("#opmode2").attr('disabled',true);
		}
		else {
			$("#wired_limit").attr('disabled',false);
			$("#wireless_limit").attr('disabled',false);
			$("#btn_apply3").show();
			$("#Cancel").show();
			$("#opmode2").attr('disabled',false);
		}
	}
}

function CheckCancel(wired, wireless)
{
	document.getElementById(wired).value = wire_limit_val;
	document.getElementById(wireless).value = wireless_limit_val;
	return false;
}

function changeTable() {
	if(document.body.scrollHeight>725) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=807;
		parent.document.getElementById("menu").style.height=807;
	}
}

function CheckValue()
{
	var w = parseInt(document.form_ippolicy.wired_limit.value, 10);
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
	var confirmed = false;
	var confirmed1 = false;
	var NetKeepEn = "<% mcr_getCfgString("NetKeepCfgParam_Enable"); %>";
	if(url == "/goform/mcr_setOpMode") {
		if(waninterface == "1"){	
			confirmed = confirm("리피터 모드를 해지하려면 재부팅이 필요합니다. 모드를 변경하시겠습니까? ");
		}else{
			if(form_ippolicy.opmode[2].checked == true){
				if(NetKeepEn == "1"){
					confirmed1 = confirm("브릿지 모드 설정 시, 스마트 스케쥴러 설정은 사용할 수 없습니다. 계속하시겠습니까?");
					if(!confirmed1)
						return false;

				}
			}
			confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");
		}

		if (!confirmed)
			return false;

		parent.mcrProgress.startProgressSimple("apply", 50);
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
			} else {
				alert("접속 수 제한 설정이 변경되지 않았습니다.");
				return false;
			}
		}

		parent.mcrProgress.startProgressSimple("apply", 25);
	}
	else if(url == "/goform/mcr_setSimpleConfig") {
		var ssidlen = getByteLength($("#ssid_client").val());
		if( ssidlen == 0 ){
			var wlanActFlag5 = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
			if(wlanActFlag5 == 0){
				alert("5Ghz 무선을 활성화 시켜주세요");
				return false;
			}else{
				alert("리피터 모드로 동작합니다. SSID 가 없으므로 WPS 버튼을 이용하여 접속하셔야 합니다.\n리피터 모드 설정 시, OTV 서비스와 IPTV 서비스를 이용하실 수 없고, Wi-Fi속도가 저하될 수 있습니다.");
			}
		}else{
			confirmed= confirm("리피터 모드 설정 시, OTV 서비스와 IPTV 서비스를 이용하실 수 없고, Wi-Fi속도가 저하될 수 있습니다. 설정하시겠습니까? ");
			if(!confirmed)
				return false;
		}

		if(form_ippolicy.opmode[2].checked == true){
			if(NetKeepEn == "1"){
				confirmed1 = confirm("브릿지 모드 설정 시, 스마트 스케쥴러 설정은 사용할 수 없습니다. 계속하시겠습니까?");
				if(!confirmed1)
					return false;

			}
		}
		confirmed = confirm("단말 재부팅이 필요합니다. 재부팅 하시겠습니까?");

		if (!confirmed)
			return false;
		else
			parent.mcrProgress.startProgressSimple("apply", 65);

	}else if(url == "/goform/mcr_setdhcpProxyOpt60"){
		parent.mcrProgress.startProgressSimple("apply", 5);
	}
	form_ippolicy.action = url;
	form_ippolicy.submit();
	return false;
}

function initValue() {
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	var Check_GHz = "<% mcr_getCfgString('Wlan_WanIndex'); %>";

	if(opmode == "1" && netsel == "0") {
		form_ippolicy.opmode[0].checked = true;
	}
	else {
		if(opmode == "1"){
			if(waninterface == "0")
				form_ippolicy.opmode[1].checked = true; 
			else if(waninterface =="1")
				form_ippolicy.opmode[2].checked = true; 
			else
				form_ippolicy.opmode[1].checked = true;
		}
		else
			form_ippolicy.opmode[2].checked = true;
	}

	if(waninterface == "0")
		form_ippolicy.repeater_en[0].checked = true;
	else
		form_ippolicy.repeater_en[1].checked = true;

	if(Check_GHz == "255" || (parseInt(Check_GHz) < 100) )
		form_ippolicy.check_GHz[1].checked = true;
	else
		form_ippolicy.check_GHz[0].checked = true;

	prevOpMode = mcr_getSystemIPPolicy();
	initForms(0);
	changeIpSeting();

	document.form_ippolicy.wired_limit.value = wire_limit_val;
	document.form_ippolicy.wireless_limit.value = wireless_limit_val;

	changeTable();

	onClickNext("empty");
	$("#wlanRedirectPage").val("/new/UserFolder/3_1_1_ip_assign_policy.asp");
	parent.mcrProgress.stopProgress();
}

</script>

<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/jquery.crypt.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>'></script>

<script language="javascript" type="text/javascript">

var gIsMobile = '0';
var gCurPage = "empty";

var tableRule = null;

function parseData_pc_channel(nRow, aColumns, aRow, strSplit){
        var items = aRow.split(strSplit);
        var arrCol = new Array( aColumns.length );
        var nOffset = 0;
	if(items[4] >= -55){
		if(items[5] == 'OPEN')
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_04.png" width="22" height="20"></p>';
		else
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_04_c.png" width="22" height="20"></p>';
	}
	else if((-55 > items[4]) && (items[4] >= -70)){
		if(items[5] == 'OPEN')
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_03.png" width="22" height="20"></p>';
		else
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_03_c.png" width="22" height="20"></p>';
	}
	else if((-70 > items[4]) && (items[4] >= -85)){
		if(items[5] == 'OPEN')
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_02.png" width="22" height="20"></p>';
		else
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_02_c.png" width="22" height="20"></p>';
	}
	else if((-85 > items[4]) && (items[4] >= -100)){
		if(items[5] == 'OPEN')
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_01.png" width="22" height="20"></p>';
		else
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_01_c.png" width="22" height="20"></p>';
	}
	else{
		if(items[5] == 'OPEN')
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_00.png" width="22" height="20"></p>';
		else
			items[4] = '<p><img src="/images/WIFI_IMG/icon_list_wifi_00_c.png" width="22" height="20"></p>';
	}

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
	var strTableAttr = "class='TB TB-1' id='Grid_Table' border='0' bgcolor='#FFFFFF'";
        var strTableTr = "bgcolor='#FFFFFF'";
        var strTableTh = "class='BG1'";
        var strTableTd = "class='BG2-2'";
	var strTableTd_nopadding = "class='BG2-2-2'";


        tableRule = new MCRTable("view_aplist",
                        MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
                        strTableAttr,
                        "",
                        strTableTr,
                        "AP 정보가 없습니다.", "\r", parseData_pc_channel );
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "신호", "width='40'", strTableTh, strTableTd_nopadding+" align='center'", "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선 LAN 이름", "width='200'", strTableTh, strTableTd, "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "BSSID", "width='120'", strTableTh, strTableTd, "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "채널", "width='70'", strTableTh, strTableTd+" align='center'", "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "모드", "width='50'", strTableTh, strTableTd+" align='center'", "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "EncType", "width='130'", strTableTh, strTableTd+" align='center'", "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "NET", "width='40'", strTableTh, strTableTd+" align='center'", "");
        tableRule.addColumn(MCRColumn.TYPE_NORMAL, "선택", "width='40'", strTableTh, strTableTd+" align='center'", "");

}

function onClickNext(curPage){
	var nextPage = "";

	if( curPage == "empty" ){
		nextPage = "wan";
	}else if( curPage == "wan" ){
		if( $("input[name='rdoOperModeWan']:checked").val() == '1' ){
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
		if(validateClientMode()==false){
			return false;
		}
		else
			nextPage = "finish";
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

function update_wlan_freq(){
	if(document.form_ippolicy.check_GHz[0].checked) {
		gWlanIfIndex=100;
		$("#wlanIfIndex").val("100");
	}
	else if(form_ippolicy.check_GHz[1].checked) {
		gWlanIfIndex=0;
		$("#wlanIfIndex").val("0");
	}
	else if(form_ippolicy.check_GHz[2].checked) {
		gWlanIfIndex=1000;
		$("#wlanIfIndex").val("1000");
	}
}

function channel_check(){
	update_wlan_freq();
	
	$("#ssid_client").val("");
	$("#view_aplist").hide();
	document.form_ippolicy.securityMode.selectedIndex=0;
	clear = 1;
	onChangeSecurityMode();
		
}

function checkGhz(){
	var wlanActFlag24, wlanActFlag5;
	var wlanflag;

	if(document.form_ippolicy.check_GHz[0].checked) {
		wlanActFlag24 = '<% mcr_getCfgWireless("Wlan_Enable", 100); %>';
		if(wlanActFlag24 == 0){
			alert("2.4Ghz 무선을 활성화 시켜주세요");
			return false;
		}
		else return true;
	}else if(form_ippolicy.check_GHz[1].checked) {
		wlanActFlag5 = '<% mcr_getCfgWireless("Wlan_Enable", 0); %>';
		if(wlanActFlag5 == 0){
			alert("5Ghz 무선을 활성화 시켜주세요");
			return false;
		}
		else return true;
	}else if(form_ippolicy.check_GHz[2].checked) {
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
	$("#wlanBtnSearch").bind( "click", function(){
		if(checkGhz() == false){
			return false;
		}
		$("#view_aplist").show();
		onClickNext('next_site');
		return false;
	});

	$("#wepKeyType").bind("change", function(){
		var wepKeyType = document.getElementById("wepKeyType");
		var wepKeyTypeValue = parseInt( wepKeyType.value , 10 );

		if(wepKeyTypeValue == 0){
			$("#password_stat").text("암호는 10자입니다.");
		}else{
			$("#password_stat").text("암호는 10자입니다.");
		}
	});
	$("#wlanBtnSecurity").bind( "click", function(){
		onClickNext('dhcp');
		return false;
	});
	$("input[name='check_box']").bind( "click", function(){
		return onClick_WLAN_SecurityPasswordEnable(4);
	});

	$("input[type='text']").mjq_disableInputEnter();
	$("body").mjq_disableInputEnter();
});

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

<body onLoad="initValue()">
<form name="form_ippolicy" method="POST">

<input type="hidden" id="is_mobile" name="is_mobile" value=""/>
<input type="hidden" id="rdoOperModeWan" name="rdoOperModeWan" value=""/>
<input type="hidden" id="wirelessOperMode" name="wirelessOperMode" value=""/>
<input type="hidden" id="channel" name="channel" value="0"/>
<input type="hidden" id="chBandWidth" name="chBandWidth" value="0"/>
<input type="hidden" id="chExtension" name="chExtension" value="0"/>

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="0"/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>

<input type="hidden" id="securityMode_AP" name="securityMode_AP" value=""/>
<input type="hidden" id="encType_AP" name="encType_AP" value=""/>
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_1_menu3rd.asp');%>
        	</td>
	</tr>
 
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETIPMODE value="/new/UserFolder/3_1_1_ip_assign_policy.asp" />
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top" >
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> IP 할당정책</td>
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
											<td height="25" class="BG2" style="width:140px;">IP 할당정책</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<td width="100">
														<input type="radio" name="opmode" id="opmode" value="0" onClick="changeIpSeting()"/>
														kt 모드</td>
													<td width="100">
														<input name="opmode" type="radio" id="opmode1" value="1"  onClick="changeIpSeting()"/>
														공유기 모드
													</td>
													<td width="100">
														<input name="opmode" type="radio" id="opmode2" value="2" onClick="changeIpSeting()"/>
														브릿지 모드
													</td>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="btn_check" style="display:none;">
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply" onclick="form_act('/goform/mcr_setOpMode'); return false;"/></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="WDS_en" style="display:none;">
					<td>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
                                                	<tr>
                                                        	<td class="font5"> WDS 기능</td>
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
                                                                                        <td class="BG2" style="width:140px;">동작 설정</td>
                                                                                        <td class="BG2-2">
                                                                                                <table border="0" cellpadding="0" cellspacing="0" class="font1">
                                                                                                        <tr>
                                                                                                                <td width="100">
                                                                                                                        <input type="radio" name="repeater_en" id="repeater_en" value="2" onClick="changeIpSeting()"/>
                                                                                                                        중단</td>
                                                                                                                <td width="100">
                                                                                                                        <input name="repeater_en" type="radio" id="repeater_en1" value="1" onClick="changeIpSeting()"/>
                                                                                                                        리피터
                                                                                                                </td>
                                                                                                        </tr>
                                                                                                </table>
                                                                                        </td>
                                                                                </tr>
                                                                        </table>
								</td>
							</tr>
							<tr id="B_mode" style="display:none;">
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" value="Apply" id="btn_apply10" name="btn_apply10" onclick="form_act('/goform/mcr_setOpMode'); return false;"/>
								</td>
							</td>
						</table>
					</td>
				</tr>
				<tr id="Multipoint_Brigde" style="display:none;">
                                        <td>

                                                <table width="98%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                                <td class="font5">리피터 설정 대역</td>
                                                        </tr>
                                                        <tr>
                                                                <td class="PD4"></td>
                                                        </tr>
                                                        <tr>
                                                                <td class="PD5"></td>
                                                        </tr>
                                                        <tr>
                                                                <td>
                                                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                        <td width="100">
                                                                                                <input type="radio" name="check_GHz" id="check_24" value="1" Onclick="channel_check()"> 2.4GHz
                                                                                        </td>
                                                                                        <td width="100">
                                                                                                <input type="radio" name="check_GHz" id="check_5" value="0" Onclick="channel_check()"> 5GHz
                                                                                        </td>
                                                                                        <td width="120">
                                                                                                <input type="radio" name="check_GHz" id="check_24_5" value="2" Onclick="channel_check()"> 2.4GHz+5GHz
                                                                                        </td>
											
                                                                                        <td>
                                                                                                <input type="image" src="/images/BTN/BTN_07.gif?Sp2" width="52" height="24" value="wlanBtnSearch" id="wlanBtnSearch" name="wlanBtnSearch">
                                                                                        </td>
                                                                                </tr>
                                                                        </table>
                                                                </td>
                                                        </tr>
                                                        <tr>
								<td>
                                                                        <div>
                                                                                <table class='TB TB-1' id='Grid_Table' width='100%' border='0' style='table-layout:fixed;' bgcolor='#FFFFFF'>
                                                                                        <tr height="20">
                                                                                                <td class="BG1" width="40">신호</td>
                                                                                                <td class="BG1" width="200">무선 LAN 이름</td>
                                                                                                <td class="BG1" width="120">BSSID</td>
                                                                                                <td class="BG1" width="70">채널</td>
                                                                                                <td class="BG1" width="50">모드</td>
                                                                                                <td class="BG1" width="130">EncType</td>
                                                                                                <td class="BG1" width="40">NET
                                                                                                <td class="BG1" width="40">선택</td>
												
                                                                                        </tr>
										</table>
                                                                        </div>
                                                                </td>
                                                        </tr>
                                                        <tr height="120">
                                                                <td width="670" valign="top">
									<div id="view_aplist" style="height:120; width:750; overflow:-moz-scrollbars-vertical; overflow-x:no; overflow-y:auto;"></div>
                                                                </td>
                                                        </tr>
                                                </table>
                                        </td>
                                </tr>
                                <tr id="security_check" style="display:none;">
                                        <td>
                                                <table width="98%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                                <td height="3px"></td>
                                                        </tr>
                                                        <tr>
                                                                <td>
                                                                        <table width="100%" border="0" class="font1 TB"> 
                                                                                <tr id="view_ssid_client">
                                                                                        <td id="lbl_ssid_client" class="BG2" style="width:140px" nowrap>네트워크 이름(SSID)</td>
                                                                                        <td class="BG2-2" width="580" nowrap>
                                                                                                <input class="ime_enable" type="text" onmouseover="unlock();" onmouseout="lock();" id="ssid_client" name="ssid_client" size="32" maxlength="32" value=""></input>
                                                                                        </td>
                                                                                </tr>
                                                                                <tr id="view_securityMode">
                                                                                        <td id="lbl_securityMode" class="BG2" style="width:140px" nowrap>인증 보안 방식</td>
                                                                                        <td class="BG2-2" width="580" nowrap>
                                                                                                <select class="wldef" id="securityMode" name="securityMode" onchange="onChangeSecurityMode()">
                                                                                                        <option value="0">Open</option>
                                                                                                        <option value="3">WEP</option>
                                                                                                        <option value="4">WPA-PSK</option>
                                                                                                        <option value="5">WPA2-PSK</option>
                                                                                                        <option value="13">WPA3-PSK</option>
                                                                                                </select>
                                                                                        </td>
										</tr>
                                                                                <tr id="view_webKeyType">
                                                                                        <td id="lbl_wepKeyType" class="BG2" style="width:140px" nowrap>Key Type</td>
                                                                                        <td class="BG2-2" width="580" nowrap>
                                                                                                <select class="wldef" id="wepKeyType" name="wepKeyType">
                                                                                                        <option value="0">ASCII</option>
                                                                                                        <option value="1">HEX</option>
                                                                                                </select>
                                                                                        </td>
                                                                                </tr>
                                                                                <tr id="view_encType">
                                                                                        <td id="lbl_encType" class="BG2" style="width:140px" nowrap>암호화 방식</td>
                                                                                        <td class="BG2-2" width="580" nowrap>
                                                                                                <select class="wldef" id="encType" name="encType" onchange="onChangeEncType()">
                                                                                                        <option value="0">TKIP</option>
                                                                                                        <option value="1">AES</option>
                                                                                                </select>
                                                                                        </td>
                                                                                </tr>
                                                                                <tr id="view_encKey">
                                                                                        <td id="lbl_key" class="BG2" style="width:140px" nowrap>네트워크 암호</td>
                                                                                        <td class="BG2-2" width="580" nowrap>
												<input type="password" autocomplete="off" onmouseover="unlock();" onmouseout="lock();" id="encKey" name="encKey" size="32" maxlength="64" value=""></input> 암호키보기
												<input type="checkbox" name="check_box" name="check_box" tabindex="4" value="1"/>
													<label id="password_stat"></label>
											</td>
                                                                                </tr>
                                                                        </table>
                                                                </td>
                                                        </tr>
                                                        <tr>
                                                                <td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" value="wlanBtnSecurite" id="wlanBtnSecurity" name="wlanBtnSecurity" /></td>
                                                        </tr>
                                                </table>
                                        </td>
                                </tr>
			 
				<tr id="access_limit">
					<td>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">접속 수 제한</td>
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
														<td class="BG2" style="width:190px;">유선 단말</td>
														<td class="BG2-2"><input name="wired_limit" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="wired_limit"> ( 0 ~ 255 )</td>
													</tr>
													<tr>
														<td class="BG2" style="width:190px;">무선 단말</td>
														<td class="BG2-2"><input name="wireless_limit" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="wireless_limit"> ( 0 ~ 255 )</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<p align="right"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply3" id="btn_apply3" name="btn_apply3" onclick="form_act('/goform/mcr_setdhcpProxyLimit'); return false;"/>
									<input id="Cancel" name="Cancel" type="image" src="/images/BTN/BTN_04.gif?Sp2" width="52" height="24" onclick="return CheckCancel('wired_limit', 'wireless_limit')" />
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
