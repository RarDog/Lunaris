import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

final collectionsControllerProvider =
    AsyncNotifierProvider<CollectionsController, List<Collection>>(
  CollectionsController.new,
);

class CollectionsController extends AsyncNotifier<List<Collection>> {
  @override
  Future<List<Collection>> build() => _load();

  Future<void> create(String name, String? description) async {
    await ref
        .read(collectionServiceProvider)
        .createCollection(name, description);
    state = AsyncData(await _load());
  }

  Future<void> updateCollection(
    String id, {
    required String name,
    String? description,
    String? coverUrl,
  }) async {
    await ref.read(collectionServiceProvider).updateCollection(
          id,
          name: name,
          description: description,
          coverUrl: coverUrl,
        );
    state = AsyncData(await _load());
  }

  Future<void> delete(String id) async {
    await ref.read(collectionServiceProvider).deleteCollection(id);
    ref.invalidate(collectionPostsProvider(id));
    state = AsyncData(await _load());
  }

  Future<List<Collection>> _load() async {
    final result = await ref.read(collectionServiceProvider).getCollections();
    return result is Success<List<Collection>> ? result.data : const [];
  }
}

final collectionPostsProvider =
    FutureProvider.family<List<Post>, String>((ref, collectionId) async {
  final result = await ref
      .watch(collectionServiceProvider)
      .getCollectionPosts(collectionId);
  return result is Success<List<Post>> ? result.data : const [];
});
