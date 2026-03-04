import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class BookingService {
  Future<Map<String, dynamic>> createBooking(int tractorId, String scheduledDate, double price) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tractor_id': tractorId,
        'scheduled_date': scheduledDate,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create booking');
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bookings/my-bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['bookings'] ?? [];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load bookings');
    }
  }
}
