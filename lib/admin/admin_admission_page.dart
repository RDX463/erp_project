import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fees_page.dart';

class AdminAdmissionPage extends StatefulWidget {
  @override
  _AdminAdmissionPageState createState() => _AdminAdmissionPageState();
}

class _AdminAdmissionPageState extends State<AdminAdmissionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(); // Added password field

  bool isLoading = false;

  Future<void> admitStudent() async {
    setState(() {
      isLoading = true;
    });

    // Validate input
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        feesController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/admin/admit-student'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "total_fees": double.tryParse(feesController.text) ?? 0.0, // Prevent parsing errors
          "password": passwordController.text, // Added password field
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String studentId = data["student_id"];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeesPage(studentId: studentId),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['detail']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admit Student")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Student Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: feesController, decoration: InputDecoration(labelText: "Total Fees"), keyboardType: TextInputType.number),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: admitStudent, child: Text("Admit Student")),
          ],
        ),
      ),
    );
  }
}
