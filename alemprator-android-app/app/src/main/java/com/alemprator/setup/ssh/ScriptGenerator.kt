package com.alemprator.setup.ssh

import com.alemprator.setup.db.Device
import com.alemprator.setup.db.SubnetPool

class ScriptGenerator {

    fun generateCommands(device: Device, pool: SubnetPool? = null): List<String> {
        val commands = mutableListOf<String>()
        val lanGateway = deriveGateway(device.lanIp)
        val mode = normalizeMode(device.deviceType)
        val ssid2g = buildSsid(device.wifiSsid ?: "ALEMPRATOR", device)
        val ssid5g = buildPrimary5gSsid(device)

        commands.add("echo '=== بدء تهيئة جهاز الإمبراطور ==='")
        commands.ensureSection("setup.default", "setup")
        commands.set("setup.default.initial_setup_complete", "1")
        commands.set("setup.default.mode", if (mode == "hotspot") "ap" else mode)
        commands.set("setup.default.lan_ipaddr", device.lanIp)
        commands.set("setup.default.lan_netmask", device.lanNetmask)
        commands.set("setup.default.wifi_ssid", device.wifiSsid.orEmpty())
        commands.set("setup.default.wifi_ssid_5g_mode", device.wifi5gNameType)
        commands.set("setup.default.wifi_ssid_5g", device.wifi5gCustomSsid.orEmpty())
        commands.optionalSetOrDelete("setup.default.wifi_key", device.wifiKey)
        commands.set("setup.default.wifi_channel_2g", device.wifi2gChannel)
        commands.set("setup.default.wifi_mode_2g", device.wifi2gMode)
        commands.set("setup.default.wifi_width_2g", device.wifi2gWidth)
        commands.set("setup.default.wifi_channel_5g", device.wifi5gChannel)
        commands.set("setup.default.wifi_mode_5g", device.wifi5gMode)
        commands.set("setup.default.wifi_width_5g", device.wifi5gWidth)
        commands.set("setup.default.append_ip_to_ssid", bool(device.appendIpToSsid))
        commands.set("setup.default.is_vlan", bool(device.vlanEnabled))
        commands.optionalSetOrDelete("setup.default.vlan_id", device.vlanId)
        commands.set("setup.default.reset_button_disabled", bool(device.disableResetButton))
        commands.set("setup.default.reset_hold_seconds", device.resetPressDuration)
        commands.set("setup.default.wps_button_disabled", bool(device.disableWpsButton))

        commands.set("network.lan.proto", "static")
        commands.set("network.lan.ipaddr", device.lanIp)
        commands.set("network.lan.netmask", device.lanNetmask)
        if (lanGateway.isNotBlank()) commands.set("network.lan.gateway", lanGateway)

        commands.set("dhcp.lan.ignore", "1")
        commands.set("dhcp.lan.dynamicdhcp", "0")

        commands.configureRadios(device)

        when (mode) {
            "hotspot" -> commands.configureHotspotQuick(device, pool)
            "ap_wds" -> commands.configureAp(device, ssid2g, ssid5g, wds = true)
            "sta_wds" -> commands.configureStaWds(device, ssid2g, ssid5g)
            "mesh" -> commands.configureMesh(device, ssid2g, ssid5g)
            else -> commands.configureAp(device, ssid2g, ssid5g, wds = false)
        }

        if (mode != "hotspot") {
            commands.disableHotspotQuick()
            commands.configureVlan(device, ssid2g)
        } else {
            commands.removeVlan()
        }

        commands.configurePeriodicReboot(device)
        commands.configureOtaWindow(device)

        if (!device.rootPassword.isNullOrBlank()) {
            val password = sh(device.rootPassword)
            commands.add("printf '%s\\n%s\\n' $password $password | passwd root 2>/dev/null || true")
        }

        // حذف البرمجة المؤقتة (firstboot) قبل الـ commit لضمان
        // عدم وجودها في ملفات الـ UCI عند الـ commit النهائي
        commands.disableFirstbootProvisioning()

        commands.add("uci commit setup")
        commands.add("uci commit network")
        commands.add("uci commit wireless")
        commands.add("uci commit dhcp")
        commands.add("uci commit firewall 2>/dev/null || true")
        commands.add("uci commit alemprator_firstboot 2>/dev/null || true")
        commands.add("uci commit alemprator_ota 2>/dev/null || true")
        commands.add("uci commit system")
        commands.add("uci commit watchcat 2>/dev/null || true")
        commands.add("uci commit hotspot_openwrt")
        commands.add("echo '=== تطبيق التغييرات وإعادة تشغيل الخدمات ==='")

        if (mode == "hotspot") {
            commands.add("if [ -x /usr/libexec/hotspot-openwrt/apply ]; then /usr/libexec/hotspot-openwrt/apply >/tmp/hotspot-openwrt-apply.log 2>&1; fi")
        } else {
            commands.add("/usr/libexec/alemprator-setup/cleanup-hotspot --force --reload 2>/dev/null || true")
            commands.add("/etc/init.d/hotspot-openwrt stop 2>/dev/null || true")
            commands.add("wifi reload || wifi")
            commands.add("/etc/init.d/network reload")
            commands.add("/etc/init.d/dnsmasq restart 2>/dev/null || true")
        }

        commands.add("/etc/init.d/setup restart 2>/dev/null || true")
        // monitor_once لا يُستخدم مع hotspot لأنه reactivate firstboot
        if (mode != "hotspot") {
            commands.add("(sleep 1; /etc/init.d/alemprator-firstboot monitor_once) >/dev/null 2>&1 &")
        }
        return commands
    }

