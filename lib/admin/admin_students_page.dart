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

  final List<String> courses = ["No Course", "CS", "ENTC", "Mechanical", "AIDS", "Civil"];
  final List<String> years = ["FE", "SE", "TE", "BE"]; // Year selection for promotion

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = 'http://localhost:5000/admin/students';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          students = jsonResponse.map((student) {
            String course = student["course"] ?? "No Course";

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
              "edited_score": student["result_score"], // Track edited value
              "promotion_year": null, // Track selected promotion year
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

  Future<void> updateCourse(String studentId, String newCourse) async {
  final url = Uri.parse("http://localhost:5000/admin/update_course/$studentId");

  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"course": newCourse}),
  );

  if (response.statusCode == 200) {
    print("Course updated successfully");
  } else {
    print("Failed to update course: ${response.body}");
  }
}


  Future<void> promoteStudent(String studentId, String year) async {
    final url = 'http://localhost:5000/admin/promote_student/$studentId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"promotion_year": year}),
      );

      if (response.statusCode == 200) {
        print("Student promoted to $year successfully");
      } else {
        print("Failed to promote student");
      }
    } catch (e) {
      print("Error promoting student: $e");
    }
  }

  Future<void> updateResultScore(String studentId, int newScore) async {
    final url = 'http://localhost:5000/admin/update_result/$studentId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"result_score": newScore}),
      );

      if (response.statusCode == 200) {
        print("Result score updated successfully");
      } else {
        print("Failed to update result score");
      }
    } catch (e) {
      print("Error updating result score: $e");
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
          ? Center(child: CircularProgressIndicator())
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
                        DataColumn(label: Text("Save")), // Save moved to rightmost
                      ],
                      rows: students.map((student) {
                        TextEditingController resultController =
                            TextEditingController(text: student['edited_score'].toString());

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
                          DataCell(
                            TextFormField(
                              controller: resultController,
                              keyboardType: TextInputType.number,
                              onChanged: (newValue) {
                                int? newScore = int.tryParse(newValue);
                                if (newScore != null) {
                                  setState(() {
                                    student['edited_score'] = newScore;
                                  });
                                }
                              },
                            ),
                          ),
                          DataCell(
                            DropdownButton<String>(
                              value: student["promotion_year"],
                              hint: Text("Select Year"),
                              items: years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (newYear) {
                                if (newYear != null) {
                                  setState(() {
                                    student["promotion_year"] = newYear;
                                  });
                                  promoteStudent(student['student_id'], newYear);
                                }
                              },
                            ),
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: student['result_score'] != student['edited_score']
                                  ? () async {
                                      await updateResultScore(
                                          student['student_id'], student['edited_score']);
                                      setState(() {
                                        student['result_score'] = student['edited_score'];
                                      });
                                    }
                                  : null,
                              child: Text("Save"),
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
