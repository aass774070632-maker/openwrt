package com.alemprator.setup.ssh;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000P\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\b\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0002\u0010\u000b\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u0012\n\u0002\b\u0003\n\u0002\u0010 \n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0003\n\u0002\u0010\u0011\n\u0002\b\u0002\u0018\u00002\u00020\u0001B-\u0012\b\b\u0002\u0010\u0002\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0004\u001a\u00020\u0005\u0012\b\b\u0002\u0010\u0006\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0007\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\bJ-\u0010\t\u001a\u000e\u0012\u0004\u0012\u00020\u000b\u0012\u0004\u0012\u00020\u00030\n2\u0006\u0010\f\u001a\u00020\u00032\u0006\u0010\r\u001a\u00020\u0003H\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000eJ \u0010\u000f\u001a\u00020\u00032\u0006\u0010\u0010\u001a\u00020\u00112\u0006\u0010\u0012\u001a\u00020\u00132\u0006\u0010\u0014\u001a\u00020\u0003H\u0002J\u0010\u0010\u0015\u001a\u00020\u00162\u0006\u0010\u0017\u001a\u00020\u0003H\u0002J\u0010\u0010\u0018\u001a\u00020\u00052\u0006\u0010\u0012\u001a\u00020\u0013H\u0002J\u0016\u0010\u0019\u001a\b\u0012\u0004\u0012\u00020\u00030\u001a2\u0006\u0010\u0012\u001a\u00020\u0013H\u0002J\u0018\u0010\u001b\u001a\u00020\u001c2\u0006\u0010\u0010\u001a\u00020\u00112\u0006\u0010\u001d\u001a\u00020\u0005H\u0002J)\u0010\u001e\u001a\u00020\u001c2\u0006\u0010\u0010\u001a\u00020\u00112\u0012\u0010\u001f\u001a\n\u0012\u0006\b\u0001\u0012\u00020\u00030 \"\u00020\u0003H\u0002\u00a2\u0006\u0002\u0010!R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u0082\u0002\u0004\n\u0002\b\u0019\u00a8\u0006\""}, d2 = {"Lcom/alemprator/setup/ssh/MikrotikUserManager;", "", "host", "", "port", "", "username", "password", "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V", "configureRouter", "Lkotlin/Pair;", "", "routerIp", "sharedSecret", "(Ljava/lang/String;Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "getFirstCustomer", "output", "Ljava/io/OutputStream;", "input", "Ljava/io/DataInputStream;", "fallback", "hexStringToByteArray", "", "hex", "readLength", "readSentence", "", "writeLength", "", "len", "writeSentence", "words", "", "(Ljava/io/OutputStream;[Ljava/lang/String;)V", "app_debug"})
public final class MikrotikUserManager {
    @org.jetbrains.annotations.NotNull
    private final java.lang.String host = null;
    private final int port = 0;
    @org.jetbrains.annotations.NotNull
    private final java.lang.String username = null;
    @org.jetbrains.annotations.NotNull
    private final java.lang.String password = null;
    
    public MikrotikUserManager(@org.jetbrains.annotations.NotNull
    java.lang.String host, int port, @org.jetbrains.annotations.NotNull
    java.lang.String username, @org.jetbrains.annotations.NotNull
    java.lang.String password) {
        super();
    }
    
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object configureRouter(@org.jetbrains.annotations.NotNull
    java.lang.String routerIp, @org.jetbrains.annotations.NotNull
    java.lang.String sharedSecret, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Pair<java.lang.Boolean, java.lang.String>> $completion) {
        return null;
    }
    
    private final java.lang.String getFirstCustomer(java.io.OutputStream output, java.io.DataInputStream input, java.lang.String fallback) {
        return null;
    }
    
    private final void writeLength(java.io.OutputStream output, int len) {
    }
    
    private final int readLength(java.io.DataInputStream input) {
        return 0;
    }
    
    private final void writeSentence(java.io.OutputStream output, java.lang.String... words) {
    }
    
    private final java.util.List<java.lang.String> readSentence(java.io.DataInputStream input) {
        return null;
    }
    
    private final byte[] hexStringToByteArray(java.lang.String hex) {
        return null;
    }
    
    public MikrotikUserManager() {
        super();
    }
}