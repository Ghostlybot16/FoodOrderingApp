import 'package:flutter/material.dart';

class FoodListScreenStyles {
  // AppBar Style
  static AppBar appBarStyle = AppBar(
    title: const Text('Food Items List'),
  );

  // Card styling for each food item
  static const Card cardStyle = Card(
    margin: EdgeInsets.all(8.0),
  );

  // Title text style for food name
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Subtitle text style for food cost
  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // IconButton styling (for edit and delete icons)
  static IconButton iconButtonStyle = IconButton(
    icon: Icon(Icons.edit),
    color: Colors.blue, // Icon color
    iconSize: 30, onPressed: () {  }, // Icon size
  );

  // AlertDialog styling
  static const AlertDialog deleteDialogStyle = AlertDialog(
    title: Text('Delete Food Item'),
    content: Text('Are you sure you want to delete this item?'),
  );
}
