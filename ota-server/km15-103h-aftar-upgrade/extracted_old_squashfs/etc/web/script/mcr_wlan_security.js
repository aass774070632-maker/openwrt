///////////////////
// wlan security
/*
[form ID 정리]

*. Hidden 속성
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/aaa.asp"/>
<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value=""/>
<input type="hidden" id="wlanBroadSSID" name="wlanBroadSSID" value=""/>
<input type="hidden" id="wlanSecurityMode" name="wlanSecurityMode" value=""/>
<input type="hidden" id="wlanEncType" name="wlanEncType" value=""/>
<input type="hidden" id="wlanWEPKey" name="wlanWEPKey" value=""/>
<input type="hidden" id="wlanPSKKey" name="wlanPSKKey" value=""/>
<input type="hidden" id="wlanWPAKeyRenewInterval" name="wlanWPAKeyRenewInterval" value=""/>

*. DB와 동일
wlanRadioActivity
wlanSSID
wlanWEPKeyType
wlanWEPKeyIndex

*. UI Mapping
wlanUIHiddenSSIDEnable		=> wlanBroadSSID
wlanUISecurityType			=> wlanSecurityMode
wlanUIWEPEncType			=> wlanSecurityMode
wlanUIWEPKeyLen				=> wlanWEPKey

wlanUIWPAType				=> wlanSecurityMode
wlanUIWPAEncType			=> wlanEncType
wlanUIPSKKeyType			=> wlanPSKKey
wlanUIPSKKey				=> wlanPSKKey
wlanUIWPAKeyRenewalEnable	=> wlanWPAKeyRenewInterval
wlanUIWPAKeyRenewal			=> wlanWPAKeyRenewInterval

*. UI & DB (DB에도 저장)
wlanUIWEPKey0
wlanUIWEPKey1
wlanUIWEPKey2
wlanUIWEPKey3
*/
/*
 *	Key 비교용 Hidden 속성 추가(web only)
 *	wlanUISecurityType_org
 *	wlanUIEncType_org
 *	wlanKey_org
 */

function kt_keypolicy_getValue(strName){
	if( $("input[name='"+ strName +"']").attr('type') == 'radio' ){
		return $("input[name='"+ strName +"']:checked").val();
	}else{
		//hidden, text
		return $("#"+ strName).val();
	}
}

function kt_keypolicy_setCfg_orgInfo(){
	//backup UI
	$("#wlanUISecurityType_org").val( kt_keypolicy_getValue("wlanUISecurityType") );
	//WEP
	$("#wlanUIWEPEncType_org").val( kt_keypolicy_getValue("wlanUIWEPEncType") );
	$("#wlanWEPKeyType_org").val( kt_keypolicy_getValue("wlanWEPKeyType") );
	//PSK
	$("#wlanUIWPAType_org").val( kt_keypolicy_getValue("wlanUIWPAType") );
	$("#wlanUIWPAEncType_org").val( kt_keypolicy_getValue("wlanUIWPAEncType") );
	$("#wlanUIPSKKeyType_org").val( kt_keypolicy_getValue("wlanUIPSKKeyType") );

	//console.debug("kt_keypolicy_setCfg_orgInfo:"  );
	//console.debug("wlanUISecurityType_org:" + $("#wlanUISecurityType_org").val() );
	//console.debug("wlanUIWEPEncType_org:" + $("#wlanUIWEPEncType_org").val() );
	//console.debug("wlanWEPKeyType_org:" + $("#wlanWEPKeyType_org").val() );
	//console.debug("wlanUIWPAType_org:" + $("#wlanUIWPAType_org").val() );
	//console.debug("wlanUIWPAEncType_org:" + $("#wlanUIWPAEncType_org").val() );
	//console.debug("wlanUIPSKKeyType_org:" + $("#wlanUIPSKKeyType_org").val() );
	//console.debug("wlanKey_org:" + $("#wlanKey_org").val() );
}

function kt_keypolicy_isNeedCompare_keyInfo(newkey){
	var ret = false;
	var uiSecurityType = $("input[name='wlanUISecurityType']:checked").val();
	var uiSecurityType = kt_keypolicy_getValue("wlanUISecurityType");

	if( uiSecurityType == '0' ){	
		//None
		ret = false;
	}else if( uiSecurityType == '1' ){
		//WEP
		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType']:checked").val();
		var wlanUIWEPEncType = kt_keypolicy_getValue("wlanUIWEPEncType");
		var wlanWEPKeyType = kt_keypolicy_getValue("wlanWEPKeyType");

		//console.debug("wlanUISecurityType:" + uiSecurityType );
		//console.debug("wlanUIWEPEncType:" + wlanUIWEPEncType );
		//console.debug("wlanWEPKeyType:" + wlanWEPKeyType );
		//console.debug("wlanKey:" + newkey.value );

		if( uiSecurityType == $("#wlanUISecurityType_org").val() &&
			wlanUIWEPEncType == $("#wlanUIWEPEncType_org").val() &&
			wlanWEPKeyType == $("#wlanWEPKeyType_org").val() &&
			newkey.value == $("#wlanKey_org").val() ){

			ret = false;
		}else{
			ret = true;
		}
	}else if( uiSecurityType == '2' ){	
		//WPA
		var wlanUIWPAType = $("input[name='wlanUIWPAType']:checked").val();
		var wlanUIWPAEncType = $("input[name='wlanUIWPAEncType']:checked").val();
		var wlanUIPSKKeyType = $("input[name='wlanUIPSKKeyType']:checked").val();
		var wlanUIWPAType = kt_keypolicy_getValue("wlanUIWPAType");
		var wlanUIWPAEncType = kt_keypolicy_getValue("wlanUIWPAEncType");
		var wlanUIPSKKeyType = kt_keypolicy_getValue("wlanUIPSKKeyType");

		//console.debug("wlanUISecurityType:" + uiSecurityType );
		//console.debug("wlanUIWPAType:" + wlanUIWPAType );
		//console.debug("wlanUIWPAEncType:" + wlanUIWPAEncType );
		//console.debug("wlanUIPSKKeyType:" + wlanUIPSKKeyType );
		//console.debug("wlanKey:" + newkey.value );

		if( uiSecurityType == $("#wlanUISecurityType_org").val() &&
			wlanUIWPAType == $("#wlanUIWPAType_org").val() &&
			wlanUIWPAEncType == $("#wlanUIWPAEncType_org").val() &&
			wlanUIPSKKeyType == $("#wlanUIPSKKeyType_org").val() &&
			newkey.value == $("#wlanKey_org").val() ){

			ret = false;
		}else{
			ret = true;
		}
	}else{
		ret = false;
	}
	return ret;
}

function kt_keypolicy_isNeedCompare_keyInfo_5g(newkey){
	var ret = false;
	var uiSecurityType = $("input[name='wlanUISecurityType_5g']:checked").val();
	var uiSecurityType = kt_keypolicy_getValue("wlanUISecurityType_5g");

	if( uiSecurityType == '0' ){	
		//None
		ret = false;
	}else if( uiSecurityType == '1' ){
		//WEP
		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType_5g']:checked").val();
		var wlanUIWEPEncType = kt_keypolicy_getValue("wlanUIWEPEncType_5g");
		var wlanWEPKeyType = kt_keypolicy_getValue("wlanWEPKeyType_5g");

		//console.debug("wlanUISecurityType:" + uiSecurityType );
		//console.debug("wlanUIWEPEncType:" + wlanUIWEPEncType );
		//console.debug("wlanWEPKeyType:" + wlanWEPKeyType );
		//console.debug("wlanKey:" + newkey.value );

		if( uiSecurityType == $("#wlanUISecurityType_5g_org").val() &&
			wlanUIWEPEncType == $("#wlanUIWEPEncType_5g_org").val() &&
			wlanWEPKeyType == $("#wlanWEPKeyType_5g_org").val() &&
			newkey.value == $("#wlanKey_5g_org").val() ){

			ret = false;
		}else{
			ret = true;
		}
	}else if( uiSecurityType == '2' ){	
		//WPA
		var wlanUIWPAType = $("input[name='wlanUIWPAType_5g']:checked").val();
		var wlanUIWPAEncType = $("input[name='wlanUIWPAEncType_5g']:checked").val();
		var wlanUIPSKKeyType = $("input[name='wlanUIPSKKeyType_5g']:checked").val();
		var wlanUIWPAType = kt_keypolicy_getValue("wlanUIWPAType_5g");
		var wlanUIWPAEncType = kt_keypolicy_getValue("wlanUIWPAEncType_5g");
		var wlanUIPSKKeyType = kt_keypolicy_getValue("wlanUIPSKKeyType_5g");

		//console.debug("wlanUISecurityType:" + uiSecurityType );
		//console.debug("wlanUIWPAType:" + wlanUIWPAType );
		//console.debug("wlanUIWPAEncType:" + wlanUIWPAEncType );
		//console.debug("wlanUIPSKKeyType:" + wlanUIPSKKeyType );
		//console.debug("wlanKey:" + newkey.value );

		if( uiSecurityType == $("#wlanUISecurityType_5g_org").val() &&
			wlanUIWPAType == $("#wlanUIWPAType_5g_org").val() &&
			wlanUIWPAEncType == $("#wlanUIWPAEncType_5g_org").val() &&
			wlanUIPSKKeyType == $("#wlanUIPSKKeyType_5g_org").val() &&
			newkey.value == $("#wlanKey_5g_org").val() ){

			ret = false;
		}else{
			ret = true;
		}
	}else{
		ret = false;
	}
	return ret;
}

