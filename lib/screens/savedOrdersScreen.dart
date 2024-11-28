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

  // Function to handle editing an order
  void _editOrder(Map<String, dynamic> order) {
    // Show a dialog where the user can edit the order details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final targetCostController = TextEditingController(text: order['target_cost'].toString());
        final selectedItemsController = TextEditingController(text: order['selected_items']);

        return AlertDialog(
          title: Text('Edit Order for ${order['date']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Target Cost'),
              ),
              TextField(
                controller: selectedItemsController,
                decoration: InputDecoration(labelText: 'Selected Items'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without making any changes
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Get updated values from the controllers
                final updatedTargetCost = double.tryParse(targetCostController.text) ?? 0.0;
                final updatedSelectedItems = selectedItemsController.text;

                if (updatedTargetCost > 0 && updatedSelectedItems.isNotEmpty) {
                  // Call the update method to update the order in the database
                  await DatabaseHelper.instance.updateOrder(
                    order['id'], // Order ID
                    order['date'], // Keep the date the same (or let the user edit if needed)
                    updatedTargetCost,
                    updatedSelectedItems,
                  );

                  // Refresh the order list after update
                  _fetchSavedOrders();
                } else {
                  // You can show an error message here if validation fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid data')),
                  );
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save Changes'),
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
            onPressed: _selectDate, // Trigger date picker for filtering
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
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editOrder(order),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(order),
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
