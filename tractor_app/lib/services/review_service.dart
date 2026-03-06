import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ReviewService {
  Future<List<dynamic>> getOperatorReviews(int operatorId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/reviews/operator/$operatorId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reviews'] ?? [];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch reviews');
    }
  }
}
