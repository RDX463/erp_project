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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching results: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete the form and select a file')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json['message'])));
        _fetchUploadedResults();
        setState(() {
          _semester = null;
          _examType = null;
          _selectedFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json['detail'] ?? 'Upload failed')));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading result: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _semester,
                    hint: const Text('Select Semester'),
                    items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (value) => setState(() => _semester = value),
                    validator: (value) => value == null ? 'Please select a semester' : null,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _examType,
                    hint: const Text('Select Exam Type'),
                    items: _examTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) => setState(() => _examType = value),
                    validator: (value) => value == null ? 'Please select an exam type' : null,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text(_selectedFile == null ? 'Select PDF File' : 'File: ${_selectedFile!.name}'),
                  ),
                  const SizedBox(height: 16),
                  _isUploading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _uploadResult,
                          child: const Text('Upload Result'),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedResults.length,
                itemBuilder: (context, index) {
                  final result = _uploadedResults[index];
                  return Card(
                    child: ListTile(
                      title: Text('${result['semester']} - ${result['exam_type']}'),
                      subtitle: Text('Status: ${result['status']}'),
                      trailing: Text(result['uploaded_at'].split('T')[0]),
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