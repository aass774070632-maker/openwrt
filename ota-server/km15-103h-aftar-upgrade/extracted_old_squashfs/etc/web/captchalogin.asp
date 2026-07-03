<html>
<head>
<title></title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta http-equiv="Pragma" content="no-cache"/>
<meta http-equiv="Expires" content="-1"/>
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
<script type="text/javascript">

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

var Browser = {
	version : navigator.userAgent.toLowerCase()
}

Browser = {
	ie : /*@cc_on true || @*/ false,
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

function initValue(){
	$("#captchaimg").attr("src", "/captcha.gif?v=" + new Date().getTime());
}
</script>
</head>
<body style="margin-left: 0px; margin-right: 0px; margin-bottom: 0px; margin-top: 0px;" onLoad="initValue()">
<form name="form">
<table border="0" cellpadding="0" cellspacing="0" style="font-size:10px" width="100%" height="70">
	<tr>
		<td align="center">
			<img id="captchaimg" src="captcha.gif">
		</td>
	</tr>
</table>
</form>
</body>
</html>
