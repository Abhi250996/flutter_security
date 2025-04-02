import 'package:flutter/material.dart';

import 'image_saver.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intruder Capture',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageSaver _imageSaver = ImageSaver();
  List<String> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _imageSaver.startSecurityService();
    ImageSaver.platform.setMethodCallHandler((call) async {
      if (call.method == "imageCaptured") {
        final String? path = call.arguments as String?;
        if (path != null) {
          setState(() {
            _capturedImages.add(path);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Intruder image captured at: $path")),
          );
        }
      }
    });
  }

  Future<void> _manualCapture() async {
    final String? path = await _imageSaver.captureAndSaveImage();
    if (path != null) {
      setState(() {
        _capturedImages.add(path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Manual image saved at: $path")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Intruder Capture")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _manualCapture,
            child: Text("Manual Capture (Test)"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _capturedImages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Image ${index + 1}: ${_capturedImages[index]}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}