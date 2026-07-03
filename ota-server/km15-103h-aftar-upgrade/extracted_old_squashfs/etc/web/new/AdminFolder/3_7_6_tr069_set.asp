<html>
<head>
<%include('new/metatag.asp');%>
<title>TR069 설정</title>
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

var beforId = "menu05";
var UserPrivilege = getUserPrivilege();

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

	function changeTable() {
		if(document.body.scrollHeight>656) {
			parent.document.getElementById("main").style.height=document.body.scrollHeight;
			parent.document.getElementById("menu").style.height=document.body.scrollHeight;
		} else {
			parent.document.getElementById("main").style.height=656;
			parent.document.getElementById("menu").style.height=656;
		}
	}

    function changeTR069() {
        if(tr069.infenable[0].checked) {
			$("#acs_url").show();
			$("#acs_suburl").show();
			$("#acs_usrname").show();
			$("#acs_usrpasswd").show();
			$("#inf_interval").show();
			$("#inf_trap").show();
        }
        else if(tr069.infenable[1].checked) {
			$("#acs_url").hide();
			$("#acs_suburl").hide();
			$("#acs_usrname").hide();
			$("#acs_usrpasswd").hide();
			$("#inf_interval").hide();
			$("#inf_trap").show();
        }
        changeTable();
    }

function CheckValue()
{
    if (document.tr069.url.value == "" ) {
        alert("ACS URL을 입력해 주세요");
	document.tr069.url.focus();
        return false;
    }
    if (document.tr069.username.value == "" ) {
        alert("ACS 사용자이름을 입력해 주세요");
	document.tr069.username.focus();
        return false;
    }
    if (document.tr069.password.value == "" ) {
        alert("ACS 비밀번호를 입력해 주세요");
	document.tr069.password.focus();
        return false;
    }
    if (document.tr069.interval.value == "" ) {
        alert("Inform Interval을 입력해 주세요");
	document.tr069.interval.focus();
        return false;
    }
    if (document.tr069.trap.value == "" ) {
        alert("TRAP 을 입력해 주세요");
	document.tr069.trap.focus();
        return false;
    }
    else {
    	if (document.tr069.trap.value == "0" || document.tr069.trap.value == "1" || document.tr069.trap.value == "2" || document.tr069.trap.value == "3") {
        	return true;
	}
	else {
        	alert("TRAP은 0-3까지만 선택 가능 합니다.");
        	return false;
	}	
    }

    return true;
}

function periodicSel() {
    if ( document.tr069.infenable[0].checked ) {
        document.getElementById("tr069_enable").style.checked = "checked";
    } else {
        document.getElementById("tr069_disable").style.checked = "checked";
    }
	changeTR069();
}

function initValue()
{
	selectMenu3rd();
	
    var inform = <% mcr_getCfgString("Tr069CfgParam_EnableCWMP"); %>;
    var trapfinform = <% mcr_getCfgString("SyslogdCfgParam_LogTrap_Level"); %>;

    if (inform == 1)
        document.tr069.infenable[0].checked = true;
    else
        document.tr069.infenable[1].checked = true;

    document.tr069.trap.options.selectedIndex = trapfinform;

    periodicSel();
}

function selectMenu3rd(){
		$("#menu05").removeClass("menu3rdNormal").addClass("menu3rdSelect");
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

<body onload="initValue()">
<form action=/goform/mcr_setTR069Config method=post name="tr069">
<input type="hidden" name="SETTR069" value="/new/AdminFolder/3_7_6_tr069_set.asp" />
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
								<td class="font5">TR069 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">TR069 사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="infenable" id="tr069_enable" value="1" onClick="changeTR069()"/>
															활성
														</td>
														<td>
															<input name="infenable" type="radio" id="tr069_disable" value="0" onClick="changeTR069()"/>
															비활성 
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr id="acs_url">
											<td height="25" class="BG2" style="width:140px;">ACS URL</td>
											<td class="BG2-2" width="600"><input name="url" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="url" size="40" maxlength="50" value="<% mcr_getCfgString("Tr069CfgParam_ACS_URL"); %>" /></td>
										</tr>
										<tr id="acs_suburl">
											<td height="25" class="BG2" style="width:140px;">ACS 보조 URL</td>
											<td class="BG2-2" width="600"><input name="sub_url" type="text" onmouseover="unlock();" onmouseout="lock();" class="input3" id="sub_url" size="40" maxlength="50" value="<% mcr_getCfgString("Tr069CfgParam_UACS_URL"); %>"/></td>
										</tr>
										<tr id="acs_usrname">
											<td height="25" class="BG2" style="width:140px;">ACS 사용자 이름</td>
											<td class="BG2-2" width="600"><input name="username" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="username" size="32" maxlength="40" value="<% mcr_getCfgString("Tr069CfgParam_AcsUsrname"); %>"/></td>
										</tr>
										<tr id="acs_usrpasswd">
											<td height="25" class="BG2" style="width:140px;">ACS 비밀번호</td>
											<td class="BG2-2" width="600"><input name="password" type="password" onmouseover="unlock();" onmouseout="lock();" class="input2-1" id="password" size="32" maxlength="40" value="<% mcr_getCfgString("Tr069CfgParam_AcsUsrpasswd"); %>"/></td>
										</tr>
										<tr id="inf_interval">
											<td height="25" class="BG2" style="width:140px;">Inform Interval</td>
											<td class="BG2-2" width="600">
												<input name="interval" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2" id="interval" value="<% mcr_getCfgString("Tr069CfgParam_AcsInformInterval"); %>" /> 
												sec
											</td>
										</tr>
										<tr id="inf_trap">
											<td height="25" class="BG2" style="width:140px;">TRAP 설정</td>
											<td class="BG2-2" width="600">
												<select name="trap" class="input2" id="trap">
													<option value="0">비활성</option>
													<option selected value="1">전체</option>
													<option value="2">Major 이상</option>
													<option value="3">Critical만</option>
												</select>
<!--												<input name="trap" type="text" onmouseover="unlock();" onmouseout="lock();" class="input2-2" id="trap" maxlength="1"  size="2" value="<% mcr_getCfgString("SyslogdCfgParam_LogTrap_Level"); %>" />  0-3-->
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="PD6"><input name="Apply" type="image" src="/images/BTN/BTN_01.gif?Sp2" width="52" height="24" onClick="return CheckValue()" /></td>
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
