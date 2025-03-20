import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NoticesEventsPage(),
  ));
}

class NoticesEventsPage extends StatelessWidget {
  const NoticesEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices & Events", style: TextStyle(fontSize: 22)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade500, Colors.purpleAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            NoticeCard(
              title: "Department Notice",
              icon: Icons.apartment,
              color: Colors.blue,
              details: "📢 The Computer Science department is organizing a workshop on AI & ML on March 25.",
            ),
            NoticeCard(
              title: "Exam Notice",
              icon: Icons.assignment,
              color: Colors.red,
              details: "📝 Semester exams for all courses will commence from April 10. Check your exam schedule on the portal.",
            ),
            NoticeCard(
              title: "Scholarship Updates",
              icon: Icons.school,
              color: Colors.green,
              details: "🎓 The Government Merit Scholarship application is now open till April 5. Apply through the scholarship portal.",
            ),
            NoticeCard(
              title: "College Events",
              icon: Icons.event,
              color: Colors.orange,
              details: "🎶 Annual Cultural Fest 'College Fiesta' is on March 30. Register for competitions now!",
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String details;

  const NoticeCard({super.key, required this.title, required this.icon, required this.color, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 30, color: color),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(details, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
      ),
    );
  }
}
