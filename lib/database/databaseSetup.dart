import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _cachedDatabaseInstance;

  DatabaseHelper._init();

  // Get the database instance
  Future<Database> get database async {
    if (_cachedDatabaseInstance != null) return _cachedDatabaseInstance!;
    _cachedDatabaseInstance = await _initDB('food_ordering.db');
    return _cachedDatabaseInstance!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    try {
      final databaseDirectoryPath = await getDatabasesPath(); // Get the storage directory
      final databaseFilePath = join(databaseDirectoryPath, filePath); // Create the full file path

      print('Initializing database at: $databaseFilePath');

      // Open or create the database
      return await openDatabase(
        databaseFilePath,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      print('Error initializing database: $e'); // Log any errors during initialization
      rethrow; // Re-throw the exception to propagate it if necessary
    }
  }

  // Create tables in the database
  Future<void> _createDB(Database databaseInstance, int version) async {
    print('Creating database tables...');

    // Create the `food_items` table if it doesn't already exist
    await databaseInstance.execute('''CREATE TABLE IF NOT EXISTS food_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          cost REAL NOT NULL
        )''');

    // Create the `order_plans` table if it doesn't already exist
    await databaseInstance.execute('''CREATE TABLE IF NOT EXISTS order_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          target_cost REAL NOT NULL,
          selected_items TEXT NOT NULL
        )''');

    print('Database tables created successfully.');
  }

  // Function to insert test data into the database
  Future<void> insertTestData() async {
    final db = await database;

    // Insert test data into `food_items`
    await db.insert('food_items', {'name': 'Pizza', 'cost': 9.99});
    await db.insert('food_items', {'name': 'Burger', 'cost': 5.99});
    await db.insert('food_items', {'name': 'Sushi', 'cost': 14.99});

    // Insert test data into `order_plans`
    await db.insert('order_plans', {
      'date': '2024-11-28',
      'target_cost': 30.00,
      'selected_items': 'Pizza, Burger'
    });

    print('Test data inserted successfully.');
  }

  // Function to show tables and their data
  Future<void> debugShowTables() async {
    final db = await database;

    // Fetch all tables in the database
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table';");
    print('Tables in the database: $tables');

    // Loop through each table and print its contents
    for (var table in tables) {
      final tableName = table['name'] as String;
      if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
        final rows = await db.query(tableName);
        print('Contents of $tableName: $rows');
      }
    }
  }

  // Close the database connection
  Future<void> closeDatabaseConnection() async {
    final db = _cachedDatabaseInstance;
    if (db != null) {
      print('Closing database connection...');
      await db.close();
      print('Database connection closed.');
    }
  }
}
