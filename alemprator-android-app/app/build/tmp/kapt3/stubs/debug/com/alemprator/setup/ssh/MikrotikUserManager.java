package com.alemprator.setup.ssh;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000B\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\b\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0002\u0010\u000b\n\u0002\b\u0006\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0011\n\u0002\b\u0003\u0018\u00002\u00020\u0001:\u0001\u001bB-\u0012\b\b\u0002\u0010\u0002\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0004\u001a\u00020\u0005\u0012\b\b\u0002\u0010\u0006\u001a\u00020\u0003\u0012\b\b\u0002\u0010\u0007\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\bJ-\u0010\t\u001a\u000e\u0012\u0004\u0012\u00020\u000b\u0012\u0004\u0012\u00020\u00030\n2\u0006\u0010\f\u001a\u00020\u00032\u0006\u0010\r\u001a\u00020\u0003H\u0086@\u00f8\u0001\u0000\u00a2\u0006\u0002\u0010\u000eJ\u0010\u0010\u000f\u001a\u00020\u00032\u0006\u0010\u0010\u001a\u00020\u0003H\u0002J\u0010\u0010\u0011\u001a\u00020\u00122\u0006\u0010\u0010\u001a\u00020\u0013H\u0002J)\u0010\u0014\u001a\u00020\u00152\u0006\u0010\u0016\u001a\u00020\u00172\u0012\u0010\u0018\u001a\n\u0012\u0006\b\u0001\u0012\u00020\u00030\u0019\"\u00020\u0003H\u0002\u00a2\u0006\u0002\u0010\u001aR\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u0082\u0002\u0004\n\u0002\b\u0019\u00a8\u0006\u001c"}, d2 = {"Lcom/alemprator/setup/ssh/MikrotikUserManager;", "", "host", "", "port", "", "username", "password", "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V", "configureRouter", "Lkotlin/Pair;", "", "routerIp", "sharedSecret", "(Ljava/lang/String;Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;", "hexMd5", "input", "readSentence", "Lcom/alemprator/setup/ssh/MikrotikUserManager$Sentence;", "Ljava/io/InputStream;", "writeSentence", "", "output", "Ljava/io/OutputStream;", "words", "", "(Ljava/io/OutputStream;[Ljava/lang/String;)V", "Sentence", "app_debug"})
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
    
    private final void writeSentence(java.io.OutputStream output, java.lang.String... words) {
    }
    
    private final com.alemprator.setup.ssh.MikrotikUserManager.Sentence readSentence(java.io.InputStream input) {
        return null;
    }
    
    private final java.lang.String hexMd5(java.lang.String input) {
        return null;
    }
    
    public MikrotikUserManager() {
        super();
    }
    
    @kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010 \n\u0002\u0010\u000e\n\u0002\b\u0006\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0002\b\u0082\b\u0018\u00002\u00020\u0001B\u0013\u0012\f\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003\u00a2\u0006\u0002\u0010\u0005J\u000f\u0010\b\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003H\u00c6\u0003J\u0019\u0010\t\u001a\u00020\u00002\u000e\b\u0002\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003H\u00c6\u0001J\u0013\u0010\n\u001a\u00020\u000b2\b\u0010\f\u001a\u0004\u0018\u00010\u0001H\u00d6\u0003J\t\u0010\r\u001a\u00020\u000eH\u00d6\u0001J\t\u0010\u000f\u001a\u00020\u0004H\u00d6\u0001R\u0017\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003\u00a2\u0006\b\n\u0000\u001a\u0004\b\u0006\u0010\u0007\u00a8\u0006\u0010"}, d2 = {"Lcom/alemprator/setup/ssh/MikrotikUserManager$Sentence;", "", "entries", "", "", "(Ljava/util/List;)V", "getEntries", "()Ljava/util/List;", "component1", "copy", "equals", "", "other", "hashCode", "", "toString", "app_debug"})
    static final class Sentence {
        @org.jetbrains.annotations.NotNull
        private final java.util.List<java.lang.String> entries = null;
        
        public Sentence(@org.jetbrains.annotations.NotNull
        java.util.List<java.lang.String> entries) {
            super();
        }
        
        @org.jetbrains.annotations.NotNull
        public final java.util.List<java.lang.String> getEntries() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull
        public final java.util.List<java.lang.String> component1() {
            return null;
        }
        
        @org.jetbrains.annotations.NotNull
        public final com.alemprator.setup.ssh.MikrotikUserManager.Sentence copy(@org.jetbrains.annotations.NotNull
        java.util.List<java.lang.String> entries) {
            return null;
        }
        
        @java.lang.Override
        public boolean equals(@org.jetbrains.annotations.Nullable
        java.lang.Object other) {
            return false;
        }
        
        @java.lang.Override
        public int hashCode() {
            return 0;
        }
        
        @java.lang.Override
        @org.jetbrains.annotations.NotNull
        public java.lang.String toString() {
            return null;
        }
    }
}