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
	
	timer_id = setTimeout('self_display()', 40000);
	changeTableAdmin();
}

function selectMenu3rd(){
		$("#menu07").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="OnInit();">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#F1F1F1">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#F1F1F1">
			<form name="sysRestart">
			<table width="800" height="670" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top" >
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">시스템 재시동</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td class="font2">&nbsp;&nbsp;시스템 재시작 중입니다. 잠시후 재접속해 주시길 바랍니다. </td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>
