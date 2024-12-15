class Session {
  const Session({
    required this.id,
    required this.name,
    this.gameId,
    this.logoUrl,
  });

  final int id;
  final String name;
  final int? gameId;
  final String? logoUrl;

  Session copyWith({
    int? id,
    String? name,
    int? gameId,
    String? logoUrl,
  }) {
    return Session(
        id: id ?? this.id,
        name: name ?? this.name,
        gameId: gameId ?? this.gameId,
        logoUrl: logoUrl ?? this.logoUrl);
  }
}
