import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class RemainListScreen extends StatefulWidget {
  const RemainListScreen({super.key});

  @override
  State<RemainListScreen> createState() => _RemainListScreenState();
}

class _RemainListScreenState extends State<RemainListScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DBHelper.getTotalProductWithSales();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: const Text('Product list', style: TextStyle(
    color: Colors.white, 
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),),
   backgroundColor: Colors.deepPurple,
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
                          'Qty (Available): ${product['current_qty']}|Qty (Sold): ${product['sold_qty']} |Qty (Total): ${product['total_qty']} | Sell Price: ${product['sell_price']} | Discount: ${product['discount']}',
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
