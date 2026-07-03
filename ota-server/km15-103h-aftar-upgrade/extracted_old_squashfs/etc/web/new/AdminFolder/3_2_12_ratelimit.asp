<html>
<head>
<%include('new/metatag.asp');%>
<title>Wireless RateLimit</title>
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
<script language="javascript" type="text/javascript">

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
var gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var maxCount = 0;
var maxAccessCount = 0;
var maxRateLimitCount = 0;
var rateLimitType = 0;
var rateLimitDownload = 0;
var rateLimitUpload = 0;

var arrDataSSID = new Array();
var arrData = new Array();

var tableRule = null;

var cookieTime = 20;

checkWirelessActivity();

function checkWirelessActivity(){
	var radioActivity = '<% mcr_getCfgWireless("Wlan_Enable", gWlanIfIndexEJ); %>';	
	if( radioActivity == '0' ){
		alert("무선설정이 Disable되어 있습니다.");
		
		var strURL = generateMultiWlanURL(null, gWlanIfIndex, true, "/new/AdminFolder/3_2_8_home_wlan_connection.asp" );
		window.location.href = "http://"+window.location.host+ strURL;
	}
}

function getSelectedSSIDIndex(){
	var e = document.getElementById("ssid");
	return e[e.selectedIndex].value;
}
function onClickRefresh(){
	var selectedSSID = getSelectedSSIDIndex();

	httpRequest("/goform/mcr_getWirelessRateLimit", "wlanIfIndex="+gWlanIfIndex+"&wlanSSID="+selectedSSID, processHttpResponse);
}

function onButtonAdd(){
	var strMac = $("#macAddr").val();
	var strDesc = $("#desc").val();
	var bDuplicated = false;
	
	if( strMac == "" && strDesc == "" )
		return true;

	if( isMacAddress(strMac) == false ){
		alert("잘못된 MAC 주소입니다");
		return false;
	}

	if( maxCount > maxAccessCount ){
		alert("설정 갯수를 초과하였습니다");
		return false;
	}

	for( var i=0; i<maxCount; i++ ){
		var items = arrData[i].split("\r");	
		if( strMac.toUpperCase() == items[1] ){
			bDuplicated = true;
			break;
		}
	}
	if( bDuplicated ){
		alert("동일한 정보가 이미 설정되어 있습니다");
		return false;
	}
		
	arrData[maxCount] = "1\r"+strMac.toUpperCase()+"\r"+strDesc;
	maxCount++;
		
	layoutStationList();

	$("#macAddr").val("");
	$("#desc").val("");

	return true;
}

function onButtonDel(){
	if( maxCount > 0 ){
		var delcount = 0;
		var arrDataNew = new Array();
		for( var i=0, j=0; i<maxCount; i++ ){
			var e = document.getElementById("delmac_"+i);
			if( !(e != null && e.checked == true) ){
				arrDataNew[j] = arrData[i];
				j++;
			}else{
				delcount++;
			}
		}

		if( delcount > 0 ){
			arrData.length = 0;

			for( var i=0; i < j; i++ ){
				arrData[i] = arrDataNew[i];
			}
			maxCount = j;

			layoutStationList();
			return true;
		}
	}
	return false;
}

function addHidden(theForm, strid, strkey, strvalue) {
	$('<input>').attr({
	    type: 'hidden',
	    id: strid,
	    name: strkey,
	    value: strvalue
	}).appendTo('form');
}

function setMacList(){
	for( var i=0; i<maxCount; i++ ){
		var items = arrData[i].split("\r");	
		var strEnable = "enable_"+i;
		var strMac    = "mac_"+i;
		var strDesc   = "desc_"+i;
		addHidden("form_rateLimit", strEnable, strEnable, items[0]);
		addHidden("form_rateLimit", strMac, strMac, items[1]);
		addHidden("form_rateLimit", strDesc, strDesc, items[2]);
	}
}

function validateRateLimit(){
	var valType = parseInt(  $("input[name='rateLimitType']:checked").val() );
	
	if( valType != 0 ){
		var valueDown = parseInt( $("#rateLimitDownload").val() );
		var valueUpload = parseInt( $("#rateLimitUpload").val() );
		
		if( valueDown < 0 || valueDown > 1000 ){
			setFocusById("rateLimitDownload");
			alert( "download 속도 range 오류");
			return false;
		}
		if( valueUpload < 0 || valueUpload > 1000 ){
			setFocusById("rateLimitUpload");
			alert( "upload 속도 range 오류");
			return false;
		}
	}

	return true;
}

