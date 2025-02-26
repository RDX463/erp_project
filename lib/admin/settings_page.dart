import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                // Navigate to change password page
              },
            ),
            ListTile(
              title: Text('Update Profile'),
              onTap: () {
                // Navigate to profile update page
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                // Log out action
              },
            ),
          ],
        ),
      ),
    );
  }
}
