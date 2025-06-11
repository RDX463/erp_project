import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

class DocumentUpload extends StatefulWidget {
  final Map<String, dynamic> student;

  const DocumentUpload({super.key, required this.student});

  @override
  _DocumentUploadState createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  bool _isUploading = false;
  String? _errorMessage;
  String? _fileName;

  Future<void> _uploadDocument() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
      _fileName = result.files.single.name;
    });

    final file = File(result.files.single.path!);
    final uri = Uri.parse('http://127.0.0.1:5000/upload_document');

    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['student_id'] = widget.student['student_id']
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Document uploaded successfully'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          _fileName = null;
        });
      } else {
        setState(() {
          _errorMessage = json.decode(responseBody)['detail'] ?? 'Upload failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
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
          "Upload Document",
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
                  'Upload Your Document',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported formats: PDF, JPG, JPEG, PNG',
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
                    child: Column(
                      children: [
                        if (_fileName != null) ...[
                          Row(
                            children: [
                              Icon(
                                _fileName!.toLowerCase().endsWith('.pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: Theme.of(context).primaryColor,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _fileName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _fileName = null;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadDocument,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Select & Upload Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isUploading) ...[
                          const SizedBox(height: 16),
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
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