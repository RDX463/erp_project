import 'package:flutter/material.dart';
import 'faculty_details.dart';
import 'faculty_salary.dart';
import 'faculty_income_tax.dart';
import 'faculty_or_pr_allotment.dart';
import 'faculty_leave_management.dart'; 
import 'faculty_add.dart'; // Import Faculty Adding Page

class FacultyModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("👨‍🏫 Faculty Module")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildModuleTile(context, "➕ Add Faculty", FacultyAddPage()), // New Faculty Adding Page
          _buildModuleTile(context, "📋 Faculty Details", FacultyDetailsPage()),
          _buildModuleTile(context, "💰 Faculty Salary", FacultySalaryPage()),
          _buildModuleTile(context, "🧾 Faculty Income Tax", FacultyIncomeTaxPage()),
          _buildModuleTile(context, "📜 OR-PR External Allotment", FacultyORPRAllotmentPage()),
          _buildModuleTile(context, "🗓️ Faculty Leave Management", FacultyLeaveManagementPage()),
        ],
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, String title, Widget page) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      ),
    );
  }
}
