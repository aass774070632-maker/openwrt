<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>"></script>

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
	document.form_basic.action = "/goform/mcr_KTlogOut";
	document.form_basic.submit();
}

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var userPri = 0;

var cpuName;
var gUserPrivilege;
var gProjectCode;
var gFreqType;
var gAutoChannelRange, gAvailChannelRange;
var gBandMode;
var gChBandWidth;
var gOrgWirelessMode;
var gOrgBandWidth;

var arrData = new Array();
var tableRule = null;


function updatePrimaryChannel(freqType, projectCode, defaultChannel, nChBandWidth, nAvailChannelRange){
	setPrimaryChannel("uiChannel", defaultChannel, freqType, projectCode, nChBandWidth, nAvailChannelRange, false );
	$("#uiChannel").selectmenu('refresh');
	
}


function updateChannelExtension(defaultChExtension){
	var nChBandWidth = $("#chBandWidth").val();
	
	setChannelExtension("uichExtension", "uiChannel", gFreqType, gProjectCode, nChBandWidth, defaultChExtension);
	$("#uichExtension").selectmenu('refresh');
}


function updateWirelessMode(freqType, cWirelessMode){
	mcr_setWirelessMode(cWirelessMode);
	mcr_showWirelessMode();
}

function mcr_getWebName_WirelessMode(){
	var strName;
	if( gFreqType == '1' ){
		strName = 'uiWirelessMode_2G';
	}else{
		strName = 'uiWirelessMode_5G';
	}
	return strName;
}

function mcr_getWirelessMode(){
	var strName = mcr_getWebName_WirelessMode();
	var wirelessModeVal = $("input[name='"+strName+"']:checked").val();

	if(strName == "uiWirelessMode_2G"){
		wirelessModeVal= $("#uiWirelessMode_2G").val();
	}else{
		wirelessModeVal= $("#uiWirelessMode_5G").val();
	}

	$("#wirelessMode").val(wirelessModeVal);

	return wirelessModeVal;
}

function mcr_setWirelessMode(cWirelessMode){
	var strName = mcr_getWebName_WirelessMode();

	if(strName == "uiWirelessMode_2G"){
		setuiWirelessMode_2G(cWirelessMode);
	}else{
		setuiWirelessMode_5G(cWirelessMode);
	}

	$("#wirelessMode").val( cWirelessMode );
}

function mcr_showWirelessMode(){
	var strName;
	if( gFreqType == '1' ){
		$("#view_wireless_mode_2G").show();
		$("#view_wireless_mode_5G").hide();
	}else{
		$("#view_wireless_mode_2G").hide();
		$("#view_wireless_mode_5G").show();
	}
}

function getBandWidthAvailChannelRange(){
	return gAvailChannelRange;
	
}

function updateChannelMode(channel){
	var availChannelRange;
	if( channel == '0' ){
		if( !(gAutoChannelRange & (1<<30)) ){
			setuiChannelMode('0');	
		}else{
			setuiChannelMode('-2');	
		}
	}else{
		setuiChannelMode('-1');	
		$("#uiChannel").val( [channel] );       
	}
}

function updateBandWidth(freqType, nWirelessMode, defaultBandWidth){
	var ieee11acDisplay;
	var ieee11nDisplay;
	var checked = $("input[name='m_uiWirelessMode_5G']:checked").val();
	if( defaultBandWidth == '-1' ){
		if( freqType == '2' ){	
			if( nWirelessMode & 0x10 || nWirelessMode & 0x20){	// 11ac or 11ax
				defaultBandWidth = '2';
			}else if( nWirelessMode & 0x04 ){	//11n
				defaultBandWidth = '1';
			}
		}

		if( defaultBandWidth == '-1'){
			defaultBandWidth = '0';
		}
	}
	if( nWirelessMode & 0x04 || nWirelessMode & 0x10 || nWirelessMode & 0x20){ //11n or 11ac or 11ax	
		ieee11nDisplay = true;
		if( nWirelessMode & 0x10 || nWirelessMode & 0x20) //11ac or 11ax
			ieee11acDisplay = true;
	}else{
		ieee11nDisplay = false;
		defaultBandWidth = '0';
	}
		
	if( freqType == '1' ){ //2.4GHz + 80H
		$("label[for='m_chBandWidth2']").hide();
		$("input[id='m_chBandWidth2']").hide();
	}else{ //5GHz
		if(ieee11acDisplay){	//11ac, 11ax
			$("label[for='m_chBandWidth2']").show();
			$("input[id='m_chBandWidth2']").show();
			$("#wireless_mode_5G").val("0");
					
		}else{ //80M
			$("label[for='m_chBandWidth2']").hide();
			$("input[id='m_chBandWidth2']").hide();
		}
	}
	
	if( defaultBandWidth != null ){
		setchBandWidth(defaultBandWidth);
	}
	
	if( ieee11nDisplay ){
		$("#view_chBandWidth").show();
	}else{
		$("#view_chBandWidth").hide();
	}	
}



function onClickChannelScan(){
	layoutStationList("AP 정보 갱신중입니다.....");
	httpRequest("/goform/mcr_getWirelessChannel?wlanIfIndex="+gWlanIfIndex, "n/a", processHttpResponse);
}

function onChangeChannel(defaultChExtension){
	updateChannelExtension(defaultChExtension);
	onAutoChannelRange();
}

function onChangeChannelBandWidth(defaultChannel, defaultChExtension, defaultRate){
	var ieee11nDisplay = true;
	var wirelessModeVal = mcr_getWirelessMode();
	var nWirelessMode = parseInt(wirelessModeVal, 10);

	var varChBandWidth = $("#chBandWidth").val();
	var nChBandWidth = parseInt(varChBandWidth,10); 
	
	if( nWirelessMode & 0x04 || nWirelessMode & 0x10 || nWirelessMode & 0x20){	//11n or 11ac
		ieee11nDisplay = true;
	}else{
		ieee11nDisplay = false;
		nChBandWidth = 0;		
	}
	
	updatePrimaryChannel(gFreqType, gProjectCode, defaultChannel, nChBandWidth, gAvailChannelRange );
		
	$("#view_chExtension").hide();
	
	setAutoChannelRange("view_autochannelrange_div", gFreqType, gProjectCode, nChBandWidth, gAvailChannelRange, 7, 1);
	gChBandWidth = ''+nChBandWidth;
	setAutoChannelRangeValue(gFreqType, gAutoChannelRange);
	
	updateDataRate(document.getElementById("mcs"), 
		defaultRate, gFreqType, gBandMode, nWirelessMode, nChBandWidth);
	$("#mcs").selectmenu('refresh');
	onChangeChannel(defaultChExtension); 	
}


