<input type="hidden" id="wlanKey_org" name="wlanKey_org" value="<% mcr_getCfgWireless("Wlan_WEPPSKKey", 100); %>">
<input type="hidden" id="wlanUISecurityType_org" name="wlanUISecurityType_org" value="">
<input type="hidden" id="wlanUIWEPEncType_org" name="wlanUIWEPEncType_org" value="">
<input type="hidden" id="wlanWEPKeyType_org" name="wlanWEPKeyType_org" value="">
<input type="hidden" id="wlanUIWPAType_org" name="wlanUIWPAType_org" value="">
<input type="hidden" id="wlanUIWPAEncType_org" name="wlanUIWPAEncType_org" value="">
<input type="hidden" id="wlanUIPSKKeyType_org" name="wlanUIPSKKeyType_org" value="">

<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
	<tr id="2g_title">
		<td align="center" width"90%" style="font-weight:bold;">
			<label id="wlanTitle_2g"></label>
		</td>
	</tr>
	<tr height="10px"></tr>
	<tr>
		<td>
			<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
				<tr>
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr id="main_ssid" style="display:none">
								<td width="35%">무선랜명(SSID)</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="text" name="cur_wlanSSID" id="cur_wlanSSID" size="32" maxlength="32" value="">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr id="wlan_change" style="display:none">
								<td width="35%">변경할 무선랜명(SSID)</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="text" name="change_wlanSSID" id="change_wlanSSID" size="32" maxlength="33" value="" onclick="mcr_cursor_end(this)">
											</td>
											<td>
												<label id="lbl_wireless_wlanSSID"></label>
											</td>
										</tr>
									</table>
								</td>
							</tr>

							<tr id="wlanViewPSK2">
								<td width="35%">암호키</td>
								<td>
									<input type="password" name="wlanUIPSKKey" id="wlanUIPSKKey" size="32" maxlength="64" value=""/> 암호키보기
									<input type="checkbox" name="check_box" id="check_box" data-role="none">
								</td>
							</tr>
							<tr id="wireless_wlanUIPSKKey">
								<td width="35%"></td>
								<td>
									<label id="lbl_wireless_wlanUIPSKKey"></label>
								</td>
							</tr>		
							<tr id="wlanViewSecure">
								<td width="35%">인증 보안 설정</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanUISecurityType" id="wlanUISecurityType" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanUISecurityType">None</label>
													<input name="m_wlanUISecurityType" type="radio" id="m_wlanUISecurityType" value="0" onclick="setwlanUISecurityType(this.value)">

													<label for="m_wlanUISecurityType1" style="display:none;">802.1x</label>
													<input name="m_wlanUISecurityType" type="radio" style="display:none;" id="m_wlanUISecurityType1" value="4" onclick="setwlanUISecurityType(this.value)">

													<label for="m_wlanUISecurityType2">WEP</label>
													<input name="m_wlanUISecurityType" type="radio" id="m_wlanUISecurityType2" value="1" onclick="setwlanUISecurityType(this.value)">

													<label for="m_wlanUISecurityType3">WPA-PSK</label>
													<input name="m_wlanUISecurityType" type="radio" id="m_wlanUISecurityType3" value="2" onclick="setwlanUISecurityType(this.value)">

													
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="wlanViewWEP" style="display:none;">
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="35%">Authentication Type</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanUIWEPEncType" id="wlanUIWEPEncType" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">

													<label for="m_wlanUIWEPEncType2">　Auto (Open/Shared)　</label>
													<input name="m_wlanUIWEPEncType" type="radio" id="m_wlanUIWEPEncType2" value="2" onclick="setwlanUIWEPEncType(this.value)">
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
												<input type="hidden" name="wlanUIWEPKeyLen" id="wlanUIWEPKeyLen" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanUIWEPKeyLen">　64bits (Key Index 1) </label>
													<input name="m_wlanUIWEPKeyLen" type="radio" id="m_wlanUIWEPKeyLen" value="0" onclick="setwlanUIWEPKeyLen(this.value)">


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
												<input type="hidden" name="wlanWEPKeyType" id="wlanWEPKeyType" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanWEPKeyType1">　HEX　</label>
													<input name="m_wlanWEPKeyType" type="radio" id="m_wlanWEPKeyType1" value="1" onclick="setwlanWEPKeyType(this.value)">
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td width="35%">Key</td>
								<td>
									<input type="password" name="wlanUIWEPKey0" id="wlanUIWEPKey0" size="26" maxlength="26"> 암호키보기
									<input type="checkbox" name="check_box_1" id="check_box_1" data-role="none">
								</td>
							</tr>
							<tr>
								<td></td>
								<td><label id="wlanKey_alert" name="wlanKey_alert">암호는 10자입니다.</label></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key2</td>
								<td><input type="text" name="wlanUIWEPKey1" id="wlanUIWEPKey1" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key3</td>
								<td><input type="text" name="wlanUIWEPKey2" id="wlanUIWEPKey2" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Key4</td>
								<td><input type="text" name="wlanUIWEPKey3" id="wlanUIWEPKey3" size="26" maxlength="26"></td>
							</tr>
							<tr style="display:none;">
								<td width="35%">Default Key No.</td>
								<td>
									<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
										<tr>
											<td>
												<input type="hidden" name="wlanWEPKeyIndex" id="wlanWEPKeyIndex" value="">
												<fieldset data-role="controlgroup" data-type="horizontal">
													<label for="m_wlanWEPKeyIndex">　key1　</label>
													<input name="m_wlanWEPKeyIndex" type="radio" id="m_wlanWEPKeyIndex" value="0" onclick="setwlanWEPKeyIndex(this.value)">

													<label for="m_wlanWEPKeyIndex1">　key2　</label>
													<input name="m_wlanWEPKeyIndex" type="radio" id="m_wlanWEPKeyIndex1" value="1" onclick="setwlanWEPKeyIndex(this.value)">

													<label for="m_wlanWEPKeyIndex2">　key3　</label>
													<input name="m_wlanWEPKeyIndex" type="radio" id="m_wlanWEPKeyIndex2" value="2" onclick="setwlanWEPKeyIndex(this.value)">

													<label for="m_wlanWEPKeyIndex3">　key4　</label>
													<input name="m_wlanWEPKeyIndex" type="radio" id="m_wlanWEPKeyIndex3" value="3" onclick="setwlanWEPKeyIndex(this.value)">
												</fieldset>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr id="wlanViewWPA" style="display:none;">
					<td>
						<table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" valign="middle">
							<tr>
								<td width="35%">WPA Mode</td>
								<td>
									<input type="hidden" name="wlanUIWPAType" id="wlanUIWPAType" value="">
									<fieldset data-role="controlgroup" data-type="horizontal">
										<label for="m_wlanUIWPAType">WPA</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType" value="0" onclick="setwlanUIWPAType(this.value)">

										<label for="m_wlanUIWPAType1">WPA2</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType1" value="1" onclick="setwlanUIWPAType(this.value)">

										<label for="m_wlanUIWPAType2">WPA&amp;WPA2</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType2" value="2" onclick="setwlanUIWPAType(this.value)">
										
										<label for="m_wlanUIWPAType3">WPA3</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType3" value="3" onclick="setwlanUIWPAType(this.value)">
										
										<label for="m_wlanUIWPAType4">WPA2&amp;WPA3</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType4" value="4" onclick="setwlanUIWPAType(this.value)">
										
										<label for="m_wlanUIWPAType5">WPA&amp;WPA2&amp;WPA3</label>
										<input name="m_wlanUIWPAType" type="radio" id="m_wlanUIWPAType5" value="5" onclick="setwlanUIWPAType(this.value)">
									</fieldset>
								</td>
							</tr>
							<tr>
								<td width="35%">Encryption Type</td>
								<td>
									<input type="hidden" name="wlanUIWPAEncType" id="wlanUIWPAEncType" value="">
									<fieldset data-role="controlgroup" data-type="horizontal">
										<label for="m_wlanUIWPAEncType">TKIP</label>
										<input name="m_wlanUIWPAEncType" type="radio" id="m_wlanUIWPAEncType" value="0" onclick="setwlanUIWPAEncType(this.value)">

										<label for="m_wlanUIWPAEncType1">AES</label>
										<input name="m_wlanUIWPAEncType" type="radio" id="m_wlanUIWPAEncType1" value="1" onclick="setwlanUIWPAEncType(this.value)">
		
										<label for="m_wlanUIWPAEncType2">TKIP&amp;AES</label>
										<input name="m_wlanUIWPAEncType" type="radio" id="m_wlanUIWPAEncType2" value="2" onclick="setwlanUIWPAEncType(this.value)">
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

