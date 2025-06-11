import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  List<Map<String, dynamic>> students = [];
  bool _isLoading = true;

  // Replace with your machine's IP address for device/emulator compatibility
  static const String baseUrl = 'http://127.0.0.1:5000'; // Update IP as needed

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    const url = '$baseUrl/get_students';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            students = (jsonData['students'] as List? ?? []).map((student) => {
                  'student_id': student['student_id']?.toString() ?? 'N/A',
                  'email': student['email']?.toString() ?? 'N/A',
                  'phone': student['phone']?.toString() ?? 'N/A',
                  'department': student['department']?.toString() ?? 'N/A',
                  'year': student['year']?.toString() ?? 'N/A',
                }).toList();
            _isLoading = false;
          });
          print('Parsed students: $students');
        }
      } else {
        throw Exception('Failed to load student data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Error fetching data: $e');
      }
    }
  }

  Future<void> _updateStudentData(Map<String, dynamic> updatedData, String adminName) async {
    const url = '$baseUrl/update_student';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"updated_data": updatedData, "admin": adminName}),
      );
      print('Update response: ${response.body}');
      if (response.statusCode == 200) {
        _showSuccessDialog('Student data updated successfully!');
        await _fetchStudentData();
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        _showErrorDialog('Failed to update student data: $error');
      }
    } catch (e) {
      print('Error updating student data: $e');
      _showErrorDialog('Error updating student data: $e');
    }
  }

  Future<void> _checkAdmissionForm(String studentId) async {
    final url = '$baseUrl/validate_student_id/$studentId';

    try {
      final response = await http.get(Uri.parse(url));
      print('Validate response: ${response.body}');
      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        final data = result['student_data'];

        TextEditingController nameController = TextEditingController(text: data['name']?.toString() ?? '');
        TextEditingController dobController = TextEditingController(text: data['dob']?.toString() ?? '');
        TextEditingController addressController = TextEditingController(text: data['address']?.toString() ?? '');
        TextEditingController fatherController = TextEditingController(text: data['fatherName']?.toString() ?? '');
        TextEditingController motherController = TextEditingController(text: data['motherName']?.toString() ?? '');
        TextEditingController marks10Controller = TextEditingController(text: data['marks10']?.toString() ?? '');
        TextEditingController marks12Controller = TextEditingController(text: data['marks12']?.toString() ?? '');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Edit Admission Info: $studentId',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(
                      labelText: 'DOB',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: fatherController,
                    decoration: InputDecoration(
                      labelText: 'Father Name',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: motherController,
                    decoration: InputDecoration(
                      labelText: 'Mother Name',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: marks10Controller,
                    decoration: InputDecoration(
                      labelText: '10th Marks',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: marks12Controller,
                    decoration: InputDecoration(
                      labelText: '12th Marks',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || dobController.text.isEmpty || addressController.text.isEmpty) {
                    _showErrorDialog('Name, DOB, and Address are required.');
                    return;
                  }
                  final updateResponse = await http.post(
                    Uri.parse('$baseUrl/update_admission_form'),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      'studentId': studentId,
                      'name': nameController.text,
                      'dob': dobController.text,
                      'address': addressController.text,
                      'fatherName': fatherController.text,
                      'motherName': motherController.text,
                      'marks10': int.tryParse(marks10Controller.text) ?? 0,
                      'marks12': int.tryParse(marks12Controller.text) ?? 0,
                    }),
                  );
                  print('Update admission response: ${updateResponse.body}');
                  Navigator.pop(context);

                  if (updateResponse.statusCode == 200) {
                    final updateResult = jsonDecode(updateResponse.body);
                    if (updateResult['status'] == 'success') {
                      _showSuccessDialog('Admission form updated successfully!');
                    } else {
                      _showErrorDialog(updateResult['message'] ?? 'Update failed.');
                    }
                  } else {
                    _showErrorDialog('Failed to update admission form: ${updateResponse.body}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Invalid or missing data. Contact Main Control Center.');
      }
    } catch (e) {
      print('Error validating admission form: $e');
      _showErrorDialog('Error validating admission form: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Error',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Success',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
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

  void _editStudent(Map<String, dynamic> student) {
    TextEditingController emailController = TextEditingController(text: student['email']);
    TextEditingController phoneController = TextEditingController(text: student['phone']);
    TextEditingController departmentController = TextEditingController(text: student['department']);
    TextEditingController yearController = TextEditingController(text: student['year']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Student: ${student['student_id']}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isEmpty || phoneController.text.isEmpty) {
                  _showErrorDialog('Email and Phone are required.');
                  return;
                }
                Map<String, dynamic> updatedData = {
                  'student_id': student['student_id'],
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'department': departmentController.text,
                  'year': yearController.text,
                };
                _updateStudentData(updatedData, 'Admin_Name');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
          'Student Profiles',
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
          : students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                            ) ?? TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'All Students',
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              child: Semantics(
                                label: 'Student ${student['student_id']} profile',
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      student['student_id']?.isNotEmpty == true
                                          ? student['student_id'][0]
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student['student_id'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ) ?? const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        'Email: ${student['email']}',
                                        style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Phone: ${student['phone']}',
                                        style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Dept: ${student['department']}',
                                        style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Year: ${student['year']}',
                                        style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                        onPressed: () => _editStudent(student),
                                        tooltip: 'Edit Student',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info, color: Colors.deepPurple),
                                        onPressed: () => _checkAdmissionForm(student['student_id']),
                                        tooltip: 'Admission Info',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}