function onChangeWirelessMode(defaultBandWidth, defaultChannel, defaultChExtension, defaultRate){
	var wirelessModeVal = mcr_getWirelessMode();
	var nWirelessMode = parseInt(wirelessModeVal, 10);

	updateBandWidth(gFreqType, nWirelessMode, defaultBandWidth); //확인
	
	onChangeChannelBandWidth(defaultChannel, defaultChExtension, defaultRate);
}


function onAutoChannelRange(){
	var availChannelRange = getBandWidthAvailChannelRange();
	var autoChannelRange = gAutoChannelRange & availChannelRange;
	var varChBandWidth = $("#chBandWidth").val();

	var channelMode = $("select[name='uiChannelMode']").val();
	if( channelMode == '-1' ){                      
		$("#viewChannelSelect").hide();
		$("#viewChannelManual").show();

		setAutoChannelRangeValue(gFreqType, autoChannelRange);
	}else if( channelMode == '-2' ){        
		if( gFreqType == '1' ){
			if( !(gAutoChannelRange & (1<<30)) ){
				setAutoChannelRangeValue(gFreqType, 273);
			}else{
				setAutoChannelRangeValue(gFreqType, autoChannelRange);	
			}
		}else{
			var needReset = 0;
			var wirelessMode = mcr_getWirelessMode();
			if( !(gAutoChannelRange & (1<<30)) ||		
				wirelessMode != gOrgWirelessMode ||		
				varChBandWidth!= gOrgBandWidth){		
				needReset = 1;
			}
			if( needReset ){
				if( varChBandWidth == "3" ) 
					autoChannelRange = 0x000ffff;
				else if( varChBandWidth == "18" )
					autoChannelRange = 0x0f0000f;
				else if( varChBandWidth == "2" )
					autoChannelRange = 0x0f0000f;
				else if( varChBandWidth == "1" )
					autoChannelRange = 0x0f0000f;
				else
					autoChannelRange = 0x1f0000f;
				setAutoChannelRangeValue(gFreqType, autoChannelRange);
			}else{
				setAutoChannelRangeValue(gFreqType, autoChannelRange);
			}
		}
		$("#viewChannelSelect").show();
		$("#viewChannelManual").hide();
	}else{	
		if( gFreqType == '1' ){
			setAutoChannelRangeValue(gFreqType, 0x07ff);	
		}else{
			setAutoChannelRangeValue(gFreqType, 0x1F7FFFF);	
		}
		$("#viewChannelSelect").hide();
		$("#viewChannelManual").hide();
	}
}

function mergeChannel(){
	var channelMode = $("select[name='uiChannelMode']").val();
	if( channelMode == '-1' ){
		$("#channel").val( $("#uiChannel option:selected").val() );
	}else if( channelMode == '0' ){
		$("#channel").val( '0' );
	}else{
		$("#channel").val( '0' );
	}

	var chEx = $("#uichExtension option:selected").val();
	$("#chExtension").val( chEx );

	mergeAutoChannelRangeValue(gFreqType, "autochannelrange");

	if( channelMode == '-2' ){
		var autochrange = parseInt( $("#autochannelrange").val(), 10 );
		$("#autochannelrange").val( ''+( autochrange | (1<<30)) );
	}	
}


function validateOnSubmit_WLAN_Basic(){
	var ret = 0;
	ret = validateRangeById("beaconInterval", 10, 50, 500, true);
	if( ret!= 1 ){
		alert("beacon range 오류");
		return false;
	}
	ret = validateRangeById("dtimPeriod", 10, 1, 255, true);
	if( ret!= 1 ){
		alert("dtim range 오류");
		return false;
	}
	ret = validateRangeById("rtsThreshold", 10, 1, 2346, true);
	if( ret!= 1 ){
		alert("RTS 설정 range 오류");
		return false;
	}
	ret = validateRangeById("fragThreshold", 10, 256, 2346, true);
	if( ret!= 1 ){
		alert("Fragment 설정 range 오류");
		return false;
	}

	mergeChannel();

	if(gWlanIfIndex == '0'){
		var Activity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
		var confirmed = false;
		if(Activity == 1 && checkIoWChannelRange() != 1){
			confirmed = confirm("설정된 채널에서 IoW 동작이 원활하지 않을 수 있습니다. 계속하시겠습니까?");
			if(!confirmed)
				return false;
		}
	}

	return true;
}

function checkIoWChannelRange(){
	var ret = 1;
	//IOW 설정상태 확인 DB

	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';

	if( wlanRadioActivity == '0' ) return 1;
	
	var channelMode = $("select[name='uiChannelMode']").val();
	
	var cur_auto_ch = $("#autochannelrange").val();
	var cur_channel = $("#uiChannel").val();

	if(channelMode == '-1')
	{
		if( cur_channel > 48 && cur_channel < 149 ){
			ret = 0;
		}
	} else if(channelMode == '-2') {
		if( isDFSRange(cur_auto_ch) == 1 ){
			ret = 0;
		} 
	} else {    //auto
		// no need check
		ret = 1;
	}
	return ret;
}

function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;

	arrCol[0] = items[0];
	arrCol[1] = items[1];
	arrCol[2] = items[2];
	arrCol[3] = items[3];
	arrCol[4] = items[4];

	return arrCol;
}

function initTable(){
	var strTableAttr = "align='center' border='0' cellspacing='0' cellpadding='0' width='100%' valign='middle' id='Grid_Table' style='table-layout:fixed;'";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "style=word-break:break-all";

	tableRule = new MCRTable("view_aplist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"AP 정보가 없습니다.", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선 LAN 이름", "width='35%'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "BSSID", "width='35%'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "채널", "width='10%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "모드", "width='10%'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "신호세기", "width='10%'", strTableTh, strTableTd+" align='center'", "");
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

 
function processHttpResponse(strResponse){
	arrData.length = 0;

	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	var maxChannelCount = parseInt(lineArr[0], 10);
	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 1 ){
			arrData[row] = lineArr[row+rowOnly];
		}
	}

	initForms(1);
}


$(document).ready(function(){


	
	$("#uiChannel").bind( "change", function(){
		onChangeChannel();
	
		return true;
	});
	$("#wlanBtnSearch").bind( "click", function(){
		onClickChannelScan();
		return false;
	});

	initValue();
});


