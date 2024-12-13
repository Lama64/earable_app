import 'package:earable_app/models/session.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key, required this.onAddPressed});

  final void Function(Session) onAddPressed;

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _testController = TextEditingController();
  final _testFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocusNode.requestFocus();
  }

  void focusNextField(
      BuildContext context, FocusNode currentNode, FocusNode? nextNode) {
    currentNode.unfocus();
    if (nextNode != null) {
      FocusScope.of(context).requestFocus(nextNode);
    } else {
      widget.onAddPressed(Session(
          id: DateTime.now().millisecondsSinceEpoch,
          name: _nameController.text));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(labelText: 'Name'),
            onSubmitted: (_) =>
                focusNextField(context, _nameFocusNode, _testFocusNode),
          ),
          TextField(
            controller: _testController,
            focusNode: _testFocusNode,
            decoration: InputDecoration(labelText: 'Test'),
            onSubmitted: (_) => focusNextField(context, _testFocusNode, null),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('close')),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _testController.dispose();
    _nameFocusNode.dispose();
    _testFocusNode.dispose();
    super.dispose();
  }
}
