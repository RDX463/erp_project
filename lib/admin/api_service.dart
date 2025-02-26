import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // 🔹 Admin Login
  Future<Map<String, dynamic>> adminLogin(String employeeId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'employee_id': employeeId, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': jsonDecode(response.body)['detail'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error logging in: $e'};
    }
  }

  // 🔹 Admin Signup
  Future<Map<String, dynamic>> adminSignup(String employeeId, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_id': employeeId,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': jsonDecode(response.body)['detail'] ?? 'Signup failed'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error signing up: $e'};
    }
  }

  // 🔹 Admit Student
  Future<Map<String, dynamic>> admitStudent(String name, String email, double totalFees) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/admit-student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'total_fees': totalFees,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': jsonDecode(response.body)['detail'] ?? 'Admission failed'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error admitting student: $e'};
    }
  }

  // 🔹 Get Student Fees
  Future<Map<String, dynamic>> getFees(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/student/get-fees/$studentId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': jsonDecode(response.body)['detail'] ?? 'Failed to fetch fees'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error fetching fees: $e'};
    }
  }

  // 🔹 Pay Fees
  Future<void> payFees(String studentId, double amountPaid, String paymentMethod) async {
  final url = Uri.parse('http://localhost:8000/student/pay-fees');

  final Map<String, dynamic> requestData = {
    "student_id": studentId,
    "amount_paid": amountPaid,
    "payment_method": paymentMethod
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 200) {
    print("✅ Payment Successful: ${response.body}");
  } else {
    print("❌ Payment Failed: ${response.statusCode} - ${response.body}");
  }
}

Future<void> updateStudentDetails(String studentId, String name, String phone) async {
  final String apiUrl = "http://localhost:5000/update-student/$studentId"; // Ensure ID is included

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"name": name, "phone": phone}),
  );

  if (response.statusCode == 200) {
    print("Student details updated successfully");
  } else {
    print("Error: ${response.body}");
  }
}
}