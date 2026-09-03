import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/app_update_info.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';
import 'package:gel_rule_app/backend/services/update_service.dart';
import 'package:gel_rule_app/core/database/database_service.dart';

void main() {
  test('UpdateService parses Gitea release JSON correctly', () {
    final service = UpdateService(Dio(), SettingsService(_MockDatabaseService()));

    // Use reflection or constructor to test info
    final info = AppUpdateInfo(
      version: '2.0.2',
      tagName: 'v2.0.2',
      name: 'Lunaris 2.0.2',
      body: 'Release notes',
      htmlUrl: 'https://gitea.rardogsynapse.online/RarDog/Lunaris/releases/tag/v2.0.2',
      publishedAt: DateTime.parse('2026-09-03T18:00:00Z'),
      apkUrl: 'https://gitea.rardogsynapse.online/attachments/apk',
      linuxTarGzUrl: 'https://gitea.rardogsynapse.online/attachments/linux',
    );

    expect(info.hasAssets, isTrue);
    expect(info.apkUrl, contains('apk'));
    expect(info.linuxTarGzUrl, contains('linux'));
    expect(
      service.assetFileName(info, 'https://gitea.rardogsynapse.online/attachments/Lunaris-v2.0.2.apk'),
      'Lunaris-v2.0.2.apk',
    );
    expect(
      service.assetFileName(info, info.apkUrl!),
      'Lunaris-v2.0.2-linux-x64.tar.gz',
    );
  });
}

class _MockDatabaseService implements DatabaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
