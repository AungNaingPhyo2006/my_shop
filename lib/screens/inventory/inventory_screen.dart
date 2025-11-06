import 'package:flutter/material.dart';
import 'package:my_shop/bottomNavigation/main_navigator.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ကုန်ပစ္စည်း စာရင်းသွင်းခြင်း',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigator()),
            );
          },
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: const SizedBox.shrink(), // Empty body
    );
  }
}
