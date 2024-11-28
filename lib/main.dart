import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/add_foodScreen.dart';
import 'package:food_ordering_app/database/crudOperations.dart'; // Import CRUD operations
import 'package:food_ordering_app/screens/foodListScreen.dart';
import 'package:food_ordering_app/screens/orderFormScreen.dart';
import 'package:food_ordering_app/screens/savedOrdersScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is fully initialized

  // Clear food items and reset auto-increment counters before app starts
  //await clearFoodItemsIfNeeded();
  //await clearOrderPlansIfNeeded();

  // Populate food items with sample data of 20 food items
  await populateFoodItems();

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
        '/orderForm': (context) => const OrderFormScreen(),
        '/savedOrders': (context) => const SavedOrdersScreen(),
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
            ElevatedButton(
              onPressed: () {
                // Navigate to OrderFormScreen (Order Form)
                Navigator.pushNamed(context, '/orderForm');
              },
              child: const Text('Go to Order Form'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to SavedOrdersScreen (Saved Orders)
                Navigator.pushNamed(context, '/savedOrders');
              },
              child: const Text('View Saved Orders'),
            ),
          ],
        ),
      ),
    );
  }
}


