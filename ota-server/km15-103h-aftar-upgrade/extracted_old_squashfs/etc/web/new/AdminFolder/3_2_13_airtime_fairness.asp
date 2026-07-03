<html>
<head>
<%include('new/metatag.asp');%>
<title>Airtime Fairness 설정</title>
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
<script language="javascript" type="text/javascript"></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_table.js?version=<% mcr_getWebVersion(); %>'></script>
<script>
<% var gWlanIfIndexEJ = mcr_getCfgWirelessEJ("wlanIfIndex"); %>
gWlanIfIndex = '<% mcr_getCfgWireless("wlanIfIndex"); %>';

var arrData = new Array();
var tableRule = null;

function changeTableAdmin() 
{
			
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	}
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function initValue(){

	changeTableAdmin();
	parent.mcrProgress.stopProgress();
	initForm_WLAN_ATF(0);
}

function initForm_WLAN_ATF(value){

	var atfEnable, atfData;

	atfEnable = '<% mcr_getCfgString("Wlan_ATF_WATFEnable_0", 0); %>';

	$("#wlanUIMenu14").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	$("input[name='radioActivity']").val([atfEnable]);  
		var target = 0;
		if( gWlanIfIndex == '0' ){
			targetSSID = ''+0x01f;
			$("#WlanIfIndex").val = '0';
		}
	httpRequest("/goform/mcr_KT_getWirelessStation", targetSSID, processHttpResponse);
	layoutStationList();
}
		
function form_act(url)
{
	parent.mcrProgress.startProgressSimple('apply', 20);
	form_atfadd.action = url;
	form_atfadd.submit();
	
	return false;
}

