import 'package:flutter/material.dart';
import 'package:my_shop/screens/history/sell_history_screen.dart';
import 'package:my_shop/screens/remain/product_list_screen.dart';
import 'package:my_shop/screens/products/remain_list_screen.dart';
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
            subtitle: 'View remain products',
            icon: Icons.receipt_long,
            page: RemainListScreen(),
          ),
          NavigateCard(
            label: 'Sales',
            subtitle: 'View sales history',
            icon: Icons.point_of_sale,
            page: SellHistoryScreen(),
          ),
         
           NavigateCard(
            label: 'Remain',
            subtitle: 'View and edit your products',
            icon: Icons.person,
            page:ProductListScreen(),
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