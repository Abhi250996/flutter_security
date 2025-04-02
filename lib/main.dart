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
      home: Scaffold(
        appBar: AppBar(title: Text("Security App")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                print('Calling startSecurityService method');
                final String result = await platform.invokeMethod(
                  'startSecurityService',
                );
                print(result); // Expected: "Security service started"
              } on PlatformException catch (e) {
                print("Error: ${e.message}");
              }
            },
            child: Text("Start Security"),
          ),
        ),
      ),
    );
  }
}
