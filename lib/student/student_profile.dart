import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StudentProfilePage extends StatefulWidget {
  final String email;
  final String studentName;

  const StudentProfilePage({Key? key, required this.email, required this.studentName}) : super(key: key);

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();

  String selectedGender = "Male";
  DateTime? selectedDOB;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final url = Uri.parse("http://localhost:8000/get_student_profile?email=${Uri.encodeComponent(widget.email)}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fullNameController.text = data['full_name'] ?? widget.studentName;
        emailController.text = data['email'] ?? widget.email;
        addressController.text = data['address'] ?? "";
        phoneController.text = data['phone'] ?? "";
        fatherNameController.text = data['father_name'] ?? "";
        motherNameController.text = data['mother_name'] ?? "";
        selectedGender = data['gender'] ?? "Male";

        if (data['dob'] != null && data['dob'].isNotEmpty) {
          selectedDOB = DateTime.parse(data['dob']);
        }

        if (data['profile_picture'] != null && data['profile_picture'].isNotEmpty) {
          _saveImageToTempDirectory(data['profile_picture']).then((file) {
            setState(() {
              _image = file;
            });
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${response.body}")),
      );
    }
  }

  Future<File> _saveImageToTempDirectory(String base64Image) async {
    List<int> imageBytes = base64Decode(base64Image);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/profile_picture.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    String? base64Image;
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    final profileData = {
      "email": emailController.text,
      "full_name": fullNameController.text,
      "address": addressController.text,
      "father_name": fatherNameController.text,
      "mother_name": motherNameController.text,
      "phone": phoneController.text,
      "gender": selectedGender,
      "dob": selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : "",
      "profile_picture": base64Image,
    };

    try {
      final url = Uri.parse("http://localhost:8000/update_student_profile");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDOB ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDOB) {
      setState(() {
        selectedDOB = picked;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      backgroundColor: Colors.white,
                      child: _image == null ? Icon(Icons.camera_alt, size: 50, color: Colors.deepPurple) : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.studentName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.email, style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField("Full Name", fullNameController),
                  _buildTextField("Email", emailController, readOnly: true),
                  _buildTextField("Address", addressController),
                  _buildTextField("Phone", phoneController),
                  _buildTextField("Father Name", fatherNameController),
                  _buildTextField("Mother Name", motherNameController),
                  const SizedBox(height: 10),

                  // Gender Selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text("Male"),
                          value: "Male",
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: Text("Female"),
                          value: "Female",
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Date of Birth Selection
                  GestureDetector(
                    onTap: () => _selectDOB(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : "Select Date of Birth",
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}