function kt_keypolicy_validate_psk_passphrase(pskKey){
	var regex1 = /[a-zA-Z]/;
	var regex2 = /[0-9]/;

	if( pskKey.value.length >= 10 
		&& regex1.test(pskKey.value) 
		&& regex2.test(pskKey.value) ){
		return true;
	}
	return false;
}

function kt_keypolicy_validate_wep_hex(wepKey){
	var regex1 = /[a-fA-F]/;
	var regex2 = /[0-9]/;

	if( wepKey.value.length == 10 
		&& isHex( wepKey.value ) 
		&& regex1.test(wepKey.value) 
		&& regex2.test(wepKey.value) ){
		return true;
	}
	return false;
}

/*
 *	pskKey - psk key 저장 textbox
 *	keyType - optional ('0' - passphrase, '1' - hex )
 */
function validate_psk(pskKey, pskKeyTypeValue){
	var ret = false;

	if( kt_keypolicy_isNeedCompare_keyInfo(pskKey) == false ){
		return true;
	}

	if( isEmpty( pskKey.value ) == false ){
		//check key type
		if( pskKeyTypeValue != null ){
			switch( pskKeyTypeValue ){
			case '0': //ASCII
				if( pskKey.value.length >=8 && pskKey.value.length < 64 ){
					//ret = true;
					if( kt_keypolicy_validate_psk_passphrase(pskKey) ){
						ret = true;
					}else{
						alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
					}
				}
				else{
					//alert("PSK KEY(String)는 8~63 char 형태로 입력되어야 합니다");
					alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
				}
			break;
			case '1': //HEX
				if( pskKey.value.length == 64 && isHex( pskKey.value ) == true ){
					ret = true;	
				}else{
					alert("암호는 64 char HEX 형태로 입력되어야 합니다");
				}
			break;
			}
			if( ret == false ){
				pskKey.focus();
			}
			return ret;
		}

		if( pskKey.value.length == 64 ){ 	//HEX Type
			if( isHex( pskKey.value ) == true ){
				ret = true;
			}else{
				alert("HEX(64) char 형태로 입력되어야 합니다");
			}
		}else if( pskKey.value.length >=8 && pskKey.value.length < 64 ){ //ASCII Type
			ret = true;
		}else{
			//alert("PSK KEY(String)는 8~63 char 형태로 입력되어야 합니다");
			alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
		}
	}else{
		alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
	}
	if( ret == false ){
		pskKey.focus();
	}
	return ret;
}

/*
 *	wepKey			- wepKey text field
 *	wepKeyTypeValue	- '0' - ASCII, '1' - HEX
 *	wepKeyLen 		- optional ('0' - 64bit, '1' - 128bit)
 */
function validate_wepkey(wepKey, wepKeyTypeValue, wepKeyLen){
	var ret = 0;
	
	if( kt_keypolicy_isNeedCompare_keyInfo(wepKey) == false ){
		return true;
	}

	if( isEmpty( wepKey.value ) == false ){
		switch(wepKeyTypeValue){
		case '0':	//ASCII
			if( wepKey.value.length == 5 || wepKey.value.length == 13 )	ret = 1;
		break;
		case '1':	//HEX	
			if( wepKey.value.length == 10 || wepKey.value.length == 26 ){
				//ret = ( isHex( wepKey.value ) ) ? 1 : -1;
				ret = ( kt_keypolicy_validate_wep_hex(wepKey) ) ? 1 : -1;
			}
		break;
		}
		// key len check
		if( ret == 1 ){
			if( wepKeyLen != null ){
				if( wepKeyLen == '0' ){	//64bit
					if( wepKey.value.length == 5 || wepKey.value.length == 10 ) ret = 1;
					else ret = 0;
				}else{					//128bit
					if( wepKey.value.length == 13 || wepKey.value.length == 26 ) ret = 1;
					else ret = 0;
				}
			}
		}
	}
	if( ret == 1 ){
		return true;
	}else{
		if( ret == 0 ){
			if( wepKeyTypeValue == '0' ){
				//$("#wlanKey_alert").text("암호는 5자 또는 13자입니다.");
				alert("암호는 5자입니다.");
			}else{
				//$("#wlanKey_alert").text("암호는 10자 또는 26자입니다.");
				alert("암호는 영문 대.소문자(A~F, a~f)와 숫자 조합으로 10자이어야 합니다.");
			}
			//alert("WEP KEY Length가 부적절합니다\nASCII-5, 13 char\nHEX-10, 26 char");
		}else{
			//alert("입력된 Key가 HEX 형태가 아닙니다\n");
			alert("암호는 영문 대.소문자(A~F, a~f)와 숫자 조합으로 10자이어야 합니다.");
		}
		wepKey.focus();
		return false;
	}
}

function validate_psk_5g(pskKey, pskKeyTypeValue){
	var ret = false;

	if( kt_keypolicy_isNeedCompare_keyInfo_5g(pskKey) == false ){
		return true;
	}

	if( isEmpty( pskKey.value ) == false ){
		//check key type
		if( pskKeyTypeValue != null ){
			switch( pskKeyTypeValue ){
			case '0': //ASCII
				if( pskKey.value.length >=8 && pskKey.value.length < 64 ){
					//ret = true;
					if( kt_keypolicy_validate_psk_passphrase(pskKey) ){
						ret = true;
					}else{
						alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
					}
				}
				else{
					//alert("PSK KEY(String)는 8~63 char 형태로 입력되어야 합니다");
					alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
				}
			break;
			case '1': //HEX
				if( pskKey.value.length == 64 && isHex( pskKey.value ) == true ){
					ret = true;	
				}else{
					alert("암호는 64 char HkX 형태로 입력되어야 합니다");
				}
			break;
			}
			if( ret == false ){
				pskKey.focus();
			}
			return ret;
		}

		if( pskKey.value.length == 64 ){ 	//HEX Type
			if( isHex( pskKey.value ) == true ){
				ret = true;
			}else{
				alert("HEX(64) char 형태로 입력되어야 합니다");
			}
		}else if( pskKey.value.length >=8 && pskKey.value.length < 64 ){ //ASCII Type
			ret = true;
		}else{
			//alert("PSK KEY(String)는 8~63 char 형태로 입력되어야 합니다");
			alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
		}
	}else{
		alert("암호는 영문 대/소문자와 숫자 조합으로 10자 이상이어야 합니다.");
	}
	if( ret == false ){
		pskKey.focus();
	}
	return ret;
}

function validate_wepkey_5g(wepKey, wepKeyTypeValue, wepKeyLen){
	var ret = 0;
	
	if( kt_keypolicy_isNeedCompare_keyInfo_5g(wepKey) == false ){
		return true;
	}

	if( isEmpty( wepKey.value ) == false ){
		switch(wepKeyTypeValue){
		case '0':	//ASCII
			if( wepKey.value.length == 5 || wepKey.value.length == 13 )	ret = 1;
		break;
		case '1':	//HEX	
			if( wepKey.value.length == 10 || wepKey.value.length == 26 ){
				//ret = ( isHex( wepKey.value ) ) ? 1 : -1;
				ret = ( kt_keypolicy_validate_wep_hex(wepKey) ) ? 1 : -1;
			}
		break;
		}
		// key len check
		if( ret == 1 ){
			if( wepKeyLen != null ){
				if( wepKeyLen == '0' ){	//64bit
					if( wepKey.value.length == 5 || wepKey.value.length == 10 ) ret = 1;
					else ret = 0;
				}else{					//128bit
					if( wepKey.value.length == 13 || wepKey.value.length == 26 ) ret = 1;
					else ret = 0;
				}
			}
		}
	}
	if( ret == 1 ){
		return true;
	}else{
		if( ret == 0 ){
			if( wepKeyTypeValue == '0' ){
				//$("#wlanKey_alert").text("암호는 5자 또는 13자입니다.");
				alert("암호는 5자입니다.");
			}else{
				//$("#wlanKey_alert").text("암호는 10자 또는 26자입니다.");
				alert("암호는 영문 대.소문자(A~F, a~f)와 숫자 조합으로 10자이어야 합니다.");
			}
			//alert("WEP KEY Length가 부적절합니다\nASCII-5, 13 char\nHEX-10, 26 char");
		}else{
			//alert("입력된 Key가 HEX 형태가 아닙니다\n");
			alert("암호는 영문 대.소문자(A~F, a~f)와 숫자 조합으로 10자이어야 합니다.");
		}
		wepKey.focus();
		return false;
	}
}

function validate_WLAN_Security_pskkey(){
	return validate_psk(document.getElementById("wlanUIPSKKey"), 
		getRadioSelectedValueByName("wlanUIPSKKeyType") );
}

function validate_WLAN_Security_pskkey_5g(){
	return validate_psk_5g(document.getElementById("wlanUIPSKKey_5g"), 
		getRadioSelectedValueByName("wlanUIPSKKeyType_5g") );
}

