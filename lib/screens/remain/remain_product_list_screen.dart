import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class RemainProductListScreen extends StatefulWidget {
  const RemainProductListScreen({super.key});

  @override
  State<RemainProductListScreen> createState() => _ProductListState();
}

class _ProductListState extends State<RemainProductListScreen> {
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

  Future<void> _deleteProduct(int id) async {
    await DBHelper.deleteProduct(id);
    await _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    final TextEditingController nameController =
        TextEditingController(text: product['product_name']);
    final TextEditingController qtyController =
        TextEditingController(text: product['qty'].toString());
    final TextEditingController buyPriceController =
        TextEditingController(text: product['buy_price'].toString());
    final TextEditingController sellPriceController =
        TextEditingController(text: product['sell_price'].toString());
    final TextEditingController discountController =
        TextEditingController(text: product['discount'].toString());
    final TextEditingController remarkController =
        TextEditingController(text: product['remark'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(nameController, 'Product Name'),
                _buildTextField(qtyController, 'Quantity', isNumber: true),
                _buildTextField(buyPriceController, 'Buy Price', isNumber: true),
                _buildTextField(sellPriceController, 'Sell Price', isNumber: true),
                _buildTextField(discountController, 'Discount', isNumber: true),
                _buildTextField(remarkController, 'Remark'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        qtyController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    final updatedData = {
                      'product_name': nameController.text.trim(),
                      'qty': int.tryParse(qtyController.text) ?? 0,
                      'buy_price': double.tryParse(buyPriceController.text) ?? 0.0,
                      'sell_price': double.tryParse(sellPriceController.text) ?? 0.0,
                      'discount': double.tryParse(discountController.text) ?? 0.0,
                      'remark': remarkController.text.trim(),
                    };

                    await DBHelper.updateProduct(product['barcode'], updatedData);
                    Navigator.pop(ctx);
                    await _loadProducts();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Product updated successfully')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F4F4),
    appBar: AppBar(
      title: const Text(
        'Remaining Products',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple,
      centerTitle: true,
      elevation: 4,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
        : products.isEmpty
            ? const Center(
                child: Text(
                  'No products found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadProducts,
                color: Colors.deepPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: products.map((product) {
                      final bool outOfStock = product['qty'] == 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product['product_name'] ?? 'Unnamed',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: outOfStock
                                          ? Colors.redAccent
                                          : Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                if (outOfStock)
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.red, size: 22),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _infoRow('Barcode', product['barcode'] ?? '-'),
                            _infoRow('Quantity', '${product['qty']}'),
                            _infoRow('Buy Price', '${product['buy_price']}'),
                            _infoRow('Sell Price', '${product['sell_price']}'),
                            _infoRow('Discount', '${product['discount']}'),
                            if (product['remark'] != null &&
                                product['remark'].toString().isNotEmpty)
                              _infoRow('Remark', product['remark']),
                            const Divider(height: 22, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _editProduct(product),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit',  style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete',  style: TextStyle(color: Colors.white),),
                                        content: Text(
                                          'Are you sure you want to delete "${product['product_name']}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                ),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text(
                                                  'Delete',
                                                  style: TextStyle(color: Colors.white), 
                                                ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _deleteProduct(product['id']);
                                    }
                                  },
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete',  style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
  );
}

/// Helper for info rows
Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

}
