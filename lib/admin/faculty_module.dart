import 'package:flutter/material.dart';
import 'faculty_details.dart';
import 'faculty_salary.dart';
import 'faculty_income_tax.dart';
import 'faculty_or_pr_allotment.dart';
import 'faculty_leave_management.dart';
import 'faculty_add.dart';

class FacultyModule extends StatelessWidget {
  const FacultyModule({super.key});

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
          "Faculty Module",
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Manage Faculty Operations",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // List Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildListTile(
                  context,
                  title: "Add Faculty",
                  icon: Icons.person_add,
                  page: FacultyAddPage(),
                ),
                buildListTile(
                  context,
                  title: "Faculty Details",
                  icon: Icons.info,
                  page: FacultyDetailsPage(),
                ),
                buildListTile(
                  context,
                  title: "Faculty Salary",
                  icon: Icons.payment,
                  page: FacultySalaryPage(),
                ),
                buildListTile(
                  context,
                  title: "Faculty Income Tax",
                  icon: Icons.account_balance,
                  page: FacultyIncomeTaxPage(),
                ),
                buildListTile(
                  context,
                  title: "OR-PR External Allotment",
                  icon: Icons.assignment,
                  page: FacultyORPRAllotmentPage(),
                ),
                buildListTile(
                  context,
                  title: "Faculty Leave Management",
                  icon: Icons.event_busy,
                  page: FacultyLeaveManagementPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(BuildContext context, {required String title, required IconData icon, required Widget page}) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}