import 'package:flutter/material.dart';
import 'package:my_shop/screens/products/product_list_screen.dart';
import 'package:my_shop/widgets/navigate_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(title: const Text('My Shopie',style: TextStyle(
    color: Colors.white, 
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),), backgroundColor: Colors.deepPurple),
      body: ListView(
        children: const [
          NavigateCard(
            label: 'Products',
            subtitle: 'View and edit your products',
            icon: Icons.person,
            page: ProductListScreen(),
          ),
          NavigateCard(
            label: 'Settings',
            subtitle: 'Configure the app settings',
            icon: Icons.settings,
            page: ProductListScreen(),
          ),
        ],
      ),
    );
  }
}