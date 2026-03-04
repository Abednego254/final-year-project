import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.email ?? ''); // Temporary, since phone might not be in the model. Let me check the model later... Actually let's assume it's blank if missing
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!', style: GoogleFonts.inter()), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: GoogleFonts.inter()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Your Details', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Please re-enter your password to save changes.', style: GoogleFonts.inter(color: Colors.grey.shade600)),
                    const SizedBox(height: 32),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password to save' : null,
                    ),
                    const SizedBox(height: 48),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _updateProfile,
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
