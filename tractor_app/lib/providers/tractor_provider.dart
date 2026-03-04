import 'package:flutter/material.dart';
import '../services/tractor_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TractorProvider with ChangeNotifier {
  final TractorService _tractorService = TractorService();
  List<dynamic> _tractors = [];
  Set<Marker> _markers = {};
  bool _isLoading = false;

  List<dynamic> get tractors => _tractors;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;

  Future<void> fetchAvailableTractors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tractors = await _tractorService.getAvailableTractors();
      _markers = _tractors.map((t) {
        // Safe mapping assuming standard latitude/longitude fields
        double lat = double.tryParse(t['latitude']?.toString() ?? '0') ?? 0;
        double lng = double.tryParse(t['longitude']?.toString() ?? '0') ?? 0;
        return Marker(
          markerId: MarkerId(t['id'].toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: t['tractor_model'] ?? 'Available Tractor', 
            snippet: 'Distance: ...', // To be expanded with geolocator later
          ),
        );
      }).toSet();
    } catch (e) {
      debugPrint('Error fetching tractors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
