import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ThreeDSellHistoryScreen extends ConsumerStatefulWidget {
  const ThreeDSellHistoryScreen({super.key});

  @override
  ConsumerState<ThreeDSellHistoryScreen> createState() => _SellHistoryScreenState();
}

class _SellHistoryScreenState extends ConsumerState<ThreeDSellHistoryScreen> {
  bool isSending = false;
  String inputValue = '';
  String? selectedExtraKey; // ✅ store the selected extraKey
  List<Map<String, String>> historyData = []; // ✅ store entered history to show in list
  bool isBlockedTime() {
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;

  const start = 15 * 60 + 58; // 03:58 PM → minutes
  const end   = 16 * 60 + 1;  // 04:01 PM → minutes
  return currentMinutes >= start && currentMinutes <= end;
}

  // ===== Split category & number =====

  final List<String> defaultKeys = [
      '7', '8', '9',
      '4', '5', '6',
      '1', '2', '3',
      'ရှင်း', '0', 'ဖျက်',
       '@', 'R', '=',
    ];

  String convertDisplay(String input) {
    input = input.replaceAll(" ", "");
    List<String> parts = input.split("@");

    List<String> results = [];
    int? lastAmount;

    for (var part in parts) {
      bool isR = part.contains("R");
      part = part.replaceAll("R", "");

      if (part.contains("=")) {
        var sp = part.split("=");
        if (sp.length == 2) {
          String number = sp[0];
          int amount = int.tryParse(sp[1]) ?? 0;
          lastAmount = amount;

          if (isR) {
            int total = amount * 2;
            results.add("$number(R) = $amount  (Total: $total)");
          } else {
            results.add("$number = $amount");
          }
          continue;
        }
      }

      // ✅ if "=" not included, use last known amount
      if (lastAmount != null) {
        if (isR) {
          int total = lastAmount * 2;
          results.add("$part(R) = $lastAmount  (Total: $total)");
        } else {
          results.add("$part = $lastAmount");
        }
      }
    }

    return results.join("\n");
  }


// ✅ CLEAN onKeyPressed (no extraKeys logic)
  void onKeyPressed(String value) {
    setState(() {
      if (value == 'ရှင်း') {
        inputValue = '';
      } else if (value == 'ဖျက်') {
        if (inputValue.isNotEmpty) {
          inputValue = inputValue.substring(0, inputValue.length - 1);
        }
      } else {
        inputValue += value;
      }
    });
  }

void onEnterPressed() {
  if (inputValue.isEmpty) {
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

  setState(() {
    historyData.add({
      "input": inputValue,             // ✅ store original for editing
      "display": convertDisplay(inputValue), // ✅ formatted display
    });

    inputValue = '';
  });
}

  Future<void> sendHistoryToTelegram() async {

      // 🚫 BLOCK time check
    if (isBlockedTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⛔ Upload is not allowed between 03:58 PM and 04:01 PM"),
          backgroundColor: Colors.red,
        ),
      );
      return; // ❗ stop function
    }
    
    const String telegramBotToken = '7653380321:AAEKzt7QotYRqB36rKBaYsID3pIKFhGizGU';
    const String chatId = '5613994162';

    if (historyData.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ No history to send!")),
    );
    return;
  }

    setState(() => isSending = true); // ✅ show loading

    // Build message
    final now = DateTime.now();
    final formattedTime = "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final StringBuffer text = StringBuffer();
    text.writeln("📦 *Sales Session Report*");
    text.writeln("🕒 *Date/Time:* `$formattedTime`");
    text.writeln("--------------------");

    for (var item in historyData) {
      text.writeln("• ${item["display"]}");
    }

    text.writeln("--------------------");
    text.writeln("✅ Total Items: ${historyData.length}");

    final Uri url = Uri.parse("https://api.telegram.org/bot$telegramBotToken/sendMessage");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: '''
        {
          "chat_id": "$chatId",
          "text": "${text.toString()}",
          "parse_mode": "Markdown"
        }
        ''',
      );

      if (response.statusCode == 200) {
        // ✅ Success → clear history + hide loading
        setState(() {
          historyData.clear();
          isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Sent to Telegram Successfully!")),
        );
      } else {
        // ❌ Fail → stop loading, keep history
        setState(() => isSending = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to send: ${response.body}")),
        );
      }
    } catch (e) {
      // ❌ Error → stop loading, keep history
      setState(() => isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '3D',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                  // const Text(
                  //   "Sell History",
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final item = historyData[index];

                        return Card(
                          child: ListTile(
                            title: Text(item["display"]!), // ✅ shows "ပါဝါ300 = 3000"
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      inputValue = item["input"]!; // ✅ restore only original input (e.g ပါဝါ300)
                                      historyData.removeAt(index);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      historyData.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: onEnterPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(40, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("ENTER", style: TextStyle(color: Colors.white)),
                            ),

                            const SizedBox(width: 6),

                            ElevatedButton(
                              onPressed: isSending ? null : sendHistoryToTelegram,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(40, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSending
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send, color: Colors.white),
                            ),

                          ],
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
