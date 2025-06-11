import 'package:flutter/material.dart';
import 'student_profile.dart';
import 'document_upload.dart';
import 'student_result_upload.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDashboard({super.key, required this.student});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.student['name']}',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentUpload(student: widget.student),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentResultUploadPage(
                            studentId: widget.student['student_id'].toString(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Result'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/student_profile',
                        arguments: widget.student,
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize without building widgets that depend on Theme
  }

  @override
  Widget build(BuildContext context) {
    // Define pages here to ensure Theme.of(context) is available
    final List<Widget> pages = [
      _buildDashboardContent(),
      Container(), // Placeholder for Results page
      Container(), // Placeholder for Documents page
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        title: Text(
          "Student Dashboard",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Profile") {
                Navigator.pushNamed(
                  context,
                  '/student_profile',
                  arguments: widget.student,
                );
              } else if (value == "Logout") {
                Navigator.pushReplacementNamed(context, '/student_login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Profile",
                child: Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text("View Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text("Logout"),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    widget.student['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).secondaryHeaderColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Image.asset(
                      'assets/logo.jpg',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade100,
                          ),
                          child: const Center(
                            child: Text(
                              "Logo Error",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Student: ${widget.student['name']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Theme.of(context).primaryColor),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
              title: const Text("Upload Document"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentUpload(student: widget.student),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.upload, color: Theme.of(context).primaryColor),
              title: const Text("Upload Result"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentResultUploadPage(
                      studentId: widget.student['student_id'].toString(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/student_profile',
                  arguments: widget.student,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/student_login');
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 28),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 28),
            label: "Results",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 28),
            label: "Documents",
          ),
        ],
      ),
    );
  }
}