import 'dart:convert';
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
  double givenMoney = 0.0;
  double changeMoney = 0.0;
  final TextEditingController givenMoneyController = TextEditingController();
  
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
    // ✅ Pretty-print in console
    final prettyProducts = const JsonEncoder.withIndent('  ').convert(products);
    debugPrint('Products =>\n$prettyProducts');
  }

  // Calculate total price for all products
  double getTotalPrice() {
    double total = 0;
    for (var product in products) {
      final int qty = (product['quantity_sold'] is int)
          ? product['quantity_sold']
          : int.tryParse(product['quantity_sold'].toString()) ?? 0;
      final double price = (product['sell_price'] is double)
          ? product['sell_price']
          : double.tryParse(product['sell_price'].toString()) ?? 0.0;
      total += qty * price;
    }
    return total;
  }

  // Format date to human readable
  String formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
  String formatPrice(double value) {
    if (value % 1 == 0) {
      // No decimals → show as integer
      return value.toInt().toString();
    } else {
      // Keep decimals if necessary
      return value.toString();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Receipt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: products.isEmpty ? const SizedBox() : const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete All'),
                  content: const Text('Are you sure you want to delete all sales records?'),
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
                  const SnackBar(content: Text('All sales records deleted')),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No sales records found.'))
              : Column(
                  children: [
                    // Receipt Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.deepPurple.withOpacity(0.1),
                      child: Column(
                        children: [
                          Text(
                            'SALES RECEIPT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(products.isNotEmpty ? products.first['sale_date'] : null),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Column Headers
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.grey[200],
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Price',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'SubTotal',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Products List
                    Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final int qty = (product['quantity_sold'] is int)
                              ? product['quantity_sold']
                              : int.tryParse(product['quantity_sold'].toString()) ?? 0;
                          final double unitPrice = (product['sell_price'] is double)
                              ? product['sell_price']
                              : double.tryParse(product['sell_price'].toString()) ?? 0.0;
                          final double subTotal = qty * unitPrice;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [                            
                                // Product Name
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    product['product_name'] ?? 'Unnamed Product',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                // Quantity
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    qty.toString(),
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
                                // Unit Price
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatPrice(unitPrice),
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                
                                // Sub Total
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatPrice(subTotal),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.deepPurple.withOpacity(0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatPrice(totalPrice),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 💰 Input for Buyer Money
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Buyer Money',
                            hintText: 'Enter amount buyer gives (e.g. 20000)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.payments),
                          ),
                          onChanged: (value) {
                            final entered = double.tryParse(value) ?? 0.0;
                            setState(() {
                              givenMoney = entered;
                              changeMoney = givenMoney - totalPrice;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // 🧮 Show Change
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Change:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              changeMoney.isNegative
                                  ? 'Insufficient Money'
                                  : formatPrice(changeMoney),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: changeMoney.isNegative ? Colors.red : Colors.green[800],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            debugPrint('============================');
                            debugPrint('📦 SALES RECEIPT DATA');
                            debugPrint('Date: ${formatDate(products.isNotEmpty ? products.first['sale_date'] : null)}');
                            debugPrint('---------------------------------');
                            for (var product in products) {
                              final int qty = (product['quantity_sold'] is int)
                                  ? product['quantity_sold']
                                  : int.tryParse(product['quantity_sold'].toString()) ?? 0;
                              final double unitPrice = (product['sell_price'] is double)
                                  ? product['sell_price']
                                  : double.tryParse(product['sell_price'].toString()) ?? 0.0;
                              final double subTotal = qty * unitPrice;
                              debugPrint(
                                  'Name: ${product['product_name']} | Qty: $qty | Price: $unitPrice | Subtotal: $subTotal');
                            }
                            debugPrint('---------------------------------');
                            debugPrint('TOTAL: $totalPrice');
                            debugPrint('Buyer Money: $givenMoney');
                            debugPrint('Change: $changeMoney');
                            debugPrint('============================');
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ],
                ),
    );
  }
}