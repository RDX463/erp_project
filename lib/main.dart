import 'package:flutter/material.dart';
import 'admin/admin_login.dart';

void main() {
  runApp(CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Open Sans',
        primaryColor: Color(0xFF004AAD),
        secondaryHeaderColor: Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFFFD700),
          background: Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          primary: Color(0xFF004AAD),
          surface: Color(0xFFFFFFFF),
        ),
      ),
      home: HomePage(),
      routes: {
        '/admin_login': (context) => AdminLoginPage(),
        // Add other routes here
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> events = [
    "🔔 Campus Placement Drive on March 30th!",
    "📢 Semester Exams Begin from April 15th.",
    "🎉 College Tech Fest Coming Soon!",
    "🏆 Sports Week from April 10-15!",
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> displayedEvents = [];

  @override
  void initState() {
    super.initState();
    _addEventsWithAnimation();
  }

  void _addEventsWithAnimation() async {
    for (int i = 0; i < events.length; i++) {
      await Future.delayed(Duration(milliseconds: 400));
      if (mounted) {
        displayedEvents.add(events[i]);
        _listKey.currentState?.insertItem(displayedEvents.length - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          backgroundColor: Colors.black, // Changed to black
          elevation: 4,
          titleSpacing: 0,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 15.0),
                child: Container(
                  color: Colors.black, // Logo background color
                  child: Image.asset(
                    'assets/logo.jpeg',
                    height: 65,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 60,
                        width: 150,
                        color: Colors.red.shade100,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "Error\nLoading Logo\nCheck Console",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ajeenkya DY Patil School Of Engineering",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Lohegaon, Pune - 412105",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  children: [
                    _navButton(context, "Home", () {}),
                    _navButton(context, "About Us", () {}),
                    _navButton(context, "Placements", () {}),
                    _navButton(context, "Tie-ups", () {}),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: _loginMenu(context),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildEventSection(),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
              child: Text(
                "📢 Latest Notices & Events",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.9)),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: displayedEvents.length,
                itemBuilder: (context, index, animation) {
                  return _buildAnimatedItem(displayedEvents[index], animation);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(String event, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: Offset(0.5, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic))),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, color: Theme.of(context).primaryColor, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _loginMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Login Options",
      offset: Offset(0, 45),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.login, color: Theme.of(context).primaryColor, size: 18),
            SizedBox(width: 5),
            Text("Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: "StudentLogin", child: Text("Student Login")),
        PopupMenuItem(value: "FacultyLogin", child: Text("Faculty Login")),
        PopupMenuItem(value: "AdminLogin", child: Text("Admin Login")),
      ],
      onSelected: (value) {
        switch (value) {
          case "AdminLogin":
            Navigator.pushNamed(context, '/admin_login');
            break;
          // Handle other logins
        }
      },
    );
  }
}

// Sample Admin Login Page
class AdminLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Login"),
      ),
      body: Center(
        child: Text("Admin Login Page"),
      ),
    );
  }
}