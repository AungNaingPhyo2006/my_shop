import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // remote JSON URL
  static const String _url =
      'https://raw.githubusercontent.com/AungNaingPhyo2006/younmeinfo/refs/heads/main/auth/shopUser.json';

  /// Fetch all users from remote JSON.
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final resp = await http.get(Uri.parse(_url));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch users: ${resp.statusCode}');
    }
    final Map<String, dynamic> body = json.decode(resp.body);
    final List users = body['users'] ?? [];
    return users.cast<Map<String, dynamic>>();
  }

  /// Find user matching username and password. Returns null if not found.
  static Future<Map<String, dynamic>?> findUser(
      String username, String password) async {
    final users = await fetchUsers();
      try {
        for (final u in users) {
          final un = (u['userName']?.toString() ?? '');
          final pw = (u['password']?.toString() ?? '');
          if (un == username && pw == password) return u;
        }
        return null;
      } catch (_) {
        return null;
      }
  }

  /// Get latest user data by username (or null).
  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final users = await fetchUsers();
    try {
      return users.firstWhere(
          (u) => (u['userName']?.toString() ?? '') == username);
    } catch (_) {
      return null;
    }
  }
}
