import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';
import 'package:intl/intl.dart';

class ProfitScreen extends StatefulWidget {
  const ProfitScreen({super.key});

  @override
  State<ProfitScreen> createState() => _ProfitScreenState();
}

class _ProfitScreenState extends State<ProfitScreen> {
  DateTime? _selectedDate;


  // Fetch sales summary, optionally filtered by date
  Future<List<Map<String, dynamic>>> _fetchSalesSummary({String? selectedDate}) async {
    final db = await DBHelper.database;

    if (selectedDate != null) {
      // Filter by date (match YYYY-MM-DD)
      return await db.query(
        'sales_summary',
        where: 'sale_date LIKE ?',
        whereArgs: ['$selectedDate%'],
        orderBy: 'sale_date DESC',
      );
    }

    return await db.query('sales_summary', orderBy: 'sale_date DESC');
  }

  // Format ISO date to readable string
  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  // Format price to show integer if possible
  String _formatPrice(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  // Open calendar to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _deleteAllSalesSummary() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete all sales summary data?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await DBHelper.database.then((db) => db.delete('sales_summary'));
    setState(() {
      // Refresh the list after deletion
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All sales summary data deleted')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _pickDate(context),
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
            ),
        ],
      ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchSalesSummary(
            selectedDate: _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : null,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sales data available.'));
            }

            final salesSummary = snapshot.data!;

            // Group by sale_date
            final Map<String, List<Map<String, dynamic>>> groupedData = {};
            for (var item in salesSummary) {
              final date = _formatDate(item['sale_date']);
              groupedData.putIfAbsent(date, () => []).add(item);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: groupedData.entries.map((entry) {
                      final date = entry.key;
                      final items = entry.value;
                      final totalAmount = items.fold<double>(
                          0, (sum, item) => sum + (item['total_sale_amount'] ?? 0));

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _formatPrice(totalAmount),
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // List of products
                              ...items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(item['product_name'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Text('${item['quantity_sold'] ?? 0} pcs',
                                              textAlign: TextAlign.center)),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              _formatPrice(
                                                  item['unit_price']?.toDouble() ?? 0),
                                              textAlign: TextAlign.right)),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              _formatPrice(
                                                  item['subtotal']?.toDouble() ?? 0),
                                              textAlign: TextAlign.right)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Delete All Button at bottom
                Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Clear',style: TextStyle(color: Colors.white ),),
                    onPressed: _deleteAllSalesSummary,
                  ),
                ),
              ],
            );
          },
        ),

    );
  }
}
