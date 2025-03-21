import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentFormPage extends StatefulWidget {
  final String studentId;
  const StudentFormPage({super.key, required this.studentId});

  @override
  _StudentFormPageState createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  void submitForm() async {
    const String apiUrl = "http://localhost:5000/submit_student_form";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "student_id": widget.studentId,
        "address": addressController.text,
        "guardian_name": guardianNameController.text,
        "dob": dobController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Form submitted successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit form!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Details Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(addressController, "Address"),
            const SizedBox(height: 10),
            buildTextField(guardianNameController, "Guardian's Name"),
            const SizedBox(height: 10),
            buildTextField(dobController, "Date of Birth (DD/MM/YYYY)"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitForm,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }
}
