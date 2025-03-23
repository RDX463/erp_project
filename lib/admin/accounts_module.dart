import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminModule extends StatefulWidget {
  @override
  _AdminModuleState createState() => _AdminModuleState();
}

class _AdminModuleState extends State<AdminModule> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _recentTransactions = [
    {'id': 'TRX001', 'date': '2025-03-20', 'amount': 25000, 'type': 'Fee Payment', 'status': 'Completed'},
    {'id': 'TRX002', 'date': '2025-03-19', 'amount': 5000, 'type': 'Salary Advance', 'status': 'Processing'},
    {'id': 'TRX003', 'date': '2025-03-18', 'amount': 12500, 'type': 'Equipment Purchase', 'status': 'Completed'},
    {'id': 'TRX004', 'date': '2025-03-17', 'amount': 8750, 'type': 'Maintenance', 'status': 'Completed'},
    {'id': 'TRX005', 'date': '2025-03-15', 'amount': 32000, 'type': 'Fee Payment', 'status': 'Completed'},
  ];

  final List<Map<String, dynamic>> _pendingApprovals = [
    {'id': 'REQ001', 'type': 'Leave Request', 'requester': 'Dr. Sharma', 'date': '2025-03-22'},
    {'id': 'REQ002', 'type': 'Budget Increase', 'requester': 'CSE Department', 'date': '2025-03-21'},
    {'id': 'REQ003', 'type': 'New Equipment', 'requester': 'Physics Lab', 'date': '2025-03-20'},
    {'id': 'REQ004', 'type': 'Event Approval', 'requester': 'Student Council', 'date': '2025-03-19'},
  ];

  final Map<String, double> _expenseBreakdown = {
    'Salaries': 45.0,
    'Infrastructure': 20.0,
    'Equipment': 15.0,
    'Maintenance': 10.0,
    'Events': 5.0,
    'Others': 5.0,
  };

  final Map<String, double> _revenueBySource = {
    'Fees': 75.0,
    'Government Grants': 15.0,
    'Donations': 5.0,
    'Other Sources': 5.0,
  };

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Financial Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Approvals', icon: Icon(Icons.approval)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Show settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildApprovalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new transaction or entry
          _showAddTransactionDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add New Transaction',
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialSummary(),
          SizedBox(height: 24),
          Text(
            'Financial Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildExpenseChart()),
              SizedBox(width: 16),
              Expanded(child: _buildRevenueChart()),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildRecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Summary (FY 2024-25)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Total Revenue',
                  _currencyFormat.format(7500000),
                  Colors.green.shade100,
                  Colors.green.shade800,
                  Icons.trending_up,
                ),
                SizedBox(width: 10),
                _buildSummaryItem(
                  'Total Expenses',
                  _currencyFormat.format(5200000),
                  Colors.orange.shade100,
                  Colors.orange.shade800,
                  Icons.trending_down,
                ),
                SizedBox(width: 10),
                _buildSummaryItem(
                  'Net Balance',
                  _currencyFormat.format(2300000),
                  Colors.blue.shade100,
                  Colors.blue.shade800,
                  Icons.account_balance_wallet,
                ),
                SizedBox(width: 10),
                _buildSummaryItem(
                  'Pending Payments',
                  _currencyFormat.format(450000),
                  Colors.red.shade100,
                  Colors.red.shade800,
                  Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 180,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              SizedBox(width: 8),
              // Wrap the Text widget with Expanded to make it adjust to available space
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, // Add this to handle text overflow
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _getExpenseSections(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _buildExpenseLegend(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getExpenseSections() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return _expenseBreakdown.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${data.value.toInt()}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildExpenseLegend() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return _expenseBreakdown.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            data.key,
            style: TextStyle(fontSize: 12),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Sources',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _getRevenueSections(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _buildRevenueLegend(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getRevenueSections() {
    final List<Color> colors = [
      Colors.indigo,
      Colors.amber,
      Colors.lightGreen,
      Colors.deepOrange,
    ];

    return _revenueBySource.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${data.value.toInt()}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildRevenueLegend() {
    final List<Color> colors = [
      Colors.indigo,
      Colors.amber,
      Colors.lightGreen,
      Colors.deepOrange,
    ];

    return _revenueBySource.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            data.key,
            style: TextStyle(fontSize: 12),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRecentTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length > 3 ? 3 : _recentTransactions.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final transaction = _recentTransactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTransactionColor(transaction['type']),
              child: Icon(
                _getTransactionIcon(transaction['type']),
                color: Colors.white,
                size: 16,
              ),
            ),
            title: Text(transaction['type']),
            subtitle: Text('ID: ${transaction['id']} • ${transaction['date']}'),
            trailing: Text(
              _currencyFormat.format(transaction['amount']),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getAmountColor(transaction['type']),
              ),
            ),
            onTap: () {
              // Show transaction details
            },
          );
        },
      ),
    );
  }

  // Rest of the code remains unchanged...
  
  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentTransactions.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTransactionColor(transaction['type']),
                  child: Icon(
                    _getTransactionIcon(transaction['type']),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(transaction['type']),
                subtitle: Text('ID: ${transaction['id']} • ${transaction['date']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(transaction['amount']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getAmountColor(transaction['type']),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(transaction['status']),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Show transaction details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalsTab() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _pendingApprovals.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final approval = _pendingApprovals[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getApprovalIcon(approval['type']),
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      approval['type'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Request ID: ${approval['id']}'),
                Text('Requested by: ${approval['requester']}'),
                Text('Date: ${approval['date']}'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Reject approval
                      },
                      child: Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Approve request
                      },
                      child: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save transaction logic
                Navigator.of(context).pop();
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'Fee Payment':
        return Colors.green;
      case 'Salary Advance':
        return Colors.red;
      case 'Equipment Purchase':
        return Colors.purple;
      case 'Maintenance':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'Fee Payment':
        return Icons.school;
      case 'Salary Advance':
        return Icons.money;
      case 'Equipment Purchase':
        return Icons.computer;
      case 'Maintenance':
        return Icons.build;
      default:
        return Icons.receipt;
    }
  }

  Color _getAmountColor(String type) {
    if (type == 'Fee Payment') {
      return Colors.green.shade700;
    }
    return Colors.red.shade700;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade700;
      case 'Processing':
        return Colors.orange.shade700;
      case 'Pending':
        return Colors.blue.shade700;
      case 'Failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getApprovalIcon(String type) {
    switch (type) {
      case 'Leave Request':
        return Icons.event_busy;
      case 'Budget Increase':
        return Icons.attach_money;
      case 'New Equipment':
        return Icons.computer;
      case 'Event Approval':
        return Icons.celebration;
      default:
        return Icons.approval;
    }
  }
}