package com.example.flutter_map;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

public class UnlockDetectionService extends Service {

    private static final String TAG = "UnlockDetectionService";
    private static final String CHANNEL_ID = "UnlockServiceChannel";

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        startForeground(1, getNotification());

        Log.d(TAG, "Unlock Detection Service Started");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Start your unlock detection logic here (register receivers for SCREEN ON, FAILED PASSWORD ATTEMPTS, etc.)
        return START_STICKY;
    }

    private Notification getNotification() {
        return new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Intruder Detection Active")
                .setContentText("Monitoring failed unlock attempts...")
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Unlock Detection",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
