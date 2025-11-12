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
      CREATE TABLE sales_summary (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_date TEXT,
          user_name TEXT,
          input TEXT,
          display TEXT,
          category TEXT,
          amount REAL
      )
      ''');
      },
    );
  }

  static Future<void> insertSale({
    required String saleDate,
    required String userName,
    required String input,
    required String display,
    required String category,
    required double amount,
  }) async {
    final db = await database;
    await db.insert('sales_summary', {
      "sale_date": saleDate,
      "user_name": userName,
      "input": input,
      "display": display,
      "category": category,
      "amount": amount,
    });
  }

  static Future<List<Map<String, dynamic>>> getSales() async {
    final db = await database;
    return await db.query('sales_summary', orderBy: 'id DESC');
  }

  static Future<void> deleteSale(int id) async {
    final db = await database;
    await db.delete("sales_summary", where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteMultipleSales(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final idString = ids.join(","); // "1,2,3"
    await db.rawDelete("DELETE FROM sales_summary WHERE id IN ($idString)");
  }


}
