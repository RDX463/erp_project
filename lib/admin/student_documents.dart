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

  // Replace with your machine's IP address for device/emulator compatibility
  static const String baseUrl = 'http://127.0.0.1:5000'; // Update IP as needed

  Future<List<dynamic>> _fetchStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/get_students'));

    print('Fetch students response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['students'] ?? [];
    } else {
      throw Exception('Failed to load students: ${response.statusCode}');
    }
  }

  Future<void> _sendDocumentQuery(String studentId, String queryType, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_document_query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'query_type': queryType,
          'comment': comment,
        }),
      );
      print('Send query response: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query sent successfully!', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send query: $error', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('Error sending query: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending query: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _verifyDocument(String studentId, String documentUrl, bool verified) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/verify_document'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'document_url': documentUrl,
          'verified': verified,
        }),
      );
      print('Verify document response: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document verification updated', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {}); // Refresh UI
      } else {
        final error = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification: $error', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('Error verifying document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying document: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
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
          'Student Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar & Dropdown Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Student ID',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedDepartment,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDepartment = newValue!;
                    });
                  },
                  items: _departments
                      .map((dept) => DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  dropdownColor: Theme.of(context).colorScheme.background,
                ),
              ],
            ),
          ),
          // Student Documents List
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red.shade700) ??
                          TextStyle(color: Colors.red.shade700, fontSize: 18),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ) ?? TextStyle(color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                var students = snapshot.data!.where((student) {
                  String studentId = student['student_id'].toString();
                  String department = student['department'].toString();
                  bool matchesSearch = _searchController.text.isEmpty || studentId.contains(_searchController.text);
                  bool matchesFilter = _selectedDepartment == 'All' || department == _selectedDepartment;
                  return matchesSearch && matchesFilter;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    String studentId = student['student_id'];
                    String department = student['department'];
                    List<dynamic> documents = student['documents'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      child: Semantics(
                        label: 'Student $studentId documents',
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              studentId.isNotEmpty ? studentId[0] : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          title: Text(
                            studentId,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
                          ),
                          subtitle: Text(
                            'Dept: $department',
                            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Documents',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ) ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  documents.isEmpty
                                      ? Text(
                                          'No Documents',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.red.shade700,
                                              ) ?? TextStyle(color: Colors.red.shade700, fontSize: 14),
                                        )
                                      : Column(
                                          children: documents.map((doc) {
                                            bool verified = doc['verified'] ?? false;
                                            String fileName = doc['file_name'] ?? doc['url'].split('/').last;
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(
                                                verified ? Icons.check_circle : Icons.pending,
                                                color: verified ? Colors.green : Colors.orange,
                                                size: 24,
                                              ),
                                              title: GestureDetector(
                                                onTap: () async {
                                                  final url = Uri.parse(doc['url'].replaceAll('localhost', '127.0.0.1'));
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text('Cannot open document'),
                                                        backgroundColor: Colors.red.shade700,
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  fileName,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                      ) ?? const TextStyle(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                        fontSize: 14,
                                                      ),
                                                ),
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  verified ? Icons.verified : Icons.verified_user_outlined,
                                                  color: verified ? Colors.green : Colors.grey,
                                                ),
                                                onPressed: () => _verifyDocument(studentId, doc['url'], !verified),
                                                tooltip: verified ? 'Unverify' : 'Verify',
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.message, size: 18),
                                        label: const Text('Send Query'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange.shade700,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _sendQueryDialog(studentId),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
              title: Text(
                'Send Query to Student $studentId',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedQuery,
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedQuery = newValue!;
                      });
                    },
                    items: queryOptions
                        .map((query) => DropdownMenuItem<String>(
                              value: query,
                              child: Text(query),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Query Type',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: queryController,
                    decoration: InputDecoration(
                      labelText: 'Additional Comments (Optional)',
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
                    _sendDocumentQuery(studentId, selectedQuery, queryController.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Send', style: TextStyle(color: Colors.white)),
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