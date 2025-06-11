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
      _showErrorSnackBar("All fields are required.");
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Student admitted successfully!"),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        _showErrorSnackBar(responseBody["message"] ?? "Failed to admit student.");
      }
    } catch (e) {
      _showErrorSnackBar("Network error! Please try again.");
    }
  }

  void goToFeesPage() {
    if (studentIdController.text.isEmpty) {
      _showErrorSnackBar("Please admit the student first.");
      return;
    }
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
          "Student Admission",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Admit New Student",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      buildTextField(
                        studentIdController,
                        "Student ID",
                        Icons.badge,
                        TextInputType.text,
                        true,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        emailController,
                        "Email ID",
                        Icons.email,
                        TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        phoneController,
                        "Phone Number",
                        Icons.phone,
                        TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      buildTextField(
                        allotmentController,
                        "Allotment Number",
                        Icons.confirmation_number,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: buildDropdown(
                              "Category",
                              categories,
                              selectedCategory,
                              (String? value) {
                                setState(() {
                                  selectedCategory = value!;
                                  checkScholarshipEligibility();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildDropdown(
                              "Department",
                              departments,
                              selectedDepartment,
                              (String? value) {
                                setState(() {
                                  selectedDepartment = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildDropdown(
                              "Division",
                              divisions,
                              selectedDivision,
                              (String? value) {
                                setState(() {
                                  selectedDivision = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Year: $admissionYear",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: admitStudent,
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
                              "Admit Student",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (studentIdController.text.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: goToFeesPage,
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
                                  Colors.green,
                                  Colors.green.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.arrow_forward, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Proceed to Fees Payment",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType type = TextInputType.text,
    bool readOnly = false,
  ]) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.list,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}