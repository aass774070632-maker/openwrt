<table cellpadding="0" cellspacing="0" width="775" height="100" bgcolor="f2f2f2">
	<tr>
		<td valign="top">
			<table cellpadding="0" cellspacing="0" width="775" height="100%">
				<tr height="27">
					<td width="113" valign="top">
						<%
							var imageFileEJ = "";
							if ( gWlanIfIndexEJ == '0' )
								imageFileEJ = "/images/ad_2D_title_02_5.gif?Sp2";
							else
								imageFileEJ = "/images/ad_2D_title_02_24.gif?Sp2";
							write("<img src='"+imageFileEJ+"' width='111' height='27' border='0' style='margin:0px 0px 0px 0px'>");
						%>
					</td>
					<td width="220" valign="bottom">
						<a href="javascript:;" Onclick="WirelessChangePage(parent.menu, 'AdminFolder/3_2_1_wireless_common_set.asp', gWlanIfIndex)">
							<label id="wlanUIMenu00" class="menu3rdNormal" style="cursor:pointer;">| 무선 공통 설정</label>
						</a>
					</td>
					<td width="220" valign="bottom">
						<script language="JavaScript" type="text/javascript">
							document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'/AdminFolder/3_2_7_soip_connect_set.asp',gWlanIfIndex)>\r\n");
							document.write("<label id='wlanUIMenu12' class='menu3rdNormal' style='cursor:pointer;'>| Mesh WLAN 접속 설정</label></a>\r\n");
						</script>
					</td>
					<td width="220" valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if(gWlanIfIndex == '0'){
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'/AdminFolder/3_2_12_ratelimit.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu22' class='menu3rdNormal' style='cursor:pointer;'>| 속도 제한</label></a>\r\n");
							}else{
								document.write("\r\n");
							}
						</script>
					</td>
					<td width="220" valign="bottom">
					</td>
				</tr>
				<tr height="23">
					<td>
					</td>
					<td valign="bottom">
						<a href="javascript:;" Onclick="WirelessChangePage(parent.menu, 'AdminFolder/3_2_2_wps_set.asp', gWlanIfIndex)">
						<label id="wlanUIMenu01" class="menu3rdNormal" style="cursor:pointer;">| WPS 설정</label>
						</a>
					</td>
					<td valign="bottom">
						<script language="JavaScript" type="text/javascript">
							document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_8_home_wlan_connection.asp',gWlanIfIndex)>\r\n");
							document.write("<label id='wlanUIMenu13' class='menu3rdNormal' style='cursor:pointer;'>| Home WLAN 접속 설정</label></a>\r\n");
						</script>
					</td>
					<td valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if( gWlanIfIndex == '0'){
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_13_airtime_fairness.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu14' class='menu3rdNormal' style='cursor:pointer;'>| Airtime Fairness 설정</label></a>\r\n");
							}else{
								document.write("\r\n");
							}
						</script>
					</td>
				</tr>
				<tr height="23">
					<td>
					</td>
					<td valign="bottom">
						<a href="javascript:;" onclick="WirelessChangePage(parent.menu,'/AdminFolder/3_2_3_wmm_policy_set.asp',gWlanIfIndex)">
							<label id="wlanUIMenu02" class="menu3rdNormal" style="cursor:pointer;">| WMM 정책 설정</label>
						</a>
					</td>
					<td valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if ( gWlanIfIndex == '0' ) {
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_16_iow_connect_set.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu24' class='menu3rdNormal' style='cursor:pointer;'>| IoW WLAN 접속 설정</label></a>");
							}else{
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_9_wconnect_terminal_manage.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu20' class='menu3rdNormal' style='cursor:pointer;'>| 무선 접속 단말 관리</label></a>\r\n");
							}
						</script>
					</td>
					<td valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if ( gWlanIfIndex == '0' ) {
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_15_mesh_set.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu23' class='menu3rdNormal' style='cursor:pointer;'>| Mesh 설정</label></a>\r\n");
							}else{
								document.write("\r\n");
							}
						</script>
					</td>
				</tr>
				<tr height="23">
					<td>
					</td>
					<td valign="bottom">
						<a href="javascript:;" Onclick="WirelessChangePage(parent.menu,'AdminFolder/3_2_10_wmac_filtering_set.asp',gWlanIfIndex)">
							<label id="wlanUIMenu03" class="menu3rdNormal" style="cursor:pointer;">| 무선 MAC 필터링 설정</label>
						</a>
					</td>
					<td valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if ( gWlanIfIndex == '0' ) {
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_9_wconnect_terminal_manage.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu20' class='menu3rdNormal' style='cursor:pointer;'>| 무선 접속 단말 관리</label></a>\r\n");
							}
							else{
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'/AdminFolder/3_2_12_ratelimit.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu22' class='menu3rdNormal' style='cursor:pointer;'>| 속도 제한</label></a>\r\n");
							}
						</script>
					</td>
					<td width="220" valign="bottom">
						<script language="JavaScript" type="text/javascript">
							if ( gWlanIfIndex == '0' ) {
								document.write("<a href='javascript:;' Onclick=WirelessChangePage(parent.menu,'AdminFolder/3_2_17_iow_set.asp',gWlanIfIndex)>\r\n");
								document.write("<label id='wlanUIMenu25' class='menu3rdNormal' style='cursor:pointer;'>| IoW 설정</label></a>");
							}else{
								document.write("\r\n");
                            				}
						</script>
					</td>
				</tr>
				<tr height="4">
					<td colspan="4">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
