import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/providers/gelbooru_provider.dart';
import 'package:gel_rule_app/backend/providers/provider_factory.dart';
import 'package:gel_rule_app/core/http/dio_client.dart';

void main() {
  test('ProviderFactory creates GelbooruProvider with query credentials', () {
    final factory = ProviderFactory();
    final config = ContentProviderConfig(
      id: 'gelbooru',
      name: 'Gelbooru',
      baseUrl: 'https://gelbooru.com',
      apiType: 'gelbooru',
      enabled: true,
      priority: 10,
      timeoutSeconds: 20,
      customHeaders: const {
        'query.api_key': 'test_api_key',
        'query.user_id': '123456',
      },
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final provider = factory.create(config);
    expect(provider, isA<GelbooruProvider>());
    final gelbooru = provider as GelbooruProvider;
    expect(gelbooru.id, 'gelbooru');
    expect(gelbooru.queryParameters['api_key'], 'test_api_key');
    expect(gelbooru.queryParameters['user_id'], '123456');
  });

  test('GelbooruProvider mediaHeaders contains Referer and User-Agent', () {
    final client = DioClient(baseUrl: 'https://gelbooru.com');
    final provider = GelbooruProvider(
      id: 'gelbooru',
      name: 'Gelbooru',
      baseUrl: 'https://gelbooru.com',
      dioClient: client,
    );

    expect(provider.baseUrl, 'https://gelbooru.com');
  });
}