function validate_WLAN_Security_wpa(){
	var ret = false;
	var strMsg = "WPA Key Renewal정보가 부적절합니다(30~3600초)";
	
	var wpakey_renewal = document.getElementById("wlanUIWPAKeyRenewal");
	if( ( isEmpty(wpakey_renewal) == false && wpakey_renewal.value == '0') ||
		validateRange( wpakey_renewal, 10, 30, 3600, true) == 1 ){
		ret = true;
	}else{
		ret = false;
	}
	
	if( ret == false ){
		alert(strMsg);
		wpakey_renewal.focus();
		return false;
	}
	return true;	
}

function validate_WLAN_Security_wpa_5g(){
	var ret = false;
	var strMsg = "WPA Key Renewal정보가 부적절합니다(30~3600초)";
	
	var wpakey_renewal = document.getElementById("wlanUIWPAKeyRenewal_5g");
	if( ( isEmpty(wpakey_renewal) == false && wpakey_renewal.value == '0') ||
		validateRange( wpakey_renewal, 10, 30, 3600, true) == 1 ){
		ret = true;
	}else{
		ret = false;
	}
	
	if( ret == false ){
		alert(strMsg);
		wpakey_renewal.focus();
		return false;
	}
	return true;	
}

function validate_WLAN_Security_wepkey(){
	var nSuccess = 0;
	var wepKeyTypeValue = getRadioSelectedValueByName("wlanWEPKeyType");
	var wepKeyLen = getRadioSelectedValueByName("wlanUIWEPKeyLen");
	var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex");
	
	for( var i = 0; i < 4; i++ ){
		var keyName = "wlanUIWEPKey"+i;
		var e = document.getElementById(keyName);

		//default index check
		if( wlanWEPKeyIndex == i && e.value.length == 0 ){
			alert("Default Key No.에 대한 Key가 설정되지 않았습니다");
			return false;
		}
		//2011.05.19 Index와 관련없는 Key 항목은 검증에서 제외
		if( wlanWEPKeyIndex == i && e.value.length > 0 ){
			if( validate_wepkey(e, wepKeyTypeValue, wepKeyLen) == true ){
				nSuccess++;
			}else{
				return false;
			}
		}
	}
	
	if( nSuccess == 0 ){
		alert("Key가 설정되지 않았습니다");
		return false;
	}else{
		return true;
	}
}

function validate_WLAN_Security_wepkey_5g(){
	var nSuccess = 0;
	var wepKeyTypeValue = getRadioSelectedValueByName("wlanWEPKeyType_5g");
	var wepKeyLen = getRadioSelectedValueByName("wlanUIWEPKeyLen_5g");
	var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex_5g");
	
	for( var i = 0; i < 4; i++ ){
		var keyName = "wlanUIWEPKey"+i+"_5g";
		var e = document.getElementById(keyName);

		//default index check
		if( wlanWEPKeyIndex == i && e.value.length == 0 ){
			alert("Default Key No.에 대한 Key가 설정되지 않았습니다");
			return false;
		}
		//2011.05.19 Index와 관련없는 Key 항목은 검증에서 제외
		if( wlanWEPKeyIndex == i && e.value.length > 0 ){
			if( validate_wepkey(e, wepKeyTypeValue, wepKeyLen) == true ){
				nSuccess++;
			}else{
				return false;
			}
		}
	}
	
	if( nSuccess == 0 ){
		alert("Key가 설정되지 않았습니다");
		return false;
	}else{
		return true;
	}
}


function web2cfg_WLAN_Security(){
	var wlanUISecurityType = getRadioSelectedValueByName("wlanUISecurityType");
	var wlanSecurityMode = '0';
	var bWPAEnable = 0;
	
	if( wlanUISecurityType == '0' ){	//None
		wlanSecurityMode = '0';
	}else if( wlanUISecurityType == '1' ){	//WEP
		var wlanUIWEPEncType = getRadioSelectedValueByName("wlanUIWEPEncType");
		if( wlanUIWEPEncType == '0' ){			//Open
			wlanSecurityMode = '1';
		}else if( wlanUIWEPEncType == '1' ){	//Shared
			wlanSecurityMode = '2';
		}else if( wlanUIWEPEncType == '2' ){	//Auto
			wlanSecurityMode = '3';
		}
		
		if( validate_WLAN_Security_wepkey() == false ) return false; 
		else{
			var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex");
			var keyName = "wlanUIWEPKey"+wlanWEPKeyIndex;
			
			initTextById( "wlanWEPKey", document.getElementById(keyName).value );
		}
		
		initTextById( "wlanEncType", '1' );		//WEP Only
	}else if( wlanUISecurityType == '2' ){	//WPA-PSK
		var wlanUIWPAType = getRadioSelectedValueByName("wlanUIWPAType");
		if( wlanUIWPAType == '0' ){			//WPA
			wlanSecurityMode = '4';
		}else if( wlanUIWPAType == '1' ){	//WPA2
			wlanSecurityMode = '5';
		}else if( wlanUIWPAType == '2' ){	//WPA/WPA2
			wlanSecurityMode = '6';
		}else if( wlanUIWPAType == '3' ){	//WPA3
			wlanSecurityMode = '13';
		}else if( wlanUIWPAType == '4' ){	//WPA2/WPA3
			wlanSecurityMode = '14';
		}else if( wlanUIWPAType == '5' ){	//WPA/WPA2/WPA3
			wlanSecurityMode = '15';
		}

		if( validate_WLAN_Security_pskkey() == false ) return false;
		else{
			initTextById( "wlanPSKKey", document.getElementById("wlanUIPSKKey").value );
		}
		initTextById( "wlanEncType", getRadioSelectedValueByName("wlanUIWPAEncType") );
		
		bWPAEnable = 1;
	}else if( wlanUISecurityType == '3' ){	//WPA-Enterprise
		var wlanUIWPAType = getRadioSelectedValueByName("wlanUIWPAType");
		if( wlanUIWPAType == '0' ){			//WPA
			wlanSecurityMode = '7';
		}else if( wlanUIWPAType == '1' ){	//WPA2
			wlanSecurityMode = '8';
		}else if( wlanUIWPAType == '2' ){	//WPA/WPA2
			wlanSecurityMode = '9';
		}

		initTextById( "wlanEncType", getRadioSelectedValueByName("wlanUIWPAEncType") );
		
		bWPAEnable = 1;
	}else if( wlanUISecurityType == '4' ){	//802.1X
		wlanSecurityMode = '10';
	}
	
	initTextById( "wlanSecurityMode", wlanSecurityMode );
	
	if( bWPAEnable ){
		if( validate_WLAN_Security_wpa() == false ) return false;

		var wlanUIWPAKeyRenewal = document.getElementById("wlanUIWPAKeyRenewal").value;
		var wlanUIWPAKeyRenewalEnable = document.getElementById("wlanUIWPAKeyRenewalEnable").checked;
		if( wlanUIWPAKeyRenewalEnable == false ){
			wlanUIWPAKeyRenewal = '0';
		}
		initTextById( "wlanWPAKeyRenewInterval", wlanUIWPAKeyRenewal );
	}
	
	///////////////////////////
	// broadcastSSID
	var wlanUIHiddenSSIDEnable = document.getElementById("wlanUIHiddenSSIDEnable").checked;
	initTextById( "wlanBroadSSID", (wlanUIHiddenSSIDEnable==true) ? '0' : '1' );

/*
	2014.07.24 Roaming 기능으로 인해 SoIP 기능제거
	///////////////////////////
	// for SoIP
	var ssidIdx = $("#wlanSSIDIdx").val();
	if( ssidIdx == '1' || ssidIdx == '101' ){
		//restore
		$("#wlanSSID").val( $("#wlanSSID_pass").val() );
	}
*/	
	
	///////////////////////////
	// SSID Validate
	var ssidName = $("#wlanSSID").val();
	if( ssidName.length == 0 ){
		return false;
	}
	
	return true;
}