    fun generateRawScript(device: Device, pool: SubnetPool? = null): String {
        val header = "#!/bin/sh\n# سكريبت إعداد تلقائي لـ ${device.deviceName}\n# الماك أدرس: ${device.macAddress}\n\n"
        return header + generateCommands(device, pool).joinToString("\n")
    }

    private fun MutableList<String>.configureHotspotQuick(device: Device, pool: SubnetPool?) {
        val primaryInterface = normalizeInterface(device.hotspotSubscriberInterface, "hotspot")
        val secondaryInterface = deriveSecondaryInterface(primaryInterface)
        val primarySsid = device.wifiSsid?.takeIf { it.isNotBlank() } ?: "Hotspot-1"
        val primaryGateway = device.hotspotPrimaryIp.takeIf { it.isNotBlank() } ?: "192.168.10.1"
        val primaryPoolStart = device.hotspotPrimaryPoolStart?.takeIf { it.isNotBlank() } ?: pool?.poolStart ?: derivePoolIp(primaryGateway, "10")
        val primaryPoolEnd = device.hotspotPrimaryPoolEnd?.takeIf { it.isNotBlank() } ?: pool?.poolEnd ?: derivePoolIp(primaryGateway, "199")
        val primaryPolicy = normalizePolicy(device.hotspotPrimaryPolicy, "standard")
        val secondaryEnabled = device.hotspotSecondaryEnabled && !device.hotspotSecondarySsid.isNullOrBlank()
        val secondaryGateway = device.hotspotSecondaryIp?.takeIf { it.isNotBlank() } ?: "192.168.20.1"
        val secondaryPoolStart = device.hotspotSecondaryPoolStart?.takeIf { it.isNotBlank() } ?: derivePoolIp(secondaryGateway, "10")
        val secondaryPoolEnd = device.hotspotSecondaryPoolEnd?.takeIf { it.isNotBlank() } ?: derivePoolIp(secondaryGateway, "199")
        val loginMode = if (device.hotspotCardPage == "username") "username" else "both"
        val dnsList = listOf(device.hotspotDns1, device.hotspotDns2).map { it.trim() }.filter { it.isNotEmpty() }.joinToString(" ")
        val radiusSecret = device.radiusSecret.orEmpty()
        val radiusServer2 = device.radiusServerBackup.orEmpty()
        val walledGarden = device.hotspotWalledGarden.orEmpty()
        val restHost = device.radiusServer.trim().ifBlank { "192.168.1.2" }
        val wanInterface = normalizeInterface(device.hotspotWanInterface, "lan")

        set("setup.default.hotspot_quick_enabled", "1")
        set("setup.default.hotspot_quick_wan_interface", wanInterface)
        set("setup.default.hotspot_quick_subscriber_interface", primaryInterface)
        set("setup.default.hotspot_quick_subscriber_interface_2", secondaryInterface)
        set("setup.default.hotspot_quick_ssid_1", primarySsid)
        set("setup.default.hotspot_quick_gateway_1", primaryGateway)
        set("setup.default.hotspot_quick_pool_start_1", primaryPoolStart)
        set("setup.default.hotspot_quick_pool_end_1", primaryPoolEnd)
        set("setup.default.hotspot_quick_policy_1", primaryPolicy)
        set("setup.default.hotspot_quick_secondary_enabled", bool(secondaryEnabled))
        set("setup.default.hotspot_quick_ssid_2", device.hotspotSecondarySsid.orEmpty())
        set("setup.default.hotspot_quick_gateway_2", secondaryGateway)
        set("setup.default.hotspot_quick_pool_start_2", secondaryPoolStart)
        set("setup.default.hotspot_quick_pool_end_2", secondaryPoolEnd)
        set("setup.default.hotspot_quick_policy_2", normalizePolicy(device.hotspotSecondaryPolicy, "premium"))
        set("setup.default.hotspot_quick_radius_server", device.radiusServer)
        set("setup.default.hotspot_quick_radius_server2", radiusServer2)
        set("setup.default.hotspot_quick_radius_secret", radiusSecret)
        set("setup.default.hotspot_quick_radius_auth_port", device.radiusAuthPort)
        set("setup.default.hotspot_quick_radius_acct_port", device.radiusAcctPort)
        set("setup.default.hotspot_quick_radius_nas_ip", device.radiusNasIp)
        set("setup.default.hotspot_quick_nas_id", device.radiusNasId)
        set("setup.default.hotspot_quick_acct_interim", device.radiusInterimUpdate)
        set("setup.default.hotspot_quick_coa_enabled", bool(device.radiusCoaEnabled))
        set("setup.default.hotspot_quick_coa_port", device.radiusCoaPort)
        set("setup.default.hotspot_quick_trial_enabled", bool(device.hotspotTrialEnabled))
        set("setup.default.hotspot_quick_trial_duration", device.hotspotTrialDuration)
        set("setup.default.hotspot_quick_trial_uptime_limit", device.hotspotTrialUptimeLimit)
        set("setup.default.hotspot_quick_mac_auth_enabled", bool(device.hotspotMacAuthEnabled))
        set("setup.default.hotspot_quick_mac_auth_suffix", device.hotspotMacAuthSuffix ?: "@mac")
        set("setup.default.hotspot_quick_mac_auth_password", device.hotspotMacAuthPassword ?: "mac")
        set("setup.default.hotspot_quick_walled_garden", walledGarden)
        set("setup.default.hotspot_quick_domain", device.hotspotDnsName)
        set("setup.default.hotspot_quick_dns1", device.hotspotDns1)
        set("setup.default.hotspot_quick_dns2", device.hotspotDns2)
        set("setup.default.hotspot_quick_bridge_ageing_time", device.hotspotBridgeAgeingTime)
        set("setup.default.hotspot_quick_login_mode", loginMode)
        set("setup.default.hotspot_quick_rate_limit", device.hotspotRateLimit)
        set("setup.default.hotspot_quick_mac_cookie_enabled", bool(device.hotspotMacCookie))
        set("setup.default.hotspot_quick_available_speeds", device.hotspotAvailableSpeeds)
        set("setup.default.hotspot_quick_support_phone", device.portalSupportPhone.orEmpty())
        set("setup.default.hotspot_quick_notice_text", device.portalNotification)
        set("setup.default.hotspot_quick_live_stream_enabled", bool(device.portalLiveEnabled))
        set("setup.default.hotspot_quick_live_stream_url", device.portalLiveUrl.orEmpty())
        set("setup.default.hotspot_quick_rest_area_enabled", bool(device.portalBreakEnabled))
        set("setup.default.hotspot_quick_rest_area_url", device.portalBreakUrl.orEmpty())
        set("setup.default.hotspot_quick_speedtest_enabled", bool(device.portalSpeedtestEnabled))
        set("setup.default.hotspot_quick_maint_enabled", bool(device.maintenanceEnabled))
        set("setup.default.hotspot_quick_maint_mode", normalizeMaintenance(device.maintenancePolicy))
        set("setup.default.hotspot_quick_maint_start", device.maintenanceStartTime)
        set("setup.default.hotspot_quick_maint_end", device.maintenanceEndTime)
        set("setup.default.hotspot_quick_browser_cookie_enabled", bool(device.hotspotBrowserCookieEnabled))
        set("setup.default.hotspot_quick_browser_cookie_days", device.hotspotBrowserCookieDays)
        set("setup.default.hotspot_quick_userman_rest_enabled", bool(device.restApiEnabled))
        set("setup.default.hotspot_quick_userman_rest_scheme", device.restApiProto)
        set("setup.default.hotspot_quick_userman_rest_host", restHost)
        set("setup.default.hotspot_quick_userman_rest_port", if (device.restApiProto == "http") "80" else "443")
        set("setup.default.hotspot_quick_userman_rest_username", device.restApiUsername)
        set("setup.default.hotspot_quick_userman_rest_password", device.restApiPassword.orEmpty())
        set("setup.default.hotspot_quick_userman_rest_insecure_ssl", "0")

        set("network.hotspot_dev", "device")
        set("network.hotspot_dev.type", "bridge")
        set("network.hotspot_dev.name", "br-$primaryInterface")
        set("network.hotspot_dev.bridge_empty", "1")
        set("network.hotspot_dev.ipv6", "0")
        set("network.hotspot_dev.ageing_time", device.hotspotBridgeAgeingTime)
        set("network.hotspot", "interface")
        set("network.hotspot.proto", "static")
        set("network.hotspot.device", "br-$primaryInterface")
        set("network.hotspot.ipaddr", primaryGateway)
        set("network.hotspot.netmask", "255.255.255.0")

        if (secondaryEnabled) {
            set("network.hotspot2_dev", "device")
            set("network.hotspot2_dev.type", "bridge")
            set("network.hotspot2_dev.name", "br-$secondaryInterface")
            set("network.hotspot2_dev.bridge_empty", "1")
            set("network.hotspot2_dev.ipv6", "0")
            set("network.hotspot2_dev.ageing_time", device.hotspotBridgeAgeingTime)
            set("network.hotspot2", "interface")
            set("network.hotspot2.proto", "static")
            set("network.hotspot2.device", "br-$secondaryInterface")
            set("network.hotspot2.ipaddr", secondaryGateway)
            set("network.hotspot2.netmask", "255.255.255.0")
        } else {
            deleteIfExists("network.hotspot2_dev")
            deleteIfExists("network.hotspot2")
        }

        set("hotspot_openwrt.main.enabled", "1")
        set("hotspot_openwrt.main.wan_interface", wanInterface)
        set("hotspot_openwrt.main.subscriber_interface", primaryInterface)
        set("hotspot_openwrt.main.hotspot_ip", primaryGateway)
        set("hotspot_openwrt.main.hotspot_cidr", "24")
        set("hotspot_openwrt.main.pool_start", primaryPoolStart)
        set("hotspot_openwrt.main.pool_end", primaryPoolEnd)
        set("hotspot_openwrt.main.bridge_ageing_time", device.hotspotBridgeAgeingTime)
        set("hotspot_openwrt.main.network_name", primarySsid)
        set("hotspot_openwrt.main.domain", device.hotspotDnsName)
        set("hotspot_openwrt.main.dns", dnsList)
        set("hotspot_openwrt.main.login_mode", loginMode)
        set("hotspot_openwrt.main.rate_limit_rx_tx", device.hotspotRateLimit)
        set("hotspot_openwrt.main.mac_cookie_enabled", bool(device.hotspotMacCookie))
        set("hotspot_openwrt.main.available_speeds", device.hotspotAvailableSpeeds)
        set("hotspot_openwrt.main.support_phone", device.portalSupportPhone.orEmpty())
        set("hotspot_openwrt.main.notice_text", device.portalNotification)
        set("hotspot_openwrt.main.live_stream_enabled", bool(device.portalLiveEnabled))
        set("hotspot_openwrt.main.live_stream_url", device.portalLiveUrl.orEmpty())
        set("hotspot_openwrt.main.rest_area_enabled", bool(device.portalBreakEnabled))
        set("hotspot_openwrt.main.rest_area_url", device.portalBreakUrl.orEmpty())
        set("hotspot_openwrt.main.speedtest_enabled", bool(device.portalSpeedtestEnabled))
        set("hotspot_openwrt.main.maint_enabled", bool(device.maintenanceEnabled))
        set("hotspot_openwrt.main.maint_mode", normalizeMaintenance(device.maintenancePolicy))
        set("hotspot_openwrt.main.maint_start", device.maintenanceStartTime)
        set("hotspot_openwrt.main.maint_end", device.maintenanceEndTime)
        set("hotspot_openwrt.main.browser_cookie_enabled", bool(device.hotspotBrowserCookieEnabled))
        set("hotspot_openwrt.main.browser_cookie_days", device.hotspotBrowserCookieDays)
        set("hotspot_openwrt.main.userman_rest_enabled", bool(device.restApiEnabled))
        set("hotspot_openwrt.main.userman_rest_scheme", device.restApiProto)
        set("hotspot_openwrt.main.userman_rest_host", restHost)
        set("hotspot_openwrt.main.userman_rest_port", if (device.restApiProto == "http") "80" else "443")
        set("hotspot_openwrt.main.userman_rest_username", device.restApiUsername)
        set("hotspot_openwrt.main.userman_rest_password", device.restApiPassword.orEmpty())
        set("hotspot_openwrt.main.userman_rest_insecure_ssl", "0")
        set("hotspot_openwrt.main.quick_setup_enabled", "1")
        set("hotspot_openwrt.main.quick_no_vlan", "1")
        set("hotspot_openwrt.main.quick_wan_interface", wanInterface)
        set("hotspot_openwrt.main.quick_subscriber_interface", primaryInterface)
        set("hotspot_openwrt.main.quick_subscriber_interface_secondary", secondaryInterface)
        set("hotspot_openwrt.main.quick_runtime_dual_enabled", bool(secondaryEnabled))
        set("hotspot_openwrt.main.quick_ssid_primary", primarySsid)
        set("hotspot_openwrt.main.quick_gateway_primary", primaryGateway)
        set("hotspot_openwrt.main.quick_pool_start_primary", primaryPoolStart)
        set("hotspot_openwrt.main.quick_pool_end_primary", primaryPoolEnd)
        set("hotspot_openwrt.main.quick_policy_primary", primaryPolicy)
        set("hotspot_openwrt.main.quick_ssid_secondary", device.hotspotSecondarySsid.orEmpty())
        set("hotspot_openwrt.main.quick_gateway_secondary", secondaryGateway)
        set("hotspot_openwrt.main.quick_pool_start_secondary", secondaryPoolStart)
        set("hotspot_openwrt.main.quick_pool_end_secondary", secondaryPoolEnd)
        set("hotspot_openwrt.main.quick_policy_secondary", normalizePolicy(device.hotspotSecondaryPolicy, "premium"))
        set("hotspot_openwrt.main.radius_server", device.radiusServer)
        set("hotspot_openwrt.main.radius_server2", radiusServer2)
        set("hotspot_openwrt.main.radius_secret", radiusSecret)
        set("hotspot_openwrt.main.radius_auth_port", device.radiusAuthPort)
        set("hotspot_openwrt.main.radius_acct_port", device.radiusAcctPort)
        set("hotspot_openwrt.main.radius_nas_ip", device.radiusNasIp)
        set("hotspot_openwrt.main.radius_nas_id", device.radiusNasId)
        set("hotspot_openwrt.main.acct_interim", device.radiusInterimUpdate)
        set("hotspot_openwrt.main.coa_enabled", bool(device.radiusCoaEnabled))
        set("hotspot_openwrt.main.coa_port", device.radiusCoaPort)
        set("hotspot_openwrt.main.trial_enabled", bool(device.hotspotTrialEnabled))
        set("hotspot_openwrt.main.trial_duration", device.hotspotTrialDuration)
        set("hotspot_openwrt.main.trial_uptime_limit", device.hotspotTrialUptimeLimit)
        set("hotspot_openwrt.main.mac_auth_enabled", bool(device.hotspotMacAuthEnabled))
        set("hotspot_openwrt.main.mac_auth_suffix", device.hotspotMacAuthSuffix ?: "@mac")
        set("hotspot_openwrt.main.mac_auth_password", device.hotspotMacAuthPassword ?: "mac")
        set("hotspot_openwrt.main.walled_garden", walledGarden)

        deleteIfExists("hotspot_openwrt.radius")
        deleteIfExists("hotspot_openwrt.secondary")
        deleteIfExists("wireless.default_radio0")
        deleteIfExists("wireless.default_radio1")
        configureHotspotWireless("wizard_hotspot_quick_primary", "radio0", "hotspot", primarySsid, device)
        if (secondaryEnabled) {
            configureHotspotWireless("wizard_hotspot_quick_secondary", "radio1", "hotspot2", device.hotspotSecondarySsid ?: "Hotspot-2", device)
        } else {
            deleteIfExists("wireless.wizard_hotspot_quick_secondary")
        }
    }

