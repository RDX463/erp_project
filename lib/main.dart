import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
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
        primaryColor: Color(0xFF00796B), // Dark teal
        secondaryHeaderColor: Color(0xFFFF6F61), // Coral
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF00796B), // Primary color (Teal)
          secondary: Color(0xFFFF6F61), // Secondary color (Coral)
          background: Color(0xFFE0F7FA), // Light teal background
          surface: Color(0xFFFFFFFF), // Surface color
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF00796B), // Button color (Teal)
          textTheme: ButtonTextTheme.primary,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
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
        preferredSize: Size.fromHeight(56), // Height for the AppBar
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor, // Dark teal
          elevation: 4,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0), // Adjusted left padding
                child: Row(
                  children: [
                    Container(
                      color: Colors.black, // Logo background color
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 70, // Logo height
                        fit: BoxFit.contain, // Adjusted fit property
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 70,
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
                    SizedBox(width: 10), // Space between logo and DTE code
                    Text(
                      "DTE Code: EN6732",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // DTE code color
                      ),
                    ),
                  ],
                ),
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
          _buildSocialMediaLinks(), // Add social media links here
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
                style: Theme.of(context).textTheme.displayLarge,
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
          child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, color: Theme.of(context).primaryColor, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event,
                    style: Theme.of(context).textTheme.bodyLarge,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminLoginPage()),
            );
            break;
          // Handle other logins
        }
      },
    );
  }

  // Build social media links
  Widget _buildSocialMediaLinks() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.facebook, color: Theme.of(context).primaryColor),
                onPressed: () => _launchURL('https://www.facebook.com/'),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.twitter, color: Theme.of(context).primaryColor),
                onPressed: () => _launchURL('https://twitter.com/'),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.linkedin, color: Theme.of(context).primaryColor),
                onPressed: () => _launchURL('https://www.linkedin.com/'),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.youtube, color: Theme.of(context).primaryColor),
                onPressed: () => _launchURL('https://www.youtube.com/'),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}