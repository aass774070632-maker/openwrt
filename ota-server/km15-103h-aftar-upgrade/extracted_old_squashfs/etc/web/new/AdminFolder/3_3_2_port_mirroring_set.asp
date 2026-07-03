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

var beforId = "menu01";

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

function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function setPortCtl(arg){
	switch(arg){
		case '1':   
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").hide();
			$("#tr_5").show();
			break;
		case '0':	
			$("#tr_1").hide();
			$("#tr_2").hide();
			$("#tr_3").hide();
			$("#tr_4").hide();
			$("#tr_5").hide();
			break;
	}
	changeTable();
}

function setModeCtl(arg){
	switch(arg){
		case '1':   
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").hide();
			$("#tr_5").show();
			break;
		case '2':	
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").hide();
			$("#tr_4").show();
			$("#tr_5").show();
			break;
		case '3':	
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").show();
			$("#tr_5").show();
			break;

	}
	changeTable();
}

function CheckValue()
{
	if (document.form_mirror.mirror_en[1].checked)
		return true;

	var mode = $("input[name='mirror_mode']:checked").val(); 
	var rxport = $("input[name='mirror_rx']:checked").val(); 
	var txport = $("input[name='mirror_tx']:checked").val(); 
	var monport = $("input[name='monitor']:checked").val(); 

	if(monport == "0") {
		if(mode == "1") {
			if( rxport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "0" || txport == "0") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "1") {
		if(mode == "1") {
			if( rxport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "1" || txport == "1") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "2") {
		if(mode == "1") {
			if( rxport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "2" || txport == "2") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	else if(monport == "3") {
		if(mode == "1") {
			if( rxport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else if(mode == "2") {
			if( txport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
		else {
			if( rxport == "3" || txport == "3") {
				alert("모니터할 포트와 미러포트는 서로다르게 설정해야합니다");
				return false;
			}
		}
	}
	return true;
}

function initValue() {

	var m_en, m_mode, m_rx, m_tx, m_mon;

	$("#menu01").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	m_en = '<% mcr_getCfgString("PortMirrorParam_Enable"); %>';
	m_mode = '<% mcr_getCfgString("PortMirrorParam_Mode"); %>';
	m_rx = '<% mcr_getCfgString("PortMirrorParam_RxPort"); %>';
	m_tx = '<% mcr_getCfgString("PortMirrorParam_TxPort"); %>';
	m_mon = '<% mcr_getCfgString("PortMirrorParam_MPort"); %>';

	initRadioByName("mirror_en", m_en);
	if(m_mode == '0')
		m_mode = '1';
	initRadioByName("mirror_mode", m_mode);
	initRadioByName("mirror_rx", m_rx);
	initRadioByName("mirror_tx", m_tx);
	initRadioByName("monitor", m_mon);

	if(m_en=='1') 
		setModeCtl(m_mode);
	else
		changeTable();
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
<form name="form_mirror" id="form_mirror" action="/goform/mcr_setPortMirror" onSubmit="return CheckValue()">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/AdminFolder/3_3_2_port_mirroring_set.asp">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_3_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">포트 미러링 설정</td>
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
											<td style="width:140px" height="10" class="BG2">포트 미러링</td>
											<td height="10" colspan="5" class="BG2-2">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="mirror_en" id="mirror_en" value="1" OnClick="setPortCtl(this.value)" >
															활성
														</td>
														<td>
															<input name="mirror_en" type="radio" id="mirror_en1" value="0" OnClick="setPortCtl(this.value)">
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id = "tr_1" style="display:none">
											<td rowspan="5" class="BG2" style="width:140px;">모드</td>
											<td colspan="5" class="BG2-2">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="mirror_mode" id="mirror_mode" value="1" OnClick="setModeCtl(this.value)">
															Rx
														</td>
														<td width="110">
															<input type="radio" name="mirror_mode" id="mirror_mode1" value="2" OnClick="setModeCtl(this.value)">
															Tx</td>
														<td>
															<input name="mirror_mode" type="radio" id="mirror_mode2" value="3" OnClick="setModeCtl(this.value)">
															Rx and Tx
														</td>
												  </tr>
												</table>
											</td>
										</tr>
										<tr id = "tr_2" style="display:none">
											<td height="8" class="BG1">　</td>
											<td height="8" class="BG1">LAN1</td>
											<td height="8" class="BG1">LAN2</td>
											<td height="8" class="BG1">LAN3</td>
											<td height="8" class="BG1">LAN4</td>
										</tr>
										<tr id = "tr_3" style="display:none">
											<td height="10" valign="middle" class="BG2-3">Rx포트</td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_rx" id="mirror_rx" value="0" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_rx" id="mirror_rx1" value="1" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_rx" id="mirror_rx2" value="2" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_rx" id="mirror_rx3" value="3" /></td>
										</tr>
										<tr id = "tr_4" style="display:none">
											<td height="10" valign="middle" class="BG2-3">Tx포트</td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_tx" id="mirror_tx" value="0" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_tx" id="mirror_tx1" value="1" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_tx" id="mirror_tx2" value="2" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="mirror_tx" id="mirror_tx3" value="3" /></td>
										</tr>
										<tr id = "tr_5" style="display:none">
											<td width="15%" height="10" valign="middle" class="BG2-3">미러 포트</td>
											<td height="10" class="BG2-3"><input type="radio" name="monitor" id="monitor" value="0" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="monitor" id="monitor1" value="1" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="monitor" id="monitor2" value="2" /></td>
											<td height="10" class="BG2-3"><input type="radio" name="monitor" id="monitor3" value="3" /></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply"/></td>
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
