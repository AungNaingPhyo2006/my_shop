import 'package:flutter/material.dart';
import 'package:my_shop/db/db_helper.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> salesList = [];
  List<Map<String, dynamic>> filteredList = [];
  Set<int> selectedIds = {};
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadData();
    searchController.addListener(applyFilter);
  }

  Future<void> loadData() async {
    final data = await DBHelper.getSales();
    setState(() {
      salesList = data;
      filteredList = data;
      isLoading = false;
      selectedIds.clear();
    });
  }

void applyFilter() {
  String searchText = searchController.text.toLowerCase();

  setState(() {
    filteredList = salesList.where((item) {
      final user = item['user_name'].toString().toLowerCase();
      final category = item['category'].toString().toLowerCase();
      final saleDate = item['sale_date'].toString(); // "12/11/2025 15:39"

      // ✅ Extract only date part before space
      final dateOnly = saleDate.split(" ").first; // "12/11/2025"

      bool matchesText =
          user.contains(searchText) || category.contains(searchText);

      bool matchesDate = selectedDate == null ||
          dateOnly == DateFormat('dd/MM/yyyy').format(selectedDate!);

      return matchesText && matchesDate;
    }).toList();
  });
}


  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      applyFilter();
    }
  }

  void clearDate() {
    setState(() {
      selectedDate = null;
    });
    applyFilter();
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
      if (selectedIds.length == filteredList.length) {
        selectedIds.clear();
      } else {
        selectedIds = filteredList.map((e) => e['id'] as int).toSet();
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

    for (var item in filteredList) {
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
        "category": e.value.first["category"],
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
          selectedIds.isEmpty ? "စာရင်းများ" : "${selectedIds.length} ရွေးချယ်ပြီး",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: deleteSelected,
            ),
          IconButton(
            icon: Icon(
              selectedIds.length == filteredList.length
                  ? Icons.select_all
                  : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: selectAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ SEARCH BAR + CALENDAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "ရှာဖွေရန်...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                  onPressed: pickDate,
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: clearDate,
                  )
              ],
            ),
          ),

          // ✅ LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? const Center(child: Text("ရှာမတွေ့ပါ"))
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
                                  Text(
                                    group["user_name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    group["category"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    group["sale_date"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Divider(),

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
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
