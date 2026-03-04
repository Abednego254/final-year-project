import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/tractor_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/farmer_main_screen.dart';
import 'screens/operator_main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TractorProvider()),
      ],
      child: const TractorApp(),
    ),
  );
}

class TractorApp extends StatelessWidget {
  const TractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tractor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            if (auth.user?.role == 'operator') {
              return const OperatorMainScreen();
            }
            return const FarmerMainScreen();
          }
          return const LoginScreen();
        }
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
