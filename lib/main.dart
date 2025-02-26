import 'package:flutter/material.dart';
import 'student/student_login.dart';
import 'admin/admin_login.dart';
import 'faculty/faculty_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Role Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.deepPurple, // AppBar color
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the ERP System',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),
              // Role Buttons
              RoleButton(role: 'Student', page: StudentLoginPage()),
              RoleButton(role: 'Admin', page: const AdminLoginPage()),
              RoleButton(role: 'Faculty', page: const FacultyLoginPage()),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String role;
  final Widget page;
  
  const RoleButton({super.key, required this.role, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // Correct parameter for background color
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          elevation: 5,
        ),
        child: Text(
          'Login as $role',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Ensure text is white for visibility
          ),
        ),
      ),
    );
  }
}
