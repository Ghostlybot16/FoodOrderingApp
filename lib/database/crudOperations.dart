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