import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class FacultyORPRAllotmentPage extends StatefulWidget {
  @override
  _FacultyORPRAllotmentPageState createState() => _FacultyORPRAllotmentPageState();
}

class _FacultyORPRAllotmentPageState extends State<FacultyORPRAllotmentPage> {
  bool _isGridView = false;
  String _selectedFilter = "All";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  
  // Enhanced data model with more fields
  final List<Map<String, dynamic>> allotmentList = [
    {
      "name": "Dr. Rajesh Sharma",
      "department": "Computer Science",
      "subject": "Operating Systems",
      "college": "MIT Pune",
      "date": "2025-04-15",
      "time": "10:00 AM - 1:00 PM",
      "type": "OR & PR",
      "status": "Upcoming",
      "remuneration": 3000,
      "contact_person": "Dr. Mehta",
      "contact_number": "9876543210",
      "students": 45,
    },
    {
      "name": "Prof. Priya Verma",
      "department": "Computer Science",
      "subject": "Data Science",
      "college": "VIT Mumbai",
      "date": "2025-04-10",
      "time": "2:00 PM - 5:00 PM",
      "type": "PR",
      "status": "Upcoming",
      "remuneration": 2500,
      "contact_person": "Prof. Joshi",
      "contact_number": "9876543211",
      "students": 38,
    },
    {
      "name": "Dr. Kiran Desai",
      "department": "Mechanical",
      "subject": "Thermodynamics",
      "college": "COEP Pune",
      "date": "2025-03-20",
      "time": "9:00 AM - 12:00 PM",
      "type": "OR & PR",
      "status": "Completed",
      "remuneration": 3000,
      "contact_person": "Dr. Patil",
      "contact_number": "9876543212",
      "students": 50,
    },
    {
      "name": "Prof. Amit Khanna",
      "department": "Electronics",
      "subject": "VLSI Design",
      "college": "SPPU Pune",
      "date": "2025-03-18",
      "time": "10:30 AM - 1:30 PM",
      "type": "OR",
      "status": "Completed",
      "remuneration": 2000,
      "contact_person": "Prof. Sharma",
      "contact_number": "9876543213",
      "students": 42,
    },
    {
      "name": "Dr. Meera Patel",
      "department": "Computer Science",
      "subject": "Machine Learning",
      "college": "DY Patil Pune",
      "date": "2025-04-22",
      "time": "11:00 AM - 2:00 PM",
      "type": "PR",
      "status": "Upcoming",
      "remuneration": 2500,
      "contact_person": "Dr. Kumar",
      "contact_number": "9876543214",
      "students": 35,
    },
    {
      "name": "Prof. Suresh Iyer",
      "department": "Civil",
      "subject": "Structural Engineering",
      "college": "VJTI Mumbai",
      "date": "2025-04-05",
      "time": "9:30 AM - 12:30 PM",
      "type": "OR & PR",
      "status": "Cancelled",
      "remuneration": 3000,
      "contact_person": "Prof. Deshmukh",
      "contact_number": "9876543215",
      "students": 40,
    },
    {
      "name": "Dr. Neha Gupta",
      "department": "Electronics",
      "subject": "Digital Signal Processing",
      "college": "PICT Pune",
      "date": "2025-03-25",
      "time": "1:00 PM - 4:00 PM",
      "type": "OR",
      "status": "Completed",
      "remuneration": 2000,
      "contact_person": "Dr. Singh",
      "contact_number": "9876543216",
      "students": 38,
    },
    {
      "name": "Prof. Anil Sharma",
      "department": "Computer Science",
      "subject": "Computer Networks",
      "college": "SGGS Nanded",
      "date": "2025-04-18",
      "time": "10:00 AM - 1:00 PM",
      "type": "OR & PR",
      "status": "Upcoming",
      "remuneration": 3500,
      "contact_person": "Prof. Jadhav",
      "contact_number": "9876543217",
      "students": 45,
    },
  ];

  List<Map<String, dynamic>> get filteredAllotments {
    return allotmentList.where((item) {
      // Apply status filter
      if (_selectedFilter != "All" && item["status"] != _selectedFilter) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item["name"].toLowerCase().contains(query) ||
               item["subject"].toLowerCase().contains(query) ||
               item["college"].toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats for dashboard
    final upcomingCount = allotmentList.where((item) => item["status"] == "Upcoming").length;
    final completedCount = allotmentList.where((item) => item["status"] == "Completed").length;
    final cancelledCount = allotmentList.where((item) => item["status"] == "Cancelled").length;
    final totalRemuneration = filteredAllotments.fold<int>(0, (sum, item) => sum + (item["remuneration"] as int));
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "OR-PR Allotment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? "List View" : "Grid View",
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard section
          _buildDashboard(upcomingCount, completedCount, cancelledCount, totalRemuneration),
          
          // Search and filters
          _buildSearchAndFilters(),
          
          // Main content
          Expanded(
            child: filteredAllotments.isEmpty
                ? _buildEmptyState()
                : _isGridView 
                    ? _buildGridView() 
                    : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action to add new allotment
        },
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Allotment"),
      ),
    );
  }

