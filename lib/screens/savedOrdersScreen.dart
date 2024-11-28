import 'package:flutter/material.dart';
import '../database/databaseSetup.dart';

class SavedOrdersScreen extends StatefulWidget {
  const SavedOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SavedOrdersScreen> createState() => _SavedOrdersScreenState();
}

class _SavedOrdersScreenState extends State<SavedOrdersScreen> {
  List<Map<String, dynamic>> savedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedOrders();
  }

  Future<void> _fetchSavedOrders() async {
    final orders = await DatabaseHelper.instance.fetchSavedOrders();
    setState(() {
      savedOrders = orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Orders'),
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
            ),
          );
        },
      ),
    );
  }
}
