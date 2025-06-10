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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                                onPressed: _onBackPressed,
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.school,
                            size: 60,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Student Portal",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _studentIdController,
                            decoration: InputDecoration(
                              labelText: "Student ID",
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
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
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
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
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Password (Your Student ID)",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
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
                          if (_isLoading) const CircularProgressIndicator(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.blueAccent],
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
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Contact admin to reset password"),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.blue),
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