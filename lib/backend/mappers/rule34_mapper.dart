import '../models/post.dart';
import 'gelbooru_mapper.dart';

class Rule34Mapper {
  static List<Post> postsFromResponse(
    dynamic data, {
    required String providerId,
    required String providerName,
  }) {
    return GelbooruMapper.postsFromResponse(
      data,
      providerId: providerId,
      providerName: providerName,
    );
  }
}
