package com.alemprator.setup.logic

import com.alemprator.setup.db.DeviceDao
import com.alemprator.setup.db.Device
import com.alemprator.setup.db.SubnetPool

class IPValidationEngine(private val deviceDao: DeviceDao) {

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
