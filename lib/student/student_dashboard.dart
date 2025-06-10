import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDashboard({super.key, required this.student});

  String getStringValue(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is List && value.isNotEmpty) {
      return value[0].toString();
    } else if (value == null) {
      return 'N/A';
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Student map in dashboard: $student');
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${getStringValue(student['name'])}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Student Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/student_profile',
                  arguments: student,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/student_login');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}