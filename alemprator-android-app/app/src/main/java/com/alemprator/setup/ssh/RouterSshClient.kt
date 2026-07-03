package com.alemprator.setup.ssh

import com.jcraft.jsch.JSch
import com.jcraft.jsch.Session
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

class RouterSshClient(
    private val host: String = "192.168.8.1",
    private val port: Int = 22,
    private val username: String = "root",
    private val password: String = "123456"
) {

    /**
     * Executes a list of shell commands on the router sequentially.
     * Returns true if all commands execute successfully, false otherwise.
     */
    suspend fun executeCommands(commands: List<String>): Pair<Boolean, String> = withContext(Dispatchers.IO) {
        val jsch = JSch()
        var session: Session? = null
        val outputLog = StringBuilder()
        
        try {
            session = jsch.getSession(username, host, port)
            session.setPassword(password)
            
            // Skip host key verification for fast local network setup
            val config = java.util.Properties()
            config["StrictHostKeyChecking"] = "no"
            session.setConfig(config)
            
            session.connect(10000) // 10 seconds timeout
            
            for (cmd in commands) {
                if (cmd.trim().isEmpty()) continue
                
                val channel = session.openChannel("exec") as com.jcraft.jsch.ChannelExec
                channel.setCommand(cmd)
                
                val outputStream = ByteArrayOutputStream()
                val errorStream = ByteArrayOutputStream()
                channel.outputStream = outputStream
                channel.setErrStream(errorStream)
                
                channel.connect()
                
                // Wait for command completion
                while (!channel.isClosed) {
                    Thread.sleep(100)
                }
                
                val exitStatus = channel.exitStatus
                val out = outputStream.toString()
                val err = errorStream.toString()
                
                outputLog.append("\n$ $cmd\n")
                if (out.isNotEmpty()) outputLog.append(out)
                if (err.isNotEmpty()) outputLog.append("ERROR: $err")
                
                channel.disconnect()
                
                if (exitStatus != 0) {
                    return@withContext Pair(false, "فشل تنفيذ الأمر: $cmd\nالخطأ: $err")
                }
            }
            
            return@withContext Pair(true, "تم تطبيق الإعدادات بنجاح!\n${outputLog.toString()}")
            
        } catch (e: Exception) {
            return@withContext Pair(false, "فشل الاتصال بـ SSH: ${e.message}")
        } finally {
            session?.disconnect()
        }
    }

    /**
     * Connects to the router and retrieves the system MAC address.
     */
    suspend fun fetchMacAddress(): String? = withContext(Dispatchers.IO) {
        val jsch = JSch()
        var session: Session? = null
        try {
            session = jsch.getSession(username, host, port)
            session.setPassword(password)
            val config = java.util.Properties()
            config["StrictHostKeyChecking"] = "no"
            session.setConfig(config)
            session.connect(5000)
            
            val channel = session.openChannel("exec") as com.jcraft.jsch.ChannelExec
            channel.setCommand("cat /sys/class/net/eth0/address || cat /sys/class/net/br-lan/address")
            
            val outputStream = ByteArrayOutputStream()
            channel.outputStream = outputStream
            channel.connect()
            
            while (!channel.isClosed) {
                Thread.sleep(100)
            }
            
            val mac = outputStream.toString().trim().uppercase()
            channel.disconnect()
            return@withContext if (mac.isNotEmpty()) mac else null
        } catch (e: Exception) {
            return@withContext null
        } finally {
            session?.disconnect()
        }
    }
}
