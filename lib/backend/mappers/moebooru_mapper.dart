import 'danbooru_mapper.dart';
import '../models/post.dart';

class MoebooruMapper {
  static List<Post> postsFromResponse(
    dynamic data, {
    required String providerId,
    required String providerName,
  }) {
    final items = data is List ? data : const [];
    return items
        .whereType<Map>()
        .map((item) => DanbooruMapper.postFromJson(
              Map<String, dynamic>.from(item),
              providerId: providerId,
              providerName: providerName,
            ))
        .toList();
  }
}
