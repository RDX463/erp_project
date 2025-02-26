import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // Method to handle the student login
  Future<void> _login() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showErrorDialog("Please enter both name and email.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // API request to check if the student exists in the database
      final response = await http.post(
        Uri.parse('http://localhost:8000/student/login'), // Make sure your API is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200) {
        // Student is logged in
        // Navigate to student portal or homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentPortalPage()),
        );
      } else {
        // Show error if student not found
        _showErrorDialog("Student not found or incorrect details.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again later.");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Login"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name TextField
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Email TextField
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Login Button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                      backgroundColor: Colors.deepPurple, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class StudentPortalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Portal")),
      body: Center(child: Text("Welcome to the Student Portal!")),
    );
  }
}