function initForm_WLAN_Basic(useDefault){
	var cWirelessMode;
	var channel, chBandWidth, chExtension, mcs, activeChannel;
	var autoChannelRange, availChannelRange;
	var beaconInterval, dtimPeriod, rtsThreshold, fragThreshold, bgProtection;
	var txPower, shortSlot, preambleType;
	var m2u;
	var txbf;
	var stbc;
	var guard_interval, dl_ofdma, ul_ofdma, dl_mmimo, ul_mmimo, ldpc, twt;

	if( useDefault == 0 ){
		cWirelessMode = '<% mcr_getCfgWireless("Wlan_WirelessMode", gWlanIfIndexEJ); %>';       
		gOrgWirelessMode = cWirelessMode;
		channel = '<% mcr_getCfgWireless("Wlan_Channel", gWlanIfIndexEJ); %>';                          
		chBandWidth = '<% mcr_getCfgWireless("Wlan_ChannelBandWidth", gWlanIfIndexEJ); %>';
		gChBandWidth = chBandWidth;
		gOrgBandWidth = chBandWidth;
		chExtension = '<% mcr_getCfgWireless("Wlan_ChannelExtension", gWlanIfIndexEJ); %>';

		cpuName = '<% mcr_getCfgWireless("cpu_name"); %>';

		mcs = '<% mcr_getCfgWireless("Wlan_MCS", gWlanIfIndexEJ); %>';

		autoChannelRange = '<% mcr_getCfgWireless("Wlan_AutoChannelRange", gWlanIfIndexEJ); %>';
		availChannelRange = '<% mcr_getCfgWireless("Wlan_AvailChannelRange", gWlanIfIndexEJ); %>';
		activeChannel = '<% mcr_getCfgWireless("Wlan_active_channelString", gWlanIfIndexEJ); %>';

		gFreqType = '<% mcr_getCfgWireless("Wlan_BandType", gWlanIfIndexEJ); %>';
		gProjectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';

		gAutoChannelRange = parseInt(autoChannelRange, 10);
		gAvailChannelRange = parseInt(availChannelRange, 10);
		
		gBandMode = 		'<% mcr_getCfgWireless("Wlan_BandMode"); %>';

		beaconInterval = '<% mcr_getCfgWireless("Wlan_BeaconInterval", gWlanIfIndexEJ); %>';
		dtimPeriod = '<% mcr_getCfgWireless("Wlan_DtimPeriod", gWlanIfIndexEJ); %>';
		rtsThreshold = '<% mcr_getCfgWireless("Wlan_RtsThreshold", gWlanIfIndexEJ); %>';
		fragThreshold = '<% mcr_getCfgWireless("Wlan_FragmentThreshold", gWlanIfIndexEJ); %>';
		bgProtection = '<% mcr_getCfgWireless("Wlan_BGProtection", gWlanIfIndexEJ); %>';

		txPower = '<% mcr_getCfgWireless("Wlan_TxPower", gWlanIfIndexEJ); %>';
		shortSlot = '<% mcr_getCfgWireless("Wlan_ShortSlot", gWlanIfIndexEJ); %>';
		preambleType = '<% mcr_getCfgWireless("Wlan_PreambleType", gWlanIfIndexEJ); %>';
		ampdu = '<% mcr_getCfgWireless("Wlan_Ampdu", gWlanIfIndexEJ); %>';

		m2u = '<% mcr_getCfgWireless("Wlan_MulticastToUnicastEnable", gWlanIfIndexEJ); %>';
		txbf = '<% mcr_getCfgWireless("Wlan_TxBeamforming", gWlanIfIndexEJ); %>';
		stbc = '<% mcr_getCfgWireless("Wlan_STBC_Enable", gWlanIfIndexEJ); %>';

		ldpc = '<% mcr_getCfgWireless("Wlan_LDPCEnable", gWlanIfIndexEJ); %>';
		guard_interval = '<% mcr_getCfgWireless("Wlan_GI", gWlanIfIndexEJ); %>';
		dl_ofdma = '<% mcr_getCfgWireless("Wlan_OFDMA_DN_Enable", gWlanIfIndexEJ); %>';
		ul_ofdma = '<% mcr_getCfgWireless("Wlan_OFDMA_UP_Enable", gWlanIfIndexEJ); %>';
		dl_mmimo = '<% mcr_getCfgWireless("Wlan_DL_MuMIMO", gWlanIfIndexEJ); %>';
		ul_mmimo = '<% mcr_getCfgWireless("Wlan_UL_MuMIMO", gWlanIfIndexEJ); %>';
		twt = '<% mcr_getCfgWireless("Wlan_TWTEnable", gWlanIfIndexEJ); %>';

	}

	userPri=1;
	updateWirelessMode(gFreqType, cWirelessMode);
	
	onChangeWirelessMode(chBandWidth, channel, chExtension, mcs);
	updateChannelMode(channel); 
	

	$("input[name='uiChannelMode']:checked").trigger("change");


	layoutStationList();

	if( gFreqType == '1' ){
		$("#view_multi2uni").hide();
		$("#view_txbf").hide();
		$("#view_stbc").hide();
		$("#view_mmimo").hide();
	}else{
		$("#view_multi2uni").hide();
		$("#view_txbf").hide();
		$("#view_stbc").hide();
		$("#view_mmimo").hide();
	}
	

	$("#uiActiveChannel").text( activeChannel );

	settxPower(txPower);
	$("#beaconInterval").val( beaconInterval );
	setpreambleType(preambleType);
	setshortSlot(shortSlot);
	setampdu(ampdu);
	setbgProtection(bgProtection);
	$("#rtsThreshold").val( rtsThreshold );
	$("#fragThreshold").val( fragThreshold );
	$("#dtimPeriod").val( dtimPeriod );
	$("#twt").val( twt );
	$("#ldpc").val( ldpc );
	$("#guard_interval").val( guard_interval );
	$("#dl_ofdma").val( dl_ofdma );
	$("#ul_ofdma").val( ul_ofdma );
	$("#ul_mmimo").val( ul_mmimo );
	$("#dl_mmimo").val( dl_mmimo );

	setm2u(m2u);
	setSTBC(stbc);
	setTXBF(txbf);
	setMMIMO(mmimo);
	setPrivilageControl(0);
}

function validateOnSubmit(){
	var ret = validateOnSubmit_WLAN_Basic();
	if( ret == true ){
		setPrivilageControl(1);
	}
	return ret;
}

function updateFormValue(useDefault){
	if( useDefault == 1 ){
		if( arrData == null || arrData.length == 0 ){
			layoutStationList("AP 정보가 없습니다.");
		}else{
			layoutStationList();
		}
	}
}

function initForms(flag){
	if( flag == 0 ){
		initForm_WLAN_Basic(flag);
	}else{
		updateFormValue(flag);
	}
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){

	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	vendor_init();
	initForms(0);
}

function setPrivilageControl(flag){
	if( flag == 0 ){
		switch(gUserPrivilege){
		case 1:
			$("input[name='txPower']").attr("disabled","disabled");
		case 3:
			$("#view_mcs").hide();
			$("#view_beaconInterval").hide();
			$("#view_preambleType").hide();
			$("#view_shortSlot").hide();
			$("#view_ampdu").hide();
			$("#view_bgProtection").hide();
			$("#view_rtsThreshold").hide();
			$("#view_fragThreshold").hide();
			$("#view_dtimPeriod").hide();
			$("#view_multi2uni").hide();
			$("#view_stbc").hide();

		break;
		case 7:
		break;
		default:
		break;
		}
	}else{
		$("input[name='txPower']").removeAttr("disabled");
		$("select[name='mcs']").removeAttr("disabled");
		$("input[name='preambleType']").removeAttr("disabled");
		$("input[name='shortSlot']").removeAttr("disabled");
		$("input[name='ampdu']").removeAttr("disabled");
		$("input[name='bgProtection']").removeAttr("disabled");
		$("input[name='m2u']").removeAttr("disabled");	
	}
}

