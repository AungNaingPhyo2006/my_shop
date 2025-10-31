import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/screens/auth/login_screen.dart';

Future<void> checkBannedStatus({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final notifier = ref.read(authProvider.notifier);
  final isBanned = await notifier.isUserBannedRemotely();

  if (isBanned) {
    await notifier.logout(clearSaved: true);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
