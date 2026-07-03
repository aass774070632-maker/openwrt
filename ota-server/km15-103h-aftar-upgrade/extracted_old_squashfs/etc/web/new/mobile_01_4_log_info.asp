<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<%include('new/script.asp');%>
<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/iscroll.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.wrapper {
	margin: 30px auto;
	width: 300px;
	height: 150px;
	background: #ccc;
	overflow-x: scroll;
	overflow-y: scroll;
}


</style>

<script language="javascript" type="text/javascript">
var http_request = null;
var myScroll;

function makeRequest(url, content)
{
	
        if (window.XMLHttpRequest) { 
                http_request = new XMLHttpRequest();
                if (http_request.overrideMimeType) {
                        http_request.overrideMimeType('text/xml');
                }
        }
        else if (window.ActiveXObject) { 
                try {
                        http_request = new ActiveXObject("Msxml2.XMLHTTP");
                } catch (e) {
                        try {
                                http_request = new ActiveXObject("Microsoft.XMLHTTP");
                        } catch (e) {}
                }
        }
        if (!http_request) {
                alert('XMLHTTP를 생성할수 없습니다.');
                return false;
        }
        http_request.onreadystatechange = alertContents;
        http_request.open('POST', url, true);
        http_request.send(content);
}

function alertContents()
{
        if( http_request != null ){
                if (http_request.readyState == 4) {
                        if (http_request.status == 200) {
                                uploadLogField(http_request.responseText);
                        }
                        else {
                                alert('There was a problem with the request.');
                        }
                }
        }
}

function uploadLogField(str)
{
        var id;

        id = "memorylog";

        if(str == "-1"){
                document.getElementById(id).value = "Not support.\n(Busybox->\n  System Logging Utilitie ->\n    syslogd\n    Circular Buffer\n logread";
        }
	else if(str.indexOf("<html>")!=-1){
		document.getElementById(id).value = "Not support.\n";
	}
	else if(str.indexOf("|HHUB|")==0){
                document.getElementById(id).value = str.substr(6);
        }
}

function updateMemorySyslog()
{
        makeRequest("/goform/mcr_sysUserMemLog", "n/a", false);
	
}

function clearMemoryLog()
{
        makeRequest("/goform/mcr_clearMemLog", "n/a", false);
        return true;
}


function initValue()
{
	updateMemorySyslog();
}

function processHttpGetLog(strResponse){
        result_url = "http://"+window.location.host+strResponse;
        window.location.href = result_url;
        return true;
}

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
	document.form_simple.action = "/goform/mcr_KTlogOut";
	document.form_simple.submit();
}
</script>
</head>
<body onload="initValue()">
<form method="post" id="form_simple" name="form_simple">
<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<input type="button" value="로그아웃" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-mini="false" data-ajax="false">
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<input type="button" value="새로고침" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-mini="false" data-ajax="false">
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
					로그 정보
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0;" width="100%">
	<div style="padding:0 5 12 5px;">
		<table>
			<tr height="5">
			</tr>
		</table>
		<div>
			<textarea name="memorylog" cols="100%" rows="10" style="height:100%; width:100%;" id="memorylog" wrap="off" readonly="1"></textarea>
		</div>
		<div style="padding:10px 0 0 0;">
			<a href="/mobile.asp#secondPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
		</div>
	</div>
</div>
</form>
</body>
</html>
