import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'favorites_state.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, FavoritesState>(
  FavoritesController.new,
);

final favoriteKeysProvider = FutureProvider<Set<String>>((ref) async {
  final result = await ref.watch(favoriteServiceProvider).getFavorites();
  return result.fold(
    onSuccess: (favorites) => favorites
        .map((favorite) => '${favorite.providerId}:${favorite.postId}')
        .toSet(),
    onError: (_) => <String>{},
  );
});

class FavoritesController extends AsyncNotifier<FavoritesState> {
  @override
  Future<FavoritesState> build() async => FavoritesState(posts: await _load());

  Future<void> remove(Post post) async {
    await ref
        .read(favoriteServiceProvider)
        .removeFavorite(post.id, post.providerId);
    ref.invalidate(favoriteKeysProvider);
    state = AsyncData(FavoritesState(posts: await _load()));
  }

  Future<List<Post>> _load() async {
    final result = await ref.read(favoriteServiceProvider).getFavoritePosts();
    return result is Success<List<Post>> ? result.data : const [];
  }
}
