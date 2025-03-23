import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class FacultyLeaveManagementPage extends StatefulWidget {
  @override
  _FacultyLeaveManagementPageState createState() => _FacultyLeaveManagementPageState();
}

class _FacultyLeaveManagementPageState extends State<FacultyLeaveManagementPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allLeaveRequests = [];
  List<Map<String, dynamic>> _filteredLeaveRequests = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String _processingEmployeeId = "";
  String _selectedFilter = "All";
  int? _expandedIndex;
  
  late AnimationController _animationController;
  
  final List<String> _filterOptions = ["All", "Pending", "Approved", "Rejected"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchLeaveRequests();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Fetch all leave requests from backend
  Future<void> _fetchLeaveRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/faculty/get_all_leaves"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allLeaveRequests = List<Map<String, dynamic>>.from(data);
          _filterLeaveRequests(_selectedFilter);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load leave requests.");
      }
    } catch (e) {
      _showErrorSnackbar("Error fetching leave requests: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filter leave requests by status
  void _filterLeaveRequests(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == "All") {
        _filteredLeaveRequests = List.from(_allLeaveRequests);
      } else {
        _filteredLeaveRequests = _allLeaveRequests
            .where((leave) => leave["status"] == filter)
            .toList();
      }
    });
  }

  /// Approve or Reject Leave Request
  Future<void> _updateLeaveStatus(String employeeId, String leaveName, String status) async {
    setState(() {
      _isProcessing = true;
      _processingEmployeeId = employeeId;
    });
    
    try {
      final response = await http.put(
        Uri.parse("http://127.0.0.1:5000/faculty/update_leave"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"employee_id": employeeId, "status": status}),
      );

      setState(() {
        _isProcessing = false;
        _processingEmployeeId = "";
      });

      if (response.statusCode == 200) {
        _showSuccessSnackbar("$leaveName's leave request ${status.toLowerCase()} successfully!");
        await _fetchLeaveRequests(); // Refresh list after update
      } else {
        throw Exception("Failed to update leave request.");
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingEmployeeId = "";
      });
      _showErrorSnackbar("Error: $e");
    }
  }

  void _confirmUpdateStatus(String employeeId, String name, String status) {
    final String statusAction = status == "Approved" ? "approve" : "reject";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                status == "Approved" ? Icons.check_circle : Icons.cancel,
                color: status == "Approved" ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text("Confirm $status"),
            ],
          ),
          content: Text("Are you sure you want to $statusAction $name's leave request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateLeaveStatus(employeeId, name, status);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == "Approved" ? Colors.green.shade600 : Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(status),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Format date string to a more readable format
  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      
      return "${date.day} ${months[date.month - 1]}, ${date.year}";
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }
  
  // Calculate leave duration in days
  String _getLeaveDuration(Map<String, dynamic> leave) {
    try {
      if (leave["end_date"] != null) {
        final DateTime startDate = DateTime.parse(leave["leave_date"]);
        final DateTime endDate = DateTime.parse(leave["end_date"]);
        final int days = endDate.difference(startDate).inDays + 1;
        return "$days ${days == 1 ? 'day' : 'days'}";
      } else {
        return "1 day";
      }
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Leave Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaveRequests,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterOptions(),
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _filteredLeaveRequests.isEmpty
                    ? _buildEmptyView()
                    : _buildLeaveList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    // Count leaves by status
    final int pendingCount = _allLeaveRequests.where((leave) => leave["status"] == "Pending").length;
    final int approvedCount = _allLeaveRequests.where((leave) => leave["status"] == "Approved").length;
    final int rejectedCount = _allLeaveRequests.where((leave) => leave["status"] == "Rejected").length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_available,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Faculty Leave Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Manage and process faculty leave applications",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Total: ${_allLeaveRequests.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatusCard("Pending", pendingCount, Colors.orange),
              const SizedBox(width: 8),
              _buildStatusCard("Approved", approvedCount, Colors.green),
              const SizedBox(width: 8),
              _buildStatusCard("Rejected", rejectedCount, Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(String status, int count, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.shade300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            "Filter by status:",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final bool isSelected = _selectedFilter == filter;
                  final Color filterColor = _getFilterColor(filter);
                  
                  return GestureDetector(
                    onTap: () => _filterLeaveRequests(filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? filterColor.withOpacity(0.2) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? filterColor : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? filterColor : Colors.grey.shade700,
                            ),
                          ),
                          if (filter != "All")
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? filterColor : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _countByStatus(filter).toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countByStatus(String status) {
    return _allLeaveRequests.where((leave) => leave["status"] == status).length;
  }
  
  MaterialColor _getFilterColor(String filter) {
    switch (filter) {
      case "Pending":
        return Colors.orange;
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.purple.shade700),
          const SizedBox(height: 16),
          Text(
            "Loading leave requests...",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter != "All" ? Icons.filter_list_off : Icons.event_busy,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter != "All"
                ? "No $_selectedFilter leave requests found"
                : "No leave requests available",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedFilter != "All")
            TextButton.icon(
              onPressed: () => _filterLeaveRequests("All"),
              icon: const Icon(Icons.filter_list),
              label: const Text("Show all requests"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLeaveRequests.length,
      itemBuilder: (context, index) {
        final leave = _filteredLeaveRequests[index];
        final String status = leave["status"] ?? "Unknown";
        final Color statusColor = _getStatusColor(status);
        final bool isPending = status == "Pending";
        final bool isExpanded = _expandedIndex == index;
        final bool isProcessingThis = _isProcessing && _processingEmployeeId == leave["employee_id"];
        
        // Generate faculty initial for avatar
        final String name = leave["name"] ?? "Unknown";
        final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
        
        return Card(
          elevation: isExpanded ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isExpanded ? statusColor.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: statusColor,
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
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${leave["employee_id"] ?? "Unknown"}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(leave["leave_date"] ?? "Unknown"),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getLeaveDuration(leave),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status, statusColor),
                    ],
                  ),
                ),
                // Expanded details section
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: _buildExpandedDetails(leave, isPending, isProcessingThis),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatusBadge(String status, Color color) {
    IconData icon;
    switch (status) {
      case "Approved":
        icon = Icons.check_circle;
        break;
      case "Rejected":
        icon = Icons.cancel;
        break;
      case "Pending":
        icon = Icons.schedule;
        break;
      default:
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandedDetails(Map<String, dynamic> leave, bool isPending, bool isProcessingThis) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildDetailRow(
                  "Type",
                  leave["leave_type"] ?? "Regular Leave",
                  Icons.category,
                ),
                
                const SizedBox(height: 8),
                
                _buildDetailRow(
                  "Duration",
                  "${_formatDate(leave["leave_date"] ?? "Unknown")}${leave["end_date"] != null ? " to ${_formatDate(leave["end_date"])}" : ""}",
                  Icons.date_range,
                ),
                
                const SizedBox(height: 8),
                
                _buildDetailRow(
                  "Status",
                  "${leave["status"] ?? "Unknown"}${leave["status_date"] != null ? " on ${_formatDate(leave["status_date"])}" : ""}",
                  Icons.info,
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Reason for Leave",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        leave["reason"] ?? "No reason provided",
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons for pending requests
          if (isPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: isProcessingThis
                        ? null
                        : () => _confirmUpdateStatus(
                              leave["employee_id"],
                              leave["name"],
                              "Rejected",
                            ),
                    icon: isProcessingThis
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red.shade300,
                            ),
                          )
                        : const Icon(Icons.cancel, size: 16),
                    label: const Text("Reject"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: isProcessingThis
                        ? null
                        : () => _confirmUpdateStatus(
                              leave["employee_id"],
                              leave["name"],
                              "Approved",
                            ),
                    icon: isProcessingThis
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 16),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.green.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  /// Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}