<html>
<head>
<%include('new/metatag.asp');%>
<title>무선 공통 설정</title>
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
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_channel.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
var WirelessMode_1 = '<% mcr_getCfgWireless("Wlan_ACType", gWlanIfIndexEJ); %>';

var cpuName;
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
}

function updateChannelExtension(defaultChExtension){
	var nChBandWidth = getRadioSelectedValueByName("chBandWidth");
	
	setChannelExtension("uichExtension", "uiChannel", gFreqType, gProjectCode, nChBandWidth, defaultChExtension);
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
	
	$("#wirelessMode").val( wirelessModeVal );
	
	return wirelessModeVal;
}

function mcr_setWirelessMode(cWirelessMode){
	var strName = mcr_getWebName_WirelessMode();
	$("input[name='"+strName+"']").val( [cWirelessMode] );
	
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
	if( channel == '0' ){
		if( !(gAutoChannelRange & (1<<30)) ){
			$("input[name='uiChannelMode']").val( ['0'] );	
		}else{
			$("input[name='uiChannelMode']").val( ['-2'] );	
		}
	}else{
		$("input[name='uiChannelMode']").val( ['-1'] );	
		$("#uiChannel").val( [channel] );	
	}	
}

function updateBandWidth(freqType, nWirelessMode, defaultBandWidth){
	var ieee11acDisplay; 
	var ieee11nDisplay;
	if( defaultBandWidth == '-1' ){
		if( freqType == '2' ){
			if( nWirelessMode & 0x10 || nWirelessMode & 0x20 ){
				defaultBandWidth = '2';
			}else if( nWirelessMode & 0x04 ){	
				defaultBandWidth = '1';
			}
		}

		if( defaultBandWidth == '-1'){
			defaultBandWidth = '0';
		}
	}
	if( nWirelessMode & 0x04 || nWirelessMode & 0x10 || nWirelessMode & 0x20 ){
		ieee11nDisplay = true;
		if( nWirelessMode & 0x10 || nWirelessMode & 0x20 ){
			ieee11acDisplay = true;
		}
	}else{
		ieee11nDisplay = false;
		defaultBandWidth = '0';
	}
		
	if( freqType == '1' ){
		$("#chBandWidth_2").hide();	
		// $("#chBandWidth_3").hide();	
		// $("#chBandWidth_4").hide();	
	}else{
		if( ieee11acDisplay ){
			$("#chBandWidth_2").show();
			// $("#chBandWidth_3").show();
			// $("#chBandWidth_4").show();
			$("#wireless_mode_5G").val("0");
		}else{
			$("#chBandWidth_2").hide();	
			// $("#chBandWidth_3").hide();	
			// $("#chBandWidth_4").hide();	
		}
	}
	
	if( defaultBandWidth != null ){
		$("input[name='chBandWidth']").val( [defaultBandWidth] );	
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

	var varChBandWidth = getRadioSelectedValueByName( "chBandWidth" );
	var nChBandWidth = parseInt(varChBandWidth,10); 
	
	if( nWirelessMode & 0x04 || nWirelessMode & 0x10 || nWirelessMode & 0x20 ){
		ieee11nDisplay = true;
	}else{
		ieee11nDisplay = false;
		nChBandWidth = 0;		
	}
	
	updatePrimaryChannel(gFreqType, gProjectCode, defaultChannel, nChBandWidth, gAvailChannelRange );
		
	if( ieee11nDisplay && varChBandWidth == "18" ){	
		$("#view_chExtension").show();
	}else{
		$("#view_chExtension").hide();
	}
	
	setAutoChannelRange("view_autochannelrange_div", gFreqType, gProjectCode, nChBandWidth, gAvailChannelRange, 7, 1);
	gChBandWidth = ''+nChBandWidth;
	setAutoChannelRangeValue(gFreqType, gAutoChannelRange);
	
	updateDataRate(document.getElementById("mcs"), 
		defaultRate, gFreqType, gBandMode, nWirelessMode, nChBandWidth);
	onChangeChannel(defaultChExtension); 	
}


function onChangeWirelessMode(defaultBandWidth, defaultChannel, defaultChExtension, defaultRate){
	var wirelessModeVal = mcr_getWirelessMode();
	var nWirelessMode = parseInt(wirelessModeVal, 10);

	updateBandWidth(gFreqType, nWirelessMode, defaultBandWidth);
	
	onChangeChannelBandWidth(defaultChannel, defaultChExtension, defaultRate);
}


function onAutoChannelRange(){
	var availChannelRange = getBandWidthAvailChannelRange();
	var autoChannelRange = gAutoChannelRange & availChannelRange;
	var varChBandWidth = getRadioSelectedValueByName( "chBandWidth" );
	
	var channelMode = $("input[name='uiChannelMode']:checked").val();
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
					// autoChannelRange = 0x000ffff;
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
	var channelMode = $("input[name='uiChannelMode']:checked").val();
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
	
	if(gWlanIfIndex == '0'){
		var Activity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';
		var confirmed = false;
		if(Activity == 1 && checkIoWChannelRange() != 1){
			confirmed = confirm("설정된 채널에서 IoW 동작이 원활하지 않을 수 있습니다. 계속하시겠습니까?");
			if(!confirmed)
				return false;
		}
	}
	mergeChannel();
	
	return true;
}

function checkIoWChannelRange(){
	var ret = 1;
	//IOW 설정상태 확인 DB

	var wlanRadioActivity = '<% mcr_getCfgWireless("Wlan_Enable", 4); %>';

	if( wlanRadioActivity == '0' ) return 1;
	
	channelStr = '<% mcr_getCfgWireless("Wlan_Channel", 0); %>';   
	autoChannelRangeStr = '<% mcr_getCfgWireless("Wlan_AutoChannelRange",0); %>';

	var channelMode = $("input[name='uiChannelMode']:checked").val();
	
	var prev_channel = parseInt( channelStr, 10 );
	var autoChannelRange = parseInt( autoChannelRangeStr, 10 );

	var autochrange = parseInt( $("#autochannelrange").val(), 10 );
	$("#autochannelrange").val( ''+( autochrange | (1<<30)) );
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
	var strTableAttr = "class='TB' id='Grid_Table' width='100%' border='0' cellpadding='0' style='table-layout:fixed;' bgcolor='#FFFFFF'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "class='BG1'";
	var strTableTd = "class='BG2-2'";
	
	tableRule = new MCRTable("view_aplist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
		strTableAttr,
		"",
		strTableTr, 
		"AP 정보가 없습니다.", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "무선 LAN 이름", "width='160'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "BSSID", "width='120'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "채널", "width='100'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "모드", "width='110'", strTableTh, strTableTd+" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "신호세기", "width='100'", strTableTh, strTableTd+" align='center'", "");
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
	$("input[name='uiWirelessMode_2G']").bind( "change", function(){
		onChangeWirelessMode('-1');	

		changeTableAdmin();
		return true;
	});
	$("input[name='uiWirelessMode_5G']").bind( "change", function(){
		onChangeWirelessMode('-1');	
		
		changeTableAdmin();
		return true;
	});
	$("input[name='chBandWidth']").bind( "change", function(){
		onChangeChannelBandWidth();
		
		changeTableAdmin();
		return true;
	});
	$("input[name='uiChannelMode']").bind( "change", function(){
		onAutoChannelRange();
		
		changeTableAdmin();
		return true;
	});
	$("#uiChannel").bind( "change", function(){
		onChangeChannel();
		
		changeTableAdmin();
		return true;
	});
	$("#wlanBtnSearch").bind( "click", function(){
		onClickChannelScan();
		return false;
	});	
	$("#form_basic").bind( "submit", function(){
		return validateOnSubmit();
	});
	// menu - mouse event
	var menu_sel = 0;
	$("label[id^='wlanUIMenu']").each( function(){
		$(this).bind({
			mouseenter: function(){
				menu_sel = $( this ).hasClass('menu3rdSelect');
				$( this ).removeClass("menu3rdNormal menu3rdSelect").addClass("menu3rdMouse");
			},
			mouseleave: function(){
				if( menu_sel ){
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdSelect");
					menu_sel = 0;
				}else{
					$( this ).removeClass("menu3rdMouse").addClass("menu3rdNormal");
				}
			}
		});
	});
	$(document).mjq_disableSelection();
	$("input[type='text']").mjq_disableInputEnter();

	initValue();
});

