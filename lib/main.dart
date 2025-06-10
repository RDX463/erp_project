import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'admin/admin_login.dart';
import 'faculty/faculty_login.dart';
import 'student/student_login.dart';
import 'student/student_dashboard.dart';
import 'student/student_profile.dart';

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
        primaryColor: Color(0xFF00796B),
        secondaryHeaderColor: Color(0xFFFF6F61),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF00796B),
          secondary: Color(0xFFFF6F61),
          background: Color(0xFFE0F7FA),
          surface: Color(0xFFFFFFFF),
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
          buttonColor: Color(0xFF00796B),
          textTheme: ButtonTextTheme.primary,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      home: HomePage(),
      routes: {
        '/admin_login': (context) => AdminLoginPage(),
        '/faculty_login': (context) => FacultyLoginPage(),
        '/student_login': (context) => const StudentLoginPage(),
        '/student_dashboard': (context) => StudentDashboard(
              student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
        '/student_profile': (context) => StudentProfile(
              student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => HomePage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List events = [
    "🔔 Campus Placement Drive on March 30th!",
    "📢 Semester Exams Begin from April 15th.",
    "🎉 College Tech Fest Coming Soon!",
    "🏆 Sports Week from April 10-15!",
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> displayedEvents = [];

  final List<String> galleryImages = [
    'assets/image1.jpeg',
    'assets/image2.jpeg',
    'assets/image3.jpeg',
    'assets/image4.jpeg',
    'assets/image5.jpeg',
  ];

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
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 4,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Container(
                      color: Colors.black,
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 70,
                        fit: BoxFit.contain,
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
                    SizedBox(width: 10),
                    Text(
                      "DTE Code: EN6732",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildEventSection(),
            _buildPhotoGallery(),
            _buildDepartmentsSection(),
            _buildSocialMediaLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection() {
    return Padding(
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
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            initialItemCount: displayedEvents.length,
            itemBuilder: (context, index, animation) {
              return _buildAnimatedItem(displayedEvents[index], animation);
            },
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

  Widget _buildPhotoGallery() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📸 Photo Gallery",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    galleryImages[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
              itemCount: galleryImages.length,
              pagination: SwiperPagination(),
              control: SwiperControl(),
              autoplay: true,
              viewportFraction: 0.25,
              scale: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🏫 Engineering Departments",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(height: 8),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _departmentCard("Computer Science Engineering", Icons.computer),
              _departmentCard("Mechanical Engineering", Icons.build),
              _departmentCard("Civil Engineering", Icons.apartment),
              _departmentCard("Electrical Engineering", Icons.electrical_services),
              _departmentCard("Electronics and Communication Engineering", Icons.radio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _departmentCard(String departmentName, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            SizedBox(width: 12),
            Text(
              departmentName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
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
          case "FacultyLogin":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FacultyLoginPage()),
            );
            break;
          case "StudentLogin":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentLoginPage()),
            );
            break;
        }
      },
    );
  }

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

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}