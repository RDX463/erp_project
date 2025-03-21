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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: const Text("Admin Login", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent.shade100,
                child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),

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

              // Login Button with Loading Indicator
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
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

              // Sign-up Redirection
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminSignupPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
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
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  // Function to handle login
  void _login() async {
    setState(() => _isLoading = true);

    String employeeId = employeeIdController.text.trim();
    String password = passwordController.text.trim();

    if (employeeId.isEmpty || password.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      setState(() => _isLoading = false);
      return;
    }

    final url = 'http://localhost:5000/admin_login'; // Your API URL

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

  // Function to show error message
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
              child: const Text("OK", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}
