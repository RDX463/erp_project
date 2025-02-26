import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'student_login.dart';

class StudentSignupPage extends StatefulWidget {
  const StudentSignupPage({super.key});

  @override
  _StudentSignupPageState createState() => _StudentSignupPageState();
}

class _StudentSignupPageState extends State<StudentSignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureReenterText = true;

  Future<void> _signup() async {
    if (passwordController.text != reenterPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:8000/student/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful! Redirecting to login...")),
      );

      // Wait for 2 seconds before navigating
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentLoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Signup'),
        backgroundColor: Colors.deepPurple, // Customize the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Makes the page scrollable if the keyboard appears
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '📧 Email',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password TextField
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '🔒 Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                obscureText: _obscureText,
              ),
              const SizedBox(height: 16),

              // Re-enter Password TextField
              TextField(
                controller: reenterPasswordController,
                decoration: InputDecoration(
                  labelText: '🔑 Re-enter Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureReenterText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureReenterText = !_obscureReenterText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                obscureText: _obscureReenterText,
              ),
              const SizedBox(height: 20),

              // Signup Button
              ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
              backgroundColor: Colors.deepPurple, // Correct way to set the button color
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
                    ),
                  ),
            child: const Text(
                'Signup',
                style: TextStyle(fontSize: 18, color: Colors.white), // Text style
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
