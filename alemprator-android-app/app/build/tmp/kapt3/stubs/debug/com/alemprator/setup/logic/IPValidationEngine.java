package com.alemprator.setup.logic;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0003\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0004J#\u0010\u0005\u001a\u0004\u0018\u00010\u00062\u0006\u0010\u0007\u001a\u00020\b2\u0006\u0010\t\u001a\u00020\bH\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\nJ#\u0010\u000b\u001a\u0014\u0012\u0004\u0012\u00020\b\u0012\u0004\u0012\u00020\b\u0012\u0004\u0012\u00020\b0\fH\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\rJ\u0011\u0010\u000e\u001a\u00020\bH\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\rR\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u0082\u0002\u0004\n\u0002\b\u0019\u00a8\u0006\u000f"}, d2 = {"Lcom/alemprator/setup/logic/IPValidationEngine;", "", "deviceDao", "Lcom/alemprator/setup/db/DeviceDao;", "(Lcom/alemprator/setup/db/DeviceDao;)V", "checkLanIpConflict", "Lcom/alemprator/setup/db/Device;", "ip", "", "currentMac", "(Ljava/lang/String;Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "suggestNextHotspotPool", "Lkotlin/Triple;", "(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "suggestNextLanIp", "app_debug"})
public final class IPValidationEngine {
    @org.jetbrains.annotations.NotNull
    private final com.alemprator.setup.db.DeviceDao deviceDao = null;
    
    public IPValidationEngine(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.DeviceDao deviceDao) {
        super();
    }
    
    /**
     * Checks if a LAN IP is already assigned to a different MAC address.
     * Returns the conflicting Device if exists, null otherwise.
     */
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object checkLanIpConflict(@org.jetbrains.annotations.NotNull
    java.lang.String ip, @org.jetbrains.annotations.NotNull
    java.lang.String currentMac, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super com.alemprator.setup.db.Device> $completion) {
        return null;
    }
    
    /**
     * Suggests the next available LAN IP based on the highest IP in the DB.
     * Fallback to 192.168.1.20 if DB is empty.
     */
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object suggestNextLanIp(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super java.lang.String> $completion) {
        return null;
    }
    
    /**
     * Suggests the next non-conflicting Hotspot DHCP Subnet Pool.
     * Incrementing the third octet starting from 10.10.10.0/24
     */
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object suggestNextHotspotPool(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Triple<java.lang.String, java.lang.String, java.lang.String>> $completion) {
        return null;
    }
}