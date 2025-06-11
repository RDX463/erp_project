import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ScholarshipEligibilityPage extends StatefulWidget {
  const ScholarshipEligibilityPage({super.key});

  @override
  _ScholarshipEligibilityPageState createState() =>
      _ScholarshipEligibilityPageState();
}

class _ScholarshipEligibilityPageState
    extends State<ScholarshipEligibilityPage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = true;
  String selectedDepartment = "All";
  List<String> departments = ["All", "COM", "AIDS", "MECH", "ENTC", "CIVIL"];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchScholarshipStudents();
  }

  Future<void> _fetchScholarshipStudents() async {
    const url = 'http://localhost:5000/get_scholarship_students';

    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body);

      if (jsonData is Map && jsonData['status'] == 'success') {
        final List<dynamic> studentList = jsonData['students'] ?? [];
        if (mounted) {
          setState(() {
            students = studentList.map<Map<String, dynamic>>((student) {
              return {
                "student_id": student["student_id"]?.toString() ?? "N/A",
                "name": student["name"] ?? "Unknown",
                "email": student["email"] ?? "No Email",
                "department": student["department"] ?? "No Dept",
                "year": (student["year"] ?? 0).toString(),
                "form_submitted": student["form_completed"] ?? false,
                "marks": student["marks"] ?? 0,
                "total_fees": student["total_fees"] ?? 0,
                "amount_paid": student["amount_paid"] ?? 0,
                "remaining_fees": student["remaining_fees"] ?? 0,
              };
            }).toList();
            _filterStudents();
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Unexpected data format");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("Error fetching data. Please check your connection.");
      }
    }
  }

  void _filterStudents() {
    if (mounted) {
      setState(() {
        if (selectedDepartment == "All") {
          filteredStudents = students;
        } else {
          filteredStudents = students
              .where((student) => student["department"] == selectedDepartment)
              .toList();
        }
      });
    }
  }

  Future<void> _sendFeeReminder(String studentId) async {
    const url = 'http://localhost:5000/send_fee_reminder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Fee reminder sent successfully!");
      } else {
        _showErrorDialog("Failed to send fee reminder.");
      }
    } catch (e) {
      _showErrorDialog("Error sending fee reminder.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Error",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Success",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ) ?? const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
          "Scholarship Eligibility",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Eligible Students",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                              ) ?? const TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Department Filter
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: InputDecoration(
                        labelText: "Filter by Department",
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        border: InputBorder.none,
                      ),
                      items: departments.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(
                            department,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                ) ?? const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDepartment = newValue;
                            _filterStudents();
                          });
                        }
                      },
                    ),
                  ),
                ),
                // Student List - Fixed with Expanded at the top level
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final bool hasPendingFees = (student["remaining_fees"] ?? 0) > 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: Semantics(
                            label: "Student ${student["name"]} details",
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  student["name"]?.isNotEmpty == true ? student["name"][0] : "?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                student["name"],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ) ?? const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    "Dept: ${student["department"]}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                        ) ?? const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Year: ${student["year"]}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                        ) ?? const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Remaining Fees: ₹${student["remaining_fees"]}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          color: hasPendingFees ? Colors.red : Colors.green,
                                        ) ?? TextStyle(
                                          fontSize: 16,
                                          color: hasPendingFees ? Colors.red : Colors.green,
                                        ),
                                  ),
                                ],
                              ),
                              trailing: Semantics(
                                label: hasPendingFees ? "Send fee reminder for ${student["student_id"]}" : "No action available",
                                child: ElevatedButton(
                                  onPressed: hasPendingFees
                                      ? () => _sendFeeReminder(student["student_id"])
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: hasPendingFees
                                            ? [
                                                Theme.of(context).primaryColor,
                                                Theme.of(context).primaryColor.withOpacity(0.8),
                                              ]
                                            : [Colors.grey, Colors.grey.shade700],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Send Reminder",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ) ?? const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}