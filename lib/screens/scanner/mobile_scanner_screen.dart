import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_shop/providers/barcode_provider.dart';
import 'package:my_shop/screens/receipt/receipt_screen.dart';

enum ScannerMode { receipt, inventory }

class MobileScannerScreen extends ConsumerStatefulWidget {
  final ScannerMode mode;

  const MobileScannerScreen({super.key, this.mode = ScannerMode.receipt});

  @override
  ConsumerState< MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends ConsumerState<MobileScannerScreen> {
    final MobileScannerController _controller = MobileScannerController();
   Barcode? _barcode;
   bool _isTorchOn = false;
   
  
   


  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'စကန် ဖတ်ပါ',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
    }

    return Text(
      value.displayValue ?? 'စကန် ဖတ်ထားသည်များ မရှိပါ',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  bool _isProcessing = false;

  void _handleBarcode(BarcodeCapture barcodes) {
    final value = barcodes.barcodes.isNotEmpty ? barcodes.barcodes.first.displayValue : null;
    if (value == null) return;

    // avoid multiple rapid detections causing multiple navigations/pops
    if (_isProcessing) return;
    _isProcessing = true;

    ref.read(barcodeProvider.notifier).state = value;
    setState(() {
      _barcode = barcodes.barcodes.first;
    });

    // navigate depending on mode
    if (widget.mode == ScannerMode.receipt) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReceiptScreen()),
      );
    } else {
      // inventory mode: pop back to InventoryScreen (it will read the provider)
      Navigator.pop(context);
    }

    // allow handling again after short delay if still mounted
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isProcessing = false;
    });
  }


  // void _handleBarcode(BarcodeCapture barcodes) {
  //   if (mounted) {
  //     setState(() {
  //       _barcode = barcodes.barcodes.firstOrNull;
  //     });
  //   }
  // }

  void _toggleFlashlight() async {
    await _controller.toggleTorch();
    // toggle local state (we don't rely on controller.torchState getter here)
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('QR Code Scanner')),
      backgroundColor: Colors.black,
      body: Stack(
           children: [
        MobileScanner(  
          controller: _controller,
         onDetect: _handleBarcode ,
          fit: BoxFit.cover,
),

        // Barcode Preview at bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            alignment: Alignment.bottomCenter,
            height: 200,
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Center(child: _barcodePreview(_barcode))),
              ],
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: 220, // Just above the barcode preview height (200)
          child: FloatingActionButton(
            mini: true,
            // ignore: deprecated_member_use
            backgroundColor: Colors.white.withOpacity(0.8),
              onPressed: _toggleFlashlight,
              child: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.black,
              ),
          ),
        ),
      ],
       
      ),
    );
  }
}

// Note: removed incorrect torchState extension. MobileScannerController provides
// toggleTorch(); we maintain a local `_isTorchOn` flag for UI.


