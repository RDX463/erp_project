import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudentDocuments extends StatefulWidget {
  @override
  _StudentDocumentsState createState() => _StudentDocumentsState();
}

class _StudentDocumentsState extends State<StudentDocuments> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  String selectedDepartment = "All";
  bool isDarkMode = false;
  bool isLoading = false;
  bool isGridView = false;
  String sortBy = "Name";
  bool isAscending = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  List<dynamic> allStudents = [];
  List<dynamic> filteredStudents = [];

  // Expanded list of departments for better filtering
  final List<String> departments = [
    "All", "COM", "AIDS", "MECH", "ENTC", "CIVIL", "IT", "EE", "CHEM", "BIO"
  ];
  
  // Document status indicators with colors
  final Map<String, Color> statusColors = {
    "Verified": Colors.green,
    "Pending": Colors.orange,
    "Rejected": Colors.red,
    "Missing": Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchStudents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/get_students"));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          allStudents = data["students"];
          _filterStudents();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar("Failed to load students");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Network error: $e");
    }
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = allStudents.where((student) {
        var studentID = student["student_id"].toString().toLowerCase();
        var name = student["name"].toString().toLowerCase();
        var department = student["department"].toString();
        var searchText = searchController.text.toLowerCase();

        bool matchesSearch = studentID.contains(searchText) || 
                            name.contains(searchText);
        bool matchesFilter = selectedDepartment == "All" || 
                            department == selectedDepartment;

        return matchesSearch && matchesFilter;
      }).toList();
      
      // Sort the filtered list
      _sortStudents();
    });
  }

  void _sortStudents() {
    filteredStudents.sort((a, b) {
      int result;
      
      switch (sortBy) {
        case "Name":
          result = a["name"].toString().compareTo(b["name"].toString());
          break;
        case "ID":
          result = a["student_id"].toString().compareTo(b["student_id"].toString());
          break;
        case "Department":
          result = a["department"].toString().compareTo(b["department"].toString());
          break;
        case "Documents":
          int aCount = (a["documents"] ?? []).length;
          int bCount = (b["documents"] ?? []).length;
          result = aCount.compareTo(bCount);
          break;
        default:
          result = 0;
      }
      
      return isAscending ? result : -result;
    });
  }

  Future<void> sendDocumentQuery(String studentID, String queryType, String comment) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/send_document_query"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": studentID, 
          "query_type": queryType, 
          "comment": comment,
          "timestamp": DateTime.now().toIso8601String()
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar("Query sent successfully!");
      } else {
        _showErrorSnackBar("Failed to send query");
      }
    } catch (e) {
      _showErrorSnackBar("Network error: $e");
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  String _getDocumentStatus(dynamic student) {
    List<dynamic> documents = student["documents"] ?? [];
    if (documents.isEmpty) return "Missing";
    
    // For demonstration, randomly assign statuses
    // In a real app, this would come from your backend
    var statuses = ["Verified", "Pending", "Rejected"];
    var statusIndex = student["student_id"].hashCode % 3;
    return statuses[statusIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _fetchStudents,
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          color: Colors.blue,
          displacement: 40,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchAndFilterSection(),
                SizedBox(height: 8),
                _buildSortingSection(),
                SizedBox(height: 8),
                Expanded(
                  child: isLoading
                      ? _buildLoadingShimmer()
                      : filteredStudents.isEmpty
                          ? _buildEmptyState()
                          : isGridView
                              ? _buildGridView()
                              : _buildListView(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddDocumentRequestDialog();
          },
          label: Text("Request Documents"),
          icon: Icon(Icons.add),
          backgroundColor: isDarkMode ? Colors.blue.shade700 : Colors.blue,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.description,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Documents",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${filteredStudents.length} ${filteredStudents.length == 1 ? 'student' : 'students'}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.view_list : Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isGridView = !isGridView;
                  });
                },
                tooltip: isGridView ? "List View" : "Grid View",
              ),
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
                tooltip: isDarkMode ? "Light Mode" : "Dark Mode",
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: _fetchStudents,
                tooltip: "Refresh",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or ID",
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _filterStudents();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              style: TextStyle(
                fontSize: 16,
              ),
              onChanged: (value) {
                _filterStudents();
              },
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDepartmentChip("All"),
                ...departments.where((dept) => dept != "All").map((dept) => _buildDepartmentChip(dept)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentChip(String department) {
    bool isSelected = selectedDepartment == department;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(department),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedDepartment = department;
            _filterStudents();
          });
        },
        checkmarkColor: Colors.white,
        selectedColor: Colors.blue,
        showCheckmark: true,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        elevation: isSelected ? 3 : 0,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildSortingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "Sort by:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          DropdownButton<String>(
            value: sortBy,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  if (sortBy == newValue) {
                    isAscending = !isAscending;
                  } else {
                    sortBy = newValue;
                    isAscending = true;
                  }
                  _sortStudents();
                });
              }
            },
            items: ["Name", "ID", "Department", "Documents"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value),
                    SizedBox(width: 4),
                    if (sortBy == value)
                      Icon(
                        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList(),
            underline: Container(height: 1, color: Colors.blue),
          ),
          Spacer(),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withOpacity(0.3))
            ),
            child: Text(
              "${filteredStudents.length} results",
              style: TextStyle(
                color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 10,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            "No students found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try changing your search or filters",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              searchController.clear();
              setState(() {
                selectedDepartment = "All";
                _filterStudents();
              });
            },
            icon: Icon(Icons.refresh),
            label: Text("Reset Filters"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final status = _getDocumentStatus(student);
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    index * 0.05,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: child,
              ),
            );
          },
          child: Slidable(
            key: ValueKey(student["student_id"]),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _showDocumentHistoryDialog(student);
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.history,
                  label: 'History',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    _sendQueryDialog(student["student_id"]);
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  icon: Icons.message,
                  label: 'Query',
                ),
                SlidableAction(
                  onPressed: (context) {
                    _showResetConfirmation(student["student_id"]);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Reset',
                ),
              ],
            ),
            child: _buildStudentCard(student, status),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final status = _getDocumentStatus(student);
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.95,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    index * 0.05,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                )),
                child: child,
              ),
            );
          },
          child: _buildStudentGridCard(student, status),
        );
      },
    );
  }

  Widget _buildStudentCard(dynamic student, String status) {
    String name = student["name"];
    String studentID = student["student_id"];
    String department = student["department"];
    List<dynamic> documents = student["documents"] ?? [];
    DateTime lastUpdated = DateTime.now().subtract(Duration(days: student["student_id"].hashCode % 30));
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColors[status]?.withOpacity(0.5) ?? Colors.transparent,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showStudentDetails(student),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "ID: $studentID",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            department,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[status]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == "Verified" ? Icons.check_circle : 
                          status == "Pending" ? Icons.access_time : 
                          status == "Rejected" ? Icons.cancel : Icons.warning,
                          size: 14,
                          color: statusColors[status],
                        ),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColors[status],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Documents (${documents.length})",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        documents.isEmpty
                            ? Text(
                                "No documents uploaded",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Container(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: documents.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getDocumentIcon(documents[index]),
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            documents[index].split('/').last,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Last updated",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        timeago.format(lastUpdated),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.visibility, size: 18),
                    label: Text("View"),
                    onPressed: documents.isNotEmpty
                        ? () async {
                            if (await canLaunch(documents.first)) {
                              await launch(documents.first);
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    icon: Icon(Icons.message, size: 18),
                    label: Text("Query"),
                    onPressed: () => _sendQueryDialog(studentID),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGridCard(dynamic student, String status) {
    String name = student["name"];
    String studentID = student["student_id"];
    String department = student["department"];
    List<dynamic> documents = student["documents"] ?? [];
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColors[status]?.withOpacity(0.5) ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showStudentDetails(student),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: statusColors[status],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      status == "Verified" ? Icons.check : 
                      status == "Pending" ? Icons.access_time : 
                      status == "Rejected" ? Icons.cancel : Icons.warning,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                studentID,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  department,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description,
                      size: 14,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${documents.length} document${documents.length != 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: documents.isNotEmpty
                        ? () async {
                            if (await canLaunch(documents.first)) {
                              await launch(documents.first);
                            }
                          }
                        : null,
                    color: Colors.blue,
                    tooltip: "View documents",
                  ),
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () => _sendQueryDialog(studentID),
                    color: Colors.orange,
                    tooltip: "Send query",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String documentPath) {
    String extension = documentPath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showStudentDetails(dynamic student) {
    String name = student["name"];
    String studentID = student["student_id"];
    String department = student["department"];
    List<dynamic> documents = student["documents"] ?? [];
    String status = _getDocumentStatus(student);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "ID: $studentID • $department",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColors[status]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == "Verified" ? Icons.check_circle : 
                          status == "Pending" ? Icons.access_time : 
                          status == "Rejected" ? Icons.cancel : Icons.warning,
                          size: 16,
                          color: statusColors[status],
                        ),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColors[status],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Documents",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    documents.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_off,
                                  size: 60,
                                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No documents uploaded",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _sendQueryDialog(studentID),
                                  icon: Icon(Icons.message),
                                  label: Text("Send Document Request"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getDocumentIcon(documents[index]),
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: Text(
                                    documents[index].split('/').last,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Uploaded on ${DateTime.now().subtract(Duration(days: index * 3 + 1)).toString().split(' ')[0]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.visibility, color: Colors.blue),
                                        onPressed: () async {
                                          if (await canLaunch(documents[index])) {
                                            await launch(documents[index]);
                                          }
                                        },
                                        tooltip: "View",
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.download, color: Colors.green),
                                        onPressed: () async {
                                          if (await canLaunch(documents[index])) {
                                            await launch(documents[index]);
                                          }
                                        },
                                        tooltip: "Download",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 24),
                    Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            index == 0 ? Icons.upload_file :
                            index == 1 ? Icons.message :
                            Icons.check_circle,
                            color: index == 0 ? Colors.blue :
                                   index == 1 ? Colors.orange :
                                   Colors.green,
                          ),
                          title: Text(
                            index == 0 ? "Document uploaded" :
                            index == 1 ? "Query received" :
                            "Document verified",
                          ),
                          subtitle: Text(
                            "By Admin • ${timeago.format(DateTime.now().subtract(Duration(days: index * 2 + 1)))}",
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.message),
                    label: Text("Send Query"),
                    onPressed: () {
                      Navigator.pop(context);
                      _sendQueryDialog(studentID);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.update),
                    label: Text("Update Status"),
                    onPressed: () {
                      Navigator.pop(context);
                      _showUpdateStatusDialog(studentID, status);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentHistoryDialog(dynamic student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 8),
                Text(
                  "Document History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "${student["name"]} (${student["student_id"]})",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,  // Sample history entries
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: index == 0 
                          ? Border.all(color: Colors.blue, width: 1) 
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              index == 0 ? "Document uploaded" :
                              index == 1 ? "Document rejected" :
                              index == 2 ? "Query sent" :
                              index == 3 ? "Document requested" :
                              "Account created",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (index == 0 ? Colors.blue :
                                       index == 1 ? Colors.red :
                                       index == 2 ? Colors.orange :
                                       index == 3 ? Colors.purple :
                                       Colors.grey).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateTime.now().subtract(Duration(days: index * 3 + 1)).toString().split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: index == 0 ? Colors.blue :
                                         index == 1 ? Colors.red :
                                         index == 2 ? Colors.orange :
                                         index == 3 ? Colors.purple :
                                         Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          index == 0 ? "Student uploaded identity card document." :
                          index == 1 ? "Document was rejected due to poor image quality." :
                          index == 2 ? "Requested student to upload missing document." :
                          index == 3 ? "Admin requested document submission." :
                          "Student account was created in the system.",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "By: ${index == 0 ? student["name"] : "Admin User"}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQueryDialog(String studentID) {
    TextEditingController queryController = TextEditingController();
    List<String> queryOptions = [
      "Document Missing", 
      "Incorrect Document", 
      "Change Required",
      "Document Expired",
      "Poor Image Quality"
    ];
    String selectedQuery = queryOptions[0];
    bool sendEmail = true;
    bool sendSMS = false;
    bool urgent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text("Send Query to Student"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student ID: $studentID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Query Type",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedQuery,
                        underline: SizedBox(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedQuery = newValue!;
                          });
                        },
                        items: queryOptions.map((query) {
                          return DropdownMenuItem<String>(
                            value: query,
                            child: Text(query),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Additional Comments",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: queryController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Provide more details about the query...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Notification Options",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CheckboxListTile(
                      title: Text("Send Email Notification"),
                      value: sendEmail,
                      onChanged: (value) {
                        setState(() {
                          sendEmail = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text("Send SMS Notification"),
                      value: sendSMS,
                      onChanged: (value) {
                        setState(() {
                          sendSMS = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    SwitchListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.priority_high,
                            color: urgent ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Mark as Urgent",
                            style: TextStyle(
                              color: urgent ? Colors.red : null,
                              fontWeight: urgent ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                      value: urgent,
                      onChanged: (value) {
                        setState(() {
                          urgent = value;
                        });
                      },
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text("Send"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    sendDocumentQuery(
                      studentID, 
                      urgent ? "URGENT: $selectedQuery" : selectedQuery, 
                      queryController.text
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: EdgeInsets.all(16),
            );
          }
        );
      },
    );
  }

  void _showUpdateStatusDialog(String studentID, String currentStatus) {
    List<String> statusOptions = ["Verified", "Pending", "Rejected", "Missing"];
    String selectedStatus = currentStatus;
    TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.update,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text("Update Document Status"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Status: $currentStatus",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "New Status",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStatus,
                      underline: SizedBox(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatus = newValue!;
                        });
                      },
                      items: statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: statusColors[status],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(status),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Note (Optional)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Add a note about this status change...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update status (in a real app, this would call an API)
                    _showSuccessSnackBar("Status updated to $selectedStatus");
                    Navigator.pop(context);
                  },
                  child: Text("Update"),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDocumentRequestDialog() {
    TextEditingController messageController = TextEditingController();
    List<String> selectedStudents = [];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text("Request Documents"),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Students",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: filteredStudents.length > 5 ? 5 : filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final isSelected = selectedStudents.contains(student["student_id"]);
                          
                          return CheckboxListTile(
                            title: Text(student["name"]),
                            subtitle: Text(student["student_id"]),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  selectedStudents.add(student["student_id"]);
                                } else {
                                  selectedStudents.remove(student["student_id"]);
                                }
                              });
                            },
                            dense: true,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Enter message for document request...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text("Send Request"),
                  onPressed: () {
                    if (selectedStudents.isEmpty) {
                      _showErrorSnackBar("Please select at least one student");
                      return;
                    }
                    
                    if (messageController.text.trim().isEmpty) {
                      _showErrorSnackBar("Please enter a message");
                      return;
                    }
                    
                    _showSuccessSnackBar("Document request sent to ${selectedStudents.length} students");
                    Navigator.pop(context);
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmation(String studentID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("Reset Documents?"),
          ],
        ),
        content: Text(
          "This will remove all documents for student $studentID. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, call API to reset documents
              _showSuccessSnackBar("All documents have been reset for $studentID");
            },
            child: Text("RESET"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}