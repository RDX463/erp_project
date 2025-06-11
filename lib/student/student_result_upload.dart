import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class StudentResultUploadPage extends StatefulWidget {
  final String studentId;

  const StudentResultUploadPage({super.key, required this.studentId});

  @override
  _StudentResultUploadPageState createState() => _StudentResultUploadPageState();
}

class _StudentResultUploadPageState extends State<StudentResultUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _semester;
  String? _examType;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  List<Map<String, dynamic>> _uploadedResults = [];

  final List<String> _semesters = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6'];
  final List<String> _examTypes = ['Regular', 'Revaluation', 'Backlog'];

  @override
  void initState() {
    super.initState();
    _fetchUploadedResults();
  }

  Future<void> _fetchUploadedResults() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/results/${widget.studentId}'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _uploadedResults = List<Map<String, dynamic>>.from(json['results']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching results: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadResult() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete the form and select a file'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://localhost:5000/upload_result'));
      request.fields['student_id'] = widget.studentId;
      request.fields['semester'] = _semester!;
      request.fields['exam_type'] = _examType!;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _selectedFile!.bytes!,
        filename: path.basename(_selectedFile!.path!),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);

      setState(() => _isUploading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message']),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        _fetchUploadedResults();
        setState(() {
          _semester = null;
          _examType = null;
          _selectedFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['detail'] ?? 'Upload failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading result: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          "Upload Results",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Exam Result',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select semester, exam type, and upload a PDF file',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _semester,
                            hint: const Text('Select Semester'),
                            items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (value) => setState(() => _semester = value),
                            validator: (value) => value == null ? 'Please select a semester' : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _examType,
                            hint: const Text('Select Exam Type'),
                            items: _examTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (value) => setState(() => _examType = value),
                            validator: (value) => value == null ? 'Please select an exam type' : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.attach_file),
                                  label: Text(
                                    _selectedFile == null ? 'Select PDF File' : _selectedFile!.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                    elevation: 2,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _isUploading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _uploadResult,
                                  icon: const Icon(Icons.upload),
                                  label: const Text('Upload Result'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Uploaded Results',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                _uploadedResults.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No results uploaded yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _uploadedResults.length,
                        itemBuilder: (context, index) {
                          final result = _uploadedResults[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                '${result['semester']} - ${result['exam_type']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Status: ${result['status']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                result['uploaded_at'].split('T')[0],
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}