import 'package:flutter/material.dart';
import 'package:food_ordering_app/database/databaseSetup.dart'; // Import the database helper

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

    // Insert test data
    await dbHelper.insertTestData();

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
            'Database Setup and Testing Complete!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