function validateOnSubmit()
{
	var mac = document.getElementById("atf_mac");
	var pc = document.getElementById("atf_pc");
	var UserList = document.getElementById("maxinfo").value;
	var e = document.form_atfadd.atf_pcmac;
	
	if(form_atfadd.radioActivity[0].checked){
		if ( isEmpty(mac.value) == true ) {
		}else{
			if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
				alert("잘못된 타겟 MAC 주소입니다");
				return false;
			}
			if(UserList >= 64){
				alert("최대 설정 개수입니다");
				return false;
			}
		}
	}

	form_act('/goform/mcr_addAtf');
	return false;
	
}
$(document).ready(function(){
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

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function onClickact_pcmac(){
	var ret = false;
	var strRow = null;
	var items = null;
	var row = $("input[name='delmac']:checked").val();
	if( arrData != null && row != null ){
		strRow = arrData[row];
		items = strRow.split('\r');
		ret = true;
	}
	if(ret){
		document.form_atfadd.atf_mac.value = items[2];
	}else{
		$("input[name='delmac']:checked").attr("checked", false);
	}
	
}
function processHttpResponse(strResponse){
	var maxStationCount = 0;

	var rowOnly = 0;
	var lineArr = strResponse.split("\n");

	arrData.length = 0;
	for( var row=0; row < lineArr.length-rowOnly; row++){
		if( lineArr[row+rowOnly].length > 1 ){
			arrData[row] = lineArr[row+rowOnly];
			maxStationCount++;
		}
	}

	initTextById("maxStaCount", ""+maxStationCount);

	
}
function parseData(nRow, aColumns, aRow, strSplit){
	var items = aRow.split(strSplit);
	var arrCol = new Array( aColumns.length );
	var nOffset = 0;

	var btnName = "delmac_"+nRow;

	if( aColumns[0].type & MCRColumn.TYPE_NORMAL ){
		var aCheckElement = new Array(2);
		arrCol[0] = '<input type="radio" name="delmac" value="'+nRow+'" onClick="onClickact_pcmac()"></input>';
		arrCol[1] = items[2]; 
	}
	return arrCol;
}

function initTable(){
	var strTableAttr = "class='TB' width='100%' border='0' cellspacing='1' cellpadding='0'";
	var strTableTr = "bgcolor='#FFFFFF'";
	var strTableTh = "";
	var strTableTd = "class='BG2-2' style='word-break:break-all; padding-left:0px;' align='center'";

	tableRule = new MCRTable("view_stalist",
		MCRTable.TYPE_TABLE_USE_TABLE_HEADER | MCRTable.TYPE_TABLE_USE_COL,
		strTableAttr,
		"",
		strTableTr,
		"접속된단말이 없습니다", "\r", parseData );
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "delmac", "width='30'", strTableTh, strTableTd, "");
	tableRule.addColumn(MCRColumn.TYPE_NORMAL, "MAC 주소", "width='130'", strTableTh, strTableTd, "");
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
function EnableSet(val){
	var e = document.form_atfadd.atf_pcmac;
	if(val == "0"){
		$("#atfList").hide();
		on_focus_clear("atf_mac");
		e.checked = false;
		
	}
}

function check_del(index){
	
	$("#delIndex").val(index);
}
function check_pcmac() {
	var f=document.form_atfadd;
	var obj = document.getElementById('atf_height');
	if(f.atf_pcmac.checked == true){
		var target = 0;
		if( gWlanIfIndex == '0' ){
			targetSSID = ''+0x01f;
			$("#WlanIfIndex").val = '0';
		}

		httpRequest("/goform/mcr_KT_getWirelessStation", targetSSID, processHttpResponse);
		layoutStationList();
		$("#atfList").show();
	}else{
		$("#atfList").hide();
	}
	
}
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

<body>
<form method="post"class="form_layout" name="form_atfadd" id="form_atfadd" action="/goform/mcr_addAtf">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/AdminFolder/3_2_13_airtime_fairness.asp"/>
<input type="hidden" id="delIndex" name="delIndex" value="" />
<input type="hidden" id="WlanIfIndex" name="WlanIfIndex" value="" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_2_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="50" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">Airtime Fairness 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">Airtime Fairness 설정</td>
											<td class="BG2-2" width="600" colspan="3">
												<table border="0" cellpadding="0" cellspacing="0" class="font1">
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
										<tr>
											<td height="25" class="BG2" style="width:140px;">타겟 MAC 주소</td>
											<td class="BG2-2" width="600">
												<input name="atf_mac" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="atf_mac" maxlength="17" value="" onFocus="on_focus_clear('atf_mac')" /> 
												<input name="atf_pcmac" type="checkbox" id="atf_pcmac" value="" onClick="check_pcmac();" /> 
												현재 접속된 PC(예 00:11:22:33:44:55)
											</td>
										</tr>
										<tr id="atfList" height="20" style="display:none">
											<td class="PD6" colspan="2">
												<table width="300" border="0" cellpadding="0" cellspacing="0" class="fix">
													<tr>
														<td>
															<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
																<table class="TB" width="100%" border="0" style="table-layout:fixed;">
																	<col width="30">
																	<col width="130">
																	<tr height="20">
																		<td class="BG1">
																			<p style="font-size:9pt; border-width:1px; border-style:none;">
																				선택
																			</p>
																		</td>
																		<td class="BG1">
																			<p>MAC 주소</p>
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
													<tr id="atf_height">
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
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="96%" border="0" cellspacing="0" cellpadding="0">
				<tr id="apply">
					<td class="PD6">									
						<input name="Apply" type="image" id="btn_apply"src="/images/BTN/BTN_03.gif?Sp2" alt="" width="52" height="24" onclick="return validateOnSubmit();">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr id="atfMacList" style="display:inline">
		<td class="PD6">
			<table class="TB" width="100%" border="0" cellspacing="1" cellpadding="10">
				<tr height="20">
					<td width="100%" >
						<table width="764" border="0" cellpadding="0" cellspacing="0" class="fix">
							<tr>
								<td>
									<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
										<table class="TB" width="100%" border="0" style="table-layout:fixed;">
											<col width="100">
											<col width="660">
											<tr height="20">
												<td class="BG1">
													<p style="font-size:9pt; border-width:1px; border-style:none;">
													선택
													</p>
												</td>
												<td class="BG1">
													<p>MAC 주소</p>
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
							<tr>
								<td width="100%" valign="top">
									<span id="Grid_data1" align="center" style="height:100%;width:100%;">
										<table class="TB" id="Grid_Table" width="100%" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
											<col width="100" align="center"> 
											<col width="660">

												<%
													var i;
													var rule_num = mcr_getWirelessAtfCount();
													var mac = mcr_getWirelessAtfMac(i,0);
													write("<input type=hidden name=maxinfo id=maxinfo value=");write(rule_num);write(">");
													if (rule_num > 0 && mac != "00:00:00:00:00:00") {
														for ( i = 0; i < rule_num; i++ ){
															write("<tr bgcolor=#FFFFFF>");
									
															write("<td class=BG2-2 style='padding-left:0px;' align='center'>");
															write("<input type=checkbox name=chk_" + i + " onClick=check_del("+ i +")>");
															write("</td>");
														
															write("<td class=BG2-2>");
															write("<p>");write(mcr_getWirelessAtfMac(i,0));write("</p>");
															write("</td>");
										
															write("</tr>\n");
														}
													}
													else {
														write("<tr bgcolor=#FFFFFF>");
														write("<td colspan=2 align='center'>");
														write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
														write("</td>");
														write("</tr>\n");
													}
												%>
										</table>
									</span>
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
			<table width="96%" border="0" cellspacing="0" cellpadding="0">
				<tr id="apply">
					<td class="PD6">									
						<input name="Apply2" type="image" src="/images/BTN/BTN_02.gif?Sp2" alt="" width="52" height="24" onclick="form_act('/goform/mcr_delAtf'); return false;"/>
					</td>
				</tr>
			</table>
		</td>
	</tr>

</table>
</form>

</body>
</html>
