import 'package:earable_app/models/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class AddDialog extends StatefulWidget {
  const AddDialog(
      {super.key, required this.onAddPressed, required this.steamId});

  final void Function(Session) onAddPressed;
  final String steamId;

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

  Future<Session?> _fetchCurrentGame(String steamId) async {
    final profileUrl =
        Uri.https('steamcommunity.com', '/profiles/$steamId', {'xml': '1'});
    final response = await http.get(profileUrl);

    if (response.statusCode != 200) {
      final statusCode = response.statusCode;
      throw Exception('Request failed. Status code: $statusCode');
    }
    final xmlResponse = XmlDocument.parse(response.body);
    final currentGame = xmlResponse.getElement('inGameInfo');
    if (currentGame == null) {
      throw Exception('There is no game currently being played.');
    }
    final gameName = currentGame.findAllElements('gameName');
    final gameLink = currentGame.findAllElements('gameLink');
    final gameLogo = currentGame.findAllElements('gameLogo');
    if (gameLogo.length != 1 || gameLink.length != 1 || gameName.length != 1) {
      throw Exception('Information about the game is missing');
    }
    final gameId =
        int.parse(Uri.parse(gameLink.single.innerText).pathSegments.last);
    return Session(
        id: DateTime.now().millisecondsSinceEpoch,
        name: gameName.single.innerText,
        logoUrl: gameLogo.single.innerText,
        gameId: gameId);
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

  void _showError(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              try {
                final session = await _fetchCurrentGame(widget.steamId);
                widget.onAddPressed(session!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (exception) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _showError(context, exception.toString());
                }
              }
            },
            child: Text('Add from Steam'),
          ),
          Divider(),
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
