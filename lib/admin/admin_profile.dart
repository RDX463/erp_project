import 'package:flutter/material.dart';

class AdminProfilePage extends StatelessWidget {
  final String employeeId; // Accept employeeId

  const AdminProfilePage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 20),
                Text(
                  "Employee ID: $employeeId",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
