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

<script language="JavaScript" type="text/javascript" src="/script/mcr_common.js"></script>
<script language="JavaScript" type="text/javascript" src="/script/mcr_common_new.js"></script>

<script>

var UserPrivilege = getUserPrivilege();

function CheckValue()
{
	parent.mcrProgress.startProgressSimple("apply", 5);
 	return true;
}

function initValue()
{
	var encryption  = "<% mcr_getCfgString("HOMEDrivceCfgParam_Encryption"); %>";
	form.radio1[0].checked = false;
	form.radio1[1].checked = false;

	if ( encryption == "1" ) {
		form.radio1[1].checked = true;
			alert("비암호화 모드");
	}
	else {
		form.radio1[0].checked = true;
			alert("암호화 모드");
	}

}

//마우스 드래그 및 오른쪽 버튼 막기
//Crome and Firefox
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

//IE

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
        <td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
		
			<form name="form" action="/goform/mcr_setASencrypt">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">홈드라이브 앱 암호화 설정</td>
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
											<td height="25" class="BG2" style="width:140px;">암호화 사용</td>
											<td class="BG2-2" width="600">
												<table  border="0" cellpadding="0" cellspacing="0" class="font1">
													<tr>
														<td width="110">
															<input type="radio" name="radio1" id="radio13" value="0" >암호화
														</td>
														<td>
															<input type="radio" name="radio1" id="radio14" value="1" >비암호화 
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
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
