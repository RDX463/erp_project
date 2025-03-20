import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  final String email;

  // Constructor accepting email
  const AttendancePage({Key? key, required this.email}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String studentName = "Loading...";
  Map<String, String> dailyAttendance = {}; // Stores attendance per day
  Map<String, double> subjectAttendance = {}; // Stores subject-wise attendance
  TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudentEmail(); // Load email from SharedPreferences and fetch attendance
  }

  // Fetch email from SharedPreferences
  Future<void> fetchStudentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("student_email") ?? widget.email;
    fetchAttendanceData(email);
  }

  // Fetch Attendance Data from API
  Future<void> fetchAttendanceData(String email) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/get_student_attendance?email=$email"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentName = data["name"] ?? "Unknown";
          dailyAttendance = Map<String, String>.from(data["daily_attendance"] ?? {});
          subjectAttendance = Map<String, double>.from(
              (data["subject_attendance"] ?? {}).map((k, v) => MapEntry(k, v.toDouble())));
        });
      } else {
        setState(() {
          studentName = "Not Found";
          dailyAttendance = {};
          subjectAttendance = {};
        });
      }
    } catch (e) {
      setState(() {
        studentName = "Error Loading";
        dailyAttendance = {};
        subjectAttendance = {};
      });
    }
  }

  // Apply for Leave
  Future<void> applyForLeave() async {
    if (reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a reason for leave"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8000/apply_leave"),
        body: json.encode({
          "email": widget.email,
          "reason": reasonController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leave request submitted successfully"), backgroundColor: Colors.green),
        );
        reasonController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit leave request"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting leave request"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), backgroundColor: Colors.orangeAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student: $studentName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Daily Attendance List
            Expanded(
              child: ListView.builder(
                itemCount: dailyAttendance.length,
                itemBuilder: (context, index) {
                  String date = dailyAttendance.keys.elementAt(index);
                  String status = dailyAttendance[date] ?? "Absent";
                  return ListTile(
                    title: Text("Date: $date"),
                    trailing: Text(
                      status,
                      style: TextStyle(
                          color: status == "Present" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text("Subject-wise Attendance Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            // Subject Attendance List
            Column(
              children: subjectAttendance.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text("${entry.value.toStringAsFixed(1)}%"),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text("Apply for Leave", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: "Enter reason for leave",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: applyForLeave,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Submit Leave Request"),
            ),
          ],
        ),
      ),
    );
  }
}
