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

  /// Name of the session.
  final String name;

  /// Background color of the session item, randomly picked from list of pastel colors.
  final Color backgroundColor;

  /// Date and time when the session was created.
  String dateCreated = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  /// Steam ID of the game, when session is created from steam.
  final int? gameId;

  /// URL of the game logo, used as background of session item.
  final String? logoUrl;

  /// Total amount of times the movement was checked for the threshold.
  int totalMovementAmount = 0;

  /// Amount of times the movement was over the threshold.
  int amountOverThreshold = 0;

  /// Points for the heart rate graph.
  List<FlSpot> heartRatePoints = [];

  /// Duration of the session in seconds.
  double duration = 0;

  /// Copies the session, allows to change some values.
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

  /// Converts the session to a json object.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'backgroundColor': [
          backgroundColor.r,
          backgroundColor.g,
          backgroundColor.b,
          backgroundColor.a
        ],
        'dateCreated': dateCreated,
        'gameId': gameId,
        'logoUrl': logoUrl,
        'totalMovementAmount': totalMovementAmount,
        'amountOverThreshold': amountOverThreshold,
        'heartRatePoints': heartRatePoints.map((e) => [e.x, e.y]).toList(),
        'duration': duration,
      };

  /// Creates a session from a json object.
  factory Session.fromJson(Map<String, dynamic> json) {
    Session session = Session(
      id: json['id'],
      name: json['name'],
      backgroundColor: Color.from(
          red: json['backgroundColor'][0],
          green: json['backgroundColor'][1],
          blue: json['backgroundColor'][2],
          alpha: json['backgroundColor'][3]),
      gameId: json['gameId'],
      logoUrl: json['logoUrl'],
    );
    session.dateCreated = json['dateCreated'];
    session.amountOverThreshold = json['amountOverThreshold'];
    session.totalMovementAmount = json['totalMovementAmount'];
    session.duration = json['duration'];
    session.heartRatePoints = (json['heartRatePoints'] as List)
        .map((e) => FlSpot(e[0], e[1]))
        .toList();
    return session;
  }
}
