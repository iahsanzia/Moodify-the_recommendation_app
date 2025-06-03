import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.98.166:8000";

  Future<bool> registerUser(
    String fullname,
    String email,
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  Future<String?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token']; // Return JWT token
    } else {
      return null;
    }
  }
}
