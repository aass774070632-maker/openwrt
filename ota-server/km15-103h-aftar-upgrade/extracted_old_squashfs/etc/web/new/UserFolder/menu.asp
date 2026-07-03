<html>
<head>
<%include('new/metatag.asp');%>
<title></title>

<%include('new/script.asp');%>

<link href="/style/style.css" rel="stylesheet" type="text/css" />
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

.table {
	border-right-width: 2px;
	border-right-style: solid;
	border-right-color: #333333;
}

.td {
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: #333333;
}

.td_open{
	border-bottom-width: 1px;
	border-bottom-style: dotted;
	border-bottom-color: #666666;
}
	
.menu a{cursor:pointer;}
.menu .hide{display:none;}
-->
</style>

<script>
	var beforeId = "image1";

	var beforeSubMenu1Id = "image11";

	var beforeSubMenu3Id = "image31";
	
	var viewPage = "1_1_status_info.asp";

	var repeater_en = "<% mcr_getCfgString("SysOperMode_WanInterface"); %>";

	var Adminlog_en = '<% mcr_getCfgCommon("ExtWebCtrl_AdminLogAllow"); %>';

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
	
	function changeBtn(clickId, pageUrl){
		var obj = document.getElementById("check1");
		var obj2 = document.getElementById("check2");
		var obj_wlan = document.getElementById("check_wlan");
		
		if(beforeId != clickId || (beforeId == "image2" && clickId == "image2")) {
			if(clickId == "image1") {
				$("#subMenu1").show();
				$("#subMenu2").hide();
				$("#subMenu3").hide();
				obj.className="td_open";				
				obj2.className="td";
				obj_wlan.className="td";
				changeSubMenu1Btn("image11", pageUrl);
			} else if(clickId == "image2") {
				$("#subMenu1").hide();
				$("#subMenu2").show();
				$("#subMenu3").hide();
				obj.className="td";				
				obj2.className="td";
				obj_wlan.className="td_open";
				beforeSub21Btn="image2";
				changeSubMenu2Btn("image2", pageUrl);
			} else if(clickId == "image3"){
				$("#subMenu1").hide();
				$("#subMenu2").hide();
				$("#subMenu3").show();
				obj.className="td";				
				obj2.className="td_open";
				obj_wlan.className="td";
				changeSubMenu3Btn("image31", pageUrl);
			}

			var changeImage;
			
			changeImage = (document.getElementById(beforeId).src).replace('select', 'default');
			
			document.getElementById(beforeId).src = changeImage;

			document.getElementById(beforeId).name = beforeId;

			changeImage = (document.getElementById(clickId).src).replace('default', 'select');
			
			document.getElementById(clickId).src = changeImage;

			document.getElementById(clickId).name = "";

			beforeId = clickId;

			if(clickId != "image1" || clickId != "image3") {
				changePage(pageUrl);

				viewPage = pageUrl;
			}
		}
	}
	
	function changeMouse(clickId)
	{
		var changeImage;
		if(beforeId == clickId)
		{
			changeImage = (document.getElementById(beforeId).src).replace('mouse', 'select');

                       	document.getElementById(beforeId).src = changeImage;
                       	document.getElementById(beforeId).src = changeImage;

                       	document.getElementById(beforeId).name = beforeId;
		}
		else
		{
			changeImage = (document.getElementById(clickId).src).replace('mouse', 'default');

                        document.getElementById(clickId).src = changeImage;

                        document.getElementById(clickId).name = "";

		}
		
	}

	function changeMouse_1(clickId)
	{
                var changeImage;
                
                if(beforeSubMenu1Id == clickId)
		{
                        changeImage = (document.getElementById(beforeSubMenu1Id).src).replace('mouse', 'select');

                        document.getElementById(beforeSubMenu1Id).src = changeImage;

                        document.getElementById(beforeSubMenu1Id).name = beforeSubMenu1Id;
                }
		else
		{
                        changeImage = (document.getElementById(clickId).src).replace('mouse', 'default');

                        document.getElementById(clickId).src = changeImage;

                        document.getElementById(clickId).name = "";
		}	

        }

	function changeMouse_2(clickId)
        {
                var changeImage;

                if(beforeSubMenu3Id == clickId)
                {
                        changeImage = (document.getElementById(beforeSubMenu3Id).src).replace('mouse', 'select');

                        document.getElementById(beforeSubMenu3Id).src = changeImage;

                        document.getElementById(beforeSubMenu3Id).name = beforeSubMenu3Id;
                }
                else
                {
                        changeImage = (document.getElementById(clickId).src).replace('mouse', 'default');

                        document.getElementById(clickId).src = changeImage;

                        document.getElementById(clickId).name = "";
                }

        }