function setuiWirelessMode_2G(uiWirelessMode_2G){
	var label_id = 'm_uiWirelessMode_2G_' + uiWirelessMode_2G;
	mcr_clickradio_uiWirelessMode_2G('' + uiWirelessMode_2G);
	$("input[id='" + label_id + "']").attr("checked", true).checkboxradio("refresh");
	$("#uiWirelessMode_2G").val('' + uiWirelessMode_2G);
/*
	switch(uiWirelessMode_2G){
		case '1':
			mcr_clickradio_uiWirelessMode_2G('1');
			$("input[id='m_uiWirelessMode_2G']").attr("checked", true).checkboxradio("refresh");
			$("#uiWirelessMode_2G").val("1");
			break;
		case '2':
			mcr_clickradio_uiWirelessMode_2G('2');
			$("input[id='m_uiWirelessMode_2G1']").attr("checked", true).checkboxradio("refresh");
			$("#uiWirelessMode_2G").val("2");
			break;
		case '4':
			mcr_clickradio_uiWirelessMode_2G('4');
			$("input[id='m_uiWirelessMode_2G2']").attr("checked", true).checkboxradio("refresh");
			$("#uiWirelessMode_2G").val("4");
			break;
		case '6':
			mcr_clickradio_uiWirelessMode_2G('6');
			$("input[id='m_uiWirelessMode_2G4']").attr("checked", true).checkboxradio("refresh");
			$("#uiWirelessMode_2G").val("6");
			break;
		case '7':
			mcr_clickradio_uiWirelessMode_2G('7');
			$("input[id='m_uiWirelessMode_2G3']").attr("checked", true).checkboxradio("refresh");
			$("#uiWirelessMode_2G").val("7");
			break;
		default:
			break;
	}
*/
	onChangeWirelessMode('-1');	
}

function mcr_clickradio_uiWirelessMode_2G(val){
	var uMode_2G = [ '1', '2', '4', '6', '7', '32', '36', '38', '39' ];
	var label_name = '';
	var item = null;

	for( i = 0; i < uMode_2G.length; i++) {
		label_name = "m_uiWirelessMode_2G_" + uMode_2G[i];
		item = $('label[for="'+ label_name + '"]');
		item.removeClass('ui-btn-active');
	}
	for( i = 0; i < uMode_2G.length; i++ ) {
		label_name = "m_uiWirelessMode_2G_" + uMode_2G[i];
		item = $('label[for="' + label_name + '"]');
		if( uMode_2G[i] == val ){
			item.addClass('ui-btn-active-c');
		} else {
			item.removeClass('ui-btn-active-c');
		}
	}
/*
	$('label[for=m_uiWirelessMode_2G]').removeClass('ui-btn-active');
	$('label[for=m_uiWirelessMode_2G1]').removeClass('ui-btn-active');
	$('label[for=m_uiWirelessMode_2G2]').removeClass('ui-btn-active');
	$('label[for=m_uiWirelessMode_2G3]').removeClass('ui-btn-active');
	$('label[for=m_uiWirelessMode_2G4]').removeClass('ui-btn-active');
	switch(val){
		case '1':
			$('label[for=m_uiWirelessMode_2G]').addClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G1]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G2]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G4]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G3]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_uiWirelessMode_2G1]').addClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G2]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G4]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G3]').removeClass('ui-btn-active-c');
			break;
		case '4':
			$('label[for=m_uiWirelessMode_2G2]').addClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G1]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G4]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G3]').removeClass('ui-btn-active-c');
			break;
		case '6':
			$('label[for=m_uiWirelessMode_2G4]').addClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G1]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G2]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G3]').removeClass('ui-btn-active-c');
			break;
		case '7':
			$('label[for=m_uiWirelessMode_2G3]').addClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G1]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G2]').removeClass('ui-btn-active-c');
			$('label[for=m_uiWirelessMode_2G4]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
*/
}

function setuiWirelessMode_5G(uiWirelessMode_5G){
	var label_id = 'm_uiWirelessMode_5G_' + uiWirelessMode_5G;
	mcr_clickradio_uiWirelessMode_5G('' + uiWirelessMode_5G);
	$("input[id='" + label_id + "']").attr("checked", true).checkboxradio("refresh");
	$("#uiWirelessMode_5G").val('' + uiWirelessMode_5G);

	onChangeWirelessMode('-1');	
}

function mcr_clickradio_uiWirelessMode_5G(val){
	var uMode_5G = [ '8', '4', '16', '32', '60', '28', '52', '20', '12', '48' ];
	var label_name = '';
	var item = null;

	for( i = 0; i < uMode_5G.length; i++ ){
		label_name = "m_uiWirelessMode_5G_" + uMode_5G[i];
		item = $('label[for="'+ label_name + '"]');
		item.removeClass('ui-btn-active');
	}
	for( i = 0; i < uMode_5G.length; i++ ){
		label_name = "m_uiWirelessMode_5G_" + uMode_5G[i];
		item = $('label[for="' + label_name + '"]');
		if( uMode_5G[i] == val ){
			item.addClass('ui-btn-active-c');
		}else{
			item.removeClass('ui-btn-active-c');
		}
	}
}

function setchBandWidth(chBandWidth){
	switch(chBandWidth){
	case '0':
		mcr_clickradio_chBandWidth('0');
		$("input[id='m_chBandWidth']").attr("checked", true).checkboxradio("refresh");
		$("#chBandWidth").val("0");
	break;
	case '1':
		mcr_clickradio_chBandWidth('1');
		$("input[id='m_chBandWidth1']").attr("checked", true).checkboxradio("refresh");
		$("#chBandWidth").val("1");
	break;
	case '2':
		mcr_clickradio_chBandWidth('2');
		$("input[id='m_chBandWidth2']").attr("checked", true).checkboxradio("refresh");
		$("#chBandWidth").val("2");
	break;
	default:
	break;
	}
	onChangeChannelBandWidth();
}

