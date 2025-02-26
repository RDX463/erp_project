import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fees_page.dart';  // Add this import

class AdminAdmissionPage extends StatefulWidget {
  @override
  _AdminAdmissionPageState createState() => _AdminAdmissionPageState();
}

class _AdminAdmissionPageState extends State<AdminAdmissionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  
  bool isLoading = false;

  Future<void> admitStudent() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://localhost:5000/admin/admit-student'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "email": emailController.text,
        "total_fees": double.parse(feesController.text)
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String studentId = data["student_id"]; // Only using student_id now

      // Navigate to the Fees Page with the student_id
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeesPage(studentId: studentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to admit student")),
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
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Student Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: feesController,
              decoration: InputDecoration(labelText: "Total Fees"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: admitStudent,
                    child: Text("Admit Student"),
                  ),
          ],
        ),
      ),
    );
  }
}
