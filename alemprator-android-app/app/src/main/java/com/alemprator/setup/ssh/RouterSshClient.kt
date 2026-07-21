package com.alemprator.setup.ssh

import com.jcraft.jsch.ChannelExec
import com.jcraft.jsch.JSch
import com.jcraft.jsch.Session
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

class RouterSshClient(
    private val host: String = "192.168.8.1",
    private val port: Int = 22,
    private val username: String = "root",
    private val password: String = "testing321"
) {

    private fun connectSession(jsch: JSch, candidatePasswords: List<String>): Session {
        var lastException: Exception? = null
        val config = java.util.Properties()
        config["StrictHostKeyChecking"] = "no"

        for (pwd in candidatePasswords.distinct()) {
            try {
                val session = jsch.getSession(username, host, port)
                session.setPassword(pwd)
                session.setConfig(config)
                session.connect(4000)
                return session
            } catch (e: Exception) {
                lastException = e
            }
        }
        throw lastException ?: Exception("فشل الاتصال بـ SSH")
    }

    /**
     * Executes a list of shell commands on the router sequentially.
     * Continues on non-zero exit (doesn't stop at first failure).
     * Returns true if SSH connection succeeded and all commands were submitted.
     * Non-zero exit codes are appended to the output for caller to inspect.
     */
    suspend fun executeCommands(commands: List<String>): Pair<Boolean, String> = withContext(Dispatchers.IO) {
        val jsch = JSch()
        var session: Session? = null
        val outputLog = StringBuilder()
        var hadNonZero = false
        
        try {
            val candidatePasswords = listOf(password, "123456", "", "testing321", "admin")
            session = connectSession(jsch, candidatePasswords)
            
            for (cmd in commands) {
                if (cmd.trim().isEmpty()) continue
                
                val channel = session.openChannel("exec") as ChannelExec
                channel.setCommand(cmd)
                
                val outputStream = ByteArrayOutputStream()
                val errorStream = ByteArrayOutputStream()
                channel.outputStream = outputStream
                channel.errStream = errorStream
                
                channel.connect()
                
                while (!channel.isClosed) {
                    Thread.sleep(100)
                }
                
                val out = outputStream.toString().trim()
                val err = errorStream.toString().trim()
                val exitStatus = channel.exitStatus
                channel.disconnect()
                
                outputLog.append("\n$ $cmd\n")
                if (out.isNotEmpty()) outputLog.append("$out\n")
                if (err.isNotEmpty()) outputLog.append("[stderr] $err\n")
                
                if (exitStatus != 0) {
                    outputLog.append("[exit code: $exitStatus]")
                    hadNonZero = true
                }
            }
            
            val message = outputLog.toString().ifEmpty { "تم تطبيق الإعدادات" }
            return@withContext Pair(true, message)
            
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
            val candidatePasswords = listOf(password, "123456", "", "testing321", "admin")
            session = connectSession(jsch, candidatePasswords)
            
            val channel = session.openChannel("exec") as com.jcraft.jsch.ChannelExec
            val getMacCmd = "cat /sys/class/net/eth0/address 2>/dev/null || cat /sys/class/net/br-lan/address 2>/dev/null || cat /sys/class/net/br_setup/address 2>/dev/null || cat /sys/class/net/phy0-ap0/address 2>/dev/null || cat /sys/class/net/lan1/address 2>/dev/null || cat /sys/class/net/wan/address 2>/dev/null"
            channel.setCommand(getMacCmd)
            
            val outputStream = ByteArrayOutputStream()
            channel.outputStream = outputStream
            channel.connect()
            
            while (!channel.isClosed) {
                Thread.sleep(100)
            }
            
            val mac = outputStream.toString().trim().uppercase()
            channel.disconnect()
            return@withContext if (mac.isNotEmpty() && mac.contains(":")) mac else null
        } catch (e: Exception) {
            return@withContext null
        } finally {
            session?.disconnect()
        }
    }
}
