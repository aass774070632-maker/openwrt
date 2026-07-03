<html>
<head>
<%include('new/metatag.asp');%>
<title>무선 MAC 필터링 설정</title>
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

function getSelectedSSIDIndex(){
	var selSSID = $("input[name='ssid']:checked").val();
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

	parent.mcrProgress.startProgressSimple("apply", 20);

	return true;
} 

function validateOnSubmit_applyMAC(){
	updateMacToMacList(0);

	parent.mcrProgress.startProgressSimple("apply", 20);
	
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
	var strTableAttr = "id='Grid_Table' width='766' border='0' cellpadding='0' cellspacing='1' style='table-layout:fixed;' bgcolor='#FFFFFF'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "";
	var strTableTd = "class='BG2-2'";
	
	tableRule = new MCRTable("view_stalist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
		strTableAttr,
		"",
		strTableTr, 
		"등록된 MAC이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_CHECKBOX, "delmac", "width='35'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC List", "width='679'", strTableTh, strTableTd, "");
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
			$("#uiTarget_"+i).attr("checked", "checked");
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
		$("#wlanUIMenu03").removeClass("menu3rdNormal").addClass("menu3rdSelect");
		
		if( defaultSSIDIndex != -1 ){
			$("input[name='ssid']").val( [''+defaultSSIDIndex] );
			$("input[name='ssid']:checked").trigger("change");
		}
		
		wlanAccessCtrlTarget = '<% mcr_getCfgCommon("Wlan_AccessCtrlTarget", gWlanIfIndexEJ); %>';
		updateAccessCtrlTarget(wlanAccessCtrlTarget, gWlanIfIndex);
		
			$("#filter_item1").hide();
			$("#filter_item2").hide();
			$("#filter_item3").hide();
			$("#filter_item4").show();
			$("#filter_item5").hide();
			$("#filter_item6").hide();
			$("#filter_item7").hide();
			$("#filter_item8").show();
	}else{
			$("#filter_item1").hide();
			$("#filter_item2").hide();
			$("#filter_item3").hide();
			$("#filter_item4").show();
			$("#filter_item5").hide();
			$("#filter_item6").hide();
			$("#filter_item7").hide();
			$("#filter_item8").show();
		updateFormValue(flag);
	}
	
	changeTableAdmin();	
}

function checkTarget(){
	var sel = $("input[name='ssid']:checked").val();
	var e = document.getElementById("uiTarget_"+sel);
	if( e != null && e.checked == true ){
		return true;
	}
	return false;
}

$(document).ready(function(){

	$("input[name='ssid']").bind( "click", function(){
		var curSelect = $("input[name='ssid']:checked").val();

		if( nModifySSID != -1 && nModifySSID != curSelect ){
			var answer = confirm("적용대상 변경시 수정사항이 사라집니다. 계속하시겠습니까?");
			if( answer == 0 ){
				if( prevSSID != -1 ){
					$("input[name='ssid']").val( [''+prevSSID] );
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
	});
	
	$("#btn_add").bind( "click", function(){
		if( $("input[name='ssid']:checked").length == 0 ){
			alert("적용대상을 먼저 선택하세요");
			return false;
		}
		var ret = onClickAdd();
		if( ret == false ){
			return false;
		}
		validateOnSubmit_applyMAC();
		return true;
	});
	$("#btn_del").bind( "click", function(){
		onButtonDel();
		validateOnSubmit_applyMAC();
		return true;
	});
	
	$("#btn_apply").bind( "click", function(){
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

function initValue(){

	setMultiWlanInfo_KT(window.location, gWlanIfIndex );

	parent.mcrProgress.stopProgress();
	initForms(0, -1);

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
<form method="post" class="form_layout" id="form_accessCtrl" name="form_accessCtrl" action="/goform/mcr_KT_setWirelessAccessCtrl">

<input type="hidden" id="wlanIfIndex" name="wlanIfIndex" value=""/>
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value=""/>

<input type="hidden" id="raidusMacFilter" name="raidusMacFilter" value="" />
<input type="hidden" id="macList" name="macList" value="" />

<input type="hidden" id="wlanAccessCtrlTarget" name="wlanAccessCtrlTarget" value="" />

<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">

			<%include('new/UserFolder/3_2_menu3rd.asp');%>

        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> 무선 MAC 필터링 설정</td>
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
											<td class="BG2" style="width:140px;">필터링 대상 선택</td>
											<td class="BG2-2">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="100%">
													<tr id="filter_item">
														<td id="filter_item1" width="130" style="display:none">
															<input type="checkbox" name="uiTarget_2" id="uiTarget_2" value='2'/>ollehWiFi(Basic)
														</td>
														<td id="filter_item2" width="110" style="display:none">
															<input type="checkbox" name="uiTarget_3" id="uiTarget_3" value='3'/>ollehWiFi
														</td>
														<td id="filter_item3" width="110" style="display:none; float;">
															<input type="checkbox" name="uiTarget_1" id="uiTarget_1" value='1'/>SoIP
														</td>
														<td id="filter_item4">
															<input type="checkbox" name="uiTarget_0" id="uiTarget_0" value='0'/>Home WLAN
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
      
							<tr>
								<td class="PD6"><input type="image" id="btn_apply" name="btn_apply" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" /></td>
							</tr>
							<tr>
								<td>　</td>
							</tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td class="BG2" style="width:140px;">적용 대상</td>
											<td class="BG2-2">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr id="filter_item_1">
														<td id="filter_item5" width="130" style="display:none">
															<input type="radio" name="ssid" value='2'/>ollehWiFi(Basic) 
														</td>
														<td width="110" id="filter_item6" style="display:none">
															<input type="radio" name="ssid" value='3'/>ollehWiFi
														</td>
														<td width="110" id="filter_item7" style="display:none; float;">
															<input type="radio" name="ssid" value='1'/>SoIP
														</td>
														<td id="filter_item8">
															<input type="radio" name="ssid" value='0'/>Home WLAN
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td class="BG2" style="width:140px;">허용 MAC 주소</td>
											<td class="BG2-2">
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="150">
															<input type="text" name="macAddr" id="macAddr" />
														</td>
														<td>
															<input id='btn_add' name='btn_add' type='image' src="/images/BTN/BTN_03.gif?Sp2" width="52" height="24" value="Add"/>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6">
									<table class="TB" width="100%" border="0">
										<tr height="20">
											<td width=100%" >
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
															<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																<col width="35">
																<col width="695">
		 
																<tr height="20">
																	<td class="BG1">선택
																	</td>
																	<td class="BG1">
																		MAC List
																	</td>
																</tr>
															</table>
															</span>
														</td>
														<td id="lastTD" style="display:none;">
															<table width="100%" border="0" cellpadding="0" cellspacing="0" style="table-layout:fixed;">
																<tr height="20" width="100%">
																	<td class="BG1">&nbsp;</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>
		 
										<tr height="200">
											<td width="100%" valign="top">
												<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
												<div id="view_stalist"></div>
												</span>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="97%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="PD6" valign="top">
						<input id='btn_del' name='btn_del' type='image' src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" value="Del"/>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
