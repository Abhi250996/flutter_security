package com.example.flutter_map;

import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example/security";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startSecurityService")) {
                    startSecurityService();
                    result.success("Security service started");
                } else if (call.method.equals("enableDeviceAdmin")) {
                    enableDeviceAdmin();
                    result.success("Device Admin Activation Requested");
                } else {
                    result.notImplemented();
                }
            });
    }

    private void startSecurityService() {
        Intent intent = new Intent(this, UnlockDetectionService.class);
        startService(intent);
    }

    private void enableDeviceAdmin() {
        ComponentName componentName = new ComponentName(this, MyDeviceAdminReceiver.class);
        Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName);
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "This app needs admin access to detect failed unlock attempts.");
        startActivity(intent);
    }
}
