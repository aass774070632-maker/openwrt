package com.alemprator.setup

import com.alemprator.setup.ssh.MikrotikUserManager
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertTrue
import org.junit.Test

class MikrotikUserManagerTest {

    @Test
    fun testConfigureRouter() {
        println("=== [بدء اختبار إضافة RADIUS الفعلي عبر كوتلن] ===")
        
        val host = "192.168.66.2" // IP الراوتر الفعلي
        val port = 8728
        val username = "ubnt"
        val password = "Baalwy123456789"
        
        // سنضيف IP جديد غير مضاف مسبقاً لاختبار الإضافة الحقيقية
        val testRouterIp = "192.168.1.15"
        val sharedSecret = "!@#$%^&*()"
        
        println("جاري الاتصال بـ $host:$port لتسجيل الدخول وإجراء عملية الإضافة...")
        
        runBlocking {
            val manager = MikrotikUserManager(
                host = host,
                port = port,
                username = username,
                password = password
            )
            
            val result = manager.configureRouter(testRouterIp, sharedSecret)
            
            println("النتيجة المرجعة: ${result.second}")
            assertTrue("يجب أن تنجح عملية الإضافة ويُرجع true", result.first)
            println("✅ نجح الاختبار المباشر للكود! تم إضافة الراوتر بنجاح.")
        }
    }
}
