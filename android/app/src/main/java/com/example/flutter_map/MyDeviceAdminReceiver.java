package com.example.flutter_map;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class MyDeviceAdminReceiver extends DeviceAdminReceiver {
    private static final String TAG = "DeviceAdminReceiver";
    private static int failedAttempts = 0;

    @Override
    public void onPasswordFailed(Context context, Intent intent) {
        failedAttempts++;

 
        if (failedAttempts >= 2) {  // If wrong password entered twice
            failedAttempts = 0;  // Reset count

            // Start the foreground service to take a picture
            Intent serviceIntent = new Intent(context, UnlockDetectionService.class);
            context.startForegroundService(serviceIntent);
        }
    }
}
