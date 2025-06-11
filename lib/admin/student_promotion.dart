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
    // Replace 'localhost' with your machine's IP if running on a device/emulator
    const url = 'http://127.0.0.1:5000/get_pending_results'; // Update IP as needed

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      final jsonData = jsonDecode(response.body);
      print("Decoded JSON Data: $jsonData");

      if (jsonData['status'] == 'success') {
        if (mounted) {
          setState(() {
            pendingResults = (jsonData['results'] as List? ?? []).map<Map<String, dynamic>>((result) {
              return {
                "_id": result["_id"]?.toString() ?? "N/A",
                "student_id": result["student_id"]?.toString() ?? "N/A",
                "semester": result["semester"]?.toString() ?? "Unknown",
                "exam_type": result["exam_type"]?.toString() ?? "Unknown",
                "file_path": result["file_path"]?.toString() ?? "",
                "uploaded_at": (result["uploaded_at"]?.toString() ?? "N/A").split('T')[0],
              };
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Unexpected data format: ${jsonData['message'] ?? 'No message'}");
      }
    } catch (e) {
      print("Error fetching pending results: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog("Error fetching pending results: $e");
      }
    }
  }

  // Verify result
  Future<void> _verifyResult(String resultId, String status, String comments) async {
    const url = 'http://127.0.0.1:5000/verify_result'; // Update IP as needed

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
        await _fetchPendingResults();
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        _showErrorDialog("Failed to verify result: $error");
      }
    } catch (e) {
      print("Error verifying result: $e");
      _showErrorDialog("Error verifying result: $e");
    }
  }

  // Promote student to the next year
  Future<void> _promoteStudent(String studentId, String newYear, String currentYear) async {
    if (newYear == "NA") {
      _showSuccessDialog("Student remains in $currentYear.");
      return;
    }

    const url = 'http://127.0.0.1:5000/promote_student'; // Update IP as needed

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": studentId, "new_year": newYear}),
      );
      print("Promote Response: ${response.body}");

      if (response.statusCode == 200) {
        _showSuccessDialog("Student promoted to $newYear successfully!");
        await _fetchPendingResults();
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        _showErrorDialog("Failed to promote student: $error");
      }
    } catch (e) {
      print("Error promoting student: $e");
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
        title: Text(
          'Verify Result: ${result['student_id']}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ) ?? const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semester: ${result['semester']}',
              style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
            ),
            Text(
              'Exam Type: ${result['exam_type']}',
              style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                // Update file path to match backend's /serve_files route
                final fileName = result['file_path'].split('/').last;
                final url = 'http://127.0.0.1:5000/serve_files/$fileName'; // Update IP
                final uri = Uri.parse(url);
                if (await launcher.canLaunchUrl(uri)) {
                  await launcher.launchUrl(uri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot open file')),
                  );
                }
              },
              child: Text(
                'View PDF',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            DropdownButtonFormField<String>(
              value: status,
              items: ['approved', 'rejected']
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s[0].toUpperCase() + s.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) => status = value!,
              decoration: InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(
                labelText: 'Comments',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              maxLines: 3,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _verifyResult(result['_id'], status, commentsController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
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

  // Show success dialog
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
          actions: [
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
          "Student Promotion",
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                          Icons.verified,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pending Result Verifications",
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
                  const SizedBox(height: 16),
                  // Data Table
                  Expanded(
                    child: pendingResults.isEmpty
                        ? const Center(
                            child: Text(
                              "No pending results found.",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: DataTable(
                                    columnSpacing: 16.0,
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          "Student ID",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Semester",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Exam Type",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Uploaded Date",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Verify",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Promotion",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ) ?? const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                    rows: pendingResults.map((result) {
                                      // Fetch current year dynamically (placeholder, replace with actual logic)
                                      String currentYear = "FE"; // TODO: Fetch from backend
                                      return DataRow(cells: [
                                        DataCell(
                                          Text(
                                            result["student_id"],
                                            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            result["semester"],
                                            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            result["exam_type"],
                                            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            result["uploaded_at"],
                                            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () => _showVerificationDialog(result),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text(
                                              "Verify",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          DropdownButton<String>(
                                            value: null,
                                            items: ["NA", "SE", "TE", "BE"]
                                                .map((year) => DropdownMenuItem(
                                                      value: year,
                                                      child: Text(year),
                                                    ))
                                                .toList(),
                                            onChanged: (newYear) => _promoteStudent(result["student_id"], newYear!, currentYear),
                                            hint: Text(
                                              "Select Year",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey,
                                                  ) ?? const TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
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