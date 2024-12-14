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

  void _focusNextField(
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
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Name'),
            onSubmitted: (_) =>
                _focusNextField(context, _nameFocusNode, _testFocusNode),
          ),
          TextField(
            controller: _testController,
            focusNode: _testFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Test'),
            onSubmitted: (_) => _focusNextField(context, _testFocusNode, null),
          )
        ],
      ),
      actions: <Widget>[
        //Cancel
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel')),
        //Create
        TextButton(
            onPressed: () {
              widget.onAddPressed(Session(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: _nameController.text));
              Navigator.pop(context);
            },
            child: Text('Create'))
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
