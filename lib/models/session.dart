class Session {
  const Session({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  Session copyWith({
    int? id,
    String? name,
  }) {
    return Session(id: id ?? this.id, name: name ?? this.name);
  }
}
