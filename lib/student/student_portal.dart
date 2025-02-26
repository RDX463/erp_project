import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_profile.dart';
import 'fees_page.dart';

class StudentPortalPage extends StatefulWidget {
  final String email;
  final String studentName;

  const StudentPortalPage({Key? key, required this.email, required this.studentName}) : super(key: key);

  @override
  _StudentPortalPageState createState() => _StudentPortalPageState();
}

class _StudentPortalPageState extends State<StudentPortalPage> {
  String studentName = "Unknown";
  String studentEmail = "";

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  // Fetch Student Name & Email from SharedPreferences
  Future<void> fetchStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString("student_name");
    String? email = prefs.getString("student_email");

    setState(() {
      studentName = name ?? widget.studentName;
      studentEmail = email ?? widget.email;
    });
  }

  // Navigate to Profile Page
  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfilePage(email: studentEmail, studentName: studentName),
      ),
    );
  }

  // Navigate to Fees Page
  void navigateToFees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeesPaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Portal")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome, $studentName!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildPortalCard("Profile", Icons.person, navigateToProfile),
                _buildPortalCard("Fees", Icons.attach_money, navigateToFees),
                _buildPortalCard("Attendance", Icons.event_available, () {}),
                _buildPortalCard("Notices & Events", Icons.notifications, () {}),
                _buildPortalCard("Documents", Icons.folder, () {}),
                _buildPortalCard("Timetable", Icons.schedule, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build portal cards
  Widget _buildPortalCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
