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
    scannedMac: String = ""
) {
    var deviceName by remember { mutableStateOf("") }
    var macAddress by remember { mutableStateOf("") }
    var selectedMode by remember { mutableStateOf("ap") }
    var lanIp by remember { mutableStateOf("") }
    var ipConflictMessage by remember { mutableStateOf<String?>(null) }
    var isIpValid by remember { mutableStateOf(true) }

    // Wi-Fi basic settings state variables
    var wifiSsid by remember { mutableStateOf("ALEMPRATOR_AP") }
    var wifiKey by remember { mutableStateOf("123456789") }
    var wifiChannel by remember { mutableStateOf("36") }

    // Advanced switch options
    var isolateClients by remember { mutableStateOf(true) }
    var hideSsid by remember { mutableStateOf(false) }
    var disableDhcp by remember { mutableStateOf(true) }

    // 1. Radio & Channels (2.4G & 5G)
    var wifi2gChannel by remember { mutableStateOf("auto") }
    var wifi2gMode by remember { mutableStateOf("ax") }
    var wifi2gWidth by remember { mutableStateOf("20") }
    var wifi5gChannel by remember { mutableStateOf("36") }
    var wifi5gMode by remember { mutableStateOf("ax") }
    var wifi5gWidth by remember { mutableStateOf("80") }

    // SSID advanced
    var wifi5gNameType by remember { mutableStateOf("same") } // "same" or "custom"
    var wifi5gCustomSsid by remember { mutableStateOf("") }
    var appendIpToSsid by remember { mutableStateOf(false) }
    var noPassword by remember { mutableStateOf(false) }

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
    var hotspotDnsName by remember { mutableStateOf("hotspot.local") }
    var hotspotCardPage by remember { mutableStateOf("username_password") }
    var hotspotRateLimit by remember { mutableStateOf("2M/5M") }
    var hotspotMacCookie by remember { mutableStateOf(true) }
    var hotspotSecondaryEnabled by remember { mutableStateOf(false) }
    var hotspotSecondarySsid by remember { mutableStateOf("") }
    var hotspotSecondaryIp by remember { mutableStateOf("") }
    var hotspotSecondaryPoolStart by remember { mutableStateOf("") }
    var hotspotSecondaryPoolEnd by remember { mutableStateOf("") }
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
    var maintenancePolicy by remember { mutableStateOf("bypass") }
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
    var isRadioExpanded by remember { mutableStateOf(false) }
    var isWifiExpanded by remember { mutableStateOf(false) }
    var isVlanExpanded by remember { mutableStateOf(false) }
    var isMaintenanceExpanded by remember { mutableStateOf(false) }
    
    // Hotspot accordion states
    var isHotspotNetExpanded by remember { mutableStateOf(false) }
    var isHotspotAuthExpanded by remember { mutableStateOf(false) }
    var isHotspotPortalExpanded by remember { mutableStateOf(false) }
    var isHotspotScheduleExpanded by remember { mutableStateOf(false) }

    // Set defaults when mode changes
    LaunchedEffect(selectedMode) {
        when (selectedMode) {
            "ap" -> {
                wifiSsid = "ALEMPRATOR_AP"
                wifiKey = "123456789"
                wifiChannel = "36"
            }
            "hotspot" -> {
                wifiSsid = "ALEMPRATOR_HOTSPOT"
                wifiKey = ""
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

    // Auto-update scanned MAC from camera
    LaunchedEffect(scannedMac) {
        if (scannedMac.isNotEmpty()) {
            macAddress = scannedMac
        }
    }

    // Auto-suggest next LAN IP on load
    LaunchedEffect(Unit) {
        lanIp = validationEngine.suggestNextLanIp()
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
                        "ap_wds", "sta_wds" -> {
                            if (!vlanEnabled || selectedMode == "sta_wds") {
                                Text("إعدادات شبكة البث المحلية (Local AP)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                                OutlinedTextField(
                                    value = wifiSsid,
                                    onValueChange = { wifiSsid = it },
                                    label = { Text("اسم الشبكة المحلية (SSID)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = wifiKey,
                                    onValueChange = { wifiKey = it },
                                    label = { Text("كلمة مرور الواي فاي المحلية", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            Divider(color = Color.DarkGray, thickness = 1.dp)

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
                        }
                        "mesh" -> {
                            Text("إعدادات شبكة البث المحلية (Local AP)", color = GoldPrimary, fontWeight = FontWeight.Bold)
                            OutlinedTextField(
                                value = wifiSsid,
                                onValueChange = { wifiSsid = it },
                                label = { Text("اسم الشبكة المحلية (SSID)", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )
                            OutlinedTextField(
                                value = wifiKey,
                                onValueChange = { wifiKey = it },
                                label = { Text("كلمة مرور الواي فاي المحلية", color = Color.Gray) },
                                colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                modifier = Modifier.fillMaxWidth()
                            )

                            Divider(color = Color.DarkGray, thickness = 1.dp)

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
                        }
                    }

                    // Collapsible Advanced Sections for AP Mode
                    if (selectedMode == "ap" || selectedMode == "ap_wds" || selectedMode == "sta_wds" || selectedMode == "mesh") {
                        // Section 1: Radio & Channels
                        CollapsibleSection(
                            title = "📶 القنوات وإعدادات الراديو",
                            isExpanded = isRadioExpanded,
                            onToggle = { isRadioExpanded = !isRadioExpanded }
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
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

                        // Section 2: Wi-Fi Advanced Names & Security
                        if (!vlanEnabled) {
                            CollapsibleSection(
                                title = "🔑 الشبكة اللاسلكية الأساسية والأمان",
                                isExpanded = isWifiExpanded,
                                onToggle = { isWifiExpanded = !isWifiExpanded }
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                    Text("طريقة تعيين اسم شبكة 5GHz", color = Color.Gray, fontSize = 14.sp)
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        RadioButton(selected = (wifi5gNameType == "same"), onClick = { wifi5gNameType = "same" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                        Text("مطابق لـ 2.4GHz", color = Color.White, modifier = Modifier.padding(start = 8.dp))
                                        Spacer(modifier = Modifier.width(16.dp))
                                        RadioButton(selected = (wifi5gNameType == "custom"), onClick = { wifi5gNameType = "custom" }, colors = RadioButtonDefaults.colors(selectedColor = GoldPrimary))
                                        Text("اسم mخصص", color = Color.White, modifier = Modifier.padding(start = 8.dp))
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

                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                        Text("بدون كلمة مرور (شبكة مفتوحة)", color = Color.LightGray, fontSize = 15.sp)
                                        Checkbox(checked = noPassword, onCheckedChange = { noPassword = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                    }

                                    if (!noPassword) {
                                        OutlinedTextField(
                                            value = wifiKey,
                                            onValueChange = { wifiKey = it },
                                            label = { Text("كلمة مرور الواي فاي", color = Color.Gray) },
                                            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                    }
                                }
                            }
                        } else {
                            CollapsibleSection(
                                title = "🔑 أمان شبكة الـ VLAN",
                                isExpanded = isWifiExpanded,
                                onToggle = { isWifiExpanded = !isWifiExpanded }
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                        Text("بدون كلمة مرور (شبكة مفتوحة)", color = Color.LightGray, fontSize = 15.sp)
                                        Checkbox(checked = noPassword, onCheckedChange = { noPassword = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                    }

                                    if (!noPassword) {
                                        OutlinedTextField(
                                            value = wifiKey,
                                            onValueChange = { wifiKey = it },
                                            label = { Text("كلمة مرور شبكة الـ VLAN", color = Color.Gray) },
                                            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                    }
                                }
                            }
                        }

                        // Section 3: VLAN Settings
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
                                OutlinedTextField(
                                    value = hotspotDnsName,
                                    onValueChange = { hotspotDnsName = it },
                                    label = { Text("اسم الـ DNS الداخلي (DNS Name)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                PremiumDropdownField(
                                    label = "طريقة تسجيل الدخول (Login Mode)",
                                    selectedValue = hotspotCardPage,
                                    options = listOf("username_password", "card_phone", "phone"),
                                    onValueChange = { hotspotCardPage = it }
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
                                    Checkbox(checked = hotspotSecondaryEnabled, onCheckedChange = { hotspotSecondaryEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (hotspotSecondaryEnabled) {
                                    OutlinedTextField(
                                        value = hotspotSecondarySsid,
                                        onValueChange = { hotspotSecondarySsid = it },
                                        label = { Text("اسم الشبكة الثانية SSID", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotSecondaryIp,
                                        onValueChange = { hotspotSecondaryIp = it },
                                        label = { Text("IP الشبكة الثانية (e.g. 192.168.20.1)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotSecondaryPoolStart,
                                        onValueChange = { hotspotSecondaryPoolStart = it },
                                        label = { Text("بداية توزيع الآي بي (e.g. 192.168.20.10)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
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
                                        options = listOf("standard", "premium", "bypass"),
                                        onValueChange = { hotspotSecondaryPolicy = it }
                                    )
                                }

                                Divider(color = Color.DarkGray, thickness = 1.dp)

                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل الخدمة المجانية (Trial Users)", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = hotspotTrialEnabled, onCheckedChange = { hotspotTrialEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }

                                if (hotspotTrialEnabled) {
                                    OutlinedTextField(
                                        value = hotspotTrialDuration,
                                        onValueChange = { hotspotTrialDuration = it },
                                        label = { Text("مدة الخدمة بالدقائق", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                    OutlinedTextField(
                                        value = hotspotTrialUptimeLimit,
                                        onValueChange = { hotspotTrialUptimeLimit = it },
                                        label = { Text("حد الاستخدام اليومي بالدقائق", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
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

                        // Section 3: Portal support / Ads
                        CollapsibleSection(
                            title = "📢 بوابة الإعلانات والدعم الفني",
                            isExpanded = isHotspotPortalExpanded,
                            onToggle = { isHotspotPortalExpanded = !isHotspotPortalExpanded }
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
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
                                if (portalLiveEnabled) {
                                    OutlinedTextField(
                                        value = portalLiveUrl,
                                        onValueChange = { portalLiveUrl = it },
                                        label = { Text("رابط البث المباشر", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("إظهار الاستراحة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = portalBreakEnabled, onCheckedChange = { portalBreakEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                if (portalBreakEnabled) {
                                    OutlinedTextField(
                                        value = portalBreakUrl,
                                        onValueChange = { portalBreakUrl = it },
                                        label = { Text("رابط الاستراحة", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل فحص السرعة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = portalSpeedtestEnabled, onCheckedChange = { portalSpeedtestEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                            }
                        }

                        // Section 4: Scheduled Maintenance
                        CollapsibleSection(
                            title = "🕒 جدولة الصيانة والتحديث التلقائي",
                            isExpanded = isHotspotScheduleExpanded,
                            onToggle = { isHotspotScheduleExpanded = !isHotspotScheduleExpanded }
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text("تفعيل جدولة الصيانة", color = Color.LightGray, fontSize = 15.sp)
                                    Checkbox(checked = maintenanceEnabled, onCheckedChange = { maintenanceEnabled = it }, colors = CheckboxDefaults.colors(checkedColor = GoldPrimary))
                                }
                                if (maintenanceEnabled) {
                                    OutlinedTextField(
                                        value = maintenancePolicy,
                                        onValueChange = { maintenancePolicy = it },
                                        label = { Text("سلوك الصيانة (e.g. bypass)", color = Color.Gray) },
                                        colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                        modifier = Modifier.fillMaxWidth()
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
                                Divider(color = Color.DarkGray, thickness = 1.dp)
                                Text("وقت التحديث التلقائي للنظام", color = GoldPrimary, fontWeight = FontWeight.Bold)
                                OutlinedTextField(
                                    value = autoupdateStartTime,
                                    onValueChange = { autoupdateStartTime = it },
                                    label = { Text("بداية نافذة التحديث (HH:MM)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                OutlinedTextField(
                                    value = autoupdateEndTime,
                                    onValueChange = { autoupdateEndTime = it },
                                    label = { Text("نهاية نافذة التحديث (HH:MM)", color = Color.Gray) },
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
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
                                PremiumDropdownField(
                                    label = "إعادة التشغيل كل كم ساعة (Reboot Hours)",
                                    selectedValue = rebootHours,
                                    options = listOf("1", "2", "4", "6", "12", "24", "48", "72"),
                                    onValueChange = { rebootHours = it }
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
                                    colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = Color.White, focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.DarkGray),
                                    modifier = Modifier.fillMaxWidth()
                                )
                                if (confirmRootPassword.isNotEmpty() && rootPassword != confirmRootPassword) {
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

                    // Switches for advanced features
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("إخفاء الشبكة (Hidden SSID)", color = Color.LightGray, fontSize = 15.sp)
                        Switch(
                            checked = hideSsid,
                            onCheckedChange = { hideSsid = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = GoldPrimary,
                                checkedTrackColor = GoldPrimary.copy(alpha = 0.5f),
                                uncheckedThumbColor = Color.Gray,
                                uncheckedTrackColor = Color.DarkGray
                            )
                        )
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

            // Save / Apply Button
            Button(
                onClick = {
                    if (isIpValid && deviceName.isNotEmpty() && macAddress.isNotEmpty()) {
                        onSaveDevice(
                            Device(
                                macAddress = macAddress,
                                deviceName = deviceName,
                                deviceType = selectedMode,
                                lanIp = lanIp,
                                wifiSsid = if (wifiSsid.isNotEmpty()) wifiSsid else null,
                                wifiKey = if (wifiKey.isNotEmpty()) wifiKey else null,
                                wifiChannel = if (wifiChannel.isNotEmpty()) wifiChannel else null,
                                isolateClients = isolateClients,
                                hideSsid = hideSsid,
                                disableDhcp = disableDhcp,
                                wifi2gChannel = wifi2gChannel,
                                wifi2gMode = wifi2gMode,
                                wifi2gWidth = wifi2gWidth,
                                wifi5gChannel = wifi5gChannel,
                                wifi5gMode = wifi5gMode,
                                wifi5gWidth = wifi5gWidth,
                                wifi5gNameType = wifi5gNameType,
                                wifi5gCustomSsid = if (wifi5gCustomSsid.isNotEmpty()) wifi5gCustomSsid else null,
                                appendIpToSsid = appendIpToSsid,
                                noPassword = noPassword,
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
                                hotspotDnsName = hotspotDnsName,
                                hotspotCardPage = hotspotCardPage,
                                hotspotRateLimit = hotspotRateLimit,
                                hotspotMacCookie = hotspotMacCookie,
                                hotspotSecondaryEnabled = hotspotSecondaryEnabled,
                                hotspotSecondarySsid = if (hotspotSecondarySsid.isNotEmpty()) hotspotSecondarySsid else null,
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
                enabled = isIpValid && deviceName.isNotEmpty() && macAddress.isNotEmpty() && (rootPassword.isEmpty() || rootPassword == confirmRootPassword),
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
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(title, color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Text(if (isExpanded) "🔼" else "🔽", color = GoldPrimary)
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
    onValueChange: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            value = selectedValue,
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
                    text = { Text(option, color = Color.White) },
                    onClick = {
                        onValueChange(option)
                        expanded = false
                    }
                )
            }
        }
    }
}
