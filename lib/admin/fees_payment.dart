import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For currency formatting

class FeesPaymentPage extends StatefulWidget {
  const FeesPaymentPage({super.key});

  @override
  _FeesPaymentPageState createState() => _FeesPaymentPageState();
}

class _FeesPaymentPageState extends State<FeesPaymentPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> studentsFees = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  bool isSendingNotification = false;
  String? notificationStudentId;
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  String sortCriteria = "name"; // Default sort by name
  bool sortAscending = true;
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fetchFeesData();
    searchController.addListener(() => filterStudents());
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // 🔹 Fetch student fees data from backend
  Future<void> fetchFeesData() async {
    setState(() => isLoading = true);
    const String apiUrl = "http://localhost:5000/get_all_fees";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> studentsData = data["students"] ?? [];
        
        setState(() {
          studentsFees = studentsData.map<Map<String, dynamic>>((student) {
            final totalFees = student["total_fees"] ?? 0;
            final amountPaid = student["amount_paid"] ?? 0;
            final remainingFees = totalFees - amountPaid;
            final paymentPercentage = totalFees > 0 
                ? (amountPaid / totalFees * 100).clamp(0, 100) 
                : 0;
            
            return {
              ...student,
              "remaining_fees": remainingFees,
              "payment_percentage": paymentPercentage,
            };
          }).toList();
          
          sortStudents(); // Apply initial sorting
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load student fees data.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error fetching data: $e", isError: true);
    }
  }

  // 🔹 Sort students based on criteria
  void sortStudents() {
    setState(() {
      switch (sortCriteria) {
        case "name":
          studentsFees.sort((a, b) => sortAscending 
              ? a["name"].toString().compareTo(b["name"].toString()) 
              : b["name"].toString().compareTo(a["name"].toString()));
          break;
        case "remaining":
          studentsFees.sort((a, b) => sortAscending 
              ? (a["remaining_fees"] as num).compareTo(b["remaining_fees"] as num) 
              : (b["remaining_fees"] as num).compareTo(a["remaining_fees"] as num));
          break;
        case "percentage":
          studentsFees.sort((a, b) => sortAscending 
              ? (a["payment_percentage"] as num).compareTo(b["payment_percentage"] as num) 
              : (b["payment_percentage"] as num).compareTo(a["payment_percentage"] as num));
          break;
        default:
          studentsFees.sort((a, b) => a["name"].toString().compareTo(b["name"].toString()));
      }
      
      filterStudents(); // Apply filters after sorting
    });
  }

  // 🔹 Filter students based on search
  void filterStudents() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredStudents = studentsFees
          .where((student) =>
              student["name"].toString().toLowerCase().contains(query) ||
              student["student_id"].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  // 🔹 Send notification email
  Future<void> sendNotification(String studentId) async {
    setState(() {
      isSendingNotification = true;
      notificationStudentId = studentId;
    });
    
    const String apiUrl = "http://localhost:5000/send_fee_reminder";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      setState(() {
        isSendingNotification = false;
        notificationStudentId = null;
      });

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar(responseBody["message"] ?? "Notification sent successfully!");
      } else {
        throw Exception(responseBody["message"] ?? "Failed to send email.");
      }
    } catch (e) {
      setState(() {
        isSendingNotification = false;
        notificationStudentId = null;
      });
      
      _showSnackBar("Error sending notification: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Dashboard statistics
  int get totalStudents => filteredStudents.length;
  int get fullPaidCount => filteredStudents.where((s) => (s["remaining_fees"] as num) <= 0).length;
  int get pendingCount => filteredStudents.where((s) => (s["remaining_fees"] as num) > 0).length;
  int get criticalCount => filteredStudents.where((s) => s["payment_percentage"] as num < 50).length;
  double get collectionRate => totalStudents > 0 
      ? (fullPaidCount / totalStudents * 100) 
      : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Fees Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh data",
            onPressed: fetchFeesData,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo.shade600),
                  const SizedBox(height: 16),
                  Text(
                    "Loading fees data...",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildDashboard(),
                _buildSearchAndFilters(),
                Expanded(child: _buildStudentsList()),
              ],
            ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                "Total Students",
                totalStudents.toString(),
                Icons.people_alt,
                Colors.indigo,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                "Fully Paid",
                fullPaidCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                "Pending Fees",
                pendingCount.toString(),
                Icons.warning_amber,
                pendingCount > 0 ? Colors.orange : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Collection Rate: ${collectionRate.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                      if (criticalCount > 0)
                        Text(
                          "$criticalCount students have paid less than 50% of their fees",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or student ID...",
                prefixIcon: Icon(Icons.search, color: Colors.indigo.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                hintStyle: TextStyle(color: Colors.grey.shade500),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterStudents();
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sort Options
          Row(
            children: [
              Text(
                "Sort by:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              _buildSortChip("Name", "name"),
              const SizedBox(width: 8),
              _buildSortChip("Remaining Fees", "remaining"),
              const SizedBox(width: 8),
              _buildSortChip("Payment %", "percentage"),
              const Spacer(),
              IconButton(
                icon: Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.indigo.shade600,
                  size: 20,
                ),
                tooltip: sortAscending ? "Ascending" : "Descending",
                onPressed: () {
                  setState(() {
                    sortAscending = !sortAscending;
                    sortStudents();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = sortCriteria == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          sortCriteria = value;
          sortStudents();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.indigo.shade400 : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.isEmpty 
                ? "No student records found" 
                : "No students match your search",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (searchController.text.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  filterStudents();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Clear search"),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final totalFees = student["total_fees"] as int;
        final amountPaid = student["amount_paid"] as int;
        final remainingFees = student["remaining_fees"] as int;
        final paymentPercentage = student["payment_percentage"] as num;
        final hasPendingFees = remainingFees > 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _getStatusColor(paymentPercentage).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(paymentPercentage).withOpacity(0.2),
                      child: Text(
                        student["name"][0].toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(paymentPercentage),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student["name"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "ID: ${student["student_id"]}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(paymentPercentage),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Fees details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeeDetail("Total Fees", currencyFormat.format(totalFees), Colors.grey.shade800),
                    _buildFeeDetail("Paid", currencyFormat.format(amountPaid), Colors.green.shade700),
                    _buildFeeDetail(
                      "Remaining", 
                      currencyFormat.format(remainingFees), 
                      hasPendingFees ? Colors.red.shade700 : Colors.green.shade700
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Progress",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          "${paymentPercentage.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(paymentPercentage),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: paymentPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: _getStatusColor(paymentPercentage),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Implement view detailed history
                      },
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text("History"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo.shade700,
                        side: BorderSide(color: Colors.indigo.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: !hasPendingFees || (isSendingNotification && notificationStudentId == student["student_id"]) 
                          ? null 
                          : () => sendNotification(student["student_id"]),
                      icon: (isSendingNotification && notificationStudentId == student["student_id"])
                          ? SizedBox(
                              width: 16, 
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              hasPendingFees ? Icons.notifications_active : Icons.check_circle,
                              size: 16,
                            ),
                      label: Text(
                        (isSendingNotification && notificationStudentId == student["student_id"])
                            ? "Sending..."
                            : hasPendingFees 
                                ? "Send Reminder" 
                                : "Fully Paid"
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasPendingFees ? Colors.indigo.shade600 : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(num percentage) {
    String status;
    Color color;
    
    if (percentage >= 100) {
      status = "PAID";
      color = Colors.green;
    } else if (percentage >= 75) {
      status = "PARTIAL";
      color = Colors.blue;
    } else if (percentage >= 50) {
      status = "HALF PAID";
      color = Colors.amber;
    } else if (percentage > 0) {
      status = "MINIMAL";
      color = Colors.orange;
    } else {
      status = "UNPAID";
      color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFeeDetail(String label, String amount, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(num percentage) {
    if (percentage >= 100) return Colors.green.shade600;
    if (percentage >= 75) return Colors.blue.shade600;
    if (percentage >= 50) return Colors.amber.shade600;
    if (percentage > 0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}