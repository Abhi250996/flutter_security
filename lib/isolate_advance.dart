import 'dart:isolate';
import 'package:flutter/material.dart';

// Data model
class User {
  final int id;
  final String name;
  final int age;

  User(this.id, this.name, this.age);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age};
}

// Message class for isolate communication
class IsolateMessage {
  final SendPort sendPort;
  final List<User> users;

  IsolateMessage(this.sendPort, this.users);
}

// Isolate function to process data
void processDataInIsolate(IsolateMessage message) async {
  try {
    final sendPort = message.sendPort;
    final users = message.users;

    // Simulate progress updates
    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      sendPort.send('Progress: $i%');
    }

    // Filter users (e.g., age > 25) and sort by name
    final filteredUsers =
        users.where((user) => user.age > 25).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    // Send final result
    sendPort.send(filteredUsers.map((u) => u.toJson()).toList());
  } catch (e) {
    message.sendPort.send('Error: $e');
  }
}

class AdvancedIsolateExample extends StatefulWidget {
  const AdvancedIsolateExample({super.key});

  @override
  State<AdvancedIsolateExample> createState() => _AdvancedIsolateExampleState();
}

class _AdvancedIsolateExampleState extends State<AdvancedIsolateExample> {
  String _status = 'Idle';
  double _progress = 0.0;
  List<User> _processedUsers = [];
  Isolate? _isolate;
  late ReceivePort _receivePort;

  // Generate sample data
  List<User> generateSampleData() {
    return List.generate(
      1000,
      (index) => User(index, 'User $index', 20 + (index % 60)),
    );
  }

  Future<void> startProcessing() async {
    setState(() {
      _status = 'Starting...';
      _progress = 0.0;
      _processedUsers = [];
    });

    _receivePort = ReceivePort();
    final users = generateSampleData();

    // Spawn isolate
    _isolate = await Isolate.spawn(
      processDataInIsolate,
      IsolateMessage(_receivePort.sendPort, users),
    );

    // Listen to isolate messages
    _receivePort.listen((message) {
      if (message is String) {
        if (message.startsWith('Progress')) {
          setState(() {
            _status = message;
            _progress =
                double.parse(message.split(': ')[1].replaceAll('%', '')) / 100;
          });
        } else if (message.startsWith('Error')) {
          setState(() {
            _status = message;
          });
          _cleanup();
        }
      } else if (message is List) {
        setState(() {
          _processedUsers =
              message
                  .map((json) => User(json['id'], json['name'], json['age']))
                  .toList();
          _status = 'Completed';
        });
        _cleanup();
      }
    });
  }

  void _cleanup() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort.close();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Advanced Isolate Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $_status', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _status == 'Idle' || _status == 'Completed'
                        ? startProcessing
                        : null,
                child: const Text('Process Data in Isolate'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    _processedUsers.isEmpty
                        ? const Center(child: Text('No data processed yet'))
                        : ListView.builder(
                          itemCount: _processedUsers.length,
                          itemBuilder: (context, index) {
                            final user = _processedUsers[index];
                            return ListTile(
                              title: Text(user.name),
                              subtitle: Text('Age: ${user.age}'),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
