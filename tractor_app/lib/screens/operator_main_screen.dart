import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/socket_service.dart';
import 'operator_home_screen.dart';
import 'operator_profile_screen.dart';
import 'operator_tractors_screen.dart';
import '../utils/translations.dart';

class OperatorMainScreen extends StatefulWidget {
  const OperatorMainScreen({super.key});

  @override
  State<OperatorMainScreen> createState() => _OperatorMainScreenState();
}

class _OperatorMainScreenState extends State<OperatorMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const OperatorHomeScreen(),
    const OperatorTractorsScreen(),
    const OperatorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        SocketService().listenToUserNotifications(user.id, (data) {
          if (!mounted) return;
          
          if (data['type'] != 'payment_received') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${data['title']}: ${data['message']}'),
                backgroundColor: Colors.blue,
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
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      SocketService().stopListeningToNotifications(user.id, 'user');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AuthProvider>(context).user?.language ?? 'en';
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: Translations.get('home', Provider.of<AuthProvider>(context).user?.language ?? 'en'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.agriculture_outlined),
            selectedIcon: const Icon(Icons.agriculture),
            label: lang == 'en' ? 'My Tractors' : 'Trekta Zangu',
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
