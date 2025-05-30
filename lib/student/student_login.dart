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
          title: Text("Error", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade500, Colors.purpleAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🎓 App Icon or Image
                      Icon(Icons.school, size: 80, color: Colors.deepPurple),

                      SizedBox(height: 10),
                      Text(
                        "Student Login",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 30),

                      // Name Input Field
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                          labelText: "Full Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Email Input Field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                          labelText: "Email",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                  borderRadius: BorderRadius.circular(12),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
