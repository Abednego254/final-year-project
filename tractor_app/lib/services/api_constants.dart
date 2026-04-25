class ApiConstants {
  // Use localhost (127.0.0.1) for physical devices with ADB reverse, or 10.0.2.2 for emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
}
