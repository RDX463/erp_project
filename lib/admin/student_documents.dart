import 'package:flutter/material.dart';

class StudentDocumentsPage extends StatelessWidget {
  const StudentDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Documents")),
      body: const Center(child: Text("Manage Student Documents")),
    );
  }
}
