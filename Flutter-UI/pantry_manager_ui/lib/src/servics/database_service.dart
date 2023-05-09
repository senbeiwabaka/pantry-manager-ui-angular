import 'package:pantry_manager_ui/src/models/product.dart';
import 'package:sqlite3/sqlite3.dart';

import 'file_service.dart';

class DatabaseService {
  final FileService _fileService;

  DatabaseService(this._fileService);

  Future _createDatabase() async {
    var fileName = FileService.databaseName;

    if (!await _fileService.fileExists(fileName)) {
      var file = await _fileService.localFile(fileName);
      var db = sqlite3.open(file.path, mode: OpenMode.readWriteCreate);

      db.dispose();
    }
  }

  Future _createTables() async {
    var fileName = FileService.databaseName;
    var file = await _fileService.localFile(fileName);
    var db = sqlite3.open(file.path, mode: OpenMode.readWrite);

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
            "number_used_in_past_thirty_days" INTEGER,
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

  Future insertData(Object data) async {
    var fileName = FileService.databaseName;
    var file = await _fileService.localFile(fileName);
    var db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    if (data is Product) {
      Product productData = data;

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

    var result = db.select("SELECT last_insert_rowid()");

    db.dispose();
  }

  Future<T?> getData<T>(String upc) async {
    var fileName = FileService.databaseName;
    var file = await _fileService.localFile(fileName);
    var db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    String sql;

    if (T == Product) {
      sql = "SELECT * FROM products WHERE upc = $upc";
    } else {
      sql = "";
    }

    var result = db.select(sql);

    if (result.isEmpty) {
      return null;
    }

    return Product(upc: upc) as T;
  }
}

Type typeOf<T>() => T;
