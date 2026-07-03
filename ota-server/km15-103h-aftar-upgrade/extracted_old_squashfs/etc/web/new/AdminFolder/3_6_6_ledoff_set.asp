<html>
<head>
<%include('new/metatag.asp');%>
<title>LED OFF 시간 설정</title>
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

var beforId = "menu05";
var tableRule = null;
var arrData = new Array();
function mouseover(clickId){
        var obj = document.getElementById(clickId);
        obj.className="menu3rdMouse";
}
function mouseout(clickId){
        var obj = document.getElementById(clickId);
        if(beforId == clickId)
        {
                obj.className="menu3rdSelect";
        }else{
                obj.className="menu3rdNormal";
        }
}

function selectMenu3rd(){
        $("#menu05").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function changeTableAdmin()
{
        if(document.body.scrollHeight>656) {
                parent.document.getElementById("main").style.height=document.body.scrollHeight;
                parent.document.getElementById("menu").style.height=document.body.scrollHeight;
        }else{
                parent.document.getElementById("main").style.height=656;
                parent.document.getElementById("menu").style.height=656;
        }
}

function initValue(){
        var Enable = '<%mcr_getCfgString("LedOffCfgParam_Enable"); %>';

        selectMenu3rd();
	changeTableAdmin();

        if(Enable == '1'){
                form_ledoff.radioActivity[0].checked = true;
		$("#time_set").show();
		$("#ManageList1").show();
		$("#ManageList2").show();
		
        }else{
                form_ledoff.radioActivity[1].checked = true;
		$("#time_set").hide();
		$("#ManageList1").hide();
		$("#ManageList2").hide();
        }
	parent.mcrProgress.stopProgress();
}
		
function onClickAdd(){
	//var opmode = "<%mcr_getCfgString("SysOperMode_OperMode"); %>";
	var Enable = '<%mcr_getCfgString("LedOffCfgParam_Enable"); %>';
	var str = "<%mcr_getLedOff(); %>";

	
	if(form_ledoff.radioActivity[0].checked == true){
/*
		if(opmode == "0"){
			if(Enable == "0"){
				if(document.getElementById("radioActivity").value == "1"){
					alert("KT모드에서만 사용 가능합니다.");
					return false;
				}
			}
		}else
*/
		{
			if(str != ""){
				alert("최대 1개까지만 설정됩니다");
				return false;
			}
			tStart_hour = document.getElementById("timeStart_hour").value;
			tEnd_hour = document.getElementById("timeEnd_hour").value;
			tStart_min = document.getElementById("timeStart_min").value;
			tEnd_min = document.getElementById("timeEnd_min").value;
			ret = validateRangeById("timeStart_hour", 10, 0, 23, true);
			if(ret != 1){
				alert("설정 시간을 다시 확인해 주세요");
				return false;
			}else if(ret == 1){ // start 시간을 00:00시 이외에 다른 시간에 end 시간을 00:00 설정하는 시간 예외처리
				if(tStart_hour != "00"){
					if(tEnd_hour == "00" && tEnd_min == "00"){
						alert("시간 설정을 다시 확인해 주세요");
						return false;
					}
				}
			}
			if(tStart_hour == "00" && tStart_min == "00" && tEnd_hour == "00" && tEnd_min == "00"){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			ret = validateRangeById("timeEnd_hour", 10, 0, 24, true);
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			ret = validateRangeById("timeStart_min", 10, 0, 59, true);
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			if(tEnd_hour == "24"){
				if((tStart_hour == "00") && (tStart_min == "00")){
					alert("시간 설정을 다시 확인해 주세요");
					return false;
				}
				ret = validateRangeById("timeEnd_min", 10, 0, 00, true);
				if(ret != 1){
					alert("시간 설정을 다시 확인해 주세요");
					return false;
				}
			}else{
				ret = validateRangeById("timeEnd_min", 10, 0, 59, true);
			}
			if(ret != 1){
				alert("시간 설정을 다시 확인해 주세요");
				return false;
			}
			tStart = parseInt(tStart_hour*60) + parseInt(tStart_min);
			tEnd = parseInt(tEnd_hour*60) + parseInt(tEnd_min);
		}
	}
	
		parent.mcrProgress.startProgressSimple('apply', 15);
		form_act('/goform/mcr_setLedOff');
	
		return true;
}
function onClickDel(){
		
	parent.mcrProgress.startProgressSimple('apply', 15);
	form_act('/goform/mcr_delLedOff');
	return true;
}
		
function EnableSet(val){
	if(val == "1"){
		$("#time_set").show();
		$("#ManageList1").show();
		$("#ManageList2").show();
	}else{
		$("#time_set").hide();
		$("#ManageList1").hide();
		$("#ManageList2").hide();
	}
}
function form_act(url){
		form_ledoff.action = url;
		form_ledoff.submit();

		return false;
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
<form method="post" class="form_layout" id="form_ledoff" name="form_ledoff" action="/goform/mcr_setLedOff">
<input type="hidden" id="wlanRedirectPage" name="wlanRedirectPage" value="/new/AdminFolder/3_6_6_ledoff_set.asp"/>
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
                                                                <td class="font5">LED OFF 시간 설정</td>
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
                                                                                        <td height="25" class="BG2" style="width:140px;">LED OFF 시간 설정</td>
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
                                                                                <tr id="time_set" style="display:none;">
                                                                                        <td height="25" class="BG2" style="width:140px;">시간 설정</td>
                                                                                        <td class="BG2-2" width="600"colspan="3">
                                                                                                <table border="0" cellpadding="0" class="font1">
                                                                                                        <tr>
                                                                                                                <td>
                                                                                                                        <input type="text" id="timeStart_hour" name="timeStart_hour" size="2" maxlength="2" value="">
                                                                                                                        <label> : </label>
                                                                                                                        <input type="text" id="timeStart_min" name="timeStart_min" size="2" maxlength="2" value=""></input>
                                                                                                                        <label> ~ </label>
                                                                                                                        <input type="text" id="timeEnd_hour" name="timeEnd_hour" size="2" maxlength="2" value=""></input>
                                                                                                                        <label> : </label>
                                                                                                                        <input type="text" id="timeEnd_min" name="timeEnd_min" size="2" maxlength="2" value=""></input>
                                                                                                                </td>
                                                                                                        </tr>
                                                                                                </table>
                                                                                        </td>
                                                                                </tr>
                                                                                <tr id ="apply">
                                                                                        <td class="PD6" colspan="3">
                                                                                                <input type="image" src="/images/BTN/BTN_01.gif" value="Apply" id="btn_apply" height="24" width="52"name="btn_apply" onClick="return onClickAdd();">
                                                                                        </td>
                                                                                </tr>
                                                                        </table>
								</td>
							</tr>
                                                        <tr>
                                                                <td class="PD5"></td>
                                                        </tr>
							<tr id="ManageList1" style="display:none;">
								<td>
                                                                        <table class="TB" width="100%" border="0">
                                                                                <tr>
                                                                                        <td height="25" class="BG2" style="width:140px">관리 리스트</td>
                                                                                        <td width="600">
                                                                                </tr>
                                                                        </table>
								</td>
							</tr>
							<tr id="ManageList2" style="display:none;">
								<td>
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                        <td>
                                                                                               	<table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                        <tr>
                                                                                                                <td>
                                                                        						<table class="TB" width="100%" border="0">
                                                                                                                        <span id="Grid_title1" align="center" style="width:100px">
                                                                                                                                <col width="10%">
                                                                                                                                <col width="90%">

                                                                                                                                <tr height="25">
                                                                                                                                        <td class="BG2-1" style="padding-left:0px;" align="center">선택</td>
                                                                                                                                        <td class="BG2-1" style="padding-left:0px;" align="center">설정시간</td>

                                                                                                                                </tr>
                                                                                                                        </table>
                                                                                                                </td>
                                                                                                        </tr>
                                                                                                </table>
                                                                                        </td>
                                                                                </tr>
                                                                                <tr>
                                                                                        <td width="100%" valign="top">
                                                                                                <span id="Grid_data1" align="center" style="height:100%;width:100%;">
												<table class="TB" id="Grid_Table" width="100%" border="0" style="table-layout:fixed;" bgcolor="#FFFFFF">
													<col width="10%">
													<col width="90%">
													
													<script language="JavaScript" type="text/javascript">
														var i,j;
														var all_str = "<%mcr_getLedOff(); %>";
														var str="";
				
														if(all_str == ""){
															document.write("<tr bgcolor=#FFFFFF>");
															document.write("<td align=center colspan=8 id=LedOffListNone> <p>리스트가 없습니다</p> </td>");
															document.write("</tr>\n");
														}else{
															var entries = all_str.split(";");
														for(i=0; i<entries.length-1; i++){
																arrData[i] = entries[i].split(",");
															}
															for(i=0; i<entries.length-1; i++){
																document.write("<tr bgcolor=#FFFFFF>");
																document.write("<td class=BG2-2 style='padding-left:0px;' align=center>");
																document.write("<input type=checkbox name=del_" + i + ">");
																document.write("</td>");

																document.write("<td class=BG2-2>");
																for(j=0;j<4;j++) {
																	if( arrData[i][j+1] == null || arrData[i][j+1].length == 0 ){
																		document.write("");
																	}else{
																		str = str + arrData[i][j+1];
																		if(j==0) str = str + ":";
																		else if(j==1) str = str + " ~ ";
																		else if(j==2) str = str + ":";
																	}
																}
																document.write(str);
																document.write("</td>");
																document.write("</tr>\n");
															}
														}
						
													</script>
												</table>	
                                                                                        </td>
                                                                                </tr>
                                                                        	<tr>
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
									</table>
                                                                </td>
                                                        </tr>
                                                </table>
                                        </td>
                                </tr>
                        </table>
                </tr>
        </tr>
</table>

</form>
</body>

</html>
