import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class API {
  // String get baseUrl => 'http://192.168.1.4/sahalat-api-backup-13-2-2026/public/api/owner';
  // override for local testing: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
  static const String _apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.sahalat.sa.com/api');
  String get baseUrl => '$_apiBase/owner';
  /// Thrown when the server says the session is over (401/403): the screen must go back to the login page.
  static final sessionExpired = Exception('session expired');

  Future<Map<String, String>> _authHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future getDashboardKPIs() async {
    final response = await http
        .get(Uri.parse('$baseUrl/dashboard-kpis'), headers: await _authHeaders())
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['kpis'];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw sessionExpired;
    } else {
      throw Exception('Failed to load dashboard KPIs (${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    http.Response response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final body = jsonDecode(response.body);
      Map<String, dynamic> data = body['data']['owner'];
      await prefs.setString('email', data['email']);
      await prefs.setString('name', data['name']);
      await prefs.setString('id', data['id'].toString());
      await prefs.setString('token', body['data']['token'] ?? '');
      await prefs.remove('password'); // the password (or its hash) is never kept on the phone
      return body;
    } else {
      throw Exception('Failed to login');
    }
  }

  /// Ends the session on the server (best effort) and wipes everything stored on the phone.
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await http
          .post(Uri.parse('$baseUrl/logout'), headers: await _authHeaders())
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
    await prefs.clear();
  }
}
