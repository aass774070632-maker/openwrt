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

var beforId = "menu00";

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

function changeTable() 
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

function CheckValue()
{
	if(form.radio1[0].checked) {
		if ( isEmpty(document.form.ddnsserver.value) ) {
			alert("DDNS 서버를 입력해 주세요");
			return false;
		}

		if ( CheckInternetAddress(document.form.ddnsserver, 1) == false ) {
			alert("잘못된 DDNS서버 입니다");
			return false;
		}

		if ( isEmpty(document.form.usrid.value) ) {
			alert("사용자ID를 입력해 주세요");
			return false;
		}

		if ( isEmpty(document.form.password.value) ) {
			alert("비밀번호를 입력해 주세요");
			return false;
		}

		if ( CheckDomain(document.form.url.value) == false ) {
			alert("잘못된 URL주소 입니다");
			return false;
		}
	}
	else {
		document.form.ddnsserver.value = "";
		document.form.usrid.value = "";
		document.form.password.value = ""; 
		document.form.url.value = "";
	}
	parent.mcrProgress.startProgressSimple("apply", 5);
	return true;
}

function changDdns()
{
	if(form.radio1[0].checked) {
		$("#ddns1").show();
		$("#ddns2").show();
		$("#ddns3").show();
		$("#ddns4").show();
		$("#ddns5").show();
		$("#ddns6").show();
	}
	else {
		$("#ddns1").hide();
		$("#ddns2").hide();
		$("#ddns3").hide();
		$("#ddns4").hide();
		$("#ddns5").hide();
		$("#ddns6").hide();
	}
}

function on_focus_clear(id)
{
	document.getElementById(id).value="";
}

function selectMenu3rd(){
	$("#menu00").removeClass("menu3rdNormal").addClass("menu3rdSelect");
}

function initValue()
{
	selectMenu3rd();
			
	var ddnsserver  = "<% mcr_getCfgString("DdnsCfgParam_DdnsServer"); %>";
	var user        = "<% mcr_getCfgString("DdnsCfgParam_DdnsUser"); %>";
	var pwd         = "<% mcr_getCfgString("DdnsCfgParam_DdnsPassword"); %>";
	var url         = "<% mcr_getCfgString("DdnsCfgParam_DdnsHost"); %>";
	parent.mcrProgress.stopProgress();
	form.radio1[0].checked = false;
	form.radio1[1].checked = false;

	if ( isEmpty(ddnsserver) ) {
		form.radio1[1].checked = true ;
		document.form.ddnsserver.value = "";
		document.form.usrid.value = "";
		document.form.password.value = ""; 
		document.form.url.value = "";
	}
	else {
		form.radio1[0].checked = true;
		document.form.ddnsserver.value = ddnsserver;
		document.form.usrid.value = user;
		document.form.password.value = pwd; 
		document.form.url.value = url;
	}

    changDdns();
	changeTable();
}

var disable_tags=["input", "textarea", "select"];

disable_tags=disable_tags.join("|");

function disable_select(e){
        if (disable_tags.indexOf(e.target.tagName.toLowerCase())==-1)
        return false;
}

function reEnable(){
        return true;
}

if (typeof document.onselectstart!="undefined")
        document.onselectstart=new Function ("return false;")
else{
        document.onmousedown=disable_select;
        document.onmouseup=reEnable;
}


document.oncontextmenu = function() {return false;};
document.onselectstart = function() {return false;};
document.ondragstart = function() {return false;};

function unlock() {
        document.oncontextmenu = null;
        document.onselectstart = null;
        document.ondragstart = null;
}

function lock() {
        document.oncontextmenu = function() {return false;};
        document.onselectstart = function() {return false;};
        document.ondragstart = function() {return false;};
}

</script>
</head>

<body onload="initValue();">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_6_menu3rd.asp');%>
		</td>
	</tr>
	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
		
			<form method="post" name="form" action="/goform/mcr_setDDNS">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">DDNS 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">DDNS 사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="radio1" id="radio13" value="0" OnClick="changDdns()">활성
														</td>
														<td>
															<input name="radio1" type="radio" id="radio14" value="1" OnClick="changDdns()">비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id = "ddns1" style="display:none">
											<td height="25" colspan="2">　</td>
										</tr>
										<tr id = "ddns2" style="display:none">
											<td class="BG2" style="width:140px;">DDNS 서버</td>
											<td class="BG2-2" width="600">
												<input name="ddnsserver" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="ddnsserver" maxlength="30" value="dyndns.org" style="ime-mode:disabled" onFocus="on_focus_clear('ddnsserver')"/>
											</td>
										</tr>
										<tr id = "ddns3" style="display:none">
											<td class="BG2" style="width:140px;">사용자 ID</td>
											<td class="BG2-2" width="600">
												<input name="usrid" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="usrid" maxlength="30" value="" style="ime-mode:disabled" onFocus="on_focus_clear('usrid')" autocomplete="off" />
											</td>
										</tr>
										<tr id = "ddns4" style="display:none">
											<td class="BG2" style="width:140px;">비밀번호</td>
											<td class="BG2-2" width="600">
												<input type="text" id="user_id_fake" name="user_id_fake" autocomplete="off" style="display: none;">
												<input type="password" id="user_id_fake" name="user_pwd_fake" autocomplete="off" style="display: none;">
												<input name="password" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2" id="password" maxlength="30" style="ime-mode:disabled" onFocus="on_focus_clear('password')" value="" autocomplete="off" />
											</td>
										</tr>
										<tr id = "ddns5" style="display:none">
											<td rowspan="2" class="BG2" style="width:140px;">URL</td>
											<td class="BG2-2" width="600">
												<input name="url" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="url" maxlength="30" value="" style="ime-mode:disabled" onFocus="on_focus_clear('url')"/>
											</td>
										</tr>
										<tr id = "ddns6" style="display:none">
											<td class="BG2-2" width="600">ex)userhost.dyndns.org</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr style="display:none">
								<td>
									<input name="redirect_url" type="text" onmouseover="unlock();" onmouseout="lock();" readonly class="input2" id="redirect_url" value="/new/AdminFolder/3_6_1_ddns_set.asp" />
								<td>
							</tr>
							<tr>
								<td class="PD6">
									<input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" alt="1" width="52" height="24" onClick="return CheckValue()" />
								</td>
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
