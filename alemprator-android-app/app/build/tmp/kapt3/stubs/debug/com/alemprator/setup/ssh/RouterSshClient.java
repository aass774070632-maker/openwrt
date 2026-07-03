package com.alemprator.setup.ssh;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000*\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\b\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010 \n\u0002\b\u0004\u0018\u00002\u00020\u0001B-\u0012\b\b\u0002\u0010\u0002\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0004\u001a\u00020\u0005\u0012\b\b\u0002\u0010\u0006\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0007\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\bJ+\u0010\t\u001a\u000e\u0012\u0004\u0012\u00020\u000b\u0012\u0004\u0012\u00020\u00030\n2\f\u0010\f\u001a\b\u0012\u0004\u0012\u00020\u00030\rH\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000eJ\u0013\u0010\u000f\u001a\u0004\u0018\u00010\u0003H\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u0010R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u0082\u0002\u0004\n\u0002\b\u0019\u00a8\u0006\u0011"}, d2 = {"Lcom/alemprator/setup/ssh/RouterSshClient;", "", "host", "", "port", "", "username", "password", "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V", "executeCommands", "Lkotlin/Pair;", "", "commands", "", "(Ljava/util/List;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "fetchMacAddress", "(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "app_debug"})
public final class RouterSshClient {
    @org.jetbrains.annotations.NotNull
    private final java.lang.String host = null;
    private final int port = 0;
    @org.jetbrains.annotations.NotNull
    private final java.lang.String username = null;
    @org.jetbrains.annotations.NotNull
    private final java.lang.String password = null;
    
    public RouterSshClient(@org.jetbrains.annotations.NotNull
    java.lang.String host, int port, @org.jetbrains.annotations.NotNull
    java.lang.String username, @org.jetbrains.annotations.NotNull
    java.lang.String password) {
        super();
    }
    
    /**
     * Executes a list of shell commands on the router sequentially.
     * Returns true if all commands execute successfully, false otherwise.
     */
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object executeCommands(@org.jetbrains.annotations.NotNull
    java.util.List<java.lang.String> commands, @org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super kotlin.Pair<java.lang.Boolean, java.lang.String>> $completion) {
        return null;
    }
    
    /**
     * Connects to the router and retrieves the system MAC address.
     */
    @org.jetbrains.annotations.Nullable
    public final java.lang.Object fetchMacAddress(@org.jetbrains.annotations.NotNull
    kotlin.coroutines.Continuation<? super java.lang.String> $completion) {
        return null;
    }
    
    public RouterSshClient() {
        super();
    }
}