    private fun MutableList<String>.configureAp(device: Device, ssid2g: String, ssid5g: String, wds: Boolean) {
        set("wireless.default_radio0", "wifi-iface")
        set("wireless.default_radio0.device", "radio0")
        set("wireless.default_radio0.mode", "ap")
        set("wireless.default_radio0.network", "lan")
        set("wireless.default_radio0.disabled", "0")
        set("wireless.default_radio0.ssid", ssid2g)
        set("wireless.default_radio0.hidden", bool(shouldHideSsid(device)))
        set("wireless.default_radio0.disassoc_low_ack", "0")
        if (wds) set("wireless.default_radio0.wds", "1") else deleteOption("wireless.default_radio0.wds")
        setWifiSecurity("wireless.default_radio0", device)

        set("wireless.default_radio1", "wifi-iface")
        set("wireless.default_radio1.device", "radio1")
        set("wireless.default_radio1.mode", "ap")
        set("wireless.default_radio1.network", "lan")
        set("wireless.default_radio1.disabled", "0")
        set("wireless.default_radio1.ssid", ssid5g)
        set("wireless.default_radio1.hidden", bool(shouldHideSsid(device)))
        set("wireless.default_radio1.disassoc_low_ack", "0")
        if (wds) set("wireless.default_radio1.wds", "1") else deleteOption("wireless.default_radio1.wds")
        setWifiSecurity("wireless.default_radio1", device)
    }

