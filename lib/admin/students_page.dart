import 'package:flutter/material.dart';

class StudentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Student 1'),
              subtitle: Text('ID: S001'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Navigate to student edit page
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Student 2'),
              subtitle: Text('ID: S002'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Navigate to student edit page
                },
              ),
            ),
            // Add more students here
          ],
        ),
      ),
    );
  }
}
