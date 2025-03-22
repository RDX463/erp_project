import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      } else {
        throw Exception("Unexpected data format");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error fetching data. Please check your connection.");
    }
  }

  void _filterStudents() {
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
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Scholarship Eligibility"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    "Eligible Students",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Modern Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: "Filter by Department",
                        border: InputBorder.none,
                      ),
                      items: departments.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
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

                  const SizedBox(height: 10),

                  // Student List in Card View
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                student["name"][0],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            title: Text(
                              student["name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Dept: ${student["department"]}"),
                                Text("Year: ${student["year"]}"),
                                Text("Remaining Fees: ₹${student["remaining_fees"]}"),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: (student["remaining_fees"] ?? 0) > 0
                                  ? () => _sendFeeReminder(student["student_id"])
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (student["remaining_fees"] ?? 0) > 0
                                    ? Colors.blue
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Send Reminder"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
