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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Login Function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String employeeId = employeeIdController.text.trim();
    String password = passwordController.text.trim();

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
        _showErrorSnackBar(responseBody['detail'] ?? "Invalid credentials");
      }
    } catch (e) {
      _showErrorSnackBar("Network error! Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show Error SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Navigate to root route (/) when back button is pressed
  Future<bool> _onBackPressed() async {
    Navigator.pushReplacementNamed(context, '/');
    return false; // Prevent default back behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Back Button
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                              onPressed: _onBackPressed,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Logo Placeholder
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              'assets/logo.jpg', // Fixed logo path
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade100,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Logo Error",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Title
                          Text(
                            "Admin Portal",
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 32,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 32),
                          // Employee ID Field
                          TextFormField(
                            controller: employeeIdController,
                            decoration: InputDecoration(
                              labelText: "Employee ID",
                              prefixIcon: Icon(
                                Icons.badge,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? "Employee ID is required" : null,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) =>
                                value == null || value.isEmpty ? "Password is required" : null,
                          ),
                          const SizedBox(height: 24),
                          // Loading Indicator or Login Button
                          _isLoading
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                )
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).secondaryHeaderColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                          // Sign-up Redirect
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminSignupPage()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    employeeIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}