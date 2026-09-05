import 'cloud_media_link.dart';
import '../services/cloud_link_extractor.dart';

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
    this.tagGroups = const {},
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
  final Map<String, List<String>> tagGroups;

  String get cacheKey => '$providerId:$id';

  List<CloudMediaLink> get cloudLinks {
    final list = tagGroups['cloud_links'];
    if (list != null && list.isNotEmpty) {
      return list
          .map((e) => CloudMediaLink.tryDecode(e))
          .whereType<CloudMediaLink>()
          .toList(growable: false);
    }
    if (source != null && source!.isNotEmpty) {
      return CloudLinkExtractor.extractLinks(source: source);
    }
    return const [];
  }

  String? get commentary {
    final list = tagGroups['description'];
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  String? get description => commentary;

  String? get parentId {
    final list = tagGroups['parent_id'];
    return (list != null && list.isNotEmpty && list.first.trim().isNotEmpty)
        ? list.first.trim()
        : null;
  }

  List<String> get childrenIds => tagGroups['children'] ?? const [];

  List<String> get poolIds => tagGroups['pools'] ?? const [];

  bool get hasRelations =>
      (parentId != null && parentId!.isNotEmpty) || childrenIds.isNotEmpty;

  bool get hasPools => poolIds.isNotEmpty;

  int? get favCount {
    final raw = tagGroups['fav_count']?.firstOrNull;
    return raw != null ? int.tryParse(raw) : null;
  }

  String? get title {
    final list = tagGroups['copyright'];
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  List<String> get cleanTags {
    return tags.where((tag) {
      final t = tag.trim();
      if (t.isEmpty) return false;
      if (t == 'cloud_mirror' || t == 'text_post') return false;
      if (t.startsWith('{') && t.endsWith('}')) return false;
      if (t.contains('"url"') || t.contains('"service"')) return false;
      if (t.startsWith('http://') || t.startsWith('https://')) return false;
      if (t.contains('mega.nz') ||
          t.contains('drive.google.com') ||
          t.contains('dropbox.com') ||
          t.contains('pixeldrain.com') ||
          t.contains('catbox.moe') ||
          t.contains('mediafire.com')) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Post copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? previewUrl,
    String? sampleUrl,
    String? fileUrl,
    List<String>? tags,
    String? rating,
    int? width,
    int? height,
    String? source,
    DateTime? createdAt,
    String? fileType,
    int? score,
    Map<String, List<String>>? tagGroups,
  }) {
    return Post(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      previewUrl: previewUrl ?? this.previewUrl,
      sampleUrl: sampleUrl ?? this.sampleUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      width: width ?? this.width,
      height: height ?? this.height,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      fileType: fileType ?? this.fileType,
      score: score ?? this.score,
      tagGroups: tagGroups ?? this.tagGroups,
    );
  }

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
        'tagGroups': tagGroups,
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
        tagGroups: (json['tagGroups'] as Map?)?.map(
              (key, value) => MapEntry(
                key.toString(),
                List<String>.from((value as List?) ?? const []),
              ),
            ) ??
            const {},
      );
}

class PostNavigationContext {
  const PostNavigationContext({
    required this.currentPost,
    required this.posts,
  });

  final Post currentPost;
  final List<Post> posts;
}

