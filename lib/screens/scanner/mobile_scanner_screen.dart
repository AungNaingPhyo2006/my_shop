import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerScreen extends StatefulWidget {
  const  MobileScannerScreen({super.key});

  @override
  State< MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State< MobileScannerScreen> {
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

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
    }
  }

   void _toggleFlashlight() async {
    await _controller.toggleTorch();
    final torchState = await _controller.torchState;
    setState(() {
      _isTorchOn = torchState == TorchState.on;
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

extension on MobileScannerController {
  get torchState => null;
}