function mcr_clickradio_chBandWidth(val){
	$('label[for=m_chBandWidth]').removeClass('ui-btn-active');
	$('label[for=m_chBandWidth1]').removeClass('ui-btn-active');
	$('label[for=m_chBandWidth2]').removeClass('ui-btn-active');
	switch(val){
	case '0':
		$('label[for=m_chBandWidth]').addClass('ui-btn-active-c');

		$('label[for=m_chBandWidth1]').removeClass('ui-btn-active-c');
		$('label[for=m_chBandWidth2]').removeClass('ui-btn-active-c');
	break;
	case '1':
		$('label[for=m_chBandWidth1]').addClass('ui-btn-active-c');

		$('label[for=m_chBandWidth]').removeClass('ui-btn-active-c');
		$('label[for=m_chBandWidth2]').removeClass('ui-btn-active-c');
	break;
	case '2':
		$('label[for=m_chBandWidth2]').addClass('ui-btn-active-c');

		$('label[for=m_chBandWidth]').removeClass('ui-btn-active-c');
		$('label[for=m_chBandWidth1]').removeClass('ui-btn-active-c');
	break;
	default:
	break;
	}
}

function setuiChannelMode(uiChannelMode){
	switch(uiChannelMode){
		case '0':
			$("#uiChannelMode").val("0");
			break;
		case '-2':
			$("#uiChannelMode").val("-2");
			break;
		case '-1':
			$("#uiChannelMode").val("-1");
			break;
		default:
			break;
	}
	$("#uiChannelMode").selectmenu('refresh');
	onAutoChannelRange();
}

function settxPower(txPower){
	switch(txPower){
		case '100':
			$("#txPower")[0].selectedIndex =0;
			break;
		case '70':
			$("#txPower")[0].selectedIndex =1;
			break;
		case '50':
			$("#txPower")[0].selectedIndex =2;
			break;
		case '35':
			$("#txPower")[0].selectedIndex =3;
			break;
		case '15':
			$("#txPower")[0].selectedIndex =4;
			break;
		default:
			break;
	}
	$("#txPower").selectmenu('refresh');
}

