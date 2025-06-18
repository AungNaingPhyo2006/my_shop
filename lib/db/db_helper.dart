import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT,
            barcode TEXT,
            qty INTEGER,
            buy_price REAL,
            sell_price REAL,
            discount REAL,
            remark TEXT
          )
        ''');

        await db.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          product_name TEXT,
          barcode TEXT,
          sell_price REAL,
          quantity_sold INTEGER,
          discount REAL,
          remark TEXT,
          sale_date TEXT,
          FOREIGN KEY (product_id) REFERENCES products(id)
        )
      ''');

      },
    );
  }

  static Future<void> insertProduct(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('products', data);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'id DESC');
  }

  static Future<void> deleteAllProducts() async {
  final db = await database;
  await db.delete('products');
}

static Future<void> sellProductByBarcode(String barcode) async {
  final db = await database;

  final List<Map<String, dynamic>> result = await db.query(
    'products',
    where: 'barcode = ?',
    whereArgs: [barcode],
  );

  if (result.isNotEmpty) {
    final product = result.first;
    int currentQty = product['qty'];

    if (currentQty > 0) {
      int newQty = currentQty - 1;

      // 1. Update the product qty
      await db.update(
        'products',
        {'qty': newQty},
        where: 'id = ?',
        whereArgs: [product['id']],
      );

      // 2. Insert into sales table
      await db.insert('sales', {
        'product_id': product['id'],
        'barcode': barcode,
        'quantity_sold': 1,
        'sale_date': DateTime.now().toIso8601String(),
      });

      print('✅ Product sold and logged to sales table.');
    } else {
      print('❌ Product out of stock.');
    }
  } else {
    print('❌ Product with barcode $barcode not found.');
  }
}

 static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await database;
    return await db.query('sales', orderBy: 'id DESC');
  }

    static Future<void> deleteSales() async {
  final db = await database;
  await db.delete('sales');
}

static Future<List<Map<String, dynamic>>> getTotalProductWithSales() async {
  final db = await DBHelper.database;
  return await db.rawQuery('''
    SELECT 
      p.product_name,
      p.barcode,
      p.qty AS current_qty,
      IFNULL(SUM(s.quantity_sold), 0) AS sold_qty,
      (p.qty + IFNULL(SUM(s.quantity_sold), 0)) AS total_qty,
      p.sell_price,
      p.discount,
      p.remark
    FROM products p
    LEFT JOIN sales s 
      ON p.barcode = s.barcode AND p.product_name = s.product_name
    GROUP BY p.barcode, p.product_name
  ''');
}


}