function validateOnSubmit(commandType){
	if( validateRateLimit() == false ){
		return false;
	}

	if( commandType == "add" ){
		if( onButtonAdd() == false ){
			return false;
		}
	}else if( commandType == "del" ){
		if( onButtonDel() == false ){
			return false;
		}
	}

	setMacList();

	var selectedSSID = getSelectedSSIDIndex();
	setCookie("ratelimit_ssid", selectedSSID, cookieTime, "", "", "");
	
	parent.mcrProgress.startProgressSimple("apply", 27);
	return true;
}

function onChangeRateLimitType(){
	var rateLimitTypeVal = $("input[name='rateLimitType']:checked").val();
	
	if( rateLimitTypeVal == '0' ){

		$("#rateLimitDownload").prop("disabled",true);
		$("#rateLimitUpload").prop("disabled",true);
		$("#rateLimitDownload").val("0");
		$("#rateLimitUpload").val("0");

	}else if( rateLimitTypeVal == '1' ){

		$("#rateLimitDownload").prop("disabled",false);
		$("#rateLimitUpload").prop("disabled",false);

	}else if( rateLimitTypeVal == '2' ){

		$("#rateLimitDownload").prop("disabled",false);
		$("#rateLimitUpload").prop("disabled",false);

	}
	$("#macAddr").prop("disabled",true);
	$("#desc").prop("disabled",true);
}

