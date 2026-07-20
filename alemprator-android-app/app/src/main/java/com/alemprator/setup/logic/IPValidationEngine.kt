package com.alemprator.setup.logic

import com.alemprator.setup.db.DeviceDao
import com.alemprator.setup.db.Device
import com.alemprator.setup.db.SubnetPool

class IPValidationEngine(private val deviceDao: DeviceDao) {

    /**
     * Validates the structure of an IPv4 address (four octets 0-255).
     * Accepts any range the user types — including public ranges — because the
     * router (hotspot apply) can bridge/serve any subnet. Returns false for
     * blank or malformed input.
     */
    fun isValidIp(ip: String): Boolean {
        val trimmed = ip.trim()
        if (trimmed.isEmpty()) return false
        val parts = trimmed.split('.')
        if (parts.size != 4) return false
        for (p in parts) {
            val octet = p.toIntOrNull() ?: return false
            if (octet < 0 || octet > 255) return false
        }
        return true
    }

    /**
     * Returns true if the IPv4 address belongs to an RFC1918 private range
     * (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16). Used to warn (not block)
     * when a user types a public range such as 192.167.x.x, which would work
     * locally but cannot be NATed to the internet via the WAN interface.
     */
    fun isPrivateIp(ip: String): Boolean {
        if (!isValidIp(ip)) return false
        val parts = ip.trim().split('.').map { it.toInt() }
        return when (parts[0]) {
            10 -> true
            172 -> parts[1] in 16..31
            192 -> parts[1] == 168
            else -> false
        }
    }

    /**
     * Checks if a LAN IP is already assigned to a different MAC address.
     * Returns the conflicting Device if exists, null otherwise.
     */
    suspend fun checkLanIpConflict(ip: String, currentMac: String): Device? {
        val existing = deviceDao.getDeviceByIp(ip.trim())
        if (existing != null && existing.macAddress.lowercase() != currentMac.lowercase()) {
            return existing
        }
        return null
    }

    /**
     * Suggests the next available LAN IP based on the highest IP in the DB.
     * Fallback to 192.168.1.20 if DB is empty.
     */
    suspend fun suggestNextLanIp(): String {
        val devices = deviceDao.getAllDevices()
        if (devices.isEmpty()) {
            return "192.168.1.20"
        }

        // Parse and find highest IP
        var highestOctet = 20
        var prefix = "192.168.1"

        for (device in devices) {
            val parts = device.lanIp.split(".")
            if (parts.size == 4) {
                val currentPrefix = "${parts[0]}.${parts[1]}.${parts[2]}"
                val octet = parts[3].toIntOrNull()
                if (octet != null && octet >= highestOctet) {
                    highestOctet = octet
                    prefix = currentPrefix
                }
            }
        }

        val nextOctet = highestOctet + 1
        return if (nextOctet < 255) "$prefix.$nextOctet" else "$prefix.20"
    }

    /**
     * Suggests the next non-conflicting Hotspot DHCP Subnet Pool.
     * Incrementing the third octet starting from 10.10.10.0/24
     */
    suspend fun suggestNextHotspotPool(): Triple<String, String, String> {
        val pools = deviceDao.getAllSubnetPools()
        if (pools.isEmpty()) {
            return Triple("10.10.10.0/24", "10.10.10.10", "10.10.10.199")
        }

        var highestThirdOctet = 10
        for (pool in pools) {
            val parts = pool.poolNetwork.split(".")
            if (parts.size >= 3) {
                val thirdOctet = parts[2].toIntOrNull()
                if (thirdOctet != null && thirdOctet > highestThirdOctet) {
                    highestThirdOctet = thirdOctet
                }
            }
        }

        val nextThirdOctet = highestThirdOctet + 1
        val newSubnet = "10.10.$nextThirdOctet.0/24"
        val newStart = "10.10.$nextThirdOctet.10"
        val newEnd = "10.10.$nextThirdOctet.199"

        return Triple(newSubnet, newStart, newEnd)
    }
}
