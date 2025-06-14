class Product {
  final String barcode;
  final String name;
  final double costPrice;
  final double sellingPrice;
  int quantity;

  Product({
    required this.barcode,
    required this.name,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
  });

  double get profit => (sellingPrice - costPrice) * quantity;
}
