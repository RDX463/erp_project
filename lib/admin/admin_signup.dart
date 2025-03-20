import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSignupPage extends StatefulWidget {
  const AdminSignupPage({super.key});

  @override
  _AdminSignupPageState createState() => _AdminSignupPageState();
}

class _AdminSignupPageState extends State<AdminSignupPage> {
  TextEditingController employeeIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false; // For showing loading indicator

  // Function to handle signup
  Future<void> signupAdmin() async {
    setState(() => isLoading = true);

    String employeeId = employeeIdController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (employeeId.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showSnackbar("Please fill in all fields");
      setState(() => isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      showSnackbar("Passwords do not match");
      setState(() => isLoading = false);
      return;
    }

    final Map<String, String> data = {
      'employee_id': employeeId,
      'password': password,
      'confirm_password': confirmPassword
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/admin_signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        showSnackbar("Signup successful!");
      } else {
        final errorMessage = json.decode(response.body)['detail'] ?? 'Signup failed';
        showSnackbar(errorMessage);
      }
    } catch (e) {
      showSnackbar("Network error! Please try again.");
    }

    setState(() => isLoading = false);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Soft background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo (Optional)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent.shade100,
                  child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Admin Signup',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 30),

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

                const SizedBox(height: 20),

                // Confirm Password Field
                buildTextField(
                  controller: confirmPasswordController,
                  label: "Re-enter Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 30),

                // Signup Button with Loading Indicator
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signupAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Redirection
                TextButton(
                  onPressed: () {
                    // Navigate to login page (Add navigation logic)
                  },
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
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
}
