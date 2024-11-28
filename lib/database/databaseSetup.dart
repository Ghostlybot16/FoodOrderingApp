import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:food_ordering_app/database/crudOperations.dart'; // Import CRUD operations file

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
        )''' );

    // Create the `order_plans` table if it doesn't already exist
    await databaseInstance.execute('''CREATE TABLE IF NOT EXISTS order_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          target_cost REAL NOT NULL,
          selected_items TEXT NOT NULL
        )''' );

    print('Database tables created successfully.');
  }

  // // Function to fetch all saved orders from the 'order_plans' table
  // Future<List<Map<String, dynamic>>> fetchSavedOrders() async {
  //   final db = await database;
  //   return await db.query('order_plans'); // Fetch all rows from order_plans
  // }
  // DatabaseHelper class method to fetch saved orders with optional date filter
  Future<List<Map<String, dynamic>>> fetchSavedOrders({String? date}) async {
    final db = await DatabaseHelper.instance.database;

    // If a date is provided, filter the orders by that date
    if (date != null && date.isNotEmpty) {
      return await db.query(
        'order_plans', // Use the correct table name
        where: 'date = ?', // Filter based on the 'date' column
        whereArgs: [date],
      );
    } else {
      // If no date is provided, fetch all orders
      return await db.query('order_plans');
    }
  }



  // Function to save a new order plan to the 'order_plans' table
  Future<void> saveOrderPlan(String date, double targetCost, String selectedItems) async {
    final db = await database;
    await db.insert('order_plans', {
      'date': date,
      'target_cost': targetCost,
      'selected_items': selectedItems,
    });
  }

  // Function to clear all food items and reset auto-increment counters
  Future<void> clearFoodItemsIfNeeded() async {
    final db = await database;
    final foodItems = await db.query('food_items');
    if (foodItems.isNotEmpty) {
      await db.delete('food_items');
      await db.rawDelete('DELETE FROM sqlite_sequence WHERE name="food_items"');
      print('Food items table cleared and ID counter reset.');
    }
  }

  // Function to clear all order plans and reset auto-increment counters
  Future<void> clearOrderPlansIfNeeded() async {
    final db = await database;
    final orderPlans = await db.query('order_plans');
    if (orderPlans.isNotEmpty) {
      await db.delete('order_plans');
      await db.rawDelete('DELETE FROM sqlite_sequence WHERE name="order_plans"');
      print('Order plans table cleared and ID counter reset.');
    }
  }

  // Debugging function to show all tables and their data
  Future<void> debugShowTables() async {
    final db = await database;

    // Fetch all tables in the database
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
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

  // Function to close the database connection
  Future<void> closeDatabaseConnection() async {
    final db = _cachedDatabaseInstance;
    if (db != null) {
      print('Closing database connection...');
      await db.close();
      print('Database connection closed.');
    }
  }

  // Function to update an existing order
  Future<void> updateOrder(int orderId, String date, double targetCost, String selectedItems) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'order_plans',
      {
        'date': date,
        'target_cost': targetCost,
        'selected_items': selectedItems,
      },
      where: 'id = ?', // Specify the condition for updating the specific order
      whereArgs: [orderId], // Pass the ID of the order to update
    );
  }


// Function to delete an order by its ID
  Future<void> deleteOrder(int orderId) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'order_plans', // The table name
      where: 'id = ?', // The condition
      whereArgs: [orderId], // The argument to delete the specific order
    );
  }


}