function web2cfg_WLAN_Security_5g(){
	var wlanUISecurityType = getRadioSelectedValueByName("wlanUISecurityType_5g");
	var wlanSecurityMode = '0';
	var bWPAEnable = 0;
	
	if( wlanUISecurityType == '0' ){	//None
		wlanSecurityMode = '0';
	}else if( wlanUISecurityType == '1' ){	//WEP
		var wlanUIWEPEncType = getRadioSelectedValueByName("wlanUIWEPEncType_5g");
		if( wlanUIWEPEncType == '0' ){			//Open
			wlanSecurityMode = '1';
		}else if( wlanUIWEPEncType == '1' ){	//Shared
			wlanSecurityMode = '2';
		}else if( wlanUIWEPEncType == '2' ){	//Auto
			wlanSecurityMode = '3';
		}
		
		if( validate_WLAN_Security_wepkey_5g() == false ) return false; 
		else{
			var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex_5g");
			var keyName = "wlanUIWEPKey"+wlanWEPKeyIndex+"_5g";
			
			initTextById( "wlanWEPKey_5g", document.getElementById(keyName).value );
		}
		
		initTextById( "wlanEncType_5g", '1' );		//WEP Only
	}else if( wlanUISecurityType == '2' ){	//WPA-PSK
		var wlanUIWPAType = getRadioSelectedValueByName("wlanUIWPAType_5g");
		if( wlanUIWPAType == '0' ){			//WPA
			wlanSecurityMode = '4';
		}else if( wlanUIWPAType == '1' ){	//WPA2
			wlanSecurityMode = '5';
		}else if( wlanUIWPAType == '2' ){	//WPA/WPA2
			wlanSecurityMode = '6';
		}else if( wlanUIWPAType == '3' ){	//WPA3
			wlanSecurityMode = '13';
		}else if( wlanUIWPAType == '4' ){	//WPA2/WPA3
			wlanSecurityMode = '14';
		}else if( wlanUIWPAType == '5' ){	//WPA/WPA2/WPA3
			wlanSecurityMode = '15';
		}

		if( validate_WLAN_Security_pskkey_5g() == false ) return false;
		else{
			initTextById( "wlanPSKKey_5g", document.getElementById("wlanUIPSKKey_5g").value );
		}
		initTextById( "wlanEncType_5g", getRadioSelectedValueByName("wlanUIWPAEncType_5g") );
		
		bWPAEnable = 1;
	}else if( wlanUISecurityType == '3' ){	//WPA-Enterprise
		var wlanUIWPAType = getRadioSelectedValueByName("wlanUIWPAType_5g");
		if( wlanUIWPAType == '0' ){			//WPA
			wlanSecurityMode = '7';
		}else if( wlanUIWPAType == '1' ){	//WPA2
			wlanSecurityMode = '8';
		}else if( wlanUIWPAType == '2' ){	//WPA/WPA2
			wlanSecurityMode = '9';
		}

		initTextById( "wlanEncType_5g", getRadioSelectedValueByName("wlanUIWPAEncType_5g") );
		
		bWPAEnable = 1;
	}else if( wlanUISecurityType == '4' ){	//802.1X
		wlanSecurityMode = '10';
	}
	
	initTextById( "wlanSecurityMode_5g", wlanSecurityMode );
	
	if( bWPAEnable ){
		if( validate_WLAN_Security_wpa_5g() == false ) return false;

		var wlanUIWPAKeyRenewal = document.getElementById("wlanUIWPAKeyRenewal_5g").value;
		var wlanUIWPAKeyRenewalEnable = document.getElementById("wlanUIWPAKeyRenewalEnable_5g").checked;
		if( wlanUIWPAKeyRenewalEnable == false ){
			wlanUIWPAKeyRenewal = '0';
		}
		initTextById( "wlanWPAKeyRenewInterval_5g", wlanUIWPAKeyRenewal );
	}
	
	///////////////////////////
	// broadcastSSID
	var wlanUIHiddenSSIDEnable = document.getElementById("wlanUIHiddenSSIDEnable_5g").checked;
	initTextById( "wlanBroadSSID_5g", (wlanUIHiddenSSIDEnable==true) ? '0' : '1' );

	
	///////////////////////////
	// SSID Validate
	var ssidName = $("#wlanSSID_5g").val();
	if( ssidName.length == 0 ){
		return false;
	}
	
	return true;
}


function validateOnSubmit_WLAN_SecurityType(url){
	var ret = false;
	ret = validateSecurityInputTextForm();
	if( ret == false ){
		return ret;
	}
	ret = web2cfg_WLAN_Security();
	return ret;
} 

function validateOnSubmit_WLAN_SecurityType_5g(url){
	var ret = false;
	ret = validateSecurityInputTextForm_5g();
	if( ret == false ){
		return ret;
	}
	ret = web2cfg_WLAN_Security_5g();
	return ret;
} 

function onClick_WLAN_Enable() {
	var sel = getRadioSelectedValueByName("wlanRadioActivity");
	if ( sel == '1' ) {
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").show();
		$("#wlanViewPSK1").show();
		$("#wlanViewPSK2").show();
		$("#wlanView8021x").hide();
		$("#wireless_wlanUIPSKKey").show();
		initRadioByName("wlanUISecurityType", '2');
		//initRadioByName("wlanUIWPAType", '1');
		initRadioByName("wlanUIWPAType", '2'); // WPA1/2
		//initRadioByName("wlanUIWPAEncType", '1');
		initRadioByName("wlanUIWPAEncType", '2'); // TKIP/AES
		initRadioByName("wlanUIPSKKeyType", '0');
		objectDisableById("wlanUIWPAEncTypeTKIP", false);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", false);
	} else {}

	return 0;
}

//////////////////////////////
// EVENT
function onClick_WLAN_WPAType(){
	var sel = getRadioSelectedValueByName("wlanUIWPAType");
	if( sel == '0' ){		//WPA
		objectDisableById("wlanUIWPAEncTypeTKIP", false);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType", '2');
	}else if( sel == '1' ){	//WPA2
		objectDisableById("wlanUIWPAEncTypeTKIP", false);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType", '2');
	}else if( sel == '2' ){	//WPA1 / WPA2
		objectDisableById("wlanUIWPAEncTypeTKIP", false);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType", '2');
	}else if( sel == '3' ){	//WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP", true);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType", '1');
	}else if( sel == '4' ){	//WPA2 / WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP", true);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType", '1');
	}else if( sel == '5' ){	//WPA / WPA2 / WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP", true);
		objectDisableById("wlanUIWPAEncTypeAES", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType", '1');
	}
	return 0;
}

function onClick_WLAN_SecurityPasswordEnable(val){
	if(val == '0'){
		var Enable = $("input[name='check_box']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='wlanUIPSKKey']").prop("type", "text");
		}else{
			$("input[name='wlanUIPSKKey']").prop("type", "password");
		}
	}else if(val == '1'){
		var Enable = $("input[name='check_box_1']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='wlanUIWEPKey0']").prop("type", "text");
		}else{
			$("input[name='wlanUIWEPKey0']").prop("type", "password");
		}
	}else if(val == '2'){
		var Enable = $("input[name='check_box']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='wlanMeshPSKKey']").prop("type", "text");
		}else{
			$("input[name='wlanMeshPSKKey']").prop("type", "password");
		}
	}else if(val == '3'){
		var Enable = $("input[name='check_box_2']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='wlanUIPSKKey_5g']").prop("type", "text");
		}else{
			$("input[name='wlanUIPSKKey_5g']").prop("type", "password");
		}
	}else if(val == '4'){
		var Enable = $("input[name='check_box_3']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='wlanUIWEPKey0_5g']").prop("type", "text");
		}else{
			$("input[name='wlanUIWEPKey0_5g']").prop("type", "password");
		}
	}else{
		var Enable = $("input[name='check_box']:checked").val();
		if(Enable || Enable == "on"){
			$("input[name='encKey']").prop("type", "text");
		}else{
			$("input[name='encKey']").prop("type", "password");
		}
	}

}
function onClick_WLAN_SecurityWPAKeyRenewalEnable(){
	var wlanUIWPAKeyRenewalEnable = document.getElementById("wlanUIWPAKeyRenewalEnable").checked;
	objectDisableById("wlanUIWPAKeyRenewal", !wlanUIWPAKeyRenewalEnable);
}

function onClick_WLAN_SecurityType(){
	var org = conv2UI_WLAN_SecurityType(document.getElementById("wlanSecurityMode").value);
	var sel = getRadioSelectedValueByName("wlanUISecurityType");
	var wlanPSKKey_backup = $("#wlanWEPPSKKey_backup").val();

	if( sel == '0' ){		//None
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanView8021x").hide();
		$("#wireless_wlanUIPSKKey").hide();
	}else if( sel == '1' ){	//WEP
		$("#wlanViewWEP").show();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanView8021x").hide();
		$("#wireless_wlanUIPSKKey").hide();
	}else if( sel == '2' ){	//PSK
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").show();
		$("#wlanViewPSK1").show();
		$("#wlanViewPSK2").show();
		$("#wlanView8021x").hide();
		$("#wireless_wlanUIPSKKey").show();
	}else if( sel == '3' ){	//WPA-Enterprise
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").show();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanView8021x").hide();
		$("#wireless_wlanUIPSKKey").hide();
	}else if( sel == '4' ){	//802.1x
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wlanView8021x").show();
		$("#wireless_wlanUIPSKKey").hide();
	}
	
	//인증방식이 변경된 경우 재설정
	//set default radio
	if( sel != org && sel != '0' ){
		if( sel == '1' ){	//WEP
			/*
			initRadioByName("wlanUIWEPEncType", '0');
			initRadioByName("wlanUIWEPKeyLen", '0' );
			initRadioByName("wlanWEPKeyType", '0' );
			initRadioByName("wlanWEPKeyIndex", '0' );
			
			initTextById("wlanUIWEPKey0", "");
			initTextById("wlanUIWEPKey1", "");
			initTextById("wlanUIWEPKey2", "");
			initTextById("wlanUIWEPKey3", "");
			*/
			$("input[name='wlanUIWEPEncType']").val(['2']);
			$("input[name='wlanUIWEPKeyLen']").val(['0']);
			$("input[name='wlanWEPKeyType']").val(['1']);
			$("input[name='wlanWEPKeyIndex']").val(['0']);
			
			$("#wlanUIWEPKey0").val("");
			$("#wlanUIWEPKey1").val("");
			$("#wlanUIWEPKey2").val("");
			$("#wlanUIWEPKey3").val("");
		}else if( sel == '2' ){	//PSK
			/*
			initRadioByName("wlanUIWPAType", '0');
			initRadioByName("wlanUIWPAEncType", '0');
			initRadioByName("wlanUIPSKKeyType", '0');

			initTextById("wlanUIPSKKey", "");
			*/
			$("input[name='wlanUIWPAType']").val(['2']);	//set default to WPA1/2
			$("input[name='wlanUIWPAEncType']").val(['2']);
			$("input[name='wlanUIPSKKeyType']").val(['0']);
			
			$("#wlanUIPSKKey").val(wlanPSKKey_backup);

			onClick_WLAN_WPAType();	//refresh TKIP/AES
		}else if( sel == '3' ){	//Enterprise
			$("input[name='wlanUIWPAType']").val(['2']);
			$("input[name='wlanUIWPAEncType']").val(['2']);
			$("input[name='wlanUIPSKKeyType']").val(['0']);
			
			$("#wlanUIPSKKey").val("");
		}else if( sel == '4' ){	//802.1x
			$("input[name='wlanWEPRekeyEnable']").val(['0']);
			$("input[name='wlanMACAuthEnable']").val(['1']);
		}
	}
}

