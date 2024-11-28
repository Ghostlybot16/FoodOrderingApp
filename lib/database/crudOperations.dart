import 'package:sqflite/sqflite.dart';
import 'package:food_ordering_app/database/databaseSetup.dart';

// Function to fetch all food items
Future<List<Map<String, dynamic>>> fetchFoodItems() async {
  final db = await DatabaseHelper.instance.database;
  return await db.query('food_items');
}

// Function to insert a food item
Future<void> insertFoodItem(String name, double cost) async {
  final db = await DatabaseHelper.instance.database;
  await db.insert('food_items', {'name': name, 'cost': cost});
}

// Function to update a food item
Future<void> updateFoodItem(int id, String name, double cost) async {
  final db = await DatabaseHelper.instance.database;
  await db.update(
    'food_items',
    {'name': name, 'cost': cost},
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Function to populate the database with sample food items (20 items)
Future<void> populateFoodItems() async {
  final db = await DatabaseHelper.instance.database;
  final existingItems = await db.query('food_items');

  // Only populate the table if it is empty
  if (existingItems.isEmpty) {
    List<Map<String, dynamic>> sampleFoodItems = [
      {'name': 'Pizza', 'cost': 8.99},
      {'name': 'Burger', 'cost': 5.99},
      {'name': 'Butter Chicken', 'cost': 12.99},
      {'name': 'Pasta', 'cost': 7.49},
      {'name': 'Salad', 'cost': 4.99},
      {'name': 'Sandwich', 'cost': 3.99},
      {'name': 'Fried Chicken', 'cost': 9.99},
      {'name': 'Steak', 'cost': 14.99},
      {'name': 'Tacos', 'cost': 6.99},
      {'name': 'Wrap', 'cost': 5.49},
      {'name': 'Hot Dog', 'cost': 3.49},
      {'name': 'Nachos', 'cost': 4.49},
      {'name': 'Burrito', 'cost': 7.99},
      {'name': 'Ice Cream', 'cost': 3.49},
      {'name': 'Fries', 'cost': 2.99},
      {'name': 'Coke', 'cost': 1.99},
      {'name': 'Soup', 'cost': 4.59},
      {'name': 'Root Beer', 'cost': 1.99},
      {'name': 'Mango Juice', 'cost': 1.99},
      {'name': 'Chocolate Smoothie', 'cost': 4.99},
    ];

    // Insert sample items into the database
    for (var item in sampleFoodItems) {
      await insertFoodItem(item['name']!, item['cost']!);
    }

    print('Sample food items added to the database.');
  }
}

// Function to delete a food item
Future<void> deleteFoodItem(int id) async {
  final db = await DatabaseHelper.instance.database;
  await db.delete(
    'food_items',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> clearFoodItemsIfNeeded() async {
  final db = await DatabaseHelper.instance.database;
  final foodItems = await db.query('food_items');
  if (foodItems.isNotEmpty) {
    await db.delete('food_items'); // Delete all if there are any items
    await db.rawDelete('DELETE FROM sqlite_sequence WHERE name="food_items"'); // Reset auto-increment counter
    print('Food items table cleared and ID counter reset.');
  }
}

Future<void> clearOrderPlansIfNeeded() async {
  final db = await DatabaseHelper.instance.database;
  final orderPlans = await db.query('order_plans');
  if (orderPlans.isNotEmpty) {
    await db.delete('order_plans'); // Delete all if there are any plans
    await db.rawDelete('DELETE FROM sqlite_sequence WHERE name="order_plans"'); // Reset auto-increment counter
    print('Order plans table cleared and ID counter reset.');
  }
}