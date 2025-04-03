package com.example.flutter_map;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.graphics.ImageFormat;
import android.hardware.camera2.*;
import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;

public class UnlockDetectionService extends Service {
    private static final String CHANNEL_ID = "UnlockServiceChannel";
    private CameraManager cameraManager;
    private CameraDevice cameraDevice;
    private ImageReader imageReader;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();

        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Security Service Running")
                .setContentText("Monitoring failed unlock attempts...")
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .build();

        startForeground(1, notification);
        openCamera();
    }

    private void openCamera() {
        try {
            cameraManager = (CameraManager) getSystemService(CAMERA_SERVICE);
            String frontCameraId = getFrontCameraId();

            if (frontCameraId == null) {
                Log.e("UnlockDetectionService", "Front camera not found!");
                stopSelf();
                return;
            }

            imageReader = ImageReader.newInstance(640, 480, ImageFormat.JPEG, 1);
            imageReader.setOnImageAvailableListener(reader -> {
                Image image = reader.acquireLatestImage();
                if (image != null) {
                    saveImage(image);
                    image.close();
                }
                stopSelf();
            }, new Handler());

            cameraManager.openCamera(frontCameraId, stateCallback, new Handler());
        } catch (Exception e) {
            Log.e("UnlockDetectionService", "Error opening camera: " + e.getMessage());
        }
    }

    private String getFrontCameraId() throws CameraAccessException {
        for (String cameraId : cameraManager.getCameraIdList()) {
            CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraId);
            Integer facing = characteristics.get(CameraCharacteristics.LENS_FACING);
            if (facing != null && facing == CameraCharacteristics.LENS_FACING_FRONT) {
                return cameraId;
            }
        }
        return null;
    }

    private final CameraDevice.StateCallback stateCallback = new CameraDevice.StateCallback() {
        @Override
        public void onOpened(CameraDevice camera) {
            cameraDevice = camera;
            try {
                CaptureRequest.Builder captureBuilder = camera.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
                captureBuilder.addTarget(imageReader.getSurface());

                camera.createCaptureSession(
                        java.util.Collections.singletonList(imageReader.getSurface()),
                        new CameraCaptureSession.StateCallback() {
                            @Override
                            public void onConfigured(CameraCaptureSession session) {
                                try {
                                    session.capture(captureBuilder.build(), null, new Handler());
                                } catch (CameraAccessException e) {
                                    Log.e("UnlockDetectionService", "Capture failed: " + e.getMessage());
                                }
                            }

                            @Override
                            public void onConfigureFailed(CameraCaptureSession session) {
                                Log.e("UnlockDetectionService", "Camera session configuration failed");
                            }
                        },
                        new Handler()
                );
            } catch (CameraAccessException e) {
                Log.e("UnlockDetectionService", "Camera access error: " + e.getMessage());
            }
        }

        @Override
        public void onDisconnected(CameraDevice camera) {
            camera.close();
            cameraDevice = null;
        }

        @Override
        public void onError(CameraDevice camera, int error) {
            Log.e("UnlockDetectionService", "Camera error: " + error);
            camera.close();
            cameraDevice = null;
        }
    };

    private void saveImage(Image image) {
        try {
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            byte[] bytes = new byte[buffer.remaining()];
            buffer.get(bytes);

            File file = new File(getFilesDir(), "intruder.jpg");
            FileOutputStream output = new FileOutputStream(file);
            output.write(bytes);
            output.close();
            Log.d("UnlockDetectionService", "Image saved to: " + file.getAbsolutePath());
        } catch (Exception e) {
            Log.e("UnlockDetectionService", "Image saving error: " + e.getMessage());
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Unlock Detection Service", NotificationManager.IMPORTANCE_DEFAULT);
            getSystemService(NotificationManager.class).createNotificationChannel(channel);
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
