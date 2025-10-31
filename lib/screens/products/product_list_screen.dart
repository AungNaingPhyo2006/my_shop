import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
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
      filteredProducts = data; // ✅ Show all products initially
      isLoading = false;
    });
  }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // ✅ When search box is cleared, show all again
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          final productName = (product['product_name'] ?? '').toString().toLowerCase();
          final remark = (product['remark'] ?? '').toString().toLowerCase();
          return productName.contains(lowerQuery) || remark.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Search Bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by product name or remark...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.deepPurple.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterProducts,
                  ),
                ),

                // 🧾 Product List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('No products found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              color: Colors.deepPurple.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name
                                    Text(
                                      product['product_name'] ?? 'Unnamed Product',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Barcode
                                    _buildInfoRow('Barcode', product['barcode'] ?? '-'),

                                    const Divider(height: 16, color: Colors.deepPurpleAccent),

                                    // Quantities
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoItem('Available', '${product['current_qty']}'),
                                        _buildInfoItem('Sold', '${product['sold_qty']}'),
                                        _buildInfoItem('Total', '${product['total_qty']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Price and Discount
                                    _buildInfoRow('Sell Price', '${product['sell_price']} Ks'),
                                    _buildInfoRow('Discount', '${product['discount']} %'),

                                    const SizedBox(height: 12),

                                    // Remark (optional)
                                    if ((product['remark'] ?? '').isNotEmpty)
                                      _buildInfoRow('Remark', product['remark']),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}
