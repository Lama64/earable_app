import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Contains all information for a session.
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
  String dateCreated = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  /// Steam ID of the game, when session is created from steam.
  final int? gameId;

  /// URL of the game logo, used as background of session item.
  final String? logoUrl;

  int totalMovementAmount = 0;
  int amountOverThreshold = 0;

  List<FlSpot> heartRatePoints = [];
  double duration = 0;

  Session copyWith({
    int? id,
    String? name,
    Color? backgroundColor,
    int? gameId,
    String? logoUrl,
    double? duration = 0,
    List<FlSpot>? heartRatePoints,
  }) {
    return Session(
        id: id ?? this.id,
        name: name ?? this.name,
        gameId: gameId ?? this.gameId,
        logoUrl: logoUrl ?? this.logoUrl,
        backgroundColor: backgroundColor ?? this.backgroundColor)
      ..duration = duration ?? this.duration
      ..heartRatePoints = heartRatePoints ?? this.heartRatePoints
      ..dateCreated = dateCreated
      ..totalMovementAmount = totalMovementAmount
      ..amountOverThreshold = amountOverThreshold;
  }
}
