import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/bottomNavigation/main_navigator.dart';
import 'package:my_shop/db/db_helper.dart';
import 'package:my_shop/providers/barcode_provider.dart';
import 'package:my_shop/screens/inventory/inventory_screen.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key});

  @override
 ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
   Map<String, dynamic>? matchedProduct;
  bool isLoading = true;
  String message = "";

  @override
  void initState() {
    super.initState();
    _processSale();
  }

Future<void> _processSale() async {
  final barcodeValue = ref.read(barcodeProvider);

  if (barcodeValue == null || barcodeValue.isEmpty) {
    setState(() {
      isLoading = false;
      message = "❌ No barcode scanned.";
    });
    return;
  }

  final db = await DBHelper.database;

  final List<Map<String, dynamic>> result = await db.query(
    'products',
    where: 'barcode = ?',
    whereArgs: [barcodeValue],
  );
//Product ထည့်ထားပြီးသား မရှိရင် 
  if (result.isNotEmpty) {
    final product = result.first;
    setState(() {
      matchedProduct = product;
      isLoading = false;
      message = product['qty'] > 0
          ? "✅ Product is ready for sale."
          : "❌ Product is out of stock.";
    });
  } else {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InventoryScreen()),
      );
    });
    setState(() {
      matchedProduct = null;
      isLoading = false;
      message = "❌ No product found with this barcode.";
    });
  }
}

Future<void> _handleSaveAndExit() async {
  final db = await DBHelper.database;
  final barcodeValue = ref.read(barcodeProvider);

  if (matchedProduct == null || barcodeValue == null || barcodeValue.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No valid product to save.")),
    );
     Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigator()),
  );
    return;
  }

  final int currentQty = matchedProduct!['qty'];
  final int productId = matchedProduct!['id'];

  if (currentQty <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product is out of stock.")),
    );
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigator()),
  );
    return;
  }

  final int newQty = currentQty - 1;

  // Update product qty
  await db.update(
    'products',
    {'qty': newQty},
    where: 'id = ?',
    whereArgs: [productId],
  );

  // Insert into sales table
  await db.insert('sales', {
    'product_id': productId,
    'product_name': matchedProduct!['product_name'],
    'barcode': barcodeValue,
    'sell_price': matchedProduct!['sell_price'],
    'discount': matchedProduct!['discount'],
    'remark': matchedProduct!['remark'],
    'quantity_sold': 1,
    'sale_date': DateTime.now().toIso8601String(),
  });

  // Show confirmation and navigate
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Sale saved successfully.")),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigator()),
  );
}

 @override
Widget build(BuildContext context) {
  final barcodeValue = ref.watch(barcodeProvider);

  if (isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  if (matchedProduct == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Info",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'ကုန်ပစ္စည်း အရောင်း',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 0,
    ),

    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          /// ✅ Barcode Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "✅ Scanned: ${barcodeValue ?? 'NO BARCODE'}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 18),

          /// ✅ Product Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _productInfo("📦 Product", matchedProduct!['product_name']),
                  _productInfo("🔖 Barcode", matchedProduct!['barcode']),
                  _productInfo("📦 Quantity", matchedProduct!['qty'].toString()),
                  _productInfo("💰 Buy Price", matchedProduct!['buy_price'].toString()),
                  _productInfo("💵 Sell Price", matchedProduct!['sell_price'].toString()),
                  _productInfo("🏷 Discount", matchedProduct!['discount'].toString()),
                  _productInfo("📝 Remark", matchedProduct!['remark'] ?? "-"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ✅ Stock Status
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: matchedProduct!['qty'] > 0 ? Colors.green : Colors.red,
            ),
          ),

          const Spacer(),

          /// ✅ Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSaveAndExit,
              icon: const Icon(Icons.save),
              label: const Text(
                "Save and Exit",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// ✅ Product label + value widget
Widget _productInfo(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    ),
  );
}

}