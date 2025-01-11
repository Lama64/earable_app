import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    /// Provider to get notified when the values from the earable change.
    ChangeNotifierProvider(
      create: (_) => BluetoothService(true),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const HomePage(title: 'Sessions'),
    );
  }
}
