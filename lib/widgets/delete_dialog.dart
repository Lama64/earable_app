import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog(
      {super.key, required this.onDeletePressed, required this.sessionName});

  final VoidCallback onDeletePressed;
  final String sessionName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Session'),
      content: Text(
          'Are you sure you want to delete the session "$sessionName"? This action can not be undone.'),
      actions: [
        // cancel button
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
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