$(document).ready(function(){
	$("input[name='rateLimitType']").bind( "change", function(){
		onChangeRateLimitType();
		return true;
	});

	$("#btn_refresh").click(function(){
		onClickRefresh();
		return false;
	});
	$("#btn_delete").click(function(){
		if( validateOnSubmit("del") == false ){
			return false;
		}
		return true;
	});
	$("#btn_add").click(function(){
		if( validateOnSubmit("add") == false ){
			return false;
		}
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

function initForms(flag, defaultSSIDIndex){
	if( defaultSSIDIndex == -1 ){
		var cookieSSID = getCookie("ratelimit_ssid");
		if( cookieSSID != null ){
			defaultSSIDIndex = parseInt(cookieSSID, 10);
		}
	}
	
	if( flag == 0 ){
		$("#wlanUIMenu22").removeClass("menu3rdNormal").addClass("menu3rdSelect");

		httpRequest("/goform/mcr_getWirelessSSID?wlanIfIndex="+gWlanIfIndex, "n/a", processHttpResponseSSID);
	}else if( flag == 1 ){
		updateMBSSIDList(defaultSSIDIndex);
		updateFormValue(1);
		onClickRefresh();
	}else if( flag == 2 ){
		updateFormValue(1);
	}else if( flag == 3 ){
		updateFormValue(0);
	}

	onChangeRateLimitType();
	changeTableAdmin();
}

function initValue(){
	setMultiWlanInfo(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();

	initForms(0, -1);
}

function updateFormValue(useDefault){
	layoutStationList();
	
	if( useDefault == 1 ){
		initRadioByName("rateLimitType", ""+rateLimitType);
		initTextById("rateLimitDownload", ""+rateLimitDownload);
		initTextById("rateLimitUpload", ""+rateLimitUpload);

	}
}

function updateMBSSIDList(defaultSSIDIndex){
	var j = 0;
	var ssidIndex = 0;
	var ssidElement = document.getElementById("ssid");
	if( defaultSSIDIndex == -1 ) defaultSSIDIndex = 0;
	ssidElement.length = 0;
	for(var i=0; i<maxSSID; i++){
			ssidIndex = parseInt(arrDataSSID[i][0], 10);
			ssidElement.options[j] = new Option(arrDataSSID[i][1], parseInt(arrDataSSID[i][0], 10));
			if( ssidIndex == defaultSSIDIndex ){
				ssidElement.options[j].selected = true;
			}	
			j++;
	}
} 

function processHttpResponseSSID(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split("\n");
	maxSSID = parseInt(lineArr[0], 10);

	arrDataSSID.length = 0;
	
	for( var row=0; row < lineArr.length-rowOnly; row++){
		var strField = lineArr[row+rowOnly].split("\r");
		if( strField.length > 1 ){
			arrDataSSID[row] = strField;
		}
	}
	if( arrDataSSID.length > 0 ){
	initForms(1, -1);
	}
}


function processHttpResponse(strResponse){
	var rowOnly = 6;
	var lineArr = strResponse.split("\n");

	maxCount = 0;
	arrData.length = 0;

	selectedSSIDIndex = parseInt(lineArr[0], 10);
	maxRateLimitCount = parseInt(lineArr[1], 10);
	maxAccessCount = parseInt(lineArr[2], 10);
	rateLimitType = parseInt(lineArr[3], 10);
	rateLimitDownload = parseInt(lineArr[4], 10);
	rateLimitUpload = parseInt(lineArr[5], 10);
		
	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 0 ){
			var items = lineArr[row+rowOnly].split("\r");	
			if( items[1] != "00:00:00:00:00:00"){			
				arrData[row] = lineArr[row+rowOnly];
				maxCount++;				
			}
		}
	}
	initForms(2, selectedSSIDIndex);
}


function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;
	var strDelId = "delmac_"+nRow;
	var strEnableId = "enable_"+nRow;
	var strMacId = "mac_"+nRow;
	var strDescId = "desc_"+nRow;

	arrCol[0] = "<input type='checkbox' id='"+strDelId+"' name='"+strDelId+"' value='1'></input>";

	arrCol[1] = items[1];

	if( items[2] == "null" ){
		arrCol[2] = "";
	}else{
		arrCol[2] = items[2];	
	}
	return arrCol;
}

function initTable(){
	var strTableAttr = "class='TB' border='0' bgcolor='#FFFFFF' width='766' ";
	var strTableHeaderTr = "class='BG2-2'" 
	var strTableTr = "class='BG2-2'";
	var strTableTh = "class='BG1'";
	var strTableTd = "align='left' class='BG2-2'";

	tableRule = new MCRTable("view_stalist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_TH,
		strTableAttr,
		strTableHeaderTr,
		strTableTr,
		"등록된 MAC이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "선택", "", strTableTh + " width='30'", strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC List", "", strTableTh +" width='140'", strTableTd +" align='center'", "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "설명", "", strTableTh +" width='600'", strTableTd, "");
}

function layoutStationList(){
	if( tableRule == null ){
		initTable();
	}
	if( tableRule != null ){
		tableRule.setRows(arrData);
		tableRule.layout();
	}
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
<form method="post" id="form_rateLimit" name="form_rateLimit" action="/goform/mcr_setWirelessRateLimit">
<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>

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
								<td class="font5"> 속도제한 설정</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1" bgcolor="#ffffff">
										<tr>
											<td>
												<table class="TB" width="100%" border="0">
													<tr>
														<td class="BG2" width="140">SSID(네트워크이름)</td>
														<td class="BG2-2" colspan="3">
															<select id="ssid" name="ssid">
															</select>
																<input type="image" src="/images/BTN/BTN_13.gif?Sp2" width="71" height="24" value="Refresh" id="btn_refresh" name="btn_refresh"style="margin-bottom:-7px">
														</td>
													</tr>
													<tr>
														<td class="BG2" width="140">속도 제한 Type</td>
														<td class="BG2-2" colspan="3">
															<input type="radio" name="rateLimitType" value="0"><label>비활성</label></input>
															<input type="radio" name="rateLimitType" value="1" disabled><label>단말별</label></input>
															<input type="radio" name="rateLimitType" value="2"><label>SSID별</label></input>
														</td>
													</tr>
													<tr>
														<td class="BG2" id="lbl_rateLimitDownload" width="140">Download 속도</td>
														<td class="BG2-2" colspan="3">
															<input type="text" id="rateLimitDownload" name="rateLimitDownload" size="7" maxlength="7" value=""></input>
															<label>Mbps</label>
														</td>
													</tr>
													<tr>
														<td class="BG2" id="lbl_rateLimitUpload" width="140">Upload 속도</td>
														<td class="BG2-2" colspan="3">
															<input type="text" id="rateLimitUpload" name="rateLimitUpload" size="7" maxlength="7" value=""></input>
															<label>Mbps</label>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">제한 MAC 주소</td>
														<td class="BG2-2">
															<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
																<tr>
																	<td width="200">
																		주소
																		<input type="text" name="macAddr" id="macAddr"/>
																	</td>
																	<td width="250">
																		설명
																		<input type="text" name="desc" id="desc" size="32" maxlength="60"/>
																	</td>
																	<td align="left">
																		<input id='btn_add' name='btn_add' type='image' src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" value="Add"/>
																	</td>
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
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr id="view_sta_info" style="display:inline">
								<td>
									<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1" bgcolor="#ffffff">
										<tr>
											<td>
												<div>
													<div id="view_stalist"></div>
												</div>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<input type="image" src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" value="Delete" id="btn_delete" name="btn_delete"/>
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
