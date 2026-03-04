import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _identifierController.text.trim(),
        _passwordController.text,
      );
      // On success, Consumer in main.dart will rebuild app to show Home automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Form(
           key: _formKey,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               TextFormField(
                 controller: _identifierController,
                 decoration: const InputDecoration(labelText: 'Email or Phone'),
                 validator: (val) => val!.isEmpty ? 'Enter email/phone' : null,
               ),
               const SizedBox(height: 16),
               TextFormField(
                 controller: _passwordController,
                 decoration: const InputDecoration(labelText: 'Password'),
                 obscureText: true,
                 validator: (val) => val!.isEmpty ? 'Enter password' : null,
               ),
               const SizedBox(height: 24),
               isLoading 
                 ? const CircularProgressIndicator()
                 : ElevatedButton(
                     onPressed: _login,
                     child: const Text('Login'),
                   ),
               TextButton(
                 onPressed: () => Navigator.pushNamed(context, '/signup'),
                 child: const Text('Don\'t have an account? Sign up'),
               )
             ],
           ),
         ),
      ),
    );
  }
}
