import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StudentProfilePage extends StatefulWidget {
  final String email;

  StudentProfilePage({required this.email});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  File? _image;
  final picker = ImagePicker();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  String selectedGender = "Male";
  String selectedBranch = "Computer";
  String selectedSemester = "4th Semester";
  DateTime? selectedDOB;
  int year = 1;

  List<String> genders = ["Male", "Female"];
  List<String> branches = ["Computer", "AIDS", "ENTC", "Civil", "Mechanical"];
  List<String> semesters = [
    "1st Semester", "2nd Semester", "3rd Semester", "4th Semester",
    "5th Semester", "6th Semester", "7th Semester", "8th Semester"
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  Future<void> _loadProfile() async {
    final url = Uri.parse("http://localhost:8000/get_student_profile?email=${Uri.encodeComponent(widget.email)}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Fetch email from the student collection (non-editable)
        emailController.text = data['email'] ?? widget.email;

        fullNameController.text = data['full_name'] ?? "";
        addressController.text = data['address'] ?? "";
        phoneController.text = data['phone'] ?? "";
        fatherNameController.text = data['father_name'] ?? "";
        motherNameController.text = data['mother_name'] ?? "";
        selectedGender = data['gender'] ?? "Male";
        selectedBranch = branches.contains(data['branch']) ? data['branch'] : "Computer";
        selectedSemester = semesters.contains(data['semester']) ? data['semester'] : "4th Semester";
        year = data['year'] ?? 1;

        // Set Date of Birth and calculate Age
        if (data['dob'] != null && data['dob'].isNotEmpty) {
          selectedDOB = DateTime.parse(data['dob']);
          ageController.text = (DateTime.now().year - selectedDOB!.year).toString();
        }

        // Load Profile Picture
        if (data['profile_picture'] != null && data['profile_picture'].isNotEmpty) {
          _saveImageToTempDirectory(data['profile_picture']).then((file) {
            setState(() {
              _image = file;
            });
          });
        } else {
          _image = null;
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

  bool _validateForm() {
    if (fullNameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty || fatherNameController.text.isEmpty || motherNameController.text.isEmpty || addressController.text.isEmpty) {
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
      appBar: AppBar(title: Text("Student Profile")),
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
              TextField(controller: fullNameController, decoration: InputDecoration(labelText: "Full Name")),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email"), readOnly: true),
              TextField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
              TextField(controller: fatherNameController, decoration: InputDecoration(labelText: "Father Name")),
              TextField(controller: motherNameController, decoration: InputDecoration(labelText: "Mother Name")),

              SizedBox(height: 20),
              Text("Date of Birth"),
              ElevatedButton(
                onPressed: () => _selectDOB(context),
                child: Text(selectedDOB == null
                    ? "Select DOB"
                    : DateFormat('yyyy-MM-dd').format(selectedDOB!)),
              ),

              TextField(controller: ageController, decoration: InputDecoration(labelText: "Age"), readOnly: true),

              SizedBox(height: 20),
              Text("Gender"),
              DropdownButton<String>(
                value: selectedGender.isNotEmpty ? selectedGender : null, // Ensure the value is not empty
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: genders.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProfile, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
