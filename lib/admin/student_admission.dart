import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentAdmissionPage extends StatefulWidget {
  const StudentAdmissionPage({super.key});

  @override
  _StudentAdmissionPageState createState() => _StudentAdmissionPageState();
}

class _StudentAdmissionPageState extends State<StudentAdmissionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController allotmentController = TextEditingController();

  String selectedCategory = "OPEN";
  String selectedDepartment = "COM";
  String studentId = "";  // Store generated Student ID
  bool isScholarshipApplicable = false;
  final List<String> categories = ["OBC", "SC", "NT", "ST", "OPEN"];
  final List<String> departments = ["COM", "AIDS", "MECH", "ENTC", "CIVIL"];
  final String admissionYear = "FE";

  void generateStudentId() {
    final random = Random();
    setState(() {
      studentId = "STU${random.nextInt(9000) + 1000}"; // Random 4-digit Student ID
    });
  }

  void checkScholarshipEligibility() {
    setState(() {
      isScholarshipApplicable = selectedCategory != "OPEN";
    });
  }

  void admitStudent() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        allotmentController.text.isEmpty) {
      _showDialog("Error", "All fields are required.");
      return;
    }

    generateStudentId();
    checkScholarshipEligibility();

    // Backend API URL
    const String apiUrl = "http://localhost:5000/admit_student";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "category": selectedCategory,
          "allotment_number": allotmentController.text,
          "department": selectedDepartment
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          studentId = responseBody["student_id"];  // Set the student ID received from the backend
        });

        _showDialog("Success",
            "Student Admitted Successfully!\n\n"
            "Student ID: $studentId\n"
            "Allotment Number: ${allotmentController.text}\n"
            "Name: ${nameController.text}\n"
            "Email: ${emailController.text}\n"
            "Phone: ${phoneController.text}\n"
            "Category: $selectedCategory\n"
            "Scholarship: ${isScholarshipApplicable ? "Applicable" : "Not Applicable"}\n"
            "Year: $admissionYear\n"
            "Department: $selectedDepartment\n\n"
            "A form link has been sent to ${emailController.text} for further details.");
      } else {
        _showDialog("Error", responseBody["message"] ?? "Failed to admit student.");
      }
    } catch (e) {
      _showDialog("Error", "Network error! Please try again.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Admission"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(nameController, "Student Name", Icons.person),
            const SizedBox(height: 10),
            buildTextField(emailController, "Email ID", Icons.email, TextInputType.emailAddress),
            const SizedBox(height: 10),
            buildTextField(phoneController, "Phone Number", Icons.phone, TextInputType.phone),
            const SizedBox(height: 10),
            buildTextField(allotmentController, "Allotment Number", Icons.confirmation_number),
            const SizedBox(height: 10),
            buildDropdown("Category", categories, selectedCategory, (String? value) {
              setState(() {
                selectedCategory = value!;
                checkScholarshipEligibility();
              });
            }),
            const SizedBox(height: 10),
            buildDropdown("Department", departments, selectedDepartment, (String? value) {
              setState(() {
                selectedDepartment = value!;
              });
            }),
            const SizedBox(height: 10),
            Text("Year: $admissionYear", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: admitStudent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Admit Student", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            if (studentId.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Student ID Generated:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      studentId,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType type = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
