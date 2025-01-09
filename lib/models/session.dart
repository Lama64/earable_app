import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Session {
  Session({
    required this.id,
    required this.name,
    required this.backgroundColor,
    this.gameId,
    this.logoUrl,
  });

  final int id;
  final String name;
  final Color backgroundColor;
  final int? gameId;
  final String? logoUrl;
  List<FlSpot> heartRatePoints = [];
  double elapsedTime = 0;
  String dateCreated = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  Session copyWith({
    int? id,
    String? name,
    Color? backgroundColor,
    int? gameId,
    String? logoUrl,
    List<FlSpot>? heartRatePoints,
  }) {
    return Session(
        id: id ?? this.id,
        name: name ?? this.name,
        gameId: gameId ?? this.gameId,
        logoUrl: logoUrl ?? this.logoUrl,
        backgroundColor: backgroundColor ?? this.backgroundColor)
      ..elapsedTime =
          heartRatePoints != null ? heartRatePoints.length / 2 : elapsedTime
      ..heartRatePoints = heartRatePoints ?? this.heartRatePoints
      ..dateCreated = dateCreated;
  }
}
