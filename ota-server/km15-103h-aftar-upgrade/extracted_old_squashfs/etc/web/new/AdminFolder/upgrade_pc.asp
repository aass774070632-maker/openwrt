<html>
<head>
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
<link href="/style/style.css" rel="stylesheet" type="text/css">

<title>시스템관리</title>
<%include('new/script.asp');%>

<script>
function changeTable() {
	if(document.body.scrollHeight>656) {
		parent.document.getElementById("main").style.height=document.body.scrollHeight;
		parent.document.getElementById("menu").style.height=document.body.scrollHeight;
	} else {
		parent.document.getElementById("main").style.height=656;
		parent.document.getElementById("menu").style.height=656;
	}
}
function InitValue() {
	selectMenu3rd();
	changeTable();
}

function selectMenu3rd(){
		$("#menu06").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

</script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onload="InitValue();">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#F1F1F1">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
        </td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#F1F1F1">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">이미지 업그레이드</td>
							</tr>
							<tr>
								<td class="PD4"></td>
							</tr>
							<tr>
								<td class="PD5"></td>
							</tr>
							<tr>
								<td>
									<table width="100%" border="0" cellspacing="1" cellpadding="0">
										<tr>
											<font color=red> 업그레이드 파일 전송 완료.</font>
										</tr>

									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<script language="JavaScript" type="text/javascript">
	result_url="http://"+window.location.host+"/new/AdminFolder/upgrade_process.asp";
	New_WindowOpen(500,200,result_url,"UpgradeProgress");
	window.location.href = "/new/AdminFolder/3_7_7_image_upgrade.asp";
</script>

</body>
</html>
