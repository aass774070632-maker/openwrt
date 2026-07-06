package com.alemprator.setup.ssh;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000<\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\n\n\u0002\u0010 \n\u0000\n\u0002\u0018\u0002\n\u0002\b\u000b\n\u0002\u0010\u0002\n\u0002\u0010!\n\u0002\b\u001c\u0018\u00002\u00020\u0001B\u0005\u00a2\u0006\u0002\u0010\u0002J\u0010\u0010\u0003\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0006H\u0002J\u0010\u0010\u0007\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J\u0018\u0010\n\u001a\u00020\u00042\u0006\u0010\u000b\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J\u0010\u0010\f\u001a\u00020\u00042\u0006\u0010\r\u001a\u00020\u0004H\u0002J\u0018\u0010\u000e\u001a\u00020\u00042\u0006\u0010\u000f\u001a\u00020\u00042\u0006\u0010\u0010\u001a\u00020\u0004H\u0002J\u0010\u0010\u0011\u001a\u00020\u00042\u0006\u0010\u0012\u001a\u00020\u0004H\u0002J \u0010\u0013\u001a\b\u0012\u0004\u0012\u00020\u00040\u00142\u0006\u0010\b\u001a\u00020\t2\n\b\u0002\u0010\u0015\u001a\u0004\u0018\u00010\u0016J\u001a\u0010\u0017\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\t2\n\b\u0002\u0010\u0015\u001a\u0004\u0018\u00010\u0016J\u0010\u0010\u0018\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J\u0010\u0010\u0019\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J\u0018\u0010\u001a\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u00042\u0006\u0010\u001b\u001a\u00020\u0004H\u0002J\u0010\u0010\u001c\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0004H\u0002J\u0010\u0010\u001d\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0004H\u0002J\u0018\u0010\u001e\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u00042\u0006\u0010\u001b\u001a\u00020\u0004H\u0002J\u0010\u0010\u001f\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0004H\u0002J\u0010\u0010 \u001a\u00020\u00062\u0006\u0010\b\u001a\u00020\tH\u0002J2\u0010!\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\t2\u0006\u0010$\u001a\u00020\u00042\u0006\u0010%\u001a\u00020\u00042\u0006\u0010&\u001a\u00020\u0006H\u0002J$\u0010\'\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\t2\b\u0010\u0015\u001a\u0004\u0018\u00010\u0016H\u0002J:\u0010(\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010)\u001a\u00020\u00042\u0006\u0010*\u001a\u00020\u00042\u0006\u0010+\u001a\u00020\u00042\u0006\u0010,\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J*\u0010-\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\t2\u0006\u0010$\u001a\u00020\u00042\u0006\u0010%\u001a\u00020\u0004H\u0002J\u001a\u0010.\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\tH\u0002J\u001a\u0010/\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\tH\u0002J\u001a\u00100\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\tH\u0002J*\u00101\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\t2\u0006\u0010$\u001a\u00020\u00042\u0006\u0010%\u001a\u00020\u0004H\u0002J\"\u00102\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010\b\u001a\u00020\t2\u0006\u0010$\u001a\u00020\u0004H\u0002J2\u00103\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010)\u001a\u00020\u00042\u0006\u0010*\u001a\u00020\u00042\u0006\u0010,\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002J\u001a\u00104\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u00105\u001a\u00020\u0004H\u0002J\u001a\u00106\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u00105\u001a\u00020\u0004H\u0002J\u0012\u00107\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#H\u0002J\u0012\u00108\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#H\u0002J\"\u00109\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u00105\u001a\u00020\u00042\u0006\u0010:\u001a\u00020\u0004H\u0002J$\u0010;\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u00105\u001a\u00020\u00042\b\u0010\u0005\u001a\u0004\u0018\u00010\u0004H\u0002J\u0012\u0010<\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#H\u0002J\"\u0010=\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u00105\u001a\u00020\u00042\u0006\u0010\u0005\u001a\u00020\u0004H\u0002J\"\u0010>\u001a\u00020\"*\b\u0012\u0004\u0012\u00020\u00040#2\u0006\u0010)\u001a\u00020\u00042\u0006\u0010\b\u001a\u00020\tH\u0002\u00a8\u0006?"}, d2 = {"Lcom/alemprator/setup/ssh/ScriptGenerator;", "", "()V", "bool", "", "value", "", "buildPrimary5gSsid", "device", "Lcom/alemprator/setup/db/Device;", "buildSsid", "base", "deriveGateway", "ip", "derivePoolIp", "gateway", "host", "deriveSecondaryInterface", "primary", "generateCommands", "", "pool", "Lcom/alemprator/setup/db/SubnetPool;", "generateRawScript", "htmode2g", "htmode5g", "normalizeInterface", "fallback", "normalizeMaintenance", "normalizeMode", "normalizePolicy", "sh", "shouldHideSsid", "configureAp", "", "", "ssid2g", "ssid5g", "wds", "configureHotspotQuick", "configureHotspotWireless", "section", "radio", "network", "ssid", "configureMesh", "configureOtaWindow", "configurePeriodicReboot", "configureRadios", "configureStaWds", "configureVlan", "configureVlanWireless", "deleteIfExists", "key", "deleteOption", "disableFirstbootProvisioning", "disableHotspotQuick", "ensureSection", "type", "optionalSetOrDelete", "removeVlan", "set", "setWifiSecurity", "app_debug"})
public final class ScriptGenerator {
    
