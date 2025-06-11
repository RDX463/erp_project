import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Helper function to parse student data and convert lists to strings
  Map<String, dynamic> parseStudentData(Map<String, dynamic> data) {
    return {
      'name': data['name'] is List && data['name'].isNotEmpty
          ? data['name'][0].toString()
          : data['name']?.toString() ?? 'N/A',
      'student_id': data['student_id']?.toString() ?? 'N/A',
      'email': data['email'] is List && data['email'].isNotEmpty
          ? data['email'][0].toString()
          : data['email']?.toString() ?? 'N/A',
      'department': data['department'] is List && data['department'].isNotEmpty
          ? data['department'][0].toString()
          : data['department']?.toString() ?? 'N/A',
      'address': data['address'] is List && data['address'].isNotEmpty
          ? data['address'][0].toString()
          : data['address']?.toString() ?? 'N/A',
      'fathers name': data['fathers name'] is List && data['fathers name'].isNotEmpty
          ? data['fathers name'][0].toString()
          : data['fathers name']?.toString() ?? 'N/A',
      'mothers name': data['mothers name'] is List && data['mothers name'].isNotEmpty
          ? data['mothers name'][0].toString()
          : data['mothers name']?.toString() ?? 'N/A',
      '10th marks': data['10th marks'] is List && data['10th marks'].isNotEmpty
          ? data['10th marks'][0].toString()
          : data['10th marks']?.toString() ?? 'N/A',
      '12th marks': data['12th marks'] is List && data['12th marks'].isNotEmpty
          ? data['12th marks'][0].toString()
          : data['12th marks']?.toString() ?? 'N/A',
    };
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('http://127.0.0.1:5000/student_login');
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_id": _studentIdController.text.trim(),
          "password": _passwordController.text,
          "email": _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API response student data: ${data['student']}');
        Navigator.pushReplacementNamed(
          context,
          '/student_dashboard',
          arguments: parseStudentData(data['student']),
        );
      } else {
        setState(() {
          _errorMessage = json.decode(response.body)['detail'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                          IconButton(
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
                              'assets/logo.jpg',
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
                            "Student Portal",
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                  fontSize: 32,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 32),
                          // Student ID Field
                          TextFormField(
                            controller: _studentIdController,
                            decoration: InputDecoration(
                              labelText: "Student ID",
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your Student ID";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Password (Your Student ID)",
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              if (value != _studentIdController.text.trim()) {
                                return "Password must match your Student ID";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Loading Indicator
                          if (_isLoading)
                            CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          // Error Message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Sign In Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
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
                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Contact admin to reset password"),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
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
    _studentIdController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}