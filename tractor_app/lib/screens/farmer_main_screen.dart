import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/socket_service.dart';
import 'farmer_home_screen.dart';
import 'farmer_bookings_screen.dart';
import 'farmer_profile_screen.dart';
import '../utils/translations.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;
  int? _currentUserId;
  final List<Widget> _pages = [
    const FarmerHomeScreen(),
    const FarmerBookingsScreen(),
    const FarmerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        _currentUserId = user.id;
        SocketService().listenToUserNotifications(user.id, (data) {
          if (!mounted) return;
          
          // If it's a critical notification (like payment success), we might just rely on the Home Screen pop-up
          // but for general notifications, a snackbar is fine.
          if (data['type'] != 'payment_success') {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${data['title']}: ${data['message']}'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(20),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (_currentUserId != null) {
      SocketService().stopListeningToNotifications(_currentUserId!, 'user');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.agriculture_outlined),
            selectedIcon: const Icon(Icons.agriculture),
            label: Translations.get('home', Provider.of<AuthProvider>(context).user?.language ?? 'en'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: Translations.get('bookings', Provider.of<AuthProvider>(context).user?.language ?? 'en'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: Translations.get('profile', Provider.of<AuthProvider>(context).user?.language ?? 'en'),
          ),
        ],
      ),
    );
  }
}
