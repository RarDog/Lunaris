import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

// Меняем FutureProvider на StreamProvider
final postDetailsControllerProvider =
    StreamProvider.family<Post?, PostDetailsArgs>((ref, args) async* {
  // Правильно собираем зависимости на самом верхнем уровне (фиксим антипаттерн)
  final providerManager = ref.watch(providerManagerProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final postRepository = ref.watch(postRepositoryProvider);

  // Вспомогательная функция для загрузки тегов
  Future<Post?> enrich(Post? post) async {
    if (post == null) return null;
    final shouldEnrich = post.tagGroups.isEmpty ||
        (post.tagGroups.length == 1 && post.tagGroups.containsKey('general'));
    if (!shouldEnrich) return post;

    final enriched = await providerManager.enrichPostTags(post);
    if (enriched is Success<Post>) {
      await cacheService.cachePosts([enriched.data]);
      return enriched.data;
    }
    return post;
  }

  // СЦЕНАРИЙ 1: Пост уже передан из ленты (Самый частый случай)
  if (args.initialPost != null) {
    yield args
        .initialPost; // МГНОВЕННО отдаем пост в UI, экран сразу рендерится!
    final enriched = await enrich(args.initialPost);
    yield enriched; // Чуть позже отдаем версию с загруженными тегами
    return;
  }

  // СЦЕНАРИЙ 2: Прямой переход (например, по ссылке), проверяем локальный кэш
  final cached =
      await postRepository.getCachedPost(args.postId, args.providerId);
  if (cached is Success<Post?> && cached.data != null) {
    yield cached.data; // Нашли в кэше — сразу показываем контент
    final enriched = await enrich(cached.data);
    yield enriched; // Догружаем теги на фоне
    return;
  }

  // СЦЕНАРИЙ 3: Полный фоллбэк, если вообще ничего нет — идем в сеть за самим постом
  final remote = await providerManager.getPost(args.providerId, args.postId);
  if (remote is Success<Post?> && remote.data != null) {
    yield remote.data;
    final enriched = await enrich(remote.data);
    yield enriched;
  } else {
    yield null;
  }
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
