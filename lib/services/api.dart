import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class API {
  // String get baseUrl => 'http://192.168.1.4/sahalat-api-backup-13-2-2026/public/api/owner';
  String get baseUrl => 'https://api.sahalat.sa.com/api/owner';
  Future getDashboardKPIs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response = await http.post(
      Uri.parse('$baseUrl/dashboard-kpis'),
      body: {
        'email': prefs.getString('email') ?? '',
        'password': prefs.getString('password') ?? '',
      }
    );
    if (response.statusCode == 200) {
      //     {
      //   'profitToday': 156.30,
      //   'profitWeek': 2244.55,
      //   'profitMonth': 8975.20,
      //   'pendingSettlementsTotal': 12800.25,
      //   'completedSettlementsTotal': 47350.00,
      //   'totalOrdersToday': 31,
      //   'totalOrdersMonth': 1240,
      //   'refundsCount': 12,
      //   'refundsAmount': 345.80,
      //   'pendingAccountsCount': 4,
      //   'settlementIssues': 2,
      //   'negativeBalances': 1,
      // }
      // print('Dashboard KPIs response: ${response.body}');
      return jsonDecode(response.body)['kpis'];
    } else {
      print('Failed to load dashboard KPIs: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load dashboard KPIs');
    }
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
        http.Response response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
      // print('Login response: ${response.body}');
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> data = jsonDecode(response.body)['data']['owner'];
      String email = data['email'];
      String password = data['password'];
      String name = data['name'];
      String id = data['id'].toString();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setString('name', name);
      await prefs.setString('id', id);
      return jsonDecode(response.body);

    } else {
      throw Exception('Failed to login');
    }
  }
}