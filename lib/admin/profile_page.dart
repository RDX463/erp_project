import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // CircleAvatar with color instead of an image
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue, // Replace with your desired color
              child: Text(
                'A', // You can put the first letter of the name or any text here
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white, // Text color
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Name: Admin User', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Email: admin@example.com', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action to edit profile
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
