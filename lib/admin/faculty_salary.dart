import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart'; // For formatting currency

class FacultySalaryPage extends StatefulWidget {
  @override
  _FacultySalaryPageState createState() => _FacultySalaryPageState();
}

class _FacultySalaryPageState extends State<FacultySalaryPage> {
  bool _isGridView = false;
  String _sortBy = "name";
  bool _ascending = true;
  String _currentMonth = "March 2025";
  
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  
  // Expanded and enhanced data model
  final List<Map<String, dynamic>> salaryList = [
    {
      "name": "Dr. Rajesh Sharma",
      "department": "Computer Science",
      "designation": "Professor",
      "basic_salary": 95000,
      "allowances": 25000,
      "bonus": 10000,
      "deductions": 15000,
      "net_salary": 115000,
      "paid": true,
      "payment_date": "15-03-2025",
    },
    {
      "name": "Prof. Priya Verma",
      "department": "Electronics",
      "designation": "Associate Professor",
      "basic_salary": 78000,
      "allowances": 17000,
      "bonus": 5000,
      "deductions": 12000,
      "net_salary": 88000,
      "paid": true,
      "payment_date": "15-03-2025",
    },
    {
      "name": "Dr. Kiran Desai",
      "department": "Mechanical",
      "designation": "Professor",
      "basic_salary": 90000,
      "allowances": 20000,
      "bonus": 8000,
      "deductions": 14000,
      "net_salary": 104000,
      "paid": false,
      "payment_date": null,
    },
    {
      "name": "Prof. Amit Khanna",
      "department": "Civil",
      "designation": "Assistant Professor",
      "basic_salary": 65000,
      "allowances": 15000,
      "bonus": 4000,
      "deductions": 9000,
      "net_salary": 75000,
      "paid": true,
      "payment_date": "16-03-2025",
    },
    {
      "name": "Dr. Neha Gupta",
      "department": "Computer Science",
      "designation": "Associate Professor",
      "basic_salary": 82000,
      "allowances": 18000,
      "bonus": 6000,
      "deductions": 13000,
      "net_salary": 93000,
      "paid": false,
      "payment_date": null,
    },
    {
      "name": "Prof. Suresh Patel",
      "department": "AIDS",
      "designation": "Assistant Professor",
      "basic_salary": 70000,
      "allowances": 16000,
      "bonus": 5000,
      "deductions": 10000,
      "net_salary": 81000,
      "paid": true,
      "payment_date": "15-03-2025",
    },
    {
      "name": "Dr. Ananya Singh",
      "department": "Electronics",
      "designation": "Professor",
      "basic_salary": 92000,
      "allowances": 23000,
      "bonus": 9000,
      "deductions": 15000,
      "net_salary": 109000,
      "paid": true,
      "payment_date": "16-03-2025",
    },
    {
      "name": "Prof. Rajiv Kumar",
      "department": "Mechanical",
      "designation": "Assistant Professor",
      "basic_salary": 68000,
      "allowances": 15000,
      "bonus": 4000,
      "deductions": 9500,
      "net_salary": 77500,
      "paid": false,
      "payment_date": null,
    },
  ];

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
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
      
