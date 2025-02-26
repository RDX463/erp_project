import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_profile.dart';
import 'fees_page.dart';

class StudentPortalPage extends StatefulWidget {
  final String email; // Accept email as a parameter

  const StudentPortalPage({Key? key, required this.email}) : super(key: key);

  @override
  _StudentPortalPageState createState() => _StudentPortalPageState();
}

class _StudentPortalPageState extends State<StudentPortalPage> {
  String studentName = "Unknown"; // Default values
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
      studentName = name ?? "Unknown";
      studentEmail = email ?? "";
    });
  }

  // Navigate to Profile Page (Pass Retrieved Email)
  void navigateToProfile(BuildContext context) {
    if (studentEmail.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentProfilePage(email: studentEmail),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Email not found! Please log in again.")),
      );
    }
  }

  // Navigate to Fees Page
  void navigateToFees(BuildContext context) {
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
              "Welcome, $studentName", // Show Student Name
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
                _buildPortalCard(context, "Profile", Icons.person, () => navigateToProfile(context)),
                _buildPortalCard(context, "Fees", Icons.attach_money, () => navigateToFees(context)),
                _buildPortalCard(context, "Attendance", Icons.event_available, () {}),
                _buildPortalCard(context, "Notices & Events", Icons.notifications, () {}),
                _buildPortalCard(context, "Documents", Icons.folder, () {}),
                _buildPortalCard(context, "Timetable", Icons.schedule, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