    private fun MutableList<String>.configureStaWds(device: Device, ssid2g: String, ssid5g: String) {
        val isUplink5g = device.uplinkBand == "5GHz"
        val uplinkRadio = if (isUplink5g) "radio1" else "radio0"
        val localRadio = if (isUplink5g) "radio0" else "radio1"
        val localSection = if (isUplink5g) "wireless.default_radio0" else "wireless.default_radio1"
        val localSsid = if (isUplink5g) ssid2g else ssid5g

        set("wireless.wizard_uplink", "wifi-iface")
        set("wireless.wizard_uplink.mode", "sta")
        set("wireless.wizard_uplink.wds", "1")
        set("wireless.wizard_uplink.network", "lan")
        set("wireless.wizard_uplink.device", uplinkRadio)
        set("wireless.wizard_uplink.ssid", device.uplinkSsid ?: "Uplink")
        if (device.uplinkKey.isNullOrBlank()) {
            set("wireless.wizard_uplink.encryption", "none")
            deleteOption("wireless.wizard_uplink.key")
        } else {
            set("wireless.wizard_uplink.encryption", "psk2")
            set("wireless.wizard_uplink.key", device.uplinkKey)
        }

        set("wireless.$uplinkRadio.channel", "auto")
        set(localSection, "wifi-iface")
        set("$localSection.device", localRadio)
        set("$localSection.mode", "ap")
        set("$localSection.network", "lan")
        set("$localSection.disabled", "0")
        set("$localSection.ssid", localSsid)
        set("$localSection.hidden", bool(shouldHideSsid(device)))
        set("$localSection.disassoc_low_ack", "0")
        setWifiSecurity(localSection, device)

        set("wireless.wizard_uplink_ap", "wifi-iface")
        set("wireless.wizard_uplink_ap.device", uplinkRadio)
        set("wireless.wizard_uplink_ap.mode", "ap")
        set("wireless.wizard_uplink_ap.network", "lan")
        set("wireless.wizard_uplink_ap.disabled", "0")
        set("wireless.wizard_uplink_ap.hidden", "1")
        set("wireless.wizard_uplink_ap.ssid", if (isUplink5g) ssid5g else ssid2g)
        set("wireless.wizard_uplink_ap.disassoc_low_ack", "0")
        setWifiSecurity("wireless.wizard_uplink_ap", device)

        set("wireless.${if (isUplink5g) "default_radio1" else "default_radio0"}.disabled", "1")
    }

