import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/collection.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/repositories/collection_repository.dart';
import 'package:gel_rule_app/backend/services/collection_service.dart';
import 'package:gel_rule_app/core/utils/result.dart';

class FakeCollectionRepository implements CollectionRepository {
  final collections = <String, Collection>{};
  final postsByCollection = <String, Map<String, Post>>{};
  final cachedPosts = <String, Post>{};

  @override
  Future<Result<Collection>> save(Collection collection) async {
    collections[collection.id] = collection;
    return Success(collection);
  }

  @override
  Future<Result<void>> delete(String id) async {
    collections.remove(id);
    postsByCollection.remove(id);
    return const Success(null);
  }

  @override
  Future<Result<List<Collection>>> all() async {
    return Success(collections.values.toList());
  }

  @override
  Future<Result<Collection?>> getById(String id) async {
    return Success(collections[id]);
  }

  @override
  Future<Result<void>> addPost(String collectionId, Post post) async {
    cachedPosts[post.cacheKey] = post;
    postsByCollection.putIfAbsent(collectionId, () => {})[post.cacheKey] = post;
    return const Success(null);
  }

  @override
  Future<Result<void>> removePost(
    String collectionId,
    String postId,
    String providerId,
  ) async {
    postsByCollection[collectionId]?.remove('$providerId:$postId');
    return const Success(null);
  }

  @override
  Future<Result<List<Post>>> posts(String collectionId) async {
    return Success(postsByCollection[collectionId]?.values.toList() ?? []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Post post(String id) => Post(
      id: id,
      providerId: 'gelbooru',
      providerName: 'Gelbooru',
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
  test('create update and delete collection', () async {
    final repository = FakeCollectionRepository();
    final service = CollectionService(repository);

    final created =
        await service.createCollection('A', 'desc') as Success<Collection>;
    await service.updateCollection(created.data.id,
        name: 'B', description: 'new');
    expect(
        (await service.getCollections() as Success<List<Collection>>)
            .data
            .single
            .name,
        'B');

    await service.deleteCollection(created.data.id);
    expect((await service.getCollections() as Success<List<Collection>>).data,
        isEmpty);
  });

  test('add and remove post while cached metadata remains', () async {
    final repository = FakeCollectionRepository();
    final service = CollectionService(repository);
    final collection =
        await service.createCollection('A', null) as Success<Collection>;
    final item = post('1');

    await service.addPostToCollection(collection.data.id, item);
    expect(
      (await service.getCollectionPosts(collection.data.id)
              as Success<List<Post>>)
          .data,
      hasLength(1),
    );

    await service.removePostFromCollection(
        collection.data.id, item.id, item.providerId);
    expect(
      (await service.getCollectionPosts(collection.data.id)
              as Success<List<Post>>)
          .data,
      isEmpty,
    );
    expect(repository.cachedPosts[item.cacheKey], item);
  });
}
