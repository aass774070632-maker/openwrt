<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템관리</title>
<%include('new/script.asp');%>
<script language="JavaScript" type="text/javascript" src="/script/simpleUpload.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script type="text/javascript">

var beforId= "menu06";

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

	selectMenu3rd();

	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}
function InitValue() {

	changeTable();

	down_type = "<% mcr_getCfgCommon("UpgradeCfgParam_Download_type"); %>";
	if (down_type == "1"){
		;
	} else if (down_type == "3"){
		document.AdminUpgrade.Usb_Filename.value = "";
	} 

}

function AdminUpgrade_Setu(url) {
	if (document.AdminUpgrade.Usb_Filename.value == ""){
		alert("USB장치의 root에 있는 이미지 파일명을 입력해 주세요");
		document.AdminUpgrade.Usb_Filename.focus();
		return false;
	}
	subPage(url);
	return false;
}

function subPage(url){
	document.AdminUpgrade.action = url;
	document.AdminUpgrade.method = "post";
	document.AdminUpgrade.enctype = "multipart/form-data";
	document.body.style.cursor = 'wait';
	document.AdminUpgrade.submit();
}

function selectMenu3rd(){
	$("#menu06").removeClass("menu3rdNormal").addClass("menu3rdSelect");
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

<body onload="InitValue();">
<form method="post" name="AdminUpgrade" enctype="multipart/form-data">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/UserFolder/3_7_7_image_upgrade.asp">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top" cellspacing="0" cellpadding="0">
			<%include('new/UserFolder/3_7_menu3rd.asp');%>
			</td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">이미지 업그레이드</td>
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
											<td height="25" class="BG2" style="width:140px;">USB 업그레이드</td>
											<td class="BG2-2" colspan="2">
												<table border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">파일이름</td>
														<td width="5"></td>
														<td width="110">
															<input name="Usb_Filename" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield" size="20" maxlength="128">
														</td>
														<td width="18"></td>
														<td width="5">
														</td>
														<td>
															<input name="Apply" type="image" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24" onclick="return AdminUpgrade_Setu('/goform/mcr_setFwUpgrade_usb');">
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
</table>
</form>
</body>
</html>
