import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = true;
  bool _isSearching = false;
  int? _expandedIndex;
  
  late AnimationController _animationController;
  final TextEditingController searchController = TextEditingController();
  
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchStudentData();
  }
  
  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch student details
  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
    });
    
    const url = 'http://localhost:5000/get_students';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            students = List<Map<String, dynamic>>.from(jsonData['students']);
            filteredStudents = students;
            _isLoading = false;
          });
        } else {
          throw Exception("Unexpected data format");
        }
      } else {
        throw Exception("Failed to load student data");
      }
    } catch (e) {
      _showSnackBar("Error fetching data. Please check your connection.", isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter students based on search query
  void _filterStudents(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      filteredStudents = students
          .where((student) =>
              student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              student['student_id'].toString().toLowerCase().contains(query.toLowerCase()) ||
              student['email'].toString().toLowerCase().contains(query.toLowerCase()) ||
              student['department'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Update student details
  Future<void> _updateStudentData(Map<String, dynamic> updatedData, String adminName) async {
    const url = 'http://localhost:5000/update_student';

    try {
      _showLoadingDialog("Updating student data...");
      
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"updated_data": updatedData, "admin": adminName}),
      );

      Navigator.pop(context); // Dismiss loading dialog
      
      if (response.statusCode == 200) {
        _showSnackBar("Student data updated successfully!");
        _fetchStudentData(); // Refresh list
      } else {
        _showSnackBar("Failed to update student data.", isError: true);
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      _showSnackBar("Error updating student data.", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.indigo.shade700),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // View student details
  void _viewStudentDetails(Map<String, dynamic> student, int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  // Edit student details
  void _editStudent(Map<String, dynamic> student) {
    final nameController = TextEditingController(text: student['name']);
    final emailController = TextEditingController(text: student['email']);
    final phoneController = TextEditingController(text: student['phone']);
    final departmentController = TextEditingController(text: student['department']);
    final yearController = TextEditingController(text: student['year']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Text(
                "Edit Student",
                style: TextStyle(color: Colors.indigo.shade800),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(
                          student['name'][0].toUpperCase(),
                          style: TextStyle(color: Colors.indigo.shade800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['student_id'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            Text(
                              "Editing student information",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                buildTextField(nameController, "Full Name", Icons.person),
                buildTextField(emailController, "Email Address", Icons.email),
                buildTextField(phoneController, "Phone Number", Icons.phone),
                buildTextField(departmentController, "Department", Icons.business),
                buildTextField(yearController, "Year", Icons.calendar_today),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedData = {
                  "student_id": student['student_id'],
                  "name": nameController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "department": departmentController.text,
                  "year": yearController.text,
                };
                _updateStudentData(updatedData, "Admin_Name"); // Replace with actual admin name
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Save Changes"),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }

  // UI Component for input fields
  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo.shade400, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Student Profiles",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Filter options
            },
            tooltip: "Filter options",
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo.shade600),
                  const SizedBox(height: 16),
                  Text(
                    "Loading student profiles...",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search by name, ID, email or department",
                            prefixIcon: Icon(Icons.search, color: Colors.indigo.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      _filterStudents('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: _filterStudents,
                        ),
                      ),
                      if (_isSearching) 
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Text(
                                "Found ${filteredStudents.length} student(s)",
                                style: TextStyle(
                                  color: Colors.grey.shade700, 
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  searchController.clear();
                                  _filterStudents('');
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text("Clear search"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.indigo.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Student list
                Expanded(
                  child: filteredStudents.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearching ? Icons.search_off : Icons.people_alt,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching 
                                ? "No students match your search" 
                                : "No student profiles available",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_isSearching)
                              ElevatedButton.icon(
                                onPressed: () {
                                  searchController.clear();
                                  _filterStudents('');
                                },
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text("Clear search"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade100,
                                  foregroundColor: Colors.indigo.shade700,
                                  elevation: 0,
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchStudentData,
                        color: Colors.indigo.shade700,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final bool isExpanded = _expandedIndex == index;
                            
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isExpanded 
                                      ? Colors.indigo.shade100.withOpacity(0.5) 
                                      : Colors.grey.shade200,
                                    blurRadius: isExpanded ? 10 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: isExpanded 
                                  ? Border.all(color: Colors.indigo.shade200) 
                                  : null,
                              ),
                              child: Column(
                                children: [
                                  // Student card header
                                  InkWell(
                                    onTap: () => _viewStudentDetails(student, index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          _buildStudentAvatar(student),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student["name"] ?? "Unknown",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  student["student_id"] ?? "ID not assigned",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildInfoChip(
                                                      student["department"] ?? "No Dept",
                                                      Colors.blue.shade50,
                                                      Colors.blue.shade700,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    _buildInfoChip(
                                                      "Year: ${student["year"] ?? "N/A"}",
                                                      Colors.purple.shade50,
                                                      Colors.purple.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                              color: Colors.indigo.shade400,
                                            ),
                                            onPressed: () => _viewStudentDetails(student, index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Expanded details section
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox(height: 0),
                                    secondChild: Container(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: Column(
                                        children: [
                                          const Divider(),
                                          _buildDetailRow("Email", student["email"] ?? "No email", Icons.email),
                                          _buildDetailRow("Phone", student["phone"] ?? "No phone", Icons.phone),
                                          if (student["enrollment_date"] != null)
                                            _buildDetailRow(
                                              "Enrollment Date", 
                                              student["enrollment_date"], 
                                              Icons.calendar_today
                                            ),
                                          if (student["fees_status"] != null)
                                            _buildDetailRow(
                                              "Fees Status", 
                                              student["fees_status"], 
                                              Icons.payment,
                                              valueColor: student["fees_status"] == "Paid" 
                                                ? Colors.green.shade700 
                                                : Colors.orange.shade700,
                                            ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _editStudent(student),
                                                icon: const Icon(Icons.edit, size: 16),
                                                label: const Text("Edit Profile"),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(color: Colors.indigo.shade300),
                                                  foregroundColor: Colors.indigo.shade700,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    crossFadeState: isExpanded 
                                      ? CrossFadeState.showSecond 
                                      : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                ),
              ],
            ),
      floatingActionButton: _isLoading 
        ? null 
        : FloatingActionButton(
            onPressed: _fetchStudentData,
            backgroundColor: Colors.indigo.shade600,
            child: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh student data",
          ),
    );
  }
  
  Widget _buildStudentAvatar(Map<String, dynamic> student) {
    final name = student['name'] ?? "?";
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final department = student['department'] ?? "GEN";
    
    // Generate color based on department
    Color avatarColor;
    switch (department) {
      case "COM":
        avatarColor = Colors.blue.shade700;
        break;
      case "MECH":
        avatarColor = Colors.orange.shade700;
        break;
      case "ENTC":
        avatarColor = Colors.green.shade700;
        break;
      case "CIVIL":
        avatarColor = Colors.purple.shade700;
        break;
      case "AIDS":
        avatarColor = Colors.red.shade700;
        break;
      default:
        avatarColor = Colors.indigo.shade700;
    }
    
    return Hero(
      tag: "student_avatar_${student['student_id']}",
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              avatarColor,
              avatarColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}