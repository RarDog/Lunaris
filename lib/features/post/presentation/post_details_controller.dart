import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

final postDetailsControllerProvider =
    FutureProvider.family<Post?, PostDetailsArgs>((ref, args) async {
  Future<Post?> enrich(Post? post) async {
    if (post == null) return null;
    final shouldEnrich = post.tagGroups.isEmpty ||
        (post.tagGroups.length == 1 && post.tagGroups.containsKey('general'));
    if (!shouldEnrich) return post;
    final enriched =
        await ref.watch(providerManagerProvider).enrichPostTags(post);
    if (enriched is Success<Post>) {
      await ref.watch(cacheServiceProvider).cachePosts([enriched.data]);
      return enriched.data;
    }
    return post;
  }

  if (args.initialPost != null) return enrich(args.initialPost);
  final cached = await ref
      .watch(postRepositoryProvider)
      .getCachedPost(args.postId, args.providerId);
  if (cached is Success<Post?> && cached.data != null) {
    return enrich(cached.data);
  }
  final remote = await ref
      .watch(providerManagerProvider)
      .getPost(args.providerId, args.postId);
  return remote is Success<Post?> ? enrich(remote.data) : null;
});

class PostDetailsArgs {
  const PostDetailsArgs({
    required this.providerId,
    required this.postId,
    this.initialPost,
  });

  final String providerId;
  final String postId;
  final Post? initialPost;

  @override
  bool operator ==(Object other) {
    return other is PostDetailsArgs &&
        other.providerId == providerId &&
        other.postId == postId &&
        other.initialPost == initialPost;
  }

  @override
  int get hashCode => Object.hash(providerId, postId, initialPost);
}
