<html>
<head>
<%include('new/metatag.asp');%>
<title>시스템관리</title>
<%include('new/script.asp');%>

<script>

var beforId = "menu02";

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
function initValue(){
	selectMenu3rd();
	parent.mcrProgress.stopProgress();

	changeTable();
}

function Factory_Reset(url) {
	var conf_rlt = confirm('AP장비의 사용자 설정 정보를 모두 초기화하시겠습니까?');
	if (conf_rlt == false){
		return false;
	}

	subPage(url);
	return true;
}
function subPage(url){
	document.form_setfile.action = url;
	document.form_setfile.submit();
}

function selectMenu3rd(){
	$("#menu02").removeClass("menu3rdNormal").addClass("menu3rdSelect");
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
<form method="post" name="form_setfile" enctype="multipart/form-data">
<input type="hidden" name="redirect_url" id="redirect_url" value="/new/UserFolder/3_7_3_set_file_manage_process.asp">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/UserFolder/3_7_menu3rd.asp');%>
			</td>
    </tr>
    <tr>
        <td width="800" style="font-size:5px;" valign="top" bgcolor="#FFFFFF">
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="98%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="font5">설정 파일 관리</td>
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
											<td height="25" class="BG2" style="width:140px;">초기 설정 복원</td>
											<td class="BG2-2" width="600" colspan="3">
												<input name="FactoryReset" type="image" src="/images/BTN/BTN_20.gif?Sp2" alt="" width="85" height="24" onclick="Factory_Reset('/goform/mcr_setFactory');return false;">
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
