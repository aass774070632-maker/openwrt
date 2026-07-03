
<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var maxChannelCount = 0;

var arrData = new Array();
var tableRule = null; 	

var ckData = new Array();
var arrClientInfo = new Array();

function linkto(Sender){
    document.location.href = Sender.src;
}


function validate_wepkey(){
	var ret = 0;
	var wepKey = document.getElementById("encKey");
	var wepKeyType = document.getElementById("wepKeyType");
	var wepKeyTypeValue = parseInt( wepKeyType.value , 10 );
	
	if( isEmpty( wepKey.value ) == false ){
		switch(wepKeyTypeValue){
		case 0:	
			if( wepKey.value.length == 10)	ret = 1;
		break;
		case 1:	
			if( wepKey.value.length == 10){
				ret = ( isHex( wepKey.value ) ) ? 1 : -1;
			}else{
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
		}else if( ret == -2){
			alert("암호는 10자입니다.");
		}else{
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
	case '13':	/* WPA3-PSK */
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
	var channel = "";
	
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

	channel = items[2].split(/[+\/]/);
	if(channel[0] < 15){
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
			//TODO
			securityMode = '5';
		}else if( items[5].indexOf('WPA3') != -1 ){
			securityMode = '13';
		}else if( items[5].indexOf('WPA2') != -1 ){
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
	if( items[3].indexOf('B') != -1 ){	rate += 1;	}
	if( items[3].indexOf('G') != -1 ){	rate += 2;	}
	if( items[3].indexOf('N') != -1 ){	rate += 4;	}
	if( items[3].indexOf('A') != -1 ){	rate += 8;	}

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
	changeTable();
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

function layoutChannelList_channel(){
	if( tableRule == null ){
		initTable_pc_channel();
	}
	if( tableRule != null ){
		tableRule.setRows(arrData);
		tableRule.layout();
	}
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
	}else if( security == '13' || security == '14' ){
		//wpa3-psk, wpa2/wpa3-psk
		securityMode = '13';
		if( encType == '2' || encType == '1' ){	//TKIP/AES, AES
			encTypeVal = '1';	//AES
		}else{
			encTypeVal = '0';	//TKIP
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
	var wepKeyType = document.getElementById("wepKeyType");
	var wepKeyTypeValue = parseInt( wepKeyType.value , 10 );

	switch( securityModeValue ){
	case '0':	
		$("#view_encType").hide();
		$("#view_encKey").hide();
		$("#view_webKeyType").hide();
	break;
	case '3':	
		$("#view_encType").hide();
		$("#view_encKey").show();
		$("#view_webKeyType").show();
		if(wepKeyTypeValue == 0){
			$("#password_stat").text("암호는 10자입니다.");
		}else{
			$("#password_stat").text("암호는 10자입니다.");
		}
		changeTable();
	break;
	case '4':	
	case '5':
	case '13':	/* WPA3-PSK */
		$("#view_encType").show();
		$("#view_encKey").show();
		$("#view_webKeyType").hide();
		$("#password_stat").text("암호는 10자 이상 64자 이하여야 합니다.");
		changeTable();
	break;
	default:
		alert("Not Supported SecurityMode");
	break;
	}
}

function connectionTypeSwitch(){
	if( $("#sel_connectionType option:selected").val() == 1 ){
		$("#view_static").show();
		$("#view_dhcp").hide();
	}else{
		$("#view_static").hide();
		$("#view_dhcp").show();
	}
	if( gIsMobile == '1' ){
		$('select#sel_connectionType').selectmenu('refresh'); 
	}
	onClickDhcpDnsType();
}

function onClickDhcpDnsType(){
	
	if( $("input[name='rdo_dhcpDnsType']:checked").val() == 1 ){
		$("#view_dhcpDnsAddr").show();
	}else{
		$("#view_dhcpDnsAddr").hide();
	}
}

function checkIpRange(str, min, max)
{
	var	val;

	if (str.length < 1 || str.length > 3) return false;

	for (var i = 0; i < str.length; i++) {
		if ((str.charAt(i) < '0' && str.charAt(i) > '9')) return false;
	}

	val = parseInt(str, 10);
	if (val < min || val > max) return false;

	return true;
} 

function checkIpAddr(field, fieldname, chktype)
{
	var	i;
	var	parts;

	if (field.value == "") {
		alert(fieldname + "입력하셔야 합니다.");
		field.focus();
		return false;
	}

	if (field.value.length < 7 || field.value.length > 15) {
		alert(fieldname + "잘못 입력하셨습니다.");
		field.focus();
		return false;
	}

	parts = field.value.split('.');
	if (parts.length > 4) {
		alert(fieldname + "잘못 입력하셨습니다.");
		field.focus();
		return false;
	}

	for (i = 0; i < 4; i++) {
		if (!checkIpRange(parts[i], 0, 255)) {
			alert(fieldname + "잘못 입력하셨습니다.");
			field.focus();
			return false;
		}
	}

	if (chktype == 1) {	
		var val1 = parseInt(parts[0], 10);
		var val2 = parseInt(parts[1], 10);
		var val3 = parseInt(parts[2], 10);
		var val4 = parseInt(parts[3], 10);
		var	valid = true;

		if (val1 == 0   && val2 == 0   && val3 == 0   && val4 == 0)   valid = false;
		if (val1 == 255 && val2 == 255 && val3 == 255 && val4 == 255) valid = false;
		if (val1 == 127 && val2 == 0   && val3 == 0   && val4 == 1)   valid = false;

		if (!valid) {
			alert(fieldname + "잘못 입력하셨습니다.");
			field.focus();
			return false;
		}
	}
	else if (chktype == 2) {	
		var val1 = parseInt(parts[0], 10);
		var val2 = parseInt(parts[1], 10);
		var val3 = parseInt(parts[2], 10);
		var val4 = parseInt(parts[3], 10);
		var	valid = true;

		if (val1 != 0 && val1 != 128 && val1 != 192 && val1 != 224 && val1 != 240 && val1 != 248 && val1 != 252 && val1 != 254 && val1 != 255) valid = false;
		if (val2 != 0 && val2 != 128 && val2 != 192 && val2 != 224 && val2 != 240 && val2 != 248 && val2 != 252 && val2 != 254 && val2 != 255) valid = false;
		if (val3 != 0 && val3 != 128 && val3 != 192 && val3 != 224 && val3 != 240 && val3 != 248 && val3 != 252 && val3 != 254 && val3 != 255) valid = false;
		if (val4 != 0 && val4 != 128 && val4 != 192 && val4 != 224 && val4 != 240 && val4 != 248 && val4 != 252 && val4 != 254 && val4 != 255) valid = false;

		if (!valid) {
			alert(fieldname + "잘못 입력하셨습니다.");
			field.focus();
			return false;
		}
	}

	return true;
}

function validateOnSubmit_dhcp(){
	var dns1, dns2;
	
	if( $("#sel_connectionType option:selected").val() == 1 ){
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
		if( $("input[name='rdo_dhcpDnsType']:checked").val() == 1 ){
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
		gOperModeWan = 		'<% mcr_getCfgCommon("SysOperMode_WanInterface"); %>';

		<% var gWlanVXDEJ = mcr_getCfgWirelessEJ("Wlan_WanIndex"); %>
		
		gClient_ssid = 		'<% mcr_getCfgWireless("Wlan_SSID", 			gWlanVXDEJ); %>';
		gClient_security = 	'<% mcr_getCfgWireless("Wlan_SecurityMode", 	gWlanVXDEJ); %>';
		gClient_encType = 	'<% mcr_getCfgWireless("Wlan_EncryptType", 		gWlanVXDEJ); %>';
		gClient_encKey = 	'<% mcr_getCfgWireless("Wlan_WEPPSKKey", 		gWlanVXDEJ); %>';
		gClient_keyType = 	'<% mcr_getCfgWireless("Wlan_KeyType", 			gWlanVXDEJ); %>';
		
		gWirelessOperMode = 	'<% mcr_getCfgWireless("Wlan_WirelessOperMode", 	gWlanIfIndexEJ); %>';
		gChannel = 			'<% mcr_getCfgWireless("Wlan_Channel", 			gWlanIfIndexEJ); %>';
		gChBandWidth = 		'<% mcr_getCfgWireless("Wlan_ChannelBandWidth", gWlanIfIndexEJ); %>';
		gChExtension = 		'<% mcr_getCfgWireless("Wlan_ChannelExtension", gWlanIfIndexEJ); %>';
		
		gWanConnType = 		'<% mcr_getCfgCommon("WanDevice_WanConnType"); %>';

		
		$("input[name='rdoOperModeWan']").val([ gOperModeWan ]);
		$("#sel_connectionType").val([ gWanConnType ]);

	}
	if( $("input[name='rdoOperModeWan']").val() == '1' ){
		gOperModeWan = '1';
		gWirelessOperMode = '4';	
	}else{
		gOperModeWan = '0';
		gWirelessOperMode = '0';	
	}
	
	
	if( arrClientInfo.length != 0 ){
		gClient_ssid 		= arrClientInfo[1];
		gChBandWidth 		= arrClientInfo[4];
		gChannel 			= arrClientInfo[5];
		gChExtension 		= arrClientInfo[6];
		gClient_security	= arrClientInfo[7];
		gClient_encType		= arrClientInfo[8];
		gClient_keyType  	= '0';					
		
		gOperModeWan = '1';
		gWirelessOperMode = '4';	
	}
	if( gClient_ssid == 'DEFAULT_CLIENT_#!@#$' ) 
		gClient_ssid = "";
	
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
	
	$("input[name='is_mobile']").val("0" );  

	onChangeSecurityMode();
	connectionTypeSwitch();
}
