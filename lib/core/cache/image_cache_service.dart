import '../../backend/models/post.dart';

class ImageCacheService {
  String previewCacheKey(Post post) => 'preview:${post.providerId}:${post.id}';
  String sampleCacheKey(Post post) => 'sample:${post.providerId}:${post.id}';
  String fileCacheKey(Post post) => 'file:${post.providerId}:${post.id}';
}
