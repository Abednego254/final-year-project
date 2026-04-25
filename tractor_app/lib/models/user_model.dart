class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool pushNotifications;
  final bool smsAlerts;
  final String language;
  final bool darkMode;
  
  User({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.phone,
    required this.role,
    this.pushNotifications = true,
    this.smsAlerts = false,
    this.language = 'en',
    this.darkMode = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'farmer',
      pushNotifications: json['push_notifications'] ?? true,
      smsAlerts: json['sms_alerts'] ?? false,
      language: json['language'] ?? 'en',
      darkMode: json['dark_mode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'push_notifications': pushNotifications,
      'sms_alerts': smsAlerts,
      'language': language,
      'dark_mode': darkMode,
    };
  }
}
