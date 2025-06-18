import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class SellHistoryScreen extends StatefulWidget {
  const SellHistoryScreen({super.key});

  @override
  State<SellHistoryScreen> createState() => _SellHistoryScreenState();
}

class _SellHistoryScreenState extends State<SellHistoryScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

 Future<void> _loadProducts() async {
  final rawData = await DBHelper.getSales();

  // Group by barcode and product_name and sum quantity_sold
  final Map<String, Map<String, dynamic>> grouped = {};

  for (var item in rawData) {
    final key = '${item['barcode']}_${item['product_name']}';

    // Ensure quantity_sold is treated as int
    final int qty = (item['quantity_sold'] is int)
        ? item['quantity_sold']
        : int.tryParse(item['quantity_sold'].toString()) ?? 0;

    if (grouped.containsKey(key)) {
      grouped[key]!['quantity_sold'] += qty;
    } else {
      final Map<String, dynamic> newItem = Map<String, dynamic>.from(item);
      newItem['quantity_sold'] = qty;
      grouped[key] = newItem;
    }
  }

  setState(() {
    products = grouped.values.toList();
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: const Text('Sales History', style: TextStyle(
    color: Colors.white, 
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),),
   backgroundColor: Colors.deepPurple,
  actions: [
     IconButton(
      icon:  products.isEmpty  ?const SizedBox(): const Icon(Icons.delete,color: Colors.white) ,
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
          await DBHelper.deleteSales();
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
  color: Colors.grey[100],
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['product_name'] ?? 'Unnamed',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.qr_code, size: 16, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text('Barcode: ${product['barcode']}'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text('Qty: ${product['quantity_sold']}'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Price: ${product['sell_price']}'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.percent, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('Discount: ${product['discount']}'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          product['sale_date'] ?? '',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ),
  ),
);
                  },
                ),
    );
  }
}
