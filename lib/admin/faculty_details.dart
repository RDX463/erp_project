import 'package:flutter/material.dart';

class FacultyDetailsPage extends StatelessWidget {
  final List<Map<String, String>> facultyList = [
    {"name": "Dr. Rajesh Sharma", "id": "FAC001", "department": "Computer Engineering"},
    {"name": "Prof. Priya Verma", "id": "FAC002", "department": "AIDS"},
    {"name": "Dr. Kiran Desai", "id": "FAC003", "department": "Mechanical Engineering"},
    {"name": "Prof. Amit Khanna", "id": "FAC004", "department": "ENTC"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📋 Faculty Details")),
      body: ListView.builder(
        itemCount: facultyList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(facultyList[index]["name"]!),
              subtitle: Text("ID: ${facultyList[index]["id"]} | ${facultyList[index]["department"]}"),
            ),
          );
        },
      ),
    );
  }
}
