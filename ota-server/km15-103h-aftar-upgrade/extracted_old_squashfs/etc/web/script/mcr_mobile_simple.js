
function cfg2web_mobile_WLAN_Security_5g() 
{
	var bWebKeyEnable = 0;
	var bWPAEnable = 0;
	var bPSKEnable = 0;
	var b8021xEnable = 0;
	var bWebRedirectEnable = 0;
	var bWepRekeyEnable = 0;
	var securityModeValue = $("#wlanSecurityMode_5g").val();
	var uiSecurityMode = ''+conv2UI_WLAN_SecurityType(securityModeValue);

	//security
	$("input[name='wlanUISecurityType_5g']").val(uiSecurityMode);

	setwlanUISecurityType_5g(uiSecurityMode);

	switch( securityModeValue ){
		case '0':       //SECURITY_MODE_DISABLE
			break;
		case '1':       //SECURITY_MODE_OPEN
			setwlanUIWEPEncType_5g('0'); // 
			break;
		case '2':       //SECURITY_MODE_SHARED
			setwlanUIWEPEncType_5g('1');
			break;
		case '3':       //SECURITY_MODE_AUTO
			setwlanUIWEPEncType_5g('2');
			break;
		case '4':       //SECURITY_MODE_WPA_PSK
			setwlanUIWPAType_5g('0');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '5':       //SECURITY_MODE_WPA2_PSK
			setwlanUIWPAType_5g('1');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '6':       //SECURITY_MODE_WPA_WPA2_PSK
			setwlanUIWPAType_5g('2');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '7':       //SECURITY_MODE_WPA_ENT
			setwlanUIWPAType_5g('0');
			bWPAEnable = 1;
			break;
		case '8':       //SECURITY_MODE_WPA2_ENT
			setwlanUIWPAType_5g('1');
			bWPAEnable = 1;
			break;
		case '9':       //SECURITY_MODE_WPA_WPA2_ENT
			setwlanUIWPAType_5g('2');
			bWPAEnable = 1;
			break;
		case '10'://SECURITY_MODE_8021X
			b8021xEnable = 1;
			bWebRedirectEnable = 1;
			bWepRekeyEnable = 1;
			break;
		case '13'://SECURITY_MODE_WPA3_PSK
			setwlanUIWPAType_5g('3');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '14'://SECURITY_MODE_WPA2_WPA3_PSK
			setwlanUIWPAType_5g('4');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '15'://SECURITY_MODE_WPA_WPA2_WPA3_PSK
			setwlanUIWPAType_5g('5');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
	}
	//////////////////////////
	// WEP
	var wlanWEPKey = $("#wlanWEPKey_5g").val();
	var wlanWEPKeyIndex = $("#wlanWEPKeyIndex_5g").val();
	if( wlanWEPKey != null ){
		if( wlanWEPKey.length == 13 || wlanWEPKey.length == 26 ){
			setwlanUIWEPKeyLen_5g('1');
		}else{
			setwlanUIWEPKeyLen_5g('0');
		}

		if( wlanWEPKey != null ){
			initTextById("wlanUIWEPKey_5g"+wlanWEPKeyIndex, wlanWEPKey);
		}
	}

	//////////////////////////
	// WPA
	if(bWPAEnable == 1 ){
		var WlanEncType = $("#wlanEncType_5g").val();
		setwlanUIWPAEncType_5g(WlanEncType);

		if( bPSKEnable == 1 ){
			var pskKey = $("#wlanPSKKey_5g").val();
			if( pskKey != null ){
				setwlanUIPSKKeyType_5g((pskKey.length == 64 ) ? '1' : '0');
				initTextById("wlanUIPSKKey_5g", pskKey);
			}
		}
	}
	onClick_WLAN_mobile_SecurityType_5g();
	kt_keypolicy_setCfg_orgInfo_5g();

}


