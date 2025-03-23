import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentPromotionPage extends StatefulWidget {
  const StudentPromotionPage({super.key});

  @override
  _StudentPromotionPageState createState() => _StudentPromotionPageState();
}

class _StudentPromotionPageState extends State<StudentPromotionPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isPromoting = false;
  String _searchQuery = "";
  String? _selectedFilter;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fetchStudentPromotionData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        // Apply search query
        final nameMatches = student["name"].toLowerCase().contains(_searchQuery.toLowerCase());
        final idMatches = student["student_id"].toLowerCase().contains(_searchQuery.toLowerCase());
        final emailMatches = student["email"].toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply filter if selected
        bool filterMatch = true;
        if (_selectedFilter == "Result Pending") {
          filterMatch = !student["result_updated"];
        } else if (_selectedFilter == "Result Updated") {
          filterMatch = student["result_updated"];
        }
        
        return (nameMatches || idMatches || emailMatches) && filterMatch;
      }).toList();
    });
  }

  Future<void> _fetchStudentPromotionData() async {
    setState(() {
      _isLoading = true;
    });
    const url = 'http://localhost:5000/get_student_promotion';

    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body);

      if (jsonData is Map && jsonData['status'] == 'success') {
        final List<dynamic> studentList = jsonData['students'] ?? [];
        setState(() {
          students = studentList.map<Map<String, dynamic>>((student) {
            return {
              "student_id": student["student_id"]?.toString() ?? "N/A",
              "name": student["name"] ?? "Unknown",
              "email": student["email"] ?? "No Email",
              "department": student["department"] ?? "No Dept",
              "year": student["year"] ?? "FE",
              "result_updated": student["result_updated"] ?? false,
              "result": student["result"] ?? "Not Available",
              "expanded": false, // For expandable cards
            };
          }).toList();
          filteredStudents = List.from(students);
          _isLoading = false;
        });
      } else {
        throw Exception("Unexpected data format");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackbar("Error fetching data. Please check your connection.", isError: true);
    }
  }

  Future<void> _sendResultReminder(String studentId, int index) async {
    setState(() {
      _isSending = true;
    });
    const url = 'http://localhost:5000/send_result_reminder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Reminder sent successfully!");
      } else {
        _showSnackbar("Failed to send reminder.", isError: true);
      }
    } catch (e) {
      _showSnackbar("Error sending reminder.", isError: true);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _promoteStudent(String studentId, String newYear, String currentYear, int index) async {
    if (newYear == "NA") {
      _showSnackbar("Student remains in $currentYear.");
      return;
    }

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Confirm Promotion"),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                const TextSpan(text: "Are you sure you want to promote this student from "),
                TextSpan(
                  text: currentYear,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const TextSpan(text: " to "),
                TextSpan(
                  text: newYear,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const TextSpan(text: "?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("PROMOTE"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isPromoting = true;
    });
    
    const url = 'http://localhost:5000/promote_student';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId, "new_year": newYear}),
      );

      if (response.statusCode == 200) {
        // Update local state immediately for better UX
        setState(() {
          final studentIndex = students.indexWhere((s) => s["student_id"] == studentId);
          if (studentIndex >= 0) {
            students[studentIndex]["year"] = newYear;
            // Close the expanded card after promotion
            students[studentIndex]["expanded"] = false;
          }
          
          final filteredIndex = filteredStudents.indexWhere((s) => s["student_id"] == studentId);
          if (filteredIndex >= 0) {
            filteredStudents[filteredIndex]["year"] = newYear;
            filteredStudents[filteredIndex]["expanded"] = false;
          }
        });
        
        _showSnackbar("Student promoted to $newYear successfully!");
        _animateSuccess(index);
      } else {
        _showSnackbar("Failed to promote student.", isError: true);
      }
    } catch (e) {
      _showSnackbar("Error promoting student.", isError: true);
    } finally {
      setState(() {
        _isPromoting = false;
      });
    }
  }

  void _animateSuccess(int index) {
    // Animated feedback for successful promotion
    _animationController.reset();
    _animationController.forward();
  }

  void _toggleExpand(int index) {
    setState(() {
      final student = filteredStudents[index];
      student["expanded"] = !student["expanded"];
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      action: SnackBarAction(
        label: "DISMISS",
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final bool resultUpdated = student["result_updated"];
    final String currentYear = student["year"];
    final String studentId = student["student_id"];
    final bool isExpanded = student["expanded"] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: isExpanded ? 5 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: resultUpdated ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleExpand(index),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                resultUpdated 
                    ? Colors.green.shade50.withOpacity(0.3)
                    : Colors.red.shade50.withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        student['name'].substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            student['student_id'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getYearColor(student['year']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student['year'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.check, color: Colors.black54, size: 20),
                    const SizedBox(width: 8),
                    const Text("Result: ", style: TextStyle(fontWeight: FontWeight.w500)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: resultUpdated ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student['result'],
                        style: TextStyle(
                          color: resultUpdated ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    resultUpdated
                        ? Icon(Icons.verified, color: Colors.green.shade700)
                        : Icon(Icons.warning, color: Colors.orange.shade700),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isExpanded ? null : 0,
                  child: ClipRect(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isExpanded ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _row("Email", student['email'], Icons.email),
                            _row("Department", student['department'], Icons.school),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: null,
                                    decoration: InputDecoration(
                                      labelText: "Promote To",
                                      labelStyle: TextStyle(color: Colors.blue.shade700),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.blue.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.blue.shade50.withOpacity(0.3),
                                    ),
                                    items: ["NA", "SE", "TE", "BE"]
                                        .map((year) => DropdownMenuItem(
                                              value: year,
                                              child: Text(
                                                year,
                                                style: TextStyle(
                                                  color: year == "NA" ? Colors.grey.shade700 : Colors.blue.shade700,
                                                  fontWeight: year == "NA" ? FontWeight.normal : FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: resultUpdated && !_isPromoting
                                        ? (newYear) => _promoteStudent(studentId, newYear!, currentYear, index)
                                        : null,
                                    disabledHint: Text(
                                      _isPromoting ? "Processing..." : "Update result first",
                                      style: TextStyle(color: Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: resultUpdated || _isSending
                                      ? null
                                      : () => _sendResultReminder(studentId, index),
                                  icon: _isSending
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(2.0),
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.notifications_active),
                                  label: Text(_isSending ? "Sending..." : "Notify"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: resultUpdated ? Colors.grey.shade400 : Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getYearColor(String year) {
    switch (year) {
      case "FE":
        return Colors.blue.shade700;
      case "SE":
        return Colors.green.shade700;
      case "TE":
        return Colors.purple.shade700;
      case "BE":
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Student Promotion", 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade600],
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
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Fetching student data...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search by name, ID or email",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _filterStudents();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip("All", null),
                            _filterChip("Result Pending", "Result Pending"),
                            _filterChip("Result Updated", "Result Updated"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "No students match your search",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                    _selectedFilter = null;
                                    filteredStudents = List.from(students);
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("Clear Search"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: Colors.blue.shade700,
                          backgroundColor: Colors.white,
                          onRefresh: _fetchStudentPromotionData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 12, bottom: 80),
                            itemCount: filteredStudents.length + 1, // +1 for the header
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Students (${filteredStudents.length})",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "Tap card to expand",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.touch_app, size: 16, color: Colors.grey.shade600),
                                    ],
                                  ),
                                );
                              }
                              return _buildStudentCard(filteredStudents[index - 1], index - 1);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String label, String? filterValue) {
    final bool isSelected = _selectedFilter == filterValue;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? null : filterValue;
          _filterStudents();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}