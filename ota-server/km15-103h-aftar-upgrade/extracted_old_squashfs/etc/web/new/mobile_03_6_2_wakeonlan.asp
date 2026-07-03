<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js?version=<% mcr_getWebVersion(); %>"></script>

<style type="text/css">

.ui-btn-up-a {
	border: 1px solid #bbb;
	background: #fff;
	font-weight: bold;
	color: #333;
	text-shadow: 0 1px 0 #fff;
	background-image: -webkit-gradient(linear,left top,left bottom,from(#dedede),to(#bebebe));
	background-image: -webkit-linear-gradient(#dedede,#bebebe);
	background-image: -moz-linear-gradient(#dedede,#bebebe);
	background-image: -ms-linear-gradient(#dedede,#bebebe);
	background-image: -o-linear-gradient(#dedede,#bebebe);
	background-image: linear-gradient(#dedede,#bebebe);
}



.ui-btn-active-a{
	border:1px solid #bbb;
	background:#bebebe;
	font-weight:bold;
	color:#333;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#bebebe),to(#9e9e9e));
	background-image:-webkit-linear-gradient(#bebebe,#9e9e9e);
	background-image:-moz-linear-gradient(#bebebe,#9e9e9e);
	background-image:-ms-linear-gradient(#bebebe,#9e9e9e);
	background-image:-o-linear-gradient(#bebebe,#9e9e9e);
	background-image:linear-gradient(#bebebe,#9e9e9e);
	font-family:Helvetica,Arial,sans-serif
}

</style>

<script language="javascript" type="text/javascript">

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
	document.form_woladd.action = "/goform/mcr_KTlogOut";
	document.form_woladd.submit();
}

function on_focus_clear(id){
	document.getElementById(id).value="";
}

function act_pcmac(macaddr) {
	document.form_woladd.wol_mac.value = macaddr;
}

function validateOnSubmit(){
	var mac = document.getElementById("wol_mac");
	var pc = document.getElementById("wol_pc");
	var UserList = document.getElementById("maxinfo").value;

	if ( isEmpty(mac.value) == true ) {
		alert("MAC 주소를 입력해 주세요");
		return false;
	}

	if ( (isMacAddress(mac.value) == false) || (mac.value == "00:00:00:00:00:00") ) {
		alert("잘못된 타겟 MAC 주소입니다");
		return false;
	}
	if ( isEmpty(pc.value) == true){
		alert("PC이름을 입력해 주세요");
		return false;
	}
	if(UserList >= 16){
		alert("최대 설정 개수입니다");
		return false;
	}
	$('a[name=btn_apply1]').removeClass('ui-btn-active');
	$('a[name=btn_apply1]').addClass('ui-btn-active-a');
	form_act('/goform/mcr_addWol');
	return false;
}

function check_pcmac(){
	var f=document.form_woladd;
	var UserList = document.getElementById("cur_wol");
	var obj = document.getElementById('wol_height');
	
	if(f.wol_pcmac.checked == true){
		$("#wolList").show();
	}
	else{
		$("#wolList").hide();
	}
}
function CheckValue()
{
	var count=0;
	var f=document.form_wolset;
	var i=0;
	var UserList = document.getElementById("maxinfo").value;
	for(i=0; i<UserList; i++){
		var a = document.getElementById("chk_"+i);
		if(a.checked == true){
			count++;
		}
	}
	if(count >1){
		alert("1개만 선택해 주세요.");
		return false;
	}

	return true;
}

function form_act(url){
	if(url == '/goform/mcr_setWolSnd'){
		if(!CheckValue())
			return false;
		$('a[name=btn_apply2]').removeClass('ui-btn-active');
		$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	}
	parent.mcrProgress.startProgressSimple("apply",5);
	form_woladd.action = url;
	form_woladd.submit();
	return false;
}

</script>

</head>
<body>
<form method="post" name="form_woladd" data-ajax="false">

<input name="redirect_url" type="hidden" id="redirect_url" value="/new/mobile_03_6_2_wakeonlan.asp">

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply" name="btn_apply" onclick="logoff()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>">
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
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
					스마트 부팅 설정
				</td>
			</tr>
		</table>
	</div>
	<hr color="f62530" style="border-width: 2px 0 0 0; margin:0px" width="100%">
	<div>
		<table>
			<tr height="5"></tr>
		</table>
	</div>

	<div style="padding:0 5 12 5px;" class="ui-field-contain" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td style="font-weight:bold;">타겟 MAC 주소</td>
							<td>
								<input name="wol_mac" type="text" id="wol_mac" maxlength="17" value="" onfocus="on_focus_clear('wol_mac')">
							</td>
						</tr>
						<tr>
							<td></td>
							<td>
								<input type="checkbox" name="wol_pcmac" id="wol_pcmac" value="" data-role="none" onclick="check_pcmac();">
								<label for="wol_pcmac"></label>
								현재 LAN 포트 접속된 PC
							</td>
						</tr>
						<tr id="wolList" style="display:none">
							<td colspan="2">
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle" class="fix">
									<tr>
										<td>
											<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
												<table class="TB" width="100%" border="0" style="table-layout:fixed;">
													<col>
													
													<col>
													<tr>
														<td align="center">선택</td>
														<td align="center">MAC 주소</td>
														
													</tr>
												</table>
											</span>
										</td>
									</tr>
									<tr id="wol_height">
										<td width="100%">
											<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
												<table class="TB" id="Grid_Table" border="0" style="table-layout:fixed">
													<col align="center">
													<col align="center">
													<%
														var i;
														var rule_num = mcr_getLanConnectBindInfo(0,0);
														write("<input type=hidden id=cur_wol value=");write(rule_num);write(">");
									
														if (rule_num > 0) {
															for ( i = 0; i < rule_num; i++ ){
																write("<tr>");
																write("<td style='padding-left:0px;' align='middle'>");
																write("<input name=DR type=checkbox onClick=act_pcmac(\""+mcr_getLanConnectBindInfo(1,i)+"\") data-role=none>");
																write("</td>");

																write("<td style=word-break:break-all>");
																write("<p>");write(mcr_getLanConnectBindInfo(1,i));write("</p>");
																write("</td>");
																write("</tr>\n");
															}
														}
														else {
															write("<tr>");
															write("<td colspan=5 align='center'>");
															write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
															write("</td>");
															write("</tr>\n");
														}
													%>	
												</table>
											</span>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td style="font-weight:bold;">PC 이름</td>
							<td>
								<input name="wol_pc" type="text" id="wol_pc" maxlength="17" value="" onfocus="on_focus_clear('wol_pc')">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply1" name="btn_apply1" onclick="return validateOnSubmit();" data-theme="a" data-role="button" data-mini="false" data-ajax="false">추가</a>
	</div>
	<div name="form_wolset" style="padding:0 5 12 5px;" class="ui-field-contain" data-role="fieldcontain">
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td style="font-weight:bold;">대상 리스트</td>
			</tr>
		</table>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" valign="middle">
			<tr id="wolMacList">
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>
								<span id="Grid_title1" align="center" style="width:100%;height:100%; overflow-x:hidden; overflow-y:hidden">
									<col align="middle">
									<col align="middle">
									<col align="middle">
									<tr>
										<td>선택</td>
										<td>MAC 주소</td>
										<td>PC 이름</td>
									</tr>
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" valign="middle">
						<tr>
							<td>
								<span id="Grid_data1" align="center" style="height:100%;width:100%; overflow-x:no; overflow-y:auto">
									<col>
									<col>
									<col>
										<%
											var i;
											var rule_num = mcr_getWolMacInfoCount();
											write("<input type=hidden id=maxinfo value=");write(rule_num);write(">");
											if (rule_num > 0) {
												for ( i = 0; i < rule_num; i++ ){
													 write("<tr>");
								
													write("<td align='middle'>");
													write("<input type=checkbox name=chk_" + i + " id=chk_"+i+" data-role='none'>");
													write("</td>");

													write("<td style='word-break:break-all' align='center'>");
													write("<p>");write(mcr_getWolMacListSnd(i,0));write("</p>");
													write("</td>");

													write("<td align='center'>");
													write("<p>");write(mcr_getWolMacListSnd(i,1));write("</p>");
													write("</td>");
													write("</tr>\n");
												}
											}
											else {
												write("<tr>");
												write("<td colspan=3 align='center'>");
												write("<p id=dDhcpBindIPListNone> 할당된 정보가 없습니다. </p>");
												write("</td>");
												write("</tr>\n");
											}
										%>
									
								</span>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>				
	<div style="padding:10px 0 12 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" alt="" onclick="return form_act('/goform/mcr_setWolSnd');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">켜기</a>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="javascript:;" id="btn_apply2" name="btn_apply2" alt="" onclick="return form_act('/goform/mcr_delWol');" data-theme="a" data-role="button" data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#tenthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