function setwlanUISecurityType_5g(wlanUISecurityType_5g){
	var wlanUIPSKType = wlanUISecurityType_5g;
	switch(wlanUIPSKType){
		case '0':
			mcr_clickradio_wlanUISecurityType_5g('0');
			$("input[id='m_wlanUISecurityType_5g']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType_5g").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUISecurityType_5g('1');
			$("input[id='m_wlanUISecurityType_5g2']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType_5g").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUISecurityType_5g('2');
			$("input[id='m_wlanUISecurityType_5g3']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType_5g").val("2");
			break;
		case '3':
			mcr_clickradio_wlanUISecurityType_5g('3');
			$("input[id='m_wlanUISecurityType_5g4']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType_5g").val("3");
			break;
		case '4':
			mcr_clickradio_wlanUISecurityType_5g('4');
			$("input[id='m_wlanUISecurityType_5g1']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType_5g").val("4");
			break;
		default:
			break;
	}
	onClick_WLAN_mobile_SecurityType_5g();
}

function mcr_clickradio_wlanUISecurityType_5g(val){
	$('label[for=m_wlanUISecurityType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType_5g2]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType_5g3]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType_5g4]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType_5g1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUISecurityType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g4]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUISecurityType_5g2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g4]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUISecurityType_5g3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g4]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanUISecurityType_5g4]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g3]').removeClass('ui-btn-active-c');
			break;
		case '4':
			$('label[for=m_wlanUISecurityType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType_5g4]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWEPEncType_5g(wlanUIWEPEncType_5g){
        switch(wlanUIWEPEncType_5g){
                case '0':
			mcr_clickradio_wlanUIWEPEncType_5g('0');
                        $("input[id='m_wlanUIWEPEncType_5g']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType_5g").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIWEPEncType_5g('1');
                        $("input[id='m_wlanUIWEPEncType_5g1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType_5g").val("1");
                        break;
                case '2':
			mcr_clickradio_wlanUIWEPEncType_5g('2');
                        $("input[id='m_wlanUIWEPEncType_5g2']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType_5g").val("2");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIWEPEncType_5g(val){
	$('label[for=m_wlanUIWEPEncType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPEncType_5g1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPEncType_5g2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWEPEncType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g2]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWEPEncType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWEPEncType_5g2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType_5g1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWPAType_5g(wlanUIWPAType_5g){
	switch(wlanUIWPAType_5g){
		case '0':
			mcr_clickradio_wlanUIWPAType_5g('0');
			$("input[id='m_wlanUIWPAType_5g']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUIWPAType_5g('1');
			$("input[id='m_wlanUIWPAType_5g1']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUIWPAType_5g('2');
			$("input[id='m_wlanUIWPAType_5g2']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("2");
			break;
		case '3':
			mcr_clickradio_wlanUIWPAType_5g('3');
			$("input[id='m_wlanUIWPAType_5g3']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType_5g('1');
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("3");
			break;
		case '4':
			mcr_clickradio_wlanUIWPAType_5g('4');
			$("input[id='m_wlanUIWPAType_5g4']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType_5g('1');
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("4");
			break;
		case '5':
			mcr_clickradio_wlanUIWPAType_5g('5');
			$("input[id='m_wlanUIWPAType_5g5']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType_5g('1');
			$("input[id='m_wlanUIWPAEncType_5g']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType_5g2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType_5g").val("5");
			break;
		default:
			break;
	}
}

function mcr_clickradio_wlanUIWPAType_5g(val){
	$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWPAType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWPAType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWPAType_5g2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanUIWPAType_5g3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active-c');
			break;
		case '4':
			$('label[for=m_wlanUIWPAType_5g4]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g5]').removeClass('ui-btn-active-c');
			break;
		case '5':
			$('label[for=m_wlanUIWPAType_5g5]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType_5g4]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWEPKeyLen_5g(wlanUIWEPKeyLen_5g){
        switch(wlanUIWEPKeyLen_5g){
                case '0':
			mcr_clickradio_wlanUIWEPKeyLen_5g('0');
                        $("input[id='m_wlanUIWEPKeyLen_5g']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPKeyLen_5g").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIWEPKeyLen_5g('1');
                        $("input[id='m_wlanUIWEPKeyLen_5g1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPKeyLen_5g").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIWEPKeyLen_5g(val){
	$('label[for=m_wlanUIWEPKeyLen_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPKeyLen_5g1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWEPKeyLen_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPKeyLen_5g1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWEPKeyLen_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPKeyLen_5g]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIPSKKeyType_5g(wlanUIPSKKeyType_5g){
        switch(wlanUIPSKKeyType_5g){
                case '0':
			mcr_clickradio_wlanUIPSKKeyType_5g('0');
                        $("input[id='m_wlanUIPSKKeyType_5g']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIPSKKeyType_5g").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIPSKKeyType_5g('1');
                        $("input[id='m_wlanUIPSKKeyType_5g1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIPSKKeyType_5g").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIPSKKeyType_5g(val){
	$('label[for=m_wlanUIPSKKeyType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIPSKKeyType_5g1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIPSKKeyType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIPSKKeyType_5g1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIPSKKeyType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIPSKKeyType_5g]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWEPKeyType_5g(wlanWEPKeyType_5g){
        switch(wlanWEPKeyType_5g){
                case '0':
			mcr_clickradio_wlanWEPKeyType_5g('0');
                        $("input[id='m_wlanWEPKeyType_5g']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyType_5g").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWEPKeyType_5g('1');
                        $("input[id='m_wlanWEPKeyType_5g1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyType_5g").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWEPKeyType_5g(val){
	$('label[for=m_wlanWEPKeyType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyType_5g1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWEPKeyType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyType_5g1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWEPKeyType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyType_5g]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWEPKeyIndex_5g(wlanWEPKeyIndex_5g){
        switch(wlanWEPKeyIndex_5g){
                case '0':
			mcr_clickradio_wlanWEPKeyIndex_5g('0');
                        $("input[id='m_wlanWEPKeyIndex_5g']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex_5g").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWEPKeyIndex_5g('1');
                        $("input[id='m_wlanWEPKeyIndex_5g1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex_5g").val("1");
                        break;
                case '2':
			mcr_clickradio_wlanWEPKeyIndex_5g('2');
                        $("input[id='m_wlanWEPKeyIndex_5g2']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex_5g").val("2");
                        break;
                case '3':
			mcr_clickradio_wlanWEPKeyIndex_5g('3');
                        $("input[id='m_wlanWEPKeyIndex_5g3']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex_5g").val("3");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWEPKeyIndex_5g(val){
	$('label[for=m_wlanWEPKeyIndex_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex_5g1]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex_5g2]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex_5g3]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWEPKeyIndex_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g3]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWEPKeyIndex_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g3]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanWEPKeyIndex_5g2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g3]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanWEPKeyIndex_5g3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex_5g2]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function onClick_WLAN_mobile_SecurityType_5g(){
	var org = '' + conv2UI_WLAN_SecurityType($("#wlanSecurityMode_5g").val());
	var sel = $("input[name='wlanUISecurityType_5g']").val();
	var wlanPSKKey_backup = $("#wlanWEPPSKKey_backup_5g").val();

	if( sel == '0' ){               //None
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
		$("#wlanView8021x_5g").hide();
	}else if( sel == '1' ){ //WEP
		$("#wlanViewWEP_5g").show();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
		$("#wlanView8021x_5g").hide();
	}else if( sel == '2' ){ //PSK
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").show();
		$("#wlanViewPSK1_5g").show();
		$("#wlanViewPSK2_5g").show();
		$("#wireless_wlanUIPSKKey_5g").show();
		$("#wlanView8021x_5g").hide();
	}else if( sel == '3' ){ //WPA-Enterprise
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").show();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
		$("#wlanView8021x_5g").hide();
	}else if( sel == '4' ){ //802.1x
		$("#wlanViewWEP_5g").hide();
		$("#wlanViewWPA_5g").hide();
		$("#wlanViewPSK1_5g").hide();
		$("#wlanViewPSK2_5g").hide();
		$("#wireless_wlanUIPSKKey_5g").hide();
		$("#wlanView8021x_5g").show();
	}

	//인증방식이 변경된 경우 재설정
	//set default radio
	if( sel != org && sel != '0' ){
		if( sel == '1' ){       //WEP
			setwlanUIWEPEncType_5g('2');
			setwlanUIWEPKeyLen_5g('0');
			setwlanWEPKeyType_5g('1');
			setwlanWEPKeyIndex_5g('0');

			$("#wlanUIWEPKey0_5g").val("");
			$("#wlanUIWEPKey1_5g").val("");
			$("#wlanUIWEPKey2_5g").val("");
			$("#wlanUIWEPKey3_5g").val("");
		}else if( sel == '2' ){ //PSK
			setwlanUIWPAType_5g('2');
			setwlanUIWPAEncType_5g('2');
			setwlanUIPSKKeyType_5g('0');

			//$("#wlanUIPSKKey_5g").val("");
			$("#wlanUIPSKKey_5g").val(wlanPSKKey_backup);
		}else if( sel == '3' ){ //Enterprise
			setwlanUIWPAType_5g('0');
			setwlanUIWPAEncType_5g('0');
			setwlanUIPSKKeyType_5g('0');

			$("#wlanUIPSKKey_5g").val("");
		}else if( sel == '4' ){ //802.1x
			setwlanWEPRekeyEnable_5g('0');
			setwlanMACAuthEnable_5g('1');
		}
	}
}

function setwlanUIWPAEncType_5g(wlanUIWPAEncType_5g){
	switch(wlanUIWPAEncType_5g){
		case '0':
			mcr_clickradio_wlanUIWPAEncType_5g('0');
			$("input[id='m_wlanUIWPAEncType_5g']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType_5g").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUIWPAEncType_5g('1');
			$("input[id='m_wlanUIWPAEncType_5g1']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType_5g").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUIWPAEncType_5g('2');
			$("input[id='m_wlanUIWPAEncType_5g2']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType_5g").val("2");
			break;
		default:
			break;
	}
}

function mcr_clickradio_wlanUIWPAEncType_5g(val){
	$('label[for=m_wlanUIWPAEncType_5g]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAEncType_5g1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAEncType_5g2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWPAEncType_5g]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g2]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWPAEncType_5g1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWPAEncType_5g2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType_5g1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function web2cfg_WLAN_mobile_Security_5g()
{
	var wlanUISecurityType = $("input[name='wlanUISecurityType_5g']").val();
	var wlanSecurityMode = '0';

	if( wlanUISecurityType == '0' ){        //None
		wlanSecurityMode = '0';
	}else if( wlanUISecurityType == '1' ){  //WEP
		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType_5g']").val(); 
		if( wlanUIWEPEncType == '0' ){                  //Open
			wlanSecurityMode = '1';
		}else if( wlanUIWEPEncType == '1' ){    //Shared
			wlanSecurityMode = '2';
		}else if( wlanUIWEPEncType == '2' ){    //Auto
			wlanSecurityMode = '3';
		}

		var keyName = "wlanUIWEPKey0_5g";
		initTextById( "wlanWEPKey_5g", document.getElementById(keyName).value );
		if( validate_WLAN_mobile_Security_wepkey_5g() == false ) return false;
		else{
			var wlanWEPKeyIndex = $("#wlanWEPKeyIndex_5g").val();
			var keyName = "wlanUIWEPKey"+wlanWEPKeyIndex+"_5g";

			initTextById( "wlanWEPKey_5g", document.getElementById(keyName).value );
		}

		initTextById( "wlanEncType_5g", '1' );             //WEP Only
	}else if( wlanUISecurityType == '2' ){  //WPA-PSK
		var wlanUIWPAType = $("input[name='wlanUIWPAType_5g']").val();
		if( wlanUIWPAType == '0' ){                     //WPA
			wlanSecurityMode = '4';
		}else if( wlanUIWPAType == '1' ){       //WPA2
			wlanSecurityMode = '5';
		}else if( wlanUIWPAType == '2' ){       //WPA/WPA2
			wlanSecurityMode = '6';
		}else if( wlanUIWPAType == '3'){	//WPA3
			wlanSecurityMode = '13';
		}else if( wlanUIWPAType == '4'){	//WPA2/WPA3
			wlanSecurityMode = '14';
		}else if( wlanUIWPAType == '5'){	//WPA/WPA2/WPA3
			wlanSecurityMode = '15';
		}

		if( validate_WLAN_mobile_Security_pskkey_5g() == false ) return false;
		else{
			initTextById( "wlanPSKKey_5g", document.getElementById("wlanUIPSKKey_5g").value );
		}
		initTextById( "wlanEncType_5g", $("input[name='wlanUIWPAEncType_5g']").val() );
	}

	initTextById( "wlanSecurityMode_5g", wlanSecurityMode );

	return true;
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

function validate_WLAN_mobile_Security_wepkey_5g(){
	var nSuccess = 0;
	var wepKeyTypeValue = $("input[name='wlanWEPKeyType_5g']").val();
	var wepKeyLen = $("input[name='wlanUIWEPKeyLen_5g']").val();
	var wlanWEPKeyIndex = $("#wlanWEPKeyIndex_5g").val();

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
			if( validate_wepkey_5g(e, wepKeyTypeValue, wepKeyLen) == true ){
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

	console.debug("kt_keypolicy_setCfg_orgInfo_5g:"  );
	console.debug("wlanUISecurityType_5g_org:" + $("#wlanUISecurityType_org_5g").val() );
	console.debug("wlanUIWEPEncType_5g_org:" + $("#wlanUIWEPEncType_org_5g").val() );
	console.debug("wlanWEPKeyType_5g_org:" + $("#wlanWEPKeyType_org_5g").val() );
	console.debug("wlanUIWPAType_5g_org:" + $("#wlanUIWPAType_org_5g").val() );
	console.debug("wlanUIWPAEncType_5g_org:" + $("#wlanUIWPAEncType_org_5g").val() );
	console.debug("wlanUIPSKKeyType_5g_org:" + $("#wlanUIPSKKeyType_org_5g").val() );
	console.debug("wlanKey_org:" + $("#wlanKey_org").val() );
}

function kt_keypolicy_isNeedCompare_keyInfo_5g(newkey){
	var ret = false;
//	var uiSecurityType = $("input[name='wlanUISecurityType']:checked").val();
	var uiSecurityType = kt_keypolicy_getValue("wlanUISecurityType_5g");

	if( uiSecurityType == '0' ){	
		//None
		ret = false;
	}else if( uiSecurityType == '1' ){
		//WEP
//		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType']:checked").val();
		var wlanUIWEPEncType = kt_keypolicy_getValue("wlanUIWEPEncType_5g");
		var wlanWEPKeyType = kt_keypolicy_getValue("wlanWEPKeyType_5g");

		console.debug("wlanUISecurityType_5g:" + uiSecurityType );
		console.debug("wlanUIWEPEncType_5g:" + wlanUIWEPEncType );
		console.debug("wlanWEPKeyType_5g:" + wlanWEPKeyType );
		console.debug("wlanKey_5g:" + newkey.value );

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
//		var wlanUIWPAType = $("input[name='wlanUIWPAType']:checked").val();
//		var wlanUIWPAEncType = $("input[name='wlanUIWPAEncType']:checked").val();
//		var wlanUIPSKKeyType = $("input[name='wlanUIPSKKeyType']:checked").val();
		var wlanUIWPAType = kt_keypolicy_getValue("wlanUIWPAType_5g");
		var wlanUIWPAEncType = kt_keypolicy_getValue("wlanUIWPAEncType_5g");
		var wlanUIPSKKeyType = kt_keypolicy_getValue("wlanUIPSKKeyType_5g");

		console.debug("wlanUISecurityType:" + uiSecurityType );
		console.debug("wlanUIWPAType:" + wlanUIWPAType );
		console.debug("wlanUIWPAEncType:" + wlanUIWPAEncType );
		console.debug("wlanUIPSKKeyType:" + wlanUIPSKKeyType );
		console.debug("wlanKey:" + newkey.value );

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
	console.debug("5G key check ret:" + ret );
	return ret;
}


function validate_WLAN_mobile_Security_pskkey_5g(){
	return validate_psk_5g(document.getElementById("wlanUIPSKKey_5g"),
		$("input[name='wlanUIPSKKeyType_5g']").val());
}

/*
 *	pskKey - psk key 저장 textbox
 *	keyType - optional ('0' - passphrase, '1' - hex )
 */
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















