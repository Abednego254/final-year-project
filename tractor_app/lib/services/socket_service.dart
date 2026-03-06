import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void initSocket() {
    socket = IO.io(ApiConstants.baseUrl.replaceAll('/api', ''), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    
    socket.onConnect((_) {
      print('Connected to Socket.io server');
    });
    
    socket.onDisconnect((_) {
      print('Disconnected from Socket.io server');
    });
  }

  void emitLocation(int tractorId, double lat, double lng) {
    socket.emit('update_location', {
      'tractorId': tractorId,
      'latitude': lat,
      'longitude': lng,
    });
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

  void stopListeningToNotifications(int userId, String role) {
    socket.off('${role}_${userId}_notification');
  }
}
