import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/features/settings/presentation/settings_controller.dart';
import 'package:gel_rule_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders category quick nav and sections', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
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

    // Verify Category Quick Nav renders
    expect(find.text('Основное'), findsWidgets);
    expect(find.text('Внешний вид'), findsWidgets);
    expect(find.text('Лента и раскладка'), findsWidgets);
    expect(find.text('Фильтры'), findsWidgets);
    expect(find.text('Хранилище'), findsWidgets);

    // Verify Theme mode segment buttons
    expect(find.text('Темная'), findsOneWidget);
    expect(find.text('Светлая'), findsOneWidget);
    // Both ThemeMode and MediaQualityMode have 'Авто'
    expect(find.text('Авто'), findsNWidgets(2));

    // Verify Language segmented buttons
    expect(find.text('🇷🇺 RU'), findsOneWidget);
    expect(find.text('🇬🇧 EN'), findsOneWidget);
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
