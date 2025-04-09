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
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController allotmentController = TextEditingController();

  String selectedCategory = "OPEN";
  String selectedDepartment = "COM";
  String selectedDivision = "A";
  bool isScholarshipApplicable = false;

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
    if (emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        allotmentController.text.isEmpty) {
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
          "email": emailController.text,
          "phone": phoneController.text,
          "category": selectedCategory,
          "allotment_number": allotmentController.text,
          "department": selectedDepartment,
          "division": selectedDivision,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          studentIdController.text = responseBody["student_id"];
        });
      } else {
        _showDialog("Error", responseBody["message"] ?? "Failed to admit student.");
      }
    } catch (e) {
      _showDialog("Error", "Network error! Please try again.");
    }
  }

  void goToFeesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFeesPayPage(
          studentId: studentIdController.text,
          isScholarshipApplicable: isScholarshipApplicable,
        ),
      ),
    );
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            buildTextField(studentIdController, "Student ID", Icons.badge, TextInputType.text, true),
            const SizedBox(height: 10),
            buildTextField(emailController, "Email ID", Icons.email, TextInputType.emailAddress),
            const SizedBox(height: 10),
            buildTextField(phoneController, "Phone Number", Icons.phone, TextInputType.phone),
            const SizedBox(height: 10),
            buildTextField(allotmentController, "Allotment Number", Icons.confirmation_number),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: buildDropdown("Category", categories, selectedCategory, (String? value) {
                    setState(() {
                      selectedCategory = value!;
                      checkScholarshipEligibility();
                    });
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildDropdown("Department", departments, selectedDepartment, (String? value) {
                    setState(() {
                      selectedDepartment = value!;
                    });
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildDropdown("Division", divisions, selectedDivision, (String? value) {
                    setState(() {
                      selectedDivision = value!;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Year: $admissionYear", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: admitStudent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Admit Student", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            if (studentIdController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: goToFeesPage,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Proceed to Fees Payment"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ Updated to support 4 arguments (with readOnly as optional positional)
  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType type = TextInputType.text,
    bool readOnly = false,
  ]) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
