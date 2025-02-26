import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_portal.dart';

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  // Method to handle student login
  Future<void> _login() async {
    String email = emailController.text.trim();
    String studentName = nameController.text.trim();

    if (email.isEmpty || studentName.isEmpty) {
      _showErrorDialog("Please enter both your email and name.");
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/student/login'), // Ensure API URL is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'name': studentName}), // Send both email & name
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // ✅ Successful login → Store email & name in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("student_email", email);
        await prefs.setString("student_name", studentName); // Store student name too

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentPortalPage(email: email, studentName: studentName), // Pass name & email
          ),
        );
      } else {
        _showErrorDialog(responseData["detail"] ?? "Invalid login details.");
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
            SizedBox(height: 20),

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
