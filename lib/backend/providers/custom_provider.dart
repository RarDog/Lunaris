import '../../core/errors/app_exception.dart';
import '../models/post.dart';
import '../models/provider_health.dart';
import '../models/top_period_filter.dart';
import 'content_provider.dart';

class CustomProvider implements ContentProvider {
  CustomProvider(this._delegate);

  final ContentProvider _delegate;

  @override
  String get id => _delegate.id;
  @override
  String get name => _delegate.name;
  @override
  String get baseUrl => _delegate.baseUrl;

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) =>
      _delegate.searchPosts(
        tags: tags,
        page: page,
        limit: limit,
        rating: rating,
        topPeriod: topPeriod,
      );

  @override
  Future<Post?> getPost(String id) => _delegate.getPost(id);

  @override
  Future<ProviderHealth> checkHealth() => _delegate.checkHealth();
}

class UnsupportedCustomProvider implements ContentProvider {
  UnsupportedCustomProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiType,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String baseUrl;
  final String apiType;

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    throw ProviderUnavailableException(
        'Unsupported provider apiType: $apiType');
  }

  @override
  Future<Post?> getPost(String id) async {
    throw ProviderUnavailableException(
        'Unsupported provider apiType: $apiType');
  }

  @override
  Future<ProviderHealth> checkHealth() async => ProviderHealth(
        providerId: id,
        status: ProviderStatus.offline,
        pingMs: 0,
        lastCheckedAt: DateTime.now(),
        errorMessage: 'Unsupported provider apiType: $apiType',
      );
}
