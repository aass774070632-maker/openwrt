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

var beforId = "menu00";

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

function form_act(url){
	parent.mcrProgress.startProgressSimple("apply",15);
	form_portcfg.action = url;
	form_portcfg.submit();
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

function pause_set(id, val)
{
	var value = parseInt(val , 10 );
	if(value){
		$('#'+id).removeAttr("disabled");
	}else{
		$('#'+id).attr("disabled","disabled");
		$('#'+id).val("0");
	}
}

function initValue() {
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	parent.mcrProgress.stopProgress();
	p0_s = <% mcr_getLanPortStatus(0,6); %>;
	p1_s = <% mcr_getLanPortStatus(1,6); %>;
	p2_s = <% mcr_getLanPortStatus(2,6); %>;
	p3_s = <% mcr_getLanPortStatus(3,6); %>;
	p4_s = <% mcr_getLanPortStatus(4,6); %>;
	p0_f = <% mcr_getLanPortStatus(0,7); %>;
	p1_f = <% mcr_getLanPortStatus(1,7); %>;
	p2_f = <% mcr_getLanPortStatus(2,7); %>;
	p3_f = <% mcr_getLanPortStatus(3,7); %>;
	p4_f = <% mcr_getLanPortStatus(4,7); %>;
	p0_fm = <% mcr_getLanPortStatus(0,8); %>;
	p1_fm = <% mcr_getLanPortStatus(1,8); %>;
	p2_fm = <% mcr_getLanPortStatus(2,8); %>;
	p3_fm = <% mcr_getLanPortStatus(3,8); %>;
	p4_fm = <% mcr_getLanPortStatus(4,8); %>;

	changeTable();

	document.form_portcfg.port0_an.options.selectedIndex = p0_s;
	document.form_portcfg.port1_an.options.selectedIndex = p1_s;
	document.form_portcfg.port2_an.options.selectedIndex = p2_s;
	document.form_portcfg.port3_an.options.selectedIndex = p3_s;
	document.form_portcfg.port4_an.options.selectedIndex = p4_s;

	document.form_portcfg.port0_fc.options.selectedIndex = p0_f;
	document.form_portcfg.port1_fc.options.selectedIndex = p1_f;
	document.form_portcfg.port2_fc.options.selectedIndex = p2_f;
	document.form_portcfg.port3_fc.options.selectedIndex = p3_f;
	document.form_portcfg.port4_fc.options.selectedIndex = p4_f;

	pause_set("port0_fcm", p0_f);
	pause_set("port1_fcm", p1_f);
	pause_set("port2_fcm", p2_f);
	pause_set("port3_fcm", p3_f);
	pause_set("port4_fcm", p4_f);

	document.form_portcfg.port0_fcm.options.selectedIndex = p0_fm;
	document.form_portcfg.port1_fcm.options.selectedIndex = p1_fm;
	document.form_portcfg.port2_fcm.options.selectedIndex = p2_fm;
	document.form_portcfg.port3_fcm.options.selectedIndex = p3_fm;
	document.form_portcfg.port4_fcm.options.selectedIndex = p4_fm;
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
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js">
</script>
</head>

<body onload="initValue();">
<form name="form_portcfg">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/AdminFolder/3_3_1_port_link_set.asp" />
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
								<td class="font5">포트 링크 설정</td>
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
											<td width="200">　</td>
											<td colspan="3" class="BG1">현재 상태</td>
											<td colspan="4" class="BG1">설정 상태</td>
										</tr>
										<tr>
											<td class="font2-1" width="200">포트이름</td>
											<td width="10%" class="BG5">Link</td>
											<td width="10%" class="BG5">Speed</td>
											<td width="10%" class="BG5">Duplex</td>
											<td width="15%" class="BG5">포트설정</td>
											<td width="15%" class="BG5">Pause설정</td>
											<td width="15%" class="BG5">Pause모드</td>
											<td width="10%" class="BG5">포트리셋</td>
										</tr>
										<tr>
											<td class="BG2" width="200">LAN1</td>
											<td class="BG2-3"><% mcr_getLanPortStatus(1,2); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(1,4); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(1,5); %></td>
											<td class="BG2-3">
												<select name="port1_an" class="input2" id="port1_an">
													<option value="0">Port disable</option>
													<option selected value="1">Auto nego</option>
													<option value="2">1G full</option>
													<option value="3">100M full</option>
													<option value="4">100M half</option>
													<option value="5">10M full</option>
													<option value="6">10M half</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port1_fc" class="input2" id="port1_fc" onchange="pause_set('port1_fcm',this.value);">
													<option selected value="0">비활성</option>
													<option value="1">활성</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port1_fcm" class="input2" id="port1_fcm">
													<option selected value="0">없음</option>
													<option value="1">수신</option>
													<option value="2">발신</option>
													<option value="3">수발신</option>
												</select>
											</td>
											<td class="BG2-3"><input type="checkbox" name="port1_reset" id="port1_reset" value="1"/></td>
										</tr>
										<tr>
											<td class="BG2" width="200">LAN2</td>
											<td class="BG2-3"><% mcr_getLanPortStatus(2,2); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(2,4); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(2,5); %></td>
											<td class="BG2-3">
												<select name="port2_an" class="input2" id="port2_an">
													<option value="0">Port disable</option>
													<option selected value="1">Auto nego</option>
													<option value="2">1G full</option>
													<option value="3">100M full</option>
													<option value="4">100M half</option>
													<option value="5">10M full</option>
													<option value="6">10M half</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port2_fc" class="input2" id="port2_fc" onchange="pause_set('port2_fcm',this.value);">
													<option selected value="0">비활성</option>
													<option value="1">활성</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port2_fcm" class="input2" id="port2_fcm">
													<option selected value="0">없음</option>
													<option value="1">수신</option>
													<option value="2">발신</option>
													<option value="3">수발신</option>
												</select>
											</td>
											<td class="BG2-3"><input type="checkbox" name="port2_reset" id="port2_reset" value="1"/></td>
										</tr>
										<tr>
											<td class="BG2" width="200">LAN3</td>
											<td class="BG2-3"><% mcr_getLanPortStatus(3,2); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(3,4); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(3,5); %></td>
											<td class="BG2-3">
												<select name="port3_an" class="input2" id="port3_an">
													<option value="0">Port disable</option>
													<option selected value="1">Auto nego</option>
													<option value="2">1G full</option>
													<option value="3">100M full</option>
													<option value="4">100M half</option>
													<option value="5">10M full</option>
													<option value="6">10M half</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port3_fc" class="input2" id="port3_fc" onchange="pause_set('port3_fcm',this.value);">
													<option selected value="0">비활성</option>
													<option value="1">활성</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port3_fcm" class="input2" id="port3_fcm">
													<option selected value="0">없음</option>
													<option value="1">수신</option>
													<option value="2">발신</option>
													<option value="3">수발신</option>
												</select>
											</td>
											<td class="BG2-3"><input type="checkbox" name="port3_reset" id="port3_reset" value="1"/></td>
										</tr>
										<tr>
											<td class="BG2" width="200">LAN4</td>
											<td class="BG2-3"><% mcr_getLanPortStatus(4,2); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(4,4); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(4,5); %></td>
											<td class="BG2-3">
												<select name="port4_an" class="input2" id="port4_an">
													<option value="0">Port disable</option>
													<option selected value="1">Auto nego</option>
													<option value="2">1G full</option>
													<option value="3">100M full</option>
													<option value="4">100M half</option>
													<option value="5">10M full</option>
													<option value="6">10M half</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port4_fc" class="input2" id="port4_fc" onchange="pause_set('port4_fcm',this.value);">
													<option selected value="0">비활성</option>
													<option value="1">활성</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port4_fcm" class="input2" id="port4_fcm">
													<option selected value="0">없음</option>
													<option value="1">수신</option>
													<option value="2">발신</option>
													<option value="3">수발신</option>
												</select>
											</td>
											<td class="BG2-3"><input type="checkbox" name="port4_reset" id="port4_reset" value="1"/></td>
										</tr>
										<tr>
											<td class="BG2" width="200">WAN</td>
											<td class="BG2-3"><% mcr_getLanPortStatus(0,2); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(0,4); %></td>
											<td class="BG2-3"><% mcr_getLanPortStatus(0,5); %></td>
											<td class="BG2-3">
												<select name="port0_an" class="input2" id="port0_an">
													<option value="0">Port disable</option>
													<option selected value="1">Auto nego</option>
													<option value="2">1G full</option>
													<option value="3">100M full</option>
													<option value="4">100M half</option>
													<option value="5">10M full</option>
													<option value="6">10M half</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port0_fc" class="input2" id="port0_fc" onchange="pause_set('port0_fcm',this.value);">
													<option selected value="0">비활성</option>
													<option value="1">활성</option>
												</select>
											</td>
											<td class="BG2-3">
												<select name="port0_fcm" class="input2" id="port0_fcm">
													<option selected value="0">없음</option>
													<option value="1">수신</option>
													<option value="2">발신</option>
													<option value="3">수발신</option>
												</select>
											</td>
											<td class="BG2-3"><input type="checkbox" name="port0_reset" id="port0_reset" value="1"/></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" value="Apply" id="btn_apply" name="btn_apply" onclick="form_act('/goform/mcr_setPortLan');"/></td>
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
