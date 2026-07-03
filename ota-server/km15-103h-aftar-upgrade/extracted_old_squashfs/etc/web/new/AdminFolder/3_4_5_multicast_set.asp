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
	var arrData = new Array();

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

function chgIgmp(){
	if(form_igmp.igmpEn[0].checked) {
		$("#tr_1").show();
		$("#tr_2").show();
		$("#tr_3").show();
	}
	else if (form_igmp.igmpEn[1].checked) {
		$("#tr_1").hide();
		$("#tr_2").hide();
		$("#tr_3").hide();
	}
}

function initValue(){
	$("#menu04").removeClass("menu3rdNormal").addClass("menu3rdSelect");

	var igmpen = "<% mcr_getCfgString("IpMulticastCfgParam_Enable"); %>";
	var igmpproxyen = "<% mcr_getCfgString("IpMulticastCfgParam_Proxy_Enable"); %>";
	var igmpfastleave = "<% mcr_getCfgString("IpMulticastCfgParam_Fast_leave"); %>";

	changeTable();

	initRadioByName("igmpEn", igmpen);
	initRadioByName("igmpProxyEn", igmpproxyen);

	if(igmpfastleave == "1") 
		document.form_igmp.igmpFastLeave.checked = true;
	else
		document.form_igmp.igmpFastLeave.checked = false;

	chgIgmp();
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
<form method=post name="form_igmp" action="/goform/mcr_setIgmp_New">
<input type=hidden name=SETIGMP value="/new/AdminFolder/3_4_5_multicast_set.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top" height="145">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">멀티캐스트 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">IGS 설정</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="igmpEn" id="igmpEn" value="1" OnClick="chgIgmp()" />
															활성
														</td>
														<td>
															<input name="igmpEn" type="radio" id="igmpEn1" value="0" OnClick="chgIgmp()"  />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tr_1">
											<td class="BG2" style="width:140px;">Proxy 설정</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="igmpProxyEn" id="igmpProxyEn" value="1" />
															활성
														</td>
														<td>
															<input name="igmpProxyEn" type="radio" id="igmpProxyEn1" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tr_2">
											<td class="BG2" style="width:140px;">Fast Leave 활성</td>
											<td class="BG2-2" width="600"><input name="igmpFastLeave" type="checkbox" id="igmpFastLeave" /></td>
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
				<tr id="tr_3">
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">IGMP 테이블</td>
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
											<td width="50%" class="BG1">Group Address</td>
											<td class="BG1">Port</td>
										</tr>

										<script language="JavaScript" type="text/javascript">
											var i,j;
											var all_str = "<% mcr_getIgmpGroupTable_New(); %>";

											if (all_str == "") {
												document.write("<tr bgcolor=#FFFFFF>");
												document.write("<td align=center colspan=2 id=IgmpGroupNone> 그룹 정보가 없습니다. </td>");
												document.write("</tr>\n");
											}
											else {
												var entries = all_str.split(";");
												for(i=0; i<entries.length; i++)
													arrData[i] = entries[i].split(",");

												for(i=0; i<entries.length; i++){
													document.write("<tr bgcolor=#FFFFFF>");

													for(j=0;j<2;j++) {
														document.write("<td class=BG2-2>");
														if( arrData[i][j] == null || arrData[i][j].length == 0 ){
															document.write("");
														}else{
															document.write(arrData[i][j]);
														}
														document.write("</td>");
													}
													document.write("</tr>\n");
												}
											}
										</script>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_12.gif?Sp2" alt="" width="71" height="24" value="Reset" name="refresh" onClick="window.location.reload()"/></td>
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
