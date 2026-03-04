import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class OperatorService {
  Future<List<dynamic>> getOperatorBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bookings/operator-bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['bookings'] ?? [];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load operator bookings');
    }
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update booking');
    }
  }

  Future<Map<String, dynamic>> registerTractor(String model, String licensePlate) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/tractors'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'model': model,
        'license_plate': licensePlate,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['tractor'];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register tractor');
    }
  }

  Future<List<dynamic>> getMyTractors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/tractors/my-tractors'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['tractors'] ?? [];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to load your tractors');
    }
  }

  Future<void> updateTractorStatus(int tractorId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/tractors/$tractorId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update tractor status');
    }
  }
}
