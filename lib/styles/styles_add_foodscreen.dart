import 'package:flutter/material.dart';

class AddFoodScreenStyles {
  // General padding for the whole screen
  static const EdgeInsetsGeometry screenPadding = EdgeInsets.all(16.0);

  // Input field decoration style
  static const InputDecoration inputDecoration = InputDecoration(
    labelText: 'Food Name',
    border: OutlineInputBorder(),
  );

  // SizedBox for spacing between elements
  static const SizedBox inputSpacing = SizedBox(height: 16);
}
