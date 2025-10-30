import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_shop/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, Map<String, dynamic>?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<Map<String, dynamic>?> {
  AuthNotifier() : super(null);

  Future<String> login(String username, String password, {bool remember = false}) async {
  // Find user by username
  final user = await AuthService.getUserByUsername(username);

  if (user == null) {
    return 'invalid_username';
  }

  // Check if banned
  if ((user['isBanned'] ?? false) == true) {
    return 'banned';
  }

  // Validate password
  if (user['password'] != password) {
    return 'invalid_password';
  }

  // Success
  state = user;

  if (remember) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  }

  return 'success';
}

  Future<void> logout({bool clearSaved = false}) async {
    state = null;
    if (clearSaved) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  Future<Map<String, dynamic>?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('saved_username');
    final password = prefs.getString('saved_password');
    if (username == null || password == null) return null;

    final matched = await AuthService.findUser(username, password);
    if (matched == null) return null;
    if ((matched['isBanned'] ?? false) == true) return null;

    state = matched;
    return matched;
  }

  Future<bool> isUserBannedRemotely() async {
    if (state == null) return false;
    final username = state!['userName']?.toString() ?? '';
    final remote = await AuthService.getUserByUsername(username);
    if (remote == null) return false; // can't determine
    return (remote['isBanned'] ?? false) == true;
  }
}