function conv2UI_WLAN_SecurityType(securityModeValue){
	var ret = 0;
	switch( securityModeValue ){
	case '0':	//SECURITY_MODE_DISABLE
		ret = 0;
	break;
	case '1':	//SECURITY_MODE_OPEN
		ret = 1;
	break;
	case '2':	//SECURITY_MODE_SHARED
		ret = 1;
	break;
	case '3':	//SECURITY_MODE_AUTO
		ret = 1;
	break;
	case '4':	//SECURITY_MODE_WPA_PSK
		ret = 2;
	break;
	case '5':	//SECURITY_MODE_WPA2_PSK
		ret = 2;
	break;
	case '6':	//SECURITY_MODE_WPA_WPA2_PSK
		ret = 2;
	break;
	case '7':	//SECURITY_MODE_WPA_ENT
		ret = 3;
	break;
	case '8':	//SECURITY_MODE_WPA2_ENT
		ret = 3;
	break;
	case '9':	//SECURITY_MODE_WPA_WPA2_ENT
		ret = 3;
	break;
	case '10'://SECURITY_MODE_8021X
		ret = 4;
	break;
	case '13':	//SECURITY_MODE_WPA3_PSK
		ret = 2;
	break;
	case '14':	//SECURITY_MODE_WPA2_WPA3_PSK
		ret = 2;
	break;
	case '15':	//SECURITY_MODE_WPA_WPA2_WPA3_PSK
		ret = 2;
	break;
	}
	
	return ret;
}

function cfg2web_WLAN_Security_WEPKey(){
	var wlanWEPKey = document.getElementById("wlanWEPKey").value;
	var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex");
	if( wlanWEPKey != null ){
		initTextById("wlanUIWEPKey"+wlanWEPKeyIndex, wlanWEPKey);
	}
}

function cfg2web_WLAN_Security(){
	var bWebKeyEnable = 0; 
	var bWPAEnable = 0;
	var bPSKEnable = 0;
	var b8021xEnable = 0;
	var bWebRedirectEnable = 0;
	var bWepRekeyEnable = 0;
//	var securityModeValue = document.getElementById("wlanSecurityMode").value;
	var securityModeValue = $("#wlanSecurityMode").val();
	var uiSecurityMode = ''+conv2UI_WLAN_SecurityType(securityModeValue);
	
	//MESH 
	var meshEnableValue = $("#meshEnable").val();
	var meshIndexValue = $("#meshIndex").val();
	var index = $("#wlanSSIDIdx").val();
	//broadcast	
	initCheckboxById("wlanUIHiddenSSIDEnable", 
		( document.getElementById("wlanBroadSSID").value == '1' )? '0' : '1' );

	//security
	initRadioByName("wlanUISecurityType", uiSecurityMode);

	if(meshEnableValue == 1 && (meshIndexValue == (index%100))){
		bWPAEnable = 1;
		bPSKEnable = 1;

	}else{
		switch( securityModeValue ){
			case '0':	//SECURITY_MODE_DISABLE
				break;
			case '1':	//SECURITY_MODE_OPEN
				initRadioByName("wlanUIWEPEncType", '0');
				break;
			case '2':	//SECURITY_MODE_SHARED
				initRadioByName("wlanUIWEPEncType", '1');
				break;
			case '3':	//SECURITY_MODE_AUTO
				initRadioByName("wlanUIWEPEncType", '2');
				break;
			case '4':	//SECURITY_MODE_WPA_PSK
				initRadioByName("wlanUIWPAType", '0');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '5':	//SECURITY_MODE_WPA2_PSK
				initRadioByName("wlanUIWPAType", '1');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '6':	//SECURITY_MODE_WPA_WPA2_PSK
				initRadioByName("wlanUIWPAType", '2');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '7':	//SECURITY_MODE_WPA_ENT
				initRadioByName("wlanUIWPAType", '0');
				bWPAEnable = 1;
				break;
			case '8':	//SECURITY_MODE_WPA2_ENT
				initRadioByName("wlanUIWPAType", '1');
				bWPAEnable = 1;
				break;
			case '9':	//SECURITY_MODE_WPA_WPA2_ENT
				initRadioByName("wlanUIWPAType", '2');
				bWPAEnable = 1;
				break;
			case '10'://SECURITY_MODE_8021X
				b8021xEnable = 1;
				bWebRedirectEnable = 1;
				bWepRekeyEnable = 1; 
				break;
			case '13':	//SECURITY_MODE_WPA3_PSK
				initRadioByName("wlanUIWPAType", '3');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
			case '14':	//SECURITY_MODE_WPA2_WPA3_PSK
				initRadioByName("wlanUIWPAType", '4');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
			case '15':	//SECURITY_MODE_WPA_WPA2_WPA3_PSK
				initRadioByName("wlanUIWPAType", '5');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
		}
	}
	//////////////////////////
	// WEP
	//	var wlanWEPKey = document.getElementById("wlanWEPKey").value;
	var wlanWEPKey = $("#wlanWEPKey").val();
	if( wlanWEPKey != null ){
		if( wlanWEPKey.length == 13 || wlanWEPKey.length == 26 ){
			initRadioByName("wlanUIWEPKeyLen", '1' );
		}else{
			initRadioByName("wlanUIWEPKeyLen", '0' );
		}
		
		cfg2web_WLAN_Security_WEPKey();
	}
	
	//////////////////////////
	// WPA	
	if(	bWPAEnable == 1 ){
		initRadioByName("wlanUIWPAEncType", document.getElementById("wlanEncType").value);
		if( bPSKEnable == 1 ){
//			var pskKey = document.getElementById("wlanPSKKey").value;
			var pskKey = $("#wlanPSKKey").val();
			if( pskKey != null ){
				initRadioByName("wlanUIPSKKeyType", (pskKey.length == 64 ) ? '1' : '0' );
				initTextById("wlanUIPSKKey", pskKey);
			}
		}
	}
	//key renewal은 WPA여부와 관계없이 초기화
	var wlanWPAKeyRenewInterval = parseInt( document.getElementById("wlanWPAKeyRenewInterval").value, 10 );
	if( wlanWPAKeyRenewInterval == 0 ){
		//disable
		initCheckboxById("wlanUIWPAKeyRenewalEnable", '0' );
		initTextById("wlanUIWPAKeyRenewal", '0');	//default 표시
	}else{
		//enable
		initCheckboxById("wlanUIWPAKeyRenewalEnable", '1' );
		initTextById("wlanUIWPAKeyRenewal", ''+wlanWPAKeyRenewInterval);
	}
	
	onClick_WLAN_SecurityType();
	onClick_WLAN_SecurityWPAKeyRenewalEnable();
	onClick_WLAN_WPAType();
		
	/////////////////////////
	//SSID 0번째것은 비활성화 금지(user/admin 공통)
	var ssidIdx = $("#wlanSSIDIdx").val();
	if( ssidIdx == '0' || ssidIdx == '100' ||
		ssidIdx == '1' || ssidIdx == '101' ||
		ssidIdx == '4' || ssidIdx == '104'	){
		//2014.04.01 비활성화 가능하도록 변경
		//$("input[name='wlanRadioActivity']").attr("disabled", "disabled");
		
		$("#viewUISecurityType_8021x").hide();
		$("#viewUISecurityType_wpa_ent").hide();
	}
/*	
	if( document.getElementById("wlanSSIDIdx").value == '0' ){
		var e = document.getElementsByName("wlanRadioActivity");
		if( e != null ){
			for( var i = 0; i < e.length; i++ ){
				e[i].disabled = true;
			}
		}
	}
*/	

/*
	2014.07.24 Roaming 기능으로 인해 SoIP 기능제거
	/////////////////////////
	//SSID 1번째것은 SSID Passwd type으로 변경
	if( ssidIdx == '1' || ssidIdx == '101' ){
		//backup value to pass input
		$("#wlanSSID_pass").val( $("#wlanSSID").val() );

		$("#wlanSSID").hide();
		$("#wlanSSID_pass").show();
	}else{
		$("#wlanSSID").show();
		$("#wlanSSID_pass").hide();
	}
*/
	$("#wlanSSID").show();
	$("#wlanSSID_pass").hide();
	
	/////////////////////////
	//2010.12.06 SOHOZoneMode 추가
	//KT_WLAN, 일반등급 user, soho enable일때
	if( (ssidIdx == '0' || ssidIdx =='100') && is_kt_SOHOZoneEnabled() == true && getUserPrivilege() == 3 ){
		//보안설정중 None Disable
		$("input[name='wlanUISecurityType'][value='0']").attr("disabled", "disabled");
		$("input[name='wlanSSID']").attr("readonly", "readonly");
	}	

	kt_keypolicy_setCfg_orgInfo();
}

