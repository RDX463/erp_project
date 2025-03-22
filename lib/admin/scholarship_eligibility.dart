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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScholarshipStudents();
  }

  // Fetch all students eligible for scholarships
  Future<void> _fetchScholarshipStudents() async {
  const url = 'http://localhost:5000/get_scholarship_students';

  try {
    final response = await http.get(Uri.parse(url));

    print("Response Status: ${response.statusCode}");
    print("Raw Response Body: ${response.body}");

    final jsonData = json.decode(response.body);

    print("Decoded JSON Data: $jsonData");
    print("Data Type: ${jsonData.runtimeType}");

    if (jsonData is Map && jsonData['status'] == 'success') {
      final List<dynamic> studentList = jsonData['students'] ?? [];
      setState(() {
        students = studentList.map<Map<String, dynamic>>((student) {
          return {
            "student_id": student["student_id"]?.toString() ?? "N/A",
            "name": student["name"] ?? "Unknown",
            "email": student["email"] ?? "No Email",
            "department": student["department"] ?? "No Dept",
            "year": (student["year"] ?? 0).toString(), // Ensure 'year' is never null
            "form_submitted": student["form_completed"] ?? false,
            "marks": student["marks"] ?? 0, // Default to 0
            "total_fees": student["total_fees"] ?? 0, // Default to 0
            "amount_paid": student["amount_paid"] ?? 0, // Default to 0
            "remaining_fees": student["remaining_fees"] ?? 0, // Default to 0
          };
        }).toList();
        print("Students List: $students"); // Debug print
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

  // Send fee reminder email
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
              child: const Text("OK",
                  style: TextStyle(color: Colors.blueAccent)),
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
              child: const Text("OK",
                  style: TextStyle(color: Colors.green)),
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
                        fontSize: 22, fontWeight: FontWeight.bold),
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
                          DataColumn(label: Text("Total Fees")),
                          DataColumn(label: Text("Amount Paid")),
                          DataColumn(label: Text("Remaining Fees")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: students.map((student) {
                          return DataRow(cells: [
                            DataCell(Text(student["student_id"])),
                            DataCell(Text(student["name"])),
                            DataCell(Text(student["email"])),
                            DataCell(Text(student["department"])),
                            DataCell(Text(student["year"].toString())),
                            DataCell(Text("₹${student["total_fees"] ?? 0}")),
                            DataCell(Text("₹${student["amount_paid"] ?? 0}")),
                            DataCell(Text("₹${student["remaining_fees"] ?? 0}")),
                            DataCell(
                              ElevatedButton(
                                onPressed: (student["remaining_fees"] ?? 0) > 0
                                    ? () => _sendFeeReminder(student["student_id"])
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (student["remaining_fees"] ?? 0) > 0
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                                child: const Text("Send Reminder"),
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