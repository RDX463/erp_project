import 'package:flutter/material.dart';

class StudentPromotionPage extends StatelessWidget {
  const StudentPromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Promotion")),
      body: const Center(child: Text("Promote Students Based on Results")),
    );
  }
}
