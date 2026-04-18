import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class SupportService {
  Future<bool> sendMessage(String subject, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/support/message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subject': subject,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to send message');
    }
  }
}
