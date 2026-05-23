class Post {
  const Post({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.previewUrl,
    required this.sampleUrl,
    required this.fileUrl,
    required this.tags,
    required this.rating,
    required this.width,
    required this.height,
    this.source,
    required this.createdAt,
    required this.fileType,
    required this.score,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String previewUrl;
  final String sampleUrl;
  final String fileUrl;
  final List<String> tags;
  final String rating;
  final int width;
  final int height;
  final String? source;
  final DateTime createdAt;
  final String fileType;
  final int score;

  String get cacheKey => '$providerId:$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerId': providerId,
        'providerName': providerName,
        'previewUrl': previewUrl,
        'sampleUrl': sampleUrl,
        'fileUrl': fileUrl,
        'tags': tags,
        'rating': rating,
        'width': width,
        'height': height,
        'source': source,
        'createdAt': createdAt.toIso8601String(),
        'fileType': fileType,
        'score': score,
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'].toString(),
        providerId: json['providerId'] as String,
        providerName: json['providerName'] as String,
        previewUrl: (json['previewUrl'] as String?) ?? '',
        sampleUrl: (json['sampleUrl'] as String?) ?? '',
        fileUrl: (json['fileUrl'] as String?) ?? '',
        tags: List<String>.from((json['tags'] as List?) ?? const []),
        rating: (json['rating'] as String?) ?? 'unknown',
        width: (json['width'] as num?)?.toInt() ?? 0,
        height: (json['height'] as num?)?.toInt() ?? 0,
        source: json['source'] as String?,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        fileType: (json['fileType'] as String?) ?? 'unknown',
        score: (json['score'] as num?)?.toInt() ?? 0,
      );
}