    private fun MutableList<String>.configureMesh(device: Device, ssid2g: String, ssid5g: String) {
        val meshRadio = if (device.meshBand == "5GHz") "radio1" else "radio0"
        set("wireless.wizard_mesh", "wifi-iface")
        set("wireless.wizard_mesh.mode", "mesh")
        set("wireless.wizard_mesh.network", "lan")
        set("wireless.wizard_mesh.device", meshRadio)
        set("wireless.wizard_mesh.mesh_id", device.meshId ?: "EmpratorMesh")
        if (device.meshKey.isNullOrBlank()) {
            set("wireless.wizard_mesh.encryption", "none")
            deleteOption("wireless.wizard_mesh.key")
        } else {
            set("wireless.wizard_mesh.encryption", "psk2")
            set("wireless.wizard_mesh.key", device.meshKey)
        }
        if (!device.vlanEnabled) {
            configureAp(device, ssid2g, ssid5g, wds = false)
        }
    }

    private fun MutableList<String>.configureVlan(device: Device, ssid2g: String) {
        if (!device.vlanEnabled || device.vlanId.isNullOrBlank()) {
            removeVlan()
            return
        }

        val vlanId = device.vlanId
        val suffix = if (device.vlanSsidIpSuffix || device.appendIpToVlanSsid) "_${device.lanIp.substringAfterLast('.')}" else ""
        val baseVlanSsid = device.vlanSsid2g?.takeIf { it.isNotBlank() } ?: "${ssid2g}_VLAN"
        val vlanSsid2g = baseVlanSsid + suffix
        val vlanSsid5g = device.vlanSsid5g?.takeIf { it.isNotBlank() }?.let { it + suffix } ?: "${baseVlanSsid}${suffix}_5G"

        set("network.wizard_vlan_dev", "device")
        set("network.wizard_vlan_dev.type", "8021q")
        set("network.wizard_vlan_dev.ifname", "br-lan")
        set("network.wizard_vlan_dev.vid", vlanId)
        set("network.wizard_vlan_dev.name", "br-lan.$vlanId")
        set("network.wizard_vlan_bridge", "device")
        set("network.wizard_vlan_bridge.type", "bridge")
        set("network.wizard_vlan_bridge.name", "vlan_$vlanId")
        set("network.wizard_vlan_bridge.bridge_empty", "1")
        set("network.wizard_vlan_bridge.ipv6", "0")
        set("network.wizard_vlan_bridge.ports", "br-lan.$vlanId")
        set("network.wizard_vlan_bridge.ageing_time", "10")
        set("network.wizardvlan", "interface")
        set("network.wizardvlan.proto", "none")
        set("network.wizardvlan.device", "vlan_$vlanId")
        deleteIfExists("dhcp.wizardvlan")

        configureVlanWireless("wizard_vlan_radio0_ap", "radio0", vlanSsid2g, device)
        configureVlanWireless("wizard_vlan_radio1_ap", "radio1", vlanSsid5g, device)
    }

