import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/screens/history/sell_history_screen.dart';
import 'package:my_shop/screens/remain/product_list_screen.dart';
import 'package:my_shop/screens/products/remain_list_screen.dart';
import 'package:my_shop/widgets/navigate_card.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/screens/auth/login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkBannedStatus();
  }

  Future<void> _checkBannedStatus() async {
    // If current user is banned remotely, log them out and redirect to login
    final notifier = ref.read(authProvider.notifier);
    final isBanned = await notifier.isUserBannedRemotely();
    if (isBanned && mounted) {
      await notifier.logout(clearSaved: true);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

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
            subtitle: 'View remain products',
            icon: Icons.receipt_long,
            page: RemainListScreen(),
          ),
          NavigateCard(
            label: 'Remain',
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