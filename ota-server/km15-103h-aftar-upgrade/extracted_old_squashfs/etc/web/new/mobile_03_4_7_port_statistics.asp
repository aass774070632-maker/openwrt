<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language='JavaScript' type='text/javascript' src='/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>'></script>
<script language='JavaScript' type='text/javascript' src='/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>'></script>

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

var arrData = new Array();

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
	document.portstatis.action = "/goform/mcr_KTlogOut";
	document.portstatis.submit();
}

function form_act(url){
	
	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	parent.mcrProgress.startProgressSimple("apply",5);
	portstatis.action = url;
	portstatis.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="portstatis" data-ajax="false">

<input type=hidden name=SETSTATIS value="/new/mobile_03_4_7_port_statistics.asp" />

<div data-role="page" data-theme="d">
	<div data-role="header" data-theme="d">
		<table width="100%">
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply"  name="btn_apply" onClick="logoff()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">로그아웃</a>
				</td>
				<td align="center">
					<img src="/images/mobile/m_logo_GiGA.png?version=<% mcr_getWebVersion(); %>" />
				</td>
				<td>
					<a href="javascript:;" id="btn_apply_1"  name="btn_apply_1" onClick="document.location.reload()" data-theme="d" data-role="button"  data-mini="false" data-ajax="false">새로고침</a>
				</td>
			</tr>
		</table>
	</div>
	<div data-role="content" class="ui-grid-a" style="padding: 13 0 5 5px;">
		<table width="100%">
			<tr>
				<td>
					<img src="/images/kt_logo.png?version=<% mcr_getWebVersion(); %>" style="width: 24px;" >
				</td>
				<td align="left" width="90%" style="font-weight:bold;">
					포트 통계 정보
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

	<div style="padding:0 5 12 5px;" data-role="fieldcontain">
		<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td id="aPortNum" align="center">Port</td>
							<td align="center">Rx-Bytes </td>
							<td align="center">Rx-UniPkts </td>
							<td align="center">Rx-MultiPkts </td>
							<script language="JavaScript" type="text/javascript">
								var i,j;
								var entries = new Array();
								var all_str = "<% mcr_getPortStatis(); %>";

								entries = all_str.split(";");
								for(i=0; i<entries.length; i++){
									var one_entry = entries[i].split(",");
									arrData[i] = one_entry;
								}
								for(i=0; i<entries.length; i++){
									document.write("<tr>");
									for(j=0;j<4;j++) {
										document.write("<td align='center'>"); document.write(arrData[i][j]); document.write("</td>");
									}
									document.write("</tr>\n");
								}
							</script>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="center">Rx-BroadPkts </td>
							<td align="center">Rx-Errors </td>
							<td align="center">Tx-Bytes </td>
							<td align="center">Tx-UniPkts </td>
							<script language="JavaScript" type="text/javascript">
								var entries = new Array();
								var all_str = "<% mcr_getPortStatis(); %>";

								entries = all_str.split(";");
								for(i=0; i<entries.length; i++){
									var one_entry = entries[i].split(",");
									arrData[i] = one_entry;
								}
								for(i=0; i<entries.length; i++){
									document.write("<tr>");
									for(j=4;j<8;j++) {
										document.write("<td align='center'>"); document.write(arrData[i][j]); document.write("</td>");
									}
									document.write("</tr>\n");
								}
							</script>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table border="0" align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="center">Tx-MultiPkts </td>
							<td align="center">Tx-BroadPkts </td>
							<td align="center">Tx-Errors </td>
							<script language="JavaScript" type="text/javascript">
								var entries = new Array();
								var all_str = "<% mcr_getPortStatis(); %>";

								entries = all_str.split(";");
								for(i=0; i<entries.length; i++){
									var one_entry = entries[i].split(",");
									arrData[i] = one_entry;
								}
								for(i=0; i<entries.length; i++){
									document.write("<tr>");
									for(j=8;j<11;j++) {
										document.write("<td align='center'>"); document.write(arrData[i][j]); document.write("</td>");
									}
									document.write("</tr>\n");
								}
							</script>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div style="padding:10px 0 0 0;">
		<a href="javascript:;" id="btn_apply2"  name="btn_apply2" onClick="return form_act('/goform/mcr_setClrPortStatis_New')" data-theme="a" data-role="button"  data-mini="false" data-ajax="false">삭제</a>
	</div>
	<div style="padding:10px 0 12 0;" data-role="fieldcontain">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
