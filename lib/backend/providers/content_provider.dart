import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';

abstract class ContentProvider {
  String get id;
  String get name;
  String get baseUrl;

  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  });

  Future<Post?> getPost(String id);

  Future<ProviderHealth> checkHealth();
}

abstract class CommentProvider {
  Future<List<PostComment>> getComments(String postId);
}

abstract class TagSuggestionProvider {
  Future<List<TagSuggestion>> suggestTags(String query, {int limit = 20});
}
