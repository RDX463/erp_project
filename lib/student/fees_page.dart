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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('student_email', emailController.text);

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
            SizedBox(height: 20),
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentEmail();
  }

  Future<void> fetchStudentEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      studentEmail = prefs.getString('student_email') ?? '';
    });

    if (studentEmail.isNotEmpty) {
      await fetchStudentData();
    }
  }

  Future<void> fetchStudentData() async {
    try {
      final nameResponse = await http.get(
        Uri.parse("http://localhost:8000/get_student_name_by_email?email=$studentEmail"),
      );
      final feesResponse = await http.get(
        Uri.parse("http://localhost:8000/get_student_fees?email=$studentEmail&academic_year=$selectedYear"),
      );

      if (nameResponse.statusCode == 200 && feesResponse.statusCode == 200) {
        final nameData = json.decode(nameResponse.body);
        final feesData = json.decode(feesResponse.body);

        setState(() {
          studentName = nameData["full_name"];
          totalFees = feesData["total_fees"].toString();
          paidFees = feesData["paid_fees"].toString();
          remainingFees = feesData["remaining_fees"].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          studentName = "Not Found";
          totalFees = "Error fetching";
          paidFees = "Error fetching";
          remainingFees = "Error fetching";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        studentName = "Error loading";
        totalFees = "Error";
        paidFees = "Error";
        remainingFees = "Error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
                  isLoading = true;
                });
                fetchStudentData();
              },
            ),
            SizedBox(height: 20),
            _buildFeeDetail("Total Fees", totalFees),
            _buildFeeDetail("Paid Fees", paidFees),
            _buildFeeDetail("Remaining Fees", remainingFees),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (remainingFees != "0" && remainingFees != "Unknown") ? () => payFees() : null,
                child: Text("Pay Now"),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (paidFees != "0" && paidFees != "Unknown") ? () => printReceipt() : null,
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

  void payFees() {
    // Implement payment logic here
    print("Payment initiated for $studentEmail");
  }

  void printReceipt() {
    // Implement receipt printing logic here
    print("Receipt printing for $studentEmail");
  }
}
