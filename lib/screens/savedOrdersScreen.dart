import 'package:flutter/material.dart';
import '../database/databaseSetup.dart'; // Ensure DatabaseHelper is imported

class SavedOrdersScreen extends StatefulWidget {
  const SavedOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SavedOrdersScreen> createState() => _SavedOrdersScreenState();
}

class _SavedOrdersScreenState extends State<SavedOrdersScreen> {
  List<Map<String, dynamic>> savedOrders = [];
  String queryDate = ""; // Holds the date string for filtering

  @override
  void initState() {
    super.initState();
    _fetchSavedOrders(); // Initial fetch without filtering
  }

  // Fetch saved orders, optionally filtered by date
  Future<void> _fetchSavedOrders({String? date}) async {
    final orders = await DatabaseHelper.instance.fetchSavedOrders(date: date); // Pass date if provided
    setState(() {
      savedOrders = orders;
    });
  }

  // Show date picker to select a date for filtering
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        queryDate = formattedDate;
      });
      _fetchSavedOrders(date: queryDate);
    }
  }

  // Function to handle deleting an order
  void _deleteOrder(Map<String, dynamic> order) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              // Call the delete method
              await DatabaseHelper.instance.deleteOrder(order['id']);

              // Refresh the orders list after deletion
              _fetchSavedOrders();
            },
          ),
        ],
      ),
    );
  }

  // Function to handle editing an order (with date editing)
  void _editOrder(Map<String, dynamic> order) {
    final targetCostController = TextEditingController(text: order['target_cost'].toString());
    final selectedItemsController = TextEditingController(text: order['selected_items']);
    final dateController = TextEditingController(text: order['date']); // Add the date controller

    // Show a dialog where the user can edit the order details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Order'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Order Date'),
                  readOnly: true, // Make it read-only so the user can select a date
                  onTap: () async {
                    // Open a date picker when the date field is tapped
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(order['date']),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      final formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      dateController.text = formattedDate; // Update the date in the text field
                    }
                  },
                ),
                TextField(
                  controller: targetCostController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Cost'),
                ),
                TextField(
                  controller: selectedItemsController,
                  decoration: const InputDecoration(labelText: 'Selected Items'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Get the updated values
                final updatedDate = dateController.text;
                final updatedTargetCost = double.tryParse(targetCostController.text) ?? 0.0;
                final updatedSelectedItems = selectedItemsController.text;

                // Update the order in the database
                await DatabaseHelper.instance.updateOrder(
                  order['id'],
                  updatedDate,
                  updatedTargetCost,
                  updatedSelectedItems,
                );

                // Close the dialog and refresh the orders list
                Navigator.of(context).pop();
                _fetchSavedOrders(); // Fetch the updated list
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: savedOrders.isEmpty
          ? const Center(child: Text('No saved orders found.'))
          : ListView.builder(
        itemCount: savedOrders.length,
        itemBuilder: (context, index) {
          final order = savedOrders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text('Date: ${order['date']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Cost: \$${order['target_cost']}'),
                  Text('Selected Items: ${order['selected_items']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      _editOrder(order);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () {
                      _deleteOrder(order);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
