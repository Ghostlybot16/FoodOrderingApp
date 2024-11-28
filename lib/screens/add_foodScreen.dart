import 'package:flutter/material.dart';
import '../database/crudOperations.dart';
import '../styles/styles_add_foodscreen.dart'; // Import the styles

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  // Function to handle adding a new food item
  void _addFoodItem() async {
    final name = nameController.text;
    final cost = double.tryParse(costController.text);

    // Validate input
    if (name.isEmpty || cost == null || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid food name and cost!')),
      );
      return;
    }

    // Insert the food item into the database
    await insertFoodItem(name, cost);

    // Fetch food items after insertion for validation
    List<Map<String, dynamic>> foodItems = await fetchFoodItems();

    // Debug: Print the fetched food items
    print('Food items after insertion: $foodItems');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item added successfully!')),
    );

    // Clear the input fields
    nameController.clear();
    costController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
      ),
      body: Padding(
        padding: AddFoodScreenStyles.screenPadding, // Apply screen padding from styles
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food name input
            TextField(
              controller: nameController,
              decoration: AddFoodScreenStyles.inputDecoration, // Apply input decoration from styles
            ),
            AddFoodScreenStyles.inputSpacing, // Apply spacing from styles

            // Food cost input
            TextField(
              controller: costController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: AddFoodScreenStyles.inputDecoration.copyWith(
                labelText: 'Cost', // Modify the label text for cost input
              ),
            ),
            const SizedBox(height: 32),

            // Add button
            Center(
              child: ElevatedButton(
                onPressed: _addFoodItem,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Add Food Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
