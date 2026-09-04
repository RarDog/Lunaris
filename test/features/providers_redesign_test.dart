import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/features/providers/presentation/provider_check_screen.dart';
import 'package:gel_rule_app/features/providers/presentation/provider_form_screen.dart';
import 'package:gel_rule_app/features/providers/presentation/providers_controller.dart';
import 'package:gel_rule_app/features/providers/presentation/providers_screen.dart';

ContentProviderConfig _sampleConfig({
  required String id,
  required String name,
  String apiType = 'gelbooru',
  String baseUrl = 'https://gelbooru.com',
  bool enabled = true,
  int priority = 10,
}) {
  return ContentProviderConfig(
    id: id,
    name: name,
    baseUrl: baseUrl,
    apiType: apiType,
    enabled: enabled,
    priority: priority,
    timeoutSeconds: 20,
    customHeaders: const {},
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

class _FakeProvidersController extends ProvidersController {
  _FakeProvidersController(this._items);
  final List<ContentProviderConfig> _items;

  @override
  Future<List<ContentProviderConfig>> build() async => _items;
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('ProvidersScreen renders overview card, provider cards, and actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleProviders = [
      _sampleConfig(id: 'gelbooru', name: 'Gelbooru', apiType: 'gelbooru'),
      _sampleConfig(
          id: 'rule34',
          name: 'Rule34',
          apiType: 'rule34',
          baseUrl: 'https://api.rule34.xxx'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providersControllerProvider.overrideWith(
            () => _FakeProvidersController(sampleProviders),
          ),
        ],
        child: const MaterialApp(
          home: ProvidersScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gelbooru'), findsWidgets);
    expect(find.text('Rule34'), findsWidgets);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.byIcon(Icons.network_check_rounded), findsWidgets);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('ProviderFormScreen renders presets, sections, and input fields',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProviderFormScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check presets are visible
    expect(find.text('Danbooru'), findsOneWidget);
    expect(find.text('e621'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('ProviderCheckScreen renders metrics and health tiles',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sampleProviders = [
      _sampleConfig(id: 'gelbooru', name: 'Gelbooru', apiType: 'gelbooru'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providersControllerProvider.overrideWith(
            () => _FakeProvidersController(sampleProviders),
          ),
          providerDiagnosticsProvider.overrideWith(
            (ref) async => const {},
          ),
          providerHealthProvider.overrideWith(
            (ref) => {
              'gelbooru': ProviderHealth(
                providerId: 'gelbooru',
                status: ProviderStatus.online,
                pingMs: 85,
                apiVersion: '0.2.5',
                lastCheckedAt: DateTime(2026, 1, 1),
              ),
            },
          ),
        ],
        child: const MaterialApp(
          home: ProviderCheckScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gelbooru'), findsOneWidget);
    expect(find.text('85 ms'), findsOneWidget);
  });
}
