import 'package:flutter/material.dart';

void main() {
  runApp(CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          displayedEvents.add(events[i]);
          _listKey.currentState?.insertItem(displayedEvents.length - 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Ajeenkya DY Patil School of Engineering",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tabs
          Container(
            color: Colors.blue[100],
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navButton(context, "Home", icon: Icons.home),
                _navButton(context, "About Us", icon: Icons.info),
                
                // 🛠️ FIXED LOGIN MENU
                PopupMenuButton<String>(
                  child: Row(
                    children: [
                      Icon(Icons.login, color: Colors.black),
                      SizedBox(width: 5),
                      Text("Login", style: TextStyle(fontSize: 18, color: Colors.black)),
                      Icon(Icons.arrow_drop_down, color: Colors.black),
                    ],
                  ),
                  onSelected: (value) {
                    print("Selected: $value");
                    // You can navigate to different login pages here
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Student", child: Text("Student Login")),
                    PopupMenuItem(value: "Faculty", child: Text("Faculty Login")),
                    PopupMenuItem(value: "Admin", child: Text("Admin Login")),
                  ],
                ),

                _navButton(context, "Placements", icon: Icons.work),
                _navButton(context, "Tie-up", icon: Icons.link),
              ],
            ),
          ),
          // Notices & Events Section with Animation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📢 Latest Notices & Events",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Flexible(
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(String event, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: Offset(1, 0), // Start from the right side
          end: Offset(0, 0),   // Move to normal position
        ).chain(CurveTween(curve: Curves.easeOut))),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.blueAccent,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.event, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String text, {IconData? icon}) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.1)),
        ),
        onPressed: () {},
        child: Row(
          children: [
            icon != null ? Icon(icon, color: Colors.black) : SizedBox(),
            icon != null ? SizedBox(width: 5) : SizedBox(),
            Text(text, style: TextStyle(fontSize: 18, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
