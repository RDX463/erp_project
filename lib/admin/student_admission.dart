import 'package:flutter/material.dart';

class StudentAdmissionPage extends StatelessWidget {
  const StudentAdmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Admission")),
      body: const Center(child: Text("Student Admission Form")),
    );
  }
}
