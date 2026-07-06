package com.alemprator.setup.ssh

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStream
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
        try {
            val socket = Socket(host, port)
            socket.soTimeout = 10000
            val output = socket.getOutputStream()
            val input = socket.getInputStream()

            // Read banner
            readSentence(input)

            // Login: send /login, read challenge
            writeSentence(output, "/login")
            val loginResp = readSentence(input)
            val challenge = loginResp.entries.firstOrNull { it.startsWith("=ret=") }?.removePrefix("=ret=")
                ?: loginResp.entries.firstOrNull { it.startsWith("=challenge=") }?.removePrefix("=challenge=")
                ?: return@withContext Pair(false, "فشل تسجيل الدخول: لم يتم استلام challenge")

            val hashedPassword = hexMd5(password)
            val response = hexMd5(challenge + hashedPassword)

            writeSentence(output, "/login", "=name=$username", "=response=00$response")
            val authResp = readSentence(input)
            if (authResp.entries.any { it == "!trap" }) {
                socket.close()
                return@withContext Pair(false, "فشل تسجيل الدخول: اسم مستخدم أو كلمة سر خطأ")
            }

            // Add router to User Manager
            writeSentence(
                output,
                "/user-manager/router/add",
                "=address=$routerIp",
                "=shared-secret=$sharedSecret",
                "=coa-port=1700",
                "=disabled=no"
            )
            val addResp = readSentence(input)
            if (addResp.entries.any { it == "!trap" }) {
                val msg = addResp.entries.firstOrNull { it.startsWith("=message=") }?.removePrefix("=message=") ?: "خطأ"
                socket.close()
                return@withContext Pair(false, "فشل إضافة الراوتر: $msg")
            }

            // Set timezone
            writeSentence(output, "/user-manager/set", "=time-zone-offset=+03:00")
            val tzResp = readSentence(input)
            if (tzResp.entries.any { it == "!trap" }) {
                val msg = tzResp.entries.firstOrNull { it.startsWith("=message=") }?.removePrefix("=message=") ?: "خطأ"
                socket.close()
                return@withContext Pair(false, "فشل ضبط المنطقة الزمنية: $msg")
            }

            socket.close()
            return@withContext Pair(true, "تم إعداد User Manager بنجاح")
        } catch (e: Exception) {
            return@withContext Pair(false, "فشل الاتصال: ${e.message}")
        }
    }

    private fun writeSentence(output: OutputStream, vararg words: String) {
        for (word in words) {
            val bytes = word.toByteArray(Charsets.UTF_8)
            output.write("${bytes.size}#$word".toByteArray(Charsets.UTF_8))
            output.write(0x00)
        }
        output.write("0#".toByteArray(Charsets.UTF_8))
        output.write(0x00)
        output.flush()
    }

    private data class Sentence(val entries: List<String>)

    private fun readSentence(input: InputStream): Sentence {
        val entries = mutableListOf<String>()
        val buf = StringBuilder()
        var readingLength = true
        var expectedLength = 0
        var c: Int

        while (true) {
            c = input.read()
            if (c == -1) break

            if (readingLength) {
                if (c.toChar() == '#') {
                    expectedLength = buf.toString().toIntOrNull() ?: 0
                    buf.clear()
                    readingLength = false
                } else {
                    buf.append(c.toChar())
                }
            } else {
                if (c == 0x00) {
                    val word = buf.toString()
                    buf.clear()
                    if (word.isEmpty() && expectedLength == 0) {
                        // End of sentence
                        break
                    }
                    entries.add(word)
                    readingLength = true
                    expectedLength = 0
                } else {
                    buf.append(c.toChar())
                }
            }
        }

        return Sentence(entries)
    }

    private fun hexMd5(input: String): String {
        val md = MessageDigest.getInstance("MD5")
        val digest = md.digest(input.toByteArray(Charsets.UTF_8))
        return digest.joinToString("") { "%02x".format(it) }
    }
}
