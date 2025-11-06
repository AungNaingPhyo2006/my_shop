import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellHistoryScreen extends ConsumerStatefulWidget {
  const SellHistoryScreen({super.key});

  @override
  ConsumerState<SellHistoryScreen> createState() => _SellHistoryScreenState();
}

class _SellHistoryScreenState extends ConsumerState<SellHistoryScreen> {
  String inputValue = '';
  String? selectedExtraKey; // ✅ store the selected extraKey
  List<String> historyData = []; // ✅ store entered history to show in list

  void onKeyPressed(String value, ) {
    setState(() {
      if (value == 'C') {
        inputValue = '';
        selectedExtraKey = null;
      } else if (value == '<') {
        if (inputValue.isNotEmpty) {
          inputValue = inputValue.substring(0, inputValue.length - 1);
        }
      } else {
          inputValue += value;
          debugPrint('inputValue=> $inputValue');
      }
    });
  }

  void onEnterPressed() {
    if (inputValue.isEmpty) {
      // ❌ Alert when trying to enter empty
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Warning"),
          content: const Text("No entered value."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    // ✅ Save to history
    setState(() {
      historyData.add(inputValue);
      inputValue = '';
      selectedExtraKey = null;
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
                  const Text(
                    "Sell History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(historyData[index]),
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
                child: Column(
                  children: [
                    // ✅ Display + ENTER Button Row
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

                        ElevatedButton(
                          onPressed: onEnterPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(80, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("ENTER", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ✅ KEYPAD Grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.25,
                        children: [
                          // ✅ Numeric keys
                          for (var key in defaultKeys)
                            ElevatedButton(
                              onPressed: () => onKeyPressed(key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(key,
                                  style: const TextStyle(
                                      fontSize: 22, color: Colors.white)),
                            ),

                          // ✅ Myanmar keys (only ONE selection allowed)
                          for (var myKey in extraKeys)
                            ElevatedButton(
                              onPressed: () => onKeyPressed(myKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    selectedExtraKey == myKey ? Colors.red : Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                myKey,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
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
