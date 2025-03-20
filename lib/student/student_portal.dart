import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_profile.dart';
import 'fees_page.dart';
import 'attendance_page.dart';
import 'notices_events_page.dart'; // Import Notices & Events page
import 'documents_page.dart'; // Import Documents Upload page

class StudentPortalPage extends StatefulWidget {
  final String email;
  final String studentName;

  const StudentPortalPage({Key? key, required this.email, required this.studentName}) : super(key: key);

  @override
  _StudentPortalPageState createState() => _StudentPortalPageState();
}

class _StudentPortalPageState extends State<StudentPortalPage> with TickerProviderStateMixin {
  String studentName = "Unknown";
  String studentEmail = "";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();

    // Animation Controller for Button Press Effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  // Navigation Methods
  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfilePage(email: studentEmail, studentName: studentName),
      ),
    );
  }

  void navigateToFees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeesPaymentPage()),
    );
  }

  void navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AttendancePage(email: studentEmail)),
    );
  }

  void navigateToNoticesEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoticesEventsPage()), // Navigate to Notices & Events page
    );
  }

  void navigateToDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DocumentsPage()), // Navigate to Documents Upload page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Portal"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Welcome Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome, $studentName!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            // List of Options with Animated Buttons
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAnimatedButton("Profile", Icons.person, navigateToProfile, Colors.blueAccent),
                  _buildAnimatedButton("Fees", Icons.attach_money, navigateToFees, Colors.greenAccent),
                  _buildAnimatedButton("Attendance", Icons.event_available, navigateToAttendance, Colors.orangeAccent),
                  _buildAnimatedButton("Notices & Events", Icons.notifications, navigateToNoticesEvents, Colors.redAccent), 
                  _buildAnimatedButton("Documents", Icons.folder, navigateToDocuments, Colors.tealAccent), // ✅ Documents Page Added
                  _buildAnimatedButton("Timetable", Icons.schedule, () {}, Colors.purpleAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Animated Button with Unique Color
  Widget _buildAnimatedButton(String title, IconData icon, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: ScaleTransition(
          scale: _animationController,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
