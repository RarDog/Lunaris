import '../models/post.dart';
import '../models/provider_health.dart';
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
