import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  StreamSubscription<Position>? _locationSubscription;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  IO.Socket get socket {
    if (_socket == null) {
      initSocket();
    }
    return _socket!;
  }

  void initSocket() {
    if (_socket != null) return;

    _socket = IO.io(ApiConstants.baseUrl.replaceAll('/api', ''), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    
    _socket?.onConnect((_) {
      print('Connected to Socket.io server');
    });
    
    _socket?.onDisconnect((_) {
      print('Disconnected from Socket.io server');
    });

    _socket?.connect();
  }

  void emitLocation(int tractorId, double lat, double lng) {
    socket.emit('update_location', {
      'tractorId': tractorId,
      'latitude': lat,
      'longitude': lng,
    });
  }

  /// Operator side: start streaming real GPS coordinates to the backend.
  Future<void> startBroadcastingLocation(int tractorId) async {
    // Make sure we are not already streaming.
    await _locationSubscription?.cancel();

    // Check & request permission.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      print('Location permission denied – cannot broadcast.');
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // only emit if moved 5 metres
    );

    _locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      emitLocation(tractorId, position.latitude, position.longitude);
    });
  }

  /// Operator side: stop streaming GPS.
  Future<void> stopBroadcastingLocation() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void listenToLocation(int tractorId, Function(double lat, double lng) onLocationUpdate) {
    socket.on('tractor_${tractorId}_location', (data) {
      if (data != null && data['latitude'] != null && data['longitude'] != null) {
        onLocationUpdate(data['latitude'], data['longitude']);
      }
    });
  }

  void stopListening(int tractorId) {
    socket.off('tractor_${tractorId}_location');
  }

  void listenToNotifications(int userId, String role, Function(Map<String, dynamic> data) onNotification) {
    socket.on('${role}_${userId}_notification', (data) {
      onNotification(data);
    });
  }

  void listenToUserNotifications(int userId, Function(Map<String, dynamic> data) onNotification) {
    socket.on('user_${userId}_notification', (data) {
      onNotification(data);
    });
  }

  void stopListeningToNotifications(int userId, String role) {
    socket.off('${role}_${userId}_notification');
    socket.off('user_${userId}_notification');
  }
}
