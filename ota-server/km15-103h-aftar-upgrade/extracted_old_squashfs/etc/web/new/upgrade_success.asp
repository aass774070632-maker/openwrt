<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
	"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title>Firmware Upgrade Process</title>
<link href="/style/style.css" rel="stylesheet" type="text/css">
<%include('new/metatag.asp');%>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js" ></script>
<script language="javascript" type="text/javascript" src="/lang/b28n.js" ></script>
<script language="JavaScript" type="text/javascript">

Butterlate.setTextDomain("admin");

var time=0;
var delay_time=3000;
var timer=null;

function initTranslation()
{
	translateLabelHTML("vupgTitle","upgrade title");
	translateLabelHTML("vpkagesuccess","upgrade pkagesuccess");

}

function progress(){
  if (time ==0) {
    time = 1;
    timer = setTimeout('progress()',delay_time);
  }else if (time == 1){
    httpRequest("/goform/mcr_setSuccess", "n/a", processHttpResponse, processHttpError);
    time = 2;
    delay_time=50000;
    timer = setTimeout('progress()',delay_time);
  } else {
    clearTimeout( timer );
    timer = null;
	self.close();
  }
}

function processHttpError(status){
}

function processHttpResponse(strResponse){
}

function initValue(){
	initTranslation();
	progress();
}

</script>
</head>

<body leftmargin="20" oncontextmenu="return false" onselectstart="return false" onLoad="initValue()">
<table width=95% height=150>
    <tr><td>
		<h3 id="vupgTitle"></h3>
    </td></tr>
    <tr>
        <td class="PD4-1" ></td>
    </tr>
    <tr><td>
		<div>
		<form method="post" name="upload" action="/goform/mcr_setSuccess">
			<font size=2>
			<label class="font1-1" id="vpkagesuccess">pkgupgrade_success</label>
		</form>
		</div>
		<br>
    </td></tr>
</table>

</body>

</html>
