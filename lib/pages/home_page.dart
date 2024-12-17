import 'package:earable_app/models/session.dart';
import 'package:earable_app/widgets/add_dialog.dart';
import 'package:earable_app/widgets/session_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  final steamId = '76561198240597364';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sessions = <Session>[];
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

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

  List<Session> _filterSessions() {
    return _sessions
        .where((session) =>
            session.name.toLowerCase().contains(_searchTerm.toLowerCase()))
        .toList();
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
            _buildSearch(),
            Expanded(
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
                      steamId: widget.steamId,
                    ));
          },
          child: const Icon(Icons.add),
        ));
  }

  Widget _buildSearch() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
            icon: Icon(Icons.search),
          ),
          controller: _searchController,
        ));
  }

  Widget _buildList() {
    final filteredSessions = _filterSessions();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredSessions.length,
      itemBuilder: (context, index) {
        final session = filteredSessions[index];
        return SessionItem(
            session: session, onDelete: () => _deleteSession(session.id));
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
