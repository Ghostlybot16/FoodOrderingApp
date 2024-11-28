import 'package:flutter/material.dart';
import 'package:food_ordering_app/database/crudOperations.dart'; // Import CRUD operations
import 'package:food_ordering_app/screens/add_foodScreen.dart'; // Import AddFoodScreen for navigation
import 'package:food_ordering_app/styles/styles_foodListScreen.dart'; // Import styles for this screen

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  late Future<List<Map<String, dynamic>>> _foodItems = Future.value([]); // Initialize it with an empty list

  // Fetch food items from the database
  Future<void> fetchFoodItemsFromDatabase() async {
    List<Map<String, dynamic>> fetchedFoodItems = await fetchFoodItems(); // Fetch the food items from the database
    setState(() {
      _foodItems = Future.value(fetchedFoodItems); // Update the state
    });
  }

  @override
  void initState() {
    super.initState();
    print("Navigating to FoodListScreen and fetching food items...");
    fetchFoodItemsFromDatabase(); // Initial fetch of food items
  }

  // Handle editing a food item
  void _editFoodItem(Map<String, dynamic> foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(
          foodItem: foodItem, // Pass the food item to the AddFoodScreen
        ),
      ),
    );
  }

  // Handle deleting a food item
  void _deleteFoodItem(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Food Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteFoodItem(id); // Call delete function from CRUD
      fetchFoodItemsFromDatabase(); // Refresh the food items list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FoodListScreenStyles.appBarStyle,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _foodItems, // Use the renamed variable
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food items available.'));
          }

          final foodList = snapshot.data!;

          return ListView.builder(
            itemCount: foodList.length,
            itemBuilder: (context, index) {
              final foodItem = foodList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(foodItem['name'], style: FoodListScreenStyles.titleTextStyle),
                  subtitle: Text('\$${foodItem['cost']}', style: FoodListScreenStyles.subtitleTextStyle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editFoodItem(foodItem), // Handle edit action
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFoodItem(foodItem['id']), // Handle delete action
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
