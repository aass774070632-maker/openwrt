package com.alemprator.setup.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.alemprator.setup.db.Device
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeviceListScreen(
    devices: List<Device>,
    onBack: () -> Unit,
    onSelectDevice: (Device) -> Unit,
    onDeleteDevice: (Device) -> Unit,
    onAddManualDevice: (Device) -> Unit,
    onAddToRadius: (host: String, port: Int, apiUser: String, apiPass: String, routerIp: String, secret: String) -> Unit
) {
    val dateFormat = remember { SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()) }
    var showAddDialog by remember { mutableStateOf(false) }
    var radiusDialogDevice by remember { mutableStateOf<Device?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("الأجهزة المبرمجة", color = Color.White) },
                navigationIcon = {
                    TextButton(onClick = onBack) {
                        Text("عودة", color = GoldPrimary, fontSize = 16.sp)
                    }
                },
                actions = {
                    TextButton(onClick = { showAddDialog = true }) {
                        Text("➕ إضافة يدوي", color = GoldPrimary, fontSize = 14.sp)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF1E1E1E))
            )
        },
        containerColor = Color(0xFF121212)
    ) { padding ->
        if (devices.isEmpty()) {
            Box(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("لا توجد أجهزة مبرمجة بعد", color = Color.Gray, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    OutlinedButton(
                        onClick = { showAddDialog = true },
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = GoldPrimary),
                        border = BorderStroke(1.dp, GoldPrimary)
                    ) {
                        Text("➕ إضافة جهاز يدوي", color = GoldPrimary)
                    }
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(devices, key = { it.id }) { device ->
                    Card(
                        onClick = { onSelectDevice(device) },
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E1E1E)),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                Text(device.deviceName, color = GoldPrimary, fontWeight = FontWeight.Bold, fontSize = 16.sp, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f, fill = false))
                                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    TextButton(onClick = { radiusDialogDevice = device }) {
                                        Text("☁️ RADIUS", color = GoldPrimary, fontSize = 14.sp)
                                    }
                                    TextButton(onClick = { onDeleteDevice(device) }) {
                                        Text("🗑️ حذف", color = Color(0xFFEF5350), fontSize = 14.sp)
                                    }
                                }
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Row {
                                Text("MAC: ", color = Color.Gray, fontSize = 13.sp)
                                Text(device.macAddress, color = Color.White, fontSize = 13.sp)
                            }
                            Row {
                                Text("IP: ", color = Color.Gray, fontSize = 13.sp)
                                Text(device.lanIp, color = Color.White, fontSize = 13.sp)
                            }
                            Row {
                                Text("النوع: ", color = Color.Gray, fontSize = 13.sp)
                                Text(formatMode(device.deviceType), color = Color.White, fontSize = 13.sp)
                            }
                            Row {
                                Text("التاريخ: ", color = Color.Gray, fontSize = 13.sp)
                                Text(dateFormat.format(Date(device.timestamp)), color = Color.White, fontSize = 13.sp)
                            }
                        }
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        AddManualDeviceDialog(
            existingMacs = devices.map { it.macAddress },
            existingIps = devices.map { it.lanIp },
            existingNames = devices.map { it.deviceName },
            onDismiss = { showAddDialog = false },
            onConfirm = { device ->
                onAddManualDevice(device)
                showAddDialog = false
            }
        )
    }

    radiusDialogDevice?.let { device ->
        AddToRadiusDialog(
            device = device,
            onDismiss = { radiusDialogDevice = null },
            onConfirm = { host, port, apiUser, apiPass, routerIp, secret -> radiusDialogDevice = null; onAddToRadius(host, port, apiUser, apiPass, routerIp, secret) }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddManualDeviceDialog(
    existingMacs: List<String>,
    existingIps: List<String>,
    existingNames: List<String>,
    onDismiss: () -> Unit,
    onConfirm: (Device) -> Unit
) {
    var name by remember { mutableStateOf("") }
    var mac by remember { mutableStateOf("") }
    var ip by remember { mutableStateOf("") }
    var type by remember { mutableStateOf("ap") }
    var nameError by remember { mutableStateOf(false) }
    var macError by remember { mutableStateOf(false) }
    var ipError by remember { mutableStateOf(false) }
    var typeExpanded by remember { mutableStateOf(false) }

    val types = listOf("ap", "ap_wds", "sta_wds", "mesh", "hotspot")
    val typeLabels = listOf("AP", "AP + WDS", "استقبال لاسلكي", "ميش", "هوتسبوت")

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF1E1E1E),
        title = { Text("إضافة جهاز يدوي", color = GoldPrimary, fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it; nameError = false },
                    label = { Text("اسم الجهاز", color = Color.Gray) },
                    isError = nameError,
                    supportingText = if (nameError) {{ Text("الحقل مطلوب", color = Color(0xFFEF5350)) }} else null,
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = GoldPrimary,
                        unfocusedBorderColor = Color.Gray,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                OutlinedTextField(
                    value = mac,
                    onValueChange = { mac = it.uppercase(); macError = false },
                    label = { Text("MAC Address", color = Color.Gray) },
                    placeholder = { Text("00:11:22:AA:BB:CC", color = Color.Gray) },
                    isError = macError,
                    supportingText = if (macError) {{ Text("MAC موجود أو غير صالح", color = Color(0xFFEF5350)) }} else null,
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Ascii),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = GoldPrimary,
                        unfocusedBorderColor = Color.Gray,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                OutlinedTextField(
                    value = ip,
                    onValueChange = { ip = it; ipError = false },
                    label = { Text("الـ IP", color = Color.Gray) },
                    placeholder = { Text("192.168.101.10", color = Color.Gray) },
                    isError = ipError,
                    supportingText = if (ipError) {{ Text("IP موجود أو غير صالح", color = Color(0xFFEF5350)) }} else null,
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = GoldPrimary,
                        unfocusedBorderColor = Color.Gray,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
                ExposedDropdownMenuBox(expanded = typeExpanded, onExpandedChange = { typeExpanded = it }) {
                    OutlinedTextField(
                        value = typeLabels[types.indexOf(type).coerceAtLeast(0)],
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("النوع", color = Color.Gray) },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = typeExpanded) },
                        modifier = Modifier.fillMaxWidth().menuAnchor(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = GoldPrimary,
                            unfocusedBorderColor = Color.Gray,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        )
                    )
                    ExposedDropdownMenu(expanded = typeExpanded, onDismissRequest = { typeExpanded = false }) {
                        typeLabels.forEachIndexed { i, label ->
                            DropdownMenuItem(
                                text = { Text(label, color = Color.White) },
                                onClick = { type = types[i]; typeExpanded = false }
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    var valid = true
                    if (name.isBlank()) { nameError = true; valid = false }
                    if (!isValidMac(mac)) { macError = true; valid = false }
                    if (existingMacs.contains(mac)) { macError = true; valid = false }
                    if (!isValidIp(ip)) { ipError = true; valid = false }
                    if (existingIps.contains(ip)) { ipError = true; valid = false }
                    if (!valid) return@Button
                    onConfirm(Device(macAddress = mac, deviceName = name, deviceType = type, lanIp = ip))
                },
                colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)
            ) {
                Text("إضافة", color = Color.Black, fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("إلغاء", color = Color.Gray)
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AddToRadiusDialog(
    device: Device,
    onDismiss: () -> Unit,
    onConfirm: (host: String, port: Int, apiUser: String, apiPass: String, routerIp: String, secret: String) -> Unit
) {
    var radiusHost by remember { mutableStateOf(device.radiusServer) }
    var apiPort by remember { mutableStateOf("8728") }
    var apiUser by remember { mutableStateOf(device.restApiUsername) }
    var apiPass by remember { mutableStateOf(device.restApiPassword ?: "") }
    var routerIp by remember { mutableStateOf(device.lanIp) }
    var sharedSecret by remember { mutableStateOf(device.radiusSecret ?: "") }

    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = Color(0xFF1E1E1E),
        title = { Text("إضافة إلى User Manager", color = GoldPrimary, fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = radiusHost, onValueChange = { radiusHost = it }, label = { Text("خادم RADIUS IP", color = Color.Gray) }, singleLine = true, modifier = Modifier.fillMaxWidth(), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(value = apiPort, onValueChange = { apiPort = it.filter { c -> c.isDigit() } }, label = { Text("API منفذ", color = Color.Gray) }, singleLine = true, modifier = Modifier.width(100.dp), keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
                    OutlinedTextField(value = apiUser, onValueChange = { apiUser = it }, label = { Text("SSH مستخدم", color = Color.Gray) }, singleLine = true, modifier = Modifier.weight(1f), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
                }
                OutlinedTextField(value = apiPass, onValueChange = { apiPass = it }, label = { Text("SSH كلمة سر", color = Color.Gray) }, singleLine = true, modifier = Modifier.fillMaxWidth(), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
                OutlinedTextField(value = routerIp, onValueChange = { routerIp = it }, label = { Text("IP الراوتر المبرمج", color = Color.Gray) }, singleLine = true, modifier = Modifier.fillMaxWidth(), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
                OutlinedTextField(value = sharedSecret, onValueChange = { sharedSecret = it }, label = { Text("Shared Secret", color = Color.Gray) }, singleLine = true, modifier = Modifier.fillMaxWidth(), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = GoldPrimary, unfocusedBorderColor = Color.Gray, focusedTextColor = Color.White, unfocusedTextColor = Color.White))
            }
        },
        confirmButton = {
            Button(onClick = { onConfirm(radiusHost, apiPort.toIntOrNull() ?: 8728, apiUser, apiPass, routerIp, sharedSecret) }, colors = ButtonDefaults.buttonColors(containerColor = GoldPrimary)) {
                Text("إضافة", color = Color.Black, fontWeight = FontWeight.Bold)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("إلغاء", color = Color.Gray)
            }
        }
    )
}

private fun isValidIp(ip: String): Boolean {
    val parts = ip.split(".")
    if (parts.size != 4) return false
    return parts.all { it.toIntOrNull()?.let { n -> n in 0..255 } ?: false }
}

private fun isValidMac(mac: String): Boolean {
    return mac.matches(Regex("^([0-9A-F]{2}:){5}[0-9A-F]{2}$"))
}

private fun formatMode(mode: String): String = when (mode) {
    "ap" -> "نقطة وصول (AP)"
    "ap_wds" -> "نقطة وصول + WDS"
    "sta_wds" -> "استقبال لاسلكي"
    "mesh" -> "ميش"
    "hotspot" -> "هوتسبوت"
    else -> mode
}
