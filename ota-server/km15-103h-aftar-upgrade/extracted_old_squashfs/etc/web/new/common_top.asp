<html>
<head>
<%include('new/metatag.asp');%>
<title></title>

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

function changePage(pageUrl){
	parent.changePage(pageUrl);
}


function logoff(){
	remove_auth_cache();
	document.form.action = "/goform/mcr_KTlogOut";
	document.form.submit();
}

function refresh(){
	changePage(viewPage);
 
}

function initValue(){
				   
}

var Browser = {
	version : navigator.userAgent.toLowerCase()
}

Browser = {
	ie :  false,
	ie6 : Browser.version.indexOf('msie 6') != -1,
	ie7 : Browser.version.indexOf('msie 7') != -1,
	ie8 : Browser.version.indexOf('msie 8') != -1,
	ie9 : Browser.version.indexOf('msie 9') != -1,
	opera : !!window.opera,
	safari : Browser.version.indexOf('safari') != -1,
	safari3 : Browser.version.indexOf('applewebkit/5') != -1,
	mac : Browser.version.indexOf('mac') != -1,
	chrome : Browser.version.indexOf('chrome') != -1,
	firefox : Browser.version.indexOf('firefox') != -1
}

function browserCheck() {
	if (Browser.chrome) {
		return "chrome";
	} else if (Browser.ie6) {
		return "ie6";
	} else if (Browser.ie7) {
		return "ie7";
	} else if (Browser.ie8) {
		return "ie8";
	}else if (Browser.ie9) {
		return "ie9";
	}else if (Browser.opera) {
		return "opera";
	} else if (Browser.safari) {
		return "safari";
	} else if (Browser.safari3) {
		return "safari3";
	} else if (Browser.mac) {
		return "mac";
	} else if (Browser.firefox) {
		return "firefox";
	} else {
		return "browser";
	}

		   

}

</script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>"></script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onLoad="initValue()">
<form name="form">
<table border="0" cellpadding="0" cellspacing="0" style="font-size:10px" width="975" height="51">
	<tr>
		<td valign="top">
			<table valign="top" border="0" cellpadding="0" cellspacing="0" width="975" height="51" bgcolor="#F9F9F9">
				<tr height="3">
					<td width="975" colspan="10" style="font-size:8px;"></td>
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
					<td width="20"></td>
					<td height="45" align="left" valign="bottom">   
						<img src="/images/top_04.gif?version=<% mcr_getWebVersion(); %>" width="360" height="22" border="0">
					</td>
					<td width="75" height="45" valign="bottom">	
						<a href="javascript:;" Onclick="top.document.main.location.reload()+blur()" OnMouseOver="na_change_img_src('image42', 'document', '/images/ad_refresh_mouse.gif?version=<% mcr_getWebVersion(); %>', true)" OnMouseOut="na_change_img_src('image42', 'document', '/images/ad_refresh_select.gif?version=<% mcr_getWebVersion(); %>', true);">
        	                                        <img src="/images/ad_refresh_select.gif?version=<% mcr_getWebVersion(); %>" width="75" height="18" border="0" id="image42" name="image42" style="cursor:hand">
	                                        </a>
					</td>
					<td width="67" height="45" valign="bottom">	
						<a href="javascript:;" Onclick="logoff()+blur()" OnMouseOver="na_change_img_src('image41', 'document', '/images/ad_logout_mouse.gif?version=<% mcr_getWebVersion(); %>', true)" OnMouseOut="na_change_img_src('image41', 'document', '/images/ad_logout_select.gif?version=<% mcr_getWebVersion(); %>', true);">
							<img src="/images/ad_logout_select.gif?version=<% mcr_getWebVersion(); %>" width="67" height="18" border="0" id="image41" name="image41" style="cursor:hand">
						</a>
					</td>
					<td width="5"></td>
					<td width="45" height="45" align="right" valign="bottom">       
						<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" width="35" height="28" border="0">
					</td>
					<td width="5"></td>
				</tr>
				<tr height="3">
					<td width="975" colspan="10" style="font-size:8px;"></td>
				</tr>
			</table>
			<table cellpadding="0" cellspacing="0" width="975" height="4" bgcolor="#DF2428">
				<tr>
					<td>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
