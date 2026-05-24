import '../../core/utils/result.dart';
import '../models/post.dart';
import '../models/viewed_post.dart';
import '../repositories/post_repository.dart';
import '../repositories/viewed_post_repository.dart';

class ViewedHistoryService {
  ViewedHistoryService(this._repository, this._postRepository);

  final ViewedPostRepository _repository;
  final PostRepository _postRepository;

  Future<Result<void>> markViewed(Post post) async {
    final cacheResult = await _postRepository.cachePosts([post]);
    if (cacheResult is Error<void>) return cacheResult;
    return _repository.markViewed(post.providerId, post.id);
  }

  Future<Result<bool>> isViewed(String postId, String providerId) {
    return _repository.exists(providerId, postId);
  }

  Future<Result<Set<String>>> getViewedKeys() {
    return _repository.keys();
  }

  Future<Result<List<Post>>> getViewedPosts() async {
    final viewedResult = await _repository.recent();
    if (viewedResult is Error<List<ViewedPost>>) {
      return Error(viewedResult.failure);
    }
    final viewed = (viewedResult as Success<List<ViewedPost>>).data;
    return _postRepository.getCachedPostsByKeys(
      viewed.map((item) => item.viewedKey),
    );
  }

  Future<Result<void>> clearHistory() {
    return _repository.clear();
  }
}