  Widget _buildDashboard(int upcoming, int completed, int cancelled, int totalRemuneration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800, Colors.amber.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "External Examiner Allotments",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Academic Year 2024-25",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                "Upcoming",
                upcoming.toString(),
                Icons.event_available, // Changed from event_upcoming
                Colors.blue.shade300,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                "Completed",
                completed.toString(),
                Icons.check_circle,
                Colors.green.shade300,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                "Cancelled",
                cancelled.toString(),
                Icons.cancel,
                Colors.red.shade300,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                "Total Remuneration",
                "₹$totalRemuneration",
                Icons.payments,
                Colors.purple.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: "Search by faculty, subject, or college",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _updateSearch("");
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.amber.shade400),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("All", _selectedFilter == "All"),
                const SizedBox(width: 8),
                _buildFilterChip("Upcoming", _selectedFilter == "Upcoming"),
                const SizedBox(width: 8),
                _buildFilterChip("Completed", _selectedFilter == "Completed"),
                const SizedBox(width: 8),
                _buildFilterChip("Cancelled", _selectedFilter == "Cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    Color chipColor;
    switch (label) {
      case "Upcoming":
        chipColor = Colors.blue;
        break;
      case "Completed":
        chipColor = Colors.green;
        break;
      case "Cancelled":
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.amber;
    }
    
    return GestureDetector(
      onTap: () => _setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor.withOpacity(0.5) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Icon(
                Icons.check,
                size: 16,
                color: chipColor,
              ),
            if (selected)
              const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? chipColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No allotments found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? "Try adjusting your search criteria"
                : "Try changing your filters",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _setFilter("All");
              _updateSearch("");
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reset Filters"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAllotments.length,
      itemBuilder: (context, index) {
        final allotment = filteredAllotments[index];
        final name = allotment["name"];
        final subject = allotment["subject"];
        final college = allotment["college"];
        final date = allotment["date"];
        final time = allotment["time"];
        final type = allotment["type"];
        final status = allotment["status"];
        final remuneration = allotment["remuneration"];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.2),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  college,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            children: [
              Divider(color: Colors.grey.shade300),
              
              // Details section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem("Date & Time", "$time on ${_formatDate(date)}", Icons.calendar_today),
                        const SizedBox(height: 12),
                        _buildDetailItem("Exam Type", type, Icons.assignment),
                        const SizedBox(height: 12),
                        _buildDetailItem("Remuneration", "₹$remuneration", Icons.payment),
                      ],
                    ),
                  ),
                  
                  // Right column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem("Contact Person", allotment["contact_person"], Icons.person),
                        const SizedBox(height: 12),
                        _buildDetailItem("Contact Number", allotment["contact_number"], Icons.phone),
                        const SizedBox(height: 12),
                        _buildDetailItem("Students Count", "${allotment["students"]}", Icons.people),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == "Upcoming")
                    OutlinedButton.icon(
                      onPressed: () {
                        // Cancel allotment action
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (status != "Cancelled")
                    status == "Upcoming"
                        ? ElevatedButton.icon(
                            onPressed: () {
                              // Complete allotment action
                            },
                            icon: const Icon(Icons.check_circle, size: 16),
                            label: const Text("Mark Complete"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              // Generate report action
                            },
                            icon: const Icon(Icons.description, size: 16),
                            label: const Text("Generate Report"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredAllotments.length,
      itemBuilder: (context, index) {
        final allotment = filteredAllotments[index];
        final name = allotment["name"];
        final subject = allotment["subject"];
        final college = allotment["college"];
        final date = allotment["date"];
        final time = allotment["time"];
        final type = allotment["type"];
        final status = allotment["status"];
        final remuneration = allotment["remuneration"];
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _getStatusColor(status).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Show full details
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
                        radius: 16,
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Faculty name and subject
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // College and type
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          college,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and time
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.amber.shade800),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Remuneration and action button
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Remuneration",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            "₹$remuneration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      status == "Upcoming"
                          ? ElevatedButton(
                              onPressed: () {
                                // View details action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "View",
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: () {
                                // View details action
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber.shade800,
                                side: BorderSide(color: Colors.amber.shade300),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Details",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Upcoming":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Upcoming":
        return Icons.event_available; // Changed from event_upcoming
      case "Completed":
        return Icons.check_circle;
      case "Cancelled":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateStr;
    }
  }
}