function changeMouse_wlan(clickId)
{
    var changeImage;
    if(beforeSub21Btn == clickId)
    {
        changeImage = (document.getElementById(beforeSub21Btn).src).replace('mouse', 'select');
        document.getElementById(beforeSub21Btn).src = changeImage;
        document.getElementById(beforeSub21Btn).name = beforeSubMenu2Id;
    }
    else
    {
        changeImage = (document.getElementById(clickId).src).replace('mouse', 'default');
        document.getElementById(clickId).src = changeImage;
        document.getElementById(clickId).name = "";
    }
}

	function changeSubMenu1Btn(clickId, pageUrl){
		var changeImage;
		
		changeImage = (document.getElementById(beforeSubMenu1Id).src).replace('select', 'default');
		
		document.getElementById(beforeSubMenu1Id).src = changeImage;

		document.getElementById(beforeSubMenu1Id).name = beforeSubMenu1Id;

		changeImage = (document.getElementById(clickId).src).replace('default', 'select');
		
		document.getElementById(clickId).src = changeImage;

		document.getElementById(clickId).name = "";

		beforeSubMenu1Id = clickId;
		
		changePage(pageUrl);

		viewPage = pageUrl;
	}

	function changeSubMenu3Btn(clickId, pageUrl){
		var changeImage;
		
		changeImage = (document.getElementById(beforeSubMenu3Id).src).replace('select', 'default');
		
		document.getElementById(beforeSubMenu3Id).src = changeImage;

		document.getElementById(beforeSubMenu3Id).name = beforeSubMenu3Id;

		changeImage = (document.getElementById(clickId).src).replace('default', 'select');
		
		document.getElementById(clickId).src = changeImage;

		document.getElementById(clickId).name = "";

		beforeSubMenu3Id = clickId;

		changePage(pageUrl);

		viewPage = pageUrl;
	}

function changeSubMenu2Btn(clickId, pageUrl){
    var changeImage;

    if(clickId=="image2"){
        changeImage = (document.getElementById("image2_24").src).replace('select', 'default');
        document.getElementById("image2_24").src = changeImage;
        document.getElementById("image2_24").name = "image2_24";
        changeImage = (document.getElementById("image2_5").src).replace('select', 'default');
        document.getElementById("image2_5").src = changeImage;
        document.getElementById("image2_5").name = "image2_5";
    }
    changeImage = (document.getElementById(clickId).src).replace('default', 'select');
    document.getElementById(clickId).src = changeImage;
    document.getElementById(clickId).name = "";
    beforeSubMenu2Id = clickId;
    changePage(pageUrl);
    viewPage = pageUrl;
}
function changeSubMenu21Btn(clickId, pageUrl){
    var changeImage;

    if(beforeSub21Btn !="image2"){
        changeImage = (document.getElementById(beforeSub21Btn).src).replace('select', 'default');
        document.getElementById(beforeSub21Btn).src = changeImage;
        document.getElementById(beforeSub21Btn).name = beforeSub21Btn;
    }
    changeImage = (document.getElementById(clickId).src).replace('default', 'select');
    document.getElementById(clickId).src = changeImage;
    document.getElementById(clickId).name = "";
    beforeSub21Btn = clickId;
    changePage(pageUrl);
    viewPage = pageUrl;
}
	
	function changeWirelessSubMenu1Btn(clickId, pageUrl, redirectURL, wlanIfIndex){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		WirelessSetFormElement(parent.document, "wlanIfIndex", wlanIfIndex);

		changeBtn(clickId, pageUrl);
	}
	function changeWirelessSubMenu2Btn(clickId, pageUrl, redirectURL, wlanIfIndex){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		WirelessSetFormElement(parent.document, "wlanIfIndex", wlanIfIndex);

		changeSubMenu21Btn(clickId, pageUrl);
	}
	
	function changeWirelessSubMenu3Btn(clickId, pageUrl, redirectURL, wlanIfIndex){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		WirelessSetFormElement(parent.document, "wlanIfIndex", wlanIfIndex);
		
		changeSubMenu3Btn(clickId, pageUrl);
	}	

	function changeWireless_Repeater_SubMenu1Btn(clickId, pageUrl, redirectURL){
		var Check_GHz = "0";
		
		if(Check_GHz == 0)
			changeWirelessSubMenu1Btn(clickId, pageUrl, redirectURL, '0');
		else
			changeWirelessSubMenu1Btn(clickId, pageUrl, redirectURL, '100');
	}
	
	function changeWireless_Repeater_SubMenu3Btn(clickId, pageUrl, redirectURL){
                var Check_GHz = "0";

                if(Check_GHz == 0)
                        changeWirelessSubMenu3Btn(clickId, pageUrl, redirectURL, '0');
                else
                        changeWirelessSubMenu3Btn(clickId, pageUrl, redirectURL, '100');
        }

	function changeDnsSubMenu1Btn(clickId, pageUrl, redirectURL){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		changeBtn(clickId, pageUrl);
	}

	function changeDnsSubMenu3Btn(clickId, pageUrl, redirectURL){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		changeSubMenu3Btn(clickId, pageUrl);
	}

	function changeDnsPage(redirectURL){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		changeSubMenu3SubBtn("/goform/mcr_DnsCheck");
	}

	function changeLocalPage(redirectURL){
		WirelessSetFormElement(parent.document, "redirect-url", "/new/UserFolder/"+redirectURL);
		changeSubMenu3SubBtn("/goform/mcr_LocalCheck");
	}

	function changeSubMenu3SubBtn(pageUrl){
		changePage(pageUrl);

		viewPage = pageUrl;
	}

	function changePage(pageUrl){
		parent.changePage(pageUrl);
	}

	function logoff(){
		remove_auth_cache();
		document.form.action = "/goform/mcr_KTlogOut";
		document.form.submit();
	}

	function refresh(){
		changePage(viewPage);
		
	}
	
	function initValue(){
		vendor_menu_init();
	}
	function vendor_menu_init(){
		var projectCode = '<% mcr_getCfgCommon("SysConfDb_ProjectCode"); %>';
		var modelName = '<% mcr_getCfgCommon("DeviceInfo_ModelName"); %>';

		var obj = document.getElementById("userlog");

	}

