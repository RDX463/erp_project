import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeesPaymentPage extends StatefulWidget {
  const FeesPaymentPage({super.key});

  @override
  _FeesPaymentPageState createState() => _FeesPaymentPageState();
}

class _FeesPaymentPageState extends State<FeesPaymentPage> {
  List<Map<String, dynamic>> studentsFees = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFeesData();
    searchController.addListener(() => filterStudents());
  }

  // 🔹 Fetch student fees data from backend
  Future<void> fetchFeesData() async {
    const String apiUrl = "http://localhost:5000/get_all_fees"; // Corrected URL

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          studentsFees = (json["students"] as List).map((student) => {
                "student_id": student["student_id"],
                "total_fees": (student["total_fees"] as num).toInt(),
                "amount_paid": (student["amount_paid"] as num).toInt(),
                "remaining_fees": (student["remaining_fees"] as num).toInt(),
              }).toList();
          filteredStudents = studentsFees;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load student fees data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  // 🔹 Filter students based on search
  void filterStudents() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredStudents = studentsFees
          .where((student) => student["student_id"].toLowerCase().contains(query))
          .toList();
    });
  }

  // 🔹 Send notification email
  Future<void> sendNotification(String studentId) async {
    const String apiUrl = "http://localhost:5000/student/send_fee_reminder"; // Corrected endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"]),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception(responseBody["message"] ?? "Failed to send email.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending email: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fees Payment Management"), backgroundColor: Colors.blueAccent),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by student ID...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📋 Fees Table
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        var student = filteredStudents[index];
                        int remainingFees = student["remaining_fees"]; // Use precomputed value
                        bool hasPendingFees = remainingFees > 0;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            title: Text(
                              "Student ID: ${student["student_id"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Fees: ₹${student["total_fees"]}"),
                                Text("Paid: ₹${student["amount_paid"]}", style: const TextStyle(color: Colors.green)),
                                Text(
                                  "Remaining: ₹$remainingFees",
                                  style: TextStyle(color: hasPendingFees ? Colors.red : Colors.green),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: hasPendingFees ? () => sendNotification(student["student_id"]) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasPendingFees ? Colors.red : Colors.grey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Notify", style: TextStyle(color: Colors.white)),
                            ),
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