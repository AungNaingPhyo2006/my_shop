import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/providers/two_provider.dart';
import 'package:my_shop/screens/history/sell_history_screen.dart';
import 'package:my_shop/screens/products/product_list_screen.dart';
import 'package:my_shop/screens/remain/remain_product_list_screen.dart';
import 'package:my_shop/widgets/grib_nav_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final apiData = ref.watch(twoDProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Baby Boss',
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
            // ✅ Section 1 : Live + Result (scrollable)
            Expanded(
              flex: 5,
              child: apiData.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(child: Text("No data available"));
                  }

                  final live = data["live"];
                  final result = data["result"] as List;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Card with attractive design
                        Center(
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              width: double.infinity, // take available width
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.deepPurple, Colors.purpleAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "LIVE 2D",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "2D : ${live["twod"]}",
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "SET : ${live["set"]}",
                                    style: const TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    "Value : ${live["value"]}",
                                    style: const TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    "Time : ${live["time"]}",
                                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Result List
                        const Text("RESULTS",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: result.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value;

                              // Choose colors for alternating cards
                              final Color startColor = index.isEven ? Colors.deepPurple : Colors.teal;
                              final Color endColor = index.isEven ? Colors.purpleAccent : Colors.cyanAccent;

                              return Container(
                                width: 220, // fixed width for each card
                                margin: const EdgeInsets.only(right: 12),
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                                      title: Text(
                                        "2D: ${item["twod"]}",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        "Time: ${item["open_time"]}  |  SET: ${item["set"]}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      trailing: Text(
                                        item["twod"],
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellowAccent),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text("Error loading data")),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Section 2 : Grid Buttons (fixed height)
            const Text("MENU",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const BouncingScrollPhysics(),
                children: const [
                  GridNavButton(
                    label: "Sales",
                    icon: Icons.point_of_sale,
                    page: SellHistoryScreen(),
                  ),
                  GridNavButton(
                    label: "Products",
                    icon: Icons.receipt_long,
                    page: ProductListScreen(),
                  ),
                  GridNavButton(
                    label: "Remain",
                    icon: Icons.inventory,
                    page: RemainProductListScreen(),
                  ),
                  GridNavButton(
                    label: "Settings",
                    icon: Icons.settings,
                    page: ProductListScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
