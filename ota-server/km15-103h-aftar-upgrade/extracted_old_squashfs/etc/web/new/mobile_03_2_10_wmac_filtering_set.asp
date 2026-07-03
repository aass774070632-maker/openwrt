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
<script language="JavaScript" type="text/javascript" src="/script/mcr_table.js?version=<% mcr_getWebVersion(); %>"></script>

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
	document.form_accessCtrl.action = "/goform/mcr_KTlogOut";
	document.form_accessCtrl.submit();
}

<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var maxCount = 0;
var maxAccessCount = 0;
var radiusUse = 0;
var accessPolicy = 0;
var selectedSSIDIndex = 0;
var nModifySSID = -1;
var prevSSID = -1;

var arrData = new Array();

var cookieTime = 20;

var tableRule = null;

var gUserPrivilege;

function getSelectedSSIDIndex(){
	var selSSID = $("input[name='ssid']").val();
	var selectedSSID = parseInt( gWlanIfIndex ) + parseInt( selSSID );
	return selectedSSID;
}


function onClickRefresh(){
	var selectedSSID = getSelectedSSIDIndex();

	httpRequest("/goform/mcr_getWirelessAccessCtrl", "wlanIfIndex="+gWlanIfIndex+"&wlanSSID="+selectedSSID, processHttpResponse);
}


function onClickAdd(){
	var e = document.getElementById("macAddr");
	var bDuplicated = false;

	if( isMacAddress(e.value) == false ){
		alert("잘못된 MAC 주소입니다");
		e.focus();
		return false;
	}

	if( maxCount > maxAccessCount ){
		alert("설정 갯수를 초과하였습니다");
		return false;
	}

	for( var i=0; i<maxCount; i++ ){
		if( arrData[i] == e.value.toUpperCase() ){
			bDuplicated = true;
		}
	}
	if( bDuplicated ){
		alert("동일한 정보가 이미 설정되어 있습니다");
		return false;
	}

	arrData[maxCount] = e.value.toUpperCase();
	maxCount++;

	initForms(2, selectedSSIDIndex);

	nModifySSID = selectedSSIDIndex;
	return true;
}


function onButtonDel(){
	if( maxCount > 0 ){
		var strMacList = "";
		strMacList = updateMacToMacList(0);

		var arrMac = strMacList.split(",");

		maxCount = 0;
		arrData = new Array();
		for( var i = 0; i < arrMac.length; i++ ){
			if( arrMac[i].length > 0 ){
				arrData[maxCount] = arrMac[i];
				maxCount++;
			}
		}

		initForms(2, selectedSSIDIndex);

		nModifySSID = selectedSSIDIndex;
	}
}



function validateOnSubmit_apply(){
	mergeAccessCtrlTarget();


	return true;
}


function validateOnSubmit_applyMAC(){
	updateMacToMacList(0);


	return true;
}


function parseData(nRow, aColumns, aRow, strSplit){
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;

	if( aColumns[0].type & MCRColumn.TYPE_CHECKBOX ){
		var aCheckElement = new Array(2);
		aCheckElement[0] = aColumns[0].name+"_"+nRow;   
		aCheckElement[1] = "1"; 

		arrCol[0] = aCheckElement;
		nOffset = 1;
	}

	arrCol[1] = aRow;

	return arrCol;
}


function initTable(){
	var strTableAttr = "align='center' border='0' cellspacing='0' cellpadding='0' width='100%' valign='middle' id='Grid_Table' style='table-layout:fixed;'";
	var strTableTr = "";
	var strTableTh = "";
	var strTableTd = "style=word-break:break-all";

	tableRule = new MCRTable("view_stalist",
			MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
			strTableAttr,
			"",
			strTableTr,
			"등록된 MAC이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_CHECKBOX, "delmac", "", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC List", "", strTableTh, strTableTd, "");
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


function processHttpResponse(strResponse){
	var rowOnly = 5;
	var lineArr = strResponse.split("\n");

	arrData.length = 0;

	selectedSSIDIndex = parseInt(lineArr[0], 10);
	maxAccessCount = parseInt(lineArr[1], 10);
	maxCount = parseInt(lineArr[2], 10);
	radiusUse = parseInt(lineArr[3], 10);
	accessPolicy = parseInt(lineArr[4], 10);

	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 1 ){
			arrData[row] = lineArr[row+rowOnly];
		}
	}

	updateMacToMacList(1);

	initForms(1, selectedSSIDIndex);
}


function updateFormValue(flag){
	if( flag == 1 ){
		$("#raidusMacFilter").val( radiusUse );
	}
	layoutStationList();
}


function updateMacToMacList(type){
	var strMacList = "";
	if( type == 1 ){
		for( var i=0; i<arrData.length; i++ ){
			strMacList+=arrData[i];
			strMacList+=",";
		}
	}else{
		for( var i=0; i<maxCount; i++ ){
			var e = document.getElementById("delmac_"+i);
			if( e != null && e.checked == false ){
				strMacList+=arrData[i];
				strMacList+=",";
			}
		}
	}
	initTextById("macList", strMacList);

	return strMacList;
}


function updateAccessCtrlTarget(accessCtrlTarget, nPhyIndex){
	$("#wlanAccessCtrlTarget").val(accessCtrlTarget);       

	var nWlanAccessCtrlTarget = parseInt( accessCtrlTarget, 10 );
	for( var i = 0; i < 4; i++ ){
		nIfIndex = mcr_getWlanIfIndex(nPhyIndex, i);

		if( (nWlanAccessCtrlTarget & (1 << i)) != 0 ){
			if(i == 0){
				$('label[for=uiTarget_0]').addClass('ui-btn-active-c');
			}
			$("#uiTarget_"+i).attr("checked", true).checkboxradio("refresh");
		}
	}
}


