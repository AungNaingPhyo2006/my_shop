import 'package:flutter/material.dart';
import 'package:my_shop/screens/scanner/mobile_scanner_screen.dart';
import 'package:my_shop/widgets/navigate_card.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'My Shop',
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.blueAccent,
      //   elevation: 0,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: const [
              SizedBox(height: 20),
               NavigateCard(
                label: 'စကန်နာ',
                subtitle:
                    'ကုန်ပစ္စည််း၏ ဘားကုဒ် သို့မဟုတ် QR ကုဒ်ကို  ဖတ်ရန်။',
                page: MobileScannerScreen(),
                icon: Icons.qr_code_scanner,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
