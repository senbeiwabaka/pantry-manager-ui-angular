import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:qinject/qinject.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

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
    await databaseService.insertData(expected);

    // Act
    final result = await databaseService.getData<Product>("123");

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
    final data = await databaseService.getData<Product>("123");

    expect(result, isTrue);
    expect(data, equals(expected));
  });

  tearDownAll(() async {
    final directory = await getApplicationDocumentsDirectory();
    final items = directory.listSync();

    for (var item in items) {
      await item.delete();
    }
  });
}
