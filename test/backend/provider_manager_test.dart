import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/models/provider_health.dart';
import 'package:gel_rule_app/backend/models/top_period_filter.dart';
import 'package:gel_rule_app/backend/providers/content_provider.dart';
import 'package:gel_rule_app/backend/providers/provider_factory.dart';
import 'package:gel_rule_app/backend/providers/provider_manager.dart';
import 'package:gel_rule_app/backend/repositories/provider_repository.dart';
import 'package:gel_rule_app/core/utils/result.dart';

class FakeProviderRepository implements ProviderRepository {
  final configs = <String, ContentProviderConfig>{};
  final health = <String, ProviderHealth>{};

  @override
  Future<Result<void>> ensureSeedProviders() async => const Success(null);

  @override
  Future<Result<List<ContentProviderConfig>>> getProviders({
    bool enabledOnly = false,
  }) async {
    final values = configs.values
        .where((config) => !enabledOnly || config.enabled)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return Success(values);
  }

  @override
  Future<Result<ContentProviderConfig?>> getProvider(String id) async {
    return Success(configs[id]);
  }

  @override
  Future<Result<void>> saveProvider(ContentProviderConfig config) async {
    configs[config.id] = config;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteProvider(String id) async {
    configs.remove(id);
    return const Success(null);
  }

  @override
  Future<Result<void>> saveHealth(ProviderHealth value) async {
    health[value.providerId] = value;
    return const Success(null);
  }

  @override
  Future<Result<ProviderHealth?>> getHealth(String providerId) async {
    return Success(health[providerId]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProviderFactory extends ProviderFactory {
  FakeProviderFactory(this.providers);

  final Map<String, ContentProvider> providers;

  @override
  ContentProvider create(ContentProviderConfig config) => providers[config.id]!;
}

class FakeProvider implements ContentProvider {
  FakeProvider(this.id, this.name, this.posts, {this.failSearch = false});

  @override
  final String id;
  @override
  final String name;
  @override
  String get baseUrl => 'https://example.test';
  final List<Post> posts;
  final bool failSearch;

  @override
  Future<ProviderHealth> checkHealth() async => ProviderHealth(
        providerId: id,
        status: ProviderStatus.online,
        pingMs: 1,
        lastCheckedAt: DateTime.now(),
      );

  @override
  Future<Post?> getPost(String id) async =>
      posts.where((post) => post.id == id).firstOrNull;

  @override
  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    if (failSearch) throw Exception('fail');
    return posts;
  }
}

ContentProviderConfig config(String id, int priority, {bool enabled = true}) {
  final now = DateTime.now();
  return ContentProviderConfig(
    id: id,
    name: id,
    baseUrl: 'https://example.test',
    apiType: 'fake',
    enabled: enabled,
    priority: priority,
    timeoutSeconds: 10,
    customHeaders: const {},
    createdAt: now,
    updatedAt: now,
  );
}

Post post(String providerId, String id) => Post(
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
  test('active providers are sorted by priority', () async {
    final repository = FakeProviderRepository()
      ..configs['b'] = config('b', 2)
      ..configs['a'] = config('a', 1);
    final manager = ProviderManager(
      repository,
      FakeProviderFactory({
        'a': FakeProvider('a', 'a', []),
        'b': FakeProvider('b', 'b', []),
      }),
    );

    final result =
        await manager.activeProviders() as Success<List<ContentProvider>>;
    expect(result.data.map((provider) => provider.id), ['a', 'b']);
  });

  test('saved offline health does not block enabled provider retry', () async {
    final repository = FakeProviderRepository()
      ..configs['a'] = config('a', 0)
      ..configs['b'] = config('b', 1)
      ..configs['c'] = config('c', 2)
      ..health['b'] = ProviderHealth(
        providerId: 'b',
        status: ProviderStatus.offline,
        pingMs: 0,
        lastCheckedAt: DateTime.now(),
      );
    final manager = ProviderManager(
      repository,
      FakeProviderFactory({
        'a': FakeProvider('a', 'a', [post('a', '1')]),
        'b': FakeProvider('b', 'b', [post('b', '1')]),
        'c': FakeProvider('c', 'c', [], failSearch: true),
      }),
    );

    final result = await manager.searchAcrossProviders(tags: [], page: 0)
        as Success<List<Post>>;
    expect(result.data.map((item) => item.providerId), ['a', 'b']);
    expect(repository.health['c']?.status, ProviderStatus.offline);
  });

  test('enable disable provider persists config', () async {
    final repository = FakeProviderRepository()..configs['a'] = config('a', 0);
    final manager = ProviderManager(
      repository,
      FakeProviderFactory({'a': FakeProvider('a', 'a', [])}),
    );

    await manager.enableProvider('a', false);
    expect(repository.configs['a']!.enabled, isFalse);
  });
}
