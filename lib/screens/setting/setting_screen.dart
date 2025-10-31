import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/providers/barcode_provider.dart';
import 'package:my_shop/screens/auth/login_screen.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_shop/services/locale_service.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(ctx)!.logout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppLocalizations.of(ctx)!.logoutConfirmation),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.logout),
          ),
        ],
      ),
    );

    if (result == true) {
      // Clear important app state (scanned barcode) on logout
      try {
        ref.read(barcodeProvider.notifier).state = null;
      } catch (_) {}

      // Clear saved credentials (if any) and navigate to Login
      try {
        ref.read(authProvider.notifier).logout(clearSaved: true);
      } catch (_) {}

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final displayName = user?['userName']?.toString() ?? 'Casher';
    final displayRole = user?['roleName']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayRole.isNotEmpty ? displayRole : '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Options Section
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.blue),
                    title: Text(AppLocalizations.of(context)!.appSettings),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.orange),
                    title: Text(AppLocalizations.of(context)!.aboutApp),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.green),
                    title: Text(AppLocalizations.of(context)!.changeLanguage),
                    onTap: () async {
                      final selectedLocale = await showDialog<Locale>(
                        context: context,
                        builder: (_) => SimpleDialog(
                          title: Text(AppLocalizations.of(context)!.selectLanguage),
                          children: [
                            SimpleDialogOption(
                              child: const Text('English'),
                              onPressed: () => Navigator.pop(context, const Locale('en')),
                            ),
                            SimpleDialogOption(
                              child: const Text('မြန်မာ'),
                              onPressed: () => Navigator.pop(context, const Locale('my')),
                            ),
                          ],
                        ),
                      );

                      if (selectedLocale != null) {
                        // Persist and update global app locale notifier so MaterialApp rebuilds
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('locale', selectedLocale.languageCode);
                        } catch (_) {}
                        appLocale.value = selectedLocale;
                      }
                    },
                  ),

                  const Divider(height: 1),
                ],
              ),
            ),

            // Logout Button
                  Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
