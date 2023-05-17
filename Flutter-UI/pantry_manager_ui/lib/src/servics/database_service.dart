import 'dart:io';

import 'package:pantry_manager_ui/src/models/product.dart';
import 'package:qinject/qinject.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/grocery_list_item.dart';
import '../models/inventory_item.dart';
import 'file_service.dart';

class DatabaseService {
  final FileService _fileService;
  final String _databaseName;

  DatabaseService(Qinjector qinject)
      : _fileService = qinject.use<void, FileService>(),
        _databaseName = qinject.use<void, String>();

  Future _createDatabase() async {
    if (!await _fileService.fileExists(_databaseName)) {
      final File file = await _fileService.localFile(_databaseName);
      final db = sqlite3.open(file.path, mode: OpenMode.readWriteCreate);

      db.dispose();
    }
  }

  Future _createTables() async {
    final file = await _fileService.localFile(_databaseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    const String productsTableSQL = """CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY,
            upc TEXT NOT NULL,
            label TEXT NULL,
            brand TEXT NULL,
            category TEXT NULL,
            image_url TEXT NULL
          );""";
    db.execute(productsTableSQL);

    const String inventoryTableSQL = """CREATE TABLE IF NOT EXISTS "inventory" (
            "id" INTEGER PRIMARY KEY,
            "count" INTEGER,
            "number_used_in_past_30_days" INTEGER,
            "on_grocery_list" boolean,
            "product_id" INTEGER NOT NULL,
            FOREIGN KEY(product_id) REFERENCES products(id)
          );""";
    db.execute(inventoryTableSQL);

    const String groceriesTableSQL = """CREATE TABLE IF NOT EXISTS "groceries" (
            "id" INTEGER PRIMARY KEY,
            "quantity" INTEGER,
            "shopped" boolean,
            "standard_quantity" INTEGER,
            "inventory_item_id" INTEGER NOT NULL,
            FOREIGN KEY(inventory_item_id) REFERENCES inventory(id)
          );""";
    db.execute(groceriesTableSQL);

    db.dispose();
  }

  Future initDatabase() async {
    await _createDatabase();
    await _createTables();
  }

  Future<bool> insertData(Object data) async {
    final file = await _fileService.localFile(_databaseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    if (data is Product) {
      final Product productData = data;

      db.execute(
          "INSERT INTO products (upc, label, brand, category, image_url) VALUES(?,?,?,?,?)",
          [
            productData.upc,
            productData.label,
            productData.brand,
            '',
            productData.imageUrl
          ]);
    }

    if (data is InventoryItem) {
      final List<Map> productResults = db
          .select("SELECT id FROM products WHERE upc = ?", [data.product.upc]);

      if (productResults.isEmpty) {
        return false;
      }

      final productId = productResults.first["id"] as int;

      db.execute("""
      INSERT INTO inventory
        (count, number_used_in_past_30_days, on_grocery_list, product_id)
      VALUES 
        (?, ?, ?, ?);""", [1, 0, false, productId]);
    }

    if (data is GroceryListItem) {
      final List<Map> inventoryResults = db.select("""SELECT i.id 
                    FROM inventory AS i
                    INNER JOIN products AS p ON i.product_id = p.id 
                    WHERE upc = ?""", [data.upc]);

      if (inventoryResults.isEmpty) {
        return false;
      }

      final inventoryItemId = inventoryResults.first["id"] as int;

      db.execute("""
      INSERT INTO groceries
        (quantity, shopped, standard_quantity, inventory_item_id)
      VALUES 
        (?, ?, ?, ?);""", [0, 0, false, inventoryItemId]);
    }

    final List<Map> results = db.select("SELECT last_insert_rowid()");

    if (results.isEmpty) {
      return false;
    }

    var id = results.first[0] as int;

    db.dispose();

    return id > 0;
  }

  Future<bool> updateData(Object data) async {
    final file = await _fileService.localFile(_databaseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    var successful = false;

    if (data is InventoryItem) {
      final List<Map> inventoryResults = db.select("""SELECT i.id 
                    FROM inventory AS i
                    INNER JOIN products AS p ON i.product_id = p.id 
                    WHERE upc = ?""", [data.product.upc]);

      if (inventoryResults.isEmpty) {
        return false;
      }

      final inventoryItemId = inventoryResults.first["id"] as int;

      try {
        db.execute("""
      UPDATE inventory
        SET count = ?,
          number_used_in_past_30_days = ?,
          on_grocery_list = ?
        WHERE id = ?;""", [
          data.count,
          data.numberUsedInPast30Days,
          data.onGroceryList,
          inventoryItemId
        ]);

        successful = true;
      } catch (exception) {}
    }

    db.dispose();

    return successful;
  }

  Future<Object?> getData<T>(String upc) async {
    final file = await _fileService.localFile(_databaseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    String sql;

    if (T == Product) {
      sql = "SELECT * FROM products WHERE upc LIKE ?";
    } else if (T == InventoryItem) {
      sql = """SELECT i.* , p.*
              FROM inventory AS i
              INNER JOIN products AS p ON i.product_id = p.id
              WHERE p.upc LIKE ?""";
    } else if (T == GroceryListItem) {
      sql = """SELECT g.*, i.*, p.*
              FROM groceries AS g
              INNER JOIN inventory AS i ON g.inventory_item_id = g.id
              INNER JOIN products AS p ON i.product_id = p.id
              WHERE p.upc LIKE ?""";
    } else {
      throw Error();
    }

    final List<Map> results = db.select(sql, ["%$upc%"]);

    if (results.isEmpty) {
      return null;
    }

    Object? returnObject;

    final Map<String, dynamic> result = results.first as Map<String, dynamic>;

    if (T == Product) {
      returnObject = Product.fromMap(result);
    } else if (T == InventoryItem) {
      returnObject = InventoryItem.fromMap(result);
    } else if (T == GroceryListItem) {
      returnObject = GroceryListItem.fromJson(result);
    } else {
      throw Error();
    }

    db.dispose();

    return returnObject;
  }
}

// Type typeOf<T>() => T;
