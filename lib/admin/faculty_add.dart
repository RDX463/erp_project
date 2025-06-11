import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacultyAddPage extends StatefulWidget {
  const FacultyAddPage({super.key});

  @override
  _FacultyAddPageState createState() => _FacultyAddPageState();
}

class _FacultyAddPageState extends State<FacultyAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  String selectedDepartment = "COM";
  final List<String> departments = ["COM", "AIDS", "MECH", "ENTC", "CIVIL"];
  String generatedPassword = "";
  bool _isLoading = false;

  // Replace with your machine's IP address for device/emulator compatibility
  static const String baseUrl = 'http://127.0.0.1:5000'; // Update IP as needed

  // Generate a random password
  String _generatePassword() {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*!";
    return List.generate(12, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // Validate email using regex as a fallback
  bool _validateEmail(String email) {
    // Basic email regex validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Send faculty data to backend
  Future<void> _addFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    generatedPassword = _generatePassword();
    String empId = "EMP${Random().nextInt(9000) + 1000}";
    empIdController.text = empId;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_faculty'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "employee_id": empId,
          "department": selectedDepartment,
          "experience": experienceController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
          "salary": salaryController.text.trim(),
          "password": generatedPassword,
        }),
      );

      print('Add faculty response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _showSuccessDialog(empId);
        nameController.clear();
        empIdController.clear();
        experienceController.clear();
        emailController.clear();
        phoneController.clear();
        salaryController.clear();
        setState(() => generatedPassword = "");
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add faculty: $error'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('Error adding faculty: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding faculty: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String empId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Success',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty added successfully!',
              style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee ID: $empId',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              'Password: $generatedPassword',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    empIdController.dispose();
    experienceController.dispose();
    emailController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        title: Text(
          'Add Faculty',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Faculty',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ) ?? const TextStyle(
                                  fontSize: 22,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Semantics(
                            label: 'Faculty Name',
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Faculty Name',
                                prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty ? 'Enter Faculty Name' : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Employee ID',
                            child: TextFormField(
                              controller: empIdController,
                              decoration: InputDecoration(
                                labelText: 'Employee ID (Auto-generated)',
                                prefixIcon: Icon(Icons.badge, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Department',
                            child: DropdownButtonFormField<String>(
                              value: selectedDepartment,
                              onChanged: (newValue) => setState(() => selectedDepartment = newValue!),
                              items: departments
                                  .map((dept) => DropdownMenuItem<String>(
                                        value: dept,
                                        child: Text(dept),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'Department',
                                prefixIcon: Icon(Icons.school, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Experience',
                            child: TextFormField(
                              controller: experienceController,
                              decoration: InputDecoration(
                                labelText: 'Experience (Years)',
                                prefixIcon: Icon(Icons.work_history, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter experience years';
                                final num = int.tryParse(value);
                                if (num == null || num < 0) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Email',
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter email';
                                if (!_validateEmail(value.trim())) return 'Enter a valid email';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Phone Number',
                            child: TextFormField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter phone number';
                                if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                                  return 'Enter a valid 10-digit phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label: 'Salary',
                            child: TextFormField(
                              controller: salaryController,
                              decoration: InputDecoration(
                                labelText: 'Salary (INR)',
                                prefixIcon: Icon(Icons.currency_rupee, color: Theme.of(context).primaryColor),
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter salary amount';
                                final num = double.tryParse(value);
                                if (num == null || num <= 0) return 'Enter a valid salary';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            label: 'Submit Faculty Details',
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _addFaculty,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Submit',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ) ??
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
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
    );
  }
}