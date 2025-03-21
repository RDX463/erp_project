import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminStudentsPage extends StatefulWidget {
  @override
  _AdminStudentsPageState createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentsPage> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  // Course options
  final List<String> courses = ["No Course", "CS", "ENTC", "Mechanical", "AIDS", "Civil"];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // Function to fetch student data from FastAPI
  Future<void> fetchStudents() async {
    final url = 'http://localhost:5000/admin/students';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          students = jsonResponse.map((student) {
            String course = student["course"] ?? "No Course";
            
            // Ensure course exists in the list
            if (!courses.contains(course)) {
              course = "No Course";
            }

            return {
              "student_id": student["student_id"] ?? "N/A",
              "name": student["name"] ?? "Unknown",
              "email": student["email"] ?? "No Email",
              "phone": student["phone"] ?? "No Phone",
              "course": course,
              "result_score": student["result_score"] ?? 0,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load student data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching students: $e");
    }
  }

  // Function to update student course in the database
  Future<void> updateCourse(String studentId, String newCourse) async {
    final url = 'http://localhost:5000/admin/update_course/$studentId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"course": newCourse}),
      );

      if (response.statusCode == 200) {
        print("Course updated successfully");
      } else {
        print("Failed to update course");
      }
    } catch (e) {
      print("Error updating course: $e");
    }
  }

  // Function to promote student based on result score
  Future<void> promoteStudent(String studentId) async {
    final url = 'http://localhost:5000/admin/promote_student/$studentId';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        print("Student promoted successfully");
      } else {
        print("Failed to promote student");
      }
    } catch (e) {
      print("Error promoting student: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : students.isEmpty
              ? Center(child: Text("No students found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Course")),
                        DataColumn(label: Text("Result Score")),
                        DataColumn(label: Text("Promote")),
                      ],
                      rows: students.map((student) {
                        return DataRow(cells: [
                          DataCell(Text(student['student_id'].toString())),
                          DataCell(Text(student["name"])),
                          DataCell(Text(student['email'])),
                          DataCell(Text(student['phone'])),
                          DataCell(
                            DropdownButton<String>(
                              value: student["course"],
                              items: courses.map((course) {
                                return DropdownMenuItem(
                                  value: course,
                                  child: Text(course),
                                );
                              }).toList(),
                              onChanged: (newCourse) {
                                if (newCourse != null) {
                                  setState(() {
                                    student["course"] = newCourse;
                                  });
                                  updateCourse(student['student_id'], newCourse);
                                }
                              },
                            ),
                          ),
                          DataCell(Text(student['result_score'].toString())),
                          DataCell(
                            ElevatedButton(
                              onPressed: student["result_score"] >= 50
                                  ? () => promoteStudent(student['student_id'])
                                  : null,
                              child: Text("Promote"),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
