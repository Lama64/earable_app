import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'package:earable_app/widgets/heart_rate_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage(
      {super.key, required this.session});

  final Session session;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  double _calculateAVGHeartRate() {
    double sum = widget.session.heartRatePoints
        .map((point) => point.y)
        .reduce((a, b) => a + b);
    return sum / widget.session.heartRatePoints.length;
  }

  @override
  Widget build(BuildContext context) {
    BluetoothService bluetoothService = Provider.of<BluetoothService>(context);
    _calculateAVGHeartRate();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text('${bluetoothService.heartRate} bpm',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: HeartRateGraph(
                  heartRatePoints: widget.session.heartRatePoints),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                const Text('Status: '),
                Text(bluetoothService.connectionStatus),
              ]),
              Text('Heart Rate: ${bluetoothService.heartRate} bpm'),
              Row(children: [
                Text(
                    'AVG Heart Rate: ${_calculateAVGHeartRate().toStringAsFixed(1)} bpm'),
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
    );
  }
}
