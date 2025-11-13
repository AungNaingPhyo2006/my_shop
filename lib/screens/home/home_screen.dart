import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/providers/two_provider.dart';
import 'package:my_shop/screens/history/threeD_sell_history_screen.dart';
import 'package:my_shop/screens/history/twoD_sell_history_screen.dart';
import 'package:my_shop/screens/products/product_list_screen.dart';
import 'package:my_shop/screens/remain/remain_product_list_screen.dart';
import 'package:my_shop/widgets/grib_nav_button.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

    String lastUpdated = "";
    Timer? _timer; // <-- Store timer to cancel later

  @override
  void initState() {
    super.initState();

    // ✅ Auto refresh every 30 seconds
    Future.delayed(Duration.zero, () {
      _updateTime();
      ref.invalidate(twoDProvider);
    });

    // ✅ Auto refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(twoDProvider);
      _updateTime();
    });

    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      ref.invalidate(twoDProvider);
      _updateTime();
    });
  }

  // ✅ Cancel timer when leaving the screen (to prevent memory leaks)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _updateTime() {
    setState(() {
      lastUpdated = DateTime.now().toLocal().toString().substring(0, 19);
    });
  }
  @override
  Widget build(BuildContext context) {
    final apiData = ref.watch(twoDProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '2D Lover',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               // ✅ Last updated time UI
            if (lastUpdated.isNotEmpty)
              Text(
                "နောက်ဆုံးအပ်ဒိတ် - ${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.parse(lastUpdated))}",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

            const SizedBox(height: 10),
            // ✅ Section 1 : Live + Result (scrollable)
            Expanded(
              flex: 7,
              child: apiData.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text("No data available"));
                  }

                  final live = data["live"];
                  final result = data["result"] as List;

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(twoDProvider); // ✅ refresh API
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // ✅ must add for refresh
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ------------- YOUR UI CODE HERE (no changes needed) -------------
                          Center(
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purpleAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text("LIVE 2D",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 12),
                                    Text("2D : ${live["twod"]}",
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                                    const SizedBox(height: 4),
                                    Text("SET : ${live["set"]}",
                                        style: const TextStyle(fontSize: 18, color: Colors.white)),
                                    Text("Value : ${live["value"]}",
                                        style: const TextStyle(fontSize: 18, color: Colors.white)),
                                    Text("Time : ${live["time"]}",
                                        style: const TextStyle(fontSize: 16, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Text("RESULTS",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: result.asMap().entries.map((entry) {
                                int index = entry.key;
                                var item = entry.value;

                                final Color startColor = index.isEven ? Colors.deepPurple : Colors.teal;
                                final Color endColor = index.isEven ? Colors.purpleAccent : Colors.cyanAccent;

                                return Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [startColor, endColor],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.history, color: Colors.white),
                                        title: Text("2D: ${item["twod"]}",
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                        subtitle: Text("Time: ${item["open_time"]} | SET: ${item["set"]}",
                                            style: const TextStyle(color: Colors.white70)),
                                        trailing: Text(item["twod"],
                                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  );
                },
              // ✅ SHIMMER LOADING
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(height: 90, width: double.infinity),
                    const SizedBox(height: 20),

                      // ✅ FIX: Make scrollable so it can't overflow
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _shimmerBox(height: 90, width: 180),
                            const SizedBox(width: 10),
                            _shimmerBox(height: 90, width: 180),
                            const SizedBox(width: 10),
                            _shimmerBox(height: 90, width: 180), // optional extra shimmer card
                          ],
                        ),
                      )
                    ],
                  ),

                  error: (e, _) => const Center(child: Text("Error loading data")),
                ),
              ),
            const SizedBox(height: 20),
            // ✅ Section 2 : Grid Buttons (fixed height)
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const BouncingScrollPhysics(),
                children: const [
                  GridNavButton(
                    label: "2D",
                    icon: Icons.point_of_sale,
                    page: TwoDSellHistoryScreen(),
                  ),
                  GridNavButton(
                    label: "3D",
                    icon: Icons.point_of_sale,
                    page: ThreeDSellHistoryScreen(),
                    iconColor: Colors.red,
                  ),
                  GridNavButton(
                    label: "စာရင်း",
                    icon: Icons.receipt_long,
                    page: ProductListScreen(),
                  ),
                  GridNavButton(
                    label: "ထွက်ပြီး",
                    icon: Icons.inventory,
                    page: RemainProductListScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Shimmer Widget
  Widget _shimmerBox({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
