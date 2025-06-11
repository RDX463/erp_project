import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'admin/admin_login.dart';
import 'admin/student_module.dart';
import 'admin/student_admission.dart';
import 'admin/fees_payment.dart';
import 'admin/scholarship_eligibility.dart';
import 'admin/student_promotion.dart';
import 'admin/student_documents.dart';
import 'faculty/faculty_login.dart';
import 'student/student_login.dart';
import 'student/student_dashboard.dart';
import 'student/student_profile.dart';
import 'student/document_upload.dart';
import 'screens/feedback_screen.dart';

void main() {
  runApp(const CollegeERPApp());
}

class CollegeERPApp extends StatelessWidget {
  const CollegeERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Open Sans',
        primaryColor: const Color(0xFF00796B),
        secondaryHeaderColor: const Color(0xFFFF6F61),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFFFF6F61),
          background: const Color(0xFFE0F7FA),
          surface: const Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF00796B),
          textTheme: ButtonTextTheme.primary,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
      ),
      home: const HomePage(),
      routes: {
        '/admin_login': (context) => const AdminLoginPage(),
        '/student_module': (context) => const StudentModule(),
        '/student_admission': (context) => const StudentAdmissionPage(),
        '/fees_payment': (context) => const FeesPaymentPage(),
        '/scholarship_eligibility': (context) => const ScholarshipEligibilityPage(),
        '/student_promotion': (context) => const StudentPromotionPage(),
        '/student_documents': (context) => const StudentDocuments(),
        '/faculty_login': (context) => const FacultyLoginPage(),
        '/student_login': (context) => const StudentLoginPage(),
        '/student_dashboard': (context) => StudentDashboard(
              student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
        '/student_profile': (context) => StudentProfile(
              student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
        '/document_upload': (context) => DocumentUpload(
              student: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
            ),
        '/feedback': (context) => const FeedbackScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      await Future.delayed(const Duration(milliseconds: 300));
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
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).secondaryHeaderColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 8,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 120,
                            color: Colors.red.shade100,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              "Error\nLoading Logo",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade900, fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "DTE Code: EN6732",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.event, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Latest Notices & Events",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: displayedEvents.length,
            itemBuilder: (context, index, animation) {
              return _buildAnimatedItem(displayedEvents[index], animation);
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/feedback');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic))),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign, color: Theme.of(context).primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.photo, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Photo Gallery",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        galleryImages[index],
                        fit: BoxFit.cover, // Changed to cover for zoom effect
                        alignment: Alignment.center, // Center the image for zoom
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              itemCount: galleryImages.length,
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  activeColor: Theme.of(context).primaryColor,
                  color: Colors.white,
                ),
              ),
              control: SwiperControl(
                color: Theme.of(context).primaryColor,
              ),
              autoplay: true,
              viewportFraction: 0.9, // Increased to make images appear larger
              scale: 0.95, // Adjusted to reduce overlap and enhance zoom effect
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.school, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Engineering Departments",
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _departmentCard("Computer Science Engineering", Icons.computer, () {}),
              _departmentCard("Mechanical Engineering", Icons.build, () {}),
              _departmentCard("Civil Engineering", Icons.apartment, () {}),
              _departmentCard("Electrical Engineering", Icons.electrical_services, () {}),
              _departmentCard("Electronics and Communication Engineering", Icons.radio, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _departmentCard(String departmentName, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  departmentName,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _loginMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Login Options",
      offset: const Offset(0, 50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.login, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              "Login",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor, size: 24),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "StudentLogin",
          child: Row(
            children: [
              Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text("Student Login"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "FacultyLogin",
          child: Row(
            children: [
              Icon(Icons.school, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text("Faculty Login"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "AdminLogin",
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text("Admin Login"),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case "AdminLogin":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginPage()),
            );
            break;
          case "FacultyLogin":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacultyLoginPage()),
            );
            break;
          case "StudentLogin":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentLoginPage()),
            );
            break;
        }
      },
    );
  }

  Widget _buildSocialMediaLinks() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            "Connect With Us",
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialButton(
                context,
                FaIcon(FontAwesomeIcons.facebook, color: Theme.of(context).primaryColor),
                () => _launchURL('https://www.facebook.com/'),
              ),
              _socialButton(
                context,
                FaIcon(FontAwesomeIcons.twitter, color: Theme.of(context).primaryColor),
                () => _launchURL('https://twitter.com/'),
              ),
              _socialButton(
                context,
                FaIcon(FontAwesomeIcons.linkedin, color: Theme.of(context).primaryColor),
                () => _launchURL('https://www.linkedin.com/'),
              ),
              _socialButton(
                context,
                FaIcon(FontAwesomeIcons.youtube, color: Theme.of(context).primaryColor),
                () => _launchURL('https://www.youtube.com/'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton(BuildContext context, FaIcon icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: icon,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Text(
            "College ERP System",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "© 2025 College Name. All rights reserved.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Terms of Service",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}