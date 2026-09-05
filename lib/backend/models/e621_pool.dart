class E621Pool {
  const E621Pool({
    required this.id,
    required this.name,
    required this.description,
    required this.postIds,
    required this.postCount,
    required this.category,
    required this.isActive,
    this.creatorName,
  });

  final int id;
  final String name;
  final String description;
  final List<String> postIds;
  final int postCount;
  final String category; // 'series' or 'collection'
  final bool isActive;
  final String? creatorName;

  String get cleanTitle => name.replaceAll('_', ' ');

  int pageOf(String postId) {
    final idx = postIds.indexOf(postId);
    return idx >= 0 ? idx + 1 : 0;
  }

  String? nextPostId(String postId) {
    final idx = postIds.indexOf(postId);
    if (idx >= 0 && idx < postIds.length - 1) {
      return postIds[idx + 1];
    }
    return null;
  }

  String? previousPostId(String postId) {
    final idx = postIds.indexOf(postId);
    if (idx > 0) {
      return postIds[idx - 1];
    }
    return null;
  }

  factory E621Pool.fromJson(Map<String, dynamic> json) {
    final rawPostIds = (json['post_ids'] as List?) ?? const [];
    return E621Pool(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      postIds: rawPostIds.map((e) => e.toString()).toList(),
      postCount: (json['post_count'] as num?)?.toInt() ?? rawPostIds.length,
      category: (json['category'] ?? 'series').toString(),
      isActive: (json['is_active'] as bool?) ?? true,
      creatorName: json['creator_name']?.toString(),
    );
  }
}
