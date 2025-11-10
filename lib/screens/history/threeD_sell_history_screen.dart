import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/providers/auth_provider.dart';

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
  if (inputValue.isEmpty) return;

  // ---- 1. Extract left & right side of "=" ----
  if (!inputValue.contains("=")) return;
  final parts = inputValue.split("=");

  if (parts.length != 2) return;
  final left = parts[0];      // e.g "793@567" or "567R"
  final right = parts[1];     // e.g "300"

  // ---- 2. Split by @ if exists ----
  List<String> leftItems = left.split("@");  // ["793","567"] or ["567R"]

  // ---- 3. Build display text ----
  List<String> displayLines = [];

  for (var item in leftItems) {
    if (item.endsWith("R")) {
      // 567R → 567 (R) = 300
      final num = item.replaceAll("R", "");
      displayLines.add("$num (R) = $right");
    } else {
      // 793 → 793 = 300
      displayLines.add("$item = $right");
    }
  }

  setState(() {
    historyData.add({
      "input": inputValue,           // ✅ keep raw input
      "display": displayLines.join("\n"), // ✅ show multi-line UI
    });

    inputValue = '';
  });
}


void showConfirmModal() {
  final user = ref.read(authProvider);
  final defaultName = user?['userName']?.toString() ?? 'Casher';
  final displayRole = user?['roleName']?.toString() ?? '';

  TextEditingController nameController = TextEditingController(text: defaultName);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("တင်မည့်သူ အတည်ပြုရန်"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("အမည်"),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: "အမည်ထည့်ပါ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("မလုပ်တော့ပါ"),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredName = nameController.text.trim();

              // ❗ BLOCK EMPTY NAME
              if (enteredName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠ အမည် ထည့်ရန်လိုပါသည်!"),
                    backgroundColor: Colors.red,
                  ),
                );
                return; // ❗ stop here, don't close modal
              }

              Navigator.pop(context);
              sendHistoryToTelegram(enteredName, displayRole);
            },
            child: const Text("အိုကေ"),
          ),
        ],
      );
    },
  );
}


  Future<void> sendHistoryToTelegram(String senderName, String senderRole) async {

      // 🚫 BLOCK time check
    if (isBlockedTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⛔ 03:58 PM မှ 04:01 PM အတွင်း တင်ခွင့်မပြုပါ"),
          backgroundColor: Colors.red,
        ),
      );
      return; // ❗ stop function
    }
    
    const String telegramBotToken = '7653380321:AAEKzt7QotYRqB36rKBaYsID3pIKFhGizGU';
    const String chatId = '5613994162';

    if (historyData.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ တင်ရန်  အကွက် မရှိပါ!")),
    );
    return;
  }

    setState(() => isSending = true); // ✅ show loading

    // Build message
    final now = DateTime.now();
    final formattedTime = "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final StringBuffer text = StringBuffer();
    text.writeln("📦 *စာရင်းအသစ် ရောက်လာပါသည်*");
    text.writeln("🕒 *တင်သည့် အချိန် - * `$formattedTime`");
    text.writeln("👤 *အမည် - * $senderName");
    text.writeln("🎭 *ပုံစံ - * $senderRole");
    text.writeln("--------------------");

    for (var item in historyData) {
      text.writeln("• ${item["display"]}");
    }

    text.writeln("--------------------");
    text.writeln("✅ စုစုပေါင်း = ${historyData.length}");

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
          const SnackBar(content: Text("✅ အောင်မြင်စွာ တင်ပြီးပါပြီ!")),
        );
      } else {
        // ❌ Fail → stop loading, keep history
        setState(() => isSending = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${response.body}  ကို  တင်၍ မရပါ။")),
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
                  if (historyData.isEmpty)
                    const Text(
                      "နမူနာ။ ။ 12@34= 200 , 123အခွေ500, အပူး400",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final item = historyData[index];

                        return Card(
                          child: ListTile(
                            title: Text(
                              item["display"]!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
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
                              child: const Text("အိုကေ", style: TextStyle(color: Colors.white)),
                            ),

                            const SizedBox(width: 6),

                            ElevatedButton(
                              onPressed: isSending ? null : showConfirmModal,
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
