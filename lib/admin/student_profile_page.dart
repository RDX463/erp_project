import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentProfilePage extends StatefulWidget {
  final String studentId;

  StudentProfilePage({required this.studentId});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _profilePictureUrl = "";

  // Fetch student profile data from API
  Future<void> _getStudentProfile() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/student/profile/${widget.studentId}'),
    );

    if (response.statusCode == 200) {
      final studentData = json.decode(response.body);
      setState(() {
        _emailController.text = studentData['email'] ?? '';
        _nameController.text = studentData['full_name'] ?? '';
        _phoneController.text = studentData['phone'] ?? '';
        _branchController.text = studentData['branch'] ?? '';
        _dobController.text = studentData['dob'] ?? '';
        _fatherNameController.text = studentData['father_name'] ?? '';
        _motherNameController.text = studentData['mother_name'] ?? '';
        _semesterController.text = studentData['semester'] ?? '';
        _addressController.text = studentData['address'] ?? '';
        _profilePictureUrl = studentData['profile_picture'] ?? '';
      });
    } else {
      throw Exception('Failed to load student profile');
    }
  }

  // Update student profile data using API
  Future<void> _updateProfile() async {
    final response = await http.put(
      Uri.parse('http://localhost:5000/student/profile/${widget.studentId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_id': widget.studentId,
        'email': _emailController.text,
        'full_name': _nameController.text,
        'phone': _phoneController.text,
        'branch': _branchController.text,
        'dob': _dobController.text,
        'father_name': _fatherNameController.text,
        'mother_name': _motherNameController.text,
        'semester': _semesterController.text,
        'address': _addressController.text,
        'profile_picture': _profilePictureUrl,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      throw Exception('Failed to update profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _getStudentProfile();  // Fetch profile data when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _branchController,
                decoration: InputDecoration(labelText: 'Branch'),
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
              ),
              TextFormField(
                controller: _fatherNameController,
                decoration: InputDecoration(labelText: 'Father Name'),
              ),
              TextFormField(
                controller: _motherNameController,
                decoration: InputDecoration(labelText: 'Mother Name'),
              ),
              TextFormField(
                controller: _semesterController,
                decoration: InputDecoration(labelText: 'Semester'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
