<html>
<head>
<%include('new/metatag.asp');%>
<title>홈네트워크설정</title>
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

var beforId = "menu02";

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

function changeTableA() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}

function changeHomeNetwork() {
	parent.mcrProgress.startProgressSimple("apply", 5);
}

function selectMenu3rd(){
	$("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function initValue() {
	selectMenu3rd();

	parent.mcrProgress.stopProgress();    	
	changeTableA();

	var igd_inform = <% mcr_getCfgString("NatAlgCfgParam_upnpEnable"); %>;

	if(igd_inform == 1)
		document.natra.upnp_en[0].checked = true;
	else
		document.natra.upnp_en[1].checked = true;
}

function initValue_otv(){
	var otvEnable;
	otvEnable = '<% mcr_getCfgCommon("OTVCfgParam_Enable"); %>';
	
	initRadioByName("otvEnable", otvEnable);
}

$(document).ready(function(){
	$("#btnOTVApply").bind( "click", function(){
		$('#natra').attr("action", "/goform/mcr_KT_setOTV").submit();
		parent.mcrProgress.startProgressSimple("apply", 5);
		return true;
	});	

	initValue_otv();
});


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

<body onload="initValue()">
<form action=/goform/mcr_setNatRaConf method=post name="natra" id="natra">
<input type="hidden" name="SETUPNP" value="/new/AdminFolder/3_6_3_home_network_set.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_6_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="200" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">홈 네트워크 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">UPnP IGD</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="upnp_en" id="aupnpE" value="1" />
															활성
														</td>
														<td>
															<input type="radio" name="upnp_en" id="aupnpD" value="0" />
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onClick="return changeHomeNetwork()" /></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<!--    <tr id="otv_set">
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="200" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr><td class="font5">OTV 기능 설정</td></tr>
							<tr><td class="PD4"></td></tr>
							<tr><td class="PD5"></td></tr>
							<tr>
								<td>
									<table class="TB" width="100%" border="0">
										<tr>
											<td height="25" class="BG2" style="width:140px;">OTV 사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="otvEnable" value="1" />
																<label>활성</label>
														</td>
														<td>
															<input type="radio" name="otvEnable" value="0" />
																<label>비활성</label>
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input type="image" src="/images/BTN/BTN_01.gif?Sp2" value="btnOTVApply" id="btnOTVApply" name="btnOTVApply" width="52" height="24"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr> -->
</table>
</form>
</body>
</html>
