package com.alemprator.setup.camera;

@kotlin.Metadata(mv = {1, 9, 0}, k = 1, xi = 48, d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0010\u000e\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\u0018\u00002\u00020\u0001B\u0019\u0012\u0012\u0010\u0002\u001a\u000e\u0012\u0004\u0012\u00020\u0004\u0012\u0004\u0012\u00020\u00050\u0003\u00a2\u0006\u0002\u0010\u0006J\u0010\u0010\t\u001a\u00020\u00052\u0006\u0010\n\u001a\u00020\u000bH\u0017R\u001a\u0010\u0002\u001a\u000e\u0012\u0004\u0012\u00020\u0004\u0012\u0004\u0012\u00020\u00050\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\bX\u0082\u0004\u00a2\u0006\u0002\n\u0000\u00a8\u0006\f"}, d2 = {"Lcom/alemprator/setup/camera/BarcodeScannerHelper;", "Landroidx/camera/core/ImageAnalysis$Analyzer;", "onMacScanned", "Lkotlin/Function1;", "", "", "(Lkotlin/jvm/functions/Function1;)V", "scanner", "Lcom/google/mlkit/vision/barcode/BarcodeScanner;", "analyze", "imageProxy", "Landroidx/camera/core/ImageProxy;", "app_debug"})
public final class BarcodeScannerHelper implements androidx.camera.core.ImageAnalysis.Analyzer {
    @org.jetbrains.annotations.NotNull
    private final kotlin.jvm.functions.Function1<java.lang.String, kotlin.Unit> onMacScanned = null;
    @org.jetbrains.annotations.NotNull
    private final com.google.mlkit.vision.barcode.BarcodeScanner scanner = null;
    
    public BarcodeScannerHelper(@org.jetbrains.annotations.NotNull
    kotlin.jvm.functions.Function1<? super java.lang.String, kotlin.Unit> onMacScanned) {
        super();
    }
    
    @java.lang.Override
    @android.annotation.SuppressLint(value = {"UnsafeOptInUsageError"})
    public void analyze(@org.jetbrains.annotations.NotNull
    androidx.camera.core.ImageProxy imageProxy) {
    }
}