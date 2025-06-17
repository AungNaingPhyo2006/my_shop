import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DBHelper.getProducts();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text('Home Screen'),
  actions: [
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete All'),
            content: const Text('Are you sure you want to delete all products?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await DBHelper.deleteAllProducts();
          await _loadProducts(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All products deleted')),
          );
        }
      },
    ),
  ],
),
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found.'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(product['product_name'] ?? 'Unnamed'),
                        subtitle: Text(
                          'Barcode: ${product['barcode'] ?? '-'}\n'
                          'Qty: ${product['qty']} | Buy: ${product['buy_price']} | Sell: ${product['sell_price']} | Discount: ${product['discount']}',
                        ),
                        isThreeLine: true,
                        trailing: Text(product['remark'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
