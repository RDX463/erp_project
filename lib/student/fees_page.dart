import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

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
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.deepPurple),
                  SizedBox(height: 20),
                  Text(
                    "Student Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
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
      appBar: AppBar(
        title: Text("Fees Payment"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("Student Name: $studentName", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)
              ),
            ),
            SizedBox(height: 20),
            _buildFeeDetail("Total Fees", totalFees),
            _buildFeeDetail("Paid Fees", paidFees),
            _buildFeeDetail("Remaining Fees", remainingFees),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (remainingFees != "0" && remainingFees != "Unknown") ? () => payFees() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Pay Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (paidFees != "0" && paidFees != "Unknown") ? () => printReceipt() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Print Receipt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDetail(String label, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ),
    );
  }

  void payFees() {}
  void printReceipt() {}
}
