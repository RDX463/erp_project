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
      appBar: AppBar(
        title: const Text("Faculty Profile"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[50],
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              nameController.text.isNotEmpty 
                                  ? nameController.text[0].toUpperCase() 
                                  : "?",
                              style: TextStyle(
                                fontSize: 36, 
                                color: Colors.indigo, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nameController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            departmentController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Information Section
                          _buildSectionHeader("Personal Information"),
                          _buildCard([
                            _buildReadOnlyField(
                              controller: nameController,
                              label: "Full Name",
                              icon: Icons.person,
                            ),
                            _buildReadOnlyField(
                              controller: emailController,
                              label: "Email Address",
                              icon: Icons.email,
                            ),
                            _buildReadOnlyField(
                              controller: phoneController,
                              label: "Phone Number",
                              icon: Icons.phone,
                            ),
                            _buildTextField(
                              controller: addressController,
                              label: "Address",
                              icon: Icons.home,
                            ),
                            _buildTextField(
                              controller: dobController,
                              label: "Date of Birth",
                              icon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 10),
                            _buildGenderDropdown(),
                          ]),
                          
                          const SizedBox(height: 24),
                          
                          // Academic Information Section
                          _buildSectionHeader("Academic Information"),
                          _buildCard([
                            _buildReadOnlyField(
                              controller: departmentController,
                              label: "Department",
                              icon: Icons.business,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Teaching Years",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo,
                              ),
                            ),
                            _buildYearsSelection(),
                            const SizedBox(height: 16),
                            _buildSubjectsField(),
                          ]),
                          
                          const SizedBox(height: 24),
                          
                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
  
  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
  
  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gender,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
              style: const TextStyle(
                color: Colors.black87, 
                fontSize: 16,
              ),
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
          ),
        ),
      ],
    );
  }
  
  Widget _buildYearsSelection() {
    return Column(
      children: ["FE", "SE", "TE", "BE"].map((year) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedYears.contains(year) ? Colors.indigo : Colors.grey[300]!,
            ),
            color: selectedYears.contains(year) ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
          ),
          child: CheckboxListTile(
            title: Text(
              year,
              style: TextStyle(
                fontWeight: selectedYears.contains(year) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            value: selectedYears.contains(year),
            activeColor: Colors.indigo,
            checkColor: Colors.white,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSubjectsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subjects",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: selectedSubjects.join(", ")),
          decoration: InputDecoration(
            hintText: "Enter subjects (comma separated)",
            prefixIcon: const Icon(Icons.subject, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedSubjects = value.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            });
          },
          maxLines: 2,
        ),
      ],
    );
  }
}