import 'package:earable_app/models/session.dart';
import 'package:earable_app/widgets/add_dialog.dart';
import 'package:earable_app/widgets/session_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  final steamId = '76561198240597364';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sessions = <Session>[];

  void _addNewSession(Session session) {
    _fetchCurrentGame(widget.steamId);
    setState(() {
      _sessions.insert(0, session);
    });
  }

  void _deleteSession(int id) {
    setState(() {
      _sessions.removeWhere((element) => element.id == id);
    });
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
      throw Exception('There is no game being currently played.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 0,
              child: _buildList(),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AddDialog(
                      onAddPressed: _addNewSession,
                    ));
          },
          child: const Icon(Icons.add),
        ));
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return SessionItem(
            session: session, onDelete: () => _deleteSession(session.id));
      },
    );
  }
}
