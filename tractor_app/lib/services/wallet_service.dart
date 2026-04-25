import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class WalletService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> getWalletData() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/wallet/balance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load wallet data');
    }
  }

  Future<List<dynamic>> getFullHistory() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/wallet/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['transactions'];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load transaction history');
    }
  }

  Future<Map<String, dynamic>> withdraw(double amount, String phone, String password) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/wallet/withdraw'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Withdrawal failed');
    }
  }
}
