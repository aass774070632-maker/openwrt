<html>
<head>
<%include('new/metatag.asp');%>
<title>인터넷사용제한 설정</title>
<%include('new/script.asp');%>

<link href="/style/style.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
.TB-1{
	width:778px;
	table-layout:fixed;
}
</style>
<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>
<script language="javascript" type="text/javascript"></script>
<script> 

var gUserPrivilege;
var gProjectCode;
var entries_user = new Array();

var beforId = "menu04";

function mouseover(clickId){
	var obj = document.getElementById(clickId);
	obj.className="menu3rdMouse";

}

function mouseout(clickId)
{
	var obj = document.getElementById(clickId);
	if(beforId == clickId)
	{
		obj.className="menu3rdSelect";
	}
	else{
		obj.className="menu3rdNormal";
	}
}

function selectMenu3rd(){
	$("#menu04").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function changeTableAdmin()
{
	
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else{
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}
var tableRule = null;
var arrData = new Array();	
var arrData1 = new Array();	
var maxCount = 0;

var arrDays = new Array();
arrDays[0] = "일 ";
arrDays[1] = "월 ";
arrDays[2] = "화 ";
arrDays[3] = "수 ";
arrDays[4] = "목 ";
arrDays[5] = "금 ";
arrDays[6] = "토 ";

function getTimeStr(no){
	var str, hour, time;

	if( no/60 < 10 ){
		hour = "0"+ parseInt(no/60);
	}else{
		hour = ""+ parseInt(no/60);
	}
	if( (no % 60) < 10 ){
		time = ":"+ "0" + (no % 60);
	}else{
		time = ":"+ (no % 60);
	}
	str = hour + time;

	return str;	
}


function onClickSubmit(formElement){
	document.formElement.submit();
}

function onClickScheduleWeekAll(){
	var e = document.getElementById("week_7");
	var strName, obj, disable;

	if( e.checked == true ){
		for( var i = 0; i <= 6; i++ ){
			strName = "week_"+i;
			obj = document.getElementById(strName);
			obj.checked = false;
		}
	}
	

	return true;
}
function onClickScheduleWeekOne(){
	var e = document.getElementById("week_7");
	for(var i=0; i<=6; i++){
		strName = "week_"+i;
		obj = document.getElementById(strName);
		if(obj.checked == true){
			e.checked = false;
			break;
		}
	}
	return true;
			
}
function onClickScheduleTime(){
	
	var disable;
	
	if(form_netkeep.time24[0].checked == true){

		disable = true;
		
		document.getElementById("timeStart_hour").disabled = disable;
		document.getElementById("timeStart_min").disabled = disable;
		document.getElementById("timeEnd_hour").disabled = disable;
		document.getElementById("timeEnd_min").disabled = disable;
	}
	if(form_netkeep.time24[1].checked == true){
		disable = false;

		document.getElementById("timeStart_hour").disabled = disable;
		document.getElementById("timeStart_min").disabled = disable;
		document.getElementById("timeEnd_hour").disabled = disable;
		document.getElementById("timeEnd_min").disabled = disable;
	}


	return true;
}

function mergeRules(){
	var strList = "";
	for( var i=0; i<maxCount; i++ ){
		var e = document.getElementById("delRow_"+i);
		if( e != null && e.checked == false ){
			strList+=arrData[i];
			strList+=";";
		}
	}
	return strList;
}

function checkName( data ){
	var string = ",;";
	for( var i=0;i<data.length;i++){
		if( string.indexOf( data.charAt(i) ) == -1 ){
			return true;
		}
	}
	return false;
}

function onClickDel(){
	if( maxCount > 0 ){
		var strList = "";
		var netKeepInfo = "";
	
		strList = mergeRules();
		
		var arrList = strList.split(";");
		
		maxCount = 0;
		arrData = new Array();
		for( var i = 0; i < arrList.length; i++ ){
			if( arrList[i].length > 0 ){
				arrData[maxCount] = arrList[i];
				maxCount++;
			}
		}
		parent.mcrProgress.startProgressSimple('apply', 15);
		initForms(1);
	}
	return true;
}
  
function onClickSelectAll(){
	if( maxCount > 0 ){
		var e = document.getElementById("btn_selectAll");
		var newChecked = e.checked;
		
		for( var row = 0; row < maxCount; row++ ){
			var strElementName = "delRow_"+row;
			initCheckboxById(strElementName, newChecked);
		}
	}
}

function onClickAdd(){
	var e;
	var bDuplicated = false;
	var strRule,strRule1, i, strTemp;
	var valueWeek = 0;
	var tStart, tEnd;
	var tStart_hour, tStart_min, tEnd_hour, tEnd_min;
	var opmode = "<% mcr_getCfgString("SysOperMode_OperMode"); %>";	
	var NetKeepEn = "<% mcr_getCfgString("NetKeepCfgParam_Enable"); %>";	
	if(opmode == "0"){
		if(NetKeepEn == "0"){
			if(document.getElementById("radioActivity").value == "1"){
				alert("kt모드에서만 사용 가능합니다.");
				return false;
			}
		}
	}
	else{
		if( maxCount >= 64 ){
			alert("최대 설정 개수입니다");
			return false;
		}
	
		e = document.getElementById("rule_mac");
		if(isEmpty(e.value) == true){
			alert("MAC 주소를 입력해 주세요")
			e.focus();
			return false;
		}
		if( isMacAddress(e.value) == false ){
			alert("MAC 정보가 부적절합니다");
			e.focus();
			return false;
		}

		e = document.getElementById("rule_name");
		if( isEmpty(e.value) == true){
			alert("설명을 입력해 주세요");
			return false;
		}

		if( checkName(e.value) == false ){
			alert("규칙이름이 부적절합니다(,; 등의 특수기호사용불가)");
			e.focus();
			return false;
	
		}

		strRule = "1,";	
		strRule1 = "1,";	
		strRule += "0,";
		strRule1 += "0,";
		strRule += document.getElementById("rule_name").value+",";
		strRule1 += ",";
		strRule += document.getElementById("rule_mac").value+",";
		strRule1 += document.getElementById("rule_mac").value+",";
		if( document.getElementById("week_7").checked == true ){
			valueWeek = 0x7f;
		}else{
			for( var i = 0; i < 7; i++ ){
				strTemp = "week_"+i;
				if( document.getElementById(strTemp).checked == true ){
					valueWeek |= ( 1 << i );
				}
			}
		
			if( valueWeek == 0 ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}
		}
	
		strRule += valueWeek+",";
		strRule1 += valueWeek+",";
	
		tStart_hour = document.getElementById("timeStart_hour").value;
		tEnd_hour = document.getElementById("timeEnd_hour").value;
		
		tStart_min = document.getElementById("timeStart_min").value;
		tEnd_min = document.getElementById("timeEnd_min").value;
	
		if(form_netkeep.time24[0].checked == true){
			strRule += "0,";
			strRule1 += "0,";
			strRule += "0,";
			strRule1 += "0,";
		}else{
			ret = validateRangeById("timeStart_hour", 10, 0, 23, true);
			if( ret!= 1 ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}else if(ret == 1){ 
				if(tStart_hour != "00"){
					if(tEnd_hour == "00" && tEnd_min == "00"){
						alert("이용제한 시간설정을 다시 확인해 주세요( ~ 24:00)");
						return false;
					}
				}
			}
			ret = validateRangeById("timeEnd_hour", 10, 0, 24, true);
			if( ret!= 1 ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}
			ret = validateRangeById("timeStart_min", 10, 0, 59, true);
			if( ret!= 1 ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}
			if(tEnd_hour == "24"){
				if((tStart_hour == "00") && (tStart_min == "00")){
					alert("이용제한 시간설정을 다시 확인해 주세요");
					return false;
				}
				ret = validateRangeById("timeEnd_min", 10, 0, 00, true);
				if(ret!=1){
					alert("이용제한 시간설정을 다시 확인해 주세요");
					return false;
				}
			}else
				ret = validateRangeById("timeEnd_min", 10, 0, 59, true);
			if( ret!= 1 ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}
	
			tStart = parseInt(tStart_hour*60) + parseInt(tStart_min);
			tEnd = parseInt(tEnd_hour*60) + parseInt(tEnd_min);
		
			if( tEnd != 0 && tStart >= tEnd ){
				alert("이용제한 시간설정을 다시 확인해 주세요");
				return false;
			}else{ 
					
				strRule += tStart+",";
				strRule1 += tStart+",";
				if(tEnd_hour == "24"){
					strRule += "0,";
					strRule1 += "0,";
				}else{
					strRule += tEnd+",";
					strRule1 += tEnd+",";
				}
			}
		}
		strRule += ';';
		strRule1 += ';';
	
		for( var i=0; i<maxCount; i++){
			if(arrData[i] != ""){
				entries_user = arrData[i].split(";");

				for(var j=0;j<entries_user.length; j++){
					var one_entry = entries_user[j].split(",");
					arrData1[j] = one_entry;
					arrData1[j][2] = "";
					arrData1[j] += ";";
				}
			}
		}
	
		for( var k=0; k<maxCount; k++ ){
			if( arrData1[k] == strRule1 ){
				bDuplicated = true;
			}
		}

		arrData[maxCount] = strRule;
		maxCount++;
		
		parent.mcrProgress.startProgressSimple('apply', 15);
		initForms(1);
	
		return true;
	}
} 


function validateOnSubmit(){
	var strList = "";
	strList = mergeRules();
	initTextById("ruleList", strList);
	
	return true;
}


function initForms(useDefault){
	var netKeepInfo;
	var netKeepEnable;
	
	if( useDefault == 0 ){
		vendor_init();
		netKeepInfo = '<% mcr_getNetKeepInfo(); %>';
		netKeepEnable = '<% mcr_getCfgCommon("NetKeepCfgParam_Enable"); %>';

		if(netKeepEnable == '1'){
			form_netkeep.radioActivity[0].checked = true;
		}else{
			form_netkeep.radioActivity[1].checked = true;
		}
		changeTimeSet(netKeepEnable);

		processHttpResponse(netKeepInfo);
		layoutRuleList();

	}else if( useDefault == 1 ){
		layoutRuleList();
	}
}
function EnableSet(value){
	changeTimeSet(value);


	changeTableAdmin();
	return;
}

function changeTimeSet(val){
	if(val == 1){
		$("#upnpRa1").show();
		$("#upnpRa2").show();
		$("#upnpRa4").show();
		$("#upnpRa5").show();
		$("#upnpRa6").hide();
		$("#ManageList1").show();
		$("#ManageList2").show();
		$("#ManageList4").show();
		$("#view_rulelist").show();
	}
	else{
		$("#upnpRa1").hide();
		$("#upnpRa2").hide();
		$("#upnpRa4").hide();
		$("#upnpRa5").hide();
		$("#upnpRa6").show();
		$("#ManageList1").hide();
		$("#ManageList2").hide();
		$("#ManageList4").hide();
		$("#view_rulelist").hide();
	}
}			

function initValue(){

	selectMenu3rd();
	parent.mcrProgress.stopProgress();	
	initForms(0);
	changeTableUser();
	changeTableAdmin();
}

function vendor_init(){
	gUserPrivilege = getUserPrivilege();
	gProjectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';
}






function processHttpResponse(strResponse){
	var rowOnly = 1;
	var lineArr = strResponse.split(";");

	maxCount = parseInt(lineArr[0], 10);
	if( maxCount > 0) {
		for( var row=0; row < lineArr.length-rowOnly; row++){
			if( lineArr[row+rowOnly].length > 0 ){
				arrData[row] = lineArr[row+rowOnly];
			}
		}
	}
}

function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;
	var schdule;
	var allow, week, timeStart, timeEnd;

	schdule = "";
	week = parseInt(items[4], 10);
	if( week == 0x7f ){
		schdule = "매일 ";
	}else{
		for( var i=0; i <7; i++ ){
			if( (week & (0x01 << i)) != 0 ){
				schdule += arrDays[i];
			}
		} 
	}
	arrCol[3] = schdule;
	
	schdule = "";
	timeStart = parseInt(items[5], 10);
	timeEnd = parseInt(items[6], 10);
	if( timeStart == 0 && timeEnd == 0 ){
		schdule += "24시간";
	}else{
		if( timeEnd == 0 ){
			schdule += getTimeStr(timeStart);
			schdule += " ~ ";
			schdule += "24:00";
		}else{
		schdule += getTimeStr(timeStart);
		schdule += " ~ ";
		schdule += getTimeStr(timeEnd);
		}
	} 
	arrCol[4] = schdule;

	if( aColumns[0].type & MCRColumn.TYPE_CHECKBOX ){
		var aCheckElement = new Array(2);
		aCheckElement[0] = aColumns[0].name+"_"+nRow;	
		aCheckElement[1] = "1";	

		arrCol[0] = aCheckElement;
		nOffset = 1;
	}
	
	arrCol[1] = items[3];
	arrCol[2] = items[2]; 
	
	return arrCol;
}

function initTable(){
	var strTableAttr = "class='TB' id='Grid_title1' width=100%' border='0' cellpadding='0' cellspacing='1' style='table-layout:fixed;' bgcolor='#F1F1F1'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "";
	var strTableTd = "class='BG2-2'";
	
	tableRule = new MCRTable("view_rulelist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
		strTableAttr,
		"",
		strTableTr, 
		"rule이 등록되지 않았습니다", ",", parseData );
	tableRule.addColumn(MCRColumn.TYPE_CHECKBOX, "delRow", "width='10%'", strTableTh, strTableTd, align='center', "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "width='20%'", strTableTh, strTableTd, align='center', "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "설명", "width='20%'", strTableTh, strTableTd, align='center', "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "제한요일", "width='25%'", strTableTh, strTableTd, align='center', "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "제한시간", "width='25%'", strTableTh, strTableTd, align='center', "");
}

function layoutRuleList(){
	if( tableRule == null ){
		initTable();
	}
	if( tableRule != null ){
		tableRule.setRows(arrData);
		tableRule.layout();
	}
}

function form_act(url){
	form_netkeep.action = url;
	form_netkeep.submit();

	return false;
}

function act(macaddr) {
	document.form_netkeep.rule_mac.value = macaddr;
}

//마우스 드래그 및 오른쪽 버튼 막기
//Crome and Firefox
var disable_tags=["input", "textarea", "select"];

disable_tags=disable_tags.join("|");

function disable_select(e){
	if (disable_tags.indexOf(e.target.tagName.toLowerCase())==-1)
	return false;
}

function reEnable(){
	return true;
}

if (typeof document.onselectstart!="undefined")
	document.onselectstart=new Function ("return false;")
else{
	document.onmousedown=disable_select;
	document.onmouseup=reEnable;
}

//IE

document.oncontextmenu = function() {return false;};
document.onselectstart = function() {return false;};
document.ondragstart = function() {return false;};

function unlock() {
	document.oncontextmenu = null;
	document.onselectstart = null;
	document.ondragstart = null;
}

function lock() {
	document.oncontextmenu = function() {return false;};
	document.onselectstart = function() {return false;};
	document.ondragstart = function() {return false;};
}

</script>

</head>

<body onload="initValue()">
<form method="post" class="form_layout" id="form_netkeep" name="form_netkeep" action="/goform/mcr_setNetKeepInfo" 
	onSubmit="return validateOnSubmit()">

<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/AdminFolder/3_6_5_internet_use_manage.asp"/>
<input type="hidden" id="ruleList" name="ruleList" value="">
	
<table width="800%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_6_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="800" height="200" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">스마트 스케쥴러 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">스마트 스케쥴러 설정</td>
											<td class="BG2-2" width="600" colspan="3">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input name="radioActivity"id="radioActivity" type="radio" value="1" onclick="EnableSet(this.value);"/>활성
														</td>
														<td>
															<input name="radioActivity" id="radioActivity" type="radio" value="0" onclick="EnableSet(this.value);"/>비활성
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="upnpRa2">
											<td height="25" class="BG2" style="width:140px;">타겟 MAC 주소</td>
											<td class="BG2-2" width="600"colspan="3">
												<table border="0" cellpadding="0" class="font1">
													<tr>
														<td width="110">
															<input type="text" id="rule_mac" style="width:300;" name="rule_mac" size="32" maxlength="17" value="" class="input2">
														</td>
														<td> ex) 00:11:22:33:44:55</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="upnpRa1">
											<td height="25" class="BG2" style="width=140px;">설명</td>
											<td class="BG2-2" width="600" colspan="3">
												<table border="0" cellpadding="0" class="font1">
													<tr>
														<td width="110">
															<input class="input2" type="text" style="width:300;"id="rule_name" name="rule_name" size="32" maxlength="17" value="">
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="upnpRa4">
											<td height="25" class="BG2" style="width:140px;">이용 제한 시간 설정</td>
											<td class="BG2-2">
												<table border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
				    										<td><input type="checkbox" id="week_7" name="week_7" value="1" onclick="return onClickScheduleWeekAll();"></td><td>매일</td>
													</tr>
													<tr>
														<td><input type="checkbox" id="week_0" name="week_0" value="1" onclick="return onClickScheduleWeekOne();"></td><td>일</td>
				    										<td><input type="checkbox" id="week_1" name="week_1" value="1" onclick="return onClickScheduleWeekOne();"></td><td>월</td>
				    										<td><input type="checkbox" id="week_2" name="week_2" value="1" onclick="return onClickScheduleWeekOne();"></td><td>화</td>
				    										<td><input type="checkbox" id="week_3" name="week_3" value="1" onclick="return onClickScheduleWeekOne();"></td><td>수</td>
				    										<td><input type="checkbox" id="week_4" name="week_4" value="1" onclick="return onClickScheduleWeekOne();"></td><td>목</td>
				    										<td><input type="checkbox" id="week_5" name="week_5" value="1" onclick="return onClickScheduleWeekOne();"></td><td>금</td>
				    										<td><input type="checkbox" id="week_6" name="week_6" value="1" onclick="return onClickScheduleWeekOne();"></td><td>토</td>
													</tr>
												</table>
											</td>
											<td class="BG2-2">
												<table border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td><input type="radio" id="time24" name="time24" value="1"  onclick="return onClickScheduleTime();"><label id="lbl_time_24">24 시간</label></td>
													</tr>
													<tr>
														<td><input type="radio" id="time24" name="time24" value="0"  onclick="return onClickScheduleTime();">
														<input type='text' id='timeStart_hour' name='timeStart_hour' size='2' maxlength='2' value=''>
    														<label> : </label>
    														<input type='text' id='timeStart_min' name='timeStart_min' size='2' maxlength='2' value=''></input>
														<label> ~ </label>
    														<input type='text' id='timeEnd_hour' name='timeEnd_hour' size='2' maxlength='2' value=''></input>
    														<label> : </label>
    														<input type='text' id='timeEnd_min' name='timeEnd_min' size='2' maxlength='2' value=''></input>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id ="upnpRa5">
											<td class="PD6" colspan="3">
												<input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply" height="24" width="52"name="btn_apply" onClick="return onClickAdd();">
											</td>
										</tr>
										<tr id ="upnpRa6">
											<td class="PD6" colspan="3">
												<input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply1" height="24" width="52"name="btn_apply1" onclick="form_act('/goform/mcr_setNetKeepInfo');parent.mcrProgress.startProgressSimple('apply', 15); return false;"/>
											</td>
										</tr>
									</table>
									<table class="TB" border="0" id=list3>
										<tr id=ManageList1>
											<td height="25" class="BG2" style="width:140px">관리 리스트</td>
											<td></td>
										</tr>
									</table>	
									<table class="TB" border="0">
										<tr id=ManageList2>
											<td colspan="2">
												<table width="100%" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100px">
															<table class='TB' width="100%" border="0"cellpadding="0" cellspacing="0" style="table-layoyut:fixed;">
																<col width="10%" align="center">
																<col width="20%" >
																<col width="20%">
																<col width="25%">
																<col width="25%">
										
																<tr height="25">
																	<td class="BG2-1" align="center">선택</td>
																	<td class="BG2-1" align="center">MAC 주소</td>
																	<td class="BG2-1" align="center">설명</td>
																	<td class="BG2-1" align="center">제한요일</td>
																	<td class="BG2-1" align="center">제한시간</td>
																</tr>
															</table>
															</span>
														</td>
														<td id="lastTD" style="display:none;">
															<table width="100%" border="0" cellpadding="0" cellspacing="0" style="table-layout:fixed;">
																<tr height="25" width="100%">
																	<td class="BG1">&nbsp;</td>
																</tr>
															</table>
														</td>
													</tr>
												</table>
											</td>
										</tr>

										<tr id=ManageList3>
											<td width="100%" valign="top">
												<span id="Grid_data1" align="center" style="height:100%;width:100%;">
													<div id="view_rulelist"></div>
											</td>
										</tr>
									</table>
										
									<tr id = ManageList4>
											<td class="PD6">
												<table width="100%" border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td class="PD6">
    															<input type="image" src="/images/BTN/BTN_02.gif" value="Del" id="btn_del" name="btn_del" onClick="return onClickDel();">
														</td>
													</tr>
												</table>
										
											</td>
									</tr>
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
