import 'package:flutter/material.dart';

class FacultyLeaveManagementPage extends StatefulWidget {
  const FacultyLeaveManagementPage({super.key});

  @override
  _FacultyLeaveManagementPageState createState() => _FacultyLeaveManagementPageState();
}

class _FacultyLeaveManagementPageState extends State<FacultyLeaveManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _leaveRequests = [
    {
      "name": "Dr. Rajesh Sharma",
      "id": "FAC001",
      "date": "2025-03-21",
      "reason": "Medical Leave",
      "status": "Approved"
    },
    {
      "name": "Prof. Priya Verma",
      "id": "FAC002",
      "date": "2025-03-23",
      "reason": "Personal Work",
      "status": "Pending"
    },
    {
      "name": "Dr. Kiran Desai",
      "id": "FAC003",
      "date": "2025-03-25",
      "reason": "Vacation",
      "status": "Rejected"
    },
    {
      "name": "Prof. Amit Khanna",
      "id": "FAC004",
      "date": "2025-03-27",
      "reason": "Conference",
      "status": "Approved"
    },
  ];
  List<Map<String, String>> _filteredLeaveRequests = [];

  @override
  void initState() {
    super.initState();
    _filteredLeaveRequests = _leaveRequests;
    _searchController.addListener(_filterLeaveRequests);
  }

  void _filterLeaveRequests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLeaveRequests = _leaveRequests.where((request) {
        final name = request["name"]!.toLowerCase();
        final id = request["id"]!.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  void _updateLeaveStatus(int index, String newStatus) {
    setState(() {
      _leaveRequests[index]["status"] = newStatus;
      _filteredLeaveRequests = _leaveRequests.where((request) {
        final name = request["name"]!.toLowerCase();
        final id = request["id"]!.toLowerCase();
        final query = _searchController.text.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request ${newStatus.toLowerCase()}!'),
        backgroundColor: _getStatusColor(newStatus),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green.shade700;
      case "Pending":
        return Colors.orange.shade700;
      case "Rejected":
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showLeaveDetails(BuildContext context, Map<String, String> request, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          request["name"]!,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee ID: ${request["id"]}',
              style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${request["date"]}',
              style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${request["reason"]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${request["status"]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(request["status"]!),
                    fontWeight: FontWeight.w600,
                  ) ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          if (request["status"] == "Pending") ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateLeaveStatus(index, "Approved");
              },
              child: Text(
                'Approve',
                style: TextStyle(color: Colors.green.shade700),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateLeaveStatus(index, "Rejected");
              },
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Faculty Leave Management',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or ID',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Leave Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                        ) ?? const TextStyle(
                          fontSize: 22,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Leave Requests List
          Expanded(
            child: _filteredLeaveRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No leave requests found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ) ?? TextStyle(color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredLeaveRequests.length,
                    itemBuilder: (context, index) {
                      final request = _filteredLeaveRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        child: Semantics(
                          label: 'Leave request for ${request["name"]}',
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                request["name"]!.isNotEmpty ? request["name"]![0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(
                              request["name"]!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                  'ID: ${request["id"]}',
                                  style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Date: ${request["date"]}',
                                  style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Reason: ${request["reason"]}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                request["status"]!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: _getStatusColor(request["status"]!),
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onTap: () => _showLeaveDetails(context, request, index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}