    public ScriptGenerator() {
        super();
    }
    
    @org.jetbrains.annotations.NotNull
    public final java.util.List<java.lang.String> generateCommands(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.Device device, @org.jetbrains.annotations.Nullable
    com.alemprator.setup.db.SubnetPool pool) {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull
    public final java.lang.String generateRawScript(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.Device device, @org.jetbrains.annotations.Nullable
    com.alemprator.setup.db.SubnetPool pool) {
        return null;
    }
    
    private final void configureHotspotQuick(java.util.List<java.lang.String> $this$configureHotspotQuick, com.alemprator.setup.db.Device device, com.alemprator.setup.db.SubnetPool pool) {
    }
    
    private final void configureAp(java.util.List<java.lang.String> $this$configureAp, com.alemprator.setup.db.Device device, java.lang.String ssid2g, java.lang.String ssid5g, boolean wds) {
    }
    
    private final void configureStaWds(java.util.List<java.lang.String> $this$configureStaWds, com.alemprator.setup.db.Device device, java.lang.String ssid2g, java.lang.String ssid5g) {
    }
    
    private final void configureMesh(java.util.List<java.lang.String> $this$configureMesh, com.alemprator.setup.db.Device device, java.lang.String ssid2g, java.lang.String ssid5g) {
    }
    
    private final void configureVlan(java.util.List<java.lang.String> $this$configureVlan, com.alemprator.setup.db.Device device, java.lang.String ssid2g) {
    }
    
    private final void removeVlan(java.util.List<java.lang.String> $this$removeVlan) {
    }
    
    private final void disableHotspotQuick(java.util.List<java.lang.String> $this$disableHotspotQuick) {
    }
    
    private final void disableFirstbootProvisioning(java.util.List<java.lang.String> $this$disableFirstbootProvisioning) {
    }
    
    private final void configureRadios(java.util.List<java.lang.String> $this$configureRadios, com.alemprator.setup.db.Device device) {
    }
    
    private final void configurePeriodicReboot(java.util.List<java.lang.String> $this$configurePeriodicReboot, com.alemprator.setup.db.Device device) {
    }
    
    private final void configureOtaWindow(java.util.List<java.lang.String> $this$configureOtaWindow, com.alemprator.setup.db.Device device) {
    }
    
    private final void configureHotspotWireless(java.util.List<java.lang.String> $this$configureHotspotWireless, java.lang.String section, java.lang.String radio, java.lang.String network, java.lang.String ssid, com.alemprator.setup.db.Device device) {
    }
    
    private final void configureVlanWireless(java.util.List<java.lang.String> $this$configureVlanWireless, java.lang.String section, java.lang.String radio, java.lang.String ssid, com.alemprator.setup.db.Device device) {
    }
    
    private final void setWifiSecurity(java.util.List<java.lang.String> $this$setWifiSecurity, java.lang.String section, com.alemprator.setup.db.Device device) {
    }
    
    private final void ensureSection(java.util.List<java.lang.String> $this$ensureSection, java.lang.String key, java.lang.String type) {
    }
    
    private final void set(java.util.List<java.lang.String> $this$set, java.lang.String key, java.lang.String value) {
    }
    
    private final void optionalSetOrDelete(java.util.List<java.lang.String> $this$optionalSetOrDelete, java.lang.String key, java.lang.String value) {
    }
    
    private final void deleteIfExists(java.util.List<java.lang.String> $this$deleteIfExists, java.lang.String key) {
    }
    
    private final void deleteOption(java.util.List<java.lang.String> $this$deleteOption, java.lang.String key) {
    }
    
    private final java.lang.String sh(java.lang.String value) {
        return null;
    }
    
    private final java.lang.String bool(boolean value) {
        return null;
    }
    
    private final boolean shouldHideSsid(com.alemprator.setup.db.Device device) {
        return false;
    }
    
    private final java.lang.String normalizeMode(java.lang.String value) {
        return null;
    }
    
    private final java.lang.String normalizeInterface(java.lang.String value, java.lang.String fallback) {
        return null;
    }
    
    private final java.lang.String normalizePolicy(java.lang.String value, java.lang.String fallback) {
        return null;
    }
    
    private final java.lang.String normalizeMaintenance(java.lang.String value) {
        return null;
    }
    
    private final java.lang.String deriveSecondaryInterface(java.lang.String primary) {
        return null;
    }
    
    private final java.lang.String deriveGateway(java.lang.String ip) {
        return null;
    }
    
    private final java.lang.String derivePoolIp(java.lang.String gateway, java.lang.String host) {
        return null;
    }
    
    private final java.lang.String buildSsid(java.lang.String base, com.alemprator.setup.db.Device device) {
        return null;
    }
    
    private final java.lang.String buildPrimary5gSsid(com.alemprator.setup.db.Device device) {
        return null;
    }
    
    private final java.lang.String htmode2g(com.alemprator.setup.db.Device device) {
        return null;
    }
    
    private final java.lang.String htmode5g(com.alemprator.setup.db.Device device) {
        return null;
    }
}