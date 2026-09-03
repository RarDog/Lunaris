enum TagCategory {
  general,
  artist,
  copyright,
  character,
  meta,
  species,
  unknown,
}

class TagSuggestion {
  const TagSuggestion({
    required this.name,
    required this.category,
    required this.postCount,
    required this.providerId,
  });

  final String name;
  final TagCategory category;
  final int postCount;
  final String providerId;

  String get categoryLabel => category.name;

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.name,
        'postCount': postCount,
        'providerId': providerId,
      };

  factory TagSuggestion.fromJson(Map<String, dynamic> json) => TagSuggestion(
        name: (json['name'] ?? '').toString(),
        category: tagCategoryFromString((json['category'] ?? '').toString()),
        postCount: (json['postCount'] as num?)?.toInt() ?? 0,
        providerId: (json['providerId'] ?? '').toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagSuggestion &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

TagCategory tagCategoryFromString(String? value) {
  final normalized = (value ?? '').toLowerCase();
  return switch (normalized) {
    '0' || 'general' => TagCategory.general,
    '1' || 'artist' => TagCategory.artist,
    '3' || 'copyright' || 'circle' => TagCategory.copyright,
    '4' || 'character' => TagCategory.character,
    '5' || 'meta' || 'metadata' => TagCategory.meta,
    'species' => TagCategory.species,
    _ => TagCategory.unknown,
  };
}
