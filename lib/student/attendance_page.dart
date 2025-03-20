import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  final String email;

  const AttendancePage({Key? key, required this.email}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String studentName = "Loading...";
  Map<String, String> dailyAttendance = {};
  Map<String, double> subjectAttendance = {};
  TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudentEmail();
  }

  Future<void> fetchStudentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("student_email") ?? widget.email;
    fetchAttendanceData(email);
  }

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.deepPurple, size: 40),
                    const SizedBox(width: 12),
                    Text(
                      "Student: $studentName",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Daily Attendance
            const Text("Daily Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: dailyAttendance.length,
                itemBuilder: (context, index) {
                  String date = dailyAttendance.keys.elementAt(index);
                  String status = dailyAttendance[date] ?? "Absent";
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text("Date: $date"),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          color: status == "Present" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text("Subject-wise Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            Column(
              children: subjectAttendance.entries.map((entry) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text("${entry.value.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            // Apply for Leave Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Apply for Leave",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter reason for leave",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: applyForLeave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Submit Leave Request",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
