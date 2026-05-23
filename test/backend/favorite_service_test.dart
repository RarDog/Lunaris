import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/favorite.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/repositories/favorite_repository.dart';
import 'package:gel_rule_app/backend/services/favorite_service.dart';
import 'package:gel_rule_app/core/utils/result.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  final favorites = <String, Favorite>{};

  @override
  Future<Result<void>> add(Post post) async {
    final key = '${post.providerId}:${post.id}';
    favorites[key] = Favorite(
      id: key,
      postId: post.id,
      providerId: post.providerId,
      savedAt: DateTime.now(),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String postId, String providerId) async {
    favorites.remove('$providerId:$postId');
    return const Success(null);
  }

  @override
  Future<Result<bool>> exists(String postId, String providerId) async {
    return Success(favorites.containsKey('$providerId:$postId'));
  }

  @override
  Future<Result<List<Favorite>>> all() async =>
      Success(favorites.values.toList());

  @override
  Future<Result<void>> clear() async {
    favorites.clear();
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Post post(String id, String providerId) => Post(
      id: id,
      providerId: providerId,
      providerName: providerId,
      previewUrl: '',
      sampleUrl: '',
      fileUrl: '',
      tags: const [],
      rating: 'safe',
      width: 0,
      height: 0,
      createdAt: DateTime.now(),
      fileType: 'unknown',
      score: 0,
    );

void main() {
  test('add and remove favorite', () async {
    final service = FavoriteService(FakeFavoriteRepository());
    await service.addFavorite(post('1', 'a'));
    expect((await service.isFavorite('1', 'a') as Success<bool>).data, isTrue);
    await service.removeFavorite('1', 'a');
    expect((await service.isFavorite('1', 'a') as Success<bool>).data, isFalse);
  });

  test('duplicate favorite is idempotent', () async {
    final service = FavoriteService(FakeFavoriteRepository());
    await service.addFavorite(post('1', 'a'));
    await service.addFavorite(post('1', 'a'));
    expect((await service.getFavorites() as Success<List<Favorite>>).data,
        hasLength(1));
  });

  test('same post id on different providers does not collide', () async {
    final service = FavoriteService(FakeFavoriteRepository());
    await service.addFavorite(post('1', 'a'));
    await service.addFavorite(post('1', 'b'));
    expect((await service.getFavorites() as Success<List<Favorite>>).data,
        hasLength(2));
  });
}