</script>

<script language='JavaScript' type='text/javascript' src='/script/mcr_common_new.js?version=<% mcr_getWebVersion(); %>'></script>
</head>

<body oncontextmenu="return false" onselectstart="return false" onLoad="initValue()">
<form name="form">
<table class="table" cellpadding="0" cellspacing="0" width="200" height="100%" bgcolor="#f9f9f9">
	<tr>
		<td width="200" style="font-size:5px;" valign="top">
			<table cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td id='check1' class="td_open" width="200" height="39">
						<p><a href="javascript:;" Onclick="changeBtn('image1', '1_1_status_info.asp')+blur()" OnMouseOut="changeMouse('image1')"  OnMouseOver="na_change_img_src('image1', 'document', '/images/1Depth_admin/A_mouse.gif?Sp2', true);">
						<img src="/images/1Depth_admin/A_select.gif?Sp2" width="200" height="39" border="0" id="image1" name="image1" style="cursor:hand"></a></p>
					</td>
				</tr>
			</table>
					
			<table id="subMenu1" class="td" cellpadding="0" cellspacing="0" width="100%" style="display:inline;">
                		<tr>
                    			<td width="200" style="font-size:2px;">
                        			<p><a href="javascript:;" Onclick="changeSubMenu1Btn('image11', '1_1_status_info.asp')+blur()" OnMouseOut="changeMouse_1('image11')" OnMouseOver="na_change_img_src('image11', 'document', '/images/2Depth_admin/admin_A-1_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_A-1_select.gif?Sp2" width="200" height="22" border="0" id="image11" name="image11" style="cursor:hand"></a></p>
                 			</td>
                		</tr>
                		<tr>
                    			<td width="200" style="font-size:2px;">
                        			<p><a href="javascript:;" Onclick="changeSubMenu1Btn('image12', '1_2_cwlink_info.asp')+blur()" OnMouseOut="changeMouse_1('image12')" OnMouseOver="na_change_img_src('image12', 'document', '/images/2Depth_admin/admin_A-2_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_A-2_default.gif?Sp2" width="200" height="22" border="0" id="image12" name="image12" style="cursor:hand"></a></p>
                    			</td>
                		</tr>
                		<tr>
                    			<td width="200" style="font-size:2px;">
                        			<p><a href="javascript:;" Onclick="changeSubMenu1Btn('image13', '1_3_cwterminal_info.asp')+blur()" OnMouseOut="changeMouse_1('image13')" OnMouseOver="na_change_img_src('image13', 'document', '/images/2Depth_admin/admin_A-3_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_A-3_default.gif?Sp2" width="200" height="22" border="0" id="image13" name="image13" style="cursor:hand"></a></p>
                    			</td>
                		</tr>
                		<tr class="td">
                    			<td width="200" style="font-size:2px;">
                        			<p>
						<script language="JavaScript" type="text/javascript">
							if(Adminlog_en == 1){
								document.write("<a href='javascript:;' Onclick=\"changeSubMenu1Btn('image15', '1_4_log_info.asp')+blur()\" OnMouseOut=\"changeMouse_1('image15')\" OnMouseOver=\"na_change_img_src('image15', 'document', '/images/2Depth_admin/admin_A-5_mouse.gif?Sp2', true);\"><img src='/images/2Depth_admin/admin_A-5_default.gif?Sp2' width='200' height='22' border='0' id='image15' name='image15' style='cursor:hand'></a>\r\n");
							}else{
								document.write("<a href='javascript:;' Onclick=\"changeSubMenu1Btn('image14', '1_5_userlog_info.asp')+blur()\" OnMouseOut=\"changeMouse_1('image14')\" OnMouseOver=\"na_change_img_src('image14', 'document', '/images/2Depth_admin/admin_A-4_mouse.gif?Sp2', true);\"><img src='/images/2Depth_admin/admin_A-4_default.gif?Sp2' width='200' height='22' border='0' id='image14' name='image14' style='cursor:hand'></a>\r\n");
							}
						</script>
						</p>
                    			</td>
                		</tr>
			</table>

			<table cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td id='check_wlan' class="td" width="200" height="39">
						<p><a href="javascript:;" Onclick="changeWirelessSubMenu1Btn('image2', '/goform/mcr_getWirelessFormRedirect', '2_simple_open_set_all.asp', '2')+blur()" OnMouseOut="changeMouse('image2')"  OnMouseOver="na_change_img_src('image2', 'document', '/images/1Depth_admin/D_mouse.gif?Sp2', true);">
						<img src="/images/1Depth_admin/D_default.gif?Sp2" width="200" height="39" border="0" id="image2" name="image2" style="cursor:hand"></a></p>
					</td>
				</tr>
			</table>
			<table id="subMenu2" class="td" cellpadding="0" cellspacing="0" width="100%" style="display:none;">
				<tr>
					<td width="200" style="font-size:2px;" >
						<p><a href="javascript:;" Onclick="changeWirelessSubMenu2Btn('image2_24', '/goform/mcr_getWirelessFormRedirect', '2_simple_open_set.asp', '100')+blur()" OnMouseOut="changeMouse_wlan('image2_24')"  OnMouseOver="na_change_img_src('image2_24', 'document', '/images/2Depth_admin/admin_D-2_mouse_24.gif?Sp2', true);">
						<img src="/images/2Depth_admin/admin_D-2_default_24.gif?Sp2" width="200" height="22" border="0" id="image2_24" name="image2_24" style="cursor:hand"></a></p>
					</td>
				</tr>
				<tr id="view_5g_simpleset">
					<td width="200" style="font-size:2px;" >
						<p><a href="javascript:;" Onclick="changeWirelessSubMenu2Btn('image2_5', '/goform/mcr_getWirelessFormRedirect', '2_simple_open_set.asp', '0')+blur()" OnMouseOut="changeMouse_wlan('image2_5')"  OnMouseOver="na_change_img_src('image2_5', 'document', '/images/2Depth_admin/admin_D-2_mouse_5.gif?Sp2', true);">
						<img src="/images/2Depth_admin/admin_D-2_default_5.gif?Sp2" width="200" height="22" border="0" id="image2_5" name="image2_5" style="cursor:hand"></a></p>
					</td>
				</tr>
			</table>

			<table cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td id='check2' class="td" width="200" height="39">
						<p><a href="javascript:;" Onclick="changeWireless_Repeater_SubMenu1Btn('image3', '/goform/mcr_getWirelessFormRedirect', '3_1_1_ip_assign_policy.asp')+blur()" OnMouseOut="changeMouse('image3')"  OnMouseOver="na_change_img_src('image3', 'document', '/images/1Depth_admin/C_mouse.gif?Sp2', true);">
						<img src="/images/1Depth_admin/C_default.gif?Sp2" width="200" height="39" border="0" id="image3" name="image3" style="cursor:hand"></a></p>
					</td>
				</tr>
			</table>
			<table id="subMenu3" cellpadding="0" cellspacing="0" width="190" style="display:none;">
				<tr>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeWireless_Repeater_SubMenu3Btn('image31', '/goform/mcr_getWirelessFormRedirect', '3_1_1_ip_assign_policy.asp')+blur()" OnMouseOut="changeMouse_2('image31')" OnMouseOver="na_change_img_src('image31', 'document', '/images/2Depth_admin/admin_B-1_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-1_select.gif?Sp2" width="200" height="22" border="0" id="image31" name="image31" style="cursor:hand"></a></p>
					</td>
				</tr>
				<tr>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeWirelessSubMenu3Btn('image32_24', '/goform/mcr_getWirelessFormRedirect', '3_2_1_wireless_common_set.asp', '100')+blur()" OnMouseOut="changeMouse_2('image32_24')" OnMouseOver="na_change_img_src('image32_24', 'document', '/images/2Depth_admin/admin_B-2_mouse_24.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-2_default_24.gif?Sp2" width="200" height="22" border="0" id="image32_24" name="image32_24" style="cursor:hand"></a></p>
					</td>
				</tr>
				<tr id="view_5g_wlan_set">
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeWirelessSubMenu3Btn('image32_5', '/goform/mcr_getWirelessFormRedirect', '3_2_1_wireless_common_set.asp', '0')+blur()" OnMouseOut="changeMouse_2('image32_5')" OnMouseOver="na_change_img_src('image32_5', 'document', '/images/2Depth_admin/admin_B-2_mouse_5.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-2_default_5.gif?Sp2" width="200" height="22" border="0" id="image32_5" name="image32_5" style="cursor:hand"></a></p>
					</td>
				</tr>                
				<script language="JavaScript" type="text/javascript">
					if(repeater_en ==0){
						document.write("<tr>");
					}
					else{	
						document.write("<tr style='display:none'>");
					}
				</script>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeSubMenu3Btn('image33', '3_3_1_port_link_set.asp')+blur()" OnMouseOut="changeMouse_2('image33')" OnMouseOver="na_change_img_src('image33', 'document', '/images/2Depth_admin/admin_B-3_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-3_default.gif?Sp2" width="200" height="22" border="0" id="image33" name="image33" style="cursor:hand"></a></p>
					</td>
				</tr>
				<script language="JavaScript" type="text/javascript">
					if(repeater_en ==0){
						document.write("<tr>");
					}
					else{	
						document.write("<tr style='display:none'>");
					}
				</script>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeSubMenu3Btn('image34', '3_4_1_port_forwarding_set.asp')+blur()" OnMouseOut="changeMouse_2('image34')" OnMouseOver="na_change_img_src('image34', 'document', '/images/2Depth_admin/admin_B-4_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-4_default.gif?Sp2" width="200" height="22" border="0" id="image34" name="image34" style="cursor:hand"></a></p>
					</td>
				</tr>
				<script language="JavaScript" type="text/javascript">
					if(repeater_en ==0){
						document.write("<tr>");
					}
					else{	
						document.write("<tr style='display:none'>");
					}
				</script>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeSubMenu3Btn('image35', '3_5_1_secure_func_set.asp')+blur()" OnMouseOut="changeMouse_2('image35')" OnMouseOver="na_change_img_src('image35', 'document', '/images/2Depth_admin/admin_B-5_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-5_default.gif?Sp2" width="200" height="22" border="0" id="image35" name="image35" style="cursor:hand"></a></p>
					</td>
				</tr>
				<script language="JavaScript" type="text/javascript">
					if(repeater_en ==0){
						document.write("<tr>");
					}
					else{	
						document.write("<tr style='display:none'>");
					}
				</script>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeSubMenu3Btn('image36', '3_6_1_ddns_set.asp')+blur()" OnMouseOut="changeMouse_2('image36')" OnMouseOver="na_change_img_src('image36', 'document', '/images/2Depth_admin/admin_B-6_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-6_default.gif?Sp2" width="200" height="22" border="0" id="image36" name="image36" style="cursor:hand"></a></p>
					</td>
				</tr>
				<tr>
					<td width="200" style="font-size:2px;">
						<p><a href="javascript:;" Onclick="changeSubMenu3Btn('image37', '3_7_2_mange_account_set.asp')+blur()" OnMouseOut="changeMouse_2('image37')" OnMouseOver="na_change_img_src('image37', 'document', '/images/2Depth_admin/admin_B-7_mouse.gif?Sp2', true);"><img src="/images/2Depth_admin/admin_B-7_default.gif?Sp2" width="200" height="22" border="0" id="image37" name="image37" style="cursor:hand"></a>
						</p>
					</td>
				</tr>
					
			</table>
		</td>
	</tr>
</table>
</form>
</body>
</html>
