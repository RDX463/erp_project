import 'package:flutter/material.dart';
import 'faculty_profile.dart';

class FacultyDashboard extends StatelessWidget {
  final String facultyName;
  final String employeeId; // Added Employee ID to fetch profile details

  const FacultyDashboard({super.key, required this.facultyName, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // Profile icon in top-right
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacultyProfilePage(employeeId: employeeId),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Welcome, $facultyName",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
