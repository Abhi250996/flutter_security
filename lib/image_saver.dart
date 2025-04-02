import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class ImageSaver {
  static const platform = MethodChannel('com.example/security');

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<String?> saveImageToMediaStore(List<int> imageBytes, String fileName) async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      final String? mediaStorePath = await platform.invokeMethod('addToMediaStore', {'path': file.path});
      return mediaStorePath ?? file.path;
    }
    return null;
  }

  Future<String?> captureAndSaveImage() async {
    try {
      if (!await _requestPermission()) return null;
      final String? imagePath = await platform.invokeMethod('captureImage');
      if (imagePath != null) {
        final fileName = 'intruder_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageBytes = await File(imagePath).readAsBytes();
        return await saveImageToMediaStore(imageBytes, fileName);
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> startSecurityService() async {
    try {
      await platform.invokeMethod('startSecurityService');
      print("Security service started");
    } catch (e) {
      print("Error starting service: $e");
    }
  }
}