    private fun MutableList<String>.removeVlan() {
        deleteIfExists("network.wizard_vlan_dev")
        deleteIfExists("network.wizard_vlan_bridge")
        deleteIfExists("network.wizardvlan")
        deleteIfExists("wireless.wizard_vlan_radio0_ap")
        deleteIfExists("wireless.wizard_vlan_radio1_ap")
        deleteIfExists("dhcp.wizardvlan")
    }

    private fun MutableList<String>.disableHotspotQuick() {
        set("setup.default.hotspot_quick_enabled", "0")
        set("hotspot_openwrt.main.enabled", "0")
        set("hotspot_openwrt.main.quick_setup_enabled", "0")
        set("hotspot_openwrt.main.quick_runtime_dual_enabled", "0")
        deleteIfExists("network.hotspot_dev")
        deleteIfExists("network.hotspot")
        deleteIfExists("network.hotspot2_dev")
        deleteIfExists("network.hotspot2")
        deleteIfExists("wireless.wizard_hotspot_quick_primary")
        deleteIfExists("wireless.wizard_hotspot_quick_secondary")
    }

    private fun MutableList<String>.disableFirstbootProvisioning() {
        // حذف أقسام البرمجة المؤقتة من UCI (دون commit — الـ commit سيتم في النهاية)
        add("uci -q delete network.alemprator_setup 2>/dev/null || true")
        add("uci -q delete dhcp.alemprator_setup 2>/dev/null || true")
        add("uci -q delete dhcp.alemprator_captive 2>/dev/null || true")
        add("uci -q delete firewall.alemprator_setup 2>/dev/null || true")
        add("uci -q delete wireless.alemprator_firstboot 2>/dev/null || true")
        add("for s in \$(uci show wireless 2>/dev/null | grep \"network='alemprator_setup'\" | cut -d. -f2 | cut -d= -f1); do uci -q delete wireless.\$s 2>/dev/null || true; done")
        add("for s in \$(uci show wireless 2>/dev/null | grep -i -E \"ssid='(ALemprator-KT-|KT-)\" | cut -d. -f2 | cut -d= -f1); do uci -q delete wireless.\$s 2>/dev/null || true; done")
        add("uci -q delete dhcp.@dnsmasq[0].address 2>/dev/null || true")
        add("uci -q del_list uhttpd.main.lua_prefix='/hotspot-detect.html=/www/captive-portal.html' 2>/dev/null || true")
        add("uci -q set alemprator_firstboot.main.enabled='0' 2>/dev/null || true")
        add("uci -q set alemprator_firstboot.main.configured_once='1' 2>/dev/null || true")
        add("uci -q set alemprator_firstboot.main.auto_cleanup_armed='0' 2>/dev/null || true")
        add("uci -q set alemprator_firstboot.main.auto_cleanup_pending='0' 2>/dev/null || true")
        // تنظيف ملفات ومجلدات البرمجة المؤقتة
        add("rm -f /etc/alemprator-firstboot-pending /tmp/alemprator-firstboot-cleanup.token /etc/alemprator-firstboot-baseline.md5 /www/hotspot-detect.html /www/generate_204 /www/ncsi.txt 2>/dev/null || true")
        add("nft flush chain inet fw4 alemprator_captive 2>/dev/null || true")
        add("nft delete chain inet fw4 alemprator_captive 2>/dev/null || true")
        add("touch /etc/configured 2>/dev/null || true")
        add("/etc/init.d/uhttpd reload 2>/dev/null || true")
    }

