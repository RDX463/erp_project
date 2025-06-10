import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class StudentDocumentsWidget extends StatelessWidget {
  const StudentDocumentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDocuments();
  }
}

class StudentDocuments extends StatefulWidget {
  const StudentDocuments({super.key});

  @override
  _StudentDocumentsState createState() => _StudentDocumentsState();
}

class _StudentDocumentsState extends State<StudentDocuments> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = "All";
  final List<String> _departments = ["All", "COM", "AIDS", "MECH", "ENTC", "CIVIL"];

  Future<List<dynamic>> _fetchStudents() async {
    final response = await http.get(Uri.parse('http://localhost:5000/get_students'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['students'];
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> _sendDocumentQuery(String studentId, String queryType, String comment) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/send_document_query'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_id': studentId,
        'query_type': queryType,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Query sent successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send query')),
      );
    }
  }

  Future<void> _verifyDocument(String studentId, String documentUrl, bool verified) async {
    final response = await http.patch(
      Uri.parse('http://localhost:5000/verify_document'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_id': studentId,
        'document_url': documentUrl,
        'verified': verified,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document verification updated')),
      );
      setState(() {}); // Refresh the table
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update verification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Student Documents'),
        backgroundColor: Theme.of(context).primaryColor,
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
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '🔎 Search by Student ID',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedDepartment,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDepartment = newValue!;
                    });
                  },
                  items: _departments.map((dept) {
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
              future: _fetchStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                var students = snapshot.data!.where((student) {
                  String studentId = student['student_id'].toString();
                  String department = student['department'].toString();

                  bool matchesSearch = studentId.contains(_searchController.text);
                  bool matchesFilter = _selectedDepartment == 'All' || department == _selectedDepartment;

                  return matchesSearch && matchesFilter;
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Student ID')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Documents')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: students.map((student) {
                      String studentId = student['student_id'];
                      String department = student['department'];
                      List<dynamic> documents = student['documents'] ?? [];

                      return DataRow(cells: [
                        DataCell(Text(studentId)),
                        DataCell(Text(department)),
                        DataCell(
                          documents.isEmpty
                              ? const Text('❌ No Documents', style: TextStyle(color: Colors.red))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: documents.map((doc) {
                                    bool verified = doc['verified'] ?? false;
                                    String fileName = doc['file_name'] ?? doc['url'].split('/').last;
                                    return Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final url = Uri.parse(doc['url']);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          child: Text(
                                            '📂 $fileName',
                                            style: const TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          verified ? Icons.check_circle : Icons.pending,
                                          color: verified ? Colors.green : Colors.orange,
                                          size: 16,
                                        ),
                                      ],
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
                                        final url = Uri.parse(documents.first['url']);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Colors.orange),
                                onPressed: () => _sendQueryDialog(studentId),
                              ),
                              if (documents.isNotEmpty)
                                ...documents.map((doc) {
                                  bool verified = doc['verified'] ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      verified ? Icons.verified : Icons.verified_user_outlined,
                                      color: verified ? Colors.green : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _verifyDocument(studentId, doc['url'], !verified);
                                    },
                                  );
                                }),
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
  void _sendQueryDialog(String studentId) {
    final TextEditingController queryController = TextEditingController();
    final List<String> queryOptions = ['Document Missing', 'Incorrect Document', 'Change Required'];
    String selectedQuery = queryOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('📩 Send Query to Student'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedQuery,
                    onChanged: (newValue) {
                      setDialogState(() {
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
                      labelText: 'Additional Comments (Optional)',
                      border: OutlineInputBorder(),
                    ),
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
                    _sendDocumentQuery(studentId, selectedQuery, queryController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
