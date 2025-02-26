import 'package:flutter/material.dart';
import 'admin_admission_page.dart';  // Import Student Admission Page
import 'fees_page.dart';  // Import Fees Management Page

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement Logout Functionality
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Admin!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // 📌 Admit Student Button
            ElevatedButton.icon(
              icon: Icon(Icons.person_add),
              label: Text("Admit Student"),
              onPressed: () {
                // Navigate to Student Admission Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminAdmissionPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),

            // 📌 Fees Management Section
            Card(
  elevation: 4,
  child: ListTile(
    leading: Icon(Icons.payment, color: Colors.orange),
    title: Text("Fees Management"),
    subtitle: Text("Update and track student fees"),
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Go to Admission Page first!"))
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
