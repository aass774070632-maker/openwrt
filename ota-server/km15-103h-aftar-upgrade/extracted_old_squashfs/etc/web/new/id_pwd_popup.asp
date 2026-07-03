<?xml version="1.0" encoding="UTF-8"?>
												 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko-KR">
	
<head>
<title></title>

<link href="/style/style.css" rel="stylesheet" type="text/css">
																					 
<%include('new/metatag.asp');%>
<script language="javascript" type="text/javascript" src="/lang/b28n.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common.js"></script>
<script language="javascript" type="text/javascript" src="/script/mcr_common_new.js"></script>
<script language="javascript" type="text/javascript">

Butterlate.setTextDomain("admin");



function noEvent() {
    if (event.keyCode == 116) {
        event.keyCode= 2;
        return false;
    }
    else if(event.ctrlKey && (event.keyCode==78 || event.keyCode == 82))
    {
        return false;
    }
}

</script>
</head>


<body leftmargin="20" oncontextmenu="return false" onselectstart="return false">

<table width="90%" height="150">
	<tr>
		<td> <h3 id="LoginErrorTitle"></h3> </td>
	</tr>
</table>
<script language="JavaScript" type="text/javascript">
	result_url="http://"+window.location.host+"/login_fail_popup.asp";
	New_WindowOpen(500,200,result_url,"Login Error");
</script>
<br>

</body>
</html>
