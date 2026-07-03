<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.ui-btn-up-a {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #333;
	text-shadow: 0 1px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#dedede),to(#bebebe));
	background-image: -webkit-linear-gradient(#dedede,#bebebe);
	background-image: -moz-linear-gradient(#dedede,#bebebe);
	background-image: -ms-linear-gradient(#dedede,#bebebe);
	background-image: -o-linear-gradient(#dedede,#bebebe);
	background-image: linear-gradient(#dedede,#bebebe);
}

.ui-btn-active-a{
	border:1px solid #bbb;
	background:#bebebe;
	font-weight:bold;
	color:#333;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#bebebe),to(#9e9e9e));
	background-image:-webkit-linear-gradient(#bebebe,#9e9e9e);
	background-image:-moz-linear-gradient(#bebebe,#9e9e9e);
	background-image:-ms-linear-gradient(#bebebe,#9e9e9e);
	background-image:-o-linear-gradient(#bebebe,#9e9e9e);
	background-image:linear-gradient(#bebebe,#9e9e9e);
	font-family:Helvetica,Arial,sans-serif
}

</style>

<script language="javascript" type="text/javascript">

function remove_auth_cache() {
	if($.browser.msie) { 
		document.execCommand("ClearAuthenticationCache");
	}else{
		try {
			xml = new XMLHttpRequest();
			xml.open("GET", "PAGE FROM REALM TO LOGOUT", true, "", "logout"); 
			xml.send("");
			xml.abort();
		} catch(e) { return; }
	}
}

function logoff(){
	remove_auth_cache();
	document.AdminUpgrade.action = "/goform/mcr_KTlogOut";
	document.AdminUpgrade.submit();
}

function initValue() {

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

	$('a[name=btn_apply1]').removeClass('ui-btn-active');
	$('a[name=btn_apply1]').addClass('ui-btn-active-a');

	return true;
}

function AdminUpgrade_Set(url) {
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	subPage(url);
	return false;
}
function AdminUpgrade_Setu(url) {
	if (document.AdminUpgrade.Usb_Filename.value == ""){
		alert("USB장치의 root에 있는 이미지 파일명을 입력해 주세요");
		document.AdminUpgrade.Usb_Filename.focus();
		return false;
	}
	$('a[name=btn_apply3]').removeClass('ui-btn-active');
	$('a[name=btn_apply3]').addClass('ui-btn-active-a');
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
	$('a[name=btn_apply4]').removeClass('ui-btn-active');
	$('a[name=btn_apply4]').addClass('ui-btn-active-a');
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
	$('a[name=btn_apply5]').removeClass('ui-btn-active');
	$('a[name=btn_apply5]').addClass('ui-btn-active-a');
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

</script>

</head>
<body onload="initValue()">
<form method="post" name="AdminUpgrade" data-ajax="false" action="/goform/mcr_setManUpServer" enctype="multipart/form-data">
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;">
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					이미지 업그레이드
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>

	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr style="display:none">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td rowspan="2">SODE 업그레이드</td>
							<td>업그레이드 서버주소</td>
							<td>
								<input name="ManUpServerHost" type="text" id="textfield3" size="18" value="<% mcr_getCfgString("cwmpUserInterface_AutoUpdateHostname");%>">
							</td>
						</tr>
						<tr>
							<td>포트</td>
							<td>
								<input name="ManUpServerPort" type="text" id="textfield" size="20" value="<% mcr_getCfgString("cwmpUserInterface_AutoUpdatePort"); %>">
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td width="50%">
											<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return ManHostFormCheck();" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
										</td>
										<td>
											<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return AdminUpgrade_Set('/goform/mcr_setFwUpgrade_admin');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">업그레이드</a>
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
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>USB 업그레이드</td>
							<td>파일이름</td>
							<td>
								<input name="Usb_Filename" type="text" id="textfield" size="20" maxlength="128">
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<a href="javascript:;" id="btn_apply3" name="btn_apply3" onclick="return AdminUpgrade_Setu('/goform/mcr_setFwUpgrade_usb');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">업그레이드</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr style="display:none">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td rowspan="2">TFTP 업그레이드</td>
							<td>서버주소</td>
							<td>
								<input name="Tftp_Serverip" type="text" id="textfield4" size="21">
							</td>
						</tr>
						<tr>
							<td>파일이름</td>
							<td>
								<input name="Tftp_Filename" type="text" id="textfield8" size="21" maxlength="128">
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<a href="javascript:;" id="btn_apply4" name="btn_apply4" onclick="return AdminUpgrade_Sett('/goform/mcr_setFwUpgrade_tftp');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">업그레이드</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr style="display:none">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td rowspan="4">FTP 업그레이드</td>
							<td>서버주소</td>
							<td>
								<input name="Ftp_Serverip" type="text" id="textfield9" size="21" maxlength="128">
							</td>
						</tr>
						<tr>
							<td>ID</td>
							<td>
								<input name="Ftp_Userid" type="text" id="textfield5" size="18" maxlength="128">
							</td>
						</tr>
						<tr>
							<td>비밀번호</td>
							<td>
								<input type="text" id="user_id_fake" name="user_id_fake" autocomplete="off" style="display: none;">
								<input type="password" id="user_id_fake" name="user_pwd_fake" autocomplete="off" style="display: none;">
								<input name="Ftp_Passwd" type="password" id="textfield6" size="20" maxlength="128">
							</td>
						</tr>
						<tr>
							<td>파일이름</td>
							<td>
								<input name="Ftp_Filename" type="text" id="textfield2" size="25" maxlength="128">
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<a href="javascript:;" id="btn_apply5" name="btn_apply5" onclick="return AdminUpgrade_Setf('/goform/mcr_setFwUpgrade_ftp');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">업그레이드</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#eleventhPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
