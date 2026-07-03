<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템정보</title>
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
var http_request = null;
var request_log_type = "Usermemorylog";

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
	var id = "usermemorylog";

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

function updateUserMemorySyslog()
{
	request_log_type = "memory";
	makeRequest("/goform/mcr_sysUserMemLog", "n/a", false);
}

function clearUserMemoryLog()
{
	request_log_type = "memory";
	makeRequest("/goform/mcr_clearUserMemLog", "n/a", false);
	return true;
}

function changeTable()
{
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} 
	else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}


function initValue()
{
	updateUserMemorySyslog();

	changeTable();
}

function LogFile_Get(url)
{
	httpRequest(url, "n/a", processHttpGetLog, processHttpGetLogError);
	return false;
}

function processHttpGetLog(strResponse){
	result_url = "http://"+window.location.host+strResponse;
	window.location.href = result_url;
	return true;
}

function processHttpGetLogError(status){
	alert("파일이 없습니다.");
	window.location.reload();
	return false;
}

</script>

</head>

<body oncontextmenu="return false" onload="initValue()">
<table width="800" border="0" cellspacing="0" cellpadding="10" bgcolor="#FFFFFF">
	<tr id="flash_log" style="display:inline float:left">
		<td colspan="2">
			<table width="98%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td> 
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5"> </td>
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
											<td width="15%" class="BG1">시간</td>
											<td class="BG1">내용</td>
										</tr>
										<tr>
											<td colspan="2" class="BG0">
												<textarea name="usermemorylog" cols="98%" rows="35" class="input1" id="usermemorylog" wrap="off" readonly="1"></textarea>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="PD6">
						<p align="right">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td height="50" align="right" class="PD6">&nbsp;</td>
	</tr>
</table>
</body>
</html>
