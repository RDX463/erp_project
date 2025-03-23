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

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  // Fetch student details
  Future<void> _fetchStudentData() async {
    const url = 'http://localhost:5000/get_students';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            students = List<Map<String, dynamic>>.from(jsonData['students']);
            _isLoading = false;
          });
        } else {
          throw Exception("Unexpected data format");
        }
      } else {
        throw Exception("Failed to load student data");
      }
    } catch (e) {
      _showErrorDialog("Error fetching data. Please check your connection.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update student details
  Future<void> _updateStudentData(Map<String, dynamic> updatedData, String adminName) async {
    const url = 'http://localhost:5000/update_student';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"updated_data": updatedData, "admin": adminName}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Student data updated successfully!");
        _fetchStudentData(); // Refresh list
      } else {
        _showErrorDialog("Failed to update student data.");
      }
    } catch (e) {
      _showErrorDialog("Error updating student data.");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Edit student details
  void _editStudent(Map<String, dynamic> student) {
    TextEditingController nameController = TextEditingController(text: student['name']);
    TextEditingController emailController = TextEditingController(text: student['email']);
    TextEditingController phoneController = TextEditingController(text: student['phone']);
    TextEditingController departmentController = TextEditingController(text: student['department']);
    TextEditingController yearController = TextEditingController(text: student['year']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Student: ${student['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: departmentController, decoration: const InputDecoration(labelText: "Department")),
              TextField(controller: yearController, decoration: const InputDecoration(labelText: "Year")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  "student_id": student['student_id'],
                  "name": nameController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "department": departmentController.text,
                  "year": yearController.text,
                };
                _updateStudentData(updatedData, "Admin_Name"); // Replace with actual admin name
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Student Profiles"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    "All Students",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16.0,
                        columns: const [
                          DataColumn(label: Text("Student ID")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Department")),
                          DataColumn(label: Text("Year")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: students.map((student) {
                          return DataRow(cells: [
                            DataCell(Text(student["student_id"])),
                            DataCell(Text(student["name"])),
                            DataCell(Text(student["email"])),
                            DataCell(Text(student["phone"] ?? "N/A")),
                            DataCell(Text(student["department"])),
                            DataCell(Text(student["year"])),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => _editStudent(student),
                                child: const Text("Edit"),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
