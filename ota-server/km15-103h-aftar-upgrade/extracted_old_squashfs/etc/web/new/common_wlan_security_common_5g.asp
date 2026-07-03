
<input type="hidden" id="wlanKey_5g_org" name="wlanKey_5g_org" value="<% mcr_getCfgWireless("Wlan_WEPPSKKey", 0); %>"/>
<input type="hidden" id="wlanUISecurityType_5g_org" name="wlanUISecurityType_5g_org" value=""/>
<input type="hidden" id="wlanUIWEPEncType_5g_org" name="wlanUIWEPEncType_5g_org" value=""/>
<input type="hidden" id="wlanWEPKeyType_5g_org" name="wlanWEPKeyType_5g_org" value=""/>
<input type="hidden" id="wlanUIWPAType_5g_org" name="wlanUIWPAType_5g_org" value=""/>
<input type="hidden" id="wlanUIWPAEncType_5g_org" name="wlanUIWPAEncType_5g_org" value=""/>
<input type="hidden" id="wlanUIPSKKeyType_5g_org" name="wlanUIPSKKeyType_5g_org" value=""/>

<table width="98%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td class="font5"> <label id="wlanTitle_5g"></label></td>
	</tr>
	<tr>
		<td class="PD4"></td>
	</tr>
	<tr>
		<td class="PD5"></td>
	</tr>

	<tr>
		<td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="font1">
				<tr>
					<td width="780">
						<table class="TB" width="100%" border="0" style="table-layout:fixed">
							<col width="200"/>
							<col width="580"/>
							
							<tr>
								<td class="BG2" style="width:140px" nowrap>활성 여부</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" id="wlanRadioActivity_5g" name="wlanRadioActivity_5g" value="1"/>활성
											</td>
											<td>
												<input type="radio" id="wlanRadioActivity_5g1" name="wlanRadioActivity_5g" value="0"/>비활성 
											</td>	
										</tr>
									</table>
								</td>
							</tr>	  
							<tr id="main_ssid_5g">
								<td class="BG2" style="width:140px" nowrap>무선랜명(SSID)</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="text" id="user_id_fake_5g" name="user_id_fake_5g" autocomplete="off" style="display: none;">
												<input type="password" id="user_pwd_fake_5g" name="user_pwd_fake_5g" autocomplete="off" style="display: none;">
												<input type="text" name="cur_wlanSSID_5g" id="cur_wlanSSID_5g" size="32" maxlength="32" value=""/>
												<input type="password" name="wlanSSID_pass_5g" id="wlanSSID_pass_5g" size="32" maxlength="32" value=""/>
												<!-- wlanSSID_pass ??-->
											</td>
											<td style="padding-left: 5px;">Hide SSID
												<input type="checkbox" name="wlanUIHiddenSSIDEnable_5g" id="wlanUIHiddenSSIDEnable_5g" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlan_change_5g" style="display:none">
								<td class="BG2" style="width:140px" nowrap>변경할 무선랜명(SSID)</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="text" name="change_wlanSSID_5g" id="change_wlanSSID_5g" size="32" maxlength="33" value="" onclick="mcr_cursor_end(this)"/>
											</td>
											<td style="padding-left: 5px;">
												<label id="lbl_wireless_wlanSSID_5g"></label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanViewPSK2_5g">
								<td class="BG2" style="width:140px;" rowspan="2">암호키</td>
								<td class="BG2-2">
									<input type="password" name="wlanUIPSKKey_5g" id="wlanUIPSKKey_5g" size="32" maxlength="64" value=""/> 암호키보기
									<input type="checkbox" name="check_box_2" name="check_box_2" tabindex="4" value="1"/>
									<!-- SHCHO Check box 검토-->
								</td>
							</tr>
							<tr>
								<td class="BG2-2" id="wireless_wlanUIPSKKey_5g">
									<label id="lbl_wireless_wlanUIPSKKey_5g"></label>		
								</td>
							</tr>		
							<tr id="wlanViewPSK1_5g">
								<td class="BG2" style="width:140px;">암호키 포맷</td>
								<td class="BG2-2">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="179">
										<tr>
											<td width="100">
												<input type="radio" name="wlanUIPSKKeyType_5g" value="0"/>passphrase
											</td>
											<td>
												<input type="radio" name="wlanUIPSKKeyType_5g" value="1"/>hex
											</td>
										</tr>
									</table>
								</td>
							</tr>	  

							<tr id="wlanViewSecure_5g">	
								<td class="BG2" style="width:140px" nowrap>인증 보안 설정</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>	
											<td width="100">
												<input type="radio" name="wlanUISecurityType_5g" value="0"/>None
											</td>
											<td width="100" id="viewUISecurityType_8021x_5g">
												<input type="radio" name="wlanUISecurityType_5g" value="4"/>802.1x
											</td>
											<td width="100">
												<input type="radio" name="wlanUISecurityType_5g" value="1"/>WEP
											</td>
											<td width="100">
												<input type="radio" name="wlanUISecurityType_5g" value="2"/>WPA-PSK
											</td>	
											<td id="viewUISecurityType_wpa_ent_5g">
												<input type="radio" name="wlanUISecurityType_5g" value="3"/>WPA-1x
											</td>
	
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanView8021x_5g" style="display:none;">
					<td width="780">
						<table class="TB" width="100%" border="0" style="table-layout:fixed">
							<col width="200"/>
							<col width="580"/>
							<tr>
								<td class="BG2" style="width:140px" nowrap>Dynamic WEP</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanWEPRekeyEnable_5g" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWEPRekeyEnable_5g" value="0"/>비활성
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px">Mac Authentication</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanMACAuthEnable_5g" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanMACAuthEnable_5g" value="0"/>비활성
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr  id="wlanViewWEP_5g" style="display:none;">
					<td width="780">
						<table class="TB" width="100%" border="0" style="table-layout:fixed">
							<col width="200"/>
							<col width="580"/>
							<tr>
								<td class="BG2" style="width:140px" nowrap>Authentication Type</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="radio" name="wlanUIWEPEncType_5g" value="2" />Auto (Open/Shared)
											</td>	
										</tr>

									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">Key Length</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="radio" name="wlanUIWEPKeyLen_5g" value="0"/>64bits (Key Index 1)
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">Key Type</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="radio" name="wlanWEPKeyType_5g" value="1"/><label>HEX</label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;" rowspan="2">Key</td>
								<td class="BG2-2"><input type="password" name="wlanUIWEPKey0_5g" id="wlanUIWEPKey0_5g" size="26" maxlength="26"/> 암호키보기
									<input type="checkbox" name="check_box_3" name="check_box_3" tabindex="4" value="1"/>
									<!-- check box -->
								</td>
							</tr>
							<tr>
								<td class="BG2-2">
									<label id="wlanKey_alert_5g" name="wlanKey_alert_5g">암호는 10자입니다.</label>
								</td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key2</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey1_5g" id="wlanUIWEPKey1_5g" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key3</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey2_5g" id="wlanUIWEPKey2_5g" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key4</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey3_5g" id="wlanUIWEPKey3_5g" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Default Key No.</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="299">
										<tr>
											<td><input type="radio" name="wlanWEPKeyIndex_5g" value="0"/>key1</td>
											<td><input type="radio" name="wlanWEPKeyIndex_5g" value="1"/>key2</td>
											<td><input type="radio" name="wlanWEPKeyIndex_5g" value="2"/>key3</td>
											<td><input type="radio" name="wlanWEPKeyIndex_5g" value="3"/>key4</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanViewWPA_5g" style="display:none;">
					<td width="780">
						<table class="TB" width="100%" border="0" style="table-layout:fixed">
							<col width="200"/>
							<col width="580"/>
							<tr>
								<td class="BG2" style="width:140px" nowrap>WPA Mode</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="70">
												<input type="radio" name="wlanUIWPAType_5g" value="0"/>WPA
											</td>
											<td width="70">
												<input type="radio" name="wlanUIWPAType_5g" value="1"/>WPA2
											</td>
											<td width="100">
												<input type="radio" name="wlanUIWPAType_5g" value="2"/>WPA&amp;WPA2
											</td>
											<td width="70">
												<input type="radio" name="wlanUIWPAType_5g" value="3"/>WPA3
											</td>
											<td width="100">
												<input type="radio" name="wlanUIWPAType_5g" value="4"/>WPA2&amp;WPA3
											</td>
											<td>
												<input type="radio" name="wlanUIWPAType_5g" value="5"/>WPA&amp;WPA2&amp;WPA3
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">Encryption Type</td>
								<td class="BG2-2">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" id="wlanUIWPAEncTypeTKIP_5g" name="wlanUIWPAEncType_5g" value="0"/>TKIP
											</td>
											<td width="100">
												<input type="radio" id="wlanUIWPAEncTypeAES_5g" name="wlanUIWPAEncType_5g" value="1"/>AES
											</td>
											<td>
												<input type="radio" id="wlanUIWPAEncTypeTKIPAES_5g" name="wlanUIWPAEncType_5g" value="2"/>TKIP&amp;AES
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;">Broadcast Key Update</td>
								<td class="BG2-2">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="checkbox" name="wlanUIWPAKeyRenewalEnable_5g" id="wlanUIWPAKeyRenewalEnable_5g"/>사용함 	
											</td>
											<td>
												<input type="text" name="wlanUIWPAKeyRenewal_5g" id="wlanUIWPAKeyRenewal_5g" size="5" maxlength="5" value=""/>초
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>	
					</td>
				</tr>
				<tr>
					<td width="780">
						<table class="TB" width="100%" border="0" style="table-layout:fixed">
							<col width="200"/>
							<col width="580"/>
							<tr id="wlanViewWMM_5g">
								<td class="BG2" style="width:140px;" nowrap>WMM</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanWMMEnable_5g" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWMMEnable_5g" value="0"/>비활성 
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanView_wauthEnable_5g" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 사용</td>
								<td class="BG2-2" width="580">	
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanWauthEnable_5g" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWauthEnable_5g" value="0"/>비활성 
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanView_wauthPk_5g" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 Pre-shared Key</td>
								<td class="BG2-2" width="580">
									<input type="password" id="wlanWauthPk_5g" name="wlanWauthPk_5g" size="16" maxlength="16" value=""/>
								</td>
							</tr>
							<tr id="wlanView_wauthURL_Login_5g" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 Login URL</td>
								<td class="BG2-2" width="580">
									<input type="text" id="wlanWauthURL_Login_5g" name="wlanWauthURL_Login_5g" size="50" maxlength="255" value=""/>
								</td>
							</tr>
							<tr id="wlanView_wauthURL_Logout_5g" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 LogOut URL</td>
								<td class="BG2-2" width="580">
									<input type="text" id="wlanWauthURL_Logout_5g" name="wlanWauthURL_Logout_5g" size="50" maxlength="255" value=""/>
								</td>
							</tr>

							<tr id="wlanViewWebRedirection_5g" style="display:none">
								<td class="BG2" style="width:140px;">Web Redirection</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanRedirectSet_5g" value="1"/>활성
											</td>
											<td width="100">
												<input type="radio" name="wlanRedirectSet_5g" value="0"/>비활성 
											</td>
											<td>
												<input type="text" id="wlanRedirectURL_5g" name="wlanRedirectURL_5g" size="50" maxlength="255" value=""></input>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<!-- STB NUM check-->
							<tr id="stb_info_5g" style="display:none">
								<td class="BG2" style="width:140px;" nowrap>STB 접속 제한</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<select name="stb_num_5g" class="input2" id="stb_num_5g">
													<option value="1">1</option>
													<option value="2">2</option>
													<option value="3">3</option>
												</select>
											</td>
										</tr>
									</table>
                                        			</td>
                                			<tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
