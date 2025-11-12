import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RemainProductListScreen extends StatefulWidget {
  const RemainProductListScreen({super.key});

  @override
  State<RemainProductListScreen> createState() =>
      _RemainProductListScreenState();
}

class _RemainProductListScreenState extends State<RemainProductListScreen> {
  bool isLoading = false;
  String? selectedDate;
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Set today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchResult(); // Auto search when screen opens
    });
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      fetchResult();
    }
  }

  Future<void> fetchResult() async {
    if (selectedDate == null) return;

    setState(() {
      isLoading = true;
      results = [];
    });

    final url =
        "https://api.thaistock2d.com/2d_result?date=$selectedDate";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          results = data;
        });
      } else {
        results = [];
      }
    } catch (e) {
      results = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget resultCard(Map item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Date Header
            Text(
              "📅 ${DateFormat('dd-MMM-yyyy').format(DateTime.parse(item['date']))}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const Divider(),
            ...item['child'].map<Widget>((c) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("⏰ ${c['time']}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text("SET: ${c['set']}"),
                        Text("Value: ${c['value']}"),
                      ],
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle, // 👈 Perfect circle
                      ),
                      child: Text(
                        c['twod'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )

                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '2D ထွက်ပြီးစာရင်း',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          // 🔍 Date Picker Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                       selectedDate != null ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(selectedDate!)) : "ရက်စွဲ ရွေးပါ",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_month,
                        color: Colors.deepPurple)
                  ],
                ),
              ),
            ),
          ),

          // ✅ Results Body
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? const Center(
                        child: Text(
                          "ရှာမတွေ့ပါ",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (c, i) => resultCard(results[i]),
                      ),
          )
        ],
      ),
    );
  }
}
