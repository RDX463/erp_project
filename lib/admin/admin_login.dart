import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_signup.dart';
import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final String logoPath = '/assets/logo.jpg'; // Ensure the logo is in "assets/"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA), // Light teal background
      appBar: AppBar(
        backgroundColor: Color(0xFF00796B), // Dark teal
        title: const Text("Admin Login", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 5,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container (Auto-Fitting)
              IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 3), // Soft shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit.fitWidth, // Adjust to width while keeping aspect ratio
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 100, color: Colors.red);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Employee ID Field
              buildTextField(
                controller: employeeIdController,
                label: "Employee ID",
                icon: Icons.person,
                inputType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              // Password Field
              buildTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00796B), // Dark teal
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign-up Redirect
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminSignupPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Color(0xFF00796B), fontSize: 16), // Dark teal
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF00796B)), // Dark teal
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00796B), width: 2), // Dark teal
        ),
      ),
    );
  }

  // Login Function
  void _login() async {
    setState(() => _isLoading = true);

    String employeeId = employeeIdController.text.trim();
    String password = passwordController.text.trim();

    if (employeeId.isEmpty || password.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      setState(() => _isLoading = false);
      return;
    }

    final url = 'http://localhost:5000/admin_login'; // API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "employee_id": employeeId,
          "password": password,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              employeeId: employeeId, // Pass employee ID to dashboard
            ),
          ),
        );
      } else {
        _showErrorDialog(responseBody['detail'] ?? "Invalid credentials");
      }
    } catch (e) {
      _showErrorDialog("Network error! Please try again.");
    }

    setState(() => _isLoading = false);
  }

  // Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Failed"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Color(0xFF00796B))), // Dark teal
            ),
          ],
        );
      },
    );
  }
}