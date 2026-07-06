package com.alemprator.setup.db;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010 \n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u000b\bg\u0018\u00002\u00020\u0001J\u0019\u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u0005H\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u0006J\u0017\u0010\u0007\u001a\b\u0012\u0004\u0012\u00020\u00050\bH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\tJ\u0017\u0010\n\u001a\b\u0012\u0004\u0012\u00020\u000b0\bH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\tJ\u001b\u0010\f\u001a\u0004\u0018\u00010\u00052\u0006\u0010\r\u001a\u00020\u000eH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000fJ\u001b\u0010\u0010\u001a\u0004\u0018\u00010\u00052\u0006\u0010\u0011\u001a\u00020\u000eH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000fJ\u0013\u0010\u0012\u001a\u0004\u0018\u00010\u0005H\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\tJ\u001b\u0010\u0013\u001a\u0004\u0018\u00010\u000b2\u0006\u0010\u0014\u001a\u00020\u000eH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000fJ\u0019\u0010\u0015\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u0005H\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u0006J\u0019\u0010\u0016\u001a\u00020\u00032\u0006\u0010\u0017\u001a\u00020\u000bH\u00a7@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u0018\u0082\u0002\u0004\n\u0002\b\u0019\u00a8\u0006\u0019"}, d2 = {"Lcom/alemprator/setup/db/DeviceDao;", "", "deleteDevice", "", "device", "Lcom/alemprator/setup/db/Device;", "(Lcom/alemprator/setup/db/Device;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "getAllDevices", "", "(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "getAllSubnetPools", "Lcom/alemprator/setup/db/SubnetPool;", "getDeviceByIp", "ip", "", "(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "getDeviceByMac", "mac", "getLastTemplate", "getPoolByNetwork", "network", "insertDevice", "insertSubnetPool", "pool", "(Lcom/alemprator/setup/db/SubnetPool;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "app_debug"})
@androidx.room.Dao
public abstract interface DeviceDao {
    
    @androidx.room.Query(value = "SELECT * FROM devices ORDER BY timestamp DESC")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getAllDevices(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super java.util.List<com.alemprator.setup.db.Device>> $completion);
    
    @androidx.room.Query(value = "SELECT * FROM devices WHERE macAddress = :mac LIMIT 1")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getDeviceByMac(@org.jetbrains.annotations.NotNull
    java.lang.String mac, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super com.alemprator.setup.db.Device> $completion);
    
    @androidx.room.Query(value = "SELECT * FROM devices WHERE lanIp = :ip LIMIT 1")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getDeviceByIp(@org.jetbrains.annotations.NotNull
    java.lang.String ip, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super com.alemprator.setup.db.Device> $completion);
    
    @androidx.room.Query(value = "SELECT * FROM devices WHERE isTemplate = 1 ORDER BY timestamp DESC LIMIT 1")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getLastTemplate(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super com.alemprator.setup.db.Device> $completion);
    
    @androidx.room.Insert(onConflict = 1)
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object insertDevice(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.Device device, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Unit> $completion);
    
    @androidx.room.Delete
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object deleteDevice(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.Device device, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Unit> $completion);
    
    @androidx.room.Query(value = "SELECT * FROM subnet_pools")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getAllSubnetPools(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super java.util.List<com.alemprator.setup.db.SubnetPool>> $completion);
    
    @androidx.room.Query(value = "SELECT * FROM subnet_pools WHERE poolNetwork = :network LIMIT 1")
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object getPoolByNetwork(@org.jetbrains.annotations.NotNull
    java.lang.String network, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super com.alemprator.setup.db.SubnetPool> $completion);
    
    @androidx.room.Insert(onConflict = 1)
    @org.jetbrains.annotations.Nullable
    public abstract java.lang.Object insertSubnetPool(@org.jetbrains.annotations.NotNull
    com.alemprator.setup.db.SubnetPool pool, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Unit> $completion);
}