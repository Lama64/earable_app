import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateGraph extends StatefulWidget {
  const HeartRateGraph({super.key});

  @override
  State<HeartRateGraph> createState() => _HeartRateGraphState();
}

class _HeartRateGraphState extends State<HeartRateGraph> {
  List<FlSpot> _heartRatePoints = [];
  int _elapsedTime = 0;

  @override
  void initState() {
    _generateSampleData();
    super.initState();
  }

  void _generateSampleData() {
    // Generate some example heart rate points
    List<double> sampleRates = [72, 75, 78, 74, 70, 76, 80, 82, 78, 74];
    setState(() {
      _heartRatePoints = List<FlSpot>.generate(
        sampleRates.length,
        (index) => FlSpot(index.toDouble() * 2,
            sampleRates[index]), // x = time, y = heart rate
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(LineChartData(
        minX: _heartRatePoints.isNotEmpty ? _heartRatePoints.first.x : 0,
        maxX: _heartRatePoints.isNotEmpty ? _heartRatePoints.last.x : 30,
        minY: 40,
        maxY: 120,
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
              spots: _heartRatePoints,
              isCurved: true,
              barWidth: 3,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false))
        ]));
  }
}