    private fun MutableList<String>.configureRadios(device: Device) {
        set("wireless.radio0.channel", device.wifi2gChannel)
        set("wireless.radio0.hwmode", "11g")
        set("wireless.radio0.htmode", htmode2g(device))
        set("wireless.radio1.channel", device.wifi5gChannel)
        set("wireless.radio1.hwmode", "11a")
        set("wireless.radio1.htmode", htmode5g(device))
    }

    private fun MutableList<String>.configurePeriodicReboot(device: Device) {
        if (device.autoRebootEnabled) {
            set("system.autoreboot", "1")
            set("watchcat.alemprator_periodic_reboot", "watchcat")
            set("watchcat.alemprator_periodic_reboot.mode", "periodic_reboot")
            set("watchcat.alemprator_periodic_reboot.period", "${device.rebootHours}h")
        } else {
            set("system.autoreboot", "0")
            deleteIfExists("watchcat.alemprator_periodic_reboot")
        }
    }

    private fun MutableList<String>.configureOtaWindow(device: Device) {
        val start = device.otaWindowStart.toIntOrNull()?.coerceIn(0, 23) ?: 2
        val end = device.otaWindowEnd.toIntOrNull()?.coerceIn(0, 23) ?: 6
        ensureSection("alemprator_ota.main", "ota")
        set("alemprator_ota.main.window_start", start.toString())
        set("alemprator_ota.main.window_end", end.toString())
    }

