package com.alemprator.setup.logic

object AutoIncrementUtil {

    fun incrementIp(ip: String): String {
        val parts = ip.trim().split(".")
        if (parts.size != 4) return ip
        val last = parts[3].toIntOrNull() ?: return ip
        return "${parts[0]}.${parts[1]}.${parts[2]}.${last + 1}"
    }

    fun incrementSsid(ssid: String): String {
        val trimmed = ssid.trim()
        if (trimmed.isEmpty()) return trimmed

        // Try to extract trailing number
        val match = Regex("(.*?)(\\d+)$").find(trimmed)
        return if (match != null) {
            val prefix = match.groupValues[1]
            val num = match.groupValues[2].toIntOrNull() ?: return "${trimmed}_2"
            "${prefix}${num + 1}"
        } else {
            "${trimmed}_2"
        }
    }
}
