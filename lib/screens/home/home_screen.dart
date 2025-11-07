import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/screens/history/sell_history_screen.dart';
import 'package:my_shop/screens/products/product_list_screen.dart';
import 'package:my_shop/screens/remain/remain_product_list_screen.dart';
import 'package:my_shop/widgets/grib_nav_button.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,                 // ✅ 4 buttons per row
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            GridNavButton(
              label: "Sales",
              icon: Icons.point_of_sale,
              page: SellHistoryScreen(),
            ),
            GridNavButton(
              label: "Products",
              icon: Icons.receipt_long,
              page: ProductListScreen(),
            ),
            GridNavButton(
              label: "Remain",
              icon: Icons.inventory,
              page: RemainProductListScreen(),
            ),
            GridNavButton(
              label: "Settings",
              icon: Icons.settings,
              page: ProductListScreen(),
            ),
            
          ],
        ),
      ),
    );
  }
}
