import 'package:flutter/material.dart';

class FacultySalaryPage extends StatefulWidget {
  const FacultySalaryPage({super.key});

  @override
  _FacultySalaryPageState createState() => _FacultySalaryPageState();
}

class _FacultySalaryPageState extends State<FacultySalaryPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _salaryList = [
    {"name": "Dr. Rajesh Sharma", "salary": "₹1,20,000", "bonus": "₹10,000"},
    {"name": "Prof. Priya Verma", "salary": "₹95,000", "bonus": "₹5,000"},
    {"name": "Dr. Kiran Desai", "salary": "₹1,10,000", "bonus": "₹8,000"},
    {"name": "Prof. Amit Khanna", "salary": "₹85,000", "bonus": "₹4,000"},
  ];
  List<Map<String, String>> _filteredSalaryList = [];

  @override
  void initState() {
    super.initState();
    _filteredSalaryList = _salaryList;
    _searchController.addListener(_filterSalaries);
  }

  void _filterSalaries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSalaryList = _salaryList.where((salary) {
        final name = salary["name"]!.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSalaryDetails(BuildContext context, Map<String, String> salary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          salary["name"]!,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary: ${salary["salary"]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Bonus: ${salary["bonus"]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        title: Text(
          'Faculty Salaries',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.currency_rupee,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Faculty Salary List',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                        ) ?? const TextStyle(
                          fontSize: 22,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Salary List
          Expanded(
            child: _filteredSalaryList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No faculty found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ) ?? TextStyle(color: Colors.grey.shade600, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSalaryList.length,
                    itemBuilder: (context, index) {
                      final salary = _filteredSalaryList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        child: Semantics(
                          label: 'Faculty ${salary["name"]} salary details',
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                salary["name"]!.isNotEmpty ? salary["name"]![0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(
                              salary["name"]!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ) ?? const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Salary: ${salary["salary"]}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Bonus: ${salary["bonus"]}',
                                  style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.info, color: Theme.of(context).primaryColor),
                                  onPressed: () => _showSalaryDetails(context, salary),
                                  tooltip: 'View Details',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  onPressed: null, // Placeholder for future edit functionality
                                  tooltip: 'Edit (Coming Soon)',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}