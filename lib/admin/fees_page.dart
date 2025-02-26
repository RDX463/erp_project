import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeesPage extends StatefulWidget {
  final String studentId;

  FeesPage({required this.studentId});

  @override
  _FeesPageState createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  TextEditingController amountController = TextEditingController();
  int totalFees = 0, paidFees = 0, remainingFees = 0;
  bool isLoading = true;
  bool isPaying = false; // For button loader

  @override
  void initState() {
    super.initState();
    fetchFeesData();
  }

  // 🔹 Fetch Fees Data from API
  Future<void> fetchFeesData() async {
    setState(() => isLoading = true);

    final String apiUrl = 'http://localhost:5000/student/get-fees/${widget.studentId}'; // ✅ Corrected URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("📢 Fetching Fees: $apiUrl");
      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalFees = (data["total_fees"] as num).toInt();
          paidFees = (data["paid_fees"] as num).toInt();
          remainingFees = (data["remaining_fees"] as num).toInt();
        });
      } else {
        showError("Failed to fetch fees. Try again.");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Pay Fees API Call
  Future<void> payFees() async {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty || int.tryParse(amountText) == null) {
      showError("Enter a valid amount.");
      return;
    }

    final int amount = int.parse(amountText);
    if (amount <= 0 || amount > remainingFees) {
      showError("Amount must be within the remaining balance.");
      return;
    }

    setState(() => isPaying = true); // Show loader

    final String payApiUrl = 'http://localhost:5000/student/pay-fees'; // ✅ Corrected URL

    try {
      final response = await http.post(
        Uri.parse(payApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": widget.studentId,
          "amount_paid": amount,
          "payment_method": "Credit Card", // ✅ Added required field
        }),
      );

      print("📢 Paying Fees: $payApiUrl");
      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        fetchFeesData(); // Refresh data
        amountController.clear();
        showSuccess("Payment successful!");
      } else {
        showError("Payment failed. Try again.");
      }
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() => isPaying = false); // Hide loader
    }
  }

  // 🔹 Show Error Message
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // 🔹 Show Success Message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fees Payment")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Fees: ₹$totalFees",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Paid Fees: ₹$paidFees",
                      style: TextStyle(fontSize: 18, color: Colors.green)),
                  Text("Remaining Fees: ₹$remainingFees",
                      style: TextStyle(fontSize: 18, color: Colors.red)),

                  SizedBox(height: 20),

                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: "Amount to Pay",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isPaying ? null : payFees,
                    child: isPaying
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Pay Now"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
