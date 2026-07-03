package com.alemprator.setup.ssh

import com.alemprator.setup.db.Device
import com.alemprator.setup.db.SubnetPool

class ScriptGenerator {

    /**
     * Generates a list of shell commands based on the chosen device configuration mode.
     */
    fun generateCommands(device: Device, pool: SubnetPool? = null): List<String> {
        val commands = mutableListOf<String>()
        
        commands.add("echo '=== بدء تهيئة جهاز الإمبراطور ==='")
        
        // 1. Configure basic LAN IP, mask, and derive gateway
        val lanGateway = if (device.lanIp.contains(".")) {
            val parts = device.lanIp.split(".")
            if (parts.size == 4) "${parts[0]}.${parts[1]}.${parts[2]}.1" else ""
        } else ""

        val htmode2g = when (device.wifi2gMode) {
            "n" -> "HT${device.wifi2gWidth}"
            else -> "HE${device.wifi2gWidth}"
        }
        val htmode5g = when (device.wifi5gMode) {
            "ax" -> "HE${device.wifi5gWidth}"
            "ac" -> "VHT${device.wifi5gWidth}"
            "n" -> "HT${device.wifi5gWidth}"
            else -> "HE${device.wifi5gWidth}"
        }

        commands.add("uci set network.lan.ipaddr='${device.lanIp}'")
        commands.add("uci set network.lan.proto='static'")
        if (lanGateway.isNotEmpty()) {
            commands.add("uci set network.lan.gateway='$lanGateway'")
        }
        
        // 2. Mode-specific configurations
        when (device.deviceType) {
            "ap" -> {
                commands.add("uci set setup.default.mode='ap'")
                commands.add("uci set hotspot_openwrt.main.enabled='0'")
                
                // 1. Radio 2G & 5G Channels and Modes
                commands.add("uci set wireless.radio0.channel='${device.wifi2gChannel}'")
                commands.add("uci set wireless.radio0.hwmode='11g'")
                commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                
                commands.add("uci set wireless.radio1.channel='${device.wifi5gChannel}'")
                commands.add("uci set wireless.radio1.hwmode='11a'")
                commands.add("uci set wireless.radio1.htmode='$htmode5g'")
                
                // 2. SSIDs
                val suffix = if (device.appendIpToSsid) "_${device.lanIp.substringAfterLast(".")}" else ""
                val ssid2g = "${device.wifiSsid ?: "ALEMPRATOR"}$suffix"
                val ssid5gBase = if (device.wifi5gNameType == "custom" && !device.wifi5gCustomSsid.isNullOrEmpty()) device.wifi5gCustomSsid else (device.wifiSsid ?: "ALEMPRATOR")
                val ssid5g = "$ssid5gBase$suffix"
                
                commands.add("uci set wireless.default_radio0.ssid='$ssid2g'")
                commands.add("uci set wireless.default_radio1.ssid='$ssid5g'")
                commands.add("if uci -q get wireless.default_radio0.isolate; then uci -q delete wireless.default_radio0.isolate; fi")
                commands.add("if uci -q get wireless.default_radio1.isolate; then uci -q delete wireless.default_radio1.isolate; fi")
                
                // 3. Security
                if (device.noPassword) {
                    commands.add("uci set wireless.default_radio0.encryption='none'")
                    commands.add("uci set wireless.default_radio1.encryption='none'")
                    commands.add("if uci -q get wireless.default_radio0.key; then uci -q delete wireless.default_radio0.key; fi")
                    commands.add("if uci -q get wireless.default_radio1.key; then uci -q delete wireless.default_radio1.key; fi")
                } else {
                    device.wifiKey?.let {
                        commands.add("uci set wireless.default_radio0.encryption='psk2'")
                        commands.add("uci set wireless.default_radio0.key='$it'")
                        commands.add("uci set wireless.default_radio1.encryption='psk2'")
                        commands.add("uci set wireless.default_radio1.key='$it'")
                    }
                }
                // Unset WDS on standard AP interfaces
                commands.add("if uci -q get wireless.default_radio0.wds; then uci -q delete wireless.default_radio0.wds; fi")
                commands.add("if uci -q get wireless.default_radio1.wds; then uci -q delete wireless.default_radio1.wds; fi")
            }
            "hotspot" -> {
                commands.add("uci set setup.default.mode='ap'")
                commands.add("uci set setup.default.hotspot_quick_enabled='1'")
                commands.add("uci set hotspot_openwrt.main.quick_setup_enabled='1'")
                commands.add("uci set hotspot_openwrt.main.enabled='1'")
                
                // 1. Radio Channels
                commands.add("uci set wireless.radio0.channel='${device.wifi2gChannel}'")
                commands.add("uci set wireless.radio1.channel='${device.wifi5gChannel}'")
                commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                commands.add("uci set wireless.radio1.htmode='$htmode5g'")

                // Disable standard AP interfaces
                commands.add("if uci -q get wireless.default_radio0; then uci set wireless.default_radio0.disabled='1'; fi")
                commands.add("if uci -q get wireless.default_radio1; then uci set wireless.default_radio1.disabled='1'; fi")

                // Primary Hotspot Settings
                commands.add("uci set setup.default.hotspot_quick_ssid_1='${device.wifiSsid ?: "Hotspot-1"}'")
                commands.add("uci set setup.default.hotspot_quick_gateway_1='${device.lanIp}'")
                commands.add("uci set setup.default.hotspot_quick_policy_1='standard'")
                commands.add("uci set hotspot_openwrt.main.quick_policy_primary='standard'")
                commands.add("uci set hotspot_openwrt.main.network_name='${device.wifiSsid ?: "Hotspot-1"}'")
                commands.add("uci set hotspot_openwrt.main.hotspot_ip='${device.lanIp}'")
                commands.add("uci set hotspot_openwrt.main.dns_name='${device.hotspotDnsName}'")
                commands.add("uci set hotspot_openwrt.main.domain='${device.hotspotDnsName}'")
                commands.add("uci set setup.default.hotspot_quick_domain='${device.hotspotDnsName}'")
                commands.add("uci set hotspot_openwrt.main.card_page='${device.hotspotCardPage}'")
                commands.add("uci set hotspot_openwrt.main.login_mode='${device.hotspotCardPage}'")
                commands.add("uci set setup.default.hotspot_quick_login_mode='${device.hotspotCardPage}'")
                commands.add("uci set hotspot_openwrt.main.rate_limit_rx_tx='${device.hotspotRateLimit}'")
                commands.add("uci set setup.default.hotspot_quick_rate_limit='${device.hotspotRateLimit}'")
                commands.add("uci set hotspot_openwrt.main.mac_cookie_enabled='${if (device.hotspotMacCookie) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_mac_cookie_enabled='${if (device.hotspotMacCookie) "1" else "0"}'")

                if (pool != null) {
                    commands.add("uci set setup.default.hotspot_quick_pool_start_1='${pool.poolStart}'")
                    commands.add("uci set setup.default.hotspot_quick_pool_end_1='${pool.poolEnd}'")
                    commands.add("uci set hotspot_openwrt.main.pool_start='${pool.poolStart}'")
                    commands.add("uci set hotspot_openwrt.main.pool_end='${pool.poolEnd}'")
                }

                // Primary wireless interface
                commands.add("uci set wireless.wizard_hotspot_quick_primary='wifi-iface'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.device='radio0'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.mode='ap'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.network='hotspot'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.disabled='0'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.ssid='${device.wifiSsid ?: "Hotspot-1"}'")
                commands.add("uci set wireless.wizard_hotspot_quick_primary.encryption='none'")

                // 2. Secondary Network (optional)
                if (device.hotspotSecondaryEnabled && !device.hotspotSecondarySsid.isNullOrEmpty()) {
                    commands.add("uci set setup.default.hotspot_quick_secondary_enabled='1'")
                    commands.add("uci set hotspot_openwrt.main.quick_runtime_dual_enabled='1'")
                    commands.add("uci set hotspot_openwrt.secondary.enabled='1'")
                    commands.add("uci set hotspot_openwrt.secondary.network_name='${device.hotspotSecondarySsid}'")
                    commands.add("uci set setup.default.hotspot_quick_ssid_2='${device.hotspotSecondarySsid}'")
                    
                    val secIp = device.hotspotSecondaryIp ?: "192.168.20.1"
                    commands.add("uci set hotspot_openwrt.secondary.hotspot_ip='$secIp'")
                    commands.add("uci set setup.default.hotspot_quick_gateway_2='$secIp'")
                    
                    val secStart = device.hotspotSecondaryPoolStart ?: "192.168.20.10"
                    commands.add("uci set hotspot_openwrt.secondary.pool_start='$secStart'")
                    commands.add("uci set setup.default.hotspot_quick_pool_start_2='$secStart'")
                    
                    val secEnd = device.hotspotSecondaryPoolEnd ?: "192.168.20.199"
                    commands.add("uci set hotspot_openwrt.secondary.pool_end='$secEnd'")
                    commands.add("uci set setup.default.hotspot_quick_pool_end_2='$secEnd'")
                    
                    commands.add("uci set hotspot_openwrt.secondary.quick_policy_secondary='${device.hotspotSecondaryPolicy}'")
                    commands.add("uci set setup.default.hotspot_quick_policy_2='${device.hotspotSecondaryPolicy}'")

                    // Secondary wireless interface
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary='wifi-iface'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.device='radio1'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.mode='ap'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.network='hotspot2'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.disabled='0'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.ssid='${device.hotspotSecondarySsid}'")
                    commands.add("uci set wireless.wizard_hotspot_quick_secondary.encryption='none'")
                } else {
                    commands.add("uci set setup.default.hotspot_quick_secondary_enabled='0'")
                    commands.add("uci set hotspot_openwrt.main.quick_runtime_dual_enabled='0'")
                    commands.add("uci set hotspot_openwrt.secondary.enabled='0'")
                    commands.add("if uci -q get wireless.wizard_hotspot_quick_secondary; then uci -q delete wireless.wizard_hotspot_quick_secondary; fi")
                }

                // 3. Trial settings
                if (device.hotspotTrialEnabled) {
                    commands.add("uci set hotspot_openwrt.trial.enabled='1'")
                    commands.add("uci set setup.default.hotspot_quick_trial_enabled='1'")
                    commands.add("uci set hotspot_openwrt.trial.duration='${device.hotspotTrialDuration}'")
                    commands.add("uci set setup.default.hotspot_quick_trial_duration='${device.hotspotTrialDuration}'")
                    commands.add("uci set hotspot_openwrt.trial.uptime_limit='${device.hotspotTrialUptimeLimit}'")
                    commands.add("uci set setup.default.hotspot_quick_trial_uptime_limit='${device.hotspotTrialUptimeLimit}'")
                } else {
                    commands.add("uci set hotspot_openwrt.trial.enabled='0'")
                    commands.add("uci set setup.default.hotspot_quick_trial_enabled='0'")
                }

                // 4. RADIUS server credentials
                commands.add("uci set hotspot_openwrt.radius.server='${device.radiusServer}'")
                commands.add("uci set setup.default.hotspot_quick_radius_server='${device.radiusServer}'")
                device.radiusServerBackup?.let {
                    commands.add("uci set hotspot_openwrt.radius.server_backup='$it'")
                    commands.add("uci set setup.default.hotspot_quick_radius_server2='$it'")
                }
                device.radiusSecret?.let {
                    commands.add("uci set hotspot_openwrt.radius.secret='$it'")
                    commands.add("uci set setup.default.hotspot_quick_radius_secret='$it'")
                }
                commands.add("uci set hotspot_openwrt.radius.auth_port='${device.radiusAuthPort}'")
                commands.add("uci set setup.default.hotspot_quick_radius_auth_port='${device.radiusAuthPort}'")
                commands.add("uci set hotspot_openwrt.radius.acct_port='${device.radiusAcctPort}'")
                commands.add("uci set setup.default.hotspot_quick_radius_acct_port='${device.radiusAcctPort}'")
                commands.add("uci set hotspot_openwrt.radius.nas_ip='${device.radiusNasIp}'")
                commands.add("uci set setup.default.hotspot_quick_radius_nas_ip='${device.radiusNasIp}'")
                commands.add("uci set hotspot_openwrt.radius.nas_id='${device.radiusNasId}'")
                commands.add("uci set setup.default.hotspot_quick_nas_id='${device.radiusNasId}'")
                commands.add("uci set hotspot_openwrt.radius.interim_update='${device.radiusInterimUpdate}'")
                commands.add("uci set setup.default.hotspot_quick_acct_interim='${device.radiusInterimUpdate}'")
                commands.add("uci set hotspot_openwrt.radius.coa_enabled='${if (device.radiusCoaEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_coa_enabled='${if (device.radiusCoaEnabled) "1" else "0"}'")
                commands.add("uci set hotspot_openwrt.radius.coa_port='${device.radiusCoaPort}'")
                commands.add("uci set setup.default.hotspot_quick_coa_port='${device.radiusCoaPort}'")

                // MAC Authentication
                commands.add("uci set hotspot_openwrt.main.mac_auth_enabled='${if (device.hotspotMacAuthEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_mac_auth_enabled='${if (device.hotspotMacAuthEnabled) "1" else "0"}'")
                commands.add("uci set hotspot_openwrt.main.mac_auth_suffix='${device.hotspotMacAuthSuffix ?: "@mac"}'")
                commands.add("uci set setup.default.hotspot_quick_mac_auth_suffix='${device.hotspotMacAuthSuffix ?: "@mac"}'")
                commands.add("uci set hotspot_openwrt.main.mac_auth_password='${device.hotspotMacAuthPassword ?: "mac"}'")
                commands.add("uci set setup.default.hotspot_quick_mac_auth_password='${device.hotspotMacAuthPassword ?: "mac"}'")

                // Walled Garden
                commands.add("uci set hotspot_openwrt.main.walled_garden='${device.hotspotWalledGarden ?: ""}'")
                commands.add("uci set setup.default.hotspot_quick_walled_garden='${device.hotspotWalledGarden ?: ""}'")

                // 5. REST API (Userman Rest)
                commands.add("uci set hotspot_openwrt.main.userman_rest_enabled='${if (device.restApiEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_userman_rest_enabled='${if (device.restApiEnabled) "1" else "0"}'")
                commands.add("uci set hotspot_openwrt.main.userman_rest_scheme='${device.restApiProto}'")
                commands.add("uci set setup.default.hotspot_quick_userman_rest_scheme='${device.restApiProto}'")
                commands.add("uci set hotspot_openwrt.main.userman_rest_username='${device.restApiUsername}'")
                commands.add("uci set setup.default.hotspot_quick_userman_rest_username='${device.restApiUsername}'")
                device.restApiPassword?.let {
                    commands.add("uci set hotspot_openwrt.main.userman_rest_password='$it'")
                    commands.add("uci set setup.default.hotspot_quick_userman_rest_password='$it'")
                }

                // 5.5 Browser Cookies
                commands.add("uci set hotspot_openwrt.main.browser_cookie_enabled='${if (device.hotspotBrowserCookieEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_browser_cookie_enabled='${if (device.hotspotBrowserCookieEnabled) "1" else "0"}'")
                commands.add("uci set hotspot_openwrt.main.browser_cookie_days='${device.hotspotBrowserCookieDays}'")
                commands.add("uci set setup.default.hotspot_quick_browser_cookie_days='${device.hotspotBrowserCookieDays}'")

                // 6. Portal & Support Phones
                device.portalSupportPhone?.let {
                    commands.add("uci set hotspot_openwrt.main.support_phone='$it'")
                    commands.add("uci set setup.default.hotspot_quick_support_phone='$it'")
                }
                commands.add("uci set hotspot_openwrt.main.notice_text='${device.portalNotification}'")
                commands.add("uci set setup.default.hotspot_quick_notice_text='${device.portalNotification}'")
                commands.add("uci set hotspot_openwrt.main.live_stream_enabled='${if (device.portalLiveEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_live_stream_enabled='${if (device.portalLiveEnabled) "1" else "0"}'")
                device.portalLiveUrl?.let {
                    commands.add("uci set hotspot_openwrt.main.live_stream_url='$it'")
                    commands.add("uci set setup.default.hotspot_quick_live_stream_url='$it'")
                }
                commands.add("uci set hotspot_openwrt.main.rest_area_enabled='${if (device.portalBreakEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_rest_area_enabled='${if (device.portalBreakEnabled) "1" else "0"}'")
                device.portalBreakUrl?.let {
                    commands.add("uci set hotspot_openwrt.main.rest_area_url='$it'")
                    commands.add("uci set setup.default.hotspot_quick_rest_area_url='$it'")
                }
                commands.add("uci set hotspot_openwrt.main.speedtest_enabled='${if (device.portalSpeedtestEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_speedtest_enabled='${if (device.portalSpeedtestEnabled) "1" else "0"}'")

                // 7. Scheduled maintenance & autoupdate
                commands.add("uci set hotspot_openwrt.main.maint_enabled='${if (device.maintenanceEnabled) "1" else "0"}'")
                commands.add("uci set setup.default.hotspot_quick_maint_enabled='${if (device.maintenanceEnabled) "1" else "0"}'")
                commands.add("uci set hotspot_openwrt.main.maint_mode='${device.maintenancePolicy}'")
                commands.add("uci set setup.default.hotspot_quick_maint_mode='${device.maintenancePolicy}'")
                commands.add("uci set hotspot_openwrt.main.maint_start='${device.maintenanceStartTime}'")
                commands.add("uci set setup.default.hotspot_quick_maint_start='${device.maintenanceStartTime}'")
                commands.add("uci set hotspot_openwrt.main.maint_end='${device.maintenanceEndTime}'")
                commands.add("uci set setup.default.hotspot_quick_maint_end='${device.maintenanceEndTime}'")

                commands.add("uci set system.autoupdate.start_time='${device.autoupdateStartTime}'")
                commands.add("uci set system.autoupdate.end_time='${device.autoupdateEndTime}'")
            }
            "ap_wds" -> {
                commands.add("uci set setup.default.mode='ap_wds'")
                commands.add("uci set hotspot_openwrt.main.enabled='0'")
                
                // Enable WDS mode on the AP interface
                commands.add("uci set wireless.default_radio0.wds='1'")
                commands.add("uci set wireless.default_radio1.wds='1'")
                
                // 1. Radio 2G & 5G Channels and Modes
                commands.add("uci set wireless.radio0.channel='${device.wifi2gChannel}'")
                commands.add("uci set wireless.radio0.hwmode='11g'")
                commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                
                commands.add("uci set wireless.radio1.channel='${device.wifi5gChannel}'")
                commands.add("uci set wireless.radio1.hwmode='11a'")
                commands.add("uci set wireless.radio1.htmode='$htmode5g'")
                
                // 2. SSIDs
                val suffix = if (device.appendIpToSsid) "_${device.lanIp.substringAfterLast(".")}" else ""
                val ssid2g = "${device.wifiSsid ?: "ALEMPRATOR"}$suffix"
                val ssid5gBase = if (device.wifi5gNameType == "custom" && !device.wifi5gCustomSsid.isNullOrEmpty()) device.wifi5gCustomSsid else (device.wifiSsid ?: "ALEMPRATOR")
                val ssid5g = "$ssid5gBase$suffix"
                
                commands.add("uci set wireless.default_radio0.ssid='$ssid2g'")
                commands.add("uci set wireless.default_radio1.ssid='$ssid5g'")
                commands.add("if uci -q get wireless.default_radio0.isolate; then uci -q delete wireless.default_radio0.isolate; fi")
                commands.add("if uci -q get wireless.default_radio1.isolate; then uci -q delete wireless.default_radio1.isolate; fi")
                
                // 3. Security
                if (device.noPassword) {
                    commands.add("uci set wireless.default_radio0.encryption='none'")
                    commands.add("uci set wireless.default_radio1.encryption='none'")
                    commands.add("if uci -q get wireless.default_radio0.key; then uci -q delete wireless.default_radio0.key; fi")
                    commands.add("if uci -q get wireless.default_radio1.key; then uci -q delete wireless.default_radio1.key; fi")
                } else {
                    device.wifiKey?.let {
                        commands.add("uci set wireless.default_radio0.encryption='psk2'")
                        commands.add("uci set wireless.default_radio0.key='$it'")
                        commands.add("uci set wireless.default_radio1.encryption='psk2'")
                        commands.add("uci set wireless.default_radio1.key='$it'")
                    }
                }
            }
            "sta_wds" -> {
                commands.add("uci set setup.default.mode='sta_wds'")
                commands.add("uci set hotspot_openwrt.main.enabled='0'")
                
                // 1. Configure the Uplink Client interface (wizard_uplink)
                commands.add("uci set wireless.wizard_uplink='wifi-iface'")
                commands.add("uci set wireless.wizard_uplink.mode='sta'")
                commands.add("uci set wireless.wizard_uplink.wds='1'")
                commands.add("uci set wireless.wizard_uplink.network='lan'")
                
                val isUplink5g = device.uplinkBand == "5GHz"
                val uplinkDevice = if (isUplink5g) "radio1" else "radio0"
                
                commands.add("uci set wireless.wizard_uplink.device='$uplinkDevice'")
                commands.add("uci set wireless.wizard_uplink.ssid='${device.uplinkSsid ?: "Uplink"}'")
                
                if (device.uplinkKey.isNullOrEmpty()) {
                    commands.add("uci set wireless.wizard_uplink.encryption='none'")
                    commands.add("if uci -q get wireless.wizard_uplink.key; then uci -q delete wireless.wizard_uplink.key; fi")
                } else {
                    commands.add("uci set wireless.wizard_uplink.encryption='psk2'")
                    commands.add("uci set wireless.wizard_uplink.key='${device.uplinkKey}'")
                }

                // 2. Configure Local Re-broadcasting AP on the uplink radio (wizard_uplink_ap)
                commands.add("uci set wireless.wizard_uplink_ap='wifi-iface'")
                commands.add("uci set wireless.wizard_uplink_ap.device='$uplinkDevice'")
                commands.add("uci set wireless.wizard_uplink_ap.mode='ap'")
                commands.add("uci set wireless.wizard_uplink_ap.network='lan'")
                commands.add("if uci -q get wireless.wizard_uplink_ap.isolate; then uci -q delete wireless.wizard_uplink_ap.isolate; fi")
                commands.add("uci set wireless.wizard_uplink_ap.disassoc_low_ack='0'")
                commands.add("uci set wireless.wizard_uplink_ap.hidden='1'")
                
                // 3. Radio channels & modes
                // Uplink radio channel MUST be auto
                commands.add("uci set wireless.$uplinkDevice.channel='auto'")
                
                if (isUplink5g) {
                    commands.add("uci set wireless.radio1.hwmode='11a'")
                    commands.add("uci set wireless.radio1.htmode='$htmode5g'")
                    
                    commands.add("uci set wireless.radio0.channel='${device.wifi2gChannel}'")
                    commands.add("uci set wireless.radio0.hwmode='11g'")
                    commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                } else {
                    commands.add("uci set wireless.radio0.hwmode='11g'")
                    commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                    
                    commands.add("uci set wireless.radio1.channel='${device.wifi5gChannel}'")
                    commands.add("uci set wireless.radio1.hwmode='11a'")
                    commands.add("uci set wireless.radio1.htmode='$htmode5g'")
                }

                // SSIDs
                val suffix = if (device.appendIpToSsid) "_${device.lanIp.substringAfterLast(".")}" else ""
                val ssid2g = "${device.wifiSsid ?: "ALEMPRATOR"}$suffix"
                val ssid5gBase = if (device.wifi5gNameType == "custom" && !device.wifi5gCustomSsid.isNullOrEmpty()) device.wifi5gCustomSsid else (device.wifiSsid ?: "ALEMPRATOR")
                val ssid5g = "$ssid5gBase$suffix"

                // The uplink AP SSID
                val uplinkApSsid = if (isUplink5g) ssid5g else ssid2g
                commands.add("uci set wireless.wizard_uplink_ap.ssid='$uplinkApSsid'")
                commands.add("uci set wireless.wizard_uplink_ap.disabled='0'")
                
                // The other band default AP SSID
                if (isUplink5g) {
                    commands.add("uci set wireless.default_radio0.ssid='$ssid2g'")
                    commands.add("uci set wireless.default_radio0.disabled='0'")
                    commands.add("if uci -q get wireless.default_radio0.isolate; then uci -q delete wireless.default_radio0.isolate; fi")
                    commands.add("uci set wireless.default_radio0.disassoc_low_ack='0'")
                    commands.add("uci set wireless.default_radio1.disabled='1'")
                } else {
                    commands.add("uci set wireless.default_radio1.ssid='$ssid5g'")
                    commands.add("uci set wireless.default_radio1.disabled='0'")
                    commands.add("if uci -q get wireless.default_radio1.isolate; then uci -q delete wireless.default_radio1.isolate; fi")
                    commands.add("uci set wireless.default_radio1.disassoc_low_ack='0'")
                    commands.add("uci set wireless.default_radio0.disabled='1'")
                }

                // Security for local APs
                if (device.noPassword) {
                    commands.add("uci set wireless.wizard_uplink_ap.encryption='none'")
                    commands.add("if uci -q get wireless.wizard_uplink_ap.key; then uci -q delete wireless.wizard_uplink_ap.key; fi")
                    
                    if (isUplink5g) {
                        commands.add("uci set wireless.default_radio0.encryption='none'")
                        commands.add("if uci -q get wireless.default_radio0.key; then uci -q delete wireless.default_radio0.key; fi")
                    } else {
                        commands.add("uci set wireless.default_radio1.encryption='none'")
                        commands.add("if uci -q get wireless.default_radio1.key; then uci -q delete wireless.default_radio1.key; fi")
                    }
                } else {
                    device.wifiKey?.let {
                        commands.add("uci set wireless.wizard_uplink_ap.encryption='psk2'")
                        commands.add("uci set wireless.wizard_uplink_ap.key='$it'")
                        
                        if (isUplink5g) {
                            commands.add("uci set wireless.default_radio0.encryption='psk2'")
                            commands.add("uci set wireless.default_radio0.key='$it'")
                        } else {
                            commands.add("uci set wireless.default_radio1.encryption='psk2'")
                            commands.add("uci set wireless.default_radio1.key='$it'")
                        }
                    }
                }
            }
            "mesh" -> {
                commands.add("uci set setup.default.mode='mesh'")
                commands.add("uci set hotspot_openwrt.main.enabled='0'")
                
                // 1. Configure the Mesh interface
                commands.add("uci set wireless.wizard_mesh.mode='mesh'")
                commands.add("uci set wireless.wizard_mesh.network='lan'")
                
                val deviceNameForMesh = if (device.meshBand == "5GHz") "radio1" else "radio0"
                commands.add("uci set wireless.wizard_mesh.device='$deviceNameForMesh'")
                commands.add("uci set wireless.wizard_mesh.mesh_id='${device.meshId ?: "EmpratorMesh"}'")
                
                if (device.meshKey.isNullOrEmpty()) {
                    commands.add("uci set wireless.wizard_mesh.encryption='none'")
                    commands.add("if uci -q get wireless.wizard_mesh.key; then uci -q delete wireless.wizard_mesh.key; fi")
                } else {
                    commands.add("uci set wireless.wizard_mesh.encryption='psk2'")
                    commands.add("uci set wireless.wizard_mesh.key='${device.meshKey}'")
                }

                // 2. Configure Local Re-broadcasting AP and Radios
                commands.add("uci set wireless.radio0.channel='${device.wifi2gChannel}'")
                commands.add("uci set wireless.radio0.hwmode='11g'")
                commands.add("uci set wireless.radio0.htmode='$htmode2g'")
                
                commands.add("uci set wireless.radio1.channel='${device.wifi5gChannel}'")
                commands.add("uci set wireless.radio1.hwmode='11a'")
                commands.add("uci set wireless.radio1.htmode='$htmode5g'")
                
                val suffix = if (device.appendIpToSsid) "_${device.lanIp.substringAfterLast(".")}" else ""
                val ssid2g = "${device.wifiSsid ?: "ALEMPRATOR"}$suffix"
                val ssid5gBase = if (device.wifi5gNameType == "custom" && !device.wifi5gCustomSsid.isNullOrEmpty()) device.wifi5gCustomSsid else (device.wifiSsid ?: "ALEMPRATOR")
                val ssid5g = "$ssid5gBase$suffix"
                
                commands.add("uci set wireless.default_radio0.ssid='$ssid2g'")
                commands.add("uci set wireless.default_radio1.ssid='$ssid5g'")
                
                if (device.noPassword) {
                    commands.add("uci set wireless.default_radio0.encryption='none'")
                    commands.add("uci set wireless.default_radio1.encryption='none'")
                    commands.add("if uci -q get wireless.default_radio0.key; then uci -q delete wireless.default_radio0.key; fi")
                    commands.add("if uci -q get wireless.default_radio1.key; then uci -q delete wireless.default_radio1.key; fi")
                } else {
                    device.wifiKey?.let {
                        commands.add("uci set wireless.default_radio0.encryption='psk2'")
                        commands.add("uci set wireless.default_radio0.key='$it'")
                        commands.add("uci set wireless.default_radio1.encryption='psk2'")
                        commands.add("uci set wireless.default_radio1.key='$it'")
                    }
                }
            }
        }
        
        // 3. Apply advanced switch configurations (isolate, hidden, dhcp)
        commands.add("if uci -q get wireless.default_radio0.isolate; then uci -q delete wireless.default_radio0.isolate; fi")
        commands.add("if uci -q get wireless.default_radio1.isolate; then uci -q delete wireless.default_radio1.isolate; fi")
        commands.add("uci set wireless.default_radio0.hidden='${if (device.hideSsid) "1" else "0"}'")
        commands.add("uci set wireless.default_radio1.hidden='${if (device.hideSsid) "1" else "0"}'")
        commands.add("uci set wireless.default_radio0.disabled='${if (device.vlanEnabled) "1" else "0"}'")
        commands.add("uci set wireless.default_radio1.disabled='${if (device.vlanEnabled) "1" else "0"}'")
        commands.add("uci set wireless.default_radio0.disassoc_low_ack='0'")
        commands.add("uci set wireless.default_radio1.disassoc_low_ack='0'")
        if (device.deviceType != "sta_wds") {
            commands.add("if uci -q get wireless.wizard_uplink; then uci -q delete wireless.wizard_uplink; fi")
            commands.add("if uci -q get wireless.wizard_uplink_ap; then uci -q delete wireless.wizard_uplink_ap; fi")
        }
        commands.add("uci set dhcp.lan.ignore='1'")
        commands.add("uci set dhcp.lan.dynamicdhcp='0'")
        commands.add("uci commit dhcp")
        
        // 4. VLAN configuration
        if (device.vlanEnabled && !device.vlanId.isNullOrEmpty()) {
            commands.add("uci set network.wizard_vlan_dev='device'")
            commands.add("uci set network.wizard_vlan_dev.type='8021q'")
            commands.add("uci set network.wizard_vlan_dev.ifname='br-lan'")
            commands.add("uci set network.wizard_vlan_dev.vid='${device.vlanId}'")
            commands.add("uci set network.wizard_vlan_dev.name='br-lan.${device.vlanId}'")

            commands.add("uci set network.wizard_vlan_bridge='device'")
            commands.add("uci set network.wizard_vlan_bridge.type='bridge'")
            commands.add("uci set network.wizard_vlan_bridge.name='vlan_${device.vlanId}'")
            commands.add("uci set network.wizard_vlan_bridge.bridge_empty='1'")
            commands.add("uci set network.wizard_vlan_bridge.ipv6='0'")
            commands.add("uci set network.wizard_vlan_bridge.ports='br-lan.${device.vlanId}'")
            commands.add("uci set network.wizard_vlan_bridge.ageing_time='10'")

            commands.add("uci set network.wizardvlan='interface'")
            commands.add("uci set network.wizardvlan.proto='none'")
            commands.add("uci set network.wizardvlan.device='vlan_${device.vlanId}'")
            
            commands.add("if uci -q get dhcp.wizardvlan; then uci -q delete dhcp.wizardvlan; fi")
            commands.add("uci commit network")

            val vlanSuffix = if (device.vlanSsidIpSuffix) "_${device.lanIp.substringAfterLast(".")}" else ""
            val vlanSsid2g = if (!device.vlanSsid2g.isNullOrEmpty()) "${device.vlanSsid2g}$vlanSuffix" else "${device.wifiSsid ?: "ALEMPRATOR"}_VLAN$vlanSuffix"
            val vlanSsid5g = if (!device.vlanSsid5g.isNullOrEmpty()) "${device.vlanSsid5g}$vlanSuffix" else "${device.wifiSsid ?: "ALEMPRATOR"}_VLAN$vlanSuffix" + "_5G"

            commands.add("uci set wireless.wizard_vlan_radio0_ap='wifi-iface'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.device='radio0'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.mode='ap'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.network='wizardvlan'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.disabled='0'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.ssid='$vlanSsid2g'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.disassoc_low_ack='0'")
            commands.add("uci set wireless.wizard_vlan_radio0_ap.isolate='1'")
            if (device.noPassword || device.wifiKey.isNullOrEmpty()) {
                commands.add("uci set wireless.wizard_vlan_radio0_ap.encryption='none'")
                commands.add("if uci -q get wireless.wizard_vlan_radio0_ap.key; then uci -q delete wireless.wizard_vlan_radio0_ap.key; fi")
            } else {
                commands.add("uci set wireless.wizard_vlan_radio0_ap.encryption='psk2'")
                commands.add("uci set wireless.wizard_vlan_radio0_ap.key='${device.wifiKey}'")
            }

            commands.add("uci set wireless.wizard_vlan_radio1_ap='wifi-iface'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.device='radio1'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.mode='ap'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.network='wizardvlan'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.disabled='0'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.ssid='$vlanSsid5g'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.disassoc_low_ack='0'")
            commands.add("uci set wireless.wizard_vlan_radio1_ap.isolate='1'")
            if (device.noPassword || device.wifiKey.isNullOrEmpty()) {
                commands.add("uci set wireless.wizard_vlan_radio1_ap.encryption='none'")
                commands.add("if uci -q get wireless.wizard_vlan_radio1_ap.key; then uci -q delete wireless.wizard_vlan_radio1_ap.key; fi")
            } else {
                commands.add("uci set wireless.wizard_vlan_radio1_ap.encryption='psk2'")
                commands.add("uci set wireless.wizard_vlan_radio1_ap.key='${device.wifiKey}'")
            }
        } else {
            commands.add("if uci -q get network.wizard_vlan_dev; then uci -q delete network.wizard_vlan_dev; fi")
            commands.add("if uci -q get network.wizard_vlan_bridge; then uci -q delete network.wizard_vlan_bridge; fi")
            commands.add("if uci -q get network.wizardvlan; then uci -q delete network.wizardvlan; fi")
            commands.add("if uci -q get wireless.wizard_vlan_radio0_ap; then uci -q delete wireless.wizard_vlan_radio0_ap; fi")
            commands.add("if uci -q get wireless.wizard_vlan_radio1_ap; then uci -q delete wireless.wizard_vlan_radio1_ap; fi")
            commands.add("uci commit network")
        }
        
        // 5. Hardware Buttons protection (via setup service config)
        commands.add("uci set setup.default.reset_button_disabled='${if (device.disableResetButton) "1" else "0"}'")
        commands.add("uci set setup.default.reset_hold_seconds='${device.resetPressDuration}'")
        commands.add("uci set setup.default.wps_button_disabled='${if (device.disableWpsButton) "1" else "0"}'")
        commands.add("uci commit setup")
        commands.add("/etc/init.d/setup restart")
        
        if (device.autoRebootEnabled) {
            commands.add("uci set system.autoreboot='1'")
            val hours = device.rebootHours
            commands.add("uci set watchcat.alemprator_periodic_reboot='watchcat'")
            commands.add("uci set watchcat.alemprator_periodic_reboot.mode='periodic_reboot'")
            commands.add("uci set watchcat.alemprator_periodic_reboot.period='${hours}h'")
            commands.add("uci commit watchcat")
        } else {
            commands.add("uci set system.autoreboot='0'")
            commands.add("if uci -q get watchcat.alemprator_periodic_reboot; then uci -q delete watchcat.alemprator_periodic_reboot; fi")
            commands.add("uci commit watchcat")
        }
        commands.add("uci commit system")
        
        // 6. Root password change
        if (!device.rootPassword.isNullOrEmpty()) {
            commands.add("echo -e '${device.rootPassword}\\n${device.rootPassword}' | passwd root")
        }
        
        // Store config variables in setup.default for overview
        commands.add("uci set setup.default.wifi_ssid='${device.wifiSsid ?: ""}'")
        commands.add("if [ -n '${device.wifiKey ?: ""}' ]; then uci set setup.default.wifi_key='${device.wifiKey}'; else uci -q delete setup.default.wifi_key; fi")
        commands.add("uci set setup.default.wifi_mode_2g='${device.wifi2gMode}'")
        commands.add("uci set setup.default.wifi_width_2g='${device.wifi2gWidth}'")
        commands.add("uci set setup.default.wifi_mode_5g='${device.wifi5gMode}'")
        commands.add("uci set setup.default.wifi_width_5g='${device.wifi5gWidth}'")
        commands.add("uci set setup.default.lan_ipaddr='${device.lanIp}'")
        commands.add("uci set setup.default.lan_netmask='255.255.255.0'")
        commands.add("uci set setup.default.is_vlan='${if (device.vlanEnabled) "1" else "0"}'")
        if (device.vlanEnabled && !device.vlanId.isNullOrEmpty()) {
            commands.add("uci set setup.default.vlan_id='${device.vlanId}'")
        }
        
        // Save and apply changes
        commands.add("uci set setup.default.initial_setup_complete='1'")
        commands.add("uci commit setup")
        commands.add("uci commit network")
        commands.add("uci commit wireless")
        commands.add("uci commit hotspot_openwrt")
        commands.add("echo '=== تطبيق التغييرات وإعادة تشغيل الخدمات ==='")
        if (device.deviceType == "hotspot") {
            commands.add("/usr/libexec/hotspot-openwrt/apply")
        }
        // تشغيل مراقبة التنظيف التلقائي في الخلفية لتفادي تعارض الأوامر وإتمام التنظيف ذاتياً
        commands.add("(sleep 1; /etc/init.d/alemprator-firstboot monitor_once) >/dev/null 2>&1 &")
        
        return commands
    }

    /**
     * Generates a single executable shell script text file.
     */
    fun generateRawScript(device: Device, pool: SubnetPool? = null): String {
        val header = "#!/bin/sh\n# سكريبت إعداد تلقائي لـ ${device.deviceName}\n# الماك أدرس: ${device.macAddress}\n\n"
        return header + generateCommands(device, pool).joinToString("\n")
    }
}
