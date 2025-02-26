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

  // Load Student Profile
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

  // Save profile picture to temp directory
  Future<File> _saveImageToTempDirectory(String base64Image) async {
    List<int> imageBytes = base64Decode(base64Image);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/profile_picture.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Save Student Profile
  Future<void> _saveProfile() async {
    final profileData = {
      "email": emailController.text,
      "full_name": fullNameController.text,
      "address": addressController.text,
      "father_name": fatherNameController.text,
      "mother_name": motherNameController.text,
      "phone": phoneController.text,
      "gender": selectedGender,
      "dob": selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : "",
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

  // Select Date of Birth
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

  @override
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

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
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
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

                  // Date of Birth Picker
                  GestureDetector(
                    onTap: () => _selectDOB(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : ""),
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gender Selection (Radio Buttons)
                  Row(
                    children: [
                      Text("Gender: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Radio(value: "Male", groupValue: selectedGender, onChanged: (value) => setState(() => selectedGender = value!)),
                      Text("Male"),
                      Radio(value: "Female", groupValue: selectedGender, onChanged: (value) => setState(() => selectedGender = value!)),
                      Text("Female"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40)),
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
