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
        const SnackBar(content: Text("Query sent successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send query")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📄 Student Documents"),
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
                    decoration: const InputDecoration(
                      labelText: "🔎 Search by Student ID",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
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
                  return const Center(child: CircularProgressIndicator());
                }

                var students = snapshot.data!.where((student) {
                  String studentID = student["student_id"].toString();
                  String department = student["department"].toString();

                  bool matchesSearch = studentID.contains(searchController.text);
                  bool matchesFilter = selectedDepartment == "All" || department == selectedDepartment;

                  return matchesSearch && matchesFilter;
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Student ID")),
                      DataColumn(label: Text("Department")),
                      DataColumn(label: Text("Documents")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: students.map((student) {
                      String studentID = student["student_id"];
                      String department = student["department"];
                      List<dynamic> documents = student["documents"] ?? [];

                      return DataRow(cells: [
                        DataCell(Text(studentID)),
                        DataCell(Text(department)),
                        DataCell(
                          documents.isEmpty
                              ? const Text("❌ No Documents", style: TextStyle(color: Colors.red))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: documents.map((doc) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (await canLaunchUrl(Uri.parse(doc))) {
                                          await launchUrl(Uri.parse(doc), mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      child: Text(
                                        "📂 ${doc.split('/').last}",
                                        style: const TextStyle(color: Colors.blue),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: documents.isNotEmpty
                                    ? () async {
                                        final url = Uri.parse(documents.first);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.orange),
                                onPressed: () => _sendQueryDialog(studentID),
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
          title: const Text("📩 Send Query to Student"),
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
              const SizedBox(height: 8),
              TextField(
                controller: queryController,
                decoration: const InputDecoration(
                  labelText: "Additional Comments (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                sendDocumentQuery(studentID, selectedQuery, queryController.text);
                Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }
}
