import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'package:earable_app/widgets/heart_rate_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.session});

  final Session session;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.name)),
      body: Consumer<BluetoothService>(
        builder: (context, bluetoothService, child) => Column(
          children: [
            SizedBox(
              height: 300,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: HeartRateGraph(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  const Text('Status: '),
                  Text(bluetoothService.connectionStatus),
                ]),
                Row(children: [
                  const Text('Heart Rate: '),
                  Text(bluetoothService.heartRate),
                ]),
                Row(children: [
                  const Text('Accelerometer X: '),
                  Text(bluetoothService.accX),
                ]),
                Row(children: [
                  const Text('Accelerometer Y: '),
                  Text(bluetoothService.accY),
                ]),
                Row(children: [
                  const Text('Accelerometer Z: '),
                  Text(bluetoothService.accZ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
