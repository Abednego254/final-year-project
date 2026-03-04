import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final userRole = prefs.getString('user_role');
    
    if (_token != null && userId != null && userName != null && userEmail != null && userRole != null) {
      _user = User(id: userId, name: userName, email: userEmail, role: userRole);
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(identifier, password);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      await _saveUserToPrefs(_token!, _user!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.register(name, email, phone, password, role);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      await _saveUserToPrefs(_token!, _user!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, String email, String phone, String currentPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.updateProfile(name, email, phone, currentPassword);
      final updatedUser = User.fromJson(data['user']);
      // Retain the existing token
      if (_token != null) {
        await _saveUserToPrefs(_token!, updatedUser);
        _user = updatedUser;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
