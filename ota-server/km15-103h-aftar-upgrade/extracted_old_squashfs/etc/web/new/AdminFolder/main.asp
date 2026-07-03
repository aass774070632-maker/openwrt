<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<%include('new/metatag.asp');%>
<title>GiGA WiFi home</title>
<LINK REL="shortcut icon" HREF="../../icon.ico" TYPE="image/x-icon">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
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
-->


</style>
<script>
	function changePage(pageUrl){
		form.target = "main";
		form.action = pageUrl;
		form.submit();
	}
</script>

<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/mcr_progress.js?version=<% mcr_getWebVersion(); %>'></script>
<script>
var mcrProgress = null;
function initProgress(){
	mcrProgress = new MCRProgress(MCRProgress.TYPE_LAYOUT_DIV,
						document,
						"div_detail_contents",
						"div_admin_progress",
						admin_progress );	
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

function onInit(){
	initProgress();
	var BrowSer = browserCheck();
}
</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="onInit();">
<form name="form">
<table border="0" cellpadding="0" cellspacing="0" style="font-size:10px" width="990" height="700">
	<tr>
		<td colspan="2">
			<iframe name="top" id="top" src="/new/common_top.asp" frameborder="0" width="100%" height="51" scrolling="no"  onload="this.style.height=this.contentWindow.document.body.scrollHeight;"></iframe>
         </td>
    </tr>
    <tr>
		<td width="202" valign="top" style="font-size:5px;">
			<div id="div_menu" style="overflow:-webkit-overflow-scrolling:touch;">
			<iframe name="menu" id="menu" src="/new/AdminFolder/menu.asp" frameborder="0" width="202" height="100%" scrolling="no" onload="this.style.height=this.contentWindow.document.body.scrollHeight;"></iframe>
			</div>
		</td>
	    <td valign="top" bgcolor="#FFFFFF" style="font-size:5px; padding-top:0;">
			<div id="div_detail_contents" style="overflow:-webkit-overflow-scrolling:touch;">
			<iframe name="main" id="main" src="/new/AdminFolder/1_1_status_info.asp" frameborder="0" width="100%" scrolling="no" onload="this.style.height=this.contentWindow.document.body.scrollHeight;"></iframe>
			</div>
			<div id="div_admin_progress"  style="display:none; float:left; overflow:-webkit-overflow-scrolling:touch;">
				<iframe name="admin_progress" id="admin_progress" src="/new/common_progress.asp" frameborder="0" width="100%" scrolling="no" onload="this.style.height=this.contentWindow.document.body.scrollHeight;"></iframe>
			</div>
		</td>
    </tr>
</table>
<table class="table" cellpadding="0" cellspacing="0" width="975" height="62" bgcolor="#F9F9F9">
	<tr>
		<td width="975" height="62" style="font-size:8px;">
				<p><img src="/images/bottom.gif?Sp2" width="975" height="62" border="0"></p>
		</td>
	</tr>
</table>
	
</form>
</body>
</html>
