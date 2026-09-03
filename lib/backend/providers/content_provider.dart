import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import '../models/artist_profile.dart';
import '../models/artist_work_query.dart';

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

abstract class PostPageProvider {
  String? postPageUrl(Post post);
}

abstract class MediaHeadersProvider {
  Map<String, String> mediaHeaders(Post post);
}

abstract class CommentProvider {
  Future<List<PostComment>> getComments(String postId);
}

abstract class TagSuggestionProvider {
  Future<List<TagSuggestion>> suggestTags(String query, {int limit = 20});
}

abstract class TagMetadataProvider {
  Future<Map<String, List<String>>> categorizeTags(List<String> tags);
}

abstract class ArtistProvider {
  Future<List<ArtistProfile>> listArtists({
    String? service,
    String? query,
    int page = 1,
    int limit = 30,
  });

  Future<List<ArtistProfile>> searchArtists(
    String query, {
    String? service,
    int page = 1,
    int limit = 30,
  });

  Future<List<Post>> getArtistPosts({
    required ArtistWorkQuery query,
    int page = 0,
    int limit = 50,
  });

  Future<List<PostComment>> getArtistPostComments(
    String service,
    String artistId,
    String postId,
  );
}
