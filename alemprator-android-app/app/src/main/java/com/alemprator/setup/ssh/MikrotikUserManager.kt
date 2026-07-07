package com.alemprator.setup.ssh

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.DataInputStream
import java.io.OutputStream
import java.net.Socket
import java.security.MessageDigest

class MikrotikUserManager(
    private val host: String = "192.168.1.2",
    private val port: Int = 8728,
    private val username: String = "",
    private val password: String = ""
) {

    suspend fun configureRouter(routerIp: String, sharedSecret: String): Pair<Boolean, String> = withContext(Dispatchers.IO) {
        var socket: Socket? = null
        try {
            socket = Socket(host, port)
            socket.soTimeout = 10000
            val output = socket.getOutputStream()
            val input = DataInputStream(socket.getInputStream())

            // --- Login ---
            // Try new-style login first (RouterOS v6.43+)
            writeSentence(output, "/login", "=name=$username", "=password=$password")
            val loginResp = readSentence(input)

            when {
                // New-style login succeeded
                loginResp.firstOrNull() == "!done" && loginResp.none { it.startsWith("=ret=") } -> {
                    // Logged in successfully
                }
                // Old-style RouterOS: got challenge back, need to compute MD5 response
                loginResp.firstOrNull() == "!done" && loginResp.any { it.startsWith("=ret=") } -> {
                    val challenge = loginResp.first { it.startsWith("=ret=") }.removePrefix("=ret=")
                    val challengeBytes = hexStringToByteArray(challenge)

                    val md = MessageDigest.getInstance("MD5")
                    md.update(0x00.toByte())
                    md.update(password.toByteArray(Charsets.UTF_8))
                    md.update(challengeBytes)
                    val hash = md.digest()
                    val hexHash = "00" + hash.joinToString("") { "%02x".format(it) }

                    writeSentence(output, "/login", "=name=$username", "=response=$hexHash")
                    val authResp = readSentence(input)
                    if (authResp.firstOrNull() != "!done") {
                        val msg = authResp.firstOrNull { it.startsWith("=message=") }?.removePrefix("=message=")
                            ?: "اسم مستخدم أو كلمة سر خطأ"
                        if (authResp.firstOrNull() == "!trap") readSentence(input)
                        return@withContext Pair(false, "فشل تسجيل الدخول: $msg")
                    }
                }
                // Login failed with error
                loginResp.firstOrNull() == "!trap" -> {
                    val msg = loginResp.firstOrNull { it.startsWith("=message=") }?.removePrefix("=message=")
                        ?: "اسم مستخدم أو كلمة سر خطأ"
                    readSentence(input) // read the !done that follows !trap
                    return@withContext Pair(false, "فشل تسجيل الدخول: $msg")
                }
                else -> {
                    return@withContext Pair(false, "فشل تسجيل الدخول: رد غير متوقع")
                }
            }

            // --- Get RouterOS Version ---
            writeSentence(output, "/system/resource/print")
            val resourceResp = readSentence(input)
            var isV7 = false
            for (line in resourceResp) {
                if (line.startsWith("=version=")) {
                    val versionStr = line.removePrefix("=version=")
                    if (versionStr.startsWith("7.")) {
                        isV7 = true
                    }
                    break
                }
            }

            // --- Add router to User Manager ---
            if (isV7) {
                // RouterOS v7 requires 'name' parameter for adding a router
                val routerName = "EMPRATOR-${routerIp.replace(".", "-")}"
                writeSentence(
                    output,
                    "/user-manager/router/add",
                    "=address=$routerIp",
                    "=shared-secret=$sharedSecret",
                    "=name=$routerName",
                    "=disabled=no"
                )
            } else {
                // RouterOS v6 commands (Fetch customer dynamically instead of hardcoding admin)
                val customerName = getFirstCustomer(output, input, username)
                val routerName = "EMPRATOR-${routerIp.replace(".", "-")}"
                writeSentence(
                    output,
                    "/tool/user-manager/router/add",
                    "=ip-address=$routerIp",
                    "=shared-secret=$sharedSecret",
                    "=customer=$customerName",
                    "=name=$routerName",
                    "=coa-port=1700",
                    "=log=",
                    "=disabled=no"
                )
            }
            val addResp = readSentence(input)
            if (addResp.firstOrNull() == "!trap") {
                val msg = addResp.firstOrNull { it.startsWith("=message=") }?.removePrefix("=message=") ?: "خطأ"
                readSentence(input) // read the !done that follows !trap
                
                // If it already exists error, we can ignore or update
                if (msg.contains("already exists", ignoreCase = true) || msg.contains("already", ignoreCase = true)) {
                    // Do nothing, treat as success or continue
                } else {
                    return@withContext Pair(false, "فشل إضافة الراوتر: $msg")
                }
            }

            // --- Set timezone ---
            if (isV7) {
                // In RouterOS v7, set system clock timezone
                writeSentence(output, "/system/clock/set", "=time-zone-name=Asia/Aden")
                val tzResp = readSentence(input)
                if (tzResp.firstOrNull() == "!trap") {
                    readSentence(input) // consume done
                }
            } else {
                // RouterOS v6 User Manager local timezone offset
                writeSentence(output, "/tool/user-manager/set", "=time-zone-offset=+03:00")
                val tzResp = readSentence(input)
                if (tzResp.firstOrNull() == "!trap") {
                    readSentence(input) // consume done
                }
            }

            return@withContext Pair(true, "تم إعداد User Manager بنجاح (ROS v${if (isV7) "7" else "6"})")
        } catch (e: Exception) {
            return@withContext Pair(false, "فشل الاتصال: ${e.message}")
        } finally {
            try { socket?.close() } catch (_: Exception) {}
        }
    }

    private fun getFirstCustomer(output: OutputStream, input: DataInputStream, fallback: String): String {
        try {
            writeSentence(output, "/tool/user-manager/customer/print")
            var customerName = ""
            while (true) {
                val words = readSentence(input)
                if (words.isEmpty() || words[0] == "!done") break
                if (words[0] == "!re") {
                    for (word in words) {
                        if (word.startsWith("=login=")) {
                            customerName = word.removePrefix("=login=")
                        }
                    }
                }
                if (words[0] == "!trap") {
                    readSentence(input) // consume done
                    break
                }
            }
            return customerName.ifEmpty { fallback }
        } catch (e: Exception) {
            return fallback
        }
    }

    // ========================================================================
    // MikroTik API Wire Protocol — Binary Length-Prefix Encoding
    // ========================================================================

    private fun writeLength(output: OutputStream, len: Int) {
        when {
            len < 0x80 -> {
                output.write(len)
            }
            len < 0x4000 -> {
                output.write((len shr 8) or 0x80)
                output.write(len and 0xFF)
            }
            len < 0x200000 -> {
                output.write((len shr 16) or 0xC0)
                output.write((len shr 8) and 0xFF)
                output.write(len and 0xFF)
            }
            len < 0x10000000 -> {
                output.write((len shr 24) or 0xE0)
                output.write((len shr 16) and 0xFF)
                output.write((len shr 8) and 0xFF)
                output.write(len and 0xFF)
            }
            else -> {
                output.write(0xF0)
                output.write((len shr 24) and 0xFF)
                output.write((len shr 16) and 0xFF)
                output.write((len shr 8) and 0xFF)
                output.write(len and 0xFF)
            }
        }
    }

    private fun readLength(input: DataInputStream): Int {
        val b = input.read()
        if (b < 0) return -1
        return when {
            b and 0x80 == 0 -> b
            b and 0xC0 == 0x80 -> ((b and 0x3F) shl 8) or input.read()
            b and 0xE0 == 0xC0 -> ((b and 0x1F) shl 16) or (input.read() shl 8) or input.read()
            b and 0xF0 == 0xE0 -> ((b and 0x0F) shl 24) or (input.read() shl 16) or (input.read() shl 8) or input.read()
            else -> (input.read() shl 24) or (input.read() shl 16) or (input.read() shl 8) or input.read()
        }
    }

    private fun writeSentence(output: OutputStream, vararg words: String) {
        for (word in words) {
            val bytes = word.toByteArray(Charsets.UTF_8)
            writeLength(output, bytes.size)
            output.write(bytes)
        }
        writeLength(output, 0)
        output.flush()
    }

    private fun readSentence(input: DataInputStream): List<String> {
        val words = mutableListOf<String>()
        while (true) {
            val len = readLength(input)
            if (len <= 0) break
            val buf = ByteArray(len)
            input.readFully(buf)
            words.add(String(buf, Charsets.UTF_8))
        }
        return words
    }

    private fun hexStringToByteArray(hex: String): ByteArray {
        val len = hex.length
        val data = ByteArray(len / 2)
        for (i in 0 until len step 2) {
            data[i / 2] = ((Character.digit(hex[i], 16) shl 4) + Character.digit(hex[i + 1], 16)).toByte()
        }
        return data
    }
}
