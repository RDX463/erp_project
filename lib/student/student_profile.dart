import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StudentProfilePage extends StatefulWidget {
  final String email;
  final String studentName; // Fetch student name from login

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
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();

  String selectedGender = "Male";
  String selectedBranch = "Computer";
  String selectedSemester = "4th Semester";
  DateTime? selectedDOB;
  int year = 1;

  final List<String> genders = ["Male", "Female"];
  final List<String> branches = ["Computer", "AIDS", "ENTC", "Civil", "Mechanical"];
  final List<String> semesters = [
    "1st Semester", "2nd Semester", "3rd Semester", "4th Semester",
    "5th Semester", "6th Semester", "7th Semester", "8th Semester"
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  // Select Date of Birth
  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDOB = picked;
        ageController.text = (DateTime.now().year - picked.year).toString();
      });
    }
  }

  // Load student profile from backend
  Future<void> _loadProfile() async {
    final url = Uri.parse("http://localhost:8000/get_student_profile?email=${Uri.encodeComponent(widget.email)}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        emailController.text = data['email'] ?? widget.email;
        fullNameController.text = data['full_name'] ?? widget.studentName;
        addressController.text = data['address'] ?? "";
        phoneController.text = data['phone'] ?? "";
        fatherNameController.text = data['father_name'] ?? "";
        motherNameController.text = data['mother_name'] ?? "";
        selectedGender = data['gender'] ?? "Male";
        selectedBranch = branches.contains(data['branch']) ? data['branch'] : "Computer";
        selectedSemester = semesters.contains(data['semester']) ? data['semester'] : "4th Semester";
        year = data['year'] ?? 1;

        if (data['dob'] != null && data['dob'].isNotEmpty) {
          selectedDOB = DateTime.parse(data['dob']);
          ageController.text = (DateTime.now().year - selectedDOB!.year).toString();
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

  // Save profile picture to temporary directory
  Future<File> _saveImageToTempDirectory(String base64Image) async {
    List<int> imageBytes = base64Decode(base64Image);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/profile_picture.png');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  // Save student profile to backend
  Future<void> _saveProfile() async {
    if (_validateForm()) {
      String? base64Image;
      if (_image != null) {
        List<int> imageBytes = await _image!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final profileData = {
        "email": emailController.text,
        "full_name": fullNameController.text,
        "address": addressController.text,
        "age": int.tryParse(ageController.text) ?? 0,
        "branch": selectedBranch,
        "dob": selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : "",
        "father_name": fatherNameController.text,
        "mother_name": motherNameController.text,
        "gender": selectedGender,
        "phone": phoneController.text,
        "semester": selectedSemester,
        "year": year,
        "profile_picture": base64Image ?? "",
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
  }

  // Validate input fields
  bool _validateForm() {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        fatherNameController.text.isEmpty ||
        motherNameController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the required fields")),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Profile"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.camera_alt, size: 50) : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Full Name", fullNameController),
              _buildTextField("Email", emailController, readOnly: true),
              _buildTextField("Address", addressController),
              _buildTextField("Phone", phoneController),
              _buildTextField("Father Name", fatherNameController),
              _buildTextField("Mother Name", motherNameController),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProfile, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: readOnly,
    );
  }
}
