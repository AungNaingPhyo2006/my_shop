import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/db/db_helper.dart';
import 'package:my_shop/providers/auth_provider.dart';

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
      '@', '0', '=',
      'ရှင်း', '', 'ဖျက်',
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

  List<String> convertDisplayFormat(String input) {
    // If input contains any extra key, do NOT split
    for (var key in extraKeys) {
      if (input.contains(key)) {
        return [input]; // show original only
      }
    }

    // Normal @= split logic
    if (input.contains('@') && input.contains('=')) {
      final parts = input.split('=');
      if (parts.length != 2) return [input];

      final left = parts[0].split('@');
      final amount = parts[1];

      return left.map((e) => "$e=$amount").toList();
    }

    return [input];
  }


  void onKeyPressed(String value) {
  setState(() {
       // ❌ BLOCK @ and = when extraKey is selected
    if (selectedExtraKey != null && (value == '@' || value == '=')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ '@' , '=' ကို သုံး၍ မရပါ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ❌ Also block if user tries to paste or input them manually
    if (selectedExtraKey != null && (inputValue.contains('@') || inputValue.contains('='))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ '@' , '=' ကို သုံး၍ မရပါ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    

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

bool isValidInput(String input) {
  // If input contains extraKey → always valid
  if (selectedExtraKey != null) return true;

  // If input contains @ or =, validate the pattern
  final pattern = RegExp(r'^(\d+@)*\d+=\d+$'); 
  // ✅ Explanation:
  // (\d+@)* → zero or more groups of digits followed by @
  // \d+     → digits before =
  // =\d+    → = followed by digits (amount)

  return pattern.hasMatch(input);
}


  void onEnterPressed() {
    if (inputValue.isEmpty) return;

      // ❌ BLOCK invalid input
  if (!isValidInput(inputValue)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ပုံစံမှားနေပါသည်! ပုံစံအမှန် - 78@95@32=200"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }


    final result = processInput(inputValue); // ✅ this already calculates 2000
    final total = result["result"];

    // If extraKey exists → NO SPLIT, but show result
    if (selectedExtraKey != null) {
      setState(() {
        historyData.add({
          "input": inputValue,                 // for edit restore
          "display": "$inputValue = $total",  // ✅ output now: ပါဝါ200 = 2000
        });
        inputValue = '';
        selectedExtraKey = null;
      });
      return;
    }

    // Normal split logic for 73@56@77=300
    if (inputValue.contains('@') && inputValue.contains('=')) {
      final parts = inputValue.split('=');
      if (parts.length == 2) {
        final left = parts[0].split('@');
        final amount = parts[1];

        setState(() {
          for (var num in left) {
            historyData.add({
              "input": inputValue,
              "display": "$num=$amount",
            });
          }
        });
      }
    } else {
      // Normal single number like 56=300
      setState(() {
        historyData.add({
          "input": inputValue,
          "display": inputValue,
        });
      });
    }

    setState(() {
      inputValue = '';
      selectedExtraKey = null;
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
            Text("Role: $displayRole",
                style: const TextStyle(fontWeight: FontWeight.w500)),
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
          content: Text("⛔ 11:58 AM မှ  12:01 PM အတွင်း တင်ခွင့်မပြုပါ"),
          backgroundColor: Colors.red,
        ),
      );
      return; // ❗ stop function
    }
    
    const String telegramBotToken = '7653380321:AAEKzt7QotYRqB36rKBaYsID3pIKFhGizGU';
    const String chatId = '5613994162';

    if (historyData.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ တင်ရန် အကွက် မရှိပါ!")),
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
    text.writeln("✅  စုစုပေါင်း =  ${historyData.length}");

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
         // ✅ Save each history item into Database
          for (var item in historyData) {
            final display = item["display"] ?? "";
            final input = item["input"] ?? "";

            double amount = 0;
            if (display.contains("=")) {
              amount = double.tryParse(display.split("=").last.trim()) ?? 0;
            }

            await DBHelper.insertSale(
              saleDate: formattedTime,
              userName: senderName,
              input: input,
              display: display,
              category:'2D',
              amount: amount,
            );
          }

        
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
          SnackBar(content: Text("❌ ${response.body} ကို  တင်၍ မရပါ။")),
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
                            title: Text(item["display"]!), // ✅ shows "ပါဝါ300 = 3000"
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                   onPressed: () {
                                      setState(() {
                                        // restore the full input for editing
                                        inputValue = item["input"]!;

                                        // detect any extra key
                                        final found = extraKeys.firstWhere(
                                          (ek) => inputValue.contains(ek),
                                          orElse: () => '',
                                        );
                                        selectedExtraKey = found.isNotEmpty ? found : null;

                                        // remove ALL history items that have the same original input
                                        historyData.removeWhere((element) => element["input"] == inputValue);
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
