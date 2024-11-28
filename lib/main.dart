import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/add_foodScreen.dart';
import 'package:food_ordering_app/database/crudOperations.dart'; // Import CRUD operations
import 'package:food_ordering_app/screens/foodListScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is fully initialized

  // Clear food items and reset auto-increment counters before app starts
  await clearFoodItemsIfNeeded();
  await clearOrderPlansIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const HomeScreen(), // Home screen
        '/addFood': (context) => const AddFoodScreen(), // Add food screen
        '/foodList': (context) => const FoodListScreen(), // List food items screen
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to FoodListScreen
                Navigator.pushNamed(context, '/foodList');
              },
              child: const Text('Go to Food List'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to AddFoodScreen
                Navigator.pushNamed(context, '/addFood');
              },
              child: const Text('Add Food Item'),
            ),
          ],
        ),
      ),
    );
  }
}

