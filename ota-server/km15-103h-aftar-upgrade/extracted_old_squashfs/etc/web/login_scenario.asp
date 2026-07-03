<HTML>
<HEAD>
<TITLE>GiGA WiFi home</TITLE>
<LINK REL="shortcut icon" HREF="icon.ico" TYPE="image/x-icon">
<LINK REL="icon" HREF="icon.ico" TYPE="image/x-icon">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<%include('new/script.asp');%>
<style type="text/css">
<!--
a { font-style:normal; font-weight:normal; text-decoration:none; }
body {
        margin-left: 10px;
        margin-top: 10px;
        margin-right: 10px;
        margin-bottom: 10px;
        background-color: #ffffff;
}

.table {
        border-top-width: 2px;
        border-top-style: solid;
        border-top-color: #333333;
}
.font100 {
	FONT-FAMILY: "돋움",  "arial";
	FONT-SIZE: 14px;
	LINE-HEIGHT: 14pt;
	COLOR: #000000
}
.font101 {
	FONT-FAMILY: "돋움",  "arial";
	FONT-SIZE: 12px;
	LINE-HEIGHT: 12pt;
	COLOR: #666666
}
-->


</style>
<script language="JavaScript" type="text/javascript" src="/script/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/script/captcha.js?version=<% mcr_getWebVersion(); %>"></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_crypt.js?version=<% mcr_getWebVersion(); %>'></script>
<script type="text/javascript" src="/lang/b28n.js"></script>
<script type="text/javascript">

Butterlate.setTextDomain("main");

redirectTopWindow();

function redirectTopWindow(){
        if( top != self ){
                var URL = "http://" + window.location.host;
                top.location.replace(URL);
        }
}
var captcha;

function CheckAll()
{
	if(parseInt(Base64.decode("<% mcr_getAccountInfo(4); %>"), 10)) {
		if( captcha.validate( $("input[name='captchatext']").val() ) == true ){
			if(document.Login.UserID.value == "")
			{
				alert("사용자ID를 확인해 주세요.");
				document.Login.UserID.focus();
				return false;
			}
			if(document.Login.Password.value == "")
			{
				alert("비밀번호를 확인해 주세요.");
				document.Login.Password.focus();
				return false;
			}
		}else{
			document.Login.captchatext.clear();
			return false;
		}
	}else{
		if(document.Login.UserID.value == "")
		{
			alert("사용자ID를 확인해 주세요.");
			document.Login.UserID.focus();
			return false;
		}
		if(document.Login.Password.value == "")
		{
			alert("비밀번호를 확인해 주세요.");
			document.Login.Password.focus();
			return false;
		}
	}
	return true;
}

function initValue() {
	var RememberID = Base64.decode("<% mcr_getAccountInfo(3); %>");

	if(parseInt(Base64.decode("<% mcr_getAccountInfo(4); %>"), 10)) {
		document.Login.UserID.value = Base64.decode("<% mcr_getAccountInfo(1); %>");
		document.Login.Password.value= Base64.decode("<% mcr_getAccountInfo(2); %>");
	}

	if(RememberID.length > 0) {
		document.Login.check_box.checked = true;
		document.Login.UserID.value = RememberID;
	} else {
		document.Login.check_box.checked = false;
	}

	if(parseInt(Base64.decode("<% mcr_getAccountInfo(4); %>"), 10)) {
		$("#captcha_tb").show();
	} else {
		$("#captcha_tb").hide();
	}

	document.Login.UserID.focus();
	refreshCaptcha();
}

function form_act(url){
	if(!CheckAll())
		return false;
	Login.target = "";
	Login.action = url;
	Login.submit();
	return false;
}
function removeCookie(name) {
    setCookie(name,"", 0, "", "", "");
}

window.onkeydown = function() {
        var kcode = event.keyCode;
            if(kcode == 116) removeCookie('acookie');
}
function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function changeBtn_Click(clickId, pageUrl){
	var changeImage;

	changeImage = (document.getElementById(clickId).src).replace('select', 'default');

	document.getElementById(clickId).src = changeImage;

	form_act(pageUrl);
}
function refreshCaptcha()
{
    var canvasdiv = $("canvas").parent(); if(canvasdiv){ canvasdiv.remove(); }
    var canvas = $("canvas"); if(canvas){ canvas.remove(); }

    captcha = new CAPTCHA({
    selector: '#mcr_captcha',
    width: 250,
    height: 70,
    onSuccess: function () { return true; }
    });

    captcha.generate();
}
</script>
</head>
<body onLoad="initValue()" oncontextmenu='return false' ondragstart='return false' onselectstart='return false'>
<form method="post" name="Login">
<input type="hidden" id="is_mobile" name="is_mobile" value="1"/>	
<input type="hidden" id="captchadata" name="captchadata" value=""/>
<input name="redirect_url" type="hidden" id="redirect_url" value="/login.asp" />

