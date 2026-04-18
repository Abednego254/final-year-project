import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/socket_service.dart';
import 'operator_home_screen.dart';
import 'operator_profile_screen.dart';
import 'operator_tractors_screen.dart';

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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${data['title']}: ${data['message']}'),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
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
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture),
            label: 'My Tractors',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
