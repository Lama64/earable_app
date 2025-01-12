import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Graph to display the heart rate over time.
class HeartRateGraph extends StatefulWidget {
  const HeartRateGraph({super.key, required this.heartRatePoints});

  /// Points for the graph, created by the [BluetoothService].
  final List<FlSpot> heartRatePoints;

  @override
  State<HeartRateGraph> createState() => _HeartRateGraphState();
}

class _HeartRateGraphState extends State<HeartRateGraph> {
  @override
  Widget build(BuildContext context) {
    /// Max y value in the list of points.
    double listMaxY = widget.heartRatePoints
        .fold<double>(0, (max, point) => point.y > max ? point.y : max);

    /// Min y value in the list of points.
    double listMinY = widget.heartRatePoints.fold<double>(
        double.infinity, (min, point) => point.y < min ? point.y : min);
    return LineChart(LineChartData(

        /// X value of first point is start time of the graph.
        minX: widget.heartRatePoints.isNotEmpty
            ? widget.heartRatePoints.first.x
            : 0,

        /// X value of last point is end time of the graph.
        maxX: widget.heartRatePoints.isNotEmpty
            ? widget.heartRatePoints.last.x
            : 30,

        /// Y values from 60 to 120, changes to fit the data, if outside of the range.
        maxY: listMaxY > 120 ? listMaxY : 120,
        minY: listMinY < 60 ? listMinY : 60,
        titlesData: FlTitlesData(

            /// Left axis shows the heart rate.
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),

            /// Bottom axis shows the time.
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 25)),

            /// Right and top titles are hidden.
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
              spots: widget.heartRatePoints,
              isCurved: true,
              barWidth: 3,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false))
        ]));
  }
}
