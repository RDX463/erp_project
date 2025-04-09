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
  final TextEditingController _amountController = TextEditingController();
  bool isPaymentSuccessful = false;

  void processPayment() async {
    const int totalFees = 96000;
    const int scholarshipAmount = 43000;
    int payableFees = widget.isScholarshipApplicable
        ? (totalFees - scholarshipAmount)
        : totalFees;

    int enteredAmount = int.tryParse(_amountController.text) ?? 0;

    if (enteredAmount <= 0 || enteredAmount > payableFees) {
      _showDialog(
          "Invalid Amount", "Please enter a valid amount up to ₹$payableFees.");
      return;
    }

    const String apiUrl = "http://localhost:5000/pay_fees";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_id": widget.studentId,
          "amount_paid": enteredAmount,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isPaymentSuccessful = true;
        });

        _showDialog("Payment Successful",
            "Fees payment of ₹$enteredAmount has been completed.");
      } else {
        _showDialog("Payment Failed",
            responseBody["message"] ?? "Something went wrong!");
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
                  Navigator.pop(context); // Return after success
                }
              },
              child: const Text("OK",
                  style: TextStyle(color: Colors.blueAccent)),
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
    int payableFees = widget.isScholarshipApplicable
        ? (totalFees - scholarshipAmount)
        : totalFees;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fees Payment"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fees Payment Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Student ID: ${widget.studentId}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Scholarship: ${widget.isScholarshipApplicable ? "Yes (₹43,000 discount)" : "No"}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text("Total Fees: ₹96000", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Payable Fees: ₹$payableFees",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter amount to pay",
                border: OutlineInputBorder(),
                prefixText: "₹",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: processPayment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Proceed to Pay",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
