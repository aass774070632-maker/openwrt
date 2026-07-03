<html>
<head>
<title>GiGA WiFi home Mobile Login Fail</title>

<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_mobile_kt.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_wlan_security.js?version=<% mcr_getWebVersion(); %>"></script>

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

function javascript(){
        result_url = "http://"+window.location.host+"/mobile_login.asp";
        window.location.href = result_url;

        return false;
}

function pwd_reset(url){
	MobileLoginAuth.action = url;
	MobileLoginAuth.submit();
	setTimeout(function(){window.history.back()}, 1000);
	return false;
}

$(document).ready(function(){
        $("input[name='checkoption']").bind( "click", function(){
                var Enable = $("input[name='checkoption']:checked").val();
                if(Enable || Enable == "on"){
                        $("input[name='SecurityKey']").prop("type", "text");
                }else{
                        $("input[name='SecurityKey']").prop("type", "password");
                }

                return true;
        });
});

</script>

</head>

<body>
<form method="post" name="MobileLoginAuth" data-ajax="false">
<input type="hidden" id="is_mobile" name="is_mobile" value="0">
<input type="hidden" id="simple_mobile" name="simple_mobile" value="0">
<input name="redirect_url" type="hidden" id="redirect_url" value="/login_confirm.asp">
<div data-role="page" data-theme="d">

	<div data-role="header" data-theme="d">
		<h1> <img src="/images/mobile/m_logo_GiGA.png"> </h1>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png" style="width: 24px;">
				</td>
				<td align="left" style="font-weight:bold;">
					GiGA WiFi home Login
				</td>
			</tr>
		</table>
	</div>
	<hr color="#f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div style="padding:10px 0 0 15;">
		<td width="50%"> 암호키 </td>
		<td> 
			<input type="password" name="SecurityKey" id="SecurityKey" size="32" maxlength="64" value=""> 암호키보기
			<input type="checkbox" name="checkoption" data-role="none">
			<br> ※ 계정 재설정을 위한 사용자 인증
	 	</td>
	</div>
	<div style="padding:10px 0 0 0;">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td width="50%">
					<a href="javascript:;" id="Apply" name="Apply" onclick="pwd_reset('/goform/mcr_SecurityKeyVerify')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">확인</a>
				</td>
				<td width="50%">
					<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="javascript()" data-theme="a" data-role="button" data-mini="false" data-ajax="false">취소</a>
				</td>
			</tr>
		</table>
	</div>
</div>
</form>
</body>
</html>
