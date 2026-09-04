import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/features/settings/presentation/settings_controller.dart';
import 'package:gel_rule_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders category quick nav and sections without overflow', (tester) async {
    // Test on typical mobile viewport: 390x844
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settings = AppSettings.defaults.copyWith(
      languageCode: 'ru',
      themeMode: 'dark',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(settings),
          ),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify pinned Category Quick Nav renders
    expect(find.text('Основное'), findsWidgets);
    expect(find.text('Внешний вид'), findsWidgets);

    // Verify Theme mode segment buttons
    expect(find.text('Темная'), findsOneWidget);
    expect(find.text('Светлая'), findsOneWidget);

    // Tap a quick nav chip to test scrolling
    await tester.tap(find.text('Внешний вид').first);
    await tester.pumpAndSettle();

    // Verify language segment is visible and tappable
    expect(find.text('🇷🇺 Русский'), findsOneWidget);
    expect(find.text('🇬🇧 English'), findsOneWidget);

    // Tap English to test selection
    await tester.tap(find.text('🇬🇧 English'));
    await tester.pumpAndSettle();
  });
}

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initial);

  final AppSettings _initial;

  @override
  Future<AppSettings> build() async => _initial;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    state = AsyncData(settings);
  }
}
