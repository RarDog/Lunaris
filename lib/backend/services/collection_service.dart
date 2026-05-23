import '../../core/utils/result.dart';
import '../../core/errors/failure.dart';
import '../models/collection.dart';
import '../models/post.dart';
import '../repositories/collection_repository.dart';

class CollectionService {
  CollectionService(this._repository);

  final CollectionRepository _repository;

  Future<Result<Collection>> createCollection(
      String name, String? description) {
    final now = DateTime.now();
    return _repository.save(
      Collection(
        id: now.microsecondsSinceEpoch.toString(),
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<Result<Collection>> updateCollection(
    String id, {
    required String name,
    String? description,
    String? coverUrl,
  }) async {
    final existingResult = await _repository.getById(id);
    if (existingResult is Error<Collection?>) {
      return Error(existingResult.failure);
    }
    final existing = (existingResult as Success<Collection?>).data;
    if (existing == null) {
      return const Error(
        Failure(code: 'not_found', message: 'Collection not found'),
      );
    }
    return _repository.save(
      Collection(
        id: id,
        name: name,
        description: description,
        coverUrl: coverUrl,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<Result<void>> deleteCollection(String id) => _repository.delete(id);
  Future<Result<void>> addPostToCollection(String collectionId, Post post) {
    return _repository.addPost(collectionId, post);
  }

  Future<Result<void>> removePostFromCollection(
    String collectionId,
    String postId,
    String providerId,
  ) {
    return _repository.removePost(collectionId, postId, providerId);
  }

  Future<Result<List<Collection>>> getCollections() => _repository.all();
  Future<Result<List<Post>>> getCollectionPosts(String collectionId) {
    return _repository.posts(collectionId);
  }
}
