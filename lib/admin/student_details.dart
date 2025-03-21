import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchStudentData(String studentId) async {
  final response = await http.get(Uri.parse("http://localhost:5000/get_student_data/$studentId"));
  return json.decode(response.body);
}
