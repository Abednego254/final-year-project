import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                user?.name ?? 'Farmer User',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              _buildProfileOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {},
              ),
              _buildProfileOption(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: Text('Log Out', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
