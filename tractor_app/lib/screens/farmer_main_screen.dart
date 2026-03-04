import 'package:flutter/material.dart';
import 'farmer_home_screen.dart';
import 'farmer_bookings_screen.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const FarmerHomeScreen(),
    const FarmerBookingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Home Map'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Bookings'),
        ]
      )
    );
  }
}
