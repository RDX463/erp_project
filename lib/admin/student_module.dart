import 'package:flutter/material.dart';
import 'student_admission.dart';
import 'fees_payment.dart';
import 'scholarship_eligibility.dart';
import 'student_promotion.dart';
import 'student_profile.dart';
import 'student_documents.dart';

class StudentModule extends StatelessWidget {
  const StudentModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Module"),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false, // Removes default back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Back to previous screen
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          buildListTile(
            context,
            title: "Student Admission",
            icon: Icons.person_add,
            page: const StudentAdmissionPage(),
          ),
          buildListTile(
            context,
            title: "Fees Payment",
            icon: Icons.payment,
            page: const FeesPaymentPage(),
          ),
          buildListTile(
            context,
            title: "Scholarship Eligibility",
            icon: Icons.school,
            page: const ScholarshipEligibilityPage(),
          ),
          buildListTile(
            context,
            title: "Student Promotion",
            icon: Icons.arrow_upward,
            page: const StudentPromotionPage(),
          ),
          buildListTile(
            context,
            title: "Student Profile",
            icon: Icons.person,
            page: const StudentProfilePage(),
          ),
          buildListTile(
            context,
            title: "Student Documents",
            icon: Icons.folder,
            page: StudentDocuments(),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context, {required String title, required IconData icon, required Widget page}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      ),
    );
  }
}
