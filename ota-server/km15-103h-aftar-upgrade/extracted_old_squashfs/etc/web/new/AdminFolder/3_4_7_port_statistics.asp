<html>
<head>
<%include('new/metatag.asp');%>
<title>포트 통계 정보</title>
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

var beforId = "menu07";

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

var arrData = new Array();

function initValue(){
	$("#menu07").removeClass("menu3rdNormal").addClass("menu3rdSelect");

}


function form_act(url){
	portstatis.action = url;
	portstatis.submit();
	return false;
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

<form name="portstatis">
<table width="800" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top">
			<%include('new/AdminFolder/3_4_menu3rd.asp');%>
        	</td>
	</tr>

	<tr>
		<td width="800" style="font-size:5px;" valign="top"  bgcolor="#FFFFFF">
			<input type=hidden name=SETSTATIS value="/new/AdminFolder/3_4_7_port_statistics.asp" />
			<table width="800" height="400" border="0" cellspacing="0" cellpadding="10">
				<tr>
					<td valign="top">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td valign=font5">
									<table width="100%" border="0" cellspacing="0" cellpadding="0">
										<tr> <td class="font5">포트 통계 정보</td> </tr>
										<tr> <td class="PD4"></td> </tr>
										<tr> <td class="PD5"></td> </tr>

										<tr>
											<table class="TB" width="100%" border="0">
												<tr>
													<td width="8%" class="BG1" id="aPortNum">Port</td>
													<td class="BG1">Rx-<br>Bytes</br></td>
													<td class="BG1">Rx-<br>UniPkts</br></td>
													<td class="BG1">Rx-<br>MultiPkts</br></td>
													<td class="BG1">Rx-<br>BroadPkts</br></td>
													<td class="BG1">Rx-<br>Errors</br></td>
													<td class="BG1">Tx-<br>Bytes</br></td>
													<td class="BG1">Tx-<br>UniPkts</br></td>
													<td class="BG1">Tx-<br>MultiPkts</br></td>
													<td class="BG1">Tx-<br>BroadPkts</br></td>
													<td class="BG1">Tx-<br>Errors</br></td>
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
													      for(j=0;j<11;j++) {
													        document.write("<td class='BG2-2' align='right'>"); document.write(arrData[i][j]); document.write("</td>");
													      }
													      document.write("</tr>\n");
    													 }
													</script>

												</tr>

											</table>
										</tr>
										<tr>
											<td class="PD6">
												<p align="right"><input name="Apply" type="image" src="/images/BTN/BTN_02.gif?Sp2" width="52" height="24" onclick="form_act('/goform/mcr_setClrPortStatis_New'); return false;"/>
											</td>
										</tr>
									</table>
								<td>
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