/* SHCHO -- 5g start */

function kt_keypolicy_setCfg_orgInfo_5g(){
	//backup UI
	$("#wlanUISecurityType_5g_org").val( kt_keypolicy_getValue("wlanUISecurityType_5g") );
	//WEP
	$("#wlanUIWEPEncType_5g_org").val( kt_keypolicy_getValue("wlanUIWEPEncType_5g") );
	$("#wlanWEPKeyType_5g_org").val( kt_keypolicy_getValue("wlanWEPKeyType_5g") );
	//PSK
	$("#wlanUIWPAType_5g_org").val( kt_keypolicy_getValue("wlanUIWPAType_5g") );
	$("#wlanUIWPAEncType_5g_org").val( kt_keypolicy_getValue("wlanUIWPAEncType_5g") );
	$("#wlanUIPSKKeyType_5g_org").val( kt_keypolicy_getValue("wlanUIPSKKeyType_5g") );

	//console.debug("kt_keypolicy_setCfg_orgInfo:"  );
	//console.debug("wlanUISecurityType_org:" + $("#wlanUISecurityType_org").val() );
	//console.debug("wlanUIWEPEncType_org:" + $("#wlanUIWEPEncType_org").val() );
	//console.debug("wlanWEPKeyType_org:" + $("#wlanWEPKeyType_org").val() );
	//console.debug("wlanUIWPAType_org:" + $("#wlanUIWPAType_org").val() );
	//console.debug("wlanUIWPAEncType_org:" + $("#wlanUIWPAEncType_org").val() );
	//console.debug("wlanUIPSKKeyType_org:" + $("#wlanUIPSKKeyType_org").val() );
	//console.debug("wlanKey_org:" + $("#wlanKey_org").val() );
}


function onClick_WLAN_WPAType_5g(){
	var sel = getRadioSelectedValueByName("wlanUIWPAType_5g");
	if( sel == '0' ){		//WPA
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", false);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType_5g", '2');
	}else if( sel == '1' ){	//WPA2
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", false);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType", '2');
	}else if( sel == '2' ){	//WPA1 / WPA2
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", false);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", false);
		//select default to TKIP & AES
		// initRadioByName("wlanUIWPAEncType", '2');
	}else if( sel == '3' ){	//WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", true);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType_5g", '1');
	}else if( sel == '4' ){	//WPA2 / WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", true);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType_5g", '1');
	}else if( sel == '5' ){	//WPA / WPA2 / WPA3
		objectDisableById("wlanUIWPAEncTypeTKIP_5g", true);
		objectDisableById("wlanUIWPAEncTypeAES_5g", false);
		objectDisableById("wlanUIWPAEncTypeTKIPAES_5g", true);
		//select default to AES
		//can't use other value
		initRadioByName("wlanUIWPAEncType_5g", '1');
	}
	return 0;
}

function onClick_WLAN_SecurityType_5g(){
	var org = conv2UI_WLAN_SecurityType(document.getElementById("wlanSecurityMode_5g").value);
	var sel = getRadioSelectedValueByName("wlanUISecurityType_5g");
	var wlanPSKKey_backup = $("#wlanWEPPSKKey_backup_5g").val();

	if( sel == '0' ){		//None
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wlanView8021x_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
	}else if( sel == '1' ){	//WEP
		$("#wlanViewWEP_5g").show();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wlanView8021x_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
	}else if( sel == '2' ){	//PSK
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").show();
		$("#wlanViewPSK1_5g").show();
		$("#wlanViewPSK2_5g").show();
		$("#wlanView8021x_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").show();
	}else if( sel == '3' ){	//WPA-Enterprise
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").show();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wlanView8021x_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
	}else if( sel == '4' ){	//802.1x
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wlanView8021x_5g").show();
		$("#wireless_wlanUIPSKKey_5g").hide();
	}
	
	//인증방식이 변경된 경우 재설정
	//set default radio
	if( sel != org && sel != '0' ){
		if( sel == '1' ){	//WEP
			$("input[name='wlanUIWEPEncType_5g']").val(['2']);
			$("input[name='wlanUIWEPKeyLen_5g']").val(['0']);
			$("input[name='wlanWEPKeyType_5g']").val(['1']);
			$("input[name='wlanWEPKeyIndex_5g']").val(['0']);
			
			$("#wlanUIWEPKey0_5g").val("");
			$("#wlanUIWEPKey1_5g").val("");
			$("#wlanUIWEPKey2_5g").val("");
			$("#wlanUIWEPKey3_5g").val("");
		}else if( sel == '2' ){	//PSK
			$("input[name='wlanUIWPAType_5g']").val(['2']);	//set default to WPA1/2
			$("input[name='wlanUIWPAEncType_5g']").val(['2']);
			$("input[name='wlanUIPSKKeyType_5g']").val(['0']);
			
			$("#wlanUIPSKKey_5g").val(wlanPSKKey_backup);

			onClick_WLAN_WPAType_5g();	//refresh TKIP/AES
		}else if( sel == '3' ){	//Enterprise
			$("input[name='wlanUIWPAType_5g']").val(['2']);
			$("input[name='wlanUIWPAEncType_5g']").val(['2']);
			$("input[name='wlanUIPSKKeyType_5g']").val(['0']);
			
			$("#wlanUIPSKKey_5g").val("");
		}else if( sel == '4' ){	//802.1x
			$("input[name='wlanWEPRekeyEnable_5g']").val(['0']);
			$("input[name='wlanMACAuthEnable_5g']").val(['1']);
		}
	}
}

function cfg2web_WLAN_Security_WEPKey_5g(){
	var wlanWEPKey = document.getElementById("wlanWEPKey_5g").value;
	var wlanWEPKeyIndex = getRadioSelectedValueByName("wlanWEPKeyIndex_5g");
	if( wlanWEPKey != null ){
		initTextById("wlanUIWEPKey_5g"+wlanWEPKeyIndex, wlanWEPKey);
	}
}

function onClick_WLAN_SecurityWPAKeyRenewalEnable_5g(){
	var wlanUIWPAKeyRenewalEnable = document.getElementById("wlanUIWPAKeyRenewalEnable_5g").checked;
	objectDisableById("wlanUIWPAKeyRenewal_5g", !wlanUIWPAKeyRenewalEnable);
}