<table border="0" cellpadding="0" cellspacing="0" style="font-size:10px" width="990" height="600">
	<tr>
		<td valign="top">
			<table valign="top" border="0" cellpadding="0" cellspacing="0" width="988" height="51" bgcolor="#F9F9F9">
				<tr height="3">
					<td width="988" colspan="8" style="font-size:8px;"></td>
				</tr>
				<tr height="45">
					<td width="5"></td>
					<td width="45" height="45">	
						<img src="/images/top_01.gif?version=<% mcr_getWebVersion(); %>" width="45" height="45" border="0">
					</td>
					<td width="5"></td>
					<td width="230" height="45">	
						<img src="/images/top_02.gif?version=<% mcr_getWebVersion(); %>" width="190" height="45" border="0">
					</td>
					<td width="5"></td>
					<td height="45" align="left" valign="bottom">	
						<img src="/images/top_04.gif?version=<% mcr_getWebVersion(); %>" width="360" height="22" border="0">
					</td>
					<td width="5"></td>
					<td width="45" height="45" align="right" valign="bottom">	
						<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" width="35" height="28" border="0">
					</td>
					<td width="5"></td>
				</tr>
				<tr height="3">
					<td width="988" colspan="8" style="font-size:8px;"></td>
				</tr>
			</table>
			<table cellpadding="0" cellspacing="0" width="988" height="4" bgcolor="#DF2428">
			<tr>
				<td>
				</td>
			</tr>
			</table>
			<table cellpadding="0" cellspacing="0" width="100%" height="150">
				<tr>
					<td>
					</td>
				</tr>
			</table>
			<table cellpadding="0" cellspacing="0" border="0" width="100%" height="200">
				<tr>
					<td width="250" height="200">
					</td>
					<td width="490" height="200">
						<table cellpadding="0" cellspacing="0" border="1" width="490" height="200">
							<tr>
								<td>
									<table cellpadding="0" cellspacing="0" border="0" width="350" height="150" align="center">
										<tr>
											<td width="90" height="30">
											</td>
											<td width="190" height="30">
											</td>
										</tr>
										<tr>
											<td class="font100" width="90" > 아이디</td>
											<td width="190" >
												<input name="UserID" autocomplete="off" type="text" class="font101" id="UserID" maxLength="64" tabindex="1" value="<% mcr_getCfgString("UserManage_RememverLogInId_1"); %>" onFocus="this.select()" style="width:100%">
											</td>
											<td style="width:10px">
											</td>
											<td rowspan="2" >
												<input type="image" src="/images/login_main_default.gif?version=<% mcr_getWebVersion(); %>" width="88" height="58" value="" tabindex="3" id="login_main" name="login_main" onclick="changeBtn_Click('login_main', '/goform/mcr_WebAccessAndLoginProc'); return false;" OnMouseOut="changeMouseOut('login_main')"  OnMouseOver="changeMouseOver('login_main');">
											</td>
										</tr>
										<tr>
											<td class="font100" width="90" > 비밀번호</td>
											<td width="190"><input name="Password" autocomplete="off" type="password" class="font101" id="Password" tabindex="2"  maxLength="64" value="" onFocus="this.select()" style="width:100%">
											</td>
										</tr>
										<tr>
											<td width="90">
											</td>
											<td class="font100" width="190">
												<input type="checkbox" name="check_box" tabindex="4" value="1"> 아이디기억</td>
										</tr>
										<tr>
									</table>
									<table cellpadding="0" cellspacing="0" border="0" width="350" height="150" align="center" id="captcha_tb" style="display:none;">
										<tr>
											<td>
												<input name="captchatext" autocomplete="off" type="text" class="font101" id="captchatext" width="280" maxLength="6" tabindex="5" value="여기에 아래의 문자를 입력하세요" onFocus="on_focus_clear('captchatext')" style="width:250">
											</td>
										</tr>
										<tr>
											<td align="center">
												<div name="mcr_captcha" id="mcr_captcha"><div><canvas frameborder="1" height="70" scrolling="no" style="width:250px; height:70px;"></canvas></div></div>
											</td>
											<td style="width:10px">
											</td>
											<td>
												<input type="image" src="/images/refresh_default.gif?version=<% mcr_getWebVersion(); %>" id="refresh" name="refresh" onclick="refreshCaptcha(); return false;" OnMouseOut="changeMouseOut('refresh')"  OnMouseOver="changeMouseOver('refresh');">
											</td>
										</tr>
										<tr>
											<td width="90" height="30">
											</td>
											<td width="190" height="30">
											</td>
								
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
					<td width="250" height="200">
					</td>
				</tr>
			</table>
			<table cellpadding="0" cellspacing="0" width="100%" height="150">
				<tr>
					<td>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
<table class="table" cellpadding="0" cellspacing="0" width="975" height="62" bgcolor="#F9F9F9">
	<tr>
		<td width="975" height="62" style="font-size:8px;">
			<p><img src="/images/bottom.gif?version=<% mcr_getWebVersion(); %>" width="975" height="62" border="0"></p>
		</td>
	</tr>
</table>
</body>
</html>
