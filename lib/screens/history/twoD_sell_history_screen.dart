import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class TwoDSellHistoryScreen extends ConsumerStatefulWidget {
  const TwoDSellHistoryScreen({super.key});

  @override
  ConsumerState<TwoDSellHistoryScreen> createState() => _SellHistoryScreenState();
}

class _SellHistoryScreenState extends ConsumerState<TwoDSellHistoryScreen> {
  bool isSending = false;
  String inputValue = '';
  String? selectedExtraKey; // ✅ store the selected extraKey
  List<Map<String, String>> historyData = []; // ✅ store entered history to show in list
  bool isBlockedTime() {
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;

  const start = 11 * 60 + 58; // 11:58 → minutes
  const end   = 12 * 60 + 1;  // 12:01 → minutes
  return currentMinutes >= start && currentMinutes <= end;
}



  Map<String, dynamic> processInput(String input) {
  // ===== datasets =====
  final mainData = List.generate(100, (i) => i.toString().padLeft(2, '0'));
  final apuu = ["00","11","22","33","44","55","66","77","88","99"];
  final parWar = ["05","50","16","61","27","72","38","83","49","94"];
  final nakkhat = ["07","70","18","81","24","42","35","53","69","96"];
  final nyiko = ["01","12","23","34","45","56","67","78","89","90","09","98","87","76","65","54","43","32","21","01"];
  final salPyi = ["10","20","30","40","50","60","70","80","90","55"];
  final salPwint = ["00","55","19","28","37","46"];
  final maMaYoyo = mainData.where((e) => e.contains(RegExp(r'[13579]'))).toList();
  final maMaApu = ["11","33","55","77","99"];
  final sonSonYoyo = mainData.where((e) => e.contains(RegExp(r'[02468]'))).toList();
  final sonSonApu = ["00","22","44","66","88"];

  // ===== Split category & number =====
  final regex = RegExp(r'(.*?)(\d+)$');
  final match = regex.firstMatch(input);

  if (match == null) return {"detail": "Invalid", "result": 0};

  final key = match.group(1)!;
  final amount = int.parse(match.group(2)!);

  List<String> digitList = [];

  if (key.isEmpty) {
    return {"detail": "No category", "result": 0};
  }

  // ===== If numeric digits exist before category (e.g 579အခွေ200) =====
  final digitMatch = RegExp(r'\d+').firstMatch(key);
  if (digitMatch != null) {
    final digits = digitMatch.group(0)!.split('');
    Set<String> pairs = {};

    for (int i = 0; i < digits.length; i++) {
      for (int j = 0; j < digits.length; j++) {
        if (i != j) {
          final candidate = digits[i] + digits[j];
          if (mainData.contains(candidate)) {
            pairs.add(candidate);
          }
        }
      }
    }
    digitList = pairs.toList();
  }

  // ===== If only category exists (e.g အပူး200) =====
  if (digitList.isEmpty) {
    switch (key) {
      case "အပူး": digitList = apuu; break;
      case "ပါဝါ": digitList = parWar; break;
      case "နက္ခတ်": digitList = nakkhat; break;
      case "ညီကို": digitList = nyiko; break;
      case "ဆယ်ပြည့်": digitList = salPyi; break;
      case "ဆယ်ပွင့်": digitList = salPwint; break;
      case "မမ ရိုးရိုး": digitList = maMaYoyo; break;
      case "မမ အပူး": digitList = maMaApu; break;
      case "စုံစုံ ရိုးရိုး": digitList = sonSonYoyo; break;
      case "စုံစုံ အပူး": digitList = sonSonApu; break;
    }
  }

  int total = digitList.length * amount;

  return {
    "detail": "${digitList.length} × $amount = $total",
    "result": total
  };
}

  final List<String> defaultKeys = [
      '7', '8', '9',
      '4', '5', '6',
      '1', '2', '3',
      'ရှင်း', '0', 'ဖျက်',
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
      'စုံစုံ အပူး',
    ];

  void onKeyPressed(String value) {
  setState(() {
    if (value == 'ရှင်း') {
      inputValue = '';
      selectedExtraKey = null;
    } 
    else if (value == 'ဖျက်') {
      if (inputValue.isNotEmpty) {
        if (selectedExtraKey != null && inputValue.endsWith(selectedExtraKey!)) {
          inputValue = inputValue.substring(0, inputValue.length - selectedExtraKey!.length);
          selectedExtraKey = null;
        } else {
          inputValue = inputValue.substring(0, inputValue.length - 1);
        }
      }
    } 

    // ✅ ExtraKey pressed
    else if (extraKeys.contains(value)) {
      if (selectedExtraKey != null) return; // only one extraKey allowed

      if (value == 'အခွေ') {
        // must have number before
        if (!RegExp(r'\d$').hasMatch(inputValue)) {
          debugPrint('❌ အခွေ must have number before');
          return;
        }
      } else {
        // other extraKeys MUST NOT have number before
        if (RegExp(r'\d$').hasMatch(inputValue)) {
          debugPrint('❌ This extraKey cannot have numbers before');
          return;
        }
      }

      selectedExtraKey = value;
      inputValue += value;
    } 

    // ✅ Number pressed
    else {
      inputValue += value;
    }

    debugPrint('inputValue => $inputValue, selectedExtraKey => $selectedExtraKey');
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

  final result = processInput(inputValue);

  setState(() {
    historyData.add({
      "input": inputValue, // ✅ save raw input
      "display": "$inputValue = ${result["result"]}", // ✅ clean UI format
    });

    inputValue = '';
    selectedExtraKey = null;
  });
}

  Future<void> sendHistoryToTelegram() async {

      // 🚫 BLOCK time check
    if (isBlockedTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⛔ Upload is not allowed between 11:58 AM and 12:01 PM"),
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
          '2D',
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

                                      final found = extraKeys.firstWhere(
                                        (ek) => inputValue.contains(ek),
                                        orElse: () => '',
                                      );
                                      selectedExtraKey = found.isNotEmpty ? found : null;

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
