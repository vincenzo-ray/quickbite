// info_dialog.dart
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  // Using super.key to pass the key parameter to the superclass constructor
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How to Use QuickBite'), // Dialog title
      content: const Text(
          "Use this app by entering ingredients available to you. Confirm your ingredients, and the app will search for possible meals. Select a meal to see a picture, ingredients, and recipe steps. You may also find a link to the full recipe online."), // Instructions text
      actions: [
        // Close button for the dialog
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Closes the dialog
          child: const Text('Close'), // Button text
        ),
      ],
    );
  }
}