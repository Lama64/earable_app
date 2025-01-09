import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'package:earable_app/widgets/add_dialog.dart';
import 'package:earable_app/widgets/session_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late BluetoothService bluetoothService;
  bool _useSimulatedHeartRate = true;

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
      bluetoothService.updateHeartRatePoints(_useSimulatedHeartRate, session);
      _sessions.insert(0, session);
    });
  }

  void _deleteSession(int id) {
    setState(() {
      _sessions.removeWhere((element) => element.id == id);
      if (bluetoothService.activeSessionId == id) {
        bluetoothService.stopHeartRatePoints();
      }
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
    bluetoothService = Provider.of<BluetoothService>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
                _useSimulatedHeartRate
                    ? '${bluetoothService.heartRate} bpm'
                    : '${bluetoothService.simulatedHeartRate} bpm',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(),
          Expanded(
            child: _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fabOnPressed,
        child: Icon(bluetoothService.isConnected
            ? (bluetoothService.activeSessionId != -1 ? Icons.stop : Icons.add)
            : Icons.bluetooth_searching_sharp),
      ),
    );
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

  void fabOnPressed() async {
    if (bluetoothService.isConnected &&
        bluetoothService.activeSessionId == -1) {
      // add session
      showDialog(
        context: context,
        builder: (context) => AddDialog(
          onAddPressed: (session) {
            try {
              _addNewSession(session);
            } catch (exception) {
              Navigator.pop(context);
              _showError(context, exception.toString());
            }
          },
          steamId: widget.steamId,
        ),
      );
    } else if (bluetoothService.isConnected) {
      // stop session
      bluetoothService.stopHeartRatePoints();
    } else {
      // connect
      try {
        await bluetoothService.connect();
      } catch (exception) {
        if (mounted) {
          _showError(context, exception.toString());
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
