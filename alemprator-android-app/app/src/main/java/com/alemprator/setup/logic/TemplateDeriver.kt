package com.alemprator.setup.logic

import com.alemprator.setup.db.Device

object TemplateDeriver {

    fun derive(targetType: String, allDevices: List<Device>): Device? {
        val sameType = allDevices
            .filter { it.deviceType == targetType }
            .sortedByDescending { it.timestamp }

        val latest = sameType.firstOrNull() ?: return null

        // Find max IP across ALL devices (not just same type)
        val maxIp = allDevices.maxOfOrNull { parseIp(it.lanIp) }
        val nextIp = if (maxIp != null) intToIp(maxIp + 1) else incrementIp(latest.lanIp)

        return latest.copy(
            macAddress = "",
            deviceName = "",
            lanIp = nextIp,
            wifiSsid = incrementSsid(latest.wifiSsid ?: "ALEMPRATOR_AP"),
            vlanSsid2g = latest.vlanSsid2g?.let { incrementSsid(it) },
            vlanSsid5g = latest.vlanSsid5g?.let { incrementSsid(it) },
            isTemplate = true
        )
    }

    private fun incrementIp(ip: String): String {
        val parts = ip.trim().split(".")
        if (parts.size != 4) return ip
        val last = parts[3].toIntOrNull() ?: return ip
        return "${parts[0]}.${parts[1]}.${parts[2]}.${last + 1}"
    }

    private fun incrementSsid(ssid: String): String {
        val trimmed = ssid.trim()
        if (trimmed.isEmpty()) return trimmed
        val match = Regex("(.*?)(\\d+)$").find(trimmed)
        return if (match != null) {
            "${match.groupValues[1]}${(match.groupValues[2].toIntOrNull() ?: 0) + 1}"
        } else {
            "${trimmed}_2"
        }
    }

    private fun parseIp(ip: String): Int {
        val parts = ip.trim().split(".")
        if (parts.size != 4) return 0
        return (parts[0].toIntOrNull() ?: 0) * 256 * 256 * 256 +
               (parts[1].toIntOrNull() ?: 0) * 256 * 256 +
               (parts[2].toIntOrNull() ?: 0) * 256 +
               (parts[3].toIntOrNull() ?: 0)
    }

    private fun intToIp(value: Int): String {
        return "${(value shr 24) and 0xFF}.${(value shr 16) and 0xFF}.${(value shr 8) and 0xFF}.${value and 0xFF}"
    }
}
