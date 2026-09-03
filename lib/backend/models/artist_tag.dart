class ArtistTag {
  const ArtistTag({
    required this.tag,
    required this.postCount,
  });

  final String tag;
  final int postCount;

  factory ArtistTag.fromJson(Map<String, dynamic> json) {
    return ArtistTag(
      tag: (json['tag'] ?? '').toString(),
      postCount: (json['post_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'post_count': postCount,
      };
}
