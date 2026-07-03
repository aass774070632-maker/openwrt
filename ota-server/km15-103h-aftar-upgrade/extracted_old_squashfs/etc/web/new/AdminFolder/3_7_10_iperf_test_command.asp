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
var beforId = "menu08";
var Iperf_en= "<% mcr_getCfgCommon("IperfInfoParam_Enable"); %>";

function mouseover(clickId){
	var obj = document.getElementById(clickId);
	obj.className="menu3rdMouse";

}

function mouseout(clickId)
{
	var obj = document.getElementById(clickId);
	if(beforId == clickId)
	{
		obj.className="menu3rdSelect";
	}
	else
	{
		obj.className="menu3rdNormal";
	}
}

function formCheck(url)
{
	if( document.SystemCommand.command.value == ""){
		alert("Command를 입력해 주세요");
		return false;
	}

	form_act(url);
}

function form_act(url){
	SystemCommand.action = url;
	SystemCommand.submit();
	return false;
}


function setFocus()
{
	$("#menu08").removeClass("menu3rdNormal").addClass("menu3rdSelect");
	iperfcheck(Iperf_en);

	document.SystemCommand.command.focus();

	if(Iperf_en == "1")
		$("#serverstate").text("※ 서버 동작 중입니다.");
	else
		$("#serverstate").text("");

}

function serverCheck(){
	$("#server_stop").val("0");
	form_act('/goform/mcr_IperfTest_Command');
}

function iperfcheck(check){
	if(check == "0"){
		$("#stopbutton").hide();
	}else{
		$("#stopbutton").show();
	}

}

</script>

</head>
<body onload="setFocus()">
<form method="post" name="SystemCommand">

<input type="hidden" id="redirect_url" name="redirect_url" value="/new/AdminFolder/3_7_10_iperf_test_command.asp"/>
<input type="hidden" id="server_stop" name="server_stop" value="1"/>

<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_7_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">Iperf 속도시험</td>
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
											<td height="25" class="BG2" style="width:140px;">Command</td>
											<td class="BG2-2"> 
												<input type="text" name="command" id="command" size="40" maxlength="256" value="<% mcr_iperfCommand(); %>" />
												　　　　　　　<label id="serverstate"></label>
											</td>
										</tr>
										<tr id="consolpage">
											<td colspan="2">
												<textarea style="width:100%" cols="100%" rows="20" wrap="off" readonly="1">
													<% mcr_showSystemCommand(); %>
												</textarea>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									 <table width="100%" border="0" cellspacing="0" cellpadding="0" id="table1">
										<tr>
											<td class="PD6" width="100%"> 
												<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onClick="formCheck('/goform/mcr_IperfTest_Command'); return false;" />&nbsp;
											</td>
											<td id="stopbutton">
												<input name="Cancel" type="image" src="/images/BTN/BTN_30.gif?Sp2" width="52" height="24" onClick="serverCheck(); return false;" />
											</td>
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
</form>
</body>
</html>
