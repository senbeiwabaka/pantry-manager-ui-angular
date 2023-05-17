import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_manager_ui/src/models/grocery_list_item.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:qinject/qinject.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

import 'package:pantry_manager_ui/src/models/inventory_item.dart';
import 'package:pantry_manager_ui/src/models/product.dart';
import 'package:pantry_manager_ui/src/servics/database_service.dart';
import 'package:pantry_manager_ui/src/servics/file_service.dart';

import 'fake_file_service_platform_path.dart';

Future main() async {
  // No idea why this is needed or really what it does but it is needed for tests to run
  TestWidgetsFlutterBinding.ensureInitialized();

  // Fake the storage provider so we can access storage for tests
  PathProviderPlatform.instance = FakePathProviderPlatform();

  final qinjector = Qinject.instance();

  String databseName = "";

  // Setup sqflite_common_ffi for flutter test
  setUpAll(() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing calls for SQFlite
    databaseFactory = databaseFactoryFfi;

    Qinject.registerSingleton(() => FileService());

    final directory = await getApplicationDocumentsDirectory();

    if (!await directory.exists()) {
      await directory.create();
    }
  });

  setUp(() {
    const uuid = Uuid();
    databseName = "${uuid.v4()}.db";

    Qinject.registerSingleton(() => databseName);
  });

  test('Database Service GetData - Product - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);
    const expected = Product(upc: "123", label: "label", brand: "brand");

    await databaseService.initDatabase();

    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    db.execute(
        "INSERT INTO products (upc, label, brand, category, image_url) VALUES(?,?,?,?,?)",
        [expected.upc, expected.label, expected.brand, '', expected.imageUrl]);

    db.dispose();

    // Act
    final result = await databaseService.getData<Product>("123");

    // Assert
    expect(result, isNotNull);
    expect(result, equals(expected));
  });

  test('Database Service GetData - Product (LIKE) - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);
    const expected = Product(upc: "01230", label: "label", brand: "brand");

    await databaseService.initDatabase();

    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    db.execute(
        "INSERT INTO products (upc, label, brand, category, image_url) VALUES(?,?,?,?,?)",
        [expected.upc, expected.label, expected.brand, '', expected.imageUrl]);

    db.dispose();

    // Act
    final result = await databaseService.getData<Product>("123");

    // Assert
    expect(result, isNotNull);
    expect(result, equals(expected));
  });

  test('Database Service GetData - InventoryItem - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);
    const product = Product(upc: "123", label: "label", brand: "brand");
    const expected = InventoryItem(
        count: 1,
        numberUsedInPast30Days: 0,
        onGroceryList: false,
        product: product);

    await databaseService.initDatabase();

    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    db.execute(
        "INSERT INTO products (upc, label, brand, category, image_url) VALUES(?,?,?,?,?)",
        [product.upc, product.label, product.brand, '', product.imageUrl]);

    db.execute("""
      INSERT INTO inventory
        (count, number_used_in_past_30_days, on_grocery_list, product_id)
      VALUES 
        (?, ?, ?, ?);""", [1, 0, false, 1]);

    db.dispose();

    // Act
    final result = await databaseService.getData<InventoryItem>("123");

    // Assert
    expect(result, isNotNull);
    expect(result, equals(expected));
  });

  test('Database Service GetData - GroceryListItem - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);

    const upc = "123";
    const product = Product(upc: upc, label: "label", brand: "brand");
    const inventoryItem = InventoryItem(
        count: 1,
        numberUsedInPast30Days: 0,
        onGroceryList: false,
        product: product);
    const expected = GroceryListItem(
        upc: upc,
        quantity: 1,
        shopped: false,
        standardQuantity: 0,
        count: 1,
        label: "label");

    await databaseService.initDatabase();

    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);

    db.execute(
        "INSERT INTO products (upc, label, brand, category, image_url) VALUES(?,?,?,?,?)",
        [product.upc, product.label, product.brand, '', product.imageUrl]);

    db.execute("""
      INSERT INTO inventory
        (count, number_used_in_past_30_days, on_grocery_list, product_id)
      VALUES 
        (?, ?, ?, ?);""", [
      inventoryItem.count,
      inventoryItem.numberUsedInPast30Days,
      inventoryItem.onGroceryList,
      1
    ]);

    db.execute("""
      INSERT INTO groceries
        (quantity, shopped, standard_quantity, inventory_item_id)
      VALUES 
        (?, ?, ?, ?);""", [1, false, 0, 1]);

    db.dispose();

    // Act
    final result = await databaseService.getData<GroceryListItem>("123");

    // Assert
    expect(result, isNotNull);
    expect(result, equals(expected));
  });

  test('Database Service InsertData - Product - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);
    const expected = Product(upc: "123", label: "label", brand: "brand");

    await databaseService.initDatabase();

    // Act
    final result = await databaseService.insertData(expected);

    // Assert
    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);
    final List<Map> records =
        db.select("SELECT * FROM products WHERE upc = ?", [expected.upc]);
    final Map<String, dynamic> row = records.first as Map<String, dynamic>;
    final data = Product.fromMap(row);

    db.dispose();

    expect(result, isTrue);
    expect(data, equals(expected));
  });

  test('Database Service InsertData - InventoryItem - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);
    const product = Product(upc: "123", label: "label", brand: "brand");
    const expected = InventoryItem(
        count: 1,
        numberUsedInPast30Days: 0,
        onGroceryList: false,
        product: product);

    await databaseService.initDatabase();
    await databaseService.insertData(product);

    // Act
    final result = await databaseService.insertData(expected);

    // Assert
    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);
    final List<Map> records = db.select("""
          SELECT i.*, p.*
          FROM inventory AS i
          INNER JOIN products AS p ON i.product_id = p.id
          WHERE p.upc = ?""", [product.upc]);
    final Map<String, dynamic> row = records.first as Map<String, dynamic>;
    final data = InventoryItem.fromMap(row);

    db.dispose();

    expect(result, isTrue);
    expect(data, equals(expected));
  });

  test('Database Service InsertData - GroceryListItem - Unit Test', () async {
    // Arrange
    final databaseService = DatabaseService(qinjector);

    const upc = "123";
    const product = Product(upc: upc, label: "label", brand: "brand");
    const inventoryItem = InventoryItem(
        count: 1,
        numberUsedInPast30Days: 0,
        onGroceryList: false,
        product: product);
    const expected = GroceryListItem(
        upc: upc,
        quantity: 0,
        shopped: false,
        standardQuantity: 0,
        count: 1,
        label: "label");

    await databaseService.initDatabase();
    await databaseService.insertData(product);
    await databaseService.insertData(inventoryItem);

    // Act
    final result = await databaseService.insertData(expected);

    // Assert
    final fileService = qinjector.use<void, FileService>();
    final file = await fileService.localFile(databseName);
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);
    final List<Map> records = db.select("""
          SELECT g.*, i.*, p.*
          FROM groceries AS g
          INNER JOIN inventory AS i ON g.inventory_item_id = i.id
          INNER JOIN products AS p ON i.product_id = p.id
          WHERE p.upc = ?""", [product.upc]);
    final Map<String, dynamic> row = records.first as Map<String, dynamic>;
    final data = GroceryListItem.fromMap(row);

    db.dispose();

    expect(result, isTrue);
    expect(data, equals(expected));
  });

  tearDownAll(() async {
    final directory = await getApplicationDocumentsDirectory();
    final items = directory.listSync();

    for (final item in items) {
      await item.delete();
    }
  });
}
