<html>
<head>
<title>GiGA WiFi home Mobile Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">
<script language="javascript" type="text/javascript" src="/script/jquery-1.7.1.min.js"></script>
<script language="javascript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js"></script>

<script language="JavaScript" type="text/javascript" src="/script/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/script/captcha.js?version=<% mcr_getWebVersion(); %>"></script>
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
<script>

redirectTopWindow();

var login_fail = '';
var resultValue;
var captcha;
var captchaSuccess = false;
var failcount;

function redirectTopWindow(){
	if( top != self ){
		var URL = "http://" + window.location.host;
		top.location.replace(URL);
	}
}

function form_act(url){

	if(!CheckAll())
		return false;
	
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');

	Login.target = "";
	Login.action = url;
	Login.submit();
	return false;
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}
function CheckAll()
{
	captchaSuccess = captcha.validate( $("input[name='captchatext']").val() );

	if( captchaSuccess == true ){
		if(document.Login.UserID.value == ""){
			alert("사용자ID를 확인해 주세요.");
			document.Login.UserID.focus();
			return false;
		}
		if(document.Login.Password.value == ""){
			alert("비밀번호를 확인해 주세요.");
			document.Login.Password.focus();
			return false;
		}
	}else{
		on_focus_clear('captchatext');
		return false;
	}
	return true;
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

	form_act(pageUrl);
}
function refreshCaptcha(){
	var canvasdiv = $("canvas").parent(); if(canvasdiv){ canvasdiv.remove(); }
	var canvas = $("canvas"); if(canvas){ canvas.remove(); }

	captcha = new CAPTCHA({
	selector: '#mcr_captcha',
	width: 250,
	height: 80,
	onSuccess: function () { return true; }
	});

	captcha.generate();

	var user = "<% mcr_getCfgString("UserManage_Name_1"); %>";
	var user = "<% mcr_getString("Confirm_passwd"); %>";
	var auto_login = "<% mcr_getCfgString("UserManage_Password_1"); %>";

	if(user != ""){
		document.Login.UserID.value = "ktuser";
		document.Login.Password.value= "";
	}else{
		if(auto_login != ""){
			document.Login.UserID.value = "ktuser";
			document.Login.Password.value="homehub";
		}else{
			document.Login.UserID.value="";
			document.Login.Password.value="";
		}
	}

}

function processHttpResponse(strResponse)
{
	var str;

	str = strResponse.split(',');

	resultValue = str[0];
	failcount = str[1];
}

</script>

</head>

<body onload="refreshCaptcha();">
<form method="post" name="Login" data-ajax="false">
<input type="hidden" id="is_mobile" name="is_mobile" value="0"/>
<input type="hidden" id="captchadata" name="captchadata" value=""/>
<input type="hidden" id="simple_mobile" name="simple_mobile" value="2"/>
<div data-role="page" data-theme="d">

	<div data-role="header" data-theme="d">
		<h1> <img src="/images/mobile/m_logo_GiGA.png" /> </h1>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 24px;" >
				</td>
				<td align="left" style="font-weight:bold;">
					GiGA WiFi home Login
				</td>
			</tr>
		</table>
	</div>
	<hr color="#f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div style="padding: 0 0 0 12px;" data-role="fieldcontain"> 
		<table>
			<tr height="20">
			</tr>
		</table>
		<table width="100%" style="padding: 10 0 12 0px;">
			<tr>
				<td width="100%" style="font-size:20px">
					<label for="UserID"> 아이디:</label>
				</td>
			</tr>
			<tr>
				<td width="100%">
					<input autocomplete="off" type="text" width="100%" name="UserID" id="UserID" value"" maxlength="64">
				</td>
			</tr>
			<tr>
				<td width="100%">
					<label for="Password"> 패스워드:</label>
				</td>
			</tr>
			<tr>
				<td width="100%">
					<input autocomplete="off" type="password" name="Password" id="Password" value="" maxlength="64">
				</td>
			</tr>
			<tr>
				<td>
					<input name="captchatext" autocomplete="off" type="text" id="captchatext" maxLength="6" value="여기에 아래의 문자를 입력하세요" onFocus="on_focus_clear('captchatext')">
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%">
						<tr>
							<td>
								<div id="mcr_captcha" name="mcr_captcha"><div><canvas style="border: 1px solid rgb(192, 192, 192);" frameborder="1" scrolling="no" width="250"height="80"></canvas></div></div>
							</td>
							<td height="70">
								<a href="javascript:;" type="button" name="refresh" id="refresh" data-mini="true" data-ajax="false" style="height:100%" onclick="refreshCaptcha();"><br>새로<br>고침</a>
							</td>
						</tr>
					</table>
				</td>
			</tr>

		</table>
	</div>
	<div style="padding:5 0 10 0px;">
		<a href="javascript:;" id="btn_apply2"  name="btn_apply2" onClick="changeBtn_Click('btn_apply2','/goform/mcr_WebAccessAndLoginProc')" data-theme="a" data-role="button"  data-mini="false" data-ajax="false">로그인</a>
	</div>
</div>
</form>
</body>
</html>
