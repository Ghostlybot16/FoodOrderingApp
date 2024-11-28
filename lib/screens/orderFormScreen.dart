import 'package:flutter/material.dart';
import '../database/crudOperations.dart'; // CRUD operations
import '../database/databaseSetup.dart'; // Database helper
import 'foodListScreen.dart'; // Food list screen for selecting food

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({Key? key}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  List<Map<String, dynamic>> foodItems = []; // To store food items from the database
  List<Map<String, dynamic>> selectedItems = []; // To store selected food items
  final TextEditingController targetCostController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // Store selected date

  // Function to handle saving the order
  void _saveOrder() async {
    if (selectedItems.isEmpty || targetCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select food items and set target cost')),
      );
      return;
    }

    // Convert selected items into a string for storage
    final selectedItemNames = selectedItems.map((item) => item['name']).join(', ');

    // Save the order plan into the database
    await DatabaseHelper.instance.saveOrderPlan(
      selectedDate.toIso8601String().split('T').first, // Use the selected date (in yyyy-MM-dd format)
      double.tryParse(targetCostController.text) ?? 0.0, // Parse the target cost
      selectedItemNames,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order saved successfully!')),
    );

    // Navigate to the saved orders screen after saving the order
    Navigator.pushNamed(context, '/savedOrders');
  }

  // Function to handle food item selection
  void _selectFoodItem(Map<String, dynamic> foodItem) {
    setState(() {
      if (selectedItems.contains(foodItem)) {
        selectedItems.remove(foodItem);
      } else {
        selectedItems.add(foodItem);
      }
    });
  }

  // Function to open the date picker
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: Column(
        children: [
          // Target cost input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: targetCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Date Picker input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List food items to choose from
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchFoodItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  foodItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = foodItems[index];
                      final isSelected = selectedItems.contains(foodItem);

                      return CheckboxListTile(
                        title: Text(foodItem['name']),
                        subtitle: Text('\$${foodItem['cost']}'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _selectFoodItem(foodItem);
                        },
                      );
                    },
                  );
                }

                return const Center(child: Text('No food items available.'));
              },
            ),
          ),

          // Save order button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveOrder,
              child: const Text('Save Order'),
            ),
          ),
        ],
      ),
    );
  }
}
