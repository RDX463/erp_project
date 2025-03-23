import 'package:flutter/material.dart';

class FacultyORPRAllotmentPage extends StatelessWidget {
  final List<Map<String, String>> allotmentList = [
    {"name": "Dr. Rajesh Sharma", "subject": "Operating Systems", "college": "MIT Pune"},
    {"name": "Prof. Priya Verma", "subject": "Data Science", "college": "VIT Mumbai"},
    {"name": "Dr. Kiran Desai", "subject": "Thermodynamics", "college": "COEP Pune"},
    {"name": "Prof. Amit Khanna", "subject": "VLSI Design", "college": "SPPU Pune"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📜 OR-PR External Allotment")),
      body: ListView.builder(
        itemCount: allotmentList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(allotmentList[index]["name"]!),
              subtitle: Text("Subject: ${allotmentList[index]["subject"]} | College: ${allotmentList[index]["college"]}"),
            ),
          );
        },
      ),
    );
  }
}
