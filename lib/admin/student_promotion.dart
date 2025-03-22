import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentPromotionPage extends StatefulWidget {
  const StudentPromotionPage({super.key});

  @override
  _StudentPromotionPageState createState() => _StudentPromotionPageState();
}

class _StudentPromotionPageState extends State<StudentPromotionPage> {
  List<Map<String, dynamic>> students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentPromotionData();
  }

  // Fetch student details and result update status
  Future<void> _fetchStudentPromotionData() async {
    const url = 'http://localhost:5000/get_student_promotion';

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      final jsonData = json.decode(response.body);
      print("Decoded JSON Data: $jsonData");

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
              "result": student["result"] ?? "Not Available", // Add Result Field
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Unexpected data format");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error fetching data. Please check your connection.");
    }
  }

  // Send result update reminder email
  Future<void> _sendResultReminder(String studentId) async {
    const url = 'http://localhost:5000/send_result_reminder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Reminder sent successfully!");
      } else {
        _showErrorDialog("Failed to send reminder.");
      }
    } catch (e) {
      _showErrorDialog("Error sending reminder.");
    }
  }

  // Promote student to the next year
  Future<void> _promoteStudent(String studentId, String newYear, String currentYear) async {
    if (newYear == "NA") {
      _showSuccessDialog("Student remains in $currentYear.");
      return;
    }

    const url = 'http://localhost:5000/promote_student';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId, "new_year": newYear}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("Student promoted to $newYear successfully!");
        _fetchStudentPromotionData(); // Refresh list
      } else {
        _showErrorDialog("Failed to promote student.");
      }
    } catch (e) {
      _showErrorDialog("Error promoting student.");
    }
  }

  // Show error dialog
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
              child: const Text("OK", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
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
        title: const Text("Student Promotion"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    "Student Promotion List",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16.0,
                        columns: const [
                          DataColumn(label: Text("Student ID")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Department")),
                          DataColumn(label: Text("Year")),
                          DataColumn(label: Text("Result")),
                          DataColumn(label: Text("Result Updated")),
                          DataColumn(label: Text("Promotion")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: students.map((student) {
                          bool resultUpdated = student["result_updated"];
                          String currentYear = student["year"].toString();

                          return DataRow(cells: [
                            DataCell(Text(student["student_id"])),
                            DataCell(Text(student["name"])),
                            DataCell(Text(student["email"])),
                            DataCell(Text(student["department"])),
                            DataCell(Text(currentYear)),
                            DataCell(Text(student["result"])), // Display result
                            DataCell(
                              Icon(
                                resultUpdated ? Icons.check_circle : Icons.cancel,
                                color: resultUpdated ? Colors.green : Colors.red,
                              ),
                            ),
                            DataCell(
                              DropdownButton<String>(
                                items: ["NA", "SE", "TE", "BE"]
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        ))
                                    .toList(),
                                onChanged: resultUpdated
                                    ? (newYear) => _promoteStudent(student["student_id"], newYear!, currentYear)
                                    : null,
                                hint: const Text("Select Year"),
                                disabledHint: const Text("Update Result First"),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: resultUpdated
                                    ? null
                                    : () => _sendResultReminder(student["student_id"]),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      resultUpdated ? Colors.grey : Colors.blue,
                                ),
                                child: const Text("Notify"),
                              ),
                            ),
                          ]);
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
