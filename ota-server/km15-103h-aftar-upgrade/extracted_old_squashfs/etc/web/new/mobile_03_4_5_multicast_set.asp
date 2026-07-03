<html>
<head>
<title>GiGA WiFi home Mobile Main</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">

<link rel="stylesheet" href="/style/jquery.mobile-1.1.0-rc.1.min.css" type="text/css">

<script language="JavaScript" type="text/javascript" src="/script/jquery-1.7.1.min.js?version=<% mcr_getWebVersion(); %>"></script>
<script language="JavaScript" type="text/javascript" src="/script/jquery.mobile-1.1.0-rc.1.min.js?version=<% mcr_getWebVersion(); %>"></script>

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


.ui-btn-active-c{
	border:1px solid #bbb;
	background:#fff;
	font-weight:bold;
	color:#fff;
	cursor:pointer;
	text-shadow:0 0px 0px #fff;
	text-decoration:none;
	background-image:-webkit-gradient(linear,left top,left bottom,from(#f16045),to(#ec2427));
	background-image:-webkit-linear-gradient(#f16045,#ec2427);
	background-image:-moz-linear-gradient(#f16045,#ec2427);
	background-image:-ms-linear-gradient(#f16045,#ec2427);
	background-image:-o-linear-gradient(#f16045,#ec2427);
	background-image:linear-gradient(#f16045,#ec2427);
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
	document.form_igmp.action = "/goform/mcr_KTlogOut";
	document.form_igmp.submit();
}

function initValue(){
	var igmpen = "<% mcr_getCfgString("IpMulticastCfgParam_Enable"); %>";
	var igmpproxyen = "<% mcr_getCfgString("IpMulticastCfgParam_Proxy_Enable"); %>";
	var igmpfastleave = "<% mcr_getCfgString("IpMulticastCfgParam_Fast_leave"); %>";

	setigmp(igmpen);
	setigmpProxy(igmpproxyen);
	setigmpfastleave(igmpfastleave);
}

function setigmpfastleave(igmpfastleave){
	switch(igmpfastleave){
		case '0':
			mcr_clickradio_igmpfastleave('0');
			$("input[id='m_igmpFastLeave1']").attr("checked", true).checkboxradio("refresh");
			$("#igmpFastLeave").val("0");
			break;
		case '1':
			mcr_clickradio_igmpfastleave('1');
			$("input[id='m_igmpFastLeave']").attr("checked", true).checkboxradio("refresh");
			$("#igmpFastLeave").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_igmpfastleave(val){
	$('label[for=m_igmpFastLeave]').removeClass('ui-btn-active');
	$('label[for=m_igmpFastLeave1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_igmpFastLeave1]').addClass('ui-btn-active-c');
			$('label[for=m_igmpFastLeave]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_igmpFastLeave]').addClass('ui-btn-active-c');
			$('label[for=m_igmpFastLeave1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setigmpProxy(igmpProxy){
	switch(igmpProxy){
		case '0':
			mcr_clickradio_igmpProxy('0');
			$("input[id='m_igmpProxyEn1']").attr("checked", true).checkboxradio("refresh");
			$("#igmpProxyEn").val("0");
			break;
		case '1':
			mcr_clickradio_igmpProxy('1');
			$("input[id='m_igmpProxyEn']").attr("checked", true).checkboxradio("refresh");
			$("#igmpProxyEn").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_igmpProxy(val){
	$('label[for=m_igmpProxyEn]').removeClass('ui-btn-active');
	$('label[for=m_igmpProxyEn1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_igmpProxyEn1]').addClass('ui-btn-active-c');
			$('label[for=m_igmpProxyEn]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_igmpProxyEn]').addClass('ui-btn-active-c');
			$('label[for=m_igmpProxyEn1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function setigmp(igmp){
	switch(igmp){
		case '0':
			mcr_clickradio_igmp('0');
			$("input[id='m_igmpEn1']").attr("checked", true).checkboxradio("refresh");
			$("#tr_1").hide();
			$("#tr_2").hide();
			$("#tr_3").hide();
			$("#tr_4").hide();
			$("#igmpEn").val("0");
			break;
		case '1':
			mcr_clickradio_igmp('1');
			$("input[id='m_igmpEn']").attr("checked", true).checkboxradio("refresh");
			$("#tr_1").show();
			$("#tr_2").show();
			$("#tr_3").show();
			$("#tr_4").show();
			$("#igmpEn").val("1");
			break;
		default:
			break;
	}
}

function mcr_clickradio_igmp(val){
	$('label[for=m_igmpEn]').removeClass('ui-btn-active');
	$('label[for=m_igmpEn1]').removeClass('ui-btn-active');
	switch(val){
		case '0':
			$('label[for=m_igmpEn1]').addClass('ui-btn-active-c');
			$('label[for=m_igmpEn]').removeClass('ui-btn-active-c');
			break;
		case '1':
			$('label[for=m_igmpEn]').addClass('ui-btn-active-c');
			$('label[for=m_igmpEn1]').removeClass('ui-btn-active-c');
			break;
		default:
			break;
	}

}

function form_act(url){

	$('a[name=btn_apply2]').removeClass('ui-btn-active');
	$('a[name=btn_apply2]').addClass('ui-btn-active-a');
	form_igmp.action = url;
	form_igmp.submit();
	return false;
}

</script>

</head>
<body onload="initValue()">
<form method="post" name="form_igmp" data-ajax="false">

<input type="hidden" name="igmpEn" id="igmpEn" value="">
<input type="hidden" name="igmpProxyEn" id="igmpProxyEn" value="">
<input type="hidden" name="igmpFastLeave" id="igmpFastLeave" value="">
<input type="hidden" name="SETIGMP" value="/new/mobile_03_4_5_multicast_set.asp">

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
					멀티캐스트 설정
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
		<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
			<tr>
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>IGS 설정</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_igmpEn">　활성　</label>
									<input type="radio" name="m_igmpEn" id="m_igmpEn" value="1" onclick="setigmp(this.value)">
									<label for="m_igmpEn1">　비활성　</label>
									<input type="radio" name="m_igmpEn" id="m_igmpEn1" value="0" onclick="setigmp(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="tr_1">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>Proxy 설정</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_igmpProxyEn">　활성　</label>
									<input type="radio" name="m_igmpProxyEn" id="m_igmpProxyEn" value="1" onclick="setigmpProxy(this.value)">
									<label for="m_igmpProxyEn1">　비활성　</label>
									<input type="radio" name="m_igmpProxyEn" id="m_igmpProxyEn1" value="0" onclick="setigmpProxy(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr id="tr_2">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td>Fast Leave</td>
							<td>
								<fieldset data-role="controlgroup" data-type="horizontal">
									<label for="m_igmpFastLeave">　활성　</label>
									<input type="radio" name="m_igmpFastLeave" id="m_igmpFastLeave" value="1" onclick="setigmpfastleave(this.value)">
									<label for="m_igmpFastLeave1">　비활성　</label>
									<input type="radio" name="m_igmpFastLeave" id="m_igmpFastLeave1" value="0" onclick="setigmpfastleave(this.value)">
								</fieldset>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<a href="javascript:;" id="btn_apply2" name="btn_apply2" onclick="return form_act('/goform/mcr_setIgmp_New')" data-theme="a" data-role="button" data-mini="false" data-ajax="false">적용</a>
				</td>
			</tr>
			<tr id="tr_3">
				<td>
					<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
						<tr>
							<td align="center">IGMP 테이블</td>
						</tr>
						<tr>
							<td>
								<table align="center" cellspacing="0" cellpadding="0" width="100%" valign="middle">
									<tr>
										<td align="center" width="50%">Group Address</td>
										<td align="center" width="50%">Port</td>
									</tr>
									<script language="JavaScript" type="text/javascript">
										var i,j;
										var all_str = "<% mcr_getIgmpGroupTable_New(); %>";

										if (all_str == "") {
											document.write("<tr>");
											document.write("<td align=center colspan=2 id=IgmpGroupNone> 그룹 정보가 없습니다. </td>");
											document.write("</tr>\n");
										}
										else {
											var entries = all_str.split(";");
											for(i=0; i<entries.length; i++)
												arrData[i] = entries[i].split(",");

											for(i=0; i<entries.length; i++){
												document.write("<tr>");

												for(j=0;j<2;j++) {
													document.write("<td align=center>");
													if( arrData[i][j] == null || arrData[i][j].length == 0 ){
														document.write("");
													}else{
														document.write(arrData[i][j]);
													}
													document.write("</td>");
												}
												document.write("</tr>\n");
											}
										}
									</script>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	<div id="tr_4" style="display:none; padding:10px 0 0 0;" data-role="fieldcontain">
		<a href="javascript:;" id="btn_apply_1" name="btn_apply_1" onclick="document.location.reload()" data-theme="d" data-role="button" data-mini="false" data-ajax="false">새로고침</a>
	</div>
	<div style="padding:10px 0 12 0;">
		<a href="/mobile.asp#eighthPage" data-role="button" data-rel="back" data-icon="arrow-l"> 이전 페이지 </a>
	</div>
</div>
</form>
</body>
</html>
