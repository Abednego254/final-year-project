import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/translations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final lang = user?.language ?? 'en';

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(Translations.get('settings', lang))),
        body: const Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final isDark = user.darkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(Translations.get('settings', lang), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader(Translations.get('preferences', lang), isDark),
              _buildDropdownTile(
                title: Translations.get('language', lang),
                subtitle: user.language == 'en' ? 'English' : 'Swahili',
                icon: Icons.language,
                value: user.language,
                items: [
                  {'label': 'English', 'value': 'en'},
                  {'label': 'Swahili', 'value': 'sw'},
                ],
                onChanged: (val) => auth.updateSettings(language: val),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: Translations.get('dark_mode', lang),
                subtitle: lang == 'en' ? 'Reduce eye strain' : 'Punguza mwangaza',
                icon: Icons.dark_mode_outlined,
                value: user.darkMode,
                onChanged: (val) => auth.updateSettings(darkMode: val),
                isDark: isDark,
              ),
              const Divider(height: 40),
              _buildSectionHeader(Translations.get('notifications', lang), isDark),
              _buildSwitchTile(
                title: Translations.get('push_notifications', lang),
                subtitle: lang == 'en' ? 'Real-time updates' : 'Arifa za papo hapo',
                icon: Icons.notifications_active_outlined,
                value: user.pushNotifications,
                onChanged: (val) => auth.updateSettings(pushNotifications: val),
                isDark: isDark,
              ),
              _buildSwitchTile(
                title: Translations.get('sms_alerts', lang),
                subtitle: lang == 'en' ? 'Booking updates via text' : 'Arifa za maagizo kupitia SMS',
                icon: Icons.sms_outlined,
                value: user.smsAlerts,
                onChanged: (val) => auth.updateSettings(smsAlerts: val),
                isDark: isDark,
              ),
              const Divider(height: 40),
              _buildSectionHeader(Translations.get('payment', lang), isDark),
              _buildActionTile(
                title: Translations.get('mpesa_number', lang),
                subtitle: user.phone,
                icon: Icons.account_balance_wallet_outlined,
                onTap: () {},
                isDark: isDark,
              ),
              const Divider(height: 40),
              _buildSectionHeader(Translations.get('account', lang), isDark),
              _buildActionTile(
                title: Translations.get('security', lang),
                subtitle: lang == 'en' ? 'Password and privacy' : 'Nywila na faragha',
                icon: Icons.security_outlined,
                onTap: () {},
                isDark: isDark,
              ),
              _buildActionTile(
                title: Translations.get('about', lang),
                subtitle: 'Version 1.0.2',
                icon: Icons.info_outline,
                onTap: () {},
                isDark: isDark,
              ),
            ],
          ),
          if (auth.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Colors.green)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.green.shade400 : Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? Colors.green.shade400 : Colors.green.shade700),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green.shade700,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? Colors.green.shade400 : Colors.green.shade700),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black87),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!, style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black87)),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? Colors.green.shade400 : Colors.green.shade700),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white : Colors.black87),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
