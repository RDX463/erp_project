import 'package:flutter/material.dart';
import 'student_admission.dart';
import 'fees_payment.dart';
import 'scholarship_eligibility.dart';
import 'student_promotion.dart';
import 'student_profile.dart';
import 'student_documents.dart';
import 'package:flutter/services.dart';

class StudentModule extends StatefulWidget {
  const StudentModule({super.key});

  @override
  State<StudentModule> createState() => _StudentModuleState();
}

class _StudentModuleState extends State<StudentModule> {
  final List<bool> _isExpanded = List.generate(6, (_) => false);
  bool _isGridView = false;
  bool _isDarkMode = false;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    
    // Simplified startup animation
    if (mounted) {
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isExpanded[0] = true;
          });
          
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isExpanded[0] = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Student Admission",
        "icon": Icons.person_add,
        "page": const StudentAdmissionPage(),
        "color": Colors.blue,
        "description": "Register new students and manage admissions",
        "badge": "New",
        "usage": 15,
      },
      {
        "title": "Fees Payment",
        "icon": Icons.payment,
        "page": const FeesPaymentPage(),
        "color": Colors.orange,
        "description": "Process fee payments and view payment history",
        "badge": "",
        "usage": 30,
      },
      {
        "title": "Scholarship Eligibility",
        "icon": Icons.school,
        "page": const ScholarshipEligibilityPage(),
        "color": Colors.purple,
        "description": "Check and manage scholarship applications",
        "badge": "",
        "usage": 8,
      },
      {
        "title": "Student Promotion",
        "icon": Icons.arrow_upward,
        "page": const StudentPromotionPage(),
        "color": Colors.red,
        "description": "Process class promotions and academic advancements",
        "badge": "",
        "usage": 5,
      },
      {
        "title": "Student Profile",
        "icon": Icons.person,
        "page": const StudentProfilePage(),
        "color": Colors.teal,
        "description": "View and edit student personal information",
        "badge": "Popular",
        "usage": 25,
      },
      {
        "title": "Student Documents",
        "icon": Icons.folder,
        "page": StudentDocuments(),
        "color": Colors.amber,
        "description": "Upload and manage student documents",
        "badge": "",
        "usage": 18,
      },
    ];

    // Sort items by usage for quick actions
    final quickActionItems = List<Map<String, dynamic>>.from(menuItems)
      ..sort((a, b) => b["usage"].compareTo(a["usage"]));

    return Theme(
      data: _isDarkMode 
          ? ThemeData.dark(useMaterial3: true).copyWith(
              primaryColor: Colors.indigo,
              colorScheme: ColorScheme.dark(primary: Colors.indigo.shade300),
            )
          : ThemeData.light(useMaterial3: true).copyWith(
              primaryColor: Colors.indigo,
              colorScheme: ColorScheme.light(primary: Colors.indigo),
            ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.school, size: 24),
              SizedBox(width: 10),
              Text(
                "Student Management", 
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ],
          ),
          backgroundColor: _isDarkMode ? Colors.grey.shade900 : Theme.of(context).primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
                HapticFeedback.lightImpact();
              },
              tooltip: _isDarkMode ? "Light Mode" : "Dark Mode",
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
                HapticFeedback.selectionClick();
              },
              tooltip: _isGridView ? "Switch to List View" : "Switch to Grid View",
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context, 
                  delegate: StudentModuleSearch(menuItems, _isDarkMode)
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isDarkMode 
                  ? [
                      Colors.grey.shade900,
                      Colors.grey.shade800,
                    ] 
                  : [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            children: [
              _buildTopStats(),
              Expanded(
                child: _isGridView 
                  ? _buildGridView(menuItems)
                  : _buildListView(menuItems),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => buildQuickActions(context, quickActionItems),
            );
          },
          label: Text("Quick Access"),
          icon: const Icon(Icons.dashboard_customize),
          tooltip: "Quick Actions",
          backgroundColor: _isDarkMode ? Colors.indigo.shade700 : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
  
  Widget _buildTopStats() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Students", "1,253", Icons.people, Colors.blue),
          _buildStatItem("New Admissions", "+28", Icons.person_add, Colors.green),
          _buildStatItem("Fee Due", "45", Icons.warning_amber, Colors.orange),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(_isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> menuItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return buildExpandableCard(
          context, 
          menuItems[index], 
          index
        );
      },
    );
  }
  
  Widget _buildGridView(List<Map<String, dynamic>> menuItems) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return buildGridItem(context, menuItems[index], index);
      },
    );
  }

  Widget buildExpandableCard(BuildContext context, Map<String, dynamic> item, int index) {
    final bool isExpanded = _isExpanded[index];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(
        vertical: 8, 
        horizontal: isExpanded ? 5 : 10
      ),
      child: Card(
        elevation: isExpanded ? 8 : 3,
        shadowColor: item["color"].withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item["page"]),
                );
              },
              onLongPress: () {
                setState(() {
                  // Close any other expanded cards first
                  for (int i = 0; i < _isExpanded.length; i++) {
                    if (i != index) _isExpanded[i] = false;
                  }
                  _isExpanded[index] = !_isExpanded[index];
                });
                HapticFeedback.heavyImpact();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item["color"].withOpacity(_isDarkMode ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item["icon"],
                        color: item["color"],
                      ),
                    ),
                    title: Text(
                      item["title"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: isExpanded 
                      ? Text(item["description"])
                      : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item["badge"].isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item["color"].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item["badge"],
                              style: TextStyle(
                                fontSize: 10,
                                color: item["color"],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _isDarkMode ? Colors.grey : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: SizedBox(height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ActionButton(
                            icon: Icons.edit,
                            label: "Edit",
                            onTap: () {
                              // Handle edit action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Edit ${item["title"]}"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          ActionButton(
                            icon: Icons.share,
                            label: "Share",
                            onTap: () {
                              // Handle share action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Share ${item["title"]}"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          ActionButton(
                            icon: Icons.info_outline,
                            label: "Info",
                            onTap: () {
                              // Handle info action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Info about ${item["title"]}"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridItem(BuildContext context, Map<String, dynamic> item, int index) {
    return Card(
      elevation: 4,
      shadowColor: item["color"].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => item["page"]),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item["color"].withOpacity(_isDarkMode ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item["icon"],
                      color: item["color"],
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    item["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    item["description"],
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item["badge"].isNotEmpty) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item["color"].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item["badge"],
                          style: TextStyle(
                            fontSize: 10,
                            color: item["color"],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuickActions(BuildContext context, List<Map<String, dynamic>> items) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: items.length > 3 ? 3 : items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item["color"].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item["icon"], color: item["color"]),
                      ),
                      title: Text(item["title"]),
                      subtitle: Text("Used ${item["usage"]} times recently"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item["page"]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Simple arrow indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 30,
                      color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    Text(
                      "Swipe up for more",
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class StudentModuleSearch extends SearchDelegate {
  final List<Map<String, dynamic>> items;
  final bool isDarkMode;
  
  StudentModuleSearch(this.items, this.isDarkMode);
  
  @override
  ThemeData appBarTheme(BuildContext context) {
    return isDarkMode
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items.where((item) {
      return item["title"].toLowerCase().contains(query.toLowerCase()) ||
             item["description"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Icon(item["icon"], color: item["color"]),
          title: Text(item["title"]),
          subtitle: Text(item["description"]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item["page"]),
            );
          },
        );
      },
    );
  }
}