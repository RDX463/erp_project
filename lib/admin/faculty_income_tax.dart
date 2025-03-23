import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting

class FacultyIncomeTaxPage extends StatefulWidget {
  @override
  _FacultyIncomeTaxPageState createState() => _FacultyIncomeTaxPageState();
}

class _FacultyIncomeTaxPageState extends State<FacultyIncomeTaxPage> {
  final List<Map<String, dynamic>> taxList = [
    {
      "name": "Dr. Rajesh Sharma",
      "tax": 120000,
      "designation": "Associate Professor",
      "department": "Computer Science",
      "salary": 1200000,
      "deductions": 85000,
      "paid": true,
    },
    {
      "name": "Prof. Priya Verma",
      "tax": 95000,
      "designation": "Assistant Professor",
      "department": "Electronics",
      "salary": 950000,
      "deductions": 65000,
      "paid": true,
    },
    {
      "name": "Dr. Kiran Desai",
      "tax": 110000,
      "designation": "Professor",
      "department": "Mechanical",
      "salary": 1100000,
      "deductions": 75000,
      "paid": false,
    },
    {
      "name": "Prof. Amit Khanna",
      "tax": 85000,
      "designation": "Assistant Professor",
      "department": "Civil",
      "salary": 850000,
      "deductions": 55000,
      "paid": true,
    },
    {
      "name": "Dr. Neha Singh",
      "tax": 105000,
      "designation": "Associate Professor",
      "department": "AIDS",
      "salary": 1050000,
      "deductions": 72000,
      "paid": false,
    },
    {
      "name": "Prof. Vikram Patel",
      "tax": 90000,
      "designation": "Assistant Professor",
      "department": "Computer Science",
      "salary": 900000,
      "deductions": 60000,
      "paid": true,
    },
  ];

  bool _showGridView = false;
  String _sortBy = "name";
  bool _ascending = true;
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _toggleView() {
    setState(() {
      _showGridView = !_showGridView;
    });
  }

