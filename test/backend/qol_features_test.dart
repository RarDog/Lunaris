import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/post.dart';
import 'package:gel_rule_app/backend/services/backup_service.dart';
import 'package:gel_rule_app/backend/services/download_service.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';
import 'package:gel_rule_app/core/utils/result.dart';

void main() {
  group('QoL Features Unit Tests', () {
    test('AppSettings JSON roundtrip retains new QoL fields', () {
      const initial = AppSettings(
        enabledProviderIds: ['gelbooru'],
        nsfwEnabled: true,
        cacheTtlHours: 12,
        cacheMaxItems: 500,
        providerPriority: {'gelbooru': 0},
        themeMode: 'dark',
        languageCode: 'ru',
        appSeedColor: 0xFF112233,
        hiddenTabs: [],
        allowExperimentalUpdates: false,
        desktopColumns: 4,
        mobileColumns: 2,
        blurExplicitContent: false,
        allowDownloads: true,
        autoDownloadFavorites: true,
        selectedFeedProviderIds: [],
        showPostBadges: true,
        defaultTopPeriodFilter: 'none',
        blacklistedTags: [],
        whitelistedTags: [],
        smartBlacklistRules: [],
        hideViewedPosts: false,
        mediaQualityMode: 'auto',
        motionRefreshMode: 'auto',
        autoBatterySaver60Hz: false,
        videoPlayerMuted: true,
        videoPlayerHalfVolume: false,
        videoPlayerLoop: false,
        videoPlayerCover: false,
        videoPlaybackPositions: {},
        hiddenPostKeys: [],
        diagnosticLogLines: [],
        lastFeedTags: [],
        lastFeedProviderIds: [],
        lastFeedTopPeriod: 'none',
        lastFeedScrollOffset: 0,
        amoledMode: true,
        useDynamicColor: true,
        gridMode: 'grid',
        searchPresets: ['{"name":"Favs","tags":"cat"}'],
        downloadPathTemplate: '{Provider}/{Artist}',
      );

      final json = initial.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored.amoledMode, isTrue);
      expect(restored.useDynamicColor, isTrue);
      expect(restored.gridMode, equals('grid'));
      expect(restored.searchPresets, equals(['{"name":"Favs","tags":"cat"}']));
      expect(restored.downloadPathTemplate, equals('{Provider}/{Artist}'));
    });

    test('DownloadService resolveSubDir replaces template variables correctly', () {
      final downloadService = DownloadService();
      final post = Post(
        id: '12345',
        providerId: 'pawchive',
        providerName: 'Pawchive',
        previewUrl: 'https://example.com/prev.jpg',
        sampleUrl: 'https://example.com/sample.jpg',
        fileUrl: 'https://example.com/file.jpg',
        tags: ['artist:CoolArtist', 'cat', 'safe'],
        rating: 'safe',
        width: 800,
        height: 600,
        createdAt: DateTime.now(),
        fileType: 'jpg',
        score: 42,
        tagGroups: {
          'artist': ['CoolArtist'],
        },
      );

      final resolved = downloadService.resolveSubDir(post, '{Provider}/{Artist}');
      expect(resolved, equals('Pawchive/CoolArtist'));

      final singleDir = downloadService.resolveSubDir(post, '{Artist}');
      expect(singleDir, equals('CoolArtist'));

      final withId = downloadService.resolveSubDir(post, '{Artist}/{ID}');
      expect(withId, equals('CoolArtist'));
    });

    test('BackupService exports and restores settings accurately', () async {
      final fakeSettings = _FakeSettingsService();
      final backupService = BackupService(fakeSettings);

      fakeSettings.current = AppSettings.defaults.copyWith(
        amoledMode: true,
        useDynamicColor: true,
        gridMode: 'list',
        downloadPathTemplate: '{Provider}/{ID}',
      );

      final exportedJson = await backupService.createBackupJson();
      expect(exportedJson, contains('version'));
      expect(exportedJson, contains('settings'));

      // Change settings to something else
      fakeSettings.current = AppSettings.defaults.copyWith(
        amoledMode: false,
        gridMode: 'masonry',
      );

      // Restore from backup
      final restoreResult = await backupService.restoreFromJson(exportedJson);
      expect(restoreResult.isSuccess, isTrue);
      expect(fakeSettings.current.amoledMode, isTrue);
      expect(fakeSettings.current.gridMode, equals('list'));
      expect(fakeSettings.current.downloadPathTemplate, equals('{Provider}/{ID}'));
    });
  });
}

class _FakeSettingsService extends Fake implements SettingsService {
  AppSettings current = AppSettings.defaults;

  @override
  Future<Result<AppSettings>> getSettings() async => Success(current);

  @override
  Future<Result<void>> updateSettings(AppSettings settings) async {
    current = settings;
    return const Success(null);
  }
}
