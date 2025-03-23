import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScholarshipEligibilityPage extends StatefulWidget {
  const ScholarshipEligibilityPage({super.key});

  @override
  _ScholarshipEligibilityPageState createState() =>
      _ScholarshipEligibilityPageState();
}

class _ScholarshipEligibilityPageState
    extends State<ScholarshipEligibilityPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String selectedDepartment = "All";
  int? _expandedIndex;
  
  late AnimationController _animationController;
  final List<String> departments = ["All", "COM", "AIDS", "MECH", "ENTC", "CIVIL"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchScholarshipStudents();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchScholarshipStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    const url = 'http://localhost:5000/get_scholarship_students';

    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body);

      if (jsonData is Map && jsonData['status'] == 'success') {
        final List<dynamic> studentList = jsonData['students'] ?? [];
        setState(() {
          students = studentList.map<Map<String, dynamic>>((student) {
            final totalFees = student["total_fees"] ?? 0;
            final amountPaid = student["amount_paid"] ?? 0;
            final remainingFees = student["remaining_fees"] ?? totalFees - amountPaid;
            final paymentPercentage = totalFees > 0 
                ? (amountPaid / totalFees * 100).clamp(0, 100) 
                : 0;
                
            return {
              "student_id": student["student_id"]?.toString() ?? "N/A",
              "name": student["name"] ?? "Unknown",
              "email": student["email"] ?? "No Email",
              "department": student["department"] ?? "No Dept",
              "year": (student["year"] ?? "FE").toString(),
              "form_submitted": student["form_completed"] ?? false,
              "marks": student["marks"] ?? 0,
              "total_fees": totalFees,
              "amount_paid": amountPaid,
              "remaining_fees": remainingFees,
              "payment_percentage": paymentPercentage,
              "expanded": false,
            };
          }).toList();
          _filterStudents();
          _isLoading = false;
        });
      } else {
        throw Exception("Unexpected data format");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Error fetching data. Please check your connection.", isError: true);
    }
  }

  void _filterStudents() {
    setState(() {
      if (selectedDepartment == "All") {
        filteredStudents = List.from(students);
      } else {
        filteredStudents = students
            .where((student) => student["department"] == selectedDepartment)
            .toList();
      }
    });
  }

  Future<void> _sendFeeReminder(String studentId, String studentName) async {
    setState(() {
      _isProcessing = true;
    });
    
    const url = 'http://localhost:5000/send_fee_reminder';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"student_id": studentId}),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200) {
        _showSnackBar("Fee reminder sent to $studentName");
      } else {
        _showSnackBar("Failed to send fee reminder.", isError: true);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar("Error sending fee reminder.", isError: true);
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
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
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

  void _toggleExpandStudent(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  int _getTotalStudentsWithPendingFees() {
    return filteredStudents.where((student) => (student["remaining_fees"] ?? 0) > 0).length;
  }
  
  int _getTotalStudentsWithCompletedForms() {
    return filteredStudents.where((student) => student["form_submitted"] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    final int pendingFeesCount = _getTotalStudentsWithPendingFees();
    final int completedFormsCount = _getTotalStudentsWithCompletedForms();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Scholarship Eligibility",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700, 
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchScholarshipStudents,
            tooltip: "Refresh data",
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal.shade600),
                  const SizedBox(height: 16),
                  Text(
                    "Loading scholarship data...",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Dashboard summary
                Container(
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
                          Expanded(
                            child: _buildSummaryCard(
                              "Total Eligible",
                              filteredStudents.length.toString(),
                              Icons.school,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              "Pending Fees",
                              pendingFeesCount.toString(),
                              Icons.attach_money,
                              pendingFeesCount > 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              "Forms Completed",
                              "$completedFormsCount/${filteredStudents.length}",
                              Icons.assignment_turned_in,
                              Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Department filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: departments.map((dept) {
                            final isSelected = selectedDepartment == dept;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(dept),
                                selected: isSelected,
                                selectedColor: Colors.teal.shade100,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.teal.shade800 : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedDepartment = dept;
                                      _filterStudents();
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Student List
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
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
                                "No eligible students found",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (selectedDepartment != "All")
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      selectedDepartment = "All";
                                      _filterStudents();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Show all departments"),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final isExpanded = _expandedIndex == index;
                            final hasRemainingFees = (student["remaining_fees"] ?? 0) > 0;
                            final formSubmitted = student["form_submitted"] ?? false;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isExpanded ? 4 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isExpanded 
                                    ? Colors.teal.shade300
                                    : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Basic info tile
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    onTap: () => _toggleExpandStudent(index),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: _getDepartmentColor(student["department"]),
                                      child: Text(
                                        student["name"][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            student["name"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        _buildStatusBadge(
                                          formSubmitted ? "Form Completed" : "Form Pending",
                                          formSubmitted ? Colors.green : Colors.orange,
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildInfoChip(
                                              student["department"],
                                              _getDepartmentColor(student["department"]).withOpacity(0.2),
                                              _getDepartmentColor(student["department"]),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildInfoChip(
                                              "Year: ${student["year"]}",
                                              Colors.blueGrey.shade100,
                                              Colors.blueGrey.shade700,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "ID: ${student["student_id"]}",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Fee progress bar
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Fees Paid: ${(student["payment_percentage"] as num).toStringAsFixed(0)}%",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "₹${student["amount_paid"]} / ₹${student["total_fees"]}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: (student["payment_percentage"] as num) / 100,
                                                backgroundColor: Colors.grey.shade200,
                                                color: _getProgressColor(student["payment_percentage"] as num),
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.teal.shade700,
                                      ),
                                      onPressed: () => _toggleExpandStudent(index),
                                    ),
                                  ),
                                  
                                  // Expanded details
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox(height: 0),
                                    secondChild: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Divider(),
                                          _buildDetailRow("Email", student["email"], Icons.email),
                                          _buildDetailRow(
                                            "Marks", 
                                            "${student["marks"]}",
                                            Icons.grade,
                                          ),
                                          _buildDetailRow(
                                            "Remaining Fees", 
                                            "₹${student["remaining_fees"]}",
                                            Icons.account_balance_wallet,
                                            valueColor: hasRemainingFees 
                                              ? Colors.red.shade700 
                                              : Colors.green.shade700,
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              if (!formSubmitted)
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    // Form completion action would go here
                                                  },
                                                  icon: const Icon(Icons.assignment, size: 16),
                                                  label: const Text("Form Status"),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.blue.shade700,
                                                    side: BorderSide(color: Colors.blue.shade300),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                ),
                                              const SizedBox(width: 12),
                                              hasRemainingFees
                                                  ? ElevatedButton.icon(
                                                      onPressed: _isProcessing
                                                          ? null
                                                          : () => _sendFeeReminder(
                                                              student["student_id"],
                                                              student["name"],
                                                            ),
                                                      icon: _isProcessing
                                                          ? Container(
                                                              width: 16,
                                                              height: 16,
                                                              padding: const EdgeInsets.all(2),
                                                              child: const CircularProgressIndicator(
                                                                color: Colors.white,
                                                                strokeWidth: 2,
                                                              ),
                                                            )
                                                          : const Icon(Icons.notifications_active, size: 16),
                                                      label: Text(_isProcessing ? "Sending..." : "Send Reminder"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.teal.shade700,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      ),
                                                    )
                                                  : ElevatedButton.icon(
                                                      onPressed: null,
                                                      icon: const Icon(Icons.check_circle, size: 16),
                                                      label: const Text("Fully Paid"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.grey.shade300,
                                                        foregroundColor: Colors.grey.shade700,
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
                                    crossFadeState: isExpanded 
                                      ? CrossFadeState.showSecond 
                                      : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color, // Fixed: removed .shade800
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
    );
  }
  
  Widget _buildInfoChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getDepartmentColor(String department) {
    switch (department) {
      case "COM":
        return Colors.blue.shade700;
      case "AIDS":
        return Colors.purple.shade700;
      case "MECH":
        return Colors.orange.shade700;
      case "ENTC":
        return Colors.green.shade700;
      case "CIVIL":
        return Colors.brown.shade700;
      default:
        return Colors.teal.shade700;
    }
  }
  
  Color _getProgressColor(num percentage) {
    if (percentage >= 100) return Colors.green.shade600;
    if (percentage >= 75) return Colors.lightGreen.shade600;
    if (percentage >= 50) return Colors.amber.shade600;
    if (percentage >= 25) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}