import 'package:flutter/material.dart';
import 'admin_admission_page.dart';
import 'fees_page.dart';

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
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement Logout functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "👋 Welcome, Admin!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),

            // Admit Student Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.person_add, size: 28),
                  label: Text(
                    "Admit New Student",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color:Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: Colors.greenAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminAdmissionPage()),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 30),

            // Fees Management Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.black38,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade200,
                  child: Icon(Icons.payment, color: Colors.orange.shade800),
                ),
                title: Text(
                  "Fees Management",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text("Update, manage & track fees easily."),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please go to Admission Page first!"),
                      behavior: SnackBarBehavior.floating,
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