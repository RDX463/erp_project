import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class FacultyLeavePage extends StatefulWidget {
  final String employeeId;

  const FacultyLeavePage({super.key, required this.employeeId});

  @override
  _FacultyLeavePageState createState() => _FacultyLeavePageState();
}

class _FacultyLeavePageState extends State<FacultyLeavePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _leaveRequests = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  /// Fetch leave requests for the faculty
  Future<void> _fetchLeaveRequests() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/faculty/get_leaves/${widget.employeeId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          _leaveRequests = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load leave requests.");
      }
    } catch (e) {
      _showSnackBar("Error fetching leave requests: $e", isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show a snackbar with customized styling
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Submit a new leave request
  Future<void> _submitLeaveRequest() async {
    if (_dateController.text.isEmpty ||
        _daysController.text.isEmpty ||
        _reasonController.text.isEmpty) {
      _showSnackBar("Please fill all fields!", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final leaveData = {
      "employee_id": widget.employeeId,
      "leave_date": _dateController.text,
      "days": int.tryParse(_daysController.text) ?? 1,
      "reason": _reasonController.text,
      "status": "Pending"
    };

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/faculty/apply_leave"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(leaveData),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Leave request submitted successfully!");
        _dateController.clear();
        _daysController.clear();
        _reasonController.clear();
        setState(() {
          _selectedDate = null;
        });

        _fetchLeaveRequests();
      } else {
        throw Exception("Failed to submit leave request.");
      }
    } catch (e) {
      _showSnackBar("Error: $e", isError: true);
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  /// Open date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Leave Management"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Header Section with decorative wave
            Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Apply for Leave",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Complete the form below to submit your request",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Application Form
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Leave Request Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Date Field with Calendar Icon
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: _dateController,
                                    decoration: InputDecoration(
                                      labelText: "Leave Start Date",
                                      hintText: "YYYY-MM-DD",
                                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Number of Days Field
                              TextField(
                                controller: _daysController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Number of Days",
                                  hintText: "Enter number of leave days",
                                  prefixIcon: const Icon(Icons.date_range, color: Colors.indigo),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.indigo, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Reason Field
                              TextField(
                                controller: _reasonController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: "Reason for Leave",
                                  hintText: "Please provide detailed reason for leave",
                                  alignLabelWithHint: true,
                                  prefixIcon: const Icon(Icons.description, color: Colors.indigo),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.indigo, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitLeaveRequest,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.indigo.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.send),
                                            SizedBox(width: 8),
                                            Text(
                                              "Submit Leave Request",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Leave History Section
                      Row(
                        children: [
                          const Icon(Icons.history, color: Colors.indigo),
                          const SizedBox(width: 8),
                          const Text(
                            "Leave Request History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.indigo),
                            onPressed: _fetchLeaveRequests,
                            tooltip: "Refresh",
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Leave History List
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: Colors.indigo),
                              ),
                            )
                          : _leaveRequests.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.event_busy,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "No leave requests found",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _leaveRequests.length,
                                  itemBuilder: (context, index) {
                                    final leave = _leaveRequests[index];
                                    
                                    // Determine status color and icon
                                    Color statusColor;
                                    IconData statusIcon;
                                    
                                    switch(leave["status"]) {
                                      case "Approved":
                                        statusColor = Colors.green;
                                        statusIcon = Icons.check_circle;
                                        break;
                                      case "Rejected":
                                        statusColor = Colors.red;
                                        statusIcon = Icons.cancel;
                                        break;
                                      default:
                                        statusColor = Colors.orange;
                                        statusIcon = Icons.pending;
                                    }
                                    
                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(16),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: statusColor.withOpacity(0.1),
                                          ),
                                          child: Icon(
                                            statusIcon,
                                            color: statusColor,
                                            size: 30,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Leave on ${leave["leave_date"]}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: statusColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                leave["status"],
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${leave["days"]} day${leave["days"] > 1 ? 's' : ''}",
                                                  style: TextStyle(color: Colors.grey[800]),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.comment, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    "Reason: ${leave["reason"]}",
                                                    style: TextStyle(color: Colors.grey[800]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}