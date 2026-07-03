
<input type="hidden" id="wlanKey_org" name="wlanKey_org" value="<% mcr_getCfgWireless("Wlan_WEPPSKKey", 100); %>"/>
<input type="hidden" id="wlanUISecurityType_org" name="wlanUISecurityType_org" value=""/>
<input type="hidden" id="wlanUIWEPEncType_org" name="wlanUIWEPEncType_org" value=""/>
<input type="hidden" id="wlanWEPKeyType_org" name="wlanWEPKeyType_org" value=""/>
<input type="hidden" id="wlanUIWPAType_org" name="wlanUIWPAType_org" value=""/>
<input type="hidden" id="wlanUIWPAEncType_org" name="wlanUIWPAEncType_org" value=""/>
<input type="hidden" id="wlanUIPSKKeyType_org" name="wlanUIPSKKeyType_org" value=""/>

<table width="98%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td class="font5"> <label id="wlanTitle"></label></td>
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
												<input type="radio" id="wlanRadioActivity" name="wlanRadioActivity" value="1"/>활성
											</td>
											<td>
												<input type="radio" id="wlanRadioActivity1" name="wlanRadioActivity" value="0"/>비활성 
											</td>	
										</tr>
									</table>
								</td>
							</tr>	  
							<tr id="main_ssid">
								<td class="BG2" style="width:140px" nowrap>무선랜명(SSID)</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="text" id="user_id_fake" name="user_id_fake" autocomplete="off" style="display: none;">
												<input type="password" id="user_pwd_fake" name="user_pwd_fake" autocomplete="off" style="display: none;">
												<input type="text" name="cur_wlanSSID" id="cur_wlanSSID" size="32" maxlength="32" value=""/>
												<input type="password" name="wlanSSID_pass" id="wlanSSID_pass" size="32" maxlength="32" value=""/>
											</td>
											<td style="padding-left: 5px;">Hide SSID
												<input type="checkbox" name="wlanUIHiddenSSIDEnable" id="wlanUIHiddenSSIDEnable" />
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlan_change" style="display:none">
								<td class="BG2" style="width:140px" nowrap>변경할 무선랜명(SSID)</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td>
												<input type="text" name="change_wlanSSID" id="change_wlanSSID" size="32" maxlength="33" value="" onclick="mcr_cursor_end(this)"/>
											</td>
											<td style="padding-left: 5px;">
												<label id="lbl_wireless_wlanSSID"></label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanViewPSK2">
								<td class="BG2" style="width:140px;" rowspan="2">암호키</td>
								<td class="BG2-2">
									<input type="password" name="wlanUIPSKKey" id="wlanUIPSKKey" size="32" maxlength="64" value=""/> 암호키보기
									<input type="checkbox" name="check_box" name="check_box" tabindex="4" value="1"/>
								</td>
							</tr>
							<tr>
								<td class="BG2-2" id="wireless_wlanUIPSKKey">
									<label id="lbl_wireless_wlanUIPSKKey"></label>		
								</td>
							</tr>		
							<tr id="wlanViewPSK1">
								<td class="BG2" style="width:140px;">암호키 포맷</td>
								<td class="BG2-2">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="179">
										<tr>
											<td width="100">
												<input type="radio" name="wlanUIPSKKeyType" value="0"/>passphrase
											</td>
											<td>
												<input type="radio" name="wlanUIPSKKeyType" value="1"/>hex
											</td>
										</tr>
									</table>
								</td>
							</tr>	  

							<tr id="wlanViewSecure">	
								<td class="BG2" style="width:140px" nowrap>인증 보안 설정</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>	
											<td width="100">
												<input type="radio" name="wlanUISecurityType" value="0"/>None
											</td>
											<td width="100" id="viewUISecurityType_8021x">
												<input type="radio" name="wlanUISecurityType" value="4"/>802.1x
											</td>
											<td width="100">
												<input type="radio" name="wlanUISecurityType" value="1"/>WEP
											</td>
											<td width="100">
												<input type="radio" name="wlanUISecurityType" value="2"/>WPA-PSK
											</td>	
											<td id="viewUISecurityType_wpa_ent">
												<input type="radio" name="wlanUISecurityType" value="3"/>WPA-1x
											</td>
	
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanView8021x" style="display:none;">
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
												<input type="radio" name="wlanWEPRekeyEnable" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWEPRekeyEnable" value="0"/>비활성
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
												<input type="radio" name="wlanMACAuthEnable" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanMACAuthEnable" value="0"/>비활성
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr  id="wlanViewWEP" style="display:none;">
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
												<input type="radio" name="wlanUIWEPEncType" value="2" />Auto (Open/Shared)
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
												<input type="radio" name="wlanUIWEPKeyLen" value="0"/>64bits (Key Index 1)
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
												<input type="radio" name="wlanWEPKeyType" value="1"/><label>HEX</label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td class="BG2" style="width:140px;" rowspan="2">Key</td>
								<td class="BG2-2"><input type="password" name="wlanUIWEPKey0" id="wlanUIWEPKey0" size="26" maxlength="26"/> 암호키보기
									<input type="checkbox" name="check_box_1" name="check_box_1" tabindex="4" value="1"/>
								</td>
							</tr>
							<tr>
								<td class="BG2-2">
									<label id="wlanKey_alert" name="wlanKey_alert">암호는 10자입니다.</label>
								</td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key2</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey1" id="wlanUIWEPKey1" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key3</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey2" id="wlanUIWEPKey2" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Key4</td>
								<td class="BG2-2" width="580"><input type="text" name="wlanUIWEPKey3" id="wlanUIWEPKey3" size="26" maxlength="26"/></td>
							</tr>
							<tr style="display:none;">
								<td class="BG2" style="width:140px;">Default Key No.</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1" width="299">
										<tr>
											<td><input type="radio" name="wlanWEPKeyIndex" value="0"/>key1</td>
											<td><input type="radio" name="wlanWEPKeyIndex" value="1"/>key2</td>
											<td><input type="radio" name="wlanWEPKeyIndex" value="2"/>key3</td>
											<td><input type="radio" name="wlanWEPKeyIndex" value="3"/>key4</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanViewWPA" style="display:none;">
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
												<input type="radio" name="wlanUIWPAType" value="0"/>WPA
											</td>
											<td width="70">
												<input type="radio" name="wlanUIWPAType" value="1"/>WPA2
											</td>
											<td width="100">
												<input type="radio" name="wlanUIWPAType" value="2"/>WPA&amp;WPA2
											</td>
											<td width="70">
												<input type="radio" name="wlanUIWPAType" value="3"/>WPA3
											</td>
											<td width="100">
												<input type="radio" name="wlanUIWPAType" value="4"/>WPA2&amp;WPA3
											</td>
											<td>
												<input type="radio" name="wlanUIWPAType" value="5"/>WPA&amp;WPA2&amp;WPA3
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
												<input type="radio" id="wlanUIWPAEncTypeTKIP" name="wlanUIWPAEncType" value="0"/>TKIP
											</td>
											<td width="100">
												<input type="radio" id="wlanUIWPAEncTypeAES" name="wlanUIWPAEncType" value="1"/>AES
											</td>
											<td>
												<input type="radio" id="wlanUIWPAEncTypeTKIPAES" name="wlanUIWPAEncType" value="2"/>TKIP&amp;AES
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
												<input type="checkbox" name="wlanUIWPAKeyRenewalEnable" id="wlanUIWPAKeyRenewalEnable"/>사용함 	
											</td>
											<td>
												<input type="text" name="wlanUIWPAKeyRenewal" id="wlanUIWPAKeyRenewal" size="5" maxlength="5" value=""/>초
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
							<tr id="wlanViewWMM">
								<td class="BG2" style="width:140px;" nowrap>WMM</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanWMMEnable" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWMMEnable" value="0"/>비활성 
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanView_wauthEnable" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 사용</td>
								<td class="BG2-2" width="580">	
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanWauthEnable" value="1"/>활성
											</td>
											<td>
												<input type="radio" name="wlanWauthEnable" value="0"/>비활성 
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanView_wauthPk" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 Pre-shared Key</td>
								<td class="BG2-2" width="580">
									<input type="password" id="wlanWauthPk" name="wlanWauthPk" size="16" maxlength="16" value=""/>
								</td>
							</tr>
							<tr id="wlanView_wauthURL_Login" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 Login URL</td>
								<td class="BG2-2" width="580">
									<input type="text" id="wlanWauthURL_Login" name="wlanWauthURL_Login" size="50" maxlength="255" value=""/>
								</td>
							</tr>
							<tr id="wlanView_wauthURL_Logout" style="display:none">
								<td class="BG2" style="width:140px;">Web 인증 LogOut URL</td>
								<td class="BG2-2" width="580">
									<input type="text" id="wlanWauthURL_Logout" name="wlanWauthURL_Logout" size="50" maxlength="255" value=""/>
								</td>
							</tr>

							<tr id="wlanViewWebRedirection" style="display:none">
								<td class="BG2" style="width:140px;">Web Redirection</td>
								<td class="BG2-2" width="580">
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<input type="radio" name="wlanRedirectSet" value="1"/>활성
											</td>
											<td width="100">
												<input type="radio" name="wlanRedirectSet" value="0"/>비활성 
											</td>
											<td>
												<input type="text" id="wlanRedirectURL" name="wlanRedirectURL" size="50" maxlength="255" value=""></input>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="stb_info" style="display:none">
								<td class="BG2" style="width:140px;" nowrap>STB 접속 제한</td>
								<td class="BG2-2" width="580" nowrap>
									<table  border="0" cellpadding="0" cellspacing="0" class="font1">
										<tr>
											<td width="100">
												<select name="stb_num" class="input2" id="stb_num">
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
