class Collection {
  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        coverUrl: coverUrl ?? this.coverUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
