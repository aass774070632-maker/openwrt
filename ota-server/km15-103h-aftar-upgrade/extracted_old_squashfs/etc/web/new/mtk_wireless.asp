<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Wireless HwInfo</title>
<link rel="stylesheet" type="text/css" href="/style/normal_ws.css">
<link rel="stylesheet" type="text/css" href="/style/default_wireless.css">


<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="/lang/b28n.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js"></script>
<script language="javaScript" type="text/javascript" src="/script/jquery.js"></script>
<script language="JavaScript" type="text/javascript">

Butterlate.setTextDomain("wireless");

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var gAntPath_0 = '0';
var gAntPath_100 = '0';

function getSelectedSSIDIndex(){
	var e = document.getElementById("ssid");
	return e[e.selectedIndex].value;
}
  
function onClickRefresh(){
	var selectedSSID = getSelectedSSIDIndex();
	
	var strURL = generateMultiWlanURL(null, selectedSSID, true, "/new/mtk_wireless.asp" );
	window.location.href = "http://"+window.location.host + strURL;
}

function validateOnSubmit(){
	antpath_0 = $( "#antpath_0" ).val();
	antpath_100 = $( "#antpath_0" ).val();

	if( gAntPath_0 != antpath_0 || gAntPath_100 != antpath_100){
		$("#wlanReboot").val('1');
	}

	return true;
}

function initForms(useDefault){ 
	var txstream = 4, rxstream = 4;
	var bw_signal = 0;
	var txlimit = 0;
	var vht_256qam = 0;

	if( useDefault == 0 ){ 
		bw_signal = '<% mcr_getCfgWireless("Wlan_VHT_BWSignal", gWlanIfIndexEJ); %>';
		txstream = '<% mcr_getCfgWireless("Wlan_TxStreamCount", gWlanIfIndexEJ); %>';
		rxstream = '<% mcr_getCfgWireless("Wlan_RxStreamCount", gWlanIfIndexEJ); %>';

		txlimit = '<% mcr_getCfgWireless("Wlan_MTK_TxLimit", gWlanIfIndexEJ); %>';

		gAntPath_0 = antpath_0 = '<% mcr_getCfgWireless("Wlan_AntPath", "0"); %>';
		gAntPath_100 = antpath_100 = '<% mcr_getCfgWireless("Wlan_AntPath", "100"); %>';

		vht_256qam = '<% mcr_getCfgWireless("Wlan_VHT_Use256QAM", "100"); %>';
	}

	initComboById("bw_signal", bw_signal);

	initComboById("txstream", txstream);
	initComboById("rxstream", rxstream);

	initComboById("txlimit", txlimit);

	initComboById("antpath_0", antpath_0);
	initComboById("antpath_100", antpath_100);

	initComboById("vht_256qam", vht_256qam);

	updateMBSSIDList(gWlanIfIndex);
}

function initValue(){
	setMultiWlanInfo(window.location, gWlanIfIndex, null, document.form_wlanMTKConfig );
	initForms(0);
}

function updateMBSSIDList(defaultSSIDIndex){
	var j = 0;
	var ssidIndex = 0;
	var ssidElement = document.getElementById("ssid");
	var wirelessen = "<% mcr_getCfgString("SysConfDb_WirelessEn"); %>";
	var maxPhyInf = "<% mcr_getCfgWireless("Wlan_MaxPhyInf"); %>";
	
	if( defaultSSIDIndex == -1 ) defaultSSIDIndex = 0;
	
	ssidElement.length = 0;
	for(var i=0; i<maxPhyInf; i++){
		ssidIndex = i * 100;
		if( i == 0 ){
			ssidElement.options[j] = new Option("5GHz", ssidIndex);
		}else{
			ssidElement.options[j] = new Option("2.4GHz", ssidIndex);
		}
		if( ssidIndex == defaultSSIDIndex ){
			ssidElement.options[j].selected = true;
		}	
		j++;
	}
} 


</script>
</head>

<body class="wbody" onload="initValue()">

<h1 id="title"></h1>
<h4 id="introduction"></h4>
<hr> 

<form method="post" class="form_layout" id="form_RTLHwInfo" name="form_wlanMTKConfig" action="/goform/mcr_setWirelessMTKConfig" onsubmit="return validateOnSubmit()">

<input type="hidden" name="wlanIfIndex" value="">
<input type="hidden" id="wlanReboot" name="wlanReboot" value="0">
 


<div class="div_layout">
<table class="wtbl">
  <tr class="wtr">
    <td class="whead" id="lbl_ssid">Interface</td>
    <td>
		<select class="wsel_l" id="ssid" name="ssid">
		</select>
		<input type="button" value="Refresh" id="btn_refresh" name="btn_refresh" onclick="onClickRefresh()">
    </td>
  </tr>
</table>	
</div>



<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mtk_wireless.asp">	

<div class="div_layout">

<table class="wtbl">
  
  <tr class="wtr">
    <td class="whead" id="lbl_txstream">Tx Stream</td>
    <td class="wbody">
		<select class="wsel_l" id="txstream" name="txstream">
			<option value="1">1</option>
			<option value="2">2</option>
			
		</select>
    </td>
  </tr>
</table>

<table class="wtbl">
  
  <tr class="wtr">
    <td class="whead" id="lbl_rxstream">Rx Stream</td>
    <td class="wbody">
		<select class="wsel_l" id="rxstream" name="rxstream">
			<option value="1">1</option>
			<option value="2">2</option>
			
		</select>
    </td>
  </tr>
</table>
</div>


<div class="div_layout">
<table class="wtbl">
  
  <tr class="wtr">
    <td class="whead" id="lbl_txlimit">Tx Limit</td>
    <td class="wbody">
		<select class="wsel_l" id="txlimit" name="txlimit">
			<option value="0">OFF</option>
			<option value="1">ON</option>
		</select>
    </td>
  </tr>
</table>
</div>

<div class="div_layout">
<table class="wtbl">
  <tr class="wtr">
    <td class="whead" id="lbl_vht_256qam">2G 256QAM</td>
    <td class="wbody">
		<select class="wsel_l" id="vht_256qam" name="vht_256qam">
			<option value="0">OFF</option>
			<option value="1">ON</option>
		</select>
    </td>
  </tr>
</table>
</div>

<div class="div_layout">
<table class="wtbl">
  <tr class="wtr">
    <td class="whead" id="lbl_antpath">설정변경시 재부팅합니다</td>
    
  </tr>
</table>
<table class="wtbl">
  
  <tr class="wtr">
    <td class="whead" id="lbl_antpath_5g">AntPath (5G)</td>
    <td class="wbody">
		<select class="wsel_l" id="antpath_0" name="antpath_0">
			<option value="0">Default</option>
			<option value="1">A only</option>
			<option value="2">B only</option>
			
		</select>
    </td>
  </tr>
  
  <tr class="wtr">
    <td class="whead" id="lbl_antpath_2g">AntPath (2G)</td>
    <td class="wbody">
		<select class="wsel_l" id="antpath_100" name="antpath_100">
			<option value="0">Default</option>
			<option value="1">A only</option>
			<option value="2">B only</option>
			
		</select>
    </td>
  </tr>
</table>
</div>


<div class="div_button">
    <input type="submit" class="gradbtn" value="Apply" id="btn_apply_antpath" name="btn_apply">
</div>
</form>


</body>

</html>