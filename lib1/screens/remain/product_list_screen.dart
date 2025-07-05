import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListState();
}

class _ProductListState extends State<ProductListScreen> {
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
    title: const Text('Remain list', style: TextStyle(
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
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(product['product_name'] ?? 'Unnamed'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Barcode: ${product['barcode'] ?? '-'}\n'
                              'Qty: ${product['qty']} | Buy: ${product['buy_price']} | Sell: ${product['sell_price']} | Discount: ${product['discount']}',
                            ),
                            if (product['qty'] == 0 || product['qty'].toString() == '0')
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  '⚠️ Out of stock!',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
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
