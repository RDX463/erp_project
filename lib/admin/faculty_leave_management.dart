import 'package:flutter/material.dart';

class FacultyLeaveManagementPage extends StatelessWidget {
  final List<Map<String, String>> leaveRequests = [
    {"name": "Dr. Rajesh Sharma", "id": "FAC001", "date": "2025-03-21", "reason": "Medical Leave", "status": "Approved"},
    {"name": "Prof. Priya Verma", "id": "FAC002", "date": "2025-03-23", "reason": "Personal Work", "status": "Pending"},
    {"name": "Dr. Kiran Desai", "id": "FAC003", "date": "2025-03-25", "reason": "Vacation", "status": "Rejected"},
    {"name": "Prof. Amit Khanna", "id": "FAC004", "date": "2025-03-27", "reason": "Conference", "status": "Approved"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🗓️ Faculty Leave Management")),
      body: ListView.builder(
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(leaveRequests[index]["name"]!),
              subtitle: Text("ID: ${leaveRequests[index]["id"]} | Date: ${leaveRequests[index]["date"]}"),
              trailing: Chip(
                label: Text(leaveRequests[index]["status"]!),
                backgroundColor: _getStatusColor(leaveRequests[index]["status"]!),
              ),
            ),
          );
        },
      ),
    );
  }

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
