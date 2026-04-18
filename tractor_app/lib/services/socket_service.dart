import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;

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
