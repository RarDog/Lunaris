import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import 'favorites_state.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, FavoritesState>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<FavoritesState> {
  @override
  Future<FavoritesState> build() async => FavoritesState(posts: await _load());

  Future<void> remove(Post post) async {
    await ref
        .read(favoriteServiceProvider)
        .removeFavorite(post.id, post.providerId);
    state = AsyncData(FavoritesState(posts: await _load()));
  }

  Future<List<Post>> _load() async {
    final result = await ref.read(favoriteServiceProvider).getFavoritePosts();
    return result is Success<List<Post>> ? result.data : const [];
  }
}
