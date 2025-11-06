import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/screens/history/sell_history_screen.dart';
import 'package:my_shop/screens/products/product_list_screen.dart';
import 'package:my_shop/screens/remain/remain_product_list_screen.dart';
import 'package:my_shop/widgets/navigate_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shopie',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: const [
          NavigateCard(
            label: 'Sales',
            subtitle: 'View sales history',
            icon: Icons.point_of_sale,
            page: SellHistoryScreen(),
          ),
          NavigateCard(
            label: 'Products',
            subtitle: 'View all products',
            icon: Icons.receipt_long,
            page: ProductListScreen(),
          ),
          NavigateCard(
            label: 'Remain',
            subtitle: 'View and edit your products',
            icon: Icons.inventory,
            page: RemainProductListScreen(),
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
