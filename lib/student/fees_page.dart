import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  Future<void> loginUser() async {
    final response = await http.post(
      Uri.parse("http://localhost:8000/student/login"),
      body: json.encode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Save email in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('student_email', emailController.text);

      // Navigate to the Fees Payment page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FeesPaymentPage()),
      );
    } else {
      setState(() {
        errorMessage = "Invalid email or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            ElevatedButton(
              onPressed: loginUser,
              child: Text("Login"),
            ),
            if (errorMessage.isNotEmpty) 
              Text(errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class FeesPaymentPage extends StatefulWidget {
  @override
  _FeesPaymentPageState createState() => _FeesPaymentPageState();
}

class _FeesPaymentPageState extends State<FeesPaymentPage> {
  String studentEmail = "";
  String studentName = "Loading...";
  String totalFees = "Unknown";
  String paidFees = "Unknown";
  String remainingFees = "Unknown";
  String selectedYear = "2025";

  @override
  void initState() {
    super.initState();
    fetchStudentEmail();  // Fetch email from SharedPreferences
  }

  // Fetch the student's email from SharedPreferences
  Future<void> fetchStudentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      studentEmail = prefs.getString('student_email') ?? '';
    });

    if (studentEmail.isNotEmpty) {
      fetchStudentName();  // Fetch student name if email is available
      fetchFeesData();  // Fetch fees data if email is available
    }
  }

  // Fetch Student Name from the API
  Future<void> fetchStudentName() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/get_student_name_by_email?email=$studentEmail"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        studentName = data["full_name"];
      });
    } else {
      setState(() {
        studentName = "Not Found";
      });
    }
  }

  // Fetch Fees Data from the API
  Future<void> fetchFeesData() async {
    final response = await http.get(
      Uri.parse("http://localhost:8000/get_student_fees?email=$studentEmail&academic_year=$selectedYear"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalFees = data["total_fees"].toString();
        paidFees = data["paid_fees"].toString();
        remainingFees = data["remaining_fees"].toString();
      });
    } else {
      setState(() {
        totalFees = "Unknown";
        paidFees = "Unknown";
        remainingFees = "Unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentEmail.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Fees Payment")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Fees Payment")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student Name: $studentName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Select Academic Year:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedYear,
              items: ["2023", "2024", "2025"]
                  .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                  .toList(),
              onChanged: (newYear) {
                setState(() {
                  selectedYear = newYear!;
                  fetchFeesData();  // Fetch fees again for the new year
                });
              },
            ),
            SizedBox(height: 20),
            _buildFeeDetail("Total Fees", totalFees),
            _buildFeeDetail("Paid Fees", paidFees),
            _buildFeeDetail("Remaining Fees", remainingFees),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: null,  // Disabled (Admin updates fees)
                child: Text("Pay Now"),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: null,  // Disabled (Receipt requires valid fees data)
                child: Text("Print Receipt"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
