import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<dynamic> studentData = [];

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // Fetch student data
  Future<void> fetchStudents() async {
    try {
      final data = await apiService.fetchStudentsData();  // Fetch data from API
      setState(() {
        studentData = data;  // Update the student data list with the fetched data
      });
    } catch (e) {
      print('Error fetching student data: $e');
      // Optionally show a snackbar or a dialog to indicate error to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Student Accounts'),
      ),
      body: studentData.isEmpty
          ? Center(child: CircularProgressIndicator())  // Show loading indicator while data is being fetched
          : ListView.builder(
              itemCount: studentData.length,
              itemBuilder: (context, index) {
                var student = studentData[index];
                return ListTile(
                  title: Text(student['full_name'] ?? 'No name'),
                  subtitle: Text(student['email'] ?? 'No email'),
                );
              },
            ),
    );
  }
}
