import 'package:flutter/material.dart';
import 'admin_profile.dart';
import 'student_module.dart';
import 'faculty_module.dart';
import 'accounts_module.dart';

class AdminDashboard extends StatefulWidget {
  final String employeeId;

  const AdminDashboard({super.key, required this.employeeId});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  final List<Widget> _pages = [
    StudentModule(),
    FacultyModule(),
    AdminModule(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "Profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminProfilePage(
                        employeeId: widget.employeeId,
                      ),
                    ),
                  );
                }
              },
              offset: const Offset(0, 50),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Profile",
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.green[700], size: 20),
                      const SizedBox(width: 10),
                      const Text("View Profile"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "Settings",
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.green[700], size: 20),
                      const SizedBox(width: 10),
                      const Text("Settings"),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.employeeId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 15,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0 ? Colors.green.withOpacity(0.1) : Colors.transparent,
                ),
                child: const Icon(Icons.school),
              ),
              label: "Students",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1 ? Colors.green.withOpacity(0.1) : Colors.transparent,
                ),
                child: const Icon(Icons.people),
              ),
              label: "Faculty",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 2 ? Colors.green.withOpacity(0.1) : Colors.transparent,
                ),
                child: const Icon(Icons.admin_panel_settings),
              ),
              label: "Accounts",
            ),
          ],
        ),
      ),
    );
  }
}