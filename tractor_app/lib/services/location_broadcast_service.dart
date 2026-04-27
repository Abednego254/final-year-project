import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'socket_service.dart';

class LocationBroadcastService {
  static final LocationBroadcastService _instance = LocationBroadcastService._internal();
  factory LocationBroadcastService() => _instance;
  LocationBroadcastService._internal();

  final SocketService _socketService = SocketService();
  StreamSubscription<Position>? _positionStream;
  bool _isBroadcasting = false;
  int? _currentTractorId;

  bool get isBroadcasting => _isBroadcasting;

  Future<void> startBroadcasting(int tractorId) async {
    if (_isBroadcasting && _currentTractorId == tractorId) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      return; // Can't broadcast without permissions
    }

    _isBroadcasting = true;
    _currentTractorId = tractorId;

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position pos) {
        _socketService.emitLocation(tractorId, pos.latitude, pos.longitude);
      },
      onError: (error) {
        print("Location Broadcast Error: $error");
      }
    );
  }

  Future<void> stopBroadcasting() async {
    await _positionStream?.cancel();
    _positionStream = null;
    await _socketService.stopBroadcastingLocation();
    _isBroadcasting = false;
    _currentTractorId = null;
  }
}