function initForm_WLAN_Basic(useDefault){
	var cWirelessMode;
	var channel, chBandWidth, chExtension, mcs, activeChannel, vht_2ndCh;
	var autoChannelRange, availChannelRange;
	var beaconInterval, dtimPeriod, rtsThreshold, fragThreshold, bgProtection;
	var txPower, shortSlot, preambleType;
	var m2u;
	var txbf;
	var dl_mmimo, ul_mmimo;
	var stbc, ldpc;
	var dl_ofdma, ul_ofdma, bss_coloring, twt;
	var he_gi_tx, he_gi_rx, guard_interval;
	
	if( useDefault == 0 ){
		cWirelessMode = '<% mcr_getCfgWireless("Wlan_WirelessMode", gWlanIfIndexEJ); %>';	
		gOrgWirelessMode = cWirelessMode;
		channel = '<% mcr_getCfgWireless("Wlan_Channel", gWlanIfIndexEJ); %>';				
		chBandWidth = '<% mcr_getCfgWireless("Wlan_ChannelBandWidth", gWlanIfIndexEJ); %>';
		gChBandWidth = chBandWidth;
		gOrgBandWidth = chBandWidth;
		chExtension = '<% mcr_getCfgWireless("Wlan_ChannelExtension", gWlanIfIndexEJ); %>'; 		
		vht_2ndCh = '<% mcr_getCfgWireless("Wlan_VHT_2ndCh", gWlanIfIndexEJ); %>';
		
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
		//shortSlot = '<% mcr_getCfgWireless("Wlan_ShortSlot", gWlanIfIndexEJ); %>';
		preambleType = '<% mcr_getCfgWireless("Wlan_PreambleType", gWlanIfIndexEJ); %>';
		ampdu = '<% mcr_getCfgWireless("Wlan_Ampdu", gWlanIfIndexEJ); %>';
		
		m2u = '<% mcr_getCfgWireless("Wlan_MulticastToUnicastEnable", gWlanIfIndexEJ); %>';
		txbf = '<% mcr_getCfgWireless("Wlan_TxBeamforming", gWlanIfIndexEJ); %>';
		stbc = '<% mcr_getCfgWireless("Wlan_STBC_Enable", gWlanIfIndexEJ); %>';
		dl_mmimo = '<% mcr_getCfgWireless("Wlan_DL_MuMIMO", gWlanIfIndexEJ); %>';
		ul_mmimo = '<% mcr_getCfgWireless("Wlan_UL_MuMIMO", gWlanIfIndexEJ); %>';

		dl_ofdma = '<% mcr_getCfgWireless("Wlan_OFDMA_DN_Enable", gWlanIfIndexEJ); %>';
		ul_ofdma = '<% mcr_getCfgWireless("Wlan_OFDMA_UP_Enable", gWlanIfIndexEJ); %>';
		bss_coloring = '<% mcr_getCfgWireless("Wlan_BSSColorEnable", gWlanIfIndexEJ); %>';
		twt = '<% mcr_getCfgWireless("Wlan_TWTEnable", gWlanIfIndexEJ); %>';

		ldpc = '<% mcr_getCfgWireless("Wlan_LDPCEnable", gWlanIfIndexEJ); %>';
		he_gi_tx = '<% mcr_getCfgWireless("Wlan_HE_GI_TX", gWlanIfIndexEJ); %>';
		he_gi_rx = '<% mcr_getCfgWireless("Wlan_HE_GI_RX", gWlanIfIndexEJ); %>';
		guard_interval = '<% mcr_getCfgWireless("Wlan_GI", gWlanIfIndexEJ); %>';
		//qam_256 = '<% mcr_getCfgWireless("Wlan_", gWlanIfIndexEJ); %>';
	}
	$("#wlanUIMenu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	updateWirelessMode(gFreqType, cWirelessMode);

	if( chBandWidth == '18' ){	
		onChangeWirelessMode(chBandWidth, channel, vht_2ndCh, mcs);
	}else{
		onChangeWirelessMode(chBandWidth, channel, chExtension, mcs);
	}
	updateChannelMode(channel);
	
	$("input[name='uiChannelMode']:checked").trigger("change");

	layoutStationList();
	if( gFreqType == '1' ){
		$("#view_multi2uni").hide();
		// $("#view_txbf").hide();
		// $("#view_stbc").hide();
		// $("#view_mmimo").hide();
	}else{
		$("#view_multi2uni").show();
		// $("#view_stbc").show();
		// $("#view_txbf").show();
		// $("#view_mmimo").show();
	}
	if(txbf != '0'){
		document.getElementsByName("txbf")[0].checked = true;
		$("input[name='dl_mmimo']").prop("disabled",false);
		$("input[name='ul_mmimo']").prop("disabled",false);
	}else{
		document.getElementsByName("txbf")[1].checked = true;
		$("input[name='dl_mmimo']").prop("disabled",true);
		$("input[name='ul_mmimo']").prop("disabled",true);
	}
	changeTxBF(txbf);
	$("#view_twt").show();
	$("#view_bss_coloring").hide();
	///////////////////////////////////////////////// 
	$("#uiActiveChannel").text( activeChannel );

	$("input[name='txPower']").val( [txPower] );
	$("#beaconInterval").val( beaconInterval );
	$("input[name='preambleType']").val( [preambleType] );	
	$("input[name='shortSlot']").val( [shortSlot] );	
	$("input[name='ampdu']").val( [ampdu] );	
	$("input[name='bgProtection']").val( [bgProtection] );	
	$("#rtsThreshold").val( rtsThreshold );
	$("#fragThreshold").val( fragThreshold );
	$("#dtimPeriod").val( dtimPeriod );
	
	$("input[name='m2u']").val( [m2u] );
	//$("input[name='txbf']").val( [txbf] );
	$("input[name='stbc']").val( [stbc] );

	$("input[name='dl_ofdma']").val( [dl_ofdma] );
	$("input[name='ul_ofdma']").val( [ul_ofdma] );
	$("input[name='bss_coloring']").val( [bss_coloring] );
	$("input[name='twt']").val( [twt] );

	$("input[name='ldpc']").val( [ldpc] );
	$("input[name='he_gi_tx']").val( [he_gi_tx] );
	$("input[name='he_gi_rx']").val( [he_gi_rx] );
	$("input[name='guard_interval']").val( [guard_interval] );
	$("input[name='dl_mmimo']").val( [dl_mmimo] );
	$("input[name='ul_mmimo']").val( [ul_mmimo] );
	
	// setPrivilageControl(0);
}


function validateOnSubmit(){

	var ret = validateOnSubmit_WLAN_Basic();
	if( ret == true ){
		// setPrivilageControl(1);
		parent.mcrProgress.startProgressSimple("apply", 25);
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

	changeTableAdmin();
}


function initValue(){
	parent.mcrProgress.stopProgress();
	
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );
	
	initForms(0);
}

/*
function setPrivilageControl(flag){
	if( flag != 0 ){
		$("input[name='txPower']").prop("disabled",false);
		$("select[name='mcs']").prop("disabled",false);
		$("input[name='preambleType']").prop("disabled",false);
		$("input[name='shortSlot']").prop("disabled",false);
		$("input[name='ampdu']").prop("disabled",false);
		$("input[name='bgProtection']").prop("disabled",false);
		$("input[name='m2u']").prop("disabled",false);	
		$("input[name='txbf']").prop("disabled",false);
		$("input[name='mmimo']").prop("disabled",false);
		$("input[name='stbc']").prop("disabled",false);
		$("input[name='qam']").prop("disabled",false);
	}
}
*/

function changeTxBF(val){
	if(val != '0'){
		$("#view_txbf_list").hide(); 
		$("input[name='dl_mmimo']").prop("disabled",false);
		$("input[name='ul_mmimo']").prop("disabled",false);
	
		if(gWlanIfIndex != '0'){
			document.getElementsByName("txbf_list")[0].checked = true;
			$("#txbf_list2").attr('disabled',true);
			$("#txbf_list3").attr('disabled',true);
		}else{
			if(val == '1'){
				document.getElementsByName("txbf_list")[0].checked = true;
			}else if(val == '2'){
				document.getElementsByName("txbf_list")[1].checked = true;
			}else if(val == '3'){
				document.getElementsByName("txbf_list")[2].checked = true;
			}
			$("#txbf_list1").attr('disabled',false);
			$("#txbf_list2").attr('disabled',false);
			$("#txbf_list3").attr('disabled',false);
		}
	}else{
		$("#view_txbf_list").hide(); 
		$("input[name='dl_mmimo']").prop("disabled",true);
		$("input[name='ul_mmimo']").prop("disabled",true);
	}
}
/*
function changeMIMO(val){
	var mimo = '<% mcr_getCfgWireless("Wlan_MuMIMO", gWlanIfIndexEJ); %>';
	if(val == "1"){
		$("#view_mmimo_list").show();
		if(mimo == "0"){
			document.getElementsByName("mmimo_list")[2].checked = true;
		}
	}else{
		$("#view_mmimo_list").hide();
	}
}
*/
</script>

<script>
	function changeTableAdmin() {
		if(document.body.scrollHeight>656) {
			parent.document.getElementById("main").style.height=document.body.scrollHeight;
			parent.document.getElementById("menu").style.height=document.body.scrollHeight;
		} else {
			parent.document.getElementById("main").style.height=656;
			parent.document.getElementById("menu").style.height=656;
		}
	}

</script>
</head>

<body>
<form method="post" class="form_layout" id="form_basic" name="form_basic" action="/goform/mcr_KT_setWirelessBasic">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>
<input type="hidden" id="wlanRedirectPage_AntPath" name="wlanRedirectPage_AntPath" value=""/>
<input type="hidden" id="channel" name="channel" value=""/>
<input type="hidden" id="autochannelrange" name="autochannelrange" value=""/>
<input type="hidden" id="chExtension" name="chExtension" value=""/>

<input type="hidden" id="wirelessMode" name="wirelessMode" value=""/>
<input type="hidden" id="wireless_mode_5G" name="wireless_mode_5G" value=""/>


<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_2_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td>
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> 무선 공통 설정</td>
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
										<tr id="view_wireless_mode_2G">
											<td class="BG2" style="width:140px" nowrap>무선 모드</td>
											<td class="BG2-2" width="600" colspan="4" >
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="1" />
															<label>b</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="2" />
															<label>g</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="4" />
															<label>n</label>
														</td>
														<td>
															<input type="radio" name="uiWirelessMode_2G" value="32" />
															<label>ax</label>
														</td>
													</tr>
													<tr>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="39" />
															<label>b/g/n/ax</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="7" />
															<label>b/g/n</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="38" />
															<label>g/n/ax</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_2G" value="6" />
															<label>g/n</label>
														</td>
														<td>
															<input type="radio" name="uiWirelessMode_2G" value="36" />
															<label>n/ax</label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_wireless_mode_5G">
											<td class="BG2" style="width:140px" nowrap>무선 모드</td>
											<td class="BG2-2" width="600" colspan="4" >
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="8" />
															<label>a</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="4" />
															<label>n</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="16" />
															<label>ac</label>
														</td>
														<td>
															<input type="radio" name="uiWirelessMode_5G" value="32" />
															<label>ax</label>
														</td>
													</tr>
													<tr>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="60" />
															<label>a/n/ac/ax</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="28" />
															<label>a/n/ac</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="52" />
															<label>n/ac/ax</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="20" />
															<label>n/ac</label>
														</td>
														<td width="100">
															<input type="radio" name="uiWirelessMode_5G" value="12" />
															<label>a/n</label>
														</td>
														<td>
															<input type="radio" name="uiWirelessMode_5G" value="48" />
															<label>ac/ax</label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_chBandWidth">
											<td class="BG2" style="width:140px;">채널 밴드</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<span id="chBandWidth_0">
															<input type="radio" name="chBandWidth" value="0"/><label>20MHz</label>
															</span>
														</td>
														<td width="110">
															<span id="chBandWidth_1">
															<input type="radio" name="chBandWidth" value="1"/><label>40MHz</label>
															</span>
														</td>
														<td width="110">
															<span id="chBandWidth_2">
															<input type="radio" name="chBandWidth" value="2"/><label>80MHz</label>
															</span>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">채널 모드</td>
											<td class="BG2-2" width="600" colspan="4" style="padding: 0 10 5 10;">
											<table  border="0" cellpadding="0" cellspacing="0" class="font1">
											<tr><td>
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="uiChannelMode" value="0"/><label>Auto</label>
														</td>
														<td width="110">
															<input type="radio" name="uiChannelMode" value="-2"/><label>Auto(Select)</label>
														</td>
														<td width="110">
															<input type="radio" name="uiChannelMode" value="-1"/><label>수동</label>
														</td>
														<td>(현재 채널 : <label id="uiActiveChannel"></label>)
														</td>
													</tr>
												</table>
											</td></tr>
											<tr id="viewChannelManual"><td>
												<table width="600" height="100%" border="0" cellpadding="0" cellspacing="0">
													<tr height="20">
														<td class="BG2-2">
															<table  border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="110">
																		<label>채널 선택</label>
																	</td>
																	<td width="50">
																		<select id="uiChannel" name="uiChannel" class="input2">
																		</select>
																	</td>
																	<td id="view_chExtension">
																		<select id="uichExtension" name="uichExtension">
																		</select>
																	</td>
																	<td width="70">
																		<input type="image" src="/images/BTN/BTN_07.gif?Sp2" width="52" height="24" value="wlanBtnSearch" id="wlanBtnSearch" name="wlanBtnSearch">
																	</td>
																</tr>
															</table>
														</td>
													</tr>			
													<tr>
														<td width="580" >
															<div>
																<table class='TB' id='Grid_Table' width='100%' border='0' style='table-layout:fixed;' bgcolor='#FFFFFF'>
																	<tr height="20">
																		<td class="BG1" width="160">무선 LAN 이름</td>
																		<td class="BG1" width="120">BSSID</td>
																		<td class="BG1" width="100">채널</td>
																		<td class="BG1" width="110">모드</td>
																		<td class="BG1" width="100">신호세기</td>
																	</tr>
																</table>
															</div>
														</td>
													</tr>
													<tr height="80">
														<td width="580" valign="top">
															<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
															<div id="view_aplist"></div>
															</span>
														</td>
													</tr>
												</table>
											</td></tr>
											<tr id="viewChannelSelect"><td>
												<table>
													<tr>
														<td width="60"><label>채널 선택</label></td>
														<td>
															<div id="view_autochannelrange_div"></div>
														</td>
													</tr>
												</table>
											</td></tr>
											</table>
											</td>
										</tr>
										<tr id="tx_power">
											<td rowspan="1" class="BG2" style="width:140px;">송신파워</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td>
															<input type="radio" name="txPower" value="100"/><label>Class1(100%)</label>
														</td>
														<td>
															<input type="radio" name="txPower" value="70"/><label>Class2(70%)</label>
														</td>
														<td>
															<input type="radio" name="txPower" value="50"/><label>Class3(50%)</label>
														</td>
														<td>
															<input type="radio" name="txPower" value="35"/><label>Class4(35%)</label>
														</td>
														<td>
															<input type="radio" name="txPower" value="15"/><label>Class5(15%)</label>
														</td>
														<td>
															<input type="radio" name="txPower" value="5"/><label>Class6(5%)</label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
 
										<tr id="view_mcs">
											<td class="BG2" style="width:140px;">전송율</td>
											<td class="BG2-2" width="600" colspan="4">
												<select id="mcs" name="mcs" class="input2">
												</select>
											</td>
										</tr>
										<tr id="view_beaconInterval">
											<td class="BG2" style="width:140px;">Beacon 주기</td>
											<td class="BG2-2" width="600" colspan="4">
												<input type="text" id="beaconInterval" name="beaconInterval" class="input2" value=""/>ms
											</td>
										</tr>
										<tr id="view_preambleType">
											<td class="BG2" style="width:140px;">Preamble 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="preambleType" value="1"/>Short
														</td>
														<td>
															<input type="radio" name="preambleType" value="0"/>Long
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_shortSlot">
											<td class="BG2" style="width:140px;">GI (802.11n)</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="guard_interval" value="1"/>Short
														</td>
														<td>
															<input type="radio" name="guard_interval" value="0"/>Long
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_ampdu">
											<td class="BG2" style="width:140px;">AMPDU</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="ampdu" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="ampdu" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_bgProtection">
											<td class="BG2" style="width:140px;">BG_Protect 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="bgProtection" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="bgProtection" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_rtsThreshold">
											<td class="BG2" style="width:140px;">RTS 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<input type="text" name="rtsThreshold" id="rtsThreshold" value="" class="input2" />(범위 : 1~2346)
											</td>
										</tr>
										<tr id="view_fragThreshold">
											<td class="BG2" style="width:140px;">Fragment 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<input type="text" name="fragThreshold" id="fragThreshold" value="" class="input2" />(범위 : 256~2346)
											</td>
										</tr>
										<tr id="view_dtimPeriod">
											<td class="BG2" style="width:140px;">DTIM 주기</td>
											<td class="BG2-2" width="600" colspan="4">
												<input type="text" name="dtimPeriod" id="dtimPeriod" value="" class="input2" />(범위 : 1~255)
											</td>
										</tr>
										<tr id="view_multi2uni">
											<td class="BG2" style="width:140px;">MULTI-UNI 변환</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="m2u" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="m2u" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_stbc">
											<td class="BG2" style="width:140px;">STBC 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="stbc" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="stbc" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_ldpc">
											<td class="BG2" style="width:140px;">LDPC 설정</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="ldpc" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="ldpc" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_txbf">
											<td class="BG2" style="width:140px;">TxBF</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="txbf" value="1" onclick="changeTxBF(value)"/>활성
														</td>
														<td>
															<input type="radio" name="txbf" value="0" onclick="changeTxBF(value)"/>비활성
														</td>
													</tr>
													<tr id=view_txbf_list>
														<td width="110">
															<input type="radio" name="txbf_list" id="txbf_list1" value="1"/>Explicit TxBF
														</td>
														<td width="110">
															<input type="radio" name="txbf_list" id="txbf_list2" value="2"/>Implicit TxBF
														</td>
														<td width="220">
															<input type="radio" name="txbf_list" id="txbf_list3" value="3"/>Explicit/Implicit TxBF
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_mmimo">
											<td class="BG2" style="width:140px;">DL MU-MIMO</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="dl_mmimo" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="dl_mmimo" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_mmimo_rx">
											<td class="BG2" style="width:140px;">UL MU-MIMO</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="ul_mmimo" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="ul_mmimo" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<!-- for AX -->
										<tr id="view_dl_ofdma">
											<td class="BG2" style="width:140px;">DL OFDMA</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="dl_ofdma" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="dl_ofdma" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_ul_ofdma">
											<td class="BG2" style="width:140px;">UL OFDMA</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="ul_ofdma" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="ul_ofdma" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_bss_coloring" style="display:none">
											<td class="BG2" style="width:140px;">BSS Coloring</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="bss_coloring" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="bss_coloring" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="view_twt" style="display:none">
											<td class="BG2" style="width:140px;">TWT</td>
											<td class="BG2-2" width="600" colspan="4">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="twt" value="1"/>활성
														</td>
														<td>
															<input type="radio" name="twt" value="0"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" value="wlanBtnApply" width="52" height="24" id="wlanBtnApply" name="wlanBtnApply"/></td>
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
