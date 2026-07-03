package com.alemprator.setup.db

import androidx.room.*

@Dao
interface DeviceDao {
    @Query("SELECT * FROM devices ORDER BY timestamp DESC")
    suspend fun getAllDevices(): List<Device>

    @Query("SELECT * FROM devices WHERE macAddress = :mac LIMIT 1")
    suspend fun getDeviceByMac(mac: String): Device?

    @Query("SELECT * FROM devices WHERE lanIp = :ip LIMIT 1")
    suspend fun getDeviceByIp(ip: String): Device?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDevice(device: Device)

    @Delete
    suspend fun deleteDevice(device: Device)

    // Subnet pool queries
    @Query("SELECT * FROM subnet_pools")
    suspend fun getAllSubnetPools(): List<SubnetPool>

    @Query("SELECT * FROM subnet_pools WHERE poolNetwork = :network LIMIT 1")
    suspend fun getPoolByNetwork(network: String): SubnetPool?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSubnetPool(pool: SubnetPool)
}
