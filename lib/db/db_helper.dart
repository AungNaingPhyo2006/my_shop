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

}
