import '../../core/utils/result.dart';
import '../models/favorite.dart';
import '../models/post.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/post_repository.dart';

class FavoriteService {
  FavoriteService(this._repository, [this._postRepository]);

  final FavoriteRepository _repository;
  final PostRepository? _postRepository;

  Future<Result<void>> addFavorite(Post post) => _repository.add(post);
  Future<Result<void>> removeFavorite(String postId, String providerId) {
    return _repository.remove(postId, providerId);
  }

  Future<Result<bool>> isFavorite(String postId, String providerId) {
    return _repository.exists(postId, providerId);
  }

  Future<Result<List<Favorite>>> getFavorites() => _repository.all();
  Future<Result<List<Post>>> getFavoritePosts() async {
    final postRepository = _postRepository;
    if (postRepository == null) return const Success([]);
    final favoritesResult = await _repository.all();
    if (favoritesResult is Error<List<Favorite>>) {
      return Error(favoritesResult.failure);
    }
    final favorites = (favoritesResult as Success<List<Favorite>>).data;
    return postRepository.getCachedPostsByKeys(
      favorites.map((favorite) => '${favorite.providerId}:${favorite.postId}'),
    );
  }

  Future<Result<void>> clearFavorites() => _repository.clear();
}
