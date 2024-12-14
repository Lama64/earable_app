import 'package:earable_app/models/session.dart';
import 'package:earable_app/widgets/add_dialog.dart';
import 'package:earable_app/widgets/session_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sessions = <Session>[];

  void _addNewSession(Session session) {
    setState(() {
      _sessions.insert(0, session);
    });
  }

  void _deleteSession(int id) {
    setState(() {
      _sessions.removeWhere((element) => element.id == id);
    });
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
