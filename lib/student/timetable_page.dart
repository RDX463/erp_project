import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String selectedClass = "Class 10"; // Default class
  List<dynamic> timetable = []; // Stores timetable data

  @override
  void initState() {
    super.initState();
    fetchTimetable(selectedClass);
  }

  // Fetch timetable from API
  Future<void> fetchTimetable(String className) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/get_timetable?class_name=$className"),
      );

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          timetable = data.isEmpty ? getDummyTimetable() : data;
        });
      } else {
        setState(() {
          timetable = getDummyTimetable();
        });
      }
    } catch (e) {
      print("Error Fetching Timetable: $e");
      setState(() {
        timetable = getDummyTimetable();
      });
    }
  }

  // Dummy Timetable
  List<Map<String, String>> getDummyTimetable() {
    return [
      {
        "period": "1",
        "subject": "Mathematics",
        "start_time": "08:00 AM",
        "end_time": "09:00 AM",
        "teacher": "Mr. Sharma"
      },
      {
        "period": "2",
        "subject": "English",
        "start_time": "09:00 AM",
        "end_time": "10:00 AM",
        "teacher": "Ms. Kapoor"
      },
      {
        "period": "3",
        "subject": "Science",
        "start_time": "10:15 AM",
        "end_time": "11:15 AM",
        "teacher": "Dr. Rao"
      },
    ];
  }

  // Beautiful Card UI
  Widget _buildTimetableCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            entry['period'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ),
        title: Text(
          entry['subject'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "${entry['start_time']} - ${entry['end_time']}",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: Colors.white70, size: 18),
            Text(
              entry['teacher'],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text("Class Timetable", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Animated Class Selector
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedClass,
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down_circle, color: Colors.deepPurple),
                  onChanged: (newValue) {
                    setState(() {
                      selectedClass = newValue!;
                      fetchTimetable(selectedClass);
                    });
                  },
                  items: ["Class 10", "Class 11", "Class 12"]
                      .map((className) => DropdownMenuItem(
                            value: className,
                            child: Text(className, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
              ),

              SizedBox(height: 20),

              // Timetable List with animation
              Expanded(
                child: timetable.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule, size: 60, color: Colors.grey.shade600),
                            SizedBox(height: 10),
                            Text(
                              "No Timetable Available",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: timetable.length,
                        itemBuilder: (context, index) {
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 500),
                            child: _buildTimetableCard(timetable[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
