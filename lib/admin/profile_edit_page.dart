import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileEditPage extends StatefulWidget {
  final String studentId;

  ProfileEditPage({required this.studentId});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController branchController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    branchController = TextEditingController();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final response = await http.get(Uri.parse("http://localhost:5000/student/profile/${widget.studentId}"));
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        branchController.text = data['branch'] ?? '';
        isLoading = false;
      });
    } else {
      // Handle error
      print("Failed to fetch profile data");
    }
  }

  Future<void> updateProfile() async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/student/complete-profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "student_id": widget.studentId,
        "full_name": nameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "branch": branchController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated profile
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Profile updated successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Handle error
      print("Failed to update profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name"),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: "Enter your name"),
                  ),
                  SizedBox(height: 16),
                  Text("Phone"),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(hintText: "Enter your phone number"),
                  ),
                  SizedBox(height: 16),
                  Text("Email"),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Enter your email"),
                  ),
                  SizedBox(height: 16),
                  Text("Branch"),
                  TextField(
                    controller: branchController,
                    decoration: InputDecoration(hintText: "Enter your branch"),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: updateProfile,
                    child: Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}
