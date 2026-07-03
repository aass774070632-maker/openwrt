<html>
<head>
<%include('new/metatag.asp');%>
<title>WPS 설정</title>
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



<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';
<%
	var gWlanSSID2ndIndexEJ;
	if ( gWlanIfIndexEJ == '0' )
		gWlanSSID2ndIndexEJ = '0';
	else
		gWlanSSID2ndIndexEJ = '100';
%>


function initForm_WLAN_WPS(flag){
	var wlanUserPriority;
	var wlanWPSActivity, wlanWPSMode;
	var wlanSSIDIdx, wlanUIPINSelf, wlanUIConfigured;
	
	var wlanSSID_0, wlanSecurityMode_0, wlanEncType_0, wlanWEPPSKKey_0;
	var wlanSSID_1, wlanSecurityMode_1, wlanEncType_1, wlanWEPPSKKey_1;

	if( flag == 0 ){
		wlanUserPriority = '7';	
		wlanWPSActivity = '<% mcr_getCfgWireless("Wlan_Wps_WpsEnable", gWlanIfIndexEJ); %>';
		wlanWPSMode = '<% mcr_getCfgWireless("Wlan_Wps_WpsMode", gWlanIfIndexEJ); %>';
		wlanSSIDIdx = '<% mcr_getCfgWireless("Wlan_Wps_SSIDIdx", gWlanIfIndexEJ); %>';
		wlanUIPINSelf = '<% mcr_getCfgWireless("Wlan_Wps_PINSelf", gWlanIfIndexEJ); %>';
		wlanUIConfigured = '<% mcr_getCfgWireless("Wlan_Wps_Configured", gWlanIfIndexEJ); %>';

		wlanSSID_0 = '<% mcr_getCfgWireless("Wlan_SSID", gWlanIfIndexEJ); %>';
		wlanSecurityMode_0 = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanIfIndexEJ); %>';
		wlanEncType_0 = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanIfIndexEJ); %>';
		wlanWEPPSKKey_0 = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanIfIndexEJ); %>';
		
		wlanSSID_1 = '<% mcr_getCfgWireless("Wlan_SSID", gWlanSSID2ndIndexEJ); %>';
		wlanSecurityMode_1 = '<% mcr_getCfgWireless("Wlan_SecurityMode", gWlanSSID2ndIndexEJ); %>';
		wlanEncType_1 = '<% mcr_getCfgWireless("Wlan_EncryptType", gWlanSSID2ndIndexEJ); %>';
		wlanWEPPSKKey_1 = '<% mcr_getCfgWireless("Wlan_WEPPSKKey", gWlanSSID2ndIndexEJ); %>';
	}

	$("#wlanUIMenu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	$("#wlanUserPriority").val(wlanUserPriority);
	$("input[name='wlanWPSActivity']").val([wlanWPSActivity]);	
	$("#wlanUIPINSelf").text(wlanUIPINSelf);

	if( wlanSSIDIdx == '0' || wlanSSIDIdx == '100' ){
		cfg2web_WLAN_WPS_Security(
			"wlanUISecurityType", "wlanUIEncType", "wlanUIKey", wlanSecurityMode_0, wlanEncType_0, "●●●●●●●●●●");
	}else{
		cfg2web_WLAN_WPS_Security(
			"wlanUISecurityType", "wlanUIEncType", "wlanUIKey", wlanSecurityMode_1, wlanEncType_1, "●●●●●●●●●●");
	}

	if( wlanUIConfigured == '0' ){
		$("#wlanUIConfigured").text('Unconfigured');
	}else{
		$("#wlanUIConfigured").text('Configured');
	}
}

$(document).ready(function(){
	$("#wlanBtnPIN").click(function(){
		return validateOnSubmit_WLAN_WPS(null, "wlanWPSPIN");
	});
	$("#wlanBtnPBC").click(function(){
		validateOnSubmit_apply1();
		return true;
	});	
	$("#wlanBtnApply").click(function(){
		validateOnSubmit_apply();
		return true;
	});	
	$("#wlanBtnReset").click(function(){
		validateOnSubmit_apply();
		return true;
	});	
	
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

function validateOnSubmit_apply(){
	parent.mcrProgress.startProgressSimple("apply", 20);
	return true;
}
function validateOnSubmit_apply1(){
	parent.mcrProgress.startProgressSimple("apply", 20);
	return true;
}

function validateOnSubmit(){
	return validateOnSubmit_WLAN_WPS(null);
}

function initForms(flag){
	initForm_WLAN_WPS(flag);
}


function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();
	
	initForms(0);
	changeTableAdmin();
}
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
<form method="post" class="form_layout" id="form_wps" name="form_wps" action="/goform/mcr_KT_setWirelessWps">

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="">

<input type="hidden" id="wlanUserPriority" name="wlanUserPriority" value="">
	
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_2_menu3rd.asp');%>
			</td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> WPS 설정</td>
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
											<td rowspan="1" class="BG2" style="width:140px;">WPS 적용 대상</td>
											<td class="BG2-2" width="600">
												<table>
													<tr>
														<td width="70">
															<input type="radio" name="wlanWPSActivity" value="0">None
														</td>
														<td width="100">
															<input type="radio" name="wlanWPSActivity" value="1">Home WLAN
														</td>
														<td>
															<input type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" value="wlanBtnApply" id="wlanBtnApply" name="wlanBtnApply">
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">WPS 상태</td>
											<td class="BG2-2" width="600">
												<table>
													<tr>
														<td width="170">
															<label id="wlanUIConfigured"></label>
														</td>
														<td>
															<input type="image" src="/images/BTN/BTN_24.gif?Sp2" width="133" height="24" value="wlanBtnReset" id="wlanBtnReset" name="wlanBtnReset">
														</td>
													</tr>
												</table>
											</td>
										</tr>	  
										<tr>
											<td class="BG2" style="width:140px;">PBC 버튼</td>
											<td class="BG2-2" width="600">
												<input type="image" src="/images/BTN/BTN_17.gif?Sp2" width="71" height="24" value="wlanBtnPBC" id="wlanBtnPBC" name="wlanBtnPBC">
											</td>
										</tr>
											  
										<tr style="display:none;">
											<td class="BG2" style="width:140px;">AP PIN Number</td>
											<td class="BG2-2" width="600"><label id="wlanUIPINSelf"></label></td>
										</tr>
											  
										<tr style="display:none;">
											<td class="BG2" style="width:140px;">단말 PIN Number</td>
											<td class="BG2-2" width="600">
												<table>
													<tr>
														<td width="170">
															<input type="text" id="wlanWPSPIN" name="wlanWPSPIN">
														</td>
														<td>
															<input type="image" src="/images/BTN/BTN_16.gif?Sp2" width="71" height="24" value="wlanBtnPIN" id="wlanBtnPIN" name="wlanBtnPIN">
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td colspan="3" class="BG1">Current Key 정보</td>
										</tr>
										<tr>
											<td width="33%" class="BG5">Authentication</td>
											<td width="33%" class="BG5">Encryption</td>
											<td class="BG5">Key</td>
										</tr>
										<tr>
											<td class="BG2-3"><label id="wlanUISecurityType"></label></td>
											<td class="BG2-3"><label id="wlanUIEncType"></label></td>
											<td class="BG2-3" style="font-size:10px;"><label id="wlanUIKey"></label></td>
										</tr>
									</table>
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
