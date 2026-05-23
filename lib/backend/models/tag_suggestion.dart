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
