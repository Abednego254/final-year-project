import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'farmer'; // default role
  final _formKey = GlobalKey<FormState>();

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _role,
      );
      if (mounted) {
        Navigator.pop(context); // Pop back so consumer shows home on auth status update
      }
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                 controller: _nameController,
                 decoration: const InputDecoration(labelText: 'Full Name'),
                 validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                 controller: _emailController,
                 decoration: const InputDecoration(labelText: 'Email'),
                 validator: (val) => val!.isEmpty ? 'Enter email' : null,
                 keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                 controller: _phoneController,
                 decoration: const InputDecoration(labelText: 'Phone'),
                 validator: (val) => val!.isEmpty ? 'Enter phone' : null,
                 keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                 controller: _passwordController,
                 decoration: const InputDecoration(labelText: 'Password'),
                 obscureText: true,
                 validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                  DropdownMenuItem(value: 'operator', child: Text('Tractor Operator')),
                ],
                onChanged: (val) => setState(() => _role = val!),
              ),
              const SizedBox(height: 24),
              isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
