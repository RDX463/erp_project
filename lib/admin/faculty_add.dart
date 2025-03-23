import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacultyAddPage extends StatefulWidget {
  @override
  _FacultyAddPageState createState() => _FacultyAddPageState();
}

class _FacultyAddPageState extends State<FacultyAddPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController empIdController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController salaryController = TextEditingController(); // New Salary Field

  String selectedDepartment = "COM";
  final List<String> departments = ["COM", "AIDS", "MECH", "ENTC", "CIVIL"];
  String generatedPassword = "";

  // Generate a random password
  String generatePassword() {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*!";
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // Send faculty data to backend
  Future<void> addFaculty() async {
    if (_formKey.currentState!.validate()) {
      generatedPassword = generatePassword();
      String empId = "EMP${Random().nextInt(9000) + 1000}";

      final response = await http.post(
        Uri.parse("http://localhost:5000/add_faculty"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "employee_id": empId,
          "department": selectedDepartment,
          "experience": experienceController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "salary": salaryController.text, // Sending salary data
          "password": generatedPassword
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Faculty added successfully!")),
        );
        nameController.clear();
        experienceController.clear();
        emailController.clear();
        phoneController.clear();
        salaryController.clear(); // Clear salary field
        setState(() => generatedPassword = "");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add faculty.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("➕ Add Faculty")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Faculty Name"),
                validator: (value) => value!.isEmpty ? "Enter Faculty Name" : null,
              ),
              DropdownButtonFormField(
                value: selectedDepartment,
                onChanged: (newValue) => setState(() => selectedDepartment = newValue as String),
                items: departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                decoration: InputDecoration(labelText: "Department"),
              ),
              TextFormField(
                controller: experienceController,
                decoration: InputDecoration(labelText: "Experience (Years)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter experience years" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "Enter valid email" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              TextFormField(
                controller: salaryController,
                decoration: InputDecoration(labelText: "Salary (INR)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter salary amount" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addFaculty,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
