import 'dart:convert';

import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'package:earable_app/widgets/add_dialog.dart';
import 'package:earable_app/widgets/session_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main page of app, displays all sessions.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sessions = <Session>[];
  final _searchController = TextEditingController();
  String _searchTerm = '';

  /// Filled with input in settings, 17 digit Steam ID or the custom url set in Steam.
  String _steamId = '';

  /// Used to get information from earable, initialised in the build function.
  late BluetoothService bluetoothService;

  /// Whether to use simulated heart rate or sensor data.
  bool _useSimulatedHeartRate = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  /// Saves the [_steamId] to shared preferences.
  Future<void> _saveSteamId() async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString('steamID', _steamId);
  }

  /// Saves the [_sessions] to shared preferences.
  Future<void> _saveSessions() async {
    final storage = await SharedPreferences.getInstance();
    final sessionsJson = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await storage.setString('sessions', sessionsJson);
  }

  /// Loads the sessions and steam ID from shared preferences.
  Future<void> _loadData() async {
    final storage = await SharedPreferences.getInstance();
    final sessionsJson = storage.getString('sessions');
    final steamId = storage.getString('steamID');
    if (sessionsJson != null) {
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      _sessions.clear();
      for (final session in sessionsList) {
        _sessions.add(Session.fromJson(session));
      }
    }
    if (steamId != null) {
      _steamId = steamId;
    }
  }

  /// Adds a new [Session] to [_sessions].
  void _addNewSession(Session session) {
    setState(() {
      bluetoothService.startSessionLogging(_useSimulatedHeartRate, session);
      _sessions.insert(0, session);
    });
  }

  /// Deletes the session with [id] from [_sessions].
  void _deleteSession(int id) {
    setState(() {
      _sessions.removeWhere((element) => element.id == id);
      if (bluetoothService.activeSessionId == id) {
        bluetoothService.endSessionLogging();
      }
    });
  }

  /// Filters the sessions based on [_searchTerm].
  List<Session> _filterSessions() {
    return _sessions
        .where((session) =>
            session.name.toLowerCase().contains(_searchTerm.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    bluetoothService = Provider.of<BluetoothService>(context);
    bluetoothService.saveDataCallback = _saveSessions;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
        ),
        actions: [
          /// Current heart rate, depending on [_useSimulatedHeartRate].
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
                _useSimulatedHeartRate && bluetoothService.isConnected
                    ? '${bluetoothService.simulatedHeartRate} bpm'
                    : '${bluetoothService.heartRate} bpm',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),

      /// Settings menu.
      drawer: _buildDrawer(),
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

        /// Icon changes based on connection status and wheter a session is active.
        child: Icon(bluetoothService.isConnected
            ? (bluetoothService.activeSessionId != -1 ? Icons.stop : Icons.add)
            : Icons.bluetooth_searching_sharp),
      ),
    );
  }

  /// Search bar to filter sessions.
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

  /// List of all sessions.
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

  /// Menu to set steam ID and toggle simulated heart rate.
  Widget _buildDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
          ),
          child: Text('Settings'),
        ),

        /// Toggle simulated heart rate.
        SwitchListTile(
          title: Text('Use simulated heart rate'),
          value: _useSimulatedHeartRate,
          onChanged: (value) {
            setState(() {
              bluetoothService.useSimulatedHeartRate = value;
              _useSimulatedHeartRate = value;
            });
          },
        ),

        /// Input for Steam ID.
        Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              initialValue: _steamId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Steam ID / custom URL',
              ),
              onChanged: (value) {
                _steamId = value;
                _saveSteamId();
              },
            ))
      ],
    ));
  }

  /// Handles the floating action button press.
  void fabOnPressed() async {
    if (bluetoothService.isConnected &&
        bluetoothService.activeSessionId == -1) {
      /// Add new session.
      showDialog(
          context: context,
          builder: (context) {
            return AddDialog(
              onAddPressed: (session) {
                Navigator.pop(context);
                _addNewSession(session);
              },
              steamId: _steamId,
            );
          });
    } else if (bluetoothService.isConnected) {
      /// Stop Session.
      bluetoothService.endSessionLogging();
    } else {
      /// Connect to device.
      await bluetoothService.connect(context);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