function setpreambleType(preambleType){
	switch(preambleType){
		case '0':
			mcr_clickradio_preambleType('0');
			$("input[id='m_preambleType1']").attr("checked", true).checkboxradio("refresh");
			$("#preambleType").val("0");
			break;
		case '1':
			mcr_clickradio_preambleType('1');
			$("input[id='m_preambleType']").attr("checked", true).checkboxradio("refresh");
			$("#preambleType").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_preambleType(val){
	$('label[for=m_preambleType]').removeClass('ui-btn-active');
	$('label[for=m_preambleType1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_preambleType1]').addClass('ui-btn-active-c');
			$('label[for=m_preambleType]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_preambleType]').addClass('ui-btn-active-c');
			$('label[for=m_preambleType1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setshortSlot(shortSlot){
	switch(shortSlot){
		case '0':
			mcr_clickradio_shortSlot('0');
			$("input[id='m_shortSlot1']").attr("checked", true).checkboxradio("refresh");
			$("#shortSlot").val("0");
			break;
		case '1':
			mcr_clickradio_shortSlot('1');
			$("input[id='m_shortSlot']").attr("checked", true).checkboxradio("refresh");
			$("#shortSlot").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_shortSlot(val){
	$('label[for=m_shortSlot]').removeClass('ui-btn-active');
	$('label[for=m_shortSlot1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_shortSlot1]').addClass('ui-btn-active-c');
			$('label[for=m_shortSlot]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_shortSlot]').addClass('ui-btn-active-c');
			$('label[for=m_shortSlot1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setampdu(ampdu){
	switch(ampdu){
		case '0':
			mcr_clickradio_ampdu('0');
			$("input[id='m_ampdu1']").attr("checked", true).checkboxradio("refresh");
			$("#ampdu").val("0");
			break;
		case '1':
			mcr_clickradio_ampdu('1');
			$("input[id='m_ampdu']").attr("checked", true).checkboxradio("refresh");
			$("#ampdu").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_ampdu(val){
	$('label[for=m_ampdu]').removeClass('ui-btn-active');
	$('label[for=m_ampdu1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_ampdu1]').addClass('ui-btn-active-c');
			$('label[for=m_ampdu]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_ampdu]').addClass('ui-btn-active-c');
			$('label[for=m_ampdu1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setbgProtection(bgProtection){
	switch(bgProtection){
		case '0':
			mcr_clickradio_bgProtection('0');
			$("input[id='m_bgProtection1']").attr("checked", true).checkboxradio("refresh");
			$("#bgProtection").val("0");
			break;
		case '1':
			mcr_clickradio_bgProtection('1');
			$("input[id='m_bgProtection']").attr("checked", true).checkboxradio("refresh");
			$("#bgProtection").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_bgProtection(val){
	$('label[for=m_bgProtection]').removeClass('ui-btn-active');
	$('label[for=m_bgProtection1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_bgProtection1]').addClass('ui-btn-active-c');
			$('label[for=m_bgProtection]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_bgProtection]').addClass('ui-btn-active-c');
			$('label[for=m_bgProtection1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setm2u(m2u){
	switch(m2u){
		case '0':
			mcr_clickradio_m2u('0');
			$("input[id='m_m2u1']").attr("checked", true).checkboxradio("refresh");
			$("#m2u").val("0");
			break;
		case '1':
			mcr_clickradio_m2u('1');
			$("input[id='m_m2u']").attr("checked", true).checkboxradio("refresh");
			$("#m2u").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_m2u(val){
	$('label[for=m_m2u]').removeClass('ui-btn-active');
	$('label[for=m_m2u1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_m2u1]').addClass('ui-btn-active-c');
			$('label[for=m_m2u]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_m2u]').addClass('ui-btn-active-c');
			$('label[for=m_m2u1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setSTBC(val){
	switch(val){
	case '0':
		mcr_clickradio_stbc('0');
		$("input[id='m_stbc1']").attr("checked", true).checkboxradio("refresh");
		$("#stbc").val("0");
	break;
	case '1':
		mcr_clickradio_stbc('1');
		$("input[id='m_stbc']").attr("checked", true).checkboxradio("refresh");
		$("#stbc").val("1");
	break;
	default:
	break;
	}
}

function mcr_clickradio_stbc(val){
	$('label[for=m_stbc]').removeClass('ui-btn-active');
	$('label[for=m_stbc1]').removeClass('ui-btn-active');
	switch(val){
	case '0':
		$('label[for=m_stbc1]').addClass('ui-btn-active-c');
		$('label[for=m_stbc]').removeClass('ui-btn-active-c');
	break;
	case '1':
		$('label[for=m_stbc]').addClass('ui-btn-active-c');
		$('label[for=m_stbc1]').removeClass('ui-btn-active-c');
	break;
	default:
	break;
	}
}

function changeTxBF_List(val){
	$('label[for=m_txbf_list]').removeClass('ui-btn-active');
	$('label[for=m_txbf_list1]').removeClass('ui-btn-active');
	$('label[for=m_txbf_list2]').removeClass('ui-btn-active');
	switch(val){
		case '1':
			$('label[for=m_txbf_list]').addClass('ui-btn-active-c');
			$('label[for=m_txbf_list1]').removeClass('ui-btn-active-c');
			$('label[for=m_txbf_list2]').removeClass('ui-btn-active-c');
			$("#txbf_list").val("1");
		break;
		case '2':
			$('label[for=m_txbf_list1]').addClass('ui-btn-active-c');
			$('label[for=m_txbf_list2]').removeClass('ui-btn-active-c');
			$('label[for=m_txbf_list]').removeClass('ui-btn-active-c');
			$("#txbf_list").val("2");
		break;
		case '3':
			$('label[for=m_txbf_list2]').addClass('ui-btn-active-c');
			$('label[for=m_txbf_list]').removeClass('ui-btn-active-c');
			$('label[for=m_txbf_list1]').removeClass('ui-btn-active-c');
			$("#txbf_list").val("3");
		break;
		default:
		break;

	}
}
function setTXBF(val){
	if(val == 0){
		mcr_clickradio_TXBF('0');
		$("input[id='m_txbf1']").attr("checked", true).checkboxradio("refresh");
		$("#txbf").val("0");
	}else{
		$("#txbf").val("1");
		switch(val){
			case '1':
				mcr_clickradio_TXBF('1');
				$("input[id='m_txbf']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_txbf_list']").attr("checked", true).checkboxradio("refresh");
				$("#txbf_list").val("1");
			break;
			case '2':
				mcr_clickradio_TXBF('2');
				$("input[id='m_txbf']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_txbf_list1']").attr("checked", true).checkboxradio("refresh");
				$("#txbf_list").val("2");
			break;
			case '3':
				mcr_clickradio_TXBF('3');
				$("input[id='m_txbf']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_txbf_list2']").attr("checked", true).checkboxradio("refresh");
				$("#txbf_list").val("3");

			break;

		default:
		break;
		}
	}
}
function changeTXBF(val){
	if(val == 0){
		mcr_clickradio_TXBF('0');
		$("input[id='m_txbf1']").attr("checked", true).checkboxradio("refresh");
		$("#txbf").val("0");
	}else{

		$("#txbf").val("1");
		mcr_clickradio_TXBF('3');
		$("input[id='m_txbf']").attr("checked", true).checkboxradio("refresh");
		$("input[id='m_txbf_list2']").attr("checked", true).checkboxradio("refresh");
		$("#txbf_list").val("3");
	}
}

function mcr_clickradio_TXBF(val){
	
	$('label[for=m_txbf]').removeClass('ui-btn-active');
	$('label[for=m_txbf1]').removeClass('ui-btn-active');
	
	if(val == 0){
		$('label[for=m_txbf1]').addClass('ui-btn-active-c');
		$('label[for=m_txbf]').removeClass('ui-btn-active-c');
		$("#view_txbf_list").hide();
	}else{
		$('label[for=m_txbf_list]').removeClass('ui-btn-active');
		$('label[for=m_txbf_list1]').removeClass('ui-btn-active');
		$('label[for=m_txbf_list2]').removeClass('ui-btn-active');
		$("#view_txbf_list").hide();
		switch(val){
			case '1':
				$('label[for=m_txbf]').addClass('ui-btn-active-c');
				$('label[for=m_txbf1]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list]').addClass('ui-btn-active-c');
				$('label[for=m_txbf_list1]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list2]').removeClass('ui-btn-active-c');
			break;
			case '2':
				$('label[for=m_txbf]').addClass('ui-btn-active-c');
				$('label[for=m_txbf1]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list1]').addClass('ui-btn-active-c');
				$('label[for=m_txbf_list2]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list]').removeClass('ui-btn-active-c');
			break;

			case '3':
				$('label[for=m_txbf]').addClass('ui-btn-active-c');
				$('label[for=m_txbf1]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list2]').addClass('ui-btn-active-c');
				$('label[for=m_txbf_list]').removeClass('ui-btn-active-c');
				$('label[for=m_txbf_list1]').removeClass('ui-btn-active-c');
			break;
			default:
			break;
		}
	}
}
function setMMIMO(val){
	if(val == 0){
		mcr_clickradio_MMIMO('0');
		$("input[id='m_mmimo1']").attr("checked", true).checkboxradio("refresh");
		$("#mmimo").val("0");
	}else{
		$("#mmimo").val("2");
		switch(val){
			case '1':
				mcr_clickradio_MMIMO('1');
				$("input[id='m_mmimo']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_mmimo_list']").attr("checked", true).checkboxradio("refresh");
				$("#mmimo_list").val("1");
			break;
			case '2':
				mcr_clickradio_MMIMO('2');
				$("input[id='m_mmimo']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_mmimo_list1']").attr("checked", true).checkboxradio("refresh");
				$("#mmimo_list").val("2");
			break;
			case '3':
				mcr_clickradio_MMIMO('3');
				$("input[id='m_mmimo']").attr("checked", true).checkboxradio("refresh");
				$("input[id='m_mmimo_list2']").attr("checked", true).checkboxradio("refresh");
				$("#mmimo_list").val("3");

			break;
			default:
			break;
		}
	}
}
function changeMMIMO(val){
	if(val == 0){
		mcr_clickradio_MMIMO('0');
		$("input[id='m_mmimo1']").attr("checked", true).checkboxradio("refresh");
		$("#mmimo").val("0");
	}else{
		$("#mmimo").val("1");
		mcr_clickradio_MMIMO('2');
		$("input[id='m_mmimo']").attr("checked", true).checkboxradio("refresh");
		$("input[id='m_mmimo_list1']").attr("checked", true).checkboxradio("refresh");
		$("#mmimo_list").val("2");
	}
}
function mcr_clickradio_MMIMO(val){
	
	$('label[for=m_mmimo]').removeClass('ui-btn-active');
	$('label[for=m_mmimo1]').removeClass('ui-btn-active');
	if(val == 0){
		$('label[for=m_mmimo1]').addClass('ui-btn-active-c');
		$('label[for=m_mmimo]').removeClass('ui-btn-active-c');
		$("#view_mmimo_list").hide();
	}else{
		$('label[for=m_mmimo_list]').removeClass('ui-btn-active');
		$('label[for=m_mmimo_list1]').removeClass('ui-btn-active');
		$('label[for=m_mmimo_list2]').removeClass('ui-btn-active');
		$("#view_mmimo_list").show();
		$('label[for=m_mmimo]').addClass('ui-btn-active-c');
		$('label[for=m_mmimo1]').removeClass('ui-btn-active-c');
		switch(val){
			case '1':
				$('label[for=m_mmimo_list]').addClass('ui-btn-active-c');
				$('label[for=m_mmimo_list1]').removeClass('ui-btn-active-c');
				$('label[for=m_mmimo_list2]').removeClass('ui-btn-active-c');
			break;
			case '2':
				$('label[for=m_mmimo_list1]').addClass('ui-btn-active-c');
				$('label[for=m_mmimo_list2]').removeClass('ui-btn-active-c');
				$('label[for=m_mmimo_list]').removeClass('ui-btn-active-c');
			break;

			case '3':
				$('label[for=m_mmimo_list2]').addClass('ui-btn-active-c');
				$('label[for=m_mmimo_list]').removeClass('ui-btn-active-c');
				$('label[for=m_mmimo_list1]').removeClass('ui-btn-active-c');
			break;
			default:
			break;
		}
	}
}
function changeMMIMO_List(val){
	$('label[for=m_mmimo_list]').removeClass('ui-btn-active');
	$('label[for=m_mmimo_list1]').removeClass('ui-btn-active');
	$('label[for=m_mmimo_list2]').removeClass('ui-btn-active');
	switch(val){
		case '1':
			$('label[for=m_mmimo_list]').addClass('ui-btn-active-c');
			$('label[for=m_mmimo_list1]').removeClass('ui-btn-active-c');
			$('label[for=m_mmimo_list2]').removeClass('ui-btn-active-c');
			$("#mmimo_list").val("1");
		break;
		case '2':
			$('label[for=m_mmimo_list1]').addClass('ui-btn-active-c');
			$('label[for=m_mmimo_list2]').removeClass('ui-btn-active-c');
			$('label[for=m_mmimo_list]').removeClass('ui-btn-active-c');
			$("#mmimo_list").val("2");
		break;
		case '3':
			$('label[for=m_mmimo_list2]').addClass('ui-btn-active-c');
			$('label[for=m_mmimo_list]').removeClass('ui-btn-active-c');
			$('label[for=m_mmimo_list1]').removeClass('ui-btn-active-c');
			$("#mmimo_list").val("3");
		break;
		default:
		break;

	}
}
function form_act(url){
	if(!validateOnSubmit())
		return false;
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
        $('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",40)
	form_basic.action = url;
	form_basic.submit();
	return false;
}

</script>

</head>
<body>
<form method="post" name="form_basic" data-ajax="false">

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_2_1_wireless_common_set.asp">

<input type="hidden" id="channel" name="channel" value="">

<input type="hidden" id="autochannelrange" name="autochannelrange" value="">
<input type="hidden" id="chExtension" name="chExtension" value="">

<input type="hidden" id="wirelessMode" name="wirelessMode" value="">

<input type="hidden" name="uiWirelessMode_2G" id="uiWirelessMode_2G" value="">
<input type="hidden" name="uiWirelessMode_5G" id="uiWirelessMode_5G" value="">
<input type="hidden" id="wireless_mode_5G" name="wireless_mode_5G" value="">
<input type="hidden" name="chBandWidth" id="chBandWidth" value="">
<input type="hidden" name="preambleType" id="preambleType" value="">
<input type="hidden" name="shortSlot" id="shortSlot" value="">
<input type="hidden" name="ampdu" id="ampdu" value="">
<input type="hidden" name="bgProtection" id="bgProtection" value="">
<input type="hidden" name="m2u" id="m2u" value="">
<input type="hidden" name="stbc" id="stbc" value="">
<input type="hidden" name="txbf" id="txbf" value="">
<input type="hidden" name="txbf_list" id="txbf_list" value="">
<input type="hidden" name="dl_mmimo" id="dl_mmimo" value="">
<input type="hidden" name="ul_mmimo" id="ul_mmimo" value="">
<input type="hidden" name="ul_ofdma" id="ul_ofdma" value="">
<input type="hidden" name="dl_ofdma" id="dl_ofdma" value="">
<input type="hidden" name="guard_interval" id="guard_interval" value="">
<input type="hidden" name="ldpc" id="ldpc" value="">
<input type="hidden" name="twt" id="twt" value="">
<input type="hidden" name="mmimo_list" id="mmimo_list" value="">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그아웃</a>
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
					무선 공통 설정
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

	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">

			<tr id="view_wireless_mode_2G">
				<td>무선 모드</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_uiWirelessMode_2G_1">　b　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_1" value="1" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_2">　g　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_2" value="2" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_4">　n　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_4" value="4" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_32">　ax　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_32" value="32" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_39">　b/g/n/ax　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_39" value="39" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_7">　b/g/n　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_7" value="7" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_38">　g/n/ax　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_38" value="38" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_6">　g/n　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_6" value="6" onclick="setuiWirelessMode_2G(this.value)">

									<label for="m_uiWirelessMode_2G_36">　n/ax　</label>
									<input type="radio" name="m_uiWirelessMode_2G" id="m_uiWirelessMode_2G_36" value="36" onclick="setuiWirelessMode_2G(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="view_wireless_mode_5G">
				<td>무선 모드</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_uiWirelessMode_5G_8">　a　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_8" value="8" onclick="setuiWirelessMode_5G(this.value)">

									<label for="m_uiWirelessMode_5G_4">　n　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_4" value="4" onclick="setuiWirelessMode_5G(this.value)">

									<label for="m_uiWirelessMode_5G_16">　ac　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_16" value="16" onclick="setuiWirelessMode_5G(this.value)">

									<label for="m_uiWirelessMode_5G_32">　ax　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_32" value="32" onclick="setuiWirelessMode_5G(this.value)">

									<label for="m_uiWirelessMode_5G_60">　a/n/ac/ax　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_60" value="60" onclick="setuiWirelessMode_5G(this.value)">
									
									<label for="m_uiWirelessMode_5G_28">　a/n/ac　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_28" value="28" onclick="setuiWirelessMode_5G(this.value)">
									
									<label for="m_uiWirelessMode_5G_52">　n/ac/ax　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_52" value="52" onclick="setuiWirelessMode_5G(this.value)">
									
									<label for="m_uiWirelessMode_5G_20">　n/ac　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_20" value="20" onclick="setuiWirelessMode_5G(this.value)">

									<label for="m_uiWirelessMode_5G_12">　a/n　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_12" value="12" onclick="setuiWirelessMode_5G(this.value)">
									
									<label for="m_uiWirelessMode_5G_48">　ac/ax　</label>
									<input type="radio" name="m_uiWirelessMode_5G" id="m_uiWirelessMode_5G_48" value="48" onclick="setuiWirelessMode_5G(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="view_chBandWidth">
				<td>채널 밴드</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_chBandWidth">　20MHz　</label>
									<input type="radio" name="m_chBandWidth" id="m_chBandWidth" value="0" onclick="setchBandWidth(this.value)">

									<label for="m_chBandWidth1">　40MHz　</label>
									<input type="radio" name="m_chBandWidth" id="m_chBandWidth1" value="1" onclick="setchBandWidth(this.value)">

									
									<label for="m_chBandWidth2">　80MHz　</label>
									<input type="radio" name="m_chBandWidth" id="m_chBandWidth2" value="2" onclick="setchBandWidth(this.value)">
									
									
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>채널 모드</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td>
											<select id="uiChannelMode" name="uiChannelMode" data-mini="true" onchange="setuiChannelMode(this.value)">
												<option value="0">Auto</option>
												<option value="-2">Auto(Select)</option>
												<option value="-1">수동</option>
											</select>
										</td>
										<td>(현재 채널 : <label id="uiActiveChannel"></label>)</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>

			<tr id="viewChannelManual">
				<td colspan="2">
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td>채널 선택</td>
										<td>
											<select id="uiChannel" name="uiChannel" data-mini="true"></select>
										</td>
										<td>
											<input type="button" value="검색" id="wlanBtnSearch" name="wlanBtnSearch" data-theme="d" data-mini="false" data-ajax="false">
										</td>
									</tr>
									
									<tr id="view_chExtension"><td>
										<td>확장 채널</td>
										<td>
											<select id="uichExtension" name="uichExtension"></select>
										</td>
										<td>	
										</td>
									</tr>
								</table>
							</td>
						</tr>
					
						<tr>
							<td>
								<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td width="35%">무선랜명(SSID)</td>
										<td width="35%">BSSID</td>
										<td width="10%">채널</td>
										<td width="10%">모드</td>
										<td width="10%">신호세기</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
								
									<div id="view_aplist"></div>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			
			<tr id="viewChannelSelect">
				<td colspan="2">
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>채널 선택</td>
							<td>
								<div id="view_autochannelrange_div"></div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>송신 파워</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<select id="txPower" name="txPower" data-mini="true" onchange="settxPower(this.value)">
									<option value="100">Class1(100%)</option>
									<option value="70">Class2(70%)</option>
									<option value="50">Class3(50%)</option>
									<option value="35">Class4(35%)</option>
									<option value="15">Class5(15%)</option>
									<option value="5">Class6(5%)</option>
								</select>
							</td>
						<tr>
					</table>
				</td>
			</tr>
			<tr id="view_mcs" style="display:none">
				<td>전송율</td>
				<td>
					<select id="mcs" name="mcs" data-mini="true"></select>
				</td>
			</tr>
			<tr id="view_beaconInterval" style="display:none">
				<td>Beacon 주기</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<input type="text" id="beaconInterval" name="beaconInterval" value="">
							</td>
							<td>ms</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_preambleType" style="display:none">
				<td>Preamble 설정</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_preambleType">Short</label>
									<input type="radio" name="m_preambleType" id="m_preambleType" value="1" onclick="setpreambleType(this.value)">
			
									<label for="m_preambleType1">Long</label>
									<input type="radio" name="m_preambleType" id="m_preambleType1" value="0" onclick="setpreambleType(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_shortSlot" style="display:none">
				<td>GI</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_shortSlot">Short</label>
									<input type="radio" name="m_shortSlot" id="m_shortSlot" value="1" onclick="setshortSlot(this.value)">
			
									<label for="m_shortSlot1">Long</label>
									<input type="radio" name="m_shortSlot" id="m_shortSlot1" value="0" onclick="setshortSlot(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_ampdu" style="display:none">
				<td>AMPDU</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_ampdu">　활성　</label>
									<input type="radio" name="m_ampdu" id="m_ampdu" value="1" onclick="setampdu(this.value)">
			
									<label for="m_ampdu1">　비활성　</label>
									<input type="radio" name="m_ampdu" id="m_ampdu1" value="0" onclick="setampdu(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_bgProtection" style="display:none">
				<td>BG_Protect 설정</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_bgProtection">　활성　</label>
									<input type="radio" name="m_bgProtection" id="m_bgProtection" value="1" onclick="setbgProtection(this.value)">
			
									<label for="m_bgProtection1">　비활성　</label>
									<input type="radio" name="m_bgProtection" id="m_bgProtection1" value="0" onclick="setbgProtection(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_rtsThreshold" style="display:none">
				<td>RTS 설정</td>
				<td>
					<input type="text" name="rtsThreshold" id="rtsThreshold" value="">(범위 : 1~2346)
				</td>
			</tr>
			<tr id="view_fragThreshold" style="display:none">
				<td>Fragment 설정</td>
				<td>
					<input type="text" name="fragThreshold" id="fragThreshold" value="">(범위 : 256~2346)
				</td>
			</tr>
			<tr id="view_dtimPeriod" style="display:none">
				<td>DTIM 주기</td>
				<td>
					<input type="text" name="dtimPeriod" id="dtimPeriod" value="">(범위 : 1~255)
				</td>
			</tr>
			<tr id="view_multi2uni" style="display:none">
				<td>MULTI-UNI 변환</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_m2u">　활성　</label>
									<input type="radio" name="m_m2u" id="m_m2u" value="1" onclick="setm2u(this.value)">
			
									<label for="m_m2u1">　비활성　</label>
									<input type="radio" name="m_m2u" id="m_m2u1" value="0" onclick="setm2u(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_stbc" style="display:none">
				<td>STBC 설정</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_stbc">　활성　</label>
									<input type="radio" name="m_stbc" id="m_stbc" value="1" onclick="setSTBC(this.value)">

									<label for="m_stbc1">　비활성　</label>
									<input type="radio" name="m_stbc" id="m_stbc1" value="0" onclick="setSTBC(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_txbf">
				<td>TxBF</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_txbf">　활성　</label>
									<input type="radio" name="m_txbf" id="m_txbf" value="1" onclick="changeTXBF(this.value)">

									<label for="m_txbf1">　비활성　</label>
									<input type="radio" name="m_txbf" id="m_txbf1" value="0" onclick="changeTXBF(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="view_txbf_list">
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_txbf_list">  Explicit TxBF </label>
									<input type="radio" name="m_txbf_list" id="m_txbf_list" value="1" onclick="changeTxBF_List(this.value)">
									
									<label for="m_txbf_list1">  Implicit TxBF </label>
									<input type="radio" name="m_txbf_list" id="m_txbf_list1" value="2" onclick="changeTxBF_List(this.value)">
									
									<label for="m_txbf_list2">  Explicit/Implicit TxBF </label>
									<input type="radio" name="m_txbf_list" id="m_txbf_list2" value="3" onclick="changeTxBF_List(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="view_mmimo">
				<td>MU-MIMO</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_mmimo">　활성　</label>
									<input type="radio" name="m_mmimo" id="m_mmimo" value="1" onclick="changeMMIMO(this.value)">

									<label for="m_mmimo1">　비활성　</label>
									<input type="radio" name="m_mmimo" id="m_mmimo1" value="0" onclick="changeMMIMO(this.value)">
								</fieldset>
							</td>
						</tr>
						<tr id="view_mmimo_list">
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_mmimo_list"> 스트림 1개	</label>
									<input type="radio" name="m_mmimo_list" id="m_mmimo_list" value="1" onclick="changeMMIMO_List(this.value)">
									
									<label for="m_mmimo_list1"> 스트림 2개	</label>
									<input type="radio" name="m_mmimo_list" id="m_mmimo_list1" value="2" onclick="changeMMIMO_List(this.value)">
									
								
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_KT_setWirelessBasic')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
