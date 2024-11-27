import 'package:flutter/material.dart';
import 'package:food_ordering_app/database/databaseSetup.dart'; // Import the database helper
import 'package:food_ordering_app/database/crudOperations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is fully initialized
  await testDatabaseSetup(); // Run the database setup and test
  runApp(const MyApp());
}

// Function to test the database setup
Future<void> testDatabaseSetup() async {
  try {
    final dbHelper = DatabaseHelper.instance;

    // Ensure the database is initialized
    await dbHelper.database;

    // Clear existing data from the tables before testing
    await clearFoodItemsIfNeeded();
    await clearOrderPlansIfNeeded();

    // Insert initial test data (To test insert data function)
    await insertFoodItem('Pizza', 9.99);
    await insertFoodItem('Burger', 5.99);
    await insertFoodItem('Sushi', 14.99);

    print('Initial data inserted');

    // Fetch food items (for fetch test)
    var foodItems = await fetchFoodItems();
    print('Fetched food items: $foodItems');

    // Assuming the inserted food items now have IDs 7, 8, 9
    // Update a food item (for update test) using the first item’s ID
    if (foodItems.isNotEmpty) {
      int foodIdToUpdate = foodItems[0]['id']; // Get the ID of the first food item
      await updateFoodItem(foodIdToUpdate, 'Vegan Pizza', 12.99);
      print('Food item with ID $foodIdToUpdate updated.');
    }

    // Fetch food items again to see the update (for update check)
    foodItems = await fetchFoodItems();
    print('Fetched food items after update: $foodItems');

    // Delete a food item (for delete test) using the second item’s ID
    if (foodItems.length > 1) {
      int foodIdToDelete = foodItems[1]['id']; // Get the ID of the second food item
      await deleteFoodItem(foodIdToDelete);
      print('Food item with ID $foodIdToDelete deleted.');
    }

    // Fetch food items again to see the delete result (for delete check)
    foodItems = await fetchFoodItems();
    print('Fetched food items after delete: $foodItems');

    // Debug: Print all tables and their data
    await dbHelper.debugShowTables();

    print('Database setup and testing complete.');
  } catch (e) {
    print('Error during database setup: $e'); // Print any errors
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Database Setup Complete!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
