package com.alemprator.setup.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "devices")
data class Device(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val macAddress: String, // Unique identifier checked during barcode scan
    val deviceName: String,
    val deviceType: String, // AP, Hotspot, WDS, Mesh, Client
    val lanIp: String,
    val lanNetmask: String = "255.255.255.0",
    
    // Wi-Fi basic
    val wifiSsid: String? = null,
    val wifiKey: String? = null,
    val wifiChannel: String? = null,
    
    // Advanced Radio & Channels (AP Mode)
    val wifi2gChannel: String = "auto",
    val wifi2gMode: String = "ax",
    val wifi2gWidth: String = "20",
    val wifi5gChannel: String = "36",
    val wifi5gMode: String = "ax",
    val wifi5gWidth: String = "80",
    
    // SSID advanced
    val wifi5gNameType: String = "derived", // "derived" or "custom"
    val wifi5gCustomSsid: String? = null,
    val appendIpToSsid: Boolean = false,
    val otaWindowStart: String = "2",
    val otaWindowEnd: String = "6",
    
    // VLAN
    val vlanEnabled: Boolean = false,
    val vlanId: String? = null,
    val appendIpToVlanSsid: Boolean = false,
    
    // Buttons & Maintenance
    val disableResetButton: Boolean = false,
    val resetPressDuration: String = "5",
    val disableWpsButton: Boolean = false,
    val autoRebootEnabled: Boolean = false,
    val rootPassword: String? = null,

    // Hotspot Network settings
    val hotspotWanInterface: String = "lan",
    val hotspotSubscriberInterface: String = "hotspot",
    val hotspotPrimaryIp: String = "192.168.10.1",
    val hotspotPrimaryPoolStart: String? = null,
    val hotspotPrimaryPoolEnd: String? = null,
    val hotspotPrimaryPolicy: String = "standard",
    val hotspotDnsName: String = "hotspot.local",
    val hotspotDns1: String = "8.8.8.8",
    val hotspotDns2: String = "82.114.163.31",
    val hotspotBridgeAgeingTime: String = "10",
    val hotspotCardPage: String = "both",
    val hotspotRateLimit: String = "2M/5M",
    val hotspotMacCookie: Boolean = true,
    val hotspotAvailableSpeeds: String = "1M/2M Standard\n2M/4M Fast",
    val hotspotSecondaryEnabled: Boolean = true,
    val hotspotSecondarySsid: String? = "Hotspot-2",
    val hotspotSecondaryIp: String? = "192.168.20.1",
    val hotspotTrialEnabled: Boolean = false,
    val hotspotTrialDuration: String = "30",
    val hotspotTrialUptimeLimit: String = "30",

    // Hotspot RADIUS Credentials
    val radiusServer: String = "192.168.1.2",
    val radiusServerBackup: String? = null,
    val radiusSecret: String? = null,
    val radiusAuthPort: String = "1812",
    val radiusAcctPort: String = "1813",
    val radiusNasIp: String = "192.168.1.20",
    val radiusNasId: String = "KT-KM14-102H-HOTSPOT",
    val radiusInterimUpdate: String = "60",
    val radiusCoaEnabled: Boolean = false,
    val radiusCoaPort: String = "3799",

    // REST API integration
    val restApiEnabled: Boolean = false,
    val restApiProto: String = "https",
    val restApiUsername: String = "hotspot-read",
    val restApiPassword: String? = null,

    // Portal support / Ads
    val portalSupportPhone: String? = null,
    val portalNotification: String = "أهلاً بكم في شبكتنا",
    val portalLiveEnabled: Boolean = false,
    val portalLiveUrl: String? = null,
    val portalBreakEnabled: Boolean = false,
    val portalBreakUrl: String? = null,
    val portalSpeedtestEnabled: Boolean = false,

    // Scheduled Maintenance & Autoupdate
    val maintenanceEnabled: Boolean = false,
    val maintenancePolicy: String = "free",
    val maintenanceStartTime: String = "02:00",
    val maintenanceEndTime: String = "03:00",
    val autoupdateStartTime: String = "02:00",
    val autoupdateEndTime: String = "06:00",
    
    // Station/Client Uplink/Backhaul settings
    val uplinkBand: String = "2.4GHz",
    val uplinkSsid: String? = null,
    val uplinkKey: String? = null,

    // Smart Mesh settings
    val meshBand: String = "2.4GHz",
    val meshId: String? = null,
    val meshKey: String? = null,
    val rebootHours: String = "24",
    val vlanSsid2g: String? = null,
    val vlanSsid5g: String? = null,
    val vlanSsidIpSuffix: Boolean = false,
    val hotspotSecondaryPoolStart: String? = "192.168.20.10",
    val hotspotSecondaryPoolEnd: String? = "192.168.20.199",
    val hotspotSecondaryPolicy: String = "premium",
    val hotspotMacAuthEnabled: Boolean = false,
    val hotspotMacAuthSuffix: String? = null,
    val hotspotMacAuthPassword: String? = null,
    val hotspotWalledGarden: String? = null,
    val hotspotBrowserCookieEnabled: Boolean = true,
    val hotspotBrowserCookieDays: String = "7",
    
    val timestamp: Long = System.currentTimeMillis(),
    val isTemplate: Boolean = false
)