    private fun MutableList<String>.configureHotspotWireless(section: String, radio: String, network: String, ssid: String, device: Device) {
        set("wireless.$section", "wifi-iface")
        set("wireless.$section.device", radio)
        set("wireless.$section.mode", "ap")
        set("wireless.$section.network", network)
        set("wireless.$section.disabled", "0")
        set("wireless.$section.ssid", ssid)
        set("wireless.$section.hidden", bool(shouldHideSsid(device)))
        set("wireless.$section.isolate", "1")
        set("wireless.$section.disassoc_low_ack", "0")
        setWifiSecurity("wireless.$section", device)
    }

    private fun MutableList<String>.configureVlanWireless(section: String, radio: String, ssid: String, device: Device) {
        set("wireless.$section", "wifi-iface")
        set("wireless.$section.device", radio)
        set("wireless.$section.mode", "ap")
        set("wireless.$section.network", "wizardvlan")
        set("wireless.$section.disabled", "0")
        set("wireless.$section.ssid", ssid)
        set("wireless.$section.isolate", "1")
        set("wireless.$section.disassoc_low_ack", "0")
        setWifiSecurity("wireless.$section", device)
    }

    private fun MutableList<String>.setWifiSecurity(section: String, device: Device) {
        if (device.wifiKey.isNullOrBlank()) {
            set("$section.encryption", "none")
            deleteOption("$section.key")
        } else {
            set("$section.encryption", "psk2")
            set("$section.key", device.wifiKey)
        }
    }

    private fun MutableList<String>.ensureSection(key: String, type: String) {
        add("uci -q get $key >/dev/null || uci set $key=$type")
    }

    private fun MutableList<String>.set(key: String, value: String) {
        add("uci set $key=${sh(value)}")
    }

    private fun MutableList<String>.optionalSetOrDelete(key: String, value: String?) {
        if (value.isNullOrBlank()) deleteOption(key) else set(key, value)
    }

    private fun MutableList<String>.deleteIfExists(key: String) {
        add("if uci -q get $key >/dev/null; then uci -q delete $key; fi")
    }

    private fun MutableList<String>.deleteOption(key: String) {
        add("uci -q delete $key 2>/dev/null || true")
    }

    private fun sh(value: String): String = "'" + value.replace("'", "'\"'\"'") + "'"

    private fun bool(value: Boolean): String = if (value) "1" else "0"

    private fun shouldHideSsid(device: Device): Boolean = when (normalizeMode(device.deviceType)) {
        "sta_wds" -> true
        "ap_wds" -> device.vlanEnabled
        "mesh" -> !device.vlanEnabled
        else -> false
    }

    private fun normalizeMode(value: String): String = when (value) {
        "hotspot", "ap_wds", "sta_wds", "mesh" -> value
        else -> "ap"
    }

    private fun normalizeInterface(value: String, fallback: String): String {
        val normalized = value.trim()
        return if (Regex("^[A-Za-z0-9_][A-Za-z0-9_.-]*$").matches(normalized)) normalized else fallback
    }

    private fun normalizePolicy(value: String, fallback: String): String {
        return if (value in setOf("standard", "premium", "guest", "staff", "trial")) value else fallback
    }

    private fun normalizeMaintenance(value: String): String = if (value == "block") "block" else "free"

    private fun deriveSecondaryInterface(primary: String): String {
        val candidate = "${primary}2"
        val normalized = normalizeInterface(candidate, "hotspot2")
        return if (normalized == primary) "hotspot2" else normalized
    }

    private fun deriveGateway(ip: String): String {
        val parts = ip.split('.')
        return if (parts.size == 4) "${parts[0]}.${parts[1]}.${parts[2]}.1" else ""
    }

    private fun derivePoolIp(gateway: String, host: String): String {
        val parts = gateway.split('.')
        return if (parts.size == 4) "${parts[0]}.${parts[1]}.${parts[2]}.$host" else "192.168.10.$host"
    }

    private fun buildSsid(base: String, device: Device): String {
        val suffix = if (device.appendIpToSsid) "_${device.lanIp.substringAfterLast('.')}" else ""
        return base + suffix
    }

    private fun buildPrimary5gSsid(device: Device): String {
        val custom5g = device.wifi5gCustomSsid?.takeIf { device.wifi5gNameType == "custom" && it.isNotBlank() }
        val base = custom5g ?: (device.wifiSsid ?: "ALEMPRATOR")
        return buildSsid(base, device) + if (custom5g == null) "_5G" else ""
    }

    private fun htmode2g(device: Device): String = when (device.wifi2gMode) {
        "n" -> "HT${device.wifi2gWidth}"
        else -> "HE${device.wifi2gWidth}"
    }

    private fun htmode5g(device: Device): String = when (device.wifi5gMode) {
        "ax" -> "HE${device.wifi5gWidth}"
        "ac" -> "VHT${device.wifi5gWidth}"
        "n" -> "HT${device.wifi5gWidth}"
        else -> "HE${device.wifi5gWidth}"
    }
}
