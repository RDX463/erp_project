import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_fees_pay.dart';

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
  final TextEditingController rollNoController = TextEditingController();

  String selectedCategory = "OPEN";
  String selectedDepartment = "COM";
  String selectedDivision = "A";
  String studentId = "";
  bool isScholarshipApplicable = false;
  bool isAdmitted = false;

  final List<String> categories = ["OBC", "SC", "NT", "ST", "OPEN"];
  final List<String> departments = ["COM", "AIDS", "MECH", "ENTC", "CIVIL"];
  final List<String> divisions = ["A", "B", "C", "D"];
  final String admissionYear = "FE";

  void checkScholarshipEligibility() {
    setState(() {
      isScholarshipApplicable = selectedCategory != "OPEN";
    });
  }

  void admitStudent() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        allotmentController.text.isEmpty ||
        rollNoController.text.isEmpty) {
      _showDialog("Error", "All fields are required.");
      return;
    }

    checkScholarshipEligibility();

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
          "department": selectedDepartment,
          "division": selectedDivision,
          "roll_no": int.parse(rollNoController.text),
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          studentId = responseBody["student_id"];
          isAdmitted = true;
        });
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

  void goToFeesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFeesPayPage(
          studentId: studentId,
          isScholarshipApplicable: isScholarshipApplicable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Admission"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
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
            buildTextField(rollNoController, "Roll Number", Icons.format_list_numbered, TextInputType.number),
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

            buildDropdown("Division", divisions, selectedDivision, (String? value) {
              setState(() {
                selectedDivision = value!;
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
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  children: [
                    const Text(
                      "✅ Student Admitted!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("Generated Student ID:"),
                    Text(
                      studentId,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Division: $selectedDivision",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: goToFeesPage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Go to Fees Payment"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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
