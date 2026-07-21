package com.alemprator.setup

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.lifecycle.lifecycleScope
import com.alemprator.setup.db.AppDatabase
import com.alemprator.setup.db.Device
import com.alemprator.setup.logic.IPValidationEngine
import com.alemprator.setup.logic.TemplateDeriver
import com.alemprator.setup.ssh.MikrotikUserManager
import com.alemprator.setup.ssh.RouterSshClient
import com.alemprator.setup.ssh.ScriptGenerator
import com.alemprator.setup.ui.DeviceFormScreen
import com.alemprator.setup.ui.DeviceListScreen
import com.alemprator.setup.ui.ScriptPreviewScreen
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var database: AppDatabase
    private lateinit var validationEngine: IPValidationEngine
    private val scannedMac = mutableStateOf("")
    private val showDeviceList = mutableStateOf(false)
    private val deviceList = mutableStateOf<List<Device>>(emptyList())
    private val showPreview = mutableStateOf(false)
    private val previewScript = mutableStateOf("")
    private val previewCommands = mutableStateOf<List<String>>(emptyList())
    private val previewDevice = mutableStateOf<Device?>(null)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        database = AppDatabase.getDatabase(this)
        validationEngine = IPValidationEngine(database.deviceDao())

        setContent {
            if (showDeviceList.value) {
                DeviceListScreen(
                    devices = deviceList.value,
                    onBack = { showDeviceList.value = false },
                    onSelectDevice = { device ->
                        showDeviceList.value = false
                        // Setting scannedMac triggers MAC lookup which loads device fields
                        scannedMac.value = device.macAddress
                    },
                    onDeleteDevice = { device ->
                        lifecycleScope.launch {
                            database.deviceDao().deleteDevice(device)
                            deviceList.value = database.deviceDao().getAllDevices()
                            Toast.makeText(this@MainActivity, "تم حذف ${device.deviceName}", Toast.LENGTH_SHORT).show()
                        }
                    },
                    onAddManualDevice = { device ->
                        lifecycleScope.launch {
                            val existing = database.deviceDao().getDeviceByMac(device.macAddress)
                            if (existing != null) {
                                database.deviceDao().deleteDevice(existing)
                            }
                            val saved = device.copy(isTemplate = true)
                            database.deviceDao().insertDevice(saved)
                            deviceList.value = database.deviceDao().getAllDevices()
                            Toast.makeText(this@MainActivity, "تمت إضافة ${device.deviceName}", Toast.LENGTH_SHORT).show()
                        }
                    },
                    onAddToRadius = { host, port, apiUser, apiPass, routerIp, secret ->
                        lifecycleScope.launch {
                            Toast.makeText(this@MainActivity, "جاري إضافة جهاز إلى User Manager...", Toast.LENGTH_SHORT).show()
                            try {
                                val um = MikrotikUserManager(host = host, port = port, username = apiUser, password = apiPass)
                                val result = um.configureRouter(routerIp, secret)
                                if (result.first) {
                                    Toast.makeText(this@MainActivity, "تمت الإضافة إلى User Manager بنجاح", Toast.LENGTH_LONG).show()
                                } else {
                                    Toast.makeText(this@MainActivity, "فشل: ${result.second}", Toast.LENGTH_LONG).show()
                                }
                            } catch (e: Exception) {
                                Toast.makeText(this@MainActivity, "خطأ في الاتصال: ${e.message}", Toast.LENGTH_LONG).show()
                            }
                        }
                    }
                )
            } else {
                Box(modifier = Modifier.fillMaxSize()) {
                    DeviceFormScreen(
                        validationEngine = validationEngine,
                        onSaveDevice = { device ->
                            lifecycleScope.launch {
                                val existing = database.deviceDao().getDeviceByMac(device.macAddress)
                                if (existing != null) {
                                    database.deviceDao().deleteDevice(existing)
                                }
                                database.deviceDao().insertDevice(device.copy(isTemplate = true))

                                val generator = ScriptGenerator()
                                val allCommands = generator.generateCommands(device)

                                previewDevice.value = device
                                previewCommands.value = allCommands
                                previewScript.value = allCommands.joinToString("\n")
                                showPreview.value = true
                            }
                        },
                        onScanMacClick = {
                            lifecycleScope.launch {
                                Toast.makeText(this@MainActivity, "جاري قراءة الماك الفعلي من الراوتر...", Toast.LENGTH_SHORT).show()
                                val sshClient = RouterSshClient(host = "192.168.8.1")
                                val mac = sshClient.fetchMacAddress()
                                if (mac != null) {
                                    scannedMac.value = mac
                                    Toast.makeText(this@MainActivity, "تم جلب الماك: $mac", Toast.LENGTH_SHORT).show()
                                } else {
                                    Toast.makeText(this@MainActivity, "تعذر جلب الماك. تأكد من اتصالك بالواي فاي للراوتر!", Toast.LENGTH_LONG).show()
                                }
                            }
                        },
                        onShowDeviceList = {
                            lifecycleScope.launch {
                                deviceList.value = database.deviceDao().getAllDevices()
                                showDeviceList.value = true
                            }
                        },
                        scannedMac = scannedMac.value,
                        lookupDeviceByMac = { mac -> database.deviceDao().getDeviceByMac(mac) },
                        deriveTemplateForType = { type ->
                            val all = database.deviceDao().getAllDevices()
                            TemplateDeriver.derive(type, all)
                        }
                    )

                    if (showPreview.value) {
                        ScriptPreviewScreen(
                            script = previewScript.value,
                            onExecute = {
                                showPreview.value = false
                                val device = previewDevice.value
                                val allCommands = previewCommands.value
                                if (device != null && allCommands.isNotEmpty()) {
                                    lifecycleScope.launch {
                                        saveAndConfigureDevice(device, allCommands)
                                    }
                                }
                            },
                            onCancel = { showPreview.value = false },
                            onCopy = {
                                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                val clip = ClipData.newPlainText("Script", previewScript.value)
                                clipboard.setPrimaryClip(clip)
                                Toast.makeText(this@MainActivity, "تم النسخ", Toast.LENGTH_SHORT).show()
                            }
                        )
                    }
                }
            }
        }
    }

    private fun saveAndConfigureDevice(device: Device, commands: List<String>? = null) {
        lifecycleScope.launch {
            val allCommands = commands ?: run {
                val existing = database.deviceDao().getDeviceByMac(device.macAddress)
                if (existing != null) {
                    database.deviceDao().deleteDevice(existing)
                }
                database.deviceDao().insertDevice(device.copy(isTemplate = true))
                val generator = ScriptGenerator()
                generator.generateCommands(device)
            }

            // Split: config commands (UCI safe) vs reload commands (may disrupt SSH)
            val reloadMarker = allCommands.indexOfFirst { it.startsWith("echo '=== تطبيق") }
            val configCmds = if (reloadMarker > 0) allCommands.subList(0, reloadMarker) else allCommands
            val reloadCmds = if (reloadMarker > 0) allCommands.subList(reloadMarker, allCommands.size) else emptyList()

            Toast.makeText(this@MainActivity, "بدء برمجة الجهاز...", Toast.LENGTH_SHORT).show()
            val sshClient = RouterSshClient(host = "192.168.8.1")

            val result = sshClient.executeCommands(configCmds)

            if (result.first) {
                val output = result.second
                if (output.contains("[exit code:") || output.contains("FATAL")) {
                    Toast.makeText(this@MainActivity, "تم التنفيذ مع تحذيرات (انظر المخرجات)", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this@MainActivity, "تمت برمجة الجهاز بنجاح!", Toast.LENGTH_LONG).show()
                }
                // Run reload commands in background (they may disconnect WiFi)
                if (reloadCmds.isNotEmpty()) {
                    try {
                        sshClient.executeCommands(reloadCmds)
                    } catch (_: Exception) { }
                }

                // Configure MikroTik User Manager for hotspot devices
                if (device.deviceType == "Hotspot" && device.restApiEnabled) {
                    try {
                        val um = MikrotikUserManager(
                            host = device.radiusServer,
                            port = 8728,
                            username = device.restApiUsername,
                            password = device.restApiPassword ?: ""
                        )
                        val umResult = um.configureRouter(device.lanIp, device.radiusSecret ?: "")
                        if (!umResult.first) {
                            Toast.makeText(this@MainActivity, "تحذير: RADIUS: ${umResult.second}", Toast.LENGTH_LONG).show()
                        }
                    } catch (_: Exception) { }
                }
            } else {
                Toast.makeText(this@MainActivity, "فشل البرمجة: ${result.second}", Toast.LENGTH_LONG).show()
            }
        }
    }
}
