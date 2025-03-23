import 'package:flutter/material.dart';

class FacultyIncomeTaxPage extends StatelessWidget {
  final List<Map<String, String>> taxList = [
    {"name": "Dr. Rajesh Sharma", "tax": "₹12,000"},
    {"name": "Prof. Priya Verma", "tax": "₹9,500"},
    {"name": "Dr. Kiran Desai", "tax": "₹11,000"},
    {"name": "Prof. Amit Khanna", "tax": "₹8,500"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🧾 Faculty Income Tax")),
      body: ListView.builder(
        itemCount: taxList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(taxList[index]["name"]!),
              subtitle: Text("Income Tax: ${taxList[index]["tax"]}"),
            ),
          );
        },
      ),
    );
  }
}
