import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class StudentDocuments extends StatefulWidget {
  @override
  _StudentDocumentsState createState() => _StudentDocumentsState();
}

class _StudentDocumentsState extends State<StudentDocuments> {
  TextEditingController searchController = TextEditingController();
  String selectedDepartment = "All";
  final List<String> departments = ["All", "COM", "AIDS", "MECH", "ENTC", "CIVIL"];

  Future<List<dynamic>> fetchStudents() async {
    final response = await http.get(Uri.parse("http://localhost:5000/get_students"));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data["students"];
    } else {
      throw Exception("Failed to load students");
    }
  }

  Future<void> sendDocumentQuery(String studentID, String queryType, String comment) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/send_document_query"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"student_id": studentID, "query_type": queryType, "comment": comment}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Query sent successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send query")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📄 Student Documents"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Bar & Dropdown Filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "🔎 Search by Student ID",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Trigger UI update
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedDepartment,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDepartment = newValue!;
                    });
                  },
                  items: departments.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Student Documents Table
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var students = snapshot.data!.where((student) {
                  var studentID = student["student_id"].toString();
                  var department = student["department"].toString();

                  bool matchesSearch = studentID.contains(searchController.text);
                  bool matchesFilter = selectedDepartment == "All" || department == selectedDepartment;

                  return matchesSearch && matchesFilter;
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text("Student Name")),
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Department")),
                      DataColumn(label: Text("Documents")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: students.map((student) {
                      String name = student["name"];
                      String studentID = student["student_id"];
                      String department = student["department"];
                      List<dynamic> documents = student["documents"] ?? [];

                      return DataRow(cells: [
                        DataCell(Text(name)),
                        DataCell(Text(studentID)),
                        DataCell(Text(department)),
                        DataCell(
                          documents.isEmpty
                              ? Text("❌ No Documents", style: TextStyle(color: Colors.red))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: documents.map((doc) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (await canLaunch(doc)) {
                                          await launch(doc);
                                        }
                                      },
                                      child: Text("📂 ${doc.split('/').last}", style: TextStyle(color: Colors.blue)),
                                    );
                                  }).toList(),
                                ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility, color: Colors.blue),
                                onPressed: documents.isNotEmpty
                                    ? () async {
                                        if (await canLaunch(documents.first)) {
                                          await launch(documents.first);
                                        }
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(Icons.message, color: Colors.orange),
                                onPressed: () {
                                  _sendQueryDialog(studentID);
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Admin Query Dialog
  void _sendQueryDialog(String studentID) {
    TextEditingController queryController = TextEditingController();
    List<String> queryOptions = ["Document Missing", "Incorrect Document", "Change Required"];
    String selectedQuery = queryOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("📩 Send Query to Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedQuery,
                onChanged: (newValue) {
                  setState(() {
                    selectedQuery = newValue!;
                  });
                },
                items: queryOptions.map((query) {
                  return DropdownMenuItem<String>(
                    value: query,
                    child: Text(query),
                  );
                }).toList(),
              ),
              TextField(
                controller: queryController,
                decoration: InputDecoration(
                  labelText: "Additional Comments (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                sendDocumentQuery(studentID, selectedQuery, queryController.text);
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }
}
