import 'package:flutter/material.dart';
import '../database/crudOperations.dart'; // CRUD operations
import '../database/databaseSetup.dart'; // Database helper

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({Key? key}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  List<Map<String, dynamic>> foodItems = []; // To store all food items
  List<Map<String, dynamic>> filteredFoodItems = []; // To store filtered food items based on cost
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

  // Function to fetch all food items from the database and filter them based on target cost
  Future<void> _fetchFoodItems() async {
    final fetchedFoodItems = await fetchFoodItems(); // Fetch the food items from your database

    setState(() {
      foodItems = fetchedFoodItems; // Store the fetched food items
      _filterFoodItems(); // Call the filter function whenever the food items are fetched or target cost is updated
    });
  }

  // Function to filter food items based on target cost
  void _filterFoodItems() {
    final targetCost = double.tryParse(targetCostController.text) ?? 0.0;
    double currentTotalCost = 0.0;

    // Filter the food items based on the target cost
    filteredFoodItems = foodItems.where((foodItem) {
      if (currentTotalCost + foodItem['cost'] <= targetCost) {
        currentTotalCost += foodItem['cost']; // Update total cost if this item is selected
        return true;
      }
      return false; // Exclude the item if it exceeds the target cost
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchFoodItems(); // Fetch the food items when the screen is first loaded
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
              onChanged: (value) {
                setState(() {
                  _filterFoodItems(); // Filter food items whenever the target cost changes
                });
              },
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Display selected date
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Selected Date: '),
                Text("${selectedDate.toLocal()}".split(' ')[0]),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),

          // List of filtered food items based on target cost
          Expanded(
            child: ListView.builder(
              itemCount: filteredFoodItems.length,
              itemBuilder: (context, index) {
                final foodItem = filteredFoodItems[index];
                return CheckboxListTile(
                  title: Text(foodItem['name']),
                  subtitle: Text('\$${foodItem['cost']}'),
                  value: selectedItems.contains(foodItem),
                  onChanged: (bool? selected) {
                    _selectFoodItem(foodItem);
                  },
                );
              },
            ),
          ),

          // Button to save the order
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
