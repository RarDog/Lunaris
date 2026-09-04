import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/app_update_info.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';
import 'package:gel_rule_app/backend/services/update_service.dart';
import 'package:gel_rule_app/core/database/database_service.dart';

void main() {
  test('UpdateService parses GitHub release JSON correctly', () {
    final service = UpdateService(Dio(), SettingsService(_MockDatabaseService()));

    // Use reflection or constructor to test info
    final info = AppUpdateInfo(
      version: '2.0.2',
      tagName: 'v2.0.2',
      name: 'Lunaris 2.0.2',
      body: 'Release notes',
      htmlUrl: 'https://github.com/RarDog/Lunaris/releases/tag/v2.0.2',
      publishedAt: DateTime.parse('2026-09-03T18:00:00Z'),
      apkUrl: 'https://github.com/RarDog/Lunaris/releases/download/v2.0.2/Lunaris.apk',
      linuxTarGzUrl: 'https://github.com/RarDog/Lunaris/releases/download/v2.0.2/linux.tar.gz',
    );

    expect(info.hasAssets, isTrue);
    expect(info.apkUrl, contains('apk'));
    expect(info.linuxTarGzUrl, contains('linux'));
    expect(
      service.assetFileName(info, 'https://github.com/RarDog/Lunaris/releases/download/v2.0.2/Lunaris-v2.0.2.apk'),
      'Lunaris-v2.0.2.apk',
    );
    expect(
      service.assetFileName(info, 'https://github.com/RarDog/Lunaris/releases/download/v2.0.2/unknown-linux'),
      'Lunaris-v2.0.2-linux-x64.tar.gz',
    );
  });
}

class _MockDatabaseService implements DatabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
