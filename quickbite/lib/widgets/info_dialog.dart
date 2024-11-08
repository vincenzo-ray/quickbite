import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('How to Use QuickBite'),
      content: Text(
          "Use this app by entering ingredients available to you. Confirm your ingredients, and the app will search for possible meals. Select a meal to see a picture, ingredients, and recipe steps. You may also find a link to the full recipe online."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}