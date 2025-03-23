import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class FacultyDetailsPage extends StatefulWidget {
  @override
  _FacultyDetailsPageState createState() => _FacultyDetailsPageState();
}

class _FacultyDetailsPageState extends State<FacultyDetailsPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> facultyList = [];
  List<Map<String, dynamic>> filteredFacultyList = [];
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = "";
  String? selectedDepartment;
  String sortBy = "name"; // Default sort
  bool ascending = true;
  int? expandedIndex;
  
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  
  final List<String> departments = ["All", "COM", "AIDS", "MECH", "ENTC", "CIVIL"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    fetchFacultyData();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      isSearching = searchQuery.isNotEmpty;
      _filterFaculty();
    });
  }

  /// Fetch faculty details from FastAPI
  Future<void> fetchFacultyData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:5000/faculty/all"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          facultyList = List<Map<String, dynamic>>.from(data);
          _filterFaculty();
          isLoading = false;
        });
      } else {
        showError("Failed to load faculty data: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching faculty data: $e");
    }
  }

  /// Apply filters and sorting
  void _filterFaculty() {
    setState(() {
      // First apply department filter
      if (selectedDepartment == null || selectedDepartment == "All") {
        filteredFacultyList = List.from(facultyList);
      } else {
        filteredFacultyList = facultyList
            .where((faculty) => faculty["department"] == selectedDepartment)
            .toList();
      }
      
      // Then apply search filter if applicable
      if (searchQuery.isNotEmpty) {
        filteredFacultyList = filteredFacultyList
            .where((faculty) {
              final name = faculty["name"]?.toString().toLowerCase() ?? "";
              final id = faculty["employee_id"]?.toString().toLowerCase() ?? "";
              final email = faculty["email"]?.toString().toLowerCase() ?? "";
              final dept = faculty["department"]?.toString().toLowerCase() ?? "";
              
              final query = searchQuery.toLowerCase();
              return name.contains(query) || 
                     id.contains(query) || 
                     email.contains(query) ||
                     dept.contains(query);
            })
            .toList();
      }
      
      // Apply sorting
      filteredFacultyList.sort((a, b) {
        var aValue = a[sortBy];
        var bValue = b[sortBy];
        
        // Handle null values
        if (aValue == null && bValue == null) return 0;
        if (aValue == null) return ascending ? -1 : 1;
        if (bValue == null) return ascending ? 1 : -1;
        
        // Compare based on data type
        if (aValue is String && bValue is String) {
          return ascending 
              ? aValue.compareTo(bValue) 
              : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending 
              ? aValue.compareTo(bValue) 
              : bValue.compareTo(aValue);
        }
        
        // Default to string comparison
        return ascending 
            ? aValue.toString().compareTo(bValue.toString()) 
            : bValue.toString().compareTo(aValue.toString());
      });
    });
  }

  /// Toggle sort order
  void _toggleSort(String field) {
    setState(() {
      if (sortBy == field) {
        ascending = !ascending;
      } else {
        sortBy = field;
        ascending = true;
      }
      _filterFaculty();
    });
  }
  
  /// Set the current department filter
  void _setDepartmentFilter(String? department) {
    setState(() {
      selectedDepartment = department;
      _filterFaculty();
    });
  }

  /// Clear all filters and reset to initial state
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      searchQuery = "";
      isSearching = false;
      selectedDepartment = null;
      sortBy = "name";
      ascending = true;
      _filterFaculty();
    });
  }

  /// Show error messages
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Faculty Directory",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFacultyData,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: isLoading
                ? _buildLoadingView()
                : filteredFacultyList.isEmpty
                    ? _buildEmptyView()
                    : _buildFacultyList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search faculty by name, ID or email",
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = "";
                            isSearching = false;
                            _filterFaculty();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Department filter and sorting
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDepartment ?? "All",
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                      items: departments.map((dept) {
                        return DropdownMenuItem<String>(
                          value: dept,
                          child: Text(
                            dept,
                            style: TextStyle(
                              color: dept == selectedDepartment
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                              fontWeight: dept == selectedDepartment
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _setDepartmentFilter,
                      hint: Text("Department", style: TextStyle(color: Colors.grey.shade700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                tooltip: "Sort by",
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ascending 
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                        color: Colors.blue.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.sort, color: Colors.blue.shade700),
                    ],
                  ),
                ),
                onSelected: _toggleSort,
                itemBuilder: (context) => [
                  _buildSortMenuItem("name", "Name"),
                  _buildSortMenuItem("employee_id", "ID"),
                  _buildSortMenuItem("department", "Department"),
                  _buildSortMenuItem("experience", "Experience"),
                ],
              ),
              IconButton(
                icon: Icon(Icons.filter_list_off, color: Colors.grey.shade700),
                tooltip: "Clear filters",
                onPressed: _clearFilters,
              ),
            ],
          ),
          
          // Active filters display
          if (isSearching || selectedDepartment != null && selectedDepartment != "All")
            Container(
              padding: const EdgeInsets.only(top: 12),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isSearching)
                    _buildFilterChip(
                      "Search: $searchQuery",
                      Icons.search,
                      Colors.blue.shade100,
                      Colors.blue.shade700,
                      () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = "";
                          isSearching = false;
                          _filterFaculty();
                        });
                      },
                    ),
                  if (selectedDepartment != null && selectedDepartment != "All")
                    _buildFilterChip(
                      "Dept: $selectedDepartment",
                      Icons.business,
                      Colors.purple.shade100,
                      Colors.purple.shade700,
                      () {
                        setState(() {
                          selectedDepartment = "All";
                          _filterFaculty();
                        });
                      },
                    ),
                  // Show count of results
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "${filteredFacultyList.length} faculty members",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (sortBy == value)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.blue.shade700,
              size: 18,
            ),
          if (sortBy == value)
            const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: sortBy == value ? FontWeight.bold : FontWeight.normal,
              color: sortBy == value ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onRemove,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(
            "Loading faculty data...",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_alt,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching || (selectedDepartment != null && selectedDepartment != "All")
                ? "No faculty members match your filters"
                : "No faculty data available",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (isSearching || (selectedDepartment != null && selectedDepartment != "All"))
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_list_off),
              label: const Text("Clear Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacultyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFacultyList.length,
      itemBuilder: (context, index) {
        var faculty = filteredFacultyList[index];
        final isExpanded = expandedIndex == index;
        final departmentColor = _getDepartmentColor(faculty["department"]);

        // Generate initials for avatar
        final name = faculty["name"] ?? "Unknown";
        final initials = name.toString().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
        
        return Card(
          elevation: isExpanded ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isExpanded ? departmentColor.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Faculty header section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: departmentColor.withOpacity(0.8),
                        child: Text(
                          initials.substring(0, math.min(2, initials.length)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Name and basic info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.badge, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  faculty["employee_id"] ?? "No ID",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Department badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: departmentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: departmentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          faculty["department"] ?? "No Dept",
                          style: TextStyle(
                            color: departmentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Expand/collapse icon
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                
                // Expanded details section
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: _buildExpandedDetails(faculty),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> faculty) {
    final email = faculty["email"];
    final phone = faculty["phone"];
    final departmentColor = _getDepartmentColor(faculty["department"]);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal details
                Text(
                  "Personal Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        "Date of Birth",
                        faculty["dob"] ?? "Not available",
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.wc,
                        "Gender",
                        faculty["gender"] ?? "Not specified",
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.location_on,
                        "Address",
                        faculty["address"] ?? "Not available",
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Professional details
                Text(
                  "Professional Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.work,
                        "Experience",
                        "${faculty["experience"] ?? 'N/A'} years",
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.attach_money,
                        "Salary",
                        faculty["salary"] != null ? "₹${faculty["salary"]}" : "Not available",
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Contact actions
                Text(
                  "Contact Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    if (email != null)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: email));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Email copied to clipboard"),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: _buildInfoItem(
                            Icons.email,
                            "Email",
                            email,
                            isActionable: true,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    if (phone != null)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: phone));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Phone number copied to clipboard"),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: _buildInfoItem(
                            Icons.phone,
                            "Phone",
                            phone,
                            isActionable: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quick action buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (email != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.email, size: 16),
                    label: const Text("Email"),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Email copied to clipboard"),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: departmentColor,
                      side: BorderSide(color: departmentColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (phone != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text("Call"),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Phone number copied to clipboard"),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: departmentColor,
                      side: BorderSide(color: departmentColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isActionable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActionable ? Colors.blue.shade700 : Colors.black87,
                  decoration: isActionable ? TextDecoration.underline : null,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getDepartmentColor(String? department) {
    switch (department) {
      case "COM":
        return Colors.blue.shade700;
      case "AIDS":
        return Colors.purple.shade700;
      case "MECH":
        return Colors.orange.shade700;
      case "ENTC":
        return Colors.green.shade700;
      case "CIVIL":
        return Colors.brown.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }
}