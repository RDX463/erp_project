import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as launcher;

class StudentPromotionPage extends StatefulWidget {
  const StudentPromotionPage({super.key});

  @override
  _StudentPromotionPageState createState() => _StudentPromotionPageState();
}

class _StudentPromotionPageState extends State<StudentPromotionPage> {
  List<Map<String, dynamic>> pendingResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingResults();
  }

  // Fetch pending results for verification
  Future<void> _fetchPendingResults() async {
    const url = 'http://localhost:5000/get_pending_results';

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      final jsonData = jsonDecode(response.body);
      print("Decoded JSON Data: $jsonData");

      if (jsonData['status'] == 'success') {
        setState(() {
          pendingResults = List<Map<String, dynamic>>.from(jsonData['results']).map((result) {
            return {
              "_id": result["_id"]?.toString() ?? "N/A",
              "student_id": result["student_id"]?.toString() ?? "N/A",
              "semester": result["semester"] ?? "Unknown",
              "exam_type": result["exam_type"] ?? "Unknown",
              "file_path": result["file_path"] ?? "",
              "uploaded_at": result["uploaded_at"]?.split('T')[0] ?? "N/A",
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
      _showErrorDialog("Error fetching pending results. Please check your connection.");
    }
  }

  // Verify result
  Future<void> _verifyResult(String resultId, String status, String comments) async {
    const url = 'http://localhost:5000/verify_result';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "result_id": resultId,
          "status": status,
          "comments": comments,
        }),
      );
      print("Verify Response: ${response.body}");

      if (response.statusCode == 200) {
        _showSuccessDialog("Result $status successfully!");
        _fetchPendingResults();
      } else {
        _showErrorDialog("Failed to verify result.");
      }
    } catch (e) {
      _showErrorDialog("Error verifying result: $e");
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
        body: jsonEncode({"student_id": studentId, "new_year": newYear}),
      );
      print("Promote Response: ${response.body}");

      if (response.statusCode == 200) {
        _showSuccessDialog("Student promoted to $newYear successfully!");
        _fetchPendingResults();
      } else {
        _showErrorDialog("Failed to promote student.");
      }
    } catch (e) {
      _showErrorDialog("Error promoting student: $e");
    }
  }

  // Show verification dialog
  void _showVerificationDialog(Map<String, dynamic> result) {
    final commentsController = TextEditingController();
    String status = 'approved';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify Result: ${result['student_id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Semester: ${result['semester']}'),
            Text('Exam Type: ${result['exam_type']}'),
            TextButton(
              onPressed: () async {
                final url = 'http://localhost:5000/uploads/${result['file_path'].split('/').last}';
                if (await launcher.canLaunchUrl(Uri.parse(url))) {
                  await launcher.launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open file')));
                }
              },
              child: const Text('View PDF'),
            ),
            DropdownButtonFormField<String>(
              value: status,
              items: ['approved', 'rejected']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))
                  .toList(),
              onChanged: (value) => status = value!,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(labelText: 'Comments'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _verifyResult(result['_id'], status, commentsController.text);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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
          actions: [
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
                    "Pending Result Verifications",
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
                          DataColumn(label: Text("Semester")),
                          DataColumn(label: Text("Exam Type")),
                          DataColumn(label: Text("Uploaded Date")),
                          DataColumn(label: Text("Verify")),
                          DataColumn(label: Text("Promotion")),
                        ],
                        rows: pendingResults.map((result) {
                          String currentYear = "FE"; // Fetch dynamically if available
                          return DataRow(cells: [
                            DataCell(Text(result["student_id"])),
                            DataCell(Text(result["semester"])),
                            DataCell(Text(result["exam_type"])),
                            DataCell(Text(result["uploaded_at"])),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => _showVerificationDialog(result),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                child: const Text("Verify"),
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
                                onChanged: (newYear) => _promoteStudent(result["student_id"], newYear!, currentYear),
                                hint: const Text("Select Year"),
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