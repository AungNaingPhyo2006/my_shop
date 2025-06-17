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
   appBar: AppBar(title: const Text('ကုန်ပစ္စည်း စာရင်းသွင်းခြင်း',style: TextStyle(
    color: Colors.white, 
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '✅ ${barcodeValue != null ? 'ကုန်ပစ္စည်း အချက်အလက်များ ရိုက်ထည့်ပါ။': 'ဘားကုဒ် စကန် မဖတ်ရသေးပါ။'}',
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 16),
              _buildTextField('ဘားကုဒ်', barcodeController),
              _buildTextField('ကုန်ပစ္စည်းအမည်', productNameController),
              _buildTextField('အရေအတွက်', qtyController, isNumber: true),
              _buildTextField('၀ယ်စျေး', buyPriceController, isDecimal: true),
              _buildTextField('ရောင်းစျေး', sellPriceController, isDecimal: true),
              _buildTextField('လျှော့စျေး', discountController, isDecimal: true),
              _buildTextField('မှတ်ချက်', remarkController, maxLines: 2),
              const SizedBox(height: 24),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add scan logic
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 161, 214, 189),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 71, 6, 211),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  
                ],
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isDecimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? '⚠️ $label ရိုက်ထည့်ပါ။' : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
