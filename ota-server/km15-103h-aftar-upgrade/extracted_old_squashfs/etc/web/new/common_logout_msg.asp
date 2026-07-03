<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ko" xml:lang="ko" xmlns="http://www.w3.org/1999/xhtml">
<head>
<%include('new/metatag.asp');%>
<title>로그아웃</title>
<%include('new/script.asp');%>
<script type="text/javascript">
	$(document).ready(function(){
		$('#msg').click(function(){
			alert('로그아웃 되었습니다');
			$('#go').trigger('click');
		});
		$('#go').click(function(){
			window.location.href="/";
		});
		$('#msg').trigger('click');
	});
</script>
<body oncontextmenu="return false" onselectstart="return false">
<div id="msg" style="display:hidden"></div>
<div id="go" style="display:hidden"></div>
</body>
</head>
</html>
