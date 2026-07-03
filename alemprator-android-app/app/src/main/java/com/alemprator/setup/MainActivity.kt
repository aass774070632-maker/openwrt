package com.alemprator.setup

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.lifecycleScope
import com.alemprator.setup.db.AppDatabase
import com.alemprator.setup.db.Device
import com.alemprator.setup.logic.IPValidationEngine
import com.alemprator.setup.ssh.RouterSshClient
import com.alemprator.setup.ssh.ScriptGenerator
import com.alemprator.setup.ui.DeviceFormScreen
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var database: AppDatabase
    private lateinit var validationEngine: IPValidationEngine
    private val scannedMac = mutableStateOf("")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        database = AppDatabase.getDatabase(this)
        validationEngine = IPValidationEngine(database.deviceDao())

        setContent {
            DeviceFormScreen(
                validationEngine = validationEngine,
                onSaveDevice = { device ->
                    saveAndConfigureDevice(device)
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
                scannedMac = scannedMac.value
            )
        }
    }

    private fun saveAndConfigureDevice(device: Device) {
        lifecycleScope.launch {
            // 1. Save in local database
            database.deviceDao().insertDevice(device)

            // 2. Generate commands
            val generator = ScriptGenerator()
            val commands = generator.generateCommands(device)

            // 3. Connect and execute via SSH
            Toast.makeText(this@MainActivity, "بدء البرمجة عبر الشبكة...", Toast.LENGTH_SHORT).show()
            val sshClient = RouterSshClient(host = "192.168.8.1")
            val result = sshClient.executeCommands(commands)

            if (result.first) {
                Toast.makeText(this@MainActivity, "تمت برمجة الجهاز بنجاح!", Toast.LENGTH_LONG).show()
            } else {
                Toast.makeText(this@MainActivity, "فشل الاتصال: ${result.second}", Toast.LENGTH_LONG).show()
            }
        }
    }
}
