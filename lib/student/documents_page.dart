import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsPage extends StatefulWidget {
  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> with SingleTickerProviderStateMixin {
  String? selectedFileName;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Try FileType.custom if needed
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
      });
    }
  } catch (e) {
    print("❌ Error picking file: $e");
  }
}

  void _uploadFile() {
    if (selectedFileName != null) {
      // Simulate file upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$selectedFileName uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a file first!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Upload Documents", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upload Your Scholarship Documents",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Glassmorphism File Selection Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.file_present, size: 50, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(height: 10),
                      const Text(
                        "Select a file to upload",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(height: 15),

                      // File Picker Button
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open, color: Colors.white),
                        label: const Text("Choose File", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Show Selected File Name with Animation
                if (selectedFileName != null)
                  ScaleTransition(
                    scale: _animationController,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.file_copy, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Selected File: $selectedFileName",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Upload Button with Animation
                ElevatedButton.icon(
                  onPressed: _uploadFile,
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text("Upload", style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    shadowColor: Colors.black.withOpacity(0.3),
                    elevation: 8,
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
