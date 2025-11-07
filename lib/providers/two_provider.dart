import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final twoDProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final res = await http.get(Uri.parse("https://api.thaistock2d.com/live"));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception("Failed to load data");
    }
  } catch (e) {
    return {}; // ✅ Prevent loading freeze, return empty if error
  }
});
