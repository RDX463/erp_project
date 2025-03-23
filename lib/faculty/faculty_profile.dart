import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacultyProfilePage extends StatefulWidget {
  final String employeeId;

  const FacultyProfilePage({super.key, required this.employeeId});

  @override
  _FacultyProfilePageState createState() => _FacultyProfilePageState();
}

class _FacultyProfilePageState extends State<FacultyProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String gender = "Male"; // Default gender
  List<String> selectedYears = [];
  List<String> selectedSubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacultyProfile();
  }

  /// Fetch faculty details from FastAPI backend
  Future<void> fetchFacultyProfile() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/faculty/profile/${widget.employeeId}"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          nameController.text = data["faculty_name"]?.trim().isNotEmpty == true ? data["faculty_name"] : "Unknown Faculty";
          emailController.text = data["email"] ?? "";
          phoneController.text = data["phone"] ?? "";
          departmentController.text = data["department"] ?? "";
          addressController.text = data["address"] ?? "Not Provided";
          dobController.text = data["dob"] ?? "N/A";
          gender = data["gender"] ?? "Male";
          selectedYears = List<String>.from(data["teaching_years"] ?? []);
          selectedSubjects = List<String>.from(data["subjects"] ?? []);
          isLoading = false;
        });
      } else {
        showError("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching profile: $e");
    }
  }

  /// Debugging: Print request payload before updating
  void debugRequestPayload(Map<String, dynamic> requestData) {
    print("Request Payload: ${jsonEncode(requestData)}");
  }

  /// Update faculty profile
  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      showError("Faculty name cannot be empty");
      return;
    }

    final Map<String, dynamic> requestData = {
      "faculty_name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "department": departmentController.text.trim(),
      "address": addressController.text.trim().isEmpty ? null : addressController.text.trim(),
      "dob": dobController.text.trim().isEmpty ? null : dobController.text.trim(),
      "gender": gender,
      "teaching_years": selectedYears,
      "subjects": selectedSubjects,
    };

    debugRequestPayload(requestData);

    try {
      final response = await http.put(
        Uri.parse("http://127.0.0.1:8000/faculty/profile/update/${widget.employeeId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        showSuccess("Profile updated successfully!");
      } else {
        showError("Failed to update profile: ${jsonDecode(response.body)["detail"]}");
      }
    } catch (e) {
      showError("Error updating profile: $e");
    }
  }

  /// Show error messages
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Show success messages
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name"), readOnly: true),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email"), readOnly: true),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone"), readOnly: true),
                    TextField(controller: departmentController, decoration: const InputDecoration(labelText: "Department"), readOnly: true),
                    TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
                    TextField(controller: dobController, decoration: const InputDecoration(labelText: "Date of Birth")),

                    const SizedBox(height: 10),
                    const Text("Gender"),
                    DropdownButton<String>(
                      value: gender,
                      onChanged: (newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      items: ["Male", "Female", "Other"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    const Text("Teaching Years"),
                    Column(
                      children: ["FE", "SE", "TE", "BE"].map((year) {
                        return CheckboxListTile(
                          title: Text(year),
                          value: selectedYears.contains(year),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (!selectedYears.contains(year)) {
                                  selectedYears.add(year);
                                }
                              } else {
                                selectedYears.remove(year);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    const Text("Subjects"),
                    TextField(
                      controller: TextEditingController(text: selectedSubjects.join(", ")),
                      decoration: const InputDecoration(labelText: "Subjects (comma separated)"),
                      onChanged: (value) {
                        setState(() {
                          selectedSubjects = value.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateProfile,
                      child: const Text("Update Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
