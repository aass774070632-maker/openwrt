<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템 재시동</title>
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
	background-color: #f1f1f1;
}
-->
</style>

<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js"></script>

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

function logoff(){
        remove_auth_cache();
        document.form.action = "/goform/mcr_KTlogOut";
        document.form.submit();
}

function OnInit()
{
	logoff();
}

</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="OnInit();">
<form name="form">
</form>
</body>
</html>
