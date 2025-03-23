import 'package:flutter/material.dart';

class FacultySalaryPage extends StatelessWidget {
  final List<Map<String, String>> salaryList = [
    {"name": "Dr. Rajesh Sharma", "salary": "₹1,20,000", "bonus": "₹10,000"},
    {"name": "Prof. Priya Verma", "salary": "₹95,000", "bonus": "₹5,000"},
    {"name": "Dr. Kiran Desai", "salary": "₹1,10,000", "bonus": "₹8,000"},
    {"name": "Prof. Amit Khanna", "salary": "₹85,000", "bonus": "₹4,000"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("💰 Faculty Salary")),
      body: ListView.builder(
        itemCount: salaryList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(salaryList[index]["name"]!),
              subtitle: Text("Salary: ${salaryList[index]["salary"]} | Bonus: ${salaryList[index]["bonus"]}"),
            ),
          );
        },
      ),
    );
  }
}
