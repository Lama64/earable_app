import 'package:flutter/material.dart';

/// Shows an error dialog with [message].
void showError(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Close'))
          ],
        );
      });
}
