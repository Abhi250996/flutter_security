package com.example.flutter_map;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example/security";
    private static final int REQUEST_PERMISSIONS = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestPermissions();  // Request permissions
    }

    private void requestPermissions() {
        // Permissions needed for Android 15+ (API 30)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // API 33 (Android 15+)
            ActivityCompat.requestPermissions(this, new String[]{
                    Manifest.permission.CAMERA,
                    Manifest.permission.FOREGROUND_SERVICE,
                    Manifest.permission.READ_MEDIA_IMAGES,
                    Manifest.permission.POST_NOTIFICATIONS
            }, REQUEST_PERMISSIONS);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {  // For Android 6.0+ (API 23)
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(this, Manifest.permission.FOREGROUND_SERVICE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{
                        Manifest.permission.CAMERA,
                        Manifest.permission.FOREGROUND_SERVICE
                }, REQUEST_PERMISSIONS);
            } else {
                startUnlockDetectionService();  // Start service if permission already granted
            }
        } else {
            startUnlockDetectionService();  // No permission request needed for below Android 6.0 (API 23)
        }
    }

    private void startUnlockDetectionService() {
        Intent intent = new Intent(this, UnlockDetectionService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent);  // Use startForegroundService for API 26+ (Android Oreo and above)
        } else {
            startService(intent);  // Use startService for older versions
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Create MethodChannel to communicate with Flutter code
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("startSecurityService")) {
                        startUnlockDetectionService();
                        result.success("Security service started");
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_PERMISSIONS) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }
            if (allGranted) {
                startUnlockDetectionService();  // Start the service once permissions are granted
            } else {
                Toast.makeText(this, "Permissions denied, cannot start service", Toast.LENGTH_LONG).show();
            }
        }
    }
}
