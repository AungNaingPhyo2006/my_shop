import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/db/db_helper.dart';
import 'package:my_shop/providers/barcode_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  @override
  void dispose() {
    barcodeController.dispose();
    productNameController.dispose();
    qtyController.dispose();
    buyPriceController.dispose();
    sellPriceController.dispose();
    discountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    final data = {
      'product_name': productNameController.text,
      'barcode': barcodeController.text,
      'qty': int.tryParse(qtyController.text) ?? 0,
      'buy_price': double.tryParse(buyPriceController.text) ?? 0.0,
      'sell_price': double.tryParse(sellPriceController.text) ?? 0.0,
      'discount': double.tryParse(discountController.text) ?? 0.0,
      'remark': remarkController.text,
    };

      // ignore: avoid_print
      // print('Test => $data');
    
    await DBHelper.insertProduct(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product saved to database')),
    );

    _formKey.currentState!.reset();
    productNameController.clear();
    qtyController.clear();
    buyPriceController.clear();
    sellPriceController.clear();
    discountController.clear();
    remarkController.clear();
  }
}

  @override
  Widget build(BuildContext context) {
    final barcodeValue = ref.watch(barcodeProvider);

    if (barcodeValue != null && barcodeController.text.isEmpty) {
    barcodeController.text = barcodeValue;
  }

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Scanned: ${barcodeValue ?? 'No barcode scanned'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildTextField('Barcode', barcodeController),
              _buildTextField('Product Name', productNameController),
              _buildTextField('Quantity', qtyController, isNumber: true),
              _buildTextField('Buy Price', buyPriceController, isDecimal: true),
              _buildTextField('Sell Price', sellPriceController, isDecimal: true),
              _buildTextField('Discount', discountController, isDecimal: true),
              _buildTextField('Remark', remarkController, maxLines: 2),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDecimal = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
