import 'package:flutter/material.dart';

class FacultyDashboard extends StatelessWidget {
  final String facultyName;

  const FacultyDashboard({super.key, required this.facultyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Dashboard")),
      body: Center(
        child: Text(
          "Welcome, $facultyName",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
