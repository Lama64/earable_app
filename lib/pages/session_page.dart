import 'package:earable_app/models/session.dart';
import 'package:earable_app/services/bluetooth_service.dart';
import 'package:earable_app/widgets/heart_rate_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.session});

  final Session session;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late BluetoothService bluetoothService;

  double _calculateAVG(List<FlSpot> list) {
    if (list.isEmpty) {
      return 0;
    }
    double sum = list.map((e) => e.y).reduce((a, b) => a + b);
    return sum / list.length;
  }

  String classifyMovement() {
    double amount =
        widget.session.amountOverThreshold / widget.session.totalMovementAmount;
    if (amount < 0.05) {
      return 'low';
    } else if (amount < 0.085) {
      return 'medium';
    } else {
      return 'high';
    }
  }

  String _durationToFormatString(double seconds) {
    Duration duration = Duration(seconds: seconds.toInt());
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    bluetoothService = Provider.of<BluetoothService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.session.name,
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
                bluetoothService.useSimulatedHeartRate &&
                        bluetoothService.isConnected
                    ? '${bluetoothService.simulatedHeartRate} bpm'
                    : '${bluetoothService.heartRate} bpm',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: HeartRateGraph(
                    heartRatePoints: widget.session.heartRatePoints),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(16), child: buildInformationTable()),
          ],
        ),
      ),
    );
  }

  Widget buildInformationTable() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
            border: Border.all(width: 1)),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(width: 1)),
          children: [
            TableRow(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10))),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AVG HR:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_calculateAVG(widget.session.heartRatePoints).toStringAsFixed(1)} bpm',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Max HR:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.session.heartRatePoints.fold(0, (max, point) => point.y > max ? point.y.toInt() : max)} bpm',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10))),
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Duration:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _durationToFormatString(widget.session.duration),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Movement:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        classifyMovement(),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
