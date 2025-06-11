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
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetailPage(studentId: widget.student['student_id'].toString()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('View Attendance'),
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
                    'Overall Attendance',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance: 85%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceDetailPage(studentId: widget.student['student_id'].toString()),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    minHeight: 8,
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
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardContent(),
      TimetablePage(),
      AssignmentCompletionPage(),
      NotificationBoxPage(),
      DocumentUpload(student: widget.student),
      AttendanceDetailPage(studentId: widget.student['student_id'].toString()),
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
              leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              title: const Text("Timetable"),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Theme.of(context).primaryColor),
              title: const Text("Assignments"),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
              title: const Text("Notifications"),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
              title: const Text("Documents"),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event_available, color: Theme.of(context).primaryColor),
              title: const Text("Attendance"),
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 28),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule, size: 28),
            label: "Timetable",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 28),
            label: "Assignments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder, size: 28),
            label: "Documents",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available, size: 28),
            label: "Attendance",
          ),
        ],
      ),
    );
  }
}

class TimetablePage extends StatelessWidget {
  final List<Map<String, String>> timetable = [
    {'day': 'Monday', 'time': '9:00 AM - 10:00 AM', 'course': 'DL', 'room': 'A-101'},
    {'day': 'Monday', 'time': '10:15 AM - 11:15 AM', 'course': 'ML', 'room': 'B-202'},
    {'day': 'Tuesday', 'time': '9:00 AM - 10:00 AM', 'course': 'BT', 'room': 'C-303'},
    {'day': 'Tuesday', 'time': '10:15 AM - 11:15 AM', 'course': 'SDN', 'room': 'A-102'},
    {'day': 'Wednesday', 'time': '9:00 AM - 10:00 AM', 'course': 'BI', 'room': 'A-101'},
    {'day': 'Thursday', 'time': '9:00 AM - 10:00 AM', 'course': 'HPC', 'room': 'B-202'},
    {'day': 'Friday', 'time': '9:00 AM - 10:00 AM', 'course': 'DL', 'room': 'C-303'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Timetable',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your class schedule for the week',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: timetable.map((entry) {
                    return ListTile(
                      leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                      title: Text(
                        '${entry['course']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${entry['day']} | ${entry['time']} | Room: ${entry['room']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentCompletionPage extends StatelessWidget {
  final List<Map<String, dynamic>> assignments = [
    {'title': 'HPC Assignment 1', 'course': 'HPC', 'dueDate': '2025-06-15', 'completed': true},
    {'title': 'DL Lab Report', 'course': 'DL', 'dueDate': '2025-06-20', 'completed': false},
    {'title': 'Project Report', 'course': 'Project', 'dueDate': '2025-06-18', 'completed': true},
    {'title': 'HPC Unit Test Prep', 'course': 'HPC', 'dueDate': '2025-06-22', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment Completion',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your assignment progress',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: assignments.map((assignment) {
                    return ListTile(
                      leading: Icon(
                        assignment['completed'] ? Icons.check_circle : Icons.pending,
                        color: assignment['completed'] ? Colors.green : Colors.orange,
                      ),
                      title: Text(
                        assignment['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${assignment['course']} | Due: ${assignment['dueDate']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        assignment['completed'] ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 14,
                          color: assignment['completed'] ? Colors.green : Colors.orange,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBoxPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {'title': 'Exam Schedule Released', 'message': 'Mid-term exams start on June 25, 2025.', 'date': '2025-06-10'},
    {'title': 'Assignment Reminder', 'message': 'Math Assignment 1 due on June 15, 2025.', 'date': '2025-06-08'},
    {'title': 'Campus Event', 'message': 'Tech Fest on June 20, 2025. Register now!', 'date': '2025-06-07'},
    {'title': 'Library Notice', 'message': 'Return overdue books by June 12, 2025.', 'date': '2025-06-06'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay updated with recent alerts',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: notifications.map((notification) {
                    return ListTile(
                      leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                      title: Text(
                        notification['title']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        notification['message']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        notification['date']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceDetailPage extends StatelessWidget {
  final String studentId;
  final List<Map<String, dynamic>> attendanceRecords = [
    {'date': '2025-06-01', 'course': 'DL', 'status': 'Present', 'time': '9:00 AM - 10:00 AM'},
    {'date': '2025-06-01', 'course': 'ML', 'status': 'Absent', 'time': '10:15 AM - 11:15 AM'},
    {'date': '2025-06-02', 'course': 'BT', 'status': 'Present', 'time': '9:00 AM - 10:00 AM'},
    {'date': '2025-06-02', 'course': 'SDN', 'status': 'Present', 'time': '10:15 AM - 11:15 AM'},
    {'date': '2025-06-03', 'course': 'BI', 'status': 'Present', 'time': '9:00 AM - 10:00 AM'},
    {'date': '2025-06-04', 'course': 'HPC', 'status': 'Absent', 'time': '9:00 AM - 10:00 AM'},
    {'date': '2025-06-05', 'course': 'DL', 'status': 'Present', 'time': '9:00 AM - 10:00 AM'},
  ];

  AttendanceDetailPage({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Records',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Detailed attendance history',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: attendanceRecords.map((record) {
                      return ListTile(
                        leading: Icon(
                          record['status'] == 'Present' ? Icons.check_circle : Icons.cancel,
                          color: record['status'] == 'Present' ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          '${record['course']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${record['date']} | ${record['time']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: Text(
                          record['status'],
                          style: TextStyle(
                            fontSize: 14,
                            color: record['status'] == 'Present' ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}