function cfg2web_WLAN_Security_5g(){
	var bWebKeyEnable = 0; 
	var bWPAEnable = 0;
	var bPSKEnable = 0;
	var b8021xEnable = 0;
	var bWebRedirectEnable = 0;
	var bWepRekeyEnable = 0;
//	var securityModeValue = document.getElementById("wlanSecurityMode").value;
	var securityModeValue = $("#wlanSecurityMode_5g").val();
	var uiSecurityMode = ''+conv2UI_WLAN_SecurityType(securityModeValue);
	
	//MESH 
	var meshEnableValue = $("#meshEnable").val();
	var meshIndexValue = $("#meshIndex").val();
	var index = $("#wlanSSIDIdx_5g").val();
	//broadcast	
	initCheckboxById("wlanUIHiddenSSIDEnable_5g", 
		( document.getElementById("wlanBroadSSID_5g").value == '1' )? '0' : '1' );

	//security
	initRadioByName("wlanUISecurityType_5g", uiSecurityMode);

	if(meshEnableValue == 1 && (meshIndexValue == (index%100))){
		bWPAEnable = 1;
		bPSKEnable = 1;

	}else{
		switch( securityModeValue ){
			case '0':	//SECURITY_MODE_DISABLE
				break;
			case '1':	//SECURITY_MODE_OPEN
				initRadioByName("wlanUIWEPEncType_5g", '0');
				break;
			case '2':	//SECURITY_MODE_SHARED
				initRadioByName("wlanUIWEPEncType_5g", '1');
				break;
			case '3':	//SECURITY_MODE_AUTO
				initRadioByName("wlanUIWEPEncType_5g", '2');
				break;
			case '4':	//SECURITY_MODE_WPA_PSK
				initRadioByName("wlanUIWPAType_5g", '0');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '5':	//SECURITY_MODE_WPA2_PSK
				initRadioByName("wlanUIWPAType_5g", '1');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '6':	//SECURITY_MODE_WPA_WPA2_PSK
				initRadioByName("wlanUIWPAType_5g", '2');
				bWPAEnable = 1;
				bPSKEnable = 1;
				break;
			case '7':	//SECURITY_MODE_WPA_ENT
				initRadioByName("wlanUIWPAType_5g", '0');
				bWPAEnable = 1;
				break;
			case '8':	//SECURITY_MODE_WPA2_ENT
				initRadioByName("wlanUIWPAType_5g", '1');
				bWPAEnable = 1;
				break;
			case '9':	//SECURITY_MODE_WPA_WPA2_ENT
				initRadioByName("wlanUIWPAType_5g", '2');
				bWPAEnable = 1;
				break;
			case '10'://SECURITY_MODE_8021X
				b8021xEnable = 1;
				bWebRedirectEnable = 1;
				bWepRekeyEnable = 1; 
				break;
			case '13':	//SECURITY_MODE_WPA3_PSK
				initRadioByName("wlanUIWPAType_5g", '3');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
			case '14':	//SECURITY_MODE_WPA2_WPA3_PSK
				initRadioByName("wlanUIWPAType_5g", '4');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
			case '15':	//SECURITY_MODE_WPA_WPA2_WPA3_PSK
				initRadioByName("wlanUIWPAType_5g", '5');
				bWPAEnable = 1;
				bPSKEnable = 1;
			break;
		}
	}
	//////////////////////////
	// WEP
	//	var wlanWEPKey = document.getElementById("wlanWEPKey").value;
	var wlanWEPKey = $("#wlanWEPKey_5g").val();
	if( wlanWEPKey != null ){
		if( wlanWEPKey.length == 13 || wlanWEPKey.length == 26 ){
			initRadioByName("wlanUIWEPKeyLen_5g", '1' );
		}else{
			initRadioByName("wlanUIWEPKeyLen_5g", '0' );
		}
		
		cfg2web_WLAN_Security_WEPKey_5g();
	}
	
	//////////////////////////
	// WPA	
	if(	bWPAEnable == 1 ){
		initRadioByName("wlanUIWPAEncType_5g", document.getElementById("wlanEncType_5g").value);
		if( bPSKEnable == 1 ){
//			var pskKey = document.getElementById("wlanPSKKey").value;
			var pskKey = $("#wlanPSKKey_5g").val();
			if( pskKey != null ){
				initRadioByName("wlanUIPSKKeyType_5g", (pskKey.length == 64 ) ? '1' : '0' );
				initTextById("wlanUIPSKKey_5g", pskKey);
			}
		}
	}
	//key renewal은 WPA여부와 관계없이 초기화
	var wlanWPAKeyRenewInterval = parseInt( document.getElementById("wlanWPAKeyRenewInterval_5g").value, 10 );
	if( wlanWPAKeyRenewInterval == 0 ){
		//disable
		initCheckboxById("wlanUIWPAKeyRenewalEnable_5g", '0' );
		initTextById("wlanUIWPAKeyRenewal_5g", '0');	//default 표시
	}else{
		//enable
		initCheckboxById("wlanUIWPAKeyRenewalEnable_5g", '1' );
		initTextById("wlanUIWPAKeyRenewal_5g", ''+wlanWPAKeyRenewInterval);
	}
	
	onClick_WLAN_SecurityType_5g();
	onClick_WLAN_SecurityWPAKeyRenewalEnable_5g();
	onClick_WLAN_WPAType_5g();
		
	/////////////////////////
	//SSID 0번째것은 비활성화 금지(user/admin 공통)
	var ssidIdx = $("#wlanSSIDIdx_5g").val();
	if( ssidIdx == '0' || ssidIdx == '100' ||
		ssidIdx == '1' || ssidIdx == '101' ||
		ssidIdx == '4' || ssidIdx == '104'	){
		//2014.04.01 비활성화 가능하도록 변경
		//$("input[name='wlanRadioActivity']").attr("disabled", "disabled");
		
		$("#viewUISecurityType_8021x_5g").hide();
		$("#viewUISecurityType_wpa_ent_5g").hide();
	}
/*	
	if( document.getElementById("wlanSSIDIdx").value == '0' ){
		var e = document.getElementsByName("wlanRadioActivity");
		if( e != null ){
			for( var i = 0; i < e.length; i++ ){
				e[i].disabled = true;
			}
		}
	}
*/	

/*
	2014.07.24 Roaming 기능으로 인해 SoIP 기능제거
	/////////////////////////
	//SSID 1번째것은 SSID Passwd type으로 변경
	if( ssidIdx == '1' || ssidIdx == '101' ){
		//backup value to pass input
		$("#wlanSSID_pass").val( $("#wlanSSID").val() );

		$("#wlanSSID").hide();
		$("#wlanSSID_pass").show();
	}else{
		$("#wlanSSID").show();
		$("#wlanSSID_pass").hide();
	}
*/
	$("#wlanSSID_5g").show();
	$("#wlanSSID_pass_5g").hide();
	
	/////////////////////////
	//2010.12.06 SOHOZoneMode 추가
	//KT_WLAN, 일반등급 user, soho enable일때
	if( (ssidIdx == '0') && is_kt_SOHOZoneEnabled() == true && getUserPrivilege() == 3 ){
		//보안설정중 None Disable
		$("input[name='wlanUISecurityType_5g'][value='0']").attr("disabled", "disabled");
		$("input[name='wlanSSID_5g']").attr("readonly", "readonly");
	}	

	kt_keypolicy_setCfg_orgInfo_5g(); // SHCHO
}




///////////////////
// radius check
function validate_radiusServer(ipElementName, portElementName, secretElementName){
	var ret = 0;	//0 - empty, 1-success, -1-failed
	var raAddrIP = document.getElementById(ipElementName);
	var raAddrPort = document.getElementById(portElementName);
	var raAddrSecret = document.getElementById(secretElementName);
	
	if( isEmpty( raAddrIP.value ) == false && isEmpty( raAddrPort.value ) == false && raAddrIP.value != "0.0.0.0" ){
		if( isIpAddress( raAddrIP.value ) == false ){
			alert("IPAddress가 부적절합니다");
			raAddrIP.focus();
			return -1;
		}
		if( validateRange( raAddrPort, 10, 1000, 65535, true) != 1 ){
			alert("Port정보가 부적절합니다");
			return -1;
		}
		if( isEmpty( raAddrSecret.value) == true || raAddrSecret.length > 63 ){
			alert("Shared secret이 부적절합니다");
			raAddrSecret.focus();
			return -1;
		}
		return 1;
	}
	return ret;
}

function validate_radius_param(){
	var raInterimInterval = document.getElementById("wlanRaInterimInterval");
	var raAuthMaxRetry = document.getElementById("wlanRaAuthMaxRetry");
	var raAuthMaxInterval = document.getElementById("wlanRaAuthMaxInterval");
	var raAcctMaxRetry = document.getElementById("wlanRaAcctMaxRetry");
	var raAcctMaxInterval = document.getElementById("wlanRaAcctMaxInterval");
//	var raSessionTimeout = document.getElementById("wlanRaSessionTimeout");
	var raIdleTimeout = document.getElementById("wlanRaIdleTimeout");
	var raExpireTimeout = document.getElementById("wlanRaExpireTimeout");
	
	if( validateRange(raInterimInterval, 10, 0, 600, true) != 1 ){
		alert("Range : 0~600");
		return false;
	}
	if( validateRange(raAuthMaxRetry, 10, 1, 10, true) != 1 ||
		validateRange(raAcctMaxRetry, 10, 1, 10, true) != 1 ){
		alert("Range : 1~10");
		return false;
	}
	if( validateRange(raAuthMaxInterval, 10, 1, 120, true) != 1 ||
		validateRange(raAcctMaxInterval, 10, 1, 120, true) != 1 ){
		alert("Range : 1~120");
		return false;
	}
//	if( validateRange(raSessionTimeout, 10, 0, 120, true) != 1 ){
//		alert("Range : 0~120");
//		return false;
//	}
	if( validateRange(raIdleTimeout, 10, 0, 3600, true) != 1 ){
		alert("Range : 0~3600");
		return false;
	}
	if( validateRange(raExpireTimeout, 10, 0, 500, true) != 1 ){
		alert("Range : 0~500");
		return false;
	}
	
	return true;
}

function validate_radius(flag){
	var ret1, ret2;
	ret1 = validate_radiusServer("raAuthAddrIP", "raAuthAddrPort", "raAuthAddrSecret");
	ret2 = validate_radiusServer("raAcctAddrIP", "raAcctAddrPort", "raAcctAddrSecret");

//	if( ret1 == -1 || ret2 == -1 || (ret1 == 0 && ret2 == 0) ){
	//KT 조건변경 - 서버 2개 모두 있어야 함.
	if( !(ret1 == 1 && ret2 == 1) ){
		alert("Radius 서버 정보가 비어있습니다");
		return false;
	}
	
	if( flag == 1 ){
		//radius param이 있는경우
		if( validate_radius_param() == false ){
			return false;
		}
	}
	
	ret = validateRadiusInputTextForm();
	return ret;
}

function validateSecurityInputTextForm(){
	var ret = true;
	var arrTextForm = new Array(
		"wlanUIWEPKey0", "wlanUIWEPKey1", "wlanUIWEPKey2", "wlanUIWEPKey3", "wlanUIPSKKey"
	);
	
	ret = checkKoreanTextFormArray(arrTextForm);
	if( ret == false ){
		alert("한글은 입력하실 수 없습니다");
	}
	return ret;
}
function validateSecurityInputTextForm_5g(){
	var ret = true;
	var arrTextForm = new Array(
		"wlanUIWEPKey0_5g", "wlanUIWEPKey1_5g", "wlanUIWEPKey2_5g", "wlanUIWEPKey3_5g", "wlanUIPSKKey_5g"
	);
	
	ret = checkKoreanTextFormArray(arrTextForm);
	if( ret == false ){
		alert("한글은 입력하실 수 없습니다");
	}
	return ret;
}

function validateRadiusInputTextForm(){
	var ret = true;
	var arrTextForm = new Array(
		"raAuthAddrIP", "raAuthAddrPort", "raAuthAddrSecret", 
		"raAcctAddrIP", "raAcctAddrPort", "raAcctAddrSecret"
	);
	
	ret = checkKoreanTextFormArray(arrTextForm);
	if( ret == false ){
		alert("한글은 입력하실 수 없습니다");
	}
	return ret;
}

///////////////////
// wlan wps
/*
[form ID 정리]

*. Hidden 속성
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/user_03_4_3_wps_set.asp"/>
<input type="hidden" id="wlanUserPriority" name="wlanUserPriority" value=""/>
<input type="hidden" id="wlanSSIDIdx" name="wlanSSIDIdx" value=""/>

*. DB와 동일
wlanWPSPIN
wlanUIConfigured		=> wlanBroadSSID
wlanUIPINSelf			=> wlanSecurityMode
*/

function changeLabelHTML(strElementID, strNewValue){
	var e = document.getElementById(strElementID);
	if( e!= null )
		e.innerHTML = strNewValue;
}

function isDigitOnly(data) {
	var string = "1234567890";
	for( var i=0;i<data.length;i++){
		if (string.indexOf(data.charAt(i))==-1){
			return false;
		}
	}
	return true;
}

// WPS Validate
function validate_WLAN_PinCode(code){
	var accum=0;

	accum += 3 * (parseInt(code / 10000000) % 10); 
	accum += 1 * (parseInt(code / 1000000) % 10); 
	accum += 3 * (parseInt(code / 100000) % 10); 
	accum += 1 * (parseInt(code / 10000) % 10);
	accum += 3 * (parseInt(code / 1000) % 10);
	accum += 1 * (parseInt(code / 100) % 10);
	accum += 3 * (parseInt(code / 10) % 10); 
	accum += 1 * (parseInt(code / 1) % 10);
	return (0 == (accum % 10));	
}

function validateOnSubmit_WLAN_WPS(url, pinID){
	//PIN value check
	var e = document.getElementById(pinID);
	if( e == null || e.value == null || isEmpty( e.value ) || 
		isDigitOnly(e.value) == false ){
		e.focus();
		alert( "PIN Code 오류" );
		return false;
	} 

	if( e.value.length != 4 && e.value.length != 8 ){
		e.focus();
		alert( "PIN Code 오류" );
		return false;
	}
	
	if( e.value.length == 8 ){	//length 8에 대해서만 validate	
	//2010.06.11 WIFI 인증 - PIN Validate 추가
	if( validate_WLAN_PinCode( e.value ) == false ){
		e.focus();
		alert( "PIN Code Checksum 오류" );
		return false;
	}
	}//length == 8
	
	return true;
}

function convert_WLAN_EncTypePSK(encType){
	var strEncType = ""
	if( encType == "0" ){
		strEncType += "TKIP";
	}else if( encType == "1" ){
		strEncType += "AES";
	}else if( encType == "2" ){
		strEncType += "TKIP/AES";
	}
	return strEncType;
}

function cfg2web_WLAN_WPS_Security(securityTypeID, encTypeID, keyID, securityMode, encType, wepPskkey){
	var wlanUISecurityType, wlanUIEncType;
	
	switch( securityMode ){
	case '0':	//SECURITY_MODE_DISABLE
		wlanUISecurityType = 'None';
		wlanUIEncType = 'None';
	break;
	case '1':	//SECURITY_MODE_OPEN
		wlanUISecurityType = 'OPEN';
		wlanUIEncType = 'WEP';
	break;
	case '2':	//SECURITY_MODE_SHARED
		wlanUISecurityType = 'Shared';
		wlanUIEncType = 'WEP';
	break;
	case '3':	//SECURITY_MODE_AUTO
		wlanUISecurityType = 'AUTO';
		wlanUIEncType = 'WEP';
	break;
	case '4':	//SECURITY_MODE_WPA_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	case '5':	//SECURITY_MODE_WPA2_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	case '6':	//SECURITY_MODE_WPA_WPA2_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	case '13':	//SECURITY_MODE_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	case '14':	//SECURITY_MODE_WPA2_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	case '15':	//SECURITY_MODE_WPA_WPA2_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
		wlanUIEncType = convert_WLAN_EncTypePSK(encType);
	break;
	}
	if( isEmpty(wlanUISecurityType) == false ){
		changeLabelHTML(securityTypeID, wlanUISecurityType);
	}
	if( isEmpty(wlanUIEncType) == false ){
		changeLabelHTML(encTypeID, wlanUIEncType);
	}
	if( securityMode != '0' && isEmpty(wepPskkey) == false ){
		changeLabelHTML(keyID, convertSpaceToEscape(wepPskkey));
	}
}

/////////////////////////////////////
//
function conv2Str_WLAN_SecurityMode(securityMode, encMode){
	var wlanUISecurityType;
	
	switch( securityMode ){
	case '0':	//SECURITY_MODE_DISABLE
		wlanUISecurityType = 'None';
	break;
	case '1':	//SECURITY_MODE_OPEN
		wlanUISecurityType = 'WEP';
	break;
	case '2':	//SECURITY_MODE_SHARED
		wlanUISecurityType = 'WEP';
	break;
	case '3':	//SECURITY_MODE_AUTO
		wlanUISecurityType = 'WEP';
	break;
	case '4':	//SECURITY_MODE_WPA_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	case '5':	//SECURITY_MODE_WPA2_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	case '6':	//SECURITY_MODE_WPA_WPA2_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	case '7':	//SECURITY_MODE_WPA_ENT
		wlanUISecurityType = 'WPA-1X';
	break;
	case '8':	//SECURITY_MODE_WPA2_ENT
		wlanUISecurityType = 'WPA-1X';
	break;
	case '9':	//SECURITY_MODE_WPA_WPA2_ENT
		wlanUISecurityType = 'WPA-1X';
	break;
	case '10':	//SECURITY_MODE_8021X
		wlanUISecurityType = '802.1X';
	break;
	case '13':	//SECURITY_MODE_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	case '14':	//SECURITY_MODE_WPA2_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	case '15':	//SECURITY_MODE_WPA_WPA2_WPA3_PSK
		wlanUISecurityType = 'WPA-PSK';
	break;
	}
	return wlanUISecurityType;
}

/////////////////////////////////////
//2010.12.06 SOHOZoneMode 추가
function is_kt_SOHOZoneEnabled(){
	//var privilege = getUserPrivilege();
	var sohoZoneMode = document.getElementById("opmode_sohozone");
	
	if( sohoZoneMode != null &&
		sohoZoneMode.value == "1" ){
		return true;
	}
	
	return false;
}

function confirm_main_Activity(wlanIfIndex, ssidMainEnable, ssidVapEnable){
	var confirmed = false;
	var msg = null;
	var msg_0_0 	= "5Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다";
	var msg_0_1 	= "5Ghz ollehWiFi 접속이 해제됩니다.\n5Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다.";
	var msg_100_0 	= "2.4Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다";
	var msg_100_1 	= "2.4Ghz ollehWiFi 접속이 해제됩니다.\n2.4Ghz 대역-무선 Wi-Fi 서비스를 사용할 수 없게 됩니다.";

	if( ssidMainEnable == 0 ){
		if( ssidVapEnable == 1 ){
			if( wlanIfIndex == '0' ){
				msg = msg_0_1;
			}else{
				msg = msg_100_1;
			}
		}else{
			if( wlanIfIndex == '0' ){
				msg = msg_0_0;
			}else{
				msg = msg_100_0;
			}
		}
	}else{
		confirmed = true;
	}
	if( msg != null ){
		confirmed = confirm( msg );
	}
	return confirmed;
}

/*
 * MTK 7621+7615(DBDC) Only - Main SSID Activity 변경시 재부팅 필요
 */
function MTK_WLAN_isNeedReboot(){
	var e = $("input[name='wlanRadioActivity']:checked").val();
	var org = $("#wlanEnable_org").val();
	if(e != org){
		return true;
	}
	return false;
}
function MTK_WLAN_isNeedReboot_5g(){
	var e_5g = $("input[name='wlanRadioActivity_5g']:checked").val();
	var org_5g = $("#wlanEnable_org_5g").val();
	if(e_5g != org_5g){
		return true;
	}
	return false;
}

function MTK_WLAN_isNeedReboot_mobile(){
	var e = $("input[name='m_wlanRadioActivity']:checked").val();
	var org = $("#wlanEnable_org").val();
	if(e != org){
		return true;
	}
	return false;
}
