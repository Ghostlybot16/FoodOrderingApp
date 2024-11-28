import 'package:flutter/material.dart';
import '../database/crudOperations.dart';
import '../styles/styles_add_foodscreen.dart'; // Import the styles

class AddFoodScreen extends StatefulWidget {
  final Map<String, dynamic>? foodItem;  // Accept foodItem as a named parameter

  const AddFoodScreen({Key? key, this.foodItem}) : super(key: key);  // Constructor to accept foodItem

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If a foodItem is passed for editing, populate the text controllers
    if (widget.foodItem != null) {
      nameController.text = widget.foodItem!['name'];
      costController.text = widget.foodItem!['cost'].toString();
    }
  }

  // Function to handle adding or editing a food item
  void _saveFoodItem() async {
    final name = nameController.text;
    final cost = double.tryParse(costController.text);

    // Validate input
    if (name.isEmpty || cost == null || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid food name and cost!')),
      );
      return;
    }

    if (widget.foodItem == null) {
      // If no foodItem exists (creating a new item)
      await insertFoodItem(name, cost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item added successfully!')),
      );
    } else {
      // If foodItem exists (editing an existing item)
      await updateFoodItem(widget.foodItem!['id'], name, cost);  // Update the existing food item
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item updated successfully!')),
      );
    }

    // Clear the input fields after saving
    nameController.clear();
    costController.clear();

    // Go back to the previous screen
    Navigator.pop(context);
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
                onPressed: _saveFoodItem,  // Use the updated function to save the item
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text(widget.foodItem == null ? 'Add Food Item' : 'Update Food Item'), // Change the button text depending on mode
              ),
            ),
          ],
        ),
      ),
    );
  }
}
