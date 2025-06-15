import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/providers/barcode_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      final barcodeValue = ref.watch(barcodeProvider);
      
    return Center(
      child: Text(barcodeValue ?? 'No barcode scanned', style: const TextStyle(fontSize: 24))
    );
  }
}