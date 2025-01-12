import 'dart:math';

import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/show_error.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Dialog to add a new session.
class AddDialog extends StatefulWidget {
  const AddDialog(
      {super.key, required this.onAddPressed, required this.steamId});

  /// function called when the add button is pressed
  final void Function(Session) onAddPressed;

  /// Steam ID or custom Url
  final String steamId;

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  /// pastel rainbow colors for session item background
  static const _backgroundColors = [
    Color(0xffffb3ba),
    Color(0xffffdfba),
    Color(0xffffffba),
    Color(0xffbaffc9),
    Color(0xffbae1ff)
  ];

  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _nameFocusNode.requestFocus(); // set focus to the input field on creation
  }

  /// Fetches the currently played game of the user with [steamId].
  /// Throws an exception if the request fails or the user is not playing a game.
  Future<Session> _fetchCurrentGame(String steamId) async {
    String path;
    if (steamId == '') {
      throw Exception('A Steam ID needs to be set in the settings.');
    }

    /// Steam ID consists of 17 digits.
    if (RegExp(r'^\d{17}$').hasMatch(steamId)) {
      path = '/profiles/$steamId';
    } else {
      /// Everything else treated as custom URL.
      path = '/id/$steamId';
    }
    final profileUrl = Uri.https('steamcommunity.com', path, {'xml': '1'});
    final response = await http.get(profileUrl);

    /// Check if the request was successful.
    if (response.statusCode != 200) {
      final statusCode = response.statusCode;
      throw Exception('Request failed. Status code: $statusCode');
    }
    final xmlResponse = XmlDocument.parse(response.body);
    final inGameInfo = xmlResponse.findAllElements('inGameInfo');

    /// inGameInfo only found if a game is being played.
    if (inGameInfo.isEmpty) {
      throw Exception('There is no game currently being played.');
    }
    final currentGame = inGameInfo.first;
    final gameName = currentGame.findAllElements('gameName');
    final gameLink = currentGame.findAllElements('gameLink');
    final gameLogo = currentGame.findAllElements('gameLogo');
    if (gameLogo.length != 1 || gameLink.length != 1 || gameName.length != 1) {
      throw Exception('Information about the game is missing');
    }

    /// Game ID is the last part of the URL.
    final gameId =
        int.parse(Uri.parse(gameLink.single.innerText).pathSegments.last);
    return Session(
        id: DateTime.now().millisecondsSinceEpoch,
        name: gameName.single.innerText,
        logoUrl: gameLogo.single.innerText,
        gameId: gameId,
        backgroundColor:
            _backgroundColors[Random().nextInt(_backgroundColors.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Add from Steam.
          TextButton(
            onPressed: () async {
              Session session;
              try {
                session = await _fetchCurrentGame(widget.steamId);
              } catch (exception) {
                if (context.mounted) {
                  Navigator.pop(context);
                  showError(context, exception.toString());
                }
                return;
              }
              widget.onAddPressed(session);
            },
            child: Text('Add from Steam'),
          ),
          Divider(),

          /// Name input field.
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Name'),
            onSubmitted: (_) => widget.onAddPressed(Session(
                id: DateTime.now().millisecondsSinceEpoch,
                name: _nameController.text,
                backgroundColor: _backgroundColors[
                    Random().nextInt(_backgroundColors.length)])),
          ),
        ],
      ),
      actions: <Widget>[
        /// Cancel
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel')),

        /// Create
        TextButton(
            onPressed: () {
              widget.onAddPressed(Session(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: _nameController.text,
                  backgroundColor: _backgroundColors[
                      Random().nextInt(_backgroundColors.length)]));
            },
            child: Text('Create'))
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
