import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Remove the leading `/` from the path

void main() {
  runApp(const QuickBiteApp()); // Adding 'const' here as per lint suggestion
}

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key}); // Add key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Adding 'const' to HomeScreen as suggested
    );
  }
}