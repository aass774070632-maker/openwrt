<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>
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
<script>

var beforId = "menu03";

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
	else
	{
		obj.className="menu3rdNormal";
	}
}

function checkVal( a, b, c, d ) {
	var aVal = parseInt(a.value);
	var bVal = parseInt(b.value);
	var cVal = parseInt(c.value);
	var dVal = parseInt(d.value);

	if((aVal+bVal+cVal+dVal) > 15)
		return false;
	return true;
}

function CheckValue() {
	if(document.form_qos.port0sch.options.selectedIndex == 1) {
		if((document.form_qos.port0_qw0.value == "") ||
				(isAllNum(document.form_qos.port0_qw0.value) ==0)) {
			alert("Q0의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port0_qw1.value == "") ||
				(isAllNum(document.form_qos.port0_qw1.value) ==0)) {
			alert("Q1의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port0_qw2.value == "") ||
				(isAllNum(document.form_qos.port0_qw2.value) ==0)) {
			alert("Q2의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port0_qw3.value == "") ||
				(isAllNum(document.form_qos.port0_qw3.value) ==0)) {
			alert("Q3의 가중치 값 입력오류 입니다.");
			return false;
		}
		if(!checkVal(document.form_qos.port0_qw0,document.form_qos.port0_qw1,document.form_qos.port0_qw2,document.form_qos.port0_qw3)) {
			alert("Q0+Q1+Q2+Q3의 가중치 합이 15 보다 작거나 같아야 합니다.");
			return false;
		}
	}
	if(document.form_qos.port1sch.options.selectedIndex == 1) {
		if((document.form_qos.port1_qw0.value == "") ||
				(isAllNum(document.form_qos.port1_qw0.value) ==0)) {
			alert("Q0의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port1_qw1.value == "") ||
				(isAllNum(document.form_qos.port1_qw1.value) ==0)) {
			alert("Q1의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port1_qw2.value == "") ||
				(isAllNum(document.form_qos.port1_qw2.value) ==0)) {
			alert("Q2의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port1_qw3.value == "") ||
				(isAllNum(document.form_qos.port1_qw3.value) ==0)) {
			alert("Q3의 가중치 값 입력오류 입니다.");
			return false;
		}
		if(!checkVal(document.form_qos.port1_qw0,document.form_qos.port1_qw1,document.form_qos.port1_qw2,document.form_qos.port1_qw3)) {
			alert("Q0+Q1+Q2+Q3의 가중치 합이 15 보다 작거나 같아야 합니다.");
			return false;
		}
	}
	if(document.form_qos.port2sch.options.selectedIndex == 1) {
		if((document.form_qos.port2_qw0.value == "") ||
				(isAllNum(document.form_qos.port2_qw0.value) ==0)) {
			alert("Q0의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port2_qw1.value == "") ||
				(isAllNum(document.form_qos.port2_qw1.value) ==0)) {
			alert("Q1의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port2_qw2.value == "") ||
				(isAllNum(document.form_qos.port2_qw2.value) ==0)) {
			alert("Q2의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port2_qw3.value == "") ||
				(isAllNum(document.form_qos.port2_qw3.value) ==0)) {
			alert("Q3의 가중치 값 입력오류 입니다.");
			return false;
		}
		if(!checkVal(document.form_qos.port2_qw0,document.form_qos.port2_qw1,document.form_qos.port2_qw2,document.form_qos.port2_qw3)) {
			alert("Q0+Q1+Q2+Q3의 가중치 합이 15 보다 작거나 같아야 합니다.");
			return false;
		}
	}
	if(document.form_qos.port3sch.options.selectedIndex == 1) {
		if((document.form_qos.port3_qw0.value == "") ||
				(isAllNum(document.form_qos.port3_qw0.value) ==0)) {
			alert("Q0의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port3_qw1.value == "") ||
				(isAllNum(document.form_qos.port3_qw1.value) ==0)) {
			alert("Q1의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port3_qw2.value == "") ||
				(isAllNum(document.form_qos.port3_qw2.value) ==0)) {
			alert("Q2의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port3_qw3.value == "") ||
				(isAllNum(document.form_qos.port3_qw3.value) ==0)) {
			alert("Q3의 가중치 값 입력오류 입니다.");
			return false;
		}
		if(!checkVal(document.form_qos.port3_qw0,document.form_qos.port3_qw1,document.form_qos.port3_qw2,document.form_qos.port3_qw3)) {
			alert("Q0+Q1+Q2+Q3의 가중치 합이 15 보다 작거나 같아야 합니다.");
			return false;
		}
	}
	if(document.form_qos.port4sch.options.selectedIndex == 1) {
		if((document.form_qos.port4_qw0.value == "") ||
				(isAllNum(document.form_qos.port4_qw0.value) ==0)) {
			alert("Q0의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port4_qw1.value == "") ||
				(isAllNum(document.form_qos.port4_qw1.value) ==0)) {
			alert("Q1의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port4_qw2.value == "") ||
				(isAllNum(document.form_qos.port4_qw2.value) ==0)) {
			alert("Q2의 가중치 값 입력오류 입니다.");
			return false;
		}
		if((document.form_qos.port4_qw3.value == "") ||
				(isAllNum(document.form_qos.port4_qw3.value) ==0)) {
			alert("Q3의 가중치 값 입력오류 입니다.");
			return false;
		}
		if(!checkVal(document.form_qos.port4_qw0,document.form_qos.port4_qw1,document.form_qos.port4_qw2,document.form_qos.port4_qw3)) {
			alert("Q0+Q1+Q2+Q3의 가중치 합이 15 보다 작거나 같아야 합니다.");
			return false;
		}
	}
	return true;
}

function form_act(url) {
	if(url == "/goform/mcr_setQoS_New") {
		if(!CheckValue())
			return false;
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	form_qos.action = url;
	form_qos.submit();
	return false;
}

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function changeSelect(changeSelect) {
	var idx = 0;
	var nameQw0, nameQw1, nameQw2, nameQw3;

	if( changeSelect == null ) return;

	if( changeSelect.name == 'port0sch' ){
		idx = 0;
	}else if( changeSelect.name == 'port1sch' ){
		idx = 1;
	}else if( changeSelect.name == 'port2sch' ){
		idx = 2;
	}else if( changeSelect.name == 'port3sch' ){
		idx = 3;
	}else if( changeSelect.name == 'port4sch' ){
		idx = 4;
	}

	nameQw0 = "port"+idx+"_qw0";
	nameQw1 = "port"+idx+"_qw1";
	nameQw2 = "port"+idx+"_qw2";
	nameQw3 = "port"+idx+"_qw3";

	if(changeSelect.selectedIndex == 0) {
		$('#'+nameQw0).attr("disabled", "disabled");
		$('#'+nameQw1).attr("disabled", "disabled");
		$('#'+nameQw2).attr("disabled", "disabled");
		$('#'+nameQw3).attr("disabled", "disabled");
	} else {
		$('#'+nameQw0).removeAttr("disabled");
		$('#'+nameQw1).removeAttr("disabled");
		$('#'+nameQw2).removeAttr("disabled");
		$('#'+nameQw3).removeAttr("disabled");
	}
}

function initValue() {
	$("#menu03").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	parent.mcrProgress.stopProgress()
		var p0sch = "<% mcr_getCfgString("QosCfgParam_QueueType_0"); %>";
	var p1sch = "<% mcr_getCfgString("QosCfgParam_QueueType_1"); %>";
	var p2sch = "<% mcr_getCfgString("QosCfgParam_QueueType_2"); %>";
	var p3sch = "<% mcr_getCfgString("QosCfgParam_QueueType_3"); %>";
	var p4sch = "<% mcr_getCfgString("QosCfgParam_QueueType_4"); %>";
	var p0pri = "<% mcr_getCfgString("QosCfgParam_PortPri_0"); %>";
	var p1pri = "<% mcr_getCfgString("QosCfgParam_PortPri_1"); %>";
	var p2pri = "<% mcr_getCfgString("QosCfgParam_PortPri_2"); %>";
	var p3pri = "<% mcr_getCfgString("QosCfgParam_PortPri_3"); %>";
	var p4pri = "<% mcr_getCfgString("QosCfgParam_PortPri_4"); %>";
	var pri0 = "<% mcr_getCfgString("QosDscpMapParam0_Pri0"); %>";
	var pri1 = "<% mcr_getCfgString("QosDscpMapParam0_Pri1"); %>";
	var pri2 = "<% mcr_getCfgString("QosDscpMapParam0_Pri2"); %>";
	var pri3 = "<% mcr_getCfgString("QosDscpMapParam0_Pri3"); %>";
	var pri4 = "<% mcr_getCfgString("QosDscpMapParam0_Pri4"); %>";
	var pri5 = "<% mcr_getCfgString("QosDscpMapParam0_Pri5"); %>";
	var pri6 = "<% mcr_getCfgString("QosDscpMapParam0_Pri6"); %>";
	var pri7 = "<% mcr_getCfgString("QosDscpMapParam0_Pri7"); %>";

	changeTable();

	initComboById("port0sch", p0sch);
	initComboById("port1sch", p1sch);
	initComboById("port2sch", p2sch);
	initComboById("port3sch", p3sch);
	initComboById("port4sch", p4sch);

	initComboById("port0pri", p0pri);
	initComboById("port1pri", p1pri);
	initComboById("port2pri", p2pri);
	initComboById("port3pri", p3pri);
	initComboById("port4pri", p4pri);

	initComboById("pri7", pri7);
	initComboById("pri6", pri6);
	initComboById("pri5", pri5);
	initComboById("pri4", pri4);
	initComboById("pri3", pri3);
	initComboById("pri2", pri2);
	initComboById("pri1", pri1);
	initComboById("pri0", pri0);

	changeSelect(document.getElementById("port0sch"));
	changeSelect(document.getElementById("port1sch"));
	changeSelect(document.getElementById("port2sch"));
	changeSelect(document.getElementById("port3sch"));
	changeSelect(document.getElementById("port4sch"));

	$("#port0_dscp").attr("disabled", "disabled");
	$("#port1_dscp").attr("disabled", "disabled");
	$("#port2_dscp").attr("disabled", "disabled");
	$("#port3_dscp").attr("disabled", "disabled");
	$("#port4_dscp").attr("disabled", "disabled");

}

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

<body onload="initValue();">
<form name="form_qos">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETQOS value="/new/AdminFolder/3_4_4_qos_set.asp" />
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td class="font5">QoS 설정</td>
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
														<td class="BG1">포트이름</td>
														<td class="BG1">Queue Scheduling</td>
														<td class="BG1">가중치(Q0/Q1/Q2/Q3)</td>
														<td class="BG1">DSCP</td>
														<td class="BG1">Port</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN1</td>
														<td class="BG2-3">
															<select name="port1sch" class="input2" id="port1sch" onchange="changeSelect(this);">
																<option selected value="1">SPQ</option>
																<option value="2">WRR</option>
															</select>
														</td>
														<td class="BG2-3">
															<input name="port1_qw0" type="text" onmouseover="unlock();" onmouseout="lock();" id="port1_qw0" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw0_1");%>" disabled>
															/ <input name="port1_qw1" type="text" onmouseover="unlock();" onmouseout="lock();" id="port1_qw1" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw1_1");%>" disabled>
															/ <input name="port1_qw2" type="text" onmouseover="unlock();" onmouseout="lock();" id="port1_qw2" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw2_1");%>" disabled>
															/ <input name="port1_qw3" type="text" onmouseover="unlock();" onmouseout="lock();" id="port1_qw3" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw3_1");%>" disabled>
														</td>
														<td class="BG2-3">
															<select name="port1_dscp" class="input2" id="port1_dscp">
																<option selected>ON</option>
																<option>OFF</option>
															</select></td>
														<td class="BG2-3">
															<select name="port1pri" class="input2" id="port1pri">
																<option selected value="0">OFF</option>
																<option value="1">Q0</option>
																<option value="2">Q1</option>
																<option value="3">Q2</option>
																<option value="4">Q3</option>
															</select>
														</td>
													</tr>

													<tr>
														<td class="BG2" style="width:140px;">LAN2</td>
														<td class="BG2-3">
															<select name="port2sch" class="input2" id="port2sch" onchange="changeSelect(this);">
																<option selected value="1">SPQ</option>
																<option value="2">WRR</option>
															</select>
														</td>
														<td class="BG2-3">
															<input name="port2_qw0" type="text" onmouseover="unlock();" onmouseout="lock();" id="port2_qw0" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw0_2");%>" disabled>
															/ <input name="port2_qw1" type="text" onmouseover="unlock();" onmouseout="lock();" id="port2_qw1" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw1_2");%>" disabled>
															/ <input name="port2_qw2" type="text" onmouseover="unlock();" onmouseout="lock();" id="port2_qw2" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw2_2");%>" disabled>
															/ <input name="port2_qw3" type="text" onmouseover="unlock();" onmouseout="lock();" id="port2_qw3" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw3_2");%>" disabled>
														</td>
														<td class="BG2-3">
															<select name="port2_dscp" class="input2" id="port2_dscp">
																<option selected>ON</option>
																<option>OFF</option>
															</select></td>
														<td class="BG2-3">
															<select name="port2pri" class="input2" id="port2pri">
																<option selected value="0">OFF</option>
																<option value="1">Q0</option>
																<option value="2">Q1</option>
																<option value="3">Q2</option>
																<option value="4">Q3</option>
															</select>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN3</td>
														<td class="BG2-3">
															<select name="port3sch" class="input2" id="port3sch" onchange="changeSelect(this);">
																<option selected value="1">SPQ</option>
																<option value="2">WRR</option>
															</select>
														</td>
														<td class="BG2-3">
															<input name="port3_qw0" type="text" onmouseover="unlock();" onmouseout="lock();" id="port3_qw0" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw0_3");%>" disabled>
															/ <input name="port3_qw1" type="text" onmouseover="unlock();" onmouseout="lock();" id="port3_qw1" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw1_3");%>" disabled>
															/ <input name="port3_qw2" type="text" onmouseover="unlock();" onmouseout="lock();" id="port3_qw2" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw2_3");%>" disabled>
															/ <input name="port3_qw3" type="text" onmouseover="unlock();" onmouseout="lock();" id="port3_qw3" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw3_3");%>" disabled>
														</td>
														<td class="BG2-3">
															<select name="port3_dscp" class="input2" id="port3_dscp">
																<option selected>ON</option>
																<option>OFF</option>
															</select></td>
														<td class="BG2-3">
															<select name="port3pri" class="input2" id="port3pri">
																<option selected value="0">OFF</option>
																<option value="1">Q0</option>
																<option value="2">Q1</option>
																<option value="3">Q2</option>
																<option value="4">Q3</option>
															</select>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">LAN4</td>
														<td class="BG2-3">
															<select name="port4sch" class="input2" id="port4sch" onchange="changeSelect(this);">
																<option selected value="1">SPQ</option>
																<option value="2">WRR</option>
															</select>
														</td>
														<td class="BG2-3">
															<input name="port4_qw0" type="text" onmouseover="unlock();" onmouseout="lock();" id="port4_qw0" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw0_4");%>" disabled>
															/ <input name="port4_qw1" type="text" onmouseover="unlock();" onmouseout="lock();" id="port4_qw1" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw1_4");%>" disabled>
															/ <input name="port4_qw2" type="text" onmouseover="unlock();" onmouseout="lock();" id="port4_qw2" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw2_4");%>" disabled>
															/ <input name="port4_qw3" type="text" onmouseover="unlock();" onmouseout="lock();" id="port4_qw3" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw3_4");%>" disabled>
														</td>
														<td class="BG2-3">
															<select name="port4_dscp" class="input2" id="port4_dscp">
																<option selected>ON</option>
																<option>OFF</option>
															</select></td>
														<td class="BG2-3">
															<select name="port4pri" class="input2" id="port4pri">
																<option selected value="0">OFF</option>
																<option value="1">Q0</option>
																<option value="2">Q1</option>
																<option value="3">Q2</option>
																<option value="4">Q3</option>
															</select>
														</td>
													</tr>
													<tr>
														<td class="BG2" style="width:140px;">WAN</td>
														<td class="BG2-3">
															<select name="port0sch" class="input2" id="port0sch" onchange="changeSelect(this);">
																<option selected value="1">SPQ</option>
																<option value="2">WRR</option>
															</select>
														</td>
														<td class="BG2-3">
															<input name="port0_qw0" type="text" onmouseover="unlock();" onmouseout="lock();" id="port0_qw0" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw0_0");%>" disabled>
															/ <input name="port0_qw1" type="text" onmouseover="unlock();" onmouseout="lock();" id="port0_qw1" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw1_0");%>" disabled>
															/ <input name="port0_qw2" type="text" onmouseover="unlock();" onmouseout="lock();" id="port0_qw2" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw2_0");%>" disabled>
															/ <input name="port0_qw3" type="text" onmouseover="unlock();" onmouseout="lock();" id="port0_qw3" maxlength="2" size="2" value="<% mcr_getCfgString("QosCfgParam_Qw3_0");%>" disabled>
														</td>
														<td class="BG2-3">
															<select name="port0_dscp" class="input2" id="port0_dscp">
																<option selected>ON</option>
																<option>OFF</option>
															</select></td>
														<td class="BG2-3">
															<select name="port0pri" class="input2" id="port0pri">
																<option selected value="0">OFF</option>
																<option value="1">Q0</option>
																<option value="2">Q1</option>
																<option value="3">Q2</option>
																<option value="4">Q3</option>
															</select>
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
									<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setQoS_New'); return false;"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td height="10">&nbsp;</td>
				</tr>
				<tr>
					<td>
						<input type=hidden name=SETDSCP value="/new/AdminFolder/3_4_4_qos_set.asp" />
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">DSCP 설정</td>
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
											<td colspan="8" class="BG1">DSCP(TOS) 값</td>
										</tr>
										<tr>
											<td class="BG5">7</td>
											<td class="BG5">6</td>
											<td class="BG5">5</td>
											<td class="BG5">4</td>
											<td class="BG5">3</td>
											<td class="BG5">2</td>
											<td class="BG5">1</td>
											<td class="BG5">0</td>
										</tr>
										<tr>
											<td class="BG2-3">
												<select name="pri7" class="input3" id="pri7">
													<option value="0">Q0</option>
													<option value="1">Q1</option>
													<option value="2">Q2</option>
													<option selected  value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri6" class="input3" id="pri6">
													<option value="0">Q0</option>
													<option value="1">Q1</option>
													<option value="2">Q2</option>
													<option selected  value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri5" class="input3" id="pri5">
													<option value="0">Q0</option>
													<option value="1">Q1</option>
													<option selected value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri4" class="input3" id="pri4">
													<option value="0">Q0</option>
													<option value="1">Q1</option>
													<option selected value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri3" class="input3" id="pri3">
													<option value="0">Q0</option>
													<option selected value="1">Q1</option>
													<option value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri2" class="input3" id="pri2">
													<option value="0">Q0</option>
													<option selected value="1">Q1</option>
													<option value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri1" class="input3" id="pri1">
													<option selected value="0">Q0</option>
													<option value="1">Q1</option>
													<option value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="pri0" class="input3" id="pri0">
													<option selected value="0">Q0</option>
													<option value="1">Q1</option>
													<option value="2">Q2</option>
													<option value="3">Q3</option>
												</select>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input name="Apply1" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onclick="form_act('/goform/mcr_setQoSDscp'); return false;"/></td>
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
