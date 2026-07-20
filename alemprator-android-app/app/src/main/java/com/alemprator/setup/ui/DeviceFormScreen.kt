package com.alemprator.setup.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alemprator.setup.db.Device
import com.alemprator.setup.logic.IPValidationEngine
import kotlinx.coroutines.launch

// Premium Gold & Dark HSL Palette
val DarkBg = Color(0xFF050505)
val GoldPrimary = Color(0xFFD4AF37)
val GoldGlow = Color(0x33D4AF37)
val CardBg = Color(0xFF121212)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeviceFormScreen(
    validationEngine: IPValidationEngine,
    onSaveDevice: (Device) -> Unit,
    onScanMacClick: () -> Unit,
    onShowDeviceList: () -> Unit = {},
    scannedMac: String = "",
    lookupDeviceByMac: suspend (String) -> Device? = { null },
    deriveTemplateForType: suspend (String) -> Device? = { null }
) {
    var deviceName by remember { mutableStateOf("") }
    var macAddress by remember { mutableStateOf("") }
    var selectedMode by remember { mutableStateOf("ap") }
    var lanIp by remember { mutableStateOf("") }
    var lanNetmask by remember { mutableStateOf("255.255.255.0") }
    var ipConflictMessage by remember { mutableStateOf<String?>(null) }
    var isIpValid by remember { mutableStateOf(true) }

    // Hotspot range validation: structure check + private-range warning.
    var hotspotIpError by remember { mutableStateOf<String?>(null) }

    // Wi-Fi basic settings state variables
    var wifiSsid by remember { mutableStateOf("ALEMPRATOR_AP") }
    var wifiKey by remember { mutableStateOf("123456789") }
    var wifiChannel by remember { mutableStateOf("36") }

    // Advanced switch options

    // 1. Radio & Channels (2.4G & 5G)
    var wifi2gChannel by remember { mutableStateOf("auto") }
    var wifi2gMode by remember { mutableStateOf("ax") }
    var wifi2gWidth by remember { mutableStateOf("20") }
    var wifi5gChannel by remember { mutableStateOf("36") }
    var wifi5gMode by remember { mutableStateOf("ax") }
    var wifi5gWidth by remember { mutableStateOf("80") }

    // SSID advanced
    var wifi5gNameType by remember { mutableStateOf("derived") } // "derived" or "custom"
    var wifi5gCustomSsid by remember { mutableStateOf("") }
    var appendIpToSsid by remember { mutableStateOf(false) }

    // OTA Auto-Update window
    var otaWindowStart by remember { mutableStateOf("2") }
    var otaWindowEnd by remember { mutableStateOf("6") }

    // VLAN
    var vlanEnabled by remember { mutableStateOf(false) }
    var vlanId by remember { mutableStateOf("10") }
    var vlanSsid2g by remember { mutableStateOf("") }
    var vlanSsid5g by remember { mutableStateOf("") }
    var vlanSsidIpSuffix by remember { mutableStateOf(false) }

    // Buttons & Maintenance (Common)
    var disableResetButton by remember { mutableStateOf(false) }
    var resetPressDuration by remember { mutableStateOf("5") }
    var disableWpsButton by remember { mutableStateOf(false) }
    var autoRebootEnabled by remember { mutableStateOf(false) }
    var rebootHours by remember { mutableStateOf("24") }
    var rootPassword by remember { mutableStateOf("") }
    var confirmRootPassword by remember { mutableStateOf("") }

    // Hotspot Network settings
    var hotspotWanInterface by remember { mutableStateOf("wan") }
    var hotspotSubscriberInterface by remember { mutableStateOf("hotspot") }
    var hotspotPrimaryIp by remember { mutableStateOf("192.168.10.1") }
    var hotspotPrimaryPoolStart by remember { mutableStateOf("192.168.10.10") }
    var hotspotPrimaryPoolEnd by remember { mutableStateOf("192.168.10.199") }
    var hotspotPrimaryPolicy by remember { mutableStateOf("standard") }
    var hotspotDnsName by remember { mutableStateOf("hotspot.local") }
    var hotspotDns1 by remember { mutableStateOf("8.8.8.8") }
    var hotspotDns2 by remember { mutableStateOf("82.114.163.31") }
    var hotspotBridgeAgeingTime by remember { mutableStateOf("10") }
    var hotspotCardPage by remember { mutableStateOf("both") }
    var hotspotRateLimit by remember { mutableStateOf("2M/5M") }
    var hotspotMacCookie by remember { mutableStateOf(true) }
    var hotspotAvailableSpeeds by remember { mutableStateOf("1M/2M Standard\n2M/4M Fast") }
    var hotspotSecondaryEnabled by remember { mutableStateOf(true) }
    var hotspotSecondarySsid by remember { mutableStateOf("Hotspot-2") }
    var hotspotSecondaryIp by remember { mutableStateOf("192.168.20.1") }
    var hotspotSecondaryPoolStart by remember { mutableStateOf("192.168.20.10") }
    var hotspotSecondaryPoolEnd by remember { mutableStateOf("192.168.20.199") }
    var hotspotSecondaryPolicy by remember { mutableStateOf("premium") }
    var hotspotMacAuthEnabled by remember { mutableStateOf(false) }
    var hotspotMacAuthSuffix by remember { mutableStateOf("@mac") }
    var hotspotMacAuthPassword by remember { mutableStateOf("mac") }
    var hotspotWalledGarden by remember { mutableStateOf("") }
    var hotspotBrowserCookieEnabled by remember { mutableStateOf(true) }
    var hotspotBrowserCookieDays by remember { mutableStateOf("7") }
    var hotspotTrialEnabled by remember { mutableStateOf(false) }
    var hotspotTrialDuration by remember { mutableStateOf("30") }
    var hotspotTrialUptimeLimit by remember { mutableStateOf("30") }

    // Hotspot RADIUS Credentials
    var radiusServer by remember { mutableStateOf("192.168.1.2") }
    var radiusServerBackup by remember { mutableStateOf("") }
    var radiusSecret by remember { mutableStateOf("") }
    var radiusAuthPort by remember { mutableStateOf("1812") }
    var radiusAcctPort by remember { mutableStateOf("1813") }
    var radiusNasIp by remember { mutableStateOf("192.168.1.20") }
    var radiusNasId by remember { mutableStateOf("KT-KM14-102H-HOTSPOT") }
    var radiusInterimUpdate by remember { mutableStateOf("60") }
    var radiusCoaEnabled by remember { mutableStateOf(false) }
    var radiusCoaPort by remember { mutableStateOf("3799") }

    // REST API integration
    var restApiEnabled by remember { mutableStateOf(false) }
    var restApiProto by remember { mutableStateOf("https") }
    var restApiUsername by remember { mutableStateOf("hotspot-read") }
    var restApiPassword by remember { mutableStateOf("") }

    // Portal support / Ads
    var portalSupportPhone by remember { mutableStateOf("") }
    var portalNotification by remember { mutableStateOf("أهلاً بكم في شبكتنا") }
    var portalLiveEnabled by remember { mutableStateOf(false) }
    var portalLiveUrl by remember { mutableStateOf("") }
    var portalBreakEnabled by remember { mutableStateOf(false) }
    var portalBreakUrl by remember { mutableStateOf("") }
    var portalSpeedtestEnabled by remember { mutableStateOf(false) }

    // Scheduled Maintenance & Autoupdate
    var maintenanceEnabled by remember { mutableStateOf(false) }
    var maintenancePolicy by remember { mutableStateOf("free") }
    var maintenanceStartTime by remember { mutableStateOf("02:00") }
    var maintenanceEndTime by remember { mutableStateOf("03:00") }
    var autoupdateStartTime by remember { mutableStateOf("02:00") }
    var autoupdateEndTime by remember { mutableStateOf("06:00") }

    // Station/Client Uplink/Backhaul settings
    var uplinkBand by remember { mutableStateOf("2.4GHz") }
    var uplinkSsid by remember { mutableStateOf("") }
    var uplinkKey by remember { mutableStateOf("") }

    // Smart Mesh settings
    var meshBand by remember { mutableStateOf("2.4GHz") }
    var meshId by remember { mutableStateOf("") }
    var meshKey by remember { mutableStateOf("") }

    // Collapsible accordion expansion states
    var isWifiExpanded by remember { mutableStateOf(false) }
    var isVlanExpanded by remember { mutableStateOf(false) }
    var isMaintenanceExpanded by remember { mutableStateOf(false) }
    
    // Hotspot accordion states
    var isHotspotNetExpanded by remember { mutableStateOf(false) }
    var isHotspotAuthExpanded by remember { mutableStateOf(false) }

    // Set defaults when mode changes
    LaunchedEffect(selectedMode) {
        when (selectedMode) {
            "ap" -> {
                wifiSsid = "ALEMPRATOR_AP"
                wifiKey = "123456789"
                wifiChannel = "36"
            }
            "hotspot" -> {
                wifiSsid = "Hotspot-1"
                wifiKey = ""
                wifiChannel = ""
                hotspotPrimaryIp = "192.168.10.1"
                hotspotPrimaryPoolStart = "192.168.10.10"
                hotspotPrimaryPoolEnd = "192.168.10.199"
                hotspotPrimaryPolicy = "standard"
                hotspotSecondaryEnabled = true
                hotspotSecondarySsid = "Hotspot-2"
                hotspotSecondaryIp = "192.168.20.1"
                hotspotSecondaryPoolStart = "192.168.20.10"
                hotspotSecondaryPoolEnd = "192.168.20.199"
                hotspotSecondaryPolicy = "premium"
            }
            "ap_wds" -> {
                wifiSsid = "ALEMPRATOR_AP"
                wifiKey = "123456789"
                wifiChannel = ""
            }
            "sta_wds" -> {
                wifiSsid = "UPLINK_WIFI"
                wifiKey = "123456789"
                wifiChannel = ""
            }
            "mesh" -> {
                wifiSsid = "ALEMPRATOR_MESH"
                wifiKey = "123456789"
                wifiChannel = ""
            }
            else -> {
                wifiSsid = ""
                wifiKey = ""
                wifiChannel = ""
            }
        }
    }

    val scope = rememberCoroutineScope()

    // Helper: copy all fields from a Device to state variables
    fun loadDeviceFields(t: Device) {
        deviceName = t.deviceName
        lanIp = t.lanIp
        lanNetmask = t.lanNetmask
        wifiSsid = t.wifiSsid ?: ""
        wifiKey = t.wifiKey ?: ""
        wifiChannel = t.wifiChannel ?: ""
        wifi2gChannel = t.wifi2gChannel
        wifi2gMode = t.wifi2gMode
        wifi2gWidth = t.wifi2gWidth
        wifi5gChannel = t.wifi5gChannel
        wifi5gMode = t.wifi5gMode
        wifi5gWidth = t.wifi5gWidth
        wifi5gNameType = t.wifi5gNameType
        wifi5gCustomSsid = t.wifi5gCustomSsid ?: ""
        appendIpToSsid = t.appendIpToSsid
        otaWindowStart = t.otaWindowStart
        otaWindowEnd = t.otaWindowEnd
        vlanEnabled = t.vlanEnabled
        vlanId = t.vlanId ?: ""
        vlanSsid2g = t.vlanSsid2g ?: ""
        vlanSsid5g = t.vlanSsid5g ?: ""
        vlanSsidIpSuffix = t.vlanSsidIpSuffix
        disableResetButton = t.disableResetButton
        resetPressDuration = t.resetPressDuration
        disableWpsButton = t.disableWpsButton
        autoRebootEnabled = t.autoRebootEnabled
        rootPassword = t.rootPassword ?: ""
        hotspotWanInterface = t.hotspotWanInterface
        hotspotSubscriberInterface = t.hotspotSubscriberInterface
        hotspotPrimaryIp = t.hotspotPrimaryIp
        hotspotPrimaryPoolStart = t.hotspotPrimaryPoolStart ?: ""
        hotspotPrimaryPoolEnd = t.hotspotPrimaryPoolEnd ?: ""
        hotspotPrimaryPolicy = t.hotspotPrimaryPolicy
        hotspotDnsName = t.hotspotDnsName
        hotspotDns1 = t.hotspotDns1
        hotspotDns2 = t.hotspotDns2
        hotspotBridgeAgeingTime = t.hotspotBridgeAgeingTime
        hotspotCardPage = t.hotspotCardPage
        hotspotRateLimit = t.hotspotRateLimit
        hotspotMacCookie = t.hotspotMacCookie
        hotspotAvailableSpeeds = t.hotspotAvailableSpeeds
        hotspotSecondaryEnabled = t.hotspotSecondaryEnabled
        hotspotSecondarySsid = t.hotspotSecondarySsid ?: ""
        hotspotSecondaryIp = t.hotspotSecondaryIp ?: ""
        hotspotSecondaryPoolStart = t.hotspotSecondaryPoolStart ?: ""
        hotspotSecondaryPoolEnd = t.hotspotSecondaryPoolEnd ?: ""
        hotspotSecondaryPolicy = t.hotspotSecondaryPolicy
        hotspotTrialEnabled = t.hotspotTrialEnabled
        hotspotTrialDuration = t.hotspotTrialDuration
        hotspotTrialUptimeLimit = t.hotspotTrialUptimeLimit
        radiusServer = t.radiusServer
        radiusServerBackup = t.radiusServerBackup ?: ""
        radiusSecret = t.radiusSecret ?: ""
        radiusAuthPort = t.radiusAuthPort
        radiusAcctPort = t.radiusAcctPort
        radiusNasIp = t.radiusNasIp
        radiusNasId = t.radiusNasId
        radiusInterimUpdate = t.radiusInterimUpdate
        radiusCoaEnabled = t.radiusCoaEnabled
        radiusCoaPort = t.radiusCoaPort
        restApiEnabled = t.restApiEnabled
        restApiProto = t.restApiProto
        restApiUsername = t.restApiUsername
        restApiPassword = t.restApiPassword ?: ""
        portalSupportPhone = t.portalSupportPhone ?: ""
        portalNotification = t.portalNotification
        portalLiveEnabled = t.portalLiveEnabled
        portalLiveUrl = t.portalLiveUrl ?: ""
        portalBreakEnabled = t.portalBreakEnabled
        portalBreakUrl = t.portalBreakUrl ?: ""
        portalSpeedtestEnabled = t.portalSpeedtestEnabled
        maintenanceEnabled = t.maintenanceEnabled
        maintenancePolicy = t.maintenancePolicy
        maintenanceStartTime = t.maintenanceStartTime
        maintenanceEndTime = t.maintenanceEndTime
        autoupdateStartTime = t.autoupdateStartTime
        autoupdateEndTime = t.autoupdateEndTime
        uplinkBand = t.uplinkBand
        uplinkSsid = t.uplinkSsid ?: ""
        uplinkKey = t.uplinkKey ?: ""
        meshBand = t.meshBand
        meshId = t.meshId ?: ""
        meshKey = t.meshKey ?: ""
        hotspotSecondaryPoolStart = t.hotspotSecondaryPoolStart ?: ""
        hotspotSecondaryPoolEnd = t.hotspotSecondaryPoolEnd ?: ""
        hotspotSecondaryPolicy = t.hotspotSecondaryPolicy
        hotspotMacAuthEnabled = t.hotspotMacAuthEnabled
        hotspotMacAuthSuffix = t.hotspotMacAuthSuffix ?: ""
        hotspotMacAuthPassword = t.hotspotMacAuthPassword ?: ""
        hotspotWalledGarden = t.hotspotWalledGarden ?: ""
        hotspotBrowserCookieEnabled = t.hotspotBrowserCookieEnabled
        hotspotBrowserCookieDays = t.hotspotBrowserCookieDays
        rebootHours = t.rebootHours
    }

    // Auto-update scanned MAC from camera
    LaunchedEffect(scannedMac) {
        if (scannedMac.isNotEmpty()) {
            macAddress = scannedMac
        }
    }

    // Lookup device by MAC when it changes — load exact config if found
    LaunchedEffect(macAddress) {
        if (macAddress.isBlank()) return@LaunchedEffect
        val existing = lookupDeviceByMac(macAddress)
        if (existing != null) {
            selectedMode = existing.deviceType
            loadDeviceFields(existing)
            return@LaunchedEffect
        }
    }

    // Derive template from last device of same type (for new MACs)
    LaunchedEffect(selectedMode) {
        val derived = deriveTemplateForType(selectedMode) ?: return@LaunchedEffect
        loadDeviceFields(derived)
    }

    // Auto-suggest next LAN IP on load
    LaunchedEffect(Unit) {
        lanIp = validationEngine.suggestNextLanIp()
    }

    // Suggest hotspot IPs from LAN IP only when the user has not entered a
    // custom range. The user may choose ANY private subnet (10/8, 172.16/12,
    // 192.168/16); we must never overwrite their input with a hardcoded range.
    // Fix: the secondary range used to be wrongly derived as 192.167.x.x
    // (a public range) instead of 192.168.x.x.
    LaunchedEffect(lanIp) {
        val parts = lanIp.split(".")
        if (parts.size == 4 && lanIp.isNotBlank()) {
            val last = parts[3]
            if (hotspotPrimaryIp.isBlank()) hotspotPrimaryIp = "192.168.$last.1"
            if (hotspotSecondaryIp.isBlank()) hotspotSecondaryIp = "192.168.$last.1"
            if (hotspotPrimaryPoolStart.isBlank()) hotspotPrimaryPoolStart = "192.168.${last}.10"
            if (hotspotPrimaryPoolEnd.isBlank()) hotspotPrimaryPoolEnd = "192.168.${last}.199"
            if (hotspotSecondaryPoolStart.isBlank()) hotspotSecondaryPoolStart = "192.168.${last}.10"
            if (hotspotSecondaryPoolEnd.isBlank()) hotspotSecondaryPoolEnd = "192.168.${last}.199"
        }
    }

    // Derive hotspot secondary SSID from 5GHz naming method in hotspot mode
    LaunchedEffect(selectedMode, wifi5gNameType, wifiSsid, appendIpToSsid, lanIp, wifi5gCustomSsid) {
        if (selectedMode == "hotspot" && wifiSsid.isNotBlank()) {
            val derived5g = if (wifi5gNameType == "derived") {
                buildString {
                    append(wifiSsid.trim())
                    if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.'))
                    append("_5G")
                }
            } else {
                wifi5gCustomSsid.trim().ifEmpty { "${wifiSsid.trim()}_5G" }
            }
            if (derived5g.isNotBlank() && hotspotSecondarySsid != derived5g) {
                hotspotSecondarySsid = derived5g
            }
        }
    }

    // Real-time conflict checker
    LaunchedEffect(lanIp, macAddress) {
        if (lanIp.isNotEmpty() && macAddress.isNotEmpty()) {
            scope.launch {
                val conflict = validationEngine.checkLanIpConflict(lanIp, macAddress)
                if (conflict != null) {
                    ipConflictMessage = "⚠️ آي بي محجوز لـ ${conflict.deviceName} (${conflict.macAddress})"
                    isIpValid = false
                } else {
                    ipConflictMessage = null
                    isIpValid = true
                }
            }
        }
    }

    // Validate hotspot range structure + warn on non-private (public) ranges.
    // The router accepts any subnet, but a public range (e.g. 192.167.x.x)
    // cannot be NATed to the internet, so we warn rather than block.
    LaunchedEffect(
        hotspotPrimaryIp, hotspotSecondaryIp,
        hotspotPrimaryPoolStart, hotspotPrimaryPoolEnd,
        hotspotSecondaryPoolStart, hotspotSecondaryPoolEnd
    ) {
        val fields = listOf(
            hotspotPrimaryIp, hotspotSecondaryIp,
            hotspotPrimaryPoolStart, hotspotPrimaryPoolEnd,
            hotspotSecondaryPoolStart, hotspotSecondaryPoolEnd
        ).filter { it.isNotBlank() }
        val malformed = fields.firstOrNull { !validationEngine.isValidIp(it) }
        if (malformed != null) {
            hotspotIpError = "⚠️ عنوان IP غير صالح: $malformed"
            return@LaunchedEffect
        }
        val public = fields.firstOrNull { !validationEngine.isPrivateIp(it) }
        hotspotIpError = if (public != null) {
            "⚠️ النطاق $public ليس خاصاً (RFC1918) — سيعمل محلياً لكن لا إنترنت عبر WAN"
        } else {
            null
        }
    }


    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBg)
            .padding(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            val wifiPasswordMismatch = false
            val rootPasswordMismatch = rootPassword.isNotEmpty() && confirmRootPassword.isNotEmpty() && rootPassword != confirmRootPassword
            val passwordConfirmationMissing = (rootPassword.isNotEmpty() && confirmRootPassword.isEmpty())
            val meshChannelInvalid = selectedMode == "mesh" && ((meshBand == "2.4GHz" && wifi2gChannel == "auto") || (meshBand == "5GHz" && wifi5gChannel == "auto"))
            val canSave = isIpValid && deviceName.isNotEmpty() && macAddress.isNotEmpty() && !wifiPasswordMismatch && !rootPasswordMismatch && !passwordConfirmationMissing && !meshChannelInvalid

            // Title
            Text(
                text = "إعداد جهاز الإمبراطور",
                color = GoldPrimary,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(vertical = 24.dp)
            )

            // Form Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = CardBg),
                shape = RoundedCornerShape(20.dp),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Device Name Input
                    OutlinedTextField(
                        value = deviceName,
                        onValueChange = { deviceName = it },
                        label = { Text("اسم الجهاز وموقعه", color = Color.Gray) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = GoldPrimary,
                            unfocusedBorderColor = Color.DarkGray,
                            focusedLabelColor = GoldPrimary,
                            unfocusedLabelColor = Color.Gray
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    // MAC Address Input with Camera Scan Button
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        OutlinedTextField(
                            value = macAddress,
                            onValueChange = { macAddress = it },
                            label = { Text("الماك أدرس (MAC Address)", color = Color.Gray) },
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedBorderColor = GoldPrimary,
                                unfocusedBorderColor = Color.DarkGray,
                                focusedLabelColor = GoldPrimary,
                                unfocusedLabelColor = Color.Gray
                            ),
                            modifier = Modifier.weight(1f)
                        )
                        Button(
                            onClick = onScanMacClick,
                            colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)
                        ) {
                            Text("📱 مسح الكاميرا", color = Color.Black, fontWeight = FontWeight.Bold)
                        }
                    }

                    // Mode Selection Dropdown (AP, Hotspot, etc)
                    Text("وضع التشغيل المقترح", color = GoldPrimary, fontWeight = FontWeight.Bold)
                    val modes = listOf(
                        "ap" to "نقطة وصول AP",
                        "hotspot" to "الإمبراطور (Hotspot)",
                        "ap_wds" to "نقطة وصول + WDS",
                        "sta_wds" to "استقبال لاسلكي",
                        "mesh" to "ميش ذكي"
                    )

                    modes.forEach { (modeVal, modeLabel) ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = (selectedMode == modeVal),
                                onClick = { selectedMode = modeVal },
                                colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary)
                            )
                            Text(modeLabel, color = Color.White, modifier = Modifier.padding(start = 8.dp))
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // القنوات وإعدادات الراديو
                    if (selectedMode == "ap" || selectedMode == "ap_wds" || selectedMode == "sta_wds" || selectedMode == "mesh") {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("📶 القنوات وإعدادات الراديو", color = GoldPrimary, fontWeight = FontWeight.Bold)
                        Text("إعدادات راديو 2.4GHz", color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        PremiumDropdownField(
                            label = "قناة 2G",
                            selectedValue = wifi2gChannel,
                            options = listOf("auto", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"),
                            onValueChange = { wifi2gChannel = it }
                        )
                        PremiumDropdownField(
                            label = "النمط 2G",
                            selectedValue = wifi2gMode,
                            options = listOf("ax", "n", "g"),
                            onValueChange = { wifi2gMode = it }
                        )
                        PremiumDropdownField(
                            label = "عرض القناة 2G",
                            selectedValue = wifi2gWidth,
                            options = listOf("20", "40"),
                            onValueChange = { wifi2gWidth = it }
                        )

                        Divider(color = Color.DarkGray, thickness = 1.dp)

                        Text("إعدادات راديو 5GHz", color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        PremiumDropdownField(
                            label = "قناة 5G",
                            selectedValue = wifi5gChannel,
                            options = listOf("auto", "36", "40", "44", "48", "52", "56", "60", "64", "100", "104", "108", "112", "116", "120", "124", "128", "132", "136", "140", "144", "149", "153", "157", "161", "165"),
                            onValueChange = { wifi5gChannel = it }
                        )
                        PremiumDropdownField(
                            label = "النمط 5G",
                            selectedValue = wifi5gMode,
                            options = listOf("ax", "ac", "a"),
                            onValueChange = { wifi5gMode = it }
                        )
                        PremiumDropdownField(
                            label = "عرض القناة 5G",
                            selectedValue = wifi5gWidth,
                            options = listOf("20", "40", "80", "160"),
                            onValueChange = { wifi5gWidth = it }
                        )
                    }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Dynamic Wi-Fi Fields Based on Selected Mode
                    when (selectedMode) {
                        "ap" -> {
                            if (!vlanEnabled) {
                                OutlinedTextField(
                                    value = wifiSsid,
                                    onValueChange = { wifiSsid = it },
                                    label = { Text("اسم شبكة الواي فاي (SSID)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(
                                        focusedTextColor = Color.White,
                                        unfocusedTextColor = Color.White,
                                        focusedBorderColor = GoldPrimary,
                                        unfocusedBorderColor = Color.DarkGray,
                                        focusedLabelColor = GoldPrimary,
                                        unfocusedLabelColor = Color.Gray
                                    ),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                        "hotspot" -> {
                            OutlinedTextField(
                                value = wifiSsid,
                                onValueChange = { wifiSsid = it },
                                label = { Text("اسم شبكة الهوتسبوت", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedTextColor = Color.White,
                                    unfocusedTextColor = Color.White,
                                    focusedBorderColor = GoldPrimary,
                                    unfocusedBorderColor = Color.DarkGray,
                                    focusedLabelColor = GoldPrimary,
                                    unfocusedLabelColor = Color.Gray
                                ),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                        "ap_wds" -> {
                            if (!vlanEnabled) {
                                val preview5gName = if (wifi5gNameType == "derived") {
                                    buildString {
                                        append(wifiSsid.trim())
                                        if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.'))
                                        append("_5G")
                                    }
                                } else {
                                    wifi5gCustomSsid.trim().ifEmpty { buildString { append(wifiSsid.trim()); if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.')); append("_5G") } }
                                }

                                Text("إعدادات شبكة البث المحلية (Local AP)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                                OutlinedTextField(
                                    value = wifiSsid,
                                    onValueChange = { wifiSsid = it },
                                    label = { Text("اسم SSID للبث المحلي (راديو 2.4GHz)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )

                                Text("طريقة تعيين اسم شبكة 5GHz", color = Color.Gray, fontSize = 14.sp)
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    RadioButton(selected = (wifi5gNameType == "derived"), onClick = { wifi5gNameType = "derived" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                    Text("تلقائي + _5G", color = Color.White, modifier = Modifier.padding(start = 4.dp))
                                    Spacer(modifier = Modifier.width(16.dp))
                                    RadioButton(selected = (wifi5gNameType == "custom"), onClick = { wifi5gNameType = "custom" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                    Text("اسم مخصص", color = Color.White, modifier = Modifier.padding(start = 4.dp))
                                }

                                if (wifi5gNameType == "custom") {
                                    OutlinedTextField(
                                        value = wifi5gCustomSsid,
                                        onValueChange = { wifi5gCustomSsid = it },
                                        label = { Text("الاسم المخصص لشبكة 5GHz", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Text("الاسم النهائي لشبكة 5GHz: $preview5gName", color = Color.LightGray, fontSize = 13.sp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("إضافة IP إلى نهاية اسم الشبكة الأساسية", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = appendIpToSsid, onCheckedChange = { appendIpToSsid = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                OutlinedTextField(
                                    value = wifiKey,
                                    onValueChange = { wifiKey = it },
                                    label = { Text("كلمة مرور الواي فاي", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                        "sta_wds" -> {
                            val localRadioLabel = if (uplinkBand == "5GHz") "2.4GHz" else "5GHz"

                            Text("إعدادات الربط الصاعد (Uplink Client)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                RadioButton(selected = (uplinkBand == "2.4GHz"), onClick = { uplinkBand = "2.4GHz" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("2.4GHz", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                Spacer(modifier = Modifier.width(16.dp))
                                RadioButton(selected = (uplinkBand == "5GHz"), onClick = { uplinkBand = "5GHz" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("5GHz", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                            }
                            OutlinedTextField(
                                value = uplinkSsid,
                                onValueChange = { uplinkSsid = it },
                                label = { Text("اسم شبكة الربط الصاعد (Uplink SSID)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                            OutlinedTextField(
                                value = uplinkKey,
                                onValueChange = { uplinkKey = it },
                                label = { Text("كلمة مرور الربط الصاعد", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Divider(color = Color.DarkGray, thickness = 1.dp)

                            val preview5gName = if (wifi5gNameType == "derived") {
                                buildString {
                                    append(wifiSsid.trim())
                                    if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.'))
                                    append("_5G")
                                }
                            } else {
                                wifi5gCustomSsid.trim().ifEmpty { buildString { append(wifiSsid.trim()); if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.')); append("_5G") } }
                            }

                            Text("إعدادات شبكة البث المحلية (Local AP)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                            OutlinedTextField(
                                value = wifiSsid,
                                onValueChange = { wifiSsid = it },
                                label = { Text("اسم SSID للبث المحلي (راديو $localRadioLabel)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Text("طريقة تعيين اسم شبكة 5GHz", color = Color.Gray, fontSize = 14.sp)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                RadioButton(selected = (wifi5gNameType == "derived"), onClick = { wifi5gNameType = "derived" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("تلقائي + _5G", color = Color.White, modifier = Modifier.padding(start = 4.dp))
                                Spacer(modifier = Modifier.width(16.dp))
                                RadioButton(selected = (wifi5gNameType == "custom"), onClick = { wifi5gNameType = "custom" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("اسم مخصص", color = Color.White, modifier = Modifier.padding(start = 4.dp))
                            }

                            if (wifi5gNameType == "custom") {
                                OutlinedTextField(
                                    value = wifi5gCustomSsid,
                                    onValueChange = { wifi5gCustomSsid = it },
                                    label = { Text("الاسم المخصص لشبكة 5GHz", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            Text("الاسم النهائي لشبكة 5GHz: $preview5gName", color = Color.LightGray, fontSize = 13.sp)

                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("إضافة IP إلى نهاية اسم الشبكة الأساسية", color = Color.LightGray, fontSize = 15.sp)
                                Checkbox(checked = appendIpToSsid, onCheckedChange = { appendIpToSsid = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                            }

                            OutlinedTextField(
                                value = wifiKey,
                                onValueChange = { wifiKey = it },
                                label = { Text("كلمة مرور الواي فاي", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                        "mesh" -> {
                            Text("إعدادات ترابط الميش (Mesh)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                RadioButton(selected = (meshBand == "2.4GHz"), onClick = { meshBand = "2.4GHz" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("2.4GHz", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                Spacer(modifier = Modifier.width(16.dp))
                                RadioButton(selected = (meshBand == "5GHz"), onClick = { meshBand = "5GHz" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("5GHz", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                            }
                            OutlinedTextField(
                                value = meshId,
                                onValueChange = { meshId = it },
                                label = { Text("معرف الميش (Mesh ID)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                            OutlinedTextField(
                                value = meshKey,
                                onValueChange = { meshKey = it },
                                label = { Text("كلمة مرور الميش (Mesh Key)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                            if (meshChannelInvalid) {
                                Text("يجب تحديد قناة ثابتة (غير auto) للراديو ${if (meshBand == "5GHz") "5GHz" else "2.4GHz"} في وضع الميش", color = Color.Red, fontSize = 12.sp)
                            }

                            Divider(color = Color.DarkGray, thickness = 1.dp)

                            Text("إعدادات شبكة البث المحلية (Local AP)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                            OutlinedTextField(
                                value = wifiSsid,
                                onValueChange = { wifiSsid = it },
                                label = { Text("اسم الشبكة المحلية (SSID)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }

                    // Wi-Fi Advanced Names & Security
                    // For ap_wds/sta_wds, these fields are shown in the main view above
                        if (selectedMode != "ap_wds" && selectedMode != "sta_wds") {
                            Text("طريقة تعيين اسم شبكة 5GHz", color = Color.Gray, fontSize = 14.sp)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                RadioButton(selected = (wifi5gNameType == "derived"), onClick = { wifi5gNameType = "derived" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("تلقائي من الاسم الأساسي + _5G", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                Spacer(modifier = Modifier.width(16.dp))
                                RadioButton(selected = (wifi5gNameType == "custom"), onClick = { wifi5gNameType = "custom" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                Text("اسم مخصص", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                            }

                            if (wifi5gNameType == "derived") {
                                val preview5gName = buildString {
                                    append(wifiSsid.trim())
                                    if (appendIpToSsid && lanIp.isNotBlank()) append("_").append(lanIp.substringAfterLast('.'))
                                    append("_5G")
                                }
                                Text("اسم شبكة 5GHz النهائي: $preview5gName", color = Color.LightGray, fontSize = 13.sp)
                            }

                            if (wifi5gNameType == "custom") {
                                OutlinedTextField(
                                    value = wifi5gCustomSsid,
                                    onValueChange = { wifi5gCustomSsid = it },
                                    label = { Text("الاسم المخصص لشبكة 5GHz", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("إضافة IP إلى نهاية اسم الشبكة", color = Color.LightGray, fontSize = 15.sp)
                                Checkbox(checked = appendIpToSsid, onCheckedChange = { appendIpToSsid = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                            }

                            OutlinedTextField(
                                value = wifiKey,
                                onValueChange = { wifiKey = it },
                                label = { Text("كلمة مرور الواي فاي", color = Color.Gray) },
                                isError = wifiPasswordMismatch,
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )

                        }

                        // Section 3: VLAN Settings (not applicable for hotspot mode)
                        if (selectedMode != "hotspot") {
                            CollapsibleSection(
                                title = "🌐 إعداد شبكة VLAN الثانوية",
                                isExpanded = isVlanExpanded,
                                onToggle = { isVlanExpanded = !isVlanExpanded }
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                        Text("تفعيل شبكة VLAN", color = Color.LightGray, fontSize = 15.sp)
                                        Checkbox(checked = vlanEnabled, onCheckedChange = { vlanEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                    }

                                    if (vlanEnabled) {
                                        OutlinedTextField(
                                            value = vlanId,
                                            onValueChange = { vlanId = it },
                                            label = { Text("VLAN ID", color = Color.Gray) },
                                            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                        OutlinedTextField(
                                            value = vlanSsid2g,
                                            onValueChange = { vlanSsid2g = it },
                                            label = { Text("اسم شبكة VLAN 2.4GHz (أو فارغ للتوليد التلقائي)", color = Color.Gray) },
                                            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                        OutlinedTextField(
                                            value = vlanSsid5g,
                                            onValueChange = { vlanSsid5g = it },
                                            label = { Text("اسم شبكة VLAN 5GHz (أو فارغ للتوليد التلقائي)", color = Color.Gray) },
                                            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                            Text("إضافة IP إلى أسماء واي فاي VLAN", color = Color.LightGray, fontSize = 15.sp)
                                            Checkbox(checked = vlanSsidIpSuffix, onCheckedChange = { vlanSsidIpSuffix = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                        }
                                    }
                                }
                            }
                        }

                    // Collapsible Advanced Sections for Hotspot Mode
                    if (selectedMode == "hotspot") {
                        // Section 1: Hotspot Networks
                        CollapsibleSection(
                            title = "📶 إعدادات شبكة الهوتسبوت",
                            isExpanded = isHotspotNetExpanded,
                            onToggle = { isHotspotNetExpanded = !isHotspotNetExpanded }
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = hotspotWanInterface,
                                        onValueChange = { hotspotWanInterface = it },
                                        label = { Text("واجهة الإنترنت", color = Color.Gray) },
                                        placeholder = { Text("wan (منفذ الإنترنت)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                    OutlinedTextField(
                                        value = hotspotSubscriberInterface,
                                        onValueChange = { hotspotSubscriberInterface = it },
                                        label = { Text("واجهة المشتركين", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                }
                                OutlinedTextField(
                                    value = hotspotDnsName,
                                    onValueChange = { hotspotDnsName = it },
                                    label = { Text("اسم الـ DNS الداخلي (DNS Name)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = hotspotPrimaryIp,
                                    onValueChange = {
                                        hotspotPrimaryIp = it
                                        val octets = it.split(".")
                                        if (octets.size == 4) {
                                            hotspotPrimaryPoolStart = "${octets[0]}.${octets[1]}.${octets[2]}.10"
                                            hotspotPrimaryPoolEnd = "${octets[0]}.${octets[1]}.${octets[2]}.199"
                                        }
                                    },
                                    label = { Text("IP الشبكة الأولى", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                PremiumDropdownField(
                                    label = "طريقة تسجيل الدخول (Login Mode)",
                                    selectedValue = hotspotCardPage,
                                    options = listOf("both", "username"),
                                    optionLabels = mapOf(
                                        "both" to "اسم مستخدم وكلمة مرور",
                                        "username" to "رقم كرت فقط"
                                    ),
                                    onValueChange = { hotspotCardPage = it }
                                )
                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = hotspotDns1,
                                        onValueChange = { hotspotDns1 = it },
                                        label = { Text("DNS Server 1", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                    OutlinedTextField(
                                        value = hotspotDns2,
                                        onValueChange = { hotspotDns2 = it },
                                        label = { Text("DNS Server 2", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                }
                                OutlinedTextField(
                                    value = hotspotBridgeAgeingTime,
                                    onValueChange = { hotspotBridgeAgeingTime = it },
                                    label = { Text("Bridge ageing time", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = hotspotRateLimit,
                                    onValueChange = { hotspotRateLimit = it },
                                    label = { Text("سرعة الميكروتك (Rate Limit)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("دعم MAC Cookie", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotMacCookie, onCheckedChange = { hotspotMacCookie = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                Divider(color = GoldPrimary.copy(alpha = 0.5f), thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل جدولة الصيانة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = maintenanceEnabled, onCheckedChange = { maintenanceEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                if (maintenanceEnabled) {
                                    PremiumDropdownField(
                                        label = "سلوك الصيانة",
                                        selectedValue = maintenancePolicy,
                                        options = listOf("free", "block"),
                                        onValueChange = { maintenancePolicy = it }
                                    )
                                    OutlinedTextField(
                                        value = maintenanceStartTime,
                                        onValueChange = { maintenanceStartTime = it },
                                        label = { Text("وقت بدء الصيانة (HH:MM)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = maintenanceEndTime,
                                        onValueChange = { maintenanceEndTime = it },
                                        label = { Text("وقت انتهاء الصيانة (HH:MM)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Divider(color = GoldPrimary.copy(alpha = 0.5f), thickness = 1.dp)

                                OutlinedTextField(
                                    value = portalSupportPhone,
                                    onValueChange = { portalSupportPhone = it },
                                    label = { Text("رقم الدعم الفني", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = portalNotification,
                                    onValueChange = { portalNotification = it },
                                    label = { Text("تنبيه للمشتركين", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("إظهار بث مباشر", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = portalLiveEnabled, onCheckedChange = { portalLiveEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                OutlinedTextField(
                                    value = portalLiveUrl,
                                    onValueChange = { portalLiveUrl = it },
                                    label = { Text("رابط البث المباشر", color = Color.Gray) },
                                    enabled = portalLiveEnabled,
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("إظهار الاستراحة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = portalBreakEnabled, onCheckedChange = { portalBreakEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                OutlinedTextField(
                                    value = portalBreakUrl,
                                    onValueChange = { portalBreakUrl = it },
                                    label = { Text("رابط الاستراحة", color = Color.Gray) },
                                    enabled = portalBreakEnabled,
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل فحص السرعة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = portalSpeedtestEnabled, onCheckedChange = { portalSpeedtestEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                PremiumDropdownField(
                                    label = "Policy/Profile للشبكة الأولى",
                                    selectedValue = hotspotPrimaryPolicy,
                                    options = listOf("standard", "premium", "guest", "staff", "trial"),
                                    optionLabels = hotspotPolicyLabels(),
                                    onValueChange = { hotspotPrimaryPolicy = it }
                                )

                                OutlinedTextField(
                                    value = hotspotAvailableSpeeds,
                                    onValueChange = { hotspotAvailableSpeeds = it },
                                    label = { Text("قائمة السرعات المتاحة", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth(),
                                    minLines = 2
                                )

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل كوكيز المتصفح (Browser Cookie)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotBrowserCookieEnabled, onCheckedChange = { hotspotBrowserCookieEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (hotspotBrowserCookieEnabled) {
                                    OutlinedTextField(
                                        value = hotspotBrowserCookieDays,
                                        onValueChange = { hotspotBrowserCookieDays = it },
                                        label = { Text("صلاحية الكوكيز بالأيام (e.g. 7)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل تسجيل الدخول بالماك (MAC Auth)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotMacAuthEnabled, onCheckedChange = { hotspotMacAuthEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (hotspotMacAuthEnabled) {
                                    OutlinedTextField(
                                        value = hotspotMacAuthSuffix,
                                        onValueChange = { hotspotMacAuthSuffix = it },
                                        label = { Text("لاحقة تسجيل الماك (e.g. @mac)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotMacAuthPassword,
                                        onValueChange = { hotspotMacAuthPassword = it },
                                        label = { Text("كلمة مرور الماك (e.g. mac)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                OutlinedTextField(
                                    value = hotspotWalledGarden,
                                    onValueChange = { hotspotWalledGarden = it },
                                    label = { Text("المواقع المستثناة (Walled Garden - مسافة بينها)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل شبكة ثانوية (Secondary Network)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotSecondaryEnabled, onCheckedChange = { enabled ->
                                        hotspotSecondaryEnabled = enabled
                                        if (enabled && hotspotSecondarySsid.isBlank()) {
                                            hotspotSecondarySsid = wifiSsid.takeIf { it.isNotBlank() }?.plus("_5G") ?: "Hotspot-2_5G"
                                        }
                                    }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (hotspotSecondaryEnabled) {
                                    val defaultSecSsid = if (wifiSsid.isNotBlank()) "${wifiSsid}_5G" else "Hotspot-2_5G"
                                    OutlinedTextField(
                                        value = hotspotSecondarySsid,
                                        onValueChange = { hotspotSecondarySsid = it },
                                        label = { Text("اسم الشبكة الثانية SSID", color = Color.Gray) },
                                        placeholder = { Text(defaultSecSsid, color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotSecondaryIp,
                                        onValueChange = { hotspotSecondaryIp = it },
                                        label = { Text("IP الشبكة الثانية (e.g. 192.168.20.1)", color = Color.Gray) },
                                        isError = hotspotIpError != null,
                                        supportingText = hotspotIpError?.let { { Text(it, color = Color.Red) } },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray, errorBorderColor = Color.Red, errorLabelColor = Color.Red),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotSecondaryPoolStart,
                                        onValueChange = { hotspotSecondaryPoolStart = it },
                                        label = { Text("بداية توزيع الآي بي (e.g. 192.168.20.10)", color = Color.Gray) },
                                        isError = hotspotIpError != null,
                                        supportingText = hotspotIpError?.let { { Text(it, color = Color.Red) } },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray, errorBorderColor = Color.Red, errorLabelColor = Color.Red),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotSecondaryPoolEnd,
                                        onValueChange = { hotspotSecondaryPoolEnd = it },
                                        label = { Text("نهاية توزيع الآي بي (e.g. 192.168.20.199)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    PremiumDropdownField(
                                        label = "سياسة الشبكة الثانية (Policy)",
                                        selectedValue = hotspotSecondaryPolicy,
                                        options = listOf("standard", "premium", "guest", "staff", "trial"),
                                        optionLabels = hotspotPolicyLabels(),
                                        onValueChange = { hotspotSecondaryPolicy = it }
                                    )
                                }

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل الخدمة المجانية (Trial Users)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotTrialEnabled, onCheckedChange = { hotspotTrialEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                OutlinedTextField(
                                    value = hotspotTrialDuration,
                                    onValueChange = { hotspotTrialDuration = it.filter { char -> char.isDigit() } },
                                    label = { Text("Trial Duration / مدة الخدمة بالدقائق", color = Color.Gray) },
                                    enabled = hotspotTrialEnabled,
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = hotspotTrialUptimeLimit,
                                    onValueChange = { hotspotTrialUptimeLimit = it.filter { char -> char.isDigit() } },
                                    label = { Text("Trial Uptime Limit / حد الاستخدام اليومي بالدقائق", color = Color.Gray) },
                                    enabled = hotspotTrialEnabled,
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }

                        // Section 2: RADIUS & REST API
                        CollapsibleSection(
                            title = "🔑 صلاحيات الدخول ومصادقة ميكروتك",
                            isExpanded = isHotspotAuthExpanded,
                            onToggle = { isHotspotAuthExpanded = !isHotspotAuthExpanded }
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = radiusServer,
                                    onValueChange = { radiusServer = it },
                                    label = { Text("خادم RADIUS الأساسي", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = radiusServerBackup,
                                    onValueChange = { radiusServerBackup = it },
                                    label = { Text("خادم RADIUS الاحتياطي (اختياري)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = radiusSecret,
                                    onValueChange = { radiusSecret = it },
                                    label = { Text("كلمة سر RADIUS (Secret)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = radiusAuthPort,
                                        onValueChange = { radiusAuthPort = it },
                                        label = { Text("منفذ المصادقة", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                    OutlinedTextField(
                                        value = radiusAcctPort,
                                        onValueChange = { radiusAcctPort = it },
                                        label = { Text("منفذ المحاسبة", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.weight(1f)
                                    )
                                }
                                OutlinedTextField(
                                    value = radiusNasIp,
                                    onValueChange = { radiusNasIp = it },
                                    label = { Text("NAS IP Address", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = radiusNasId,
                                    onValueChange = { radiusNasId = it },
                                    label = { Text("NAS ID", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = radiusInterimUpdate,
                                    onValueChange = { radiusInterimUpdate = it },
                                    label = { Text("Interim Update (sec)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل COA", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = radiusCoaEnabled, onCheckedChange = { radiusCoaEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                if (radiusCoaEnabled) {
                                    OutlinedTextField(
                                        value = radiusCoaPort,
                                        onValueChange = { radiusCoaPort = it },
                                        label = { Text("منفذ COA (Default 3799)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل REST API (MikroTik)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = restApiEnabled, onCheckedChange = { restApiEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (restApiEnabled) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        RadioButton(selected = (restApiProto == "http"), onClick = { restApiProto = "http" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                        Text("HTTP", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                        Spacer(modifier = Modifier.width(16.dp))
                                        RadioButton(selected = (restApiProto == "https"), onClick = { restApiProto = "https" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                        Text("HTTPS", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                    }
                                    OutlinedTextField(
                                        value = restApiUsername,
                                        onValueChange = { restApiUsername = it },
                                        label = { Text("REST اسم مستخدم", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = restApiPassword,
                                        onValueChange = { restApiPassword = it },
                                        label = { Text("REST كلمة مرور", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                            }
                        }

                    }



                    // Section 5: Hardware buttons & maintenance (Common, Always Visible)
                    CollapsibleSection(
                        title = "🛡️ الأزرار الفيزيائية، التشغيل وكلمة السر",
                        isExpanded = isMaintenanceExpanded,
                        onToggle = { isMaintenanceExpanded = !isMaintenanceExpanded }
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("تعطيل زر إعادة الضبط (Reset)", color = Color.LightGray, fontSize = 15.sp)
                                Checkbox(checked = disableResetButton, onCheckedChange = { disableResetButton = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                            }

                            if (disableResetButton) {
                                OutlinedTextField(
                                    value = resetPressDuration,
                                    onValueChange = { resetPressDuration = it },
                                    label = { Text("مدة الضغط (e.g. 5, 10)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("تعطيل زر الـ WPS", color = Color.LightGray, fontSize = 15.sp)
                                Checkbox(checked = disableWpsButton, onCheckedChange = { disableWpsButton = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                            }

                            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("تفعيل إعادة التشغيل التلقائية", color = Color.LightGray, fontSize = 15.sp)
                                Checkbox(checked = autoRebootEnabled, onCheckedChange = { autoRebootEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                            }

                            if (autoRebootEnabled) {
                                Spacer(modifier = Modifier.height(8.dp))
                                OutlinedTextField(
                                    value = rebootHours,
                                    onValueChange = { rebootHours = it.filter { char -> char.isDigit() } },
                                    label = { Text("إعادة التشغيل كل كم ساعة", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            OutlinedTextField(
                                value = rootPassword,
                                onValueChange = { rootPassword = it },
                                label = { Text("كلمة مرور الجهاز الجديدة (Root Password)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )

                            if (rootPassword.isNotEmpty()) {
                                Spacer(modifier = Modifier.height(8.dp))
                                OutlinedTextField(
                                    value = confirmRootPassword,
                                    onValueChange = { confirmRootPassword = it },
                                    label = { Text("إعادة كتابة كلمة المرور لتأكيدها (Confirm Password)", color = Color.Gray) },
                                    isError = rootPasswordMismatch,
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                if (rootPasswordMismatch) {
                                    Text(
                                        text = "كلمتا المرور غير متطابقتين",
                                        color = Color.Red,
                                        fontSize = 12.sp,
                                        modifier = Modifier.padding(top = 4.dp)
                                    )
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    // LAN IP Address Input
                    OutlinedTextField(
                        value = lanIp,
                        onValueChange = { lanIp = it },
                        label = { Text("عنوان LAN IP للراوتر", color = Color.Gray) },
                        isError = !isIpValid,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = GoldPrimary,
                            unfocusedBorderColor = Color.DarkGray,
                            focusedLabelColor = GoldPrimary,
                            unfocusedLabelColor = Color.Gray
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    OutlinedTextField(
                        value = lanNetmask,
                        onValueChange = { lanNetmask = it },
                        label = { Text("قناع شبكة LAN", color = Color.Gray) },
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = GoldPrimary,
                            unfocusedBorderColor = Color.DarkGray,
                            focusedLabelColor = GoldPrimary,
                            unfocusedLabelColor = Color.Gray
                        ),
                        modifier = Modifier.fillMaxWidth()
                    )

                    // Conflict Alert
                    ipConflictMessage?.let {
                        Text(
                            text = it,
                            color = Color.Red,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(top = 4.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Device List Button
            OutlinedButton(
                onClick = onShowDeviceList,
                modifier = Modifier.fillMaxWidth().height(50.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = GoldPrimary),
                shape = RoundedCornerShape(15.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, GoldPrimary)
            ) {
                Text("📋 الأجهزة المبرمجة سابقاً", color = GoldPrimary, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Save / Apply Button
            Button(
                onClick = {
                    if (canSave) {
                        onSaveDevice(
                            Device(
                                macAddress = macAddress,
                                deviceName = deviceName,
                                deviceType = selectedMode,
                                lanIp = lanIp,
                                lanNetmask = lanNetmask,
                                wifiSsid = if (wifiSsid.isNotEmpty()) wifiSsid else null,
                                wifiKey = if (wifiKey.isNotEmpty()) wifiKey else null,
                                wifiChannel = if (wifiChannel.isNotEmpty()) wifiChannel else null,
                                otaWindowStart = otaWindowStart,
                                otaWindowEnd = otaWindowEnd,
                                wifi2gChannel = wifi2gChannel,
                                wifi2gMode = wifi2gMode,
                                wifi2gWidth = wifi2gWidth,
                                wifi5gChannel = wifi5gChannel,
                                wifi5gMode = wifi5gMode,
                                wifi5gWidth = wifi5gWidth,
                                wifi5gNameType = wifi5gNameType,
                                wifi5gCustomSsid = if (wifi5gCustomSsid.isNotEmpty()) wifi5gCustomSsid else null,
                                appendIpToSsid = appendIpToSsid,
                                vlanEnabled = vlanEnabled,
                                vlanId = if (vlanId.isNotEmpty()) vlanId else null,
                                appendIpToVlanSsid = vlanSsidIpSuffix,
                                vlanSsid2g = if (vlanSsid2g.isNotEmpty()) vlanSsid2g else null,
                                vlanSsid5g = if (vlanSsid5g.isNotEmpty()) vlanSsid5g else null,
                                vlanSsidIpSuffix = vlanSsidIpSuffix,
                                disableResetButton = disableResetButton,
                                resetPressDuration = resetPressDuration,
                                disableWpsButton = disableWpsButton,
                                autoRebootEnabled = autoRebootEnabled,
                                rebootHours = rebootHours,
                                rootPassword = if (rootPassword.isNotEmpty()) rootPassword else null,
                                hotspotWanInterface = hotspotWanInterface,
                                hotspotSubscriberInterface = hotspotSubscriberInterface,
                                hotspotPrimaryIp = hotspotPrimaryIp,
                                hotspotPrimaryPoolStart = if (hotspotPrimaryPoolStart.isNotEmpty()) hotspotPrimaryPoolStart else null,
                                hotspotPrimaryPoolEnd = if (hotspotPrimaryPoolEnd.isNotEmpty()) hotspotPrimaryPoolEnd else null,
                                hotspotPrimaryPolicy = hotspotPrimaryPolicy,
                                hotspotDnsName = hotspotDnsName,
                                hotspotDns1 = hotspotDns1,
                                hotspotDns2 = hotspotDns2,
                                hotspotBridgeAgeingTime = hotspotBridgeAgeingTime,
                                hotspotCardPage = hotspotCardPage,
                                hotspotRateLimit = hotspotRateLimit,
                                hotspotMacCookie = hotspotMacCookie,
                                hotspotAvailableSpeeds = hotspotAvailableSpeeds,
                                hotspotSecondaryEnabled = hotspotSecondaryEnabled,
                                hotspotSecondarySsid = if (hotspotSecondarySsid.isNotEmpty()) hotspotSecondarySsid else "${wifiSsid}_5G",
                                hotspotSecondaryIp = if (hotspotSecondaryIp.isNotEmpty()) hotspotSecondaryIp else null,
                                hotspotSecondaryPoolStart = if (hotspotSecondaryPoolStart.isNotEmpty()) hotspotSecondaryPoolStart else null,
                                hotspotSecondaryPoolEnd = if (hotspotSecondaryPoolEnd.isNotEmpty()) hotspotSecondaryPoolEnd else null,
                                hotspotSecondaryPolicy = hotspotSecondaryPolicy,
                                hotspotMacAuthEnabled = hotspotMacAuthEnabled,
                                hotspotMacAuthSuffix = if (hotspotMacAuthSuffix.isNotEmpty()) hotspotMacAuthSuffix else null,
                                hotspotMacAuthPassword = if (hotspotMacAuthPassword.isNotEmpty()) hotspotMacAuthPassword else null,
                                hotspotWalledGarden = if (hotspotWalledGarden.isNotEmpty()) hotspotWalledGarden else null,
                                hotspotBrowserCookieEnabled = hotspotBrowserCookieEnabled,
                                hotspotBrowserCookieDays = hotspotBrowserCookieDays,
                                hotspotTrialEnabled = hotspotTrialEnabled,
                                hotspotTrialDuration = hotspotTrialDuration,
                                hotspotTrialUptimeLimit = hotspotTrialUptimeLimit,
                                radiusServer = radiusServer,
                                radiusServerBackup = if (radiusServerBackup.isNotEmpty()) radiusServerBackup else null,
                                radiusSecret = if (radiusSecret.isNotEmpty()) radiusSecret else null,
                                radiusAuthPort = radiusAuthPort,
                                radiusAcctPort = radiusAcctPort,
                                radiusNasIp = radiusNasIp,
                                radiusNasId = radiusNasId,
                                radiusInterimUpdate = radiusInterimUpdate,
                                radiusCoaEnabled = radiusCoaEnabled,
                                radiusCoaPort = radiusCoaPort,
                                restApiEnabled = restApiEnabled,
                                restApiProto = restApiProto,
                                restApiUsername = restApiUsername,
                                restApiPassword = if (restApiPassword.isNotEmpty()) restApiPassword else null,
                                portalSupportPhone = if (portalSupportPhone.isNotEmpty()) portalSupportPhone else null,
                                portalNotification = portalNotification,
                                portalLiveEnabled = portalLiveEnabled,
                                portalLiveUrl = if (portalLiveUrl.isNotEmpty()) portalLiveUrl else null,
                                portalBreakEnabled = portalBreakEnabled,
                                portalBreakUrl = if (portalBreakUrl.isNotEmpty()) portalBreakUrl else null,
                                portalSpeedtestEnabled = portalSpeedtestEnabled,
                                maintenanceEnabled = maintenanceEnabled,
                                maintenancePolicy = maintenancePolicy,
                                maintenanceStartTime = maintenanceStartTime,
                                maintenanceEndTime = maintenanceEndTime,
                                autoupdateStartTime = autoupdateStartTime,
                                autoupdateEndTime = autoupdateEndTime,
                                uplinkBand = uplinkBand,
                                uplinkSsid = if (uplinkSsid.isNotEmpty()) uplinkSsid else null,
                                uplinkKey = if (uplinkKey.isNotEmpty()) uplinkKey else null,
                                meshBand = meshBand,
                                meshId = if (meshId.isNotEmpty()) meshId else null,
                                meshKey = if (meshKey.isNotEmpty()) meshKey else null
                            )
                        )
                    }
                },
                enabled = canSave,
                colors = ButtonDefaults.buttonColors(
                    containerColor = GoldPrimary,
                    disabledContainerColor = Color.DarkGray
                ),
                shape = RoundedCornerShape(15.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(60.dp)
            ) {
                Text(
                    text = "حفظ ومتابعة الإعداد",
                    color = Color.Black,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }
    }
}

@Composable
fun CollapsibleSection(
    title: String,
    isExpanded: Boolean,
    onToggle: () -> Unit,
    content: @Composable () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E1E1E)),
        shape = RoundedCornerShape(10.dp)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onToggle() },
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(if (isExpanded) "▲" else "▼", color = GoldPrimary, fontSize = 14.sp)
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = title,
                    color = GoldPrimary,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    modifier = Modifier.weight(1f)
                )
            }
            if (isExpanded) {
                Spacer(modifier = Modifier.height(12.dp))
                content()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PremiumDropdownField(
    label: String,
    selectedValue: String,
    options: List<String>,
    optionLabels: Map<String, String> = emptyMap(),
    onValueChange: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            value = optionLabels[selectedValue] ?: selectedValue,
            onValueChange = {},
            readOnly = true,
            label = { Text(label, color = Color.Gray) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                focusedBorderColor = GoldPrimary,
                unfocusedBorderColor = Color.DarkGray
            ),
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor()
        )
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false },
            modifier = Modifier.background(CardBg)
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(optionLabels[option] ?: option, color = Color.White) },
                    onClick = {
                        onValueChange(option)
                        expanded = false
                    }
                )
            }
        }
    }
}

private fun hotspotPolicyLabels(): Map<String, String> = mapOf(
    "standard" to "Standard",
    "premium" to "Premium",
    "guest" to "Guest",
    "staff" to "Staff",
    "trial" to "Trial"
)
