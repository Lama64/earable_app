import 'package:flutter/material.dart';

/// Dialog to confirm deletion of a session.
class DeleteDialog extends StatelessWidget {
  const DeleteDialog(
      {super.key, required this.onDeletePressed, required this.sessionName});

  /// Function called when the delete button is pressed.
  final VoidCallback onDeletePressed;
  final String sessionName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Session'),
      content: Text(
          'Are you sure you want to delete the session "$sessionName"? This action can not be undone.'),
      actions: [
        /// Cancel
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),

        /// Delete
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeletePressed();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)))
      ],
    );
  }
}
