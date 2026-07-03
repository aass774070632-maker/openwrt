package com.alemprator.setup.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "subnet_pools")
data class SubnetPool(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val deviceMac: String, // Associated device MAC
    val poolNetwork: String, // e.g. 10.10.10.0/24
    val poolStart: String, // e.g. 10.10.10.10
    val poolEnd: String, // e.g. 10.10.10.254
    val timestamp: Long = System.currentTimeMillis()
)
