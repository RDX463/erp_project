import 'package:flutter/material.dart';
import 'admin_profile.dart';
import 'student_module.dart';
import 'faculty_module.dart';
import 'accounts_module.dart';

class AdminDashboard extends StatefulWidget {
  final String employeeId; // Change to employeeId

  const AdminDashboard({super.key, required this.employeeId});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    StudentModule(),
    FacultyModule(),
    AdminModule(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Logged-in admin info
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Profile") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProfilePage(
                      employeeId: widget.employeeId, // Pass employeeId instead
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "Profile", child: Text("View Profile")),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(widget.employeeId, // Show employee ID instead
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Faculty"),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Accounts"),
        ],
      ),
    );
  }
}
