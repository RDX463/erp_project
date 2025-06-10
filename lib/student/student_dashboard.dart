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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student ID: ${getStringValue(student['student_id'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Name: ${getStringValue(student['name'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${getStringValue(student['email'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Department: ${getStringValue(student['department'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Address: ${getStringValue(student['address'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Father\'s Name: ${getStringValue(student['fathers name'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Mother\'s Name: ${getStringValue(student['mothers name'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '10th Marks: ${getStringValue(student['10th marks'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '12th Marks: ${getStringValue(student['12th marks'])}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/student_login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}