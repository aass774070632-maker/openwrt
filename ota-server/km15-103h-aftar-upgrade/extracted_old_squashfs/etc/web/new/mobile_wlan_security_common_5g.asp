<input type="hidden" id="wlanKey_5g_5g_org" name="wlanKey_5g_5g_org" value="<% mcr_getCfgWireless("Wlan_WEPPSKKey", 0); %>">
<input type="hidden" id="wlanUISecurityType_5g_org" name="wlanUISecurityType_5g_org" value="">
<input type="hidden" id="wlanUIWEPEncType_5g_org" name="wlanUIWEPEncType_5g_org" value="">
<input type="hidden" id="wlanWEPKeyType_5g_org" name="wlanWEPKeyType_5g_org" value="">
<input type="hidden" id="wlanUIWPAType_5g_org" name="wlanUIWPAType_5g_org" value="">
<input type="hidden" id="wlanUIWPAEncType_5g_org" name="wlanUIWPAEncType_5g_org" value="">
<input type="hidden" id="wlanUIPSKKeyType_5g_org" name="wlanUIPSKKeyType_5g_org" value="">

<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
	<tr id="5g_title">
		<td align="center" width"90%" style="font-weight:bold;">
			<label id="wlanTitle_5g"></label>
		</td>
	</tr>
	<tr>
		<td>
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr id="main_ssid_5g" style="display:none">
								<td width="35%">무선랜명(SSID)</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="text" name="cur_wlanSSID_5g" id="cur_wlanSSID_5g" size="32" maxlength="32" value="">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlan_change_5g" style="display:none">
								<td width="35%">변경할 무선랜명(SSID)</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="text" name="change_wlanSSID_5g" id="change_wlanSSID_5g" size="32" maxlength="33" value="" onclick="mcr_cursor_end(this)">
											</td>
											<td>
												<label id="lbl_wireless_wlanSSID_5g"></label>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlanViewPSK2_5g">
								<td width="35%">암호키</td>
								<td>
									<input type="password" name="wlanUIPSKKey_5g" id="wlanUIPSKKey_5g" size="32" maxlength="64" value=""/> 암호키보기
									<input type="checkbox" name="check_box_2" id="check_box_2" data-role="none">
								</td>
							</tr>
							<tr id="wireless_wlanUIPSKKey_5g">
								<td width="35%"></td>
								<td>
									<label id="lbl_wireless_wlanUIPSKKey_5g"></label>
								</td>
							</tr>		
							<tr id="wlanViewSecure_5g">
								<td width="35%">인증 보안 설정</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanUISecurityType_5g" id="wlanUISecurityType_5g" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanUISecurityType_5g">None</label>
													<input name="m_wlanUISecurityType_5g" type="radio" id="m_wlanUISecurityType_5g" value="0" onclick="setwlanUISecurityType_5g(this.value)">

													<label for="m_wlanUISecurityType_5g1" style="display:none;">802.1x</label>
													<input name="m_wlanUISecurityType_5g" type="radio" style="display:none;" id="m_wlanUISecurityType_5g1" value="4" onclick="setwlanUISecurityType_5g(this.value)">

													<label for="m_wlanUISecurityType_5g2">WEP</label>
													<input name="m_wlanUISecurityType_5g" type="radio" id="m_wlanUISecurityType_5g2" value="1" onclick="setwlanUISecurityType_5g(this.value)">

													<label for="m_wlanUISecurityType_5g3">WPA-PSK</label>
													<input name="m_wlanUISecurityType_5g" type="radio" id="m_wlanUISecurityType_5g3" value="2" onclick="setwlanUISecurityType_5g(this.value)">

													
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="wlanViewWEP_5g" style="display:none;">
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="35%">Authentication Type</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanUIWEPEncType_5g" id="wlanUIWEPEncType_5g" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">

													<label for="m_wlanUIWEPEncType_5g2">　Auto (Open/Shared)　</label>
													<input name="m_wlanUIWEPEncType_5g" type="radio" id="m_wlanUIWEPEncType_5g2" value="2" onclick="setwlanUIWEPEncType_5g(this.value)">
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td width="35%">Key Length</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanUIWEPKeyLen_5g" id="wlanUIWEPKeyLen_5g" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanUIWEPKeyLen_5g">　64bits (Key Index 1) </label>
													<input name="m_wlanUIWEPKeyLen_5g" type="radio" id="m_wlanUIWEPKeyLen_5g" value="0" onclick="setwlanUIWEPKeyLen_5g(this.value)">


												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td width="35%">Key Type</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanWEPKeyType_5g" id="wlanWEPKeyType_5g" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">


													<label for="m_wlanWEPKeyType_5g1">　HEX　</label>
													<input name="m_wlanWEPKeyType_5g" type="radio" id="m_wlanWEPKeyType_5g1" value="1" onclick="setwlanWEPKeyType_5g(this.value)">
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td width="35%">Key</td>
								<td>
									<input type="password" name="wlanUIWEPKey0_5g" id="wlanUIWEPKey0_5g" size="26" maxlength="26"> 암호키보기
									<input type="checkbox" name="check_box_3" id="check_box_3" data-role="none">
								</td>
							</tr>
							<tr>
								<td></td>
								<td><label for="text" valign="center">암호는 10자입니다.</label></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key2</td>
								<td><input type="text" name="wlanUIWEPKey1_5g" id="wlanUIWEPKey1_5g" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key3</td>
								<td><input type="text" name="wlanUIWEPKey2_5g" id="wlanUIWEPKey2_5g" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key4</td>
								<td><input type="text" name="wlanUIWEPKey3_5g" id="wlanUIWEPKey3_5g" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Default Key No.</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanWEPKeyIndex_5g" id="wlanWEPKeyIndex_5g" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanWEPKeyIndex_5g">　key1　</label>
													<input name="m_wlanWEPKeyIndex_5g" type="radio" id="m_wlanWEPKeyIndex_5g" value="0" onclick="setwlanWEPKeyIndex_5g(this.value)">

													<label for="m_wlanWEPKeyIndex_5g1">　key2　</label>
													<input name="m_wlanWEPKeyIndex_5g" type="radio" id="m_wlanWEPKeyIndex_5g1" value="1" onclick="setwlanWEPKeyIndex_5g(this.value)">

													<label for="m_wlanWEPKeyIndex_5g2">　key3　</label>
													<input name="m_wlanWEPKeyIndex_5g" type="radio" id="m_wlanWEPKeyIndex_5g2" value="2" onclick="setwlanWEPKeyIndex_5g(this.value)">

													<label for="m_wlanWEPKeyIndex_5g3">　key4　</label>
													<input name="m_wlanWEPKeyIndex_5g" type="radio" id="m_wlanWEPKeyIndex_5g3" value="3" onclick="setwlanWEPKeyIndex_5g(this.value)">
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanViewWPA_5g" style="display:none;">
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="35%">WPA Mode</td>
								<td>
									<input type="hidden" name="wlanUIWPAType_5g" id="wlanUIWPAType_5g" value="">
									<fieldset data-role="controlgroup" data-type="horizontal">
										<label for="m_wlanUIWPAType_5g">WPA</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g" value="0" onclick="setwlanUIWPAType_5g(this.value)">

										<label for="m_wlanUIWPAType_5g1">WPA2</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g1" value="1" onclick="setwlanUIWPAType_5g(this.value)">

										<label for="m_wlanUIWPAType_5g2">WPA&amp;WPA2</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g2" value="2" onclick="setwlanUIWPAType_5g(this.value)">
										
										<label for="m_wlanUIWPAType_5g3">WPA3</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g3" value="3" onclick="setwlanUIWPAType_5g(this.value)">
										
										<label for="m_wlanUIWPAType_5g4">WPA2&amp;WPA3</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g4" value="4" onclick="setwlanUIWPAType_5g(this.value)">
										
										<label for="m_wlanUIWPAType_5g5">WPA&amp;WPA2&amp;WPA3</label>
										<input name="m_wlanUIWPAType_5g" type="radio" id="m_wlanUIWPAType_5g5" value="5" onclick="setwlanUIWPAType_5g(this.value)">
									</fieldset>
								</td>
							</tr>
							<tr>
								<td width="35%">Encryption Type</td>
								<td>
									<input type="hidden" name="wlanUIWPAEncType_5g" id="wlanUIWPAEncType_5g" value="">
									<fieldset data-role="controlgroup" data-type="horizontal">
										<label for="m_wlanUIWPAEncType_5g">TKIP</label>
										<input name="m_wlanUIWPAEncType_5g" type="radio" id="m_wlanUIWPAEncType_5g" value="0" onclick="setwlanUIWPAEncType_5g(this.value)">

										<label for="m_wlanUIWPAEncType_5g1">AES</label>
										<input name="m_wlanUIWPAEncType_5g" type="radio" id="m_wlanUIWPAEncType_5g1" value="1" onclick="setwlanUIWPAEncType_5g(this.value)">
		
										<label for="m_wlanUIWPAEncType_5g2">TKIP&amp;AES</label>
										<input name="m_wlanUIWPAEncType_5g" type="radio" id="m_wlanUIWPAEncType_5g2" value="2" onclick="setwlanUIWPAEncType_5g(this.value)">
									</fieldset>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