  void _sortList(String field) {
    setState(() {
      if (_sortBy == field) {
        _ascending = !_ascending;
      } else {
        _sortBy = field;
        _ascending = true;
      }

      taxList.sort((a, b) {
        if (_ascending) {
          return a[field].toString().compareTo(b[field].toString());
        } else {
          return b[field].toString().compareTo(a[field].toString());
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _sortList(_sortBy); // Initial sort by name
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    int totalFaculty = taxList.length;
    int totalPaid = taxList.where((faculty) => faculty["paid"] == true).length;
    double totalTaxAmount = taxList.fold(0, (sum, faculty) => sum + faculty["tax"]);
    double averageTax = totalTaxAmount / totalFaculty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Faculty Income Tax",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _showGridView ? "List View" : "Grid View",
          ),
          PopupMenuButton<String>(
            tooltip: "Sort by",
            icon: const Icon(Icons.sort),
            onSelected: _sortList,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "name",
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: _sortBy == "name" ? Colors.indigo.shade700 : Colors.grey.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: _sortBy == "name" ? FontWeight.bold : FontWeight.normal,
                        color: _sortBy == "name" ? Colors.indigo.shade700 : Colors.black87,
                      ),
                    ),
                    if (_sortBy == "name")
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.indigo.shade700,
                        size: 18,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "tax",
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: _sortBy == "tax" ? Colors.indigo.shade700 : Colors.grey.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Tax Amount",
                      style: TextStyle(
                        fontWeight: _sortBy == "tax" ? FontWeight.bold : FontWeight.normal,
                        color: _sortBy == "tax" ? Colors.indigo.shade700 : Colors.black87,
                      ),
                    ),
                    if (_sortBy == "tax")
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.indigo.shade700,
                        size: 18,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "department",
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: _sortBy == "department" ? Colors.indigo.shade700 : Colors.grey.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Department",
                      style: TextStyle(
                        fontWeight: _sortBy == "department" ? FontWeight.bold : FontWeight.normal,
                        color: _sortBy == "department" ? Colors.indigo.shade700 : Colors.black87,
                      ),
                    ),
                    if (_sortBy == "department")
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.indigo.shade700,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard and summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.indigo.shade700],
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
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Income Tax Dashboard",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Financial Year 2024-25",
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
                    _buildSummaryCard(
                      "Total Faculty", 
                      totalFaculty.toString(), 
                      Icons.people,
                      Colors.blue.shade300,
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryCard(
                      "Tax Filings Complete", 
                      "$totalPaid/$totalFaculty", 
                      Icons.check_circle,
                      Colors.green.shade300,
                    ),
                    const SizedBox(width: 8),
                    _buildSummaryCard(
                      "Average Tax", 
                      currencyFormat.format(averageTax), 
                      Icons.trending_up,
                      Colors.orange.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Row(
              children: [
                Text(
                  "Sort by: ${_sortBy.substring(0, 1).toUpperCase() + _sortBy.substring(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.indigo.shade700,
                ),
                const Spacer(),
                _buildFilterChip("All", true),
                const SizedBox(width: 8),
                _buildFilterChip("Paid", true),
                const SizedBox(width: 8),
                _buildFilterChip("Pending", false),
              ],
            ),
          ),

          // Faculty list or grid
          Expanded(
            child: _showGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor) {
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? Colors.indigo.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? Colors.indigo.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enabled)
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.indigo.shade700,
            ),
          if (enabled)
            const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
              color: enabled ? Colors.indigo.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taxList.length,
      itemBuilder: (context, index) {
        final faculty = taxList[index];
        final name = faculty["name"];
        final tax = faculty["tax"];
        final paid = faculty["paid"];
        final department = faculty["department"];
        final designation = faculty["designation"];
        
        // Generate initials for avatar
        final initials = name.toString().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: paid ? Colors.green.shade100 : Colors.orange.shade100,
              child: Text(
                initials.substring(0, min(2, initials.length)),
                style: TextStyle(
                  color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      department,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      " · $designation",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Fix for overflow issue - use SizedBox with maximum height
            trailing: SizedBox(
              width: 90,  // Ensure there's enough width
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,  // Important to prevent overflow
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(tax),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                          fontSize: 14,  // Reduced size
                        ),
                      ),
                      const SizedBox(height: 2),  // Reduced spacing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),  // Reduced padding
                        decoration: BoxDecoration(
                          color: paid ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: paid ? Colors.green.shade300 : Colors.orange.shade300,
                          ),
                        ),
                        child: Text(
                          paid ? "Paid" : "Pending",
                          style: TextStyle(
                            fontSize: 9,  // Smaller text
                            fontWeight: FontWeight.bold,
                            color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDetailRow("Annual Income", currencyFormat.format(faculty["salary"]), Icons.wallet),
                    const SizedBox(height: 8),
                    _buildDetailRow("Tax Deductions", currencyFormat.format(faculty["deductions"]), Icons.remove_circle_outline),
                    const SizedBox(height: 8),
                    _buildDetailRow("Net Taxable Income", currencyFormat.format(faculty["salary"] - faculty["deductions"]), Icons.calculate),
                    const SizedBox(height: 8),
                    _buildDetailRow("Total Tax", currencyFormat.format(faculty["tax"]), Icons.receipt_long),
                    const SizedBox(height: 8),
                    _buildDetailRow("Status", paid ? "Paid" : "Pending", paid ? Icons.check_circle : Icons.pending_actions, paid ? Colors.green.shade700 : Colors.orange.shade700),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.remove_red_eye, size: 16),
                          label: const Text("View Details"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo.shade700,
                            side: BorderSide(color: Colors.indigo.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!paid)
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text("Mark as Paid"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
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
        childAspectRatio: 0.85,  // Adjusted for better fit
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: taxList.length,
      itemBuilder: (context, index) {
        final faculty = taxList[index];
        final name = faculty["name"];
        final tax = faculty["tax"];
        final paid = faculty["paid"];
        final department = faculty["department"];
        final designation = faculty["designation"];
        
        // Generate initials for avatar
        final initials = name.toString().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: paid ? Colors.green.shade100 : Colors.orange.shade100,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: paid ? Colors.green.shade50 : Colors.orange.shade50,
                        child: Text(
                          initials.substring(0, min(2, initials.length)),
                          style: TextStyle(
                            color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),  // Reduced padding
                        decoration: BoxDecoration(
                          color: paid ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: paid ? Colors.green.shade300 : Colors.orange.shade300,
                          ),
                        ),
                        child: Text(
                          paid ? "Paid" : "Pending",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,  // Slightly smaller
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$designation · $department",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Income Tax:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormat.format(tax),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Deductions:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormat.format(faculty["deductions"]),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: paid ? Colors.indigo.shade600 : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),  // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        paid ? "View Details" : "Mark as Paid",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, [Color? valueColor]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  // Helper to get minimum of two integers for initials
  int min(int a, int b) => a < b ? a : b;
}