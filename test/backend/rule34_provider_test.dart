import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/providers/provider_factory.dart';
import 'package:gel_rule_app/backend/providers/rule34_provider.dart';

void main() {
  test('ProviderFactory creates Rule34Provider with credentials', () {
    final factory = ProviderFactory();
    final config = ContentProviderConfig(
      id: 'rule34',
      name: 'Rule34',
      baseUrl: 'https://api.rule34.xxx',
      apiType: 'rule34',
      enabled: true,
      priority: 1,
      timeoutSeconds: 20,
      customHeaders: const {
        'query.api_key': 'test_key',
        'query.user_id': '99999',
      },
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final provider = factory.create(config);
    expect(provider, isA<Rule34Provider>());
    final r34 = provider as Rule34Provider;
    expect(r34.id, 'rule34');
    expect(r34.baseUrl, 'https://api.rule34.xxx');
    expect(r34.queryParameters['api_key'], 'test_key');
    expect(r34.queryParameters['user_id'], '99999');
  });
}
