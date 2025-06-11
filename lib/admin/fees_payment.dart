import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class FeesPaymentPage extends StatefulWidget {
  const FeesPaymentPage({super.key});

  @override
  _FeesPaymentPageState createState() => _FeesPaymentPageState();
}

class _FeesPaymentPageState extends State<FeesPaymentPage> {
  List<Map<String, dynamic>> studentsFees = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchFees();
    _searchController.addListener(_debouncedFilterStudents);
  }

  // Fetch student fees data from backend
  Future<void> fetchFees() async {
    const String apiUrl = "http://localhost:5000/get_all_fees"; // Replace with actual IP if needed

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            studentsFees = (json["students"] as List).map((student) => {
                  "student_id": student["student_id"],
                  "total_fees": (student["total_fees"] as num).toInt(),
                  "amount_paid": (student["amount_paid"] as num).toInt(),
                  "remaining_fees": (student["remaining_fees"] as num).toInt(),
                }).toList();
            filteredStudents = studentsFees;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load student fees data: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Error fetching data: $e");
      }
    }
  }

  // Debounced search
  void _debouncedFilterStudents() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterStudents();
    });
  }

  // Filter students based on search query
  void filterStudents() {
    String query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        filteredStudents = studentsFees
            .where((student) => student["student_id"].toLowerCase().contains(query))
            .toList();
      });
    }
  }

  // Send notification email
  Future<void> sendNotification(String studentId) async {
    const String apiUrl = "http://localhost:5000/student/send_fee_reminder"; // Replace with actual IP

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        _showSuccessSnackBar(responseBody["message"]);
      } else {
        throw Exception(responseBody["message"] ?? "Failed to send email.");
      }
    } catch (e) {
      _showErrorSnackBar("Error sending email: $e");
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Fees Payment Management",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Column(
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
                          "Manage Student Fees",
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                              ) ?? const TextStyle(
                                fontSize: 22,
                                color: Colors.blue, // Fallback color
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by student ID...",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
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
                  ),
                ),
                // Fees List Section - Fixed with Expanded
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        var student = filteredStudents[index];
                        int remainingFees = student["remaining_fees"];
                        bool hasPendingFees = remainingFees > 0;

                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Semantics(
                            label: "Student ${student["student_id"]} fee details",
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              title: Text(
                                "Student ID: ${student["student_id"]}",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ) ?? const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    "Total Fees: ₹${student["total_fees"]}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        ) ?? const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                  ),
                                  Text(
                                    "Paid: ₹${student["amount_paid"]}",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ) ?? const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                  ),
                                  Text(
                                    "Remaining: ₹$remainingFees",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          color: hasPendingFees ? Colors.red : Colors.green,
                                        ) ?? TextStyle(
                                          fontSize: 16,
                                          color: hasPendingFees ? Colors.red : Colors.green,
                                        ),
                                  ),
                                ],
                              ),
                              trailing: Semantics(
                                label: hasPendingFees ? "Send fee reminder for ${student["student_id"]}" : "No action available",
                                child: ElevatedButton(
                                  onPressed: hasPendingFees ? () => sendNotification(student["student_id"]) : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: hasPendingFees
                                            ? [Colors.red, Colors.red.shade700]
                                            : [Colors.grey, Colors.grey.shade700],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Notify",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ) ?? const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}