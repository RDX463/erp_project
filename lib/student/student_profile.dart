import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentProfile({super.key, required this.student});

  String getStringValue(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is List && value.isNotEmpty) {
      return value[0].toString();
    } else if (value == null) {
      return 'N/A';
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Student map in profile: $student');
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
          "Student Profile",
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
                // Profile Avatar
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Student Name
                Center(
                  child: Text(
                    getStringValue(student['name']),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Student ID
                Center(
                  child: Text(
                    "ID: ${getStringValue(student['student_id'])}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Details
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileItem(
                          icon: Icons.email,
                          label: "Email",
                          value: getStringValue(student['email']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.school,
                          label: "Department",
                          value: getStringValue(student['department']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.location_on,
                          label: "Address",
                          value: getStringValue(student['address']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.person,
                          label: "Father's Name",
                          value: getStringValue(student['fatherName']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.person,
                          label: "Mother's Name",
                          value: getStringValue(student['motherName']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.grade,
                          label: "10th Marks",
                          value: getStringValue(student['marks10']),
                        ),
                        _buildDivider(),
                        _buildProfileItem(
                          icon: Icons.grade,
                          label: "12th Marks",
                          value: getStringValue(student['marks12']),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Placeholder for edit profile functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Back to Dashboard",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Colors.grey[300]),
    );
  }
}