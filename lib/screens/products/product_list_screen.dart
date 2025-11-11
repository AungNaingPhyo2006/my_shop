import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> salesList = [];
  Set<int> selectedIds = {}; // ✅ Store selected row IDs
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DBHelper.getSales();
    setState(() {
      salesList = data;
      isLoading = false;
      selectedIds.clear();
    });
  }

  void toggleSelect(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  void selectAll() {
    setState(() {
      if (selectedIds.length == salesList.length) {
        selectedIds.clear();
      } else {
        selectedIds = salesList.map((e) => e['id'] as int).toSet();
      }
    });
  }

  Future<void> deleteSelected() async {
    await DBHelper.deleteMultipleSales(selectedIds.toList());
    loadData();
  }

  // ✅ GROUP BY sale_date + user_name
  List<Map<String, dynamic>> groupedData() {
    Map<String, List<Map<String, dynamic>>> groups = {};

    for (var item in salesList) {
      String key = "${item['sale_date']}|${item['user_name']}";
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(item);
    }

    return groups.entries.map((e) {
      return {
        "sale_date": e.value.first["sale_date"],
        "user_name": e.value.first["user_name"],
        "items": e.value,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = groupedData();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedIds.isEmpty
              ? "Product List"
              : "${selectedIds.length} Selected",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: deleteSelected,
            ),
          IconButton(
            icon: Icon(
              selectedIds.length == salesList.length
                  ? Icons.select_all
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: selectAll,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : salesList.isEmpty
              ? const Center(child: Text("No Data Found"))
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final items = group["items"] as List<Map<String, dynamic>>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ USER NAME BOLD
                            Text(
                              group["user_name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            // ✅ DATE TIME SMALL
                            Text(
                              group["sale_date"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const Divider(),

                            // ✅ LIST ITEMS
                            ...items.map((item) {
                              final id = item['id'] as int;
                              final isSelected = selectedIds.contains(id);

                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onLongPress: () => toggleSelect(id),
                                onTap: () {
                                  if (selectedIds.isNotEmpty) toggleSelect(id);
                                },
                                leading: selectedIds.isNotEmpty
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => toggleSelect(id),
                                      )
                                    : const Icon(Icons.circle, size: 8),

                                title: Text(item['display']),

                                trailing: selectedIds.isEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () async {
                                          await DBHelper.deleteSale(id);
                                          loadData();
                                        },
                                      )
                                    : null,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
