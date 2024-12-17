import 'package:flutter/material.dart';

class Session {
  const Session(
      {required this.id,
      required this.name,
      this.gameId,
      this.logoUrl,
      this.backgroundColor});

  final int id;
  final String name;
  final int? gameId;
  final String? logoUrl;
  final Color? backgroundColor;

  Session copyWith({
    int? id,
    String? name,
    int? gameId,
    String? logoUrl,
    Color? backgroundColor,
  }) {
    return Session(
        id: id ?? this.id,
        name: name ?? this.name,
        gameId: gameId ?? this.gameId,
        logoUrl: logoUrl ?? this.logoUrl,
        backgroundColor: backgroundColor ?? this.backgroundColor);
  }
}