function mergeAccessCtrlTarget(){
	var i;
	var wlanAccessCtrlTarget;

	wlanAccessCtrlTarget = 0;
	for( i=0; i<4; i++ ){

		var e = document.getElementById("uiTarget_"+i);
		if( e != null && e.checked == true ){
			wlanAccessCtrlTarget += ( 1 << i );
		}
	}
	$("#wlanAccessCtrlTarget").val( wlanAccessCtrlTarget );

	return true;
}


function initForms(flag, defaultSSIDIndex){

	if( flag == 0 ){
		var wlanAccessCtrlTarget;


		if( defaultSSIDIndex != -1 ){
			setssid(defaultSSIDIndex);
		}

		wlanAccessCtrlTarget = '<% mcr_getCfgCommon("Wlan_AccessCtrlTarget", gWlanIfIndexEJ); %>';
		updateAccessCtrlTarget(wlanAccessCtrlTarget, gWlanIfIndex);
	}else{
		updateFormValue(flag);
	}
	$('label[for=m_ssid]').hide();
	$("input[name='m_ssid']").hide();

}


function checkTarget(){
	var sel = $("input[name='ssid']").val();
	var e = document.getElementById("uiTarget_"+sel);
	if( e != null && e.checked == true ){
		return true;
	}
	return false;
}


$(document).ready(function(){
	$("#btn_add").bind( "click", function(){
		if( $("input[name='ssid']").length == 0 ){
			alert("적용대상을 먼저 선택하세요");
			return false;
		}
		var ret = onClickAdd();
		if( ret == false ){
			return false;
		}
		validateOnSubmit_applyMAC();
	
		$('a[name=btn_add]').removeClass('ui-btn-active');
		$('a[name=btn_add]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessAccessCtrl');
		return true;
	});
	$("#btn_del").bind( "click", function(){
		onButtonDel();
		validateOnSubmit_applyMAC();
	
		$('a[name=btn_del]').removeClass('ui-btn-active');
		$('a[name=btn_del]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessAccessCtrl');
		return true;
	});
	
	$("#btn_apply2").bind( "click", function(){
		validateOnSubmit_apply();
	
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
		form_act('/goform/mcr_KT_setWirelessAccessCtrl');
		return true;
	});
	initValue();
});


function vendor_init(){
	gUserPrivilege = getUserPrivilege();
}

function initValue(){
	setMultiWlanInfo_KT(window.location, gWlanIfIndex );


	vendor_init();
	initForms(0, -1);
}


function setssid(ssid){
	var curSelect;
	switch(ssid){
		case '0':
			mcr_clickradio_ssid('0');
			$("input[id='m_ssid2']").attr("checked", true).checkboxradio("refresh");
			$("#ssid").val("0");
			break;
		default:
			break;
	}
	curSelect = $("input[name='ssid']").val();

	if( nModifySSID != -1 && nModifySSID != curSelect ){
		var answer = confirm("적용대상 변경시 수정사항이 사라집니다. 계속하시겠습니까?");
		if( answer == 0 ){
			if( prevSSID != -1 ){
				setssid(prevSSID);
			}
			return false;
		}
	}

	var targetAvail = checkTarget();
	if( targetAvail == true ){
		onClickRefresh();

		prevSSID = curSelect;
		return true;
	}else{
		alert("필터링 대상이 아닙니다");

		if( prevSSID != -1 ){
			$("input[name='ssid']").val( [''+prevSSID] );
		}
		return false;
	}	


}

function mcr_clickradio_ssid(val){
	$('label[for=m_ssid2]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_ssid2]').addClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function mcr_clickradio_uiTarget(){
	var Enable = $("input[id='uiTarget_0']:checked").val();
	if(Enable == "on"){
		$('label[for=uiTarget_0]').addClass('ui-btn-active-c');
//		$("input[id='uiTarget_0']").attr("checked", true).checkboxradio("refresh");
	}else{
		$('label[for=uiTarget_0]').removeClass('ui-btn-active-c');
//		$("input[id='uiTarget_0']").attr("checked", false).checkboxradio("refresh");
	}
}

function form_act(url){
	parent.mcrProgress.startProgressSimple("apply",30);
	form_accessCtrl.action = url;
	form_accessCtrl.submit();
	return false;
}

</script>

</head>
<body>
<form method="post" name="form_accessCtrl" data-ajax="false">

<input type="hidden" name="ssid" id="ssid" value="">


<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value="">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/mobile_03_2_10_wmac_filtering_set.asp">

<input type="hidden" id="raidusMacFilter" name="raidusMacFilter" value="">
<input type="hidden" id="macList" name="macList" value="">

<input type="hidden" id="wlanAccessCtrlTarget" name="wlanAccessCtrlTarget" value="">  

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
					무선 MAC 필터링 설정
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

	<div style="padding:0 5 12 5px;">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>필터링 대상 선택</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="uiTarget_0">Home WLAN</label>
									<input type="checkbox" name="uiTarget_0" id="uiTarget_0" onclick="mcr_clickradio_uiTarget()">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:;" id="btn_apply2" name="btn_apply2" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
			</tr>
			<tr>
				<td>적용 대상</td>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_ssid2">Home WLAN</label>
									<input type="radio" name="m_ssid" id="m_ssid2" value="0" onclick="setssid(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>허용 MAC 주소</td>
				<td>
					<input type="text" name="macAddr" id="macAddr">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<a href="javascript:;" id="btn_add" name="btn_add" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col>
									<col>
									<tr>
										<td>선택</td>
										<td>MAC List</td>
									</tr>
								</span>
							</td>
						</tr>
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<div id="view_stalist"></div>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_del" name="btn_del" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="/mobile.asp#thirdPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
