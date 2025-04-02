package com.example.flutter_map;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class UnlockReceiver extends BroadcastReceiver {
    private static int failedAttempts = 0;

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_USER_PRESENT.equals(intent.getAction())) {
            Log.d("UnlockReceiver", "✅ Device unlocked successfully.");
            failedAttempts = 0; // Reset on successful unlock
        } else if (Intent.ACTION_SCREEN_ON.equals(intent.getAction())) {
            failedAttempts++;
            Log.d("UnlockReceiver", "🚨 Failed attempt detected: " + failedAttempts);

            if (failedAttempts >= 2) {  // ✅ Take picture after 2 failed attempts
                Log.d("UnlockReceiver", "📸 Taking picture...");
                Intent cameraIntent = new Intent(context, CameraService.class);
                context.startForegroundService(cameraIntent);
            }
        }
    }
}
