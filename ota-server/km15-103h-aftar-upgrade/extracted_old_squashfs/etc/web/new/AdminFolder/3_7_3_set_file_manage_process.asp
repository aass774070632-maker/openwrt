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

<script>
var timer_id;
var URL = "http://" + window.location.host;

function self_display()
{
	clearTimeout(timer_id);
	var confirmed = confirm("로그인 페이지로 이동하시겠습니까? ");
	if (!confirmed)
		return false;
	top.location.replace(URL);
}

function changeTableAdmin() 
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

function OnInit()
{
	selectMenu3rd();

	parent.mcrProgress.startProgressSimple("apply", 50);	
	timer_id = setTimeout('self_display()', 50000);
	changeTableAdmin();
}

function selectMenu3rd(){
		$("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="OnInit();">
</body>
</html>
