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
        _fetchStudentData();
      } else {
        _showErrorDialog("Failed to update student data.");
      }
    } catch (e) {
      _showErrorDialog("Error updating student data.");
    }
  }

  Future<void> _checkAdmissionForm(String studentId) async {
  final url = 'http://localhost:5000/validate_student_id/$studentId';

  try {
    final response = await http.get(Uri.parse(url));
    final result = json.decode(response.body);

    if (response.statusCode == 200 && result['status'] == 'success') {
      final data = result['student_data'];

      // Controllers for editable fields
      TextEditingController nameController = TextEditingController(text: data["name"]);
      TextEditingController dobController = TextEditingController(text: data["dob"]);
      TextEditingController addressController = TextEditingController(text: data["address"]);
      TextEditingController fatherController = TextEditingController(text: data["fatherName"]);
      TextEditingController motherController = TextEditingController(text: data["motherName"]);
      TextEditingController marks10Controller = TextEditingController(text: data["marks10"].toString());
      TextEditingController marks12Controller = TextEditingController(text: data["marks12"].toString());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit Admission Info: $studentId"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: dobController, decoration: InputDecoration(labelText: "DOB")),
                TextField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
                TextField(controller: fatherController, decoration: InputDecoration(labelText: "Father Name")),
                TextField(controller: motherController, decoration: InputDecoration(labelText: "Mother Name")),
                TextField(controller: marks10Controller, decoration: InputDecoration(labelText: "10th Marks"), keyboardType: TextInputType.number),
                TextField(controller: marks12Controller, decoration: InputDecoration(labelText: "12th Marks"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updateResponse = await http.post(
                  Uri.parse("http://localhost:5000/update_admission_form"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "studentId": studentId,
                    "name": nameController.text,
                    "dob": dobController.text,
                    "address": addressController.text,
                    "fatherName": fatherController.text,
                    "motherName": motherController.text,
                    "marks10": int.tryParse(marks10Controller.text) ?? 0,
                    "marks12": int.tryParse(marks12Controller.text) ?? 0,
                  }),
                );

                final updateResult = json.decode(updateResponse.body);
                Navigator.pop(context);

                if (updateResponse.statusCode == 200 && updateResult["status"] == "success") {
                  _showSuccessDialog("Admission form updated successfully!");
                } else {
                  _showErrorDialog(updateResult["message"] ?? "Update failed.");
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
    } else {
      _showErrorDialog(result['message'] ?? "Invalid or missing data. Contact Main Control Center.");
    }
  } catch (e) {
    _showErrorDialog("Error validating admission form: $e");
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.green)),
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
          title: Text("Edit Student: ${student['student_id']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "department": departmentController.text,
                  "year": yearController.text,
                };
                _updateStudentData(updatedData, "Admin_Name");
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
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Department")),
                          DataColumn(label: Text("Year")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: students.map((student) {
                          return DataRow(cells: [
                            DataCell(Text(student["student_id"])),
                            DataCell(Text(student["email"])),
                            DataCell(Text(student["phone"] ?? "N/A")),
                            DataCell(Text(student["department"])),
                            DataCell(Text(student["year"])),
                            DataCell(Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _editStudent(student),
                                  child: const Text("Edit"),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed: () => _checkAdmissionForm(student["student_id"]),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                  child: const Text("Admission Info"),
                                ),
                              ],
                            )),
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
