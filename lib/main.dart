import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel("com.example/security");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: HomeScreen(), // Ensure HomeScreen is inside MaterialApp
    );
  }
}

class HomeScreen extends StatelessWidget {
  static const platform = MethodChannel("com.example/security");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Security App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final String result = await platform.invokeMethod(
                    'startSecurityService',
                  );
                  print(result);
                } on PlatformException catch (e) {
                  print("Error: ${e.message}");
                }
              },
              child: Text("Start Security"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: enableDeviceAdmin,
              child: Text("Enable Device Admin"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to ImageScreen
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => ImageScreen()));
              },
              child: Text("View Captured Images"),
            ),
          ],
        ),
      ),
    );
  }

  /// Enable Device Admin for detecting failed unlock attempts
  void enableDeviceAdmin() async {
    try {
      print('Requesting Device Admin Activation');
      final String result = await platform.invokeMethod('enableDeviceAdmin');
      print(result); // Expected: "Device Admin Activation Requested"
    } on PlatformException catch (e) {
      print("Error enabling device admin: ${e.message}");
    }
  }
}

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final String directoryPath = "/data/user/0/com.example.flutter_map/files/";
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    loadImages(); // Load images when screen opens
  }

  void loadImages() {
    Directory dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      setState(() {
        imageFiles = [];
      });
      return;
    }

    List<FileSystemEntity> files = dir.listSync();

    setState(() {
      imageFiles =
          files
              .where((file) => file.path.endsWith(".jpg"))
              .map((file) => File(file.path))
              .toList();
      imageFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      ); // Newest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Captured Images")),
      body:
          imageFiles.isNotEmpty
              ? ListView.builder(
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Image.file(imageFiles[index]),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Captured: ${imageFiles[index].lastModifiedSync()}",
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
              : Center(child: Text("No images captured yet")),
      floatingActionButton: FloatingActionButton(
        onPressed: loadImages, // Refresh the image list
        child: Icon(Icons.refresh),
      ),
    );
  }
}
