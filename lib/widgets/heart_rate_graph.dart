import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateGraph extends StatefulWidget {
  const HeartRateGraph({super.key, required this.heartRatePoints});

  final List<FlSpot> heartRatePoints;

  @override
  State<HeartRateGraph> createState() => _HeartRateGraphState();
}

class _HeartRateGraphState extends State<HeartRateGraph> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double listMaxY = widget.heartRatePoints
        .fold<double>(0, (max, point) => point.y > max ? point.y : max);
    double listMinY = widget.heartRatePoints
        .fold<double>(double.infinity, (min, point) => point.y < min ? point.y : min);
    return LineChart(LineChartData(
        minX: widget.heartRatePoints.isNotEmpty
            ? widget.heartRatePoints.first.x
            : 0,
        maxX: widget.heartRatePoints.isNotEmpty
            ? widget.heartRatePoints.last.x
            : 30,
        maxY: listMaxY > 120 ? listMaxY : 120,
        minY: listMinY < 60 ? listMinY : 60,
        titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 25)),
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
