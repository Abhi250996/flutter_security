import 'dart:isolate';

import 'package:flutter/material.dart';

// Function to run in the isolate
void isolateFunction(SendPort sendPort) {
  // Simulate some heavy computation
  int result = 0;
  for (int i = 0; i < 5000000; i++) {
    result += i;
  }
  // Send the result back to the main isolate
  sendPort.send(result);
}

class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  State<IsolateExample> createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<IsolateExample> {
  String _result = 'Result1';
  String _result2 = 'Result2';

  Future<void> runIsolate() async {
    // Create a ReceivePort to get messages from the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate
    await Isolate.spawn(isolateFunction, receivePort.sendPort);

    // Listen for the result
    receivePort.listen((message) {
      setState(() {
        _result = 'Result: $message';
      });
      // Close the port when done
      receivePort.close();
    });
  }

  void runWithoutIsolate() async {
    int result = 0;
    for (int i = 0; i < 1000000000; i++) {
      result += i;
    }
    _result2 = result.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Isolate Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_result),
              Text(_result2),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: runIsolate,
                child: const Text('Run with Isolate'),
              ),
              ElevatedButton(
                onPressed: runWithoutIsolate,
                child: const Text('Run without Isolate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
