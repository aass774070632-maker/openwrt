<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템관리</title>
<%include('new/script.asp');%>
<script language='JavaScript' type='text/javascript' src='/script/simpleUpload.min.js?version=<% mcr_getWebVersion(); %>'></script>
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
	} else if (down_type == "2"){
		document.AdminUpgrade.Tftp_Serverip.value = "";
		document.AdminUpgrade.Tftp_Filename.value = "";
	} else if (down_type == "3"){
		document.AdminUpgrade.Usb_Filename.value = "";
	} else if (down_type == "4"){
		document.AdminUpgrade.Ftp_Serverip.value = "";
		document.AdminUpgrade.Ftp_Userid.value ="";
		document.AdminUpgrade.Ftp_Passwd.value ="";
		document.AdminUpgrade.Ftp_Filename.value = "";
	} 

}
function ManHostFormCheck()
{
	if( document.AdminUpgrade.ManUpServerHost.value == "") {
		alert("수동 업그레이드 서버를 입력해 주세요(예) upgrade.ktsode.com,211.38.63.169, 220.123.31.59");
		document.AdminUpgrade.ManUpServerHost.focus();
		return false;
	}
	if( document.AdminUpgrade.ManUpServerPort.value < 0 ||
			document.AdminUpgrade.ManUpServerPort.value > 65535 ) {
		alert("수동 업그레이드 서버의 Port를 입력해 주세요(0~65535, 예) 9443, 8443");
		document.AdminUpgrade.ManUpServerPort.focus();
		return false;
	}
	return true;
}
function AdminUpgrade_Set(url) {
	subPage(url);
	return false;
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
function AdminUpgrade_Sett(url) {
	if (document.AdminUpgrade.Tftp_Serverip.value == ""){
		alert("TFTP서버의 주소를 입력해 주세요");
		document.AdminUpgrade.Tftp_Serverip.focus();
		return false;
	}
	if (document.AdminUpgrade.Tftp_Filename.value == ""){
		alert("TFTP서버에 있는 이미지 파일명을 입력해 주세요");
		document.AdminUpgrade.Tftp_Filename.focus();
		return false;
	}
	subPage(url);
	return false;
}
function AdminUpgrade_Setf(url) {
	if (document.AdminUpgrade.Ftp_Serverip.value == ""){
		alert("FTP서버의 주소를 입력해 주세요");
		document.AdminUpgrade.Ftp_Serverip.focus();
		return false;
	}
	if (document.AdminUpgrade.Ftp_Userid.value == ""){
		alert("FTP서버에 접속할 계정을 입력해 주세요");
		document.AdminUpgrade.Ftp_Userid.focus();
		return false;
	}
	if (document.AdminUpgrade.Ftp_Passwd.value == ""){
		alert("FTP서버에 접속할 계정의 비밀번호를 입력해 주세요");
		document.AdminUpgrade.Ftp_Passwd.focus();
		return false;
	}
	if (document.AdminUpgrade.Ftp_Filename.value == ""){
		alert("FTP서버에 있는 이미지 파일명을 입력해 주세요");
		document.AdminUpgrade.Ftp_Filename.focus();
		return false;
	}
	subPage(url);
	return false;
}

function Select_PCFile()
{
	document.AdminUpgrade.PC_Filename.value=document.AdminUpgrade.filename.value;
	chk_rlt = Chk_InputFile(document.AdminUpgrade.filename.value);
}
function AdminUpgrade_Setp(url)
{
	chk_rlt = Chk_InputFile(document.AdminUpgrade.filename.value);
	if(chk_rlt == true){
		subPage(url);
		return false;
	}
	return chk_rlt;
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

$(document).ready(function(){
	$("#ti_search").click(function() {
		$("#tf_upload").focus().click();
		return false;
	});

	$("#tf_upload").change(function(){
		var fileToUpload = $("#tf_upload").prop("files")[0];
		if( isEmpty( fileToUpload ) == false ){
			$("#tt_filename_pc").val(fileToUpload.name);
		}
	});
	$("#ti_submit_pc").click(function() {
		if(isEmpty(document.AdminUpgrade.filename.value) == false){
			$("#tf_upload").simpleUpload("../upload.asp", {
				limit: 1,
				allowedExts: ["bin"],

				start: function(file){
				},
				progress: function(progress){
				},
				success: function(data){
					AdminUpgrade_Setp('/goform/mcr_setFwUpgrade_pc');
					return false;
				},
				error: function(error){
					if( error.name == "InvalidFileExtensionError" ){
						alert("이미지 파일을 선택해주세요");
					}
					if( error.name == "MaxFileSizeError"){
						alert("이미지 용량이 너무 큽니다");
					}
				}
			});
		}else{
			AdminUpgrade_Setp('/goform/mcr_setFwUpgrade_pc');
		}
		return false;
	});
});
</script>

</head>

<body onload="InitValue();">
<form method="post" name="AdminUpgrade" action="/goform/mcr_setManUpServer" enctype="multipart/form-data">
<input name="redirect_url" type="hidden" id="redirect_url" value="/new/AdminFolder/3_7_7_image_upgrade.asp" />
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top" cellspacing="0" cellpadding="0"> 
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
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
										<tr id="sode_up">
											<td rowspan="2" class="BG2" style="width:140px;">SODE 업그레이드</td>
											<td height="25" class="BG2-2" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">업그레이드 서버주소</td>
														<td width="5"</td>
														<td width="110">
															<input name="ManUpServerHost" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield3" size="18" value="<% mcr_getCfgString("cwmpUserInterface_AutoUpdateHostname");%>" /> 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="sode_up2">
											<td height="25" class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">포트</td>
														<td width="5"></td>
														<td width="110"><input name="ManUpServerPort" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield" size="20" value="<% mcr_getCfgString("cwmpUserInterface_AutoUpdatePort"); %>" /></td>
														<td width="18"></td>
														<td width="5">
														</td>
														<td>
                                                                                                			<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="" width="52" height="24" onClick="return ManHostFormCheck()" />
														</td>
														<td width="5">
														</td>
														<td>
                                                                                                			<input name="Apply" type="image" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24" onClick="return AdminUpgrade_Set('/goform/mcr_setFwUpgrade_admin');" />
                                                                                        			</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td height="25" class="BG2" style="width:140px;">USB 업그레이드</td>
											<td class="BG2-2" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">파일이름</td>
														<td width="5"></td>
														<td width="110">
															<input name="Usb_Filename" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield" size="20"  maxlength="128"/>
														</td>
														<td width="18"></td>
														<td width="5">
														</td>
														<td>
															<input name="Apply" type="image" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24" onClick="return AdminUpgrade_Setu('/goform/mcr_setFwUpgrade_usb');" />
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tftp_up">
											<td rowspan="2" class="BG2" style="width:140px;">TFTP 업그레이드</td>
											<td height="25" class="BG2-2" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">서버주소</td>
														<td width="5"></td>
													
														<td width="110"><input name="Tftp_Serverip" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield4" size="128" /></td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="tftp_up2">
											<td height="25" class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">파일이름</td>
														<td width="5"></td>
														<td width="110"><input name="Tftp_Filename" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield8" size="21"  maxlength="128"/></td>
														<td width="18"></td>
														<td width="5"></td>
														<td width="100"><input name="Apply" type="image" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24" onClick="return AdminUpgrade_Sett('/goform/mcr_setFwUpgrade_tftp');" /></td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="ftp_up">
											<td rowspan="3" class="BG2" style="width:140px;">FTP 업그레이드</td>
											<td height="25" class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">서버주소</td>
														<td width="5"></td>
														<td width="110"><input name="Ftp_Serverip" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield9" size="21" maxlength="128" /></td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="ftp_up2">
											<td height="25" class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														 <td width="120" class="BG2-2">ID</td>
														<td width="5"></td>
														<td width="110">
															<input type="text" id="user_id_fake" name="user_id_fake" autocomplete="off" style="display: none;">
															<input name="Ftp_Userid" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="Ftp_Userid" size="18" maxlength="128" value="" autocomplete="off"/></td>
														<td width="35"></td>
														<td width="100" class="BG2-2">비밀번호</td>
														<td>
															<input type="password" id="user_pwd_fake" name="user_pwd_fake" autocomplete="off" style="display: none;">
															<input name="Ftp_Passwd" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield6" size="20" maxlength="128" value="" autocomplete="off"/></td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="ftp_up3">
											<td height="25" class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">파일이름</td>
														<td width="5"></td>
														<td width="110"><input name="Ftp_Filename" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="textfield2" size="25" maxlength="128"/></td>
														<td width="18"></td>
														<td width="5"></td>
														<td width="100"><input name="Apply" type="image" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24" onClick="return AdminUpgrade_Setf('/goform/mcr_setFwUpgrade_ftp');" /></td>
													</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td height="25" class="BG2" style="width:140px;">PC 업그레이드</td>
											<td class="BG2-2" width="600" colspan="2">
												<table  border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="120" class="BG2-2">파일이름</td>
														<td width="5"></td>
														<td width="110"> 
															<div>
																<input type="text" name="filename" id="tt_filename_pc" onmouseover="unlock();" onmouseout="lock();" class="input2-1" readonly="true" style="vertical-align:bottom;"/>
															</div>
														</td>
														<td width="18"></td>
														<td width="5"></td>
														<td class="BG2-2" style="padding-left: 0px;">
															<input type="file" id="tf_upload" style="display:none;" accept=".bin" />
															<input type="image" id="ti_search"  src="/images/BTN/BTN_18.gif?Sp2" />
														</td>
														<td class="BG2-2">
															<input name="Apply" type="image" id="ti_submit_pc" src="/images/BTN/BTN_19.gif?Sp2" alt="" width="85" height="24"  style="vertical-align:bottom;"/>
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
