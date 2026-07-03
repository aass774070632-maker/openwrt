/* 무선 Setting */
function setwlanRadioActivity(wlanRadioActivity){
        switch(wlanRadioActivity){
                case '0':
			mcr_clickradio_wlanRadioActivity('0');
                        $("input[id='m_wlanRadioActivity1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanRadioActivity").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanRadioActivity('1');
                        $("input[id='m_wlanRadioActivity']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanRadioActivity").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanRadioActivity(val){
	$('label[for=m_wlanRadioActivity]').removeClass('ui-btn-active');
	$('label[for=m_wlanRadioActivity1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanRadioActivity1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanRadioActivity]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanRadioActivity]').addClass('ui-btn-active-c');
			$('label[for=m_wlanRadioActivity1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIPSKKeyType(wlanUIPSKKeyType){
        switch(wlanUIPSKKeyType){
                case '0':
			mcr_clickradio_wlanUIPSKKeyType('0');
                        $("input[id='m_wlanUIPSKKeyType']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIPSKKeyType").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIPSKKeyType('1');
                        $("input[id='m_wlanUIPSKKeyType1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIPSKKeyType").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIPSKKeyType(val){
	$('label[for=m_wlanUIPSKKeyType]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIPSKKeyType1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIPSKKeyType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIPSKKeyType1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIPSKKeyType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIPSKKeyType]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUISecurityType(wlanUISecurityType){
	var wlanUIPSKType = wlanUISecurityType;
	switch(wlanUIPSKType){
		case '0':
			mcr_clickradio_wlanUISecurityType('0');
			$("input[id='m_wlanUISecurityType']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUISecurityType('1');
			$("input[id='m_wlanUISecurityType2']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUISecurityType('2');
			$("input[id='m_wlanUISecurityType3']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType").val("2");
			break;
		case '3':
			mcr_clickradio_wlanUISecurityType('3');
			$("input[id='m_wlanUISecurityType4']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType").val("3");
			break;
		case '4':
			mcr_clickradio_wlanUISecurityType('4');
			$("input[id='m_wlanUISecurityType1']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUISecurityType").val("4");
			break;
		default:
			break;
	}
	onClick_WLAN_mobile_SecurityType();
}

function mcr_clickradio_wlanUISecurityType(val){
	$('label[for=m_wlanUISecurityType]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType2]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType3]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType4]').removeClass('ui-btn-active');
	$('label[for=m_wlanUISecurityType1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUISecurityType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType4]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUISecurityType2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType4]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUISecurityType3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType4]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanUISecurityType4]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType3]').removeClass('ui-btn-active-c');
			break;
		case '4':
			$('label[for=m_wlanUISecurityType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUISecurityType4]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWEPRekeyEnable(wlanWEPRekeyEnable){
        switch(wlanWEPRekeyEnable){
                case '0':
			mcr_clickradio_wlanWEPRekeyEnable('0');
                        $("input[id='m_wlanWEPRekeyEnable1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPRekeyEnable").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWEPRekeyEnable('1');
                        $("input[id='m_wlanWEPRekeyEnable']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPRekeyEnable").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWEPRekeyEnable(val){
	$('label[for=m_wlanWEPRekeyEnable]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPRekeyEnable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWEPRekeyEnable1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPRekeyEnable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWEPRekeyEnable]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPRekeyEnable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanMACAuthEnable(wlanMACAuthEnable){
        switch(wlanWEPRekeyEnable){
                case '0':
			mcr_clickradio_wlanMACAuthEnable('0');
                        $("input[id='m_wlanMACAuthEnable1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanMACAuthEnable").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanMACAuthEnable('1');
                        $("input[id='m_wlanMACAuthEnable']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanMACAuthEnable").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanMACAuthEnable(val){
	$('label[for=m_wlanMACAuthEnable]').removeClass('ui-btn-active');
	$('label[for=m_wlanMACAuthEnable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanMACAuthEnable1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanMACAuthEnable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanMACAuthEnable]').addClass('ui-btn-active-c');
			$('label[for=m_wlanMACAuthEnable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWEPEncType(wlanUIWEPEncType){
        switch(wlanUIWEPEncType){
                case '0':
			mcr_clickradio_wlanUIWEPEncType('0');
                        $("input[id='m_wlanUIWEPEncType']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIWEPEncType('1');
                        $("input[id='m_wlanUIWEPEncType1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType").val("1");
                        break;
                case '2':
			mcr_clickradio_wlanUIWEPEncType('2');
                        $("input[id='m_wlanUIWEPEncType2']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPEncType").val("2");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIWEPEncType(val){
	$('label[for=m_wlanUIWEPEncType]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPEncType1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPEncType2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWEPEncType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType2]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWEPEncType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWEPEncType2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPEncType1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWEPKeyLen(wlanUIWEPKeyLen){
        switch(wlanUIWEPKeyLen){
                case '0':
			mcr_clickradio_wlanUIWEPKeyLen('0');
                        $("input[id='m_wlanUIWEPKeyLen']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPKeyLen").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanUIWEPKeyLen('1');
                        $("input[id='m_wlanUIWEPKeyLen1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanUIWEPKeyLen").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanUIWEPKeyLen(val){
	$('label[for=m_wlanUIWEPKeyLen]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWEPKeyLen1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWEPKeyLen]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPKeyLen1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWEPKeyLen1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWEPKeyLen]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWEPKeyType(wlanWEPKeyType){
        switch(wlanWEPKeyType){
                case '0':
			mcr_clickradio_wlanWEPKeyType('0');
                        $("input[id='m_wlanWEPKeyType']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyType").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWEPKeyType('1');
                        $("input[id='m_wlanWEPKeyType1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyType").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWEPKeyType(val){
	$('label[for=m_wlanWEPKeyType]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyType1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWEPKeyType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyType1]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWEPKeyType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyType]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWEPKeyIndex(wlanWEPKeyIndex){
        switch(wlanWEPKeyIndex){
                case '0':
			mcr_clickradio_wlanWEPKeyIndex('0');
                        $("input[id='m_wlanWEPKeyIndex']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWEPKeyIndex('1');
                        $("input[id='m_wlanWEPKeyIndex1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex").val("1");
                        break;
                case '2':
			mcr_clickradio_wlanWEPKeyIndex('2');
                        $("input[id='m_wlanWEPKeyIndex2']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex").val("2");
                        break;
                case '3':
			mcr_clickradio_wlanWEPKeyIndex('3');
                        $("input[id='m_wlanWEPKeyIndex3']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWEPKeyIndex").val("3");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWEPKeyIndex(val){
	$('label[for=m_wlanWEPKeyIndex]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex1]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex2]').removeClass('ui-btn-active');
	$('label[for=m_wlanWEPKeyIndex3]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWEPKeyIndex]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex3]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWEPKeyIndex1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex3]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanWEPKeyIndex2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex3]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanWEPKeyIndex3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanWEPKeyIndex2]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWPAType(wlanUIWPAType){
	switch(wlanUIWPAType){
		case '0':
			mcr_clickradio_wlanUIWPAType('0');
			$("input[id='m_wlanUIWPAType']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUIWPAType('1');
			$("input[id='m_wlanUIWPAType1']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUIWPAType('2');
			$("input[id='m_wlanUIWPAType2']").attr("checked", true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType']").attr('disabled',false).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled',false).checkboxradio("refresh");
			$("#wlanUIWPAType").val("2");
			break;
		case '3':
			mcr_clickradio_wlanUIWPAType('3');
			$("input[id='m_wlanUIWPAType3']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType('1');
			$("input[id='m_wlanUIWPAEncType']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType").val("3");
			break;
		case '4':
			mcr_clickradio_wlanUIWPAType('4');
			$("input[id='m_wlanUIWPAType4']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType('1');
			$("input[id='m_wlanUIWPAEncType']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType").val("4");
			break;
		case '5':
			mcr_clickradio_wlanUIWPAType('5');
			$("input[id='m_wlanUIWPAType5']").attr("checked", true).checkboxradio("refresh");
			setwlanUIWPAEncType('1');
			$("input[id='m_wlanUIWPAEncType']").attr('disabled', true).checkboxradio("refresh");
			$("input[id='m_wlanUIWPAEncType2']").attr('disabled', true).checkboxradio("refresh");
			$("#wlanUIWPAType").val("5");
			break;
		default:
			break;
	}
}

function mcr_clickradio_wlanUIWPAType(val){
	$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWPAType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWPAType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWPAType2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active-c');
			break;
		case '3':
			$('label[for=m_wlanUIWPAType3]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active-c');
			break;
		case '4':
			$('label[for=m_wlanUIWPAType4]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType5]').removeClass('ui-btn-active-c');
			break;
		case '5':
			$('label[for=m_wlanUIWPAType5]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType2]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType3]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAType4]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanUIWPAEncType(wlanUIWPAEncType){
	switch(wlanUIWPAEncType){
		case '0':
			mcr_clickradio_wlanUIWPAEncType('0');
			$("input[id='m_wlanUIWPAEncType']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType").val("0");
			break;
		case '1':
			mcr_clickradio_wlanUIWPAEncType('1');
			$("input[id='m_wlanUIWPAEncType1']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType").val("1");
			break;
		case '2':
			mcr_clickradio_wlanUIWPAEncType('2');
			$("input[id='m_wlanUIWPAEncType2']").attr("checked", true).checkboxradio("refresh");
			$("#wlanUIWPAEncType").val("2");
			break;
		default:
			break;
	}
}

function mcr_clickradio_wlanUIWPAEncType(val){
	$('label[for=m_wlanUIWPAEncType]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAEncType1]').removeClass('ui-btn-active');
	$('label[for=m_wlanUIWPAEncType2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanUIWPAEncType]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType1]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType2]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanUIWPAEncType1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType2]').removeClass('ui-btn-active-c');
			break;
		case '2':
			$('label[for=m_wlanUIWPAEncType2]').addClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType]').removeClass('ui-btn-active-c');
			$('label[for=m_wlanUIWPAEncType1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWMMEnable(wlanWMMEnable){
        switch(wlanWMMEnable){
                case '0':
			mcr_clickradio_wlanWMMEnable('0');
                        $("input[id='m_wlanWMMEnable1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWMMEnable").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWMMEnable('1');
                        $("input[id='m_wlanWMMEnable']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWMMEnable").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWMMEnable(val){
	$('label[for=m_wlanWMMEnable]').removeClass('ui-btn-active');
	$('label[for=m_wlanWMMEnable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWMMEnable1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWMMEnable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWMMEnable]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWMMEnable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanWauthEnable(wlanWauthEnable){
        switch(wlanWauthEnable){
                case '0':
			mcr_clickradio_wlanWauthEnable('0');
                        $("input[id='m_wlanWauthEnable1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWauthEnable").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanWauthEnable('1');
                        $("input[id='m_wlanWauthEnable']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanWauthEnable").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanWauthEnable(val){
	$('label[for=m_wlanWauthEnable]').removeClass('ui-btn-active');
	$('label[for=m_wlanWauthEnable1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanWauthEnable1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWauthEnable]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanWauthEnable]').addClass('ui-btn-active-c');
			$('label[for=m_wlanWauthEnable1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

function setwlanRedirectSet(wlanRedirectSet){
        switch(wlanRedirectSet){
                case '0':
			mcr_clickradio_wlanRedirectSet('0');
                        $("input[id='m_wlanRedirectSet1']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanRedirectSet").val("0");
                        break;
                case '1':
			mcr_clickradio_wlanRedirectSet('1');
                        $("input[id='m_wlanRedirectSet']").attr("checked", true).checkboxradio("refresh");
                        $("#wlanRedirectSet").val("1");
                        break;
                default:
                        break;
        }
}

function mcr_clickradio_wlanRedirectSet(val){
	$('label[for=m_wlanRedirectSet]').removeClass('ui-btn-active');
	$('label[for=m_wlanRedirectSet1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_wlanRedirectSet1]').addClass('ui-btn-active-c');
			$('label[for=m_wlanRedirectSet]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_wlanRedirectSet]').addClass('ui-btn-active-c');
			$('label[for=m_wlanRedirectSet1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}
}

/*모바일 wireless*/

function cfg2web_mobile_WLAN_Security(){
	var bWebKeyEnable = 0;
	var bWPAEnable = 0;
	var bPSKEnable = 0;
	var b8021xEnable = 0;
	var bWebRedirectEnable = 0;
	var bWepRekeyEnable = 0;
	//      var securityModeValue = document.getElementById("wlanSecurityMode").value;
	var securityModeValue = $("#wlanSecurityMode").val();
	var uiSecurityMode = ''+conv2UI_WLAN_SecurityType(securityModeValue);

	//broadcast
	initCheckboxById("wlanUIHiddenSSIDEnable",
			( document.getElementById("wlanBroadSSID").value == '1' )? '0' : '1' );


	//security
//	initRadioByName("wlanUISecurityType", uiSecurityMode);
	$("input[name='wlanUISecurityType']").val(uiSecurityMode);

	setwlanUISecurityType(uiSecurityMode);

	switch( securityModeValue ){
		case '0':       //SECURITY_MODE_DISABLE
			break;
		case '1':       //SECURITY_MODE_OPEN
			setwlanUIWEPEncType('0');
			break;
		case '2':       //SECURITY_MODE_SHARED
			setwlanUIWEPEncType('1');
			break;
		case '3':       //SECURITY_MODE_AUTO
			setwlanUIWEPEncType('2');
			break;
		case '4':       //SECURITY_MODE_WPA_PSK
			setwlanUIWPAType('0');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '5':       //SECURITY_MODE_WPA2_PSK
			setwlanUIWPAType('1');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '6':       //SECURITY_MODE_WPA_WPA2_PSK
			setwlanUIWPAType('2');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '7':       //SECURITY_MODE_WPA_ENT
			setwlanUIWPAType('0');
			bWPAEnable = 1;
			break;
		case '8':       //SECURITY_MODE_WPA2_ENT
			setwlanUIWPAType('1');
			bWPAEnable = 1;
			break;
		case '9':       //SECURITY_MODE_WPA_WPA2_ENT
			setwlanUIWPAType('2');
			bWPAEnable = 1;
			break;
		case '10'://SECURITY_MODE_8021X
			b8021xEnable = 1;
			bWebRedirectEnable = 1;
			bWepRekeyEnable = 1;
			break;
		case '13'://SECURITY_MODE_WPA3_PSK
			setwlanUIWPAType('3');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '14'://SECURITY_MODE_WPA2_WPA3_PSK
			setwlanUIWPAType('4');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
		case '15'://SECURITY_MODE_WPA_WPA2_WPA3_PSK
			setwlanUIWPAType('5');
			bWPAEnable = 1;
			bPSKEnable = 1;
			break;
	}
	//////////////////////////
	// WEP
	//      var wlanWEPKey = document.getElementById("wlanWEPKey").value;
	var wlanWEPKey = $("#wlanWEPKey").val();
	var wlanWEPKeyIndex = $("#wlanWEPKeyIndex").val();
	if( wlanWEPKey != null ){
		if( wlanWEPKey.length == 13 || wlanWEPKey.length == 26 ){
			setwlanUIWEPKeyLen('1');
		}else{
			setwlanUIWEPKeyLen('0');
		}

		if( wlanWEPKey != null ){
			initTextById("wlanUIWEPKey"+wlanWEPKeyIndex, wlanWEPKey);
		}

		//cfg2web_WLAN_Security_WEPKey();	//윗줄로 대체
	}

	//////////////////////////
	// WPA
	if(bWPAEnable == 1 ){
		var WlanEncType = $("#wlanEncType").val();
		setwlanUIWPAEncType(WlanEncType);

		if( bPSKEnable == 1 ){
			//                      var pskKey = document.getElementById("wlanPSKKey").value;
			var pskKey = $("#wlanPSKKey").val();
			if( pskKey != null ){
				setwlanUIPSKKeyType((pskKey.length == 64 ) ? '1' : '0');
				initTextById("wlanUIPSKKey", pskKey);
			}
		}
	}
	//key renewal은 WPA여부와 관계없이 초기화
	var wlanWPAKeyRenewInterval = parseInt( document.getElementById("wlanWPAKeyRenewInterval").value, 10 );
	if( wlanWPAKeyRenewInterval == 0 ){
		//disable
		initCheckboxById("wlanUIWPAKeyRenewalEnable", '0' );
		initTextById("wlanUIWPAKeyRenewal", '0');    //default 표시 - KT요청
	}else{
		//enable
		initCheckboxById("wlanUIWPAKeyRenewalEnable", '1' );
		initTextById("wlanUIWPAKeyRenewal", ''+wlanWPAKeyRenewInterval);
	}

	onClick_WLAN_mobile_SecurityType();
	onClick_WLAN_SecurityWPAKeyRenewalEnable();

	/////////////////////////
	//SSID 0번째것은 비활성화 금지(user/admin 공통)
	var ssidIdx = $("#wlanSSIDIdx").val();
	if( ssidIdx == '0' || ssidIdx == '100' ||
		ssidIdx == '1' || ssidIdx == '101' ){	//2014.07.24 Roaming 정책변경
		/*
		   $("input[name='wlanRadioActivity']").attr("disabled", "disabled");
		 */
		//$("#viewUISecurityType_8021x").hide();
		//$("#viewUISecurityType_wpa_ent").hide();
		//$("label[for=m_wlanUISecurityType1").css("display","none");
		//$("input[id=m_wlanUISecurityType1").css("display","none");
		//$("#m_wlanUISecurityType4").css('display','none');
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
/*
	if( (ssidIdx == '0' || ssidIdx =='100') && is_kt_SOHOZoneEnabled() == true && getUserPrivilege() == 3 ){
	//보안설정중 None Disable
	$("input[name='wlanUISecurityType'][value='0']").attr("disabled", "disabled");
	$("input[name='wlanSSID']").attr("readonly", "readonly");
	}
*/      //2014.07,06 [LJH] 홈허브2 소호존 모드

	kt_keypolicy_setCfg_orgInfo();
}

function onClick_WLAN_mobile_SecurityType(){
	var org = '' + conv2UI_WLAN_SecurityType($("#wlanSecurityMode").val());
	var sel = $("input[name='wlanUISecurityType']").val();
	var wlanPSKKey_backup = $("#wlanWEPPSKKey_backup").val();

	if( sel == '0' ){               //None
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlanView8021x").hide();
	}else if( sel == '1' ){ //WEP
		$("#wlanViewWEP").show();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlanView8021x").hide();
	}else if( sel == '2' ){ //PSK
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").show();
		$("#wlanViewPSK1").show();
		$("#wlanViewPSK2").show();
		$("#wireless_wlanUIPSKKey").show();
		$("#wlanView8021x").hide();
	}else if( sel == '3' ){ //WPA-Enterprise
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").show();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlanView8021x").hide();
	}else if( sel == '4' ){ //802.1x
		$("#wlanViewWEP").hide();
		$("#wlanViewWPA").hide();
		$("#wlanViewPSK1").hide();
		$("#wlanViewPSK2").hide();
		$("#wireless_wlanUIPSKKey").hide();
		$("#wlanView8021x").show();
	}

	//인증방식이 변경된 경우 재설정
	//set default radio
	if( sel != org && sel != '0' ){
		if( sel == '1' ){       //WEP
			setwlanUIWEPEncType('2');
			setwlanUIWEPKeyLen('0');
			setwlanWEPKeyType('1');
			setwlanWEPKeyIndex('0');

			$("#wlanUIWEPKey0").val("");
			$("#wlanUIWEPKey1").val("");
			$("#wlanUIWEPKey2").val("");
			$("#wlanUIWEPKey3").val("");
		}else if( sel == '2' ){ //PSK
			setwlanUIWPAType('2');
			setwlanUIWPAEncType('2');
			setwlanUIPSKKeyType('0');

			$("#wlanUIPSKKey").val(wlanPSKKey_backup);
		}else if( sel == '3' ){ //Enterprise
			setwlanUIWPAType('0');
			setwlanUIWPAEncType('0');
			setwlanUIPSKKeyType('0');

			$("#wlanUIPSKKey").val("");
		}else if( sel == '4' ){ //802.1x
			setwlanWEPRekeyEnable('0');
			setwlanMACAuthEnable('1');
		}
	}
}

function validateOnSubmit_WLAN_mobile_SecurityType(){
	var ret = false;
	ret = validateSecurityInputTextForm();
	if( ret == false ){
		return ret;
	}
	ret = web2cfg_WLAN_mobile_Security();
	return ret;
}

function web2cfg_WLAN_mobile_Security(){
	var wlanUISecurityType = $("input[name='wlanUISecurityType']").val();
	var wlanSecurityMode = '0';
	var bWPAEnable = 0;

	if( wlanUISecurityType == '0' ){        //None
		wlanSecurityMode = '0';
	}else if( wlanUISecurityType == '1' ){  //WEP
		var wlanUIWEPEncType = $("input[name='wlanUIWEPEncType']").val(); 
		if( wlanUIWEPEncType == '0' ){                  //Open
			wlanSecurityMode = '1';
		}else if( wlanUIWEPEncType == '1' ){    //Shared
			wlanSecurityMode = '2';
		}else if( wlanUIWEPEncType == '2' ){    //Auto
			wlanSecurityMode = '3';
		}

		if( validate_WLAN_mobile_Security_wepkey() == false ) return false;
		else{
			var wlanWEPKeyIndex = $("#wlanWEPKeyIndex").val();
			var keyName = "wlanUIWEPKey"+wlanWEPKeyIndex;

			initTextById( "wlanWEPKey", document.getElementById(keyName).value );
		}

		initTextById( "wlanEncType", '1' );             //WEP Only
	}else if( wlanUISecurityType == '2' ){  //WPA-PSK
		var wlanUIWPAType = $("input[name='wlanUIWPAType']").val();
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

		if( validate_WLAN_mobile_Security_pskkey() == false ) return false;
		else{
			initTextById( "wlanPSKKey", document.getElementById("wlanUIPSKKey").value );
		}
		initTextById( "wlanEncType", $("input[name='wlanUIWPAEncType']").val() );

		bWPAEnable = 1;
	}else if( wlanUISecurityType == '3' ){  //WPA-Enterprise
		var wlanUIWPAType = $("input[name='wlanUIWPAType']").val();
		if( wlanUIWPAType == '0' ){                     //WPA
			wlanSecurityMode = '7';
		}else if( wlanUIWPAType == '1' ){       //WPA2
			wlanSecurityMode = '8';
		}else if( wlanUIWPAType == '2' ){       //WPA/WPA2
			wlanSecurityMode = '9';
		}

		initTextById( "wlanEncType", $("input[name='wlanUIWPAEncType']").val() );

		bWPAEnable = 1;
	}else if( wlanUISecurityType == '4' ){  //802.1X
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

function validate_WLAN_mobile_Security_wepkey(){
	var nSuccess = 0;
	var wepKeyTypeValue = $("input[name='wlanWEPKeyType']").val();
	var wepKeyLen = $("input[name='wlanUIWEPKeyLen']").val();
	var wlanWEPKeyIndex = $("#wlanWEPKeyIndex").val();

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

function validate_WLAN_mobile_Security_pskkey(){
	return validate_psk(document.getElementById("wlanUIPSKKey"),
		$("input[name='wlanUIPSKKeyType']").val());
}
