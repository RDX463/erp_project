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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPaymentSuccessful = false;

  void processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    const int totalFees = 96000;
    const int scholarshipAmount = 43000;
    int payableFees = widget.isScholarshipApplicable
        ? (totalFees - scholarshipAmount)
        : totalFees;

    int enteredAmount = int.tryParse(_amountController.text) ?? 0;

    if (enteredAmount <= 0 || enteredAmount > payableFees) {
      _showErrorSnackBar("Please enter a valid amount up to ₹$payableFees.");
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fees payment of ₹$enteredAmount has been completed."),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Navigate back after a short delay to show the success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showErrorSnackBar(responseBody["message"] ?? "Something went wrong!");
      }
    } catch (e) {
      _showErrorSnackBar("Network error! Please try again.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
        title: Text(
          "Student Fees Payment",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Process Fees Payment",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fees Payment Details",
                          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Student ID: ${widget.studentId}",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Scholarship: ${widget.isScholarshipApplicable ? "Yes (₹43,000 discount)" : "No"}",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Total Fees: ₹96,000",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Payable Fees: ₹$payableFees",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter amount to pay",
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixText: "₹",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an amount";
                            }
                            int? amount = int.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return "Please enter a valid amount";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: processPayment,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green,
                                  Colors.green.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Proceed to Pay",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}