      salaryList.sort((a, b) {
        if (field == "name" || field == "department" || field == "designation") {
          if (_ascending) {
            return a[field].toString().compareTo(b[field].toString());
          } else {
            return b[field].toString().compareTo(a[field].toString());
          }
        } else {
          // Numeric comparison
          if (_ascending) {
            return (a[field] as num).compareTo(b[field] as num);
          } else {
            return (b[field] as num).compareTo(a[field] as num);
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _sortList(_sortBy);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals for dashboard
    final totalFaculty = salaryList.length;
    final totalPaid = salaryList.where((item) => item["paid"] == true).length;
    final totalSalaryAmount = salaryList.fold<double>(
        0, (sum, item) => sum + (item["net_salary"] as num));
    final averageSalary = totalSalaryAmount / totalFaculty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Faculty Salary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
            tooltip: _isGridView ? "List View" : "Grid View",
          ),
          PopupMenuButton<String>(
            tooltip: "Sort by",
            icon: const Icon(Icons.sort),
            onSelected: _sortList,
            itemBuilder: (context) => [
              _buildSortMenuItem("name", "Name"),
              _buildSortMenuItem("department", "Department"),
              _buildSortMenuItem("designation", "Designation"),
              _buildSortMenuItem("net_salary", "Salary Amount"),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard
          _buildDashboard(totalFaculty, totalPaid, totalSalaryAmount, averageSalary),
          
          // Month selector and filters
          _buildFiltersBar(),
          
          // Main content - list or grid
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action to process all pending payments
        },
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payments),
        label: const Text("Process Payments"),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.teal.shade700,
              size: 18,
            ),
          if (_sortBy == value) 
            const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: _sortBy == value ? FontWeight.bold : FontWeight.normal,
              color: _sortBy == value ? Colors.teal.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(int totalFaculty, int totalPaid, double totalSalaryAmount, double averageSalary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade600],
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
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Salary Dashboard",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentMonth,
                    style: TextStyle(
                      fontSize: 14,
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
                "Faculty",
                totalFaculty.toString(),
                Icons.people,
                Colors.blue.shade300,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                "Paid",
                "$totalPaid/$totalFaculty",
                Icons.check_circle,
                Colors.green.shade300,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                "Total Disbursed",
                currencyFormat.format(totalSalaryAmount),
                Icons.payments,
                Colors.orange.shade300,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                "Average Salary",
                currencyFormat.format(averageSalary),
                Icons.trending_up,
                Colors.purple.shade300,
              ),
            ],
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
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
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Text(
                  _currentMonth,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: Colors.teal.shade700),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Filter chips
          _buildFilterChip("All", true),
          const SizedBox(width: 8),
          _buildFilterChip("Paid", false),
          const SizedBox(width: 8),
          _buildFilterChip("Pending", false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.teal.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.teal.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.teal.shade700,
            ),
          if (selected) 
            const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.teal.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: salaryList.length,
      itemBuilder: (context, index) {
        final faculty = salaryList[index];
        final name = faculty["name"];
        final department = faculty["department"];
        final designation = faculty["designation"];
        final netSalary = faculty["net_salary"];
        final basicSalary = faculty["basic_salary"];
        final allowances = faculty["allowances"];
        final bonus = faculty["bonus"];
        final deductions = faculty["deductions"];
        final paid = faculty["paid"];
        final paymentDate = faculty["payment_date"];
        
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
                initials.substring(0, math.min(2, initials.length)),
                style: TextStyle(
                  color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name.toString(),
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
                      department.toString(),
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
            trailing: SizedBox(
              width: 110,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(netSalary),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            fontSize: 9,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Salary breakdown
                    Row(
                      children: [
                        Expanded(
                          child: _buildSalaryComponent(
                            "Basic Salary",
                            currencyFormat.format(basicSalary),
                            Icons.credit_card,
                            Colors.blue.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildSalaryComponent(
                            "Allowances",
                            currencyFormat.format(allowances),
                            Icons.add_circle_outline,
                            Colors.green.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildSalaryComponent(
                            "Bonus",
                            currencyFormat.format(bonus),
                            Icons.card_giftcard,
                            Colors.purple.shade700,
                          ),
                        ),
                        Expanded(
                          child: _buildSalaryComponent(
                            "Deductions",
                            currencyFormat.format(deductions),
                            Icons.remove_circle_outline,
                            Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Net salary and payment details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Net Salary",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(netSalary),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: Colors.teal,
                            thickness: 1,
                            width: 30,
                            indent: 5,
                            endIndent: 5,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      paid ? Icons.check_circle : Icons.pending_actions,
                                      size: 16,
                                      color: paid ? Colors.green.shade700 : Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      paid ? "Paid on ${paymentDate}" : "Payment Pending",
                                      style: TextStyle(
                                        color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Action to view salary slip
                          },
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text("View Slip"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal.shade700,
                            side: BorderSide(color: Colors.teal.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!paid)
                          ElevatedButton.icon(
                            onPressed: () {
                              // Action to process payment
                            },
                            icon: const Icon(Icons.payments, size: 16),
                            label: const Text("Process Payment"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
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
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: salaryList.length,
      itemBuilder: (context, index) {
        final faculty = salaryList[index];
        final name = faculty["name"];
        final department = faculty["department"];
        final designation = faculty["designation"];
        final netSalary = faculty["net_salary"];
        final basicSalary = faculty["basic_salary"];
        final allowances = faculty["allowances"];
        final bonus = faculty["bonus"];
        final paid = faculty["paid"];
        
        // Generate initials for avatar
        final initials = name.toString().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: paid ? Colors.green.shade100 : Colors.orange.shade100,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Action when card is tapped
            },
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
                          initials.substring(0, math.min(2, initials.length)),
                          style: TextStyle(
                            color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "$designation · $department",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: paid ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Net salary in large text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currencyFormat.format(netSalary),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "Net Salary",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  
                  const Divider(height: 24),
                  
                  // Salary components
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCompactSalaryComponent("Basic", currencyFormat.format(basicSalary)),
                      _buildCompactSalaryComponent("Allowances", currencyFormat.format(allowances)),
                      _buildCompactSalaryComponent("Bonus", currencyFormat.format(bonus)),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action when button is pressed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: paid ? Colors.teal.shade600 : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        paid ? "View Details" : "Process Payment",
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

  Widget _buildSalaryComponent(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompactSalaryComponent(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}