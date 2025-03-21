import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentFeesPayPage extends StatefulWidget {
  final String studentId;
  final bool isScholarshipApplicable;

  const StudentFeesPayPage({
    super.key,
    required this.studentId,
    required this.isScholarshipApplicable,
  });

  @override
  _StudentFeesPayPageState createState() => _StudentFeesPayPageState();
}

class _StudentFeesPayPageState extends State<StudentFeesPayPage> {
  bool isPaymentSuccessful = false;

  void processPayment() async {
    const int totalFees = 96000;
    const int scholarshipAmount = 43000;
    int payableFees = widget.isScholarshipApplicable ? (totalFees - scholarshipAmount) : totalFees;

    const String apiUrl = "http://localhost:5000/pay_fees";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_id": widget.studentId,
          "payable_fees": payableFees,
          "status": "Paid",
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isPaymentSuccessful = true;
        });

        _showDialog("Payment Successful", "Fees payment of ₹$payableFees has been completed.");
      } else {
        _showDialog("Payment Failed", responseBody["message"] ?? "Something went wrong!");
      }
    } catch (e) {
      _showDialog("Error", "Network error! Please try again.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isPaymentSuccessful) {
                  Navigator.pop(context); // Go back after successful payment
                }
              },
              child: const Text("OK", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const int totalFees = 96000;
    const int scholarshipAmount = 43000;
    int payableFees = widget.isScholarshipApplicable ? (totalFees - scholarshipAmount) : totalFees;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fees Payment"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fees Payment Details",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Student ID: ${widget.studentId}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Scholarship: ${widget.isScholarshipApplicable ? "Yes (₹43,000 discount)" : "No"}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text("Total Fees: ₹$totalFees", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Payable Fees: ₹$payableFees",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: processPayment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Proceed to Pay", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
