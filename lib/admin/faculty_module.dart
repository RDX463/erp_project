import 'package:flutter/material.dart';
import 'faculty_details.dart';
import 'faculty_salary.dart';
import 'faculty_income_tax.dart';
import 'faculty_or_pr_allotment.dart';
import 'faculty_leave_management.dart'; 
import 'faculty_add.dart';

class FacultyModule extends StatefulWidget {
  @override
  _FacultyModuleState createState() => _FacultyModuleState();
}

class _FacultyModuleState extends State<FacultyModule> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _hoveredIndex;
  bool _isGridView = true; // Default to card/grid style
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  final List<Map<String, dynamic>> modules = [
    {
      "title": "Add Faculty",
      "subtitle": "Register new faculty members",
      "icon": Icons.person_add_alt_1_rounded,
      "color": Colors.indigo,
      "page": FacultyAddPage(),
    },
    {
      "title": "Faculty Details",
      "subtitle": "View complete faculty information",
      "icon": Icons.assignment_ind_rounded,
      "color": Colors.blue,
      "page": FacultyDetailsPage(),
    },
    {
      "title": "Salary Management",
      "subtitle": "Manage faculty compensation",
      "icon": Icons.attach_money_rounded,
      "color": Colors.green,
      "page": FacultySalaryPage(),
    },
    {
      "title": "Income Tax",
      "subtitle": "Calculate & manage tax deductions",
      "icon": Icons.receipt_long_rounded,
      "color": Colors.red,
      "page": FacultyIncomeTaxPage(),
    },
    {
      "title": "OR-PR Allotment",
      "subtitle": "External examination assignments",
      "icon": Icons.assignment_turned_in_rounded,
      "color": Colors.orange,
      "page": FacultyORPRAllotmentPage(),
    },
    {
      "title": "Leave Management",
      "subtitle": "Track & approve faculty leave",
      "icon": Icons.event_available_rounded,
      "color": Colors.purple,
      "page": FacultyLeaveManagementPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Add scroll listener to detect when to show back arrow
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 10;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Faculty Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? "List View" : "Grid View",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            // Default to grid view (card style)
            _isGridView ? _buildModuleGrid() : _buildModuleList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.people_alt_rounded,
                size: 24,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Faculty Module",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Text(
                    "Manage and organize faculty resources",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Select a module to manage faculty-related functions",
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Available Modules (${modules.length})",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    icon: Icons.grid_view_rounded,
                    isSelected: _isGridView, // Default to grid view selected
                    onTap: _isGridView ? null : _toggleViewMode,
                  ),
                  _buildToggleButton(
                    icon: Icons.view_list_rounded,
                    isSelected: !_isGridView,
                    onTap: _isGridView ? _toggleViewMode : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildModuleGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(
          context,
          module["title"],
          module["subtitle"],
          module["icon"],
          module["color"],
          module["page"],
          index,
        );
      },
    );
  }

  Widget _buildModuleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleListItem(
          context,
          module["title"],
          module["subtitle"],
          module["icon"],
          module["color"],
          module["page"],
          index,
        );
      },
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget page,
    int index,
  ) {
    final bool isHovered = _hoveredIndex == index;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double scale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 * index,
                0.1 * index + 0.5,
                curve: Curves.easeOutBack,
              ),
            ))
            .value;
            
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? color.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isHovered ? 12 : 5,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isHovered ? color.withOpacity(0.5) : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isHovered ? color : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Open",
                        style: TextStyle(
                          color: isHovered ? Colors.white : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: isHovered ? Colors.white : Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleListItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget page,
    int index,
  ) {
    final bool isHovered = _hoveredIndex == index;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double slide = Tween<double>(begin: 100.0, end: 0.0)
            .animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 * index,
                0.1 * index + 0.5,
                curve: Curves.easeOutCubic,
              ),
            ))
            .value;
            
        return Transform.translate(
          offset: Offset(slide, 0),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? color.withOpacity(0.2)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: isHovered ? 10 : 3,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isHovered ? color.withOpacity(0.5) : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isHovered ? color : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: isHovered ? Colors.white : Colors.grey.shade700,
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
}