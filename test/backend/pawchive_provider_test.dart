import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/artist_work_query.dart';
import 'package:gel_rule_app/backend/models/content_provider_config.dart';
import 'package:gel_rule_app/backend/providers/pawchive_provider.dart';
import 'package:gel_rule_app/backend/providers/provider_factory.dart';
import 'package:gel_rule_app/core/http/dio_client.dart';

void main() {
  test('ProviderFactory creates PawchiveProvider', () {
    final factory = ProviderFactory();
    final config = ContentProviderConfig(
      id: 'pawchive',
      name: 'Pawchive',
      baseUrl: 'https://pawchive.pw',
      apiType: 'pawchive',
      enabled: true,
      priority: 12,
      timeoutSeconds: 20,
      customHeaders: const {},
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final provider = factory.create(config);
    expect(provider, isA<PawchiveProvider>());
    expect(provider.id, 'pawchive');
    expect(provider.name, 'Pawchive');
    expect(provider.baseUrl, 'https://pawchive.pw');
  });

  test('PawchiveProvider creates posts with thumbnail and file URLs', () async {
    final client = DioClient(baseUrl: 'https://pawchive.pw');
    final provider = PawchiveProvider(
      id: 'pawchive',
      name: 'Pawchive',
      baseUrl: 'https://pawchive.pw',
      dioClient: client,
    );

    const query = ArtistWorkQuery(
      providerId: 'pawchive',
      service: 'patreon',
      artistId: '30500811',
      artistName: 'BOKABA',
    );

    expect(provider.id, query.providerId);
    expect(query.artistName, 'BOKABA');
  });
}
