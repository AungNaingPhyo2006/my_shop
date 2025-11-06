import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellHistoryScreen extends ConsumerStatefulWidget {
  const SellHistoryScreen({super.key});

  @override
  ConsumerState<SellHistoryScreen> createState() => _SellHistoryScreenState();
}

class _SellHistoryScreenState extends ConsumerState<SellHistoryScreen> {
  String inputValue = '';

  void onKeyPressed(String value) {
    setState(() {
      if (value == 'C') {
        inputValue = '';
      } else if (value == '<') {
        if (inputValue.isNotEmpty) {
          inputValue = inputValue.substring(0, inputValue.length - 1);
        }
      } else {
        inputValue += value;
      }
    });
  }

  void onEnterPressed() {
    debugPrint("Entered value: $inputValue");
    // TODO: Add DB logic here
    setState(() {
      inputValue = ''; // Clear input after enter pressed
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> defaultKeys = [
      '7', '8', '9',
      '4', '5', '6',
      '1', '2', '3',
      'C', '0', '<',
    ];

    final List<String> extraKeys = [
      'အပူး',
      'အခွေ',
      'ပါဝါ',
      'နက္ခတ်',
      'ညီကို',
      'ဆယ်ပြည့်',
      'ဆယ်ပွင့်',
      'မမ ရိုးရိုး',
      'မမ အပူး',
      'စုံစုံ ရိုးရိုး',
      'အပူးပါ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Receipt',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // ===== 1. Sell history section =====
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text('Item ${index + 1}'),
                            subtitle:
                                Text('Qty: ${index + 2} | Price: \$${(index + 1) * 5}'),
                            trailing:
                                Text('\$${(index + 1) * (index + 2) * 5}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== 2. Calculator section =====
          Expanded(
            flex: 2,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  children: [
                    // Display + ENTER Button Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Text(
                                inputValue,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ENTER Button added here
                        ElevatedButton(
                          onPressed: onEnterPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(80, 60),  // Button size
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "ENTER",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.3,
                        children: [
                          for (var key in defaultKeys)
                            ElevatedButton(
                              onPressed: () => onKeyPressed(key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          for (var myKey in extraKeys)
                            ElevatedButton(
                              onPressed: () => onKeyPressed(myKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                myKey,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
