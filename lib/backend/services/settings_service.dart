import 'dart:convert';

import 'package:isar/isar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_service.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../models/content_provider_config.dart';
import '../models/provider_diagnostics.dart';
import '../repositories/provider_repository.dart';

class AppSettings {
  const AppSettings({
    required this.enabledProviderIds,
    required this.nsfwEnabled,
    required this.cacheTtlHours,
    required this.cacheMaxItems,
    required this.providerPriority,
    required this.themeMode,
    required this.desktopColumns,
    required this.mobileColumns,
    required this.blurExplicitContent,
    required this.allowDownloads,
    required this.selectedFeedProviderIds,
    required this.showPostBadges,
    required this.defaultTopPeriodFilter,
    required this.blacklistedTags,
    required this.whitelistedTags,
    required this.smartBlacklistRules,
    required this.hideViewedPosts,
    required this.mediaQualityMode,
    required this.hiddenPostKeys,
    required this.diagnosticLogLines,
    required this.lastFeedTags,
    required this.lastFeedProviderIds,
    required this.lastFeedTopPeriod,
    required this.lastFeedScrollOffset,
    this.skippedUpdateVersion,
    this.lastUpdateCheckAt,
    this.defaultRatingFilter,
    this.lastFeedRating,
  });

  final List<String> enabledProviderIds;
  final bool nsfwEnabled;
  final int cacheTtlHours;
  final int cacheMaxItems;
  final Map<String, int> providerPriority;
  final String themeMode;
  final int desktopColumns;
  final int mobileColumns;
  final bool blurExplicitContent;
  final bool allowDownloads;
  final List<String> selectedFeedProviderIds;
  final bool showPostBadges;
  final String defaultTopPeriodFilter;
  final List<String> blacklistedTags;
  final List<String> whitelistedTags;
  final List<String> smartBlacklistRules;
  final bool hideViewedPosts;
  final String mediaQualityMode;
  final List<String> hiddenPostKeys;
  final List<String> diagnosticLogLines;
  final List<String> lastFeedTags;
  final List<String> lastFeedProviderIds;
  final String lastFeedTopPeriod;
  final double lastFeedScrollOffset;
  final String? skippedUpdateVersion;
  final String? lastUpdateCheckAt;
  final String? defaultRatingFilter;
  final String? lastFeedRating;

  static const defaults = AppSettings(
    enabledProviderIds: ['gelbooru', 'rule34', 'safebooru'],
    nsfwEnabled: true,
    cacheTtlHours: 24,
    cacheMaxItems: 2000,
    providerPriority: {'gelbooru': 0, 'rule34': 1, 'safebooru': 2},
    themeMode: 'dark',
    desktopColumns: 5,
    mobileColumns: 2,
    blurExplicitContent: true,
    allowDownloads: true,
    selectedFeedProviderIds: [],
    showPostBadges: true,
    defaultTopPeriodFilter: 'none',
    blacklistedTags: [],
    whitelistedTags: [],
    smartBlacklistRules: [],
    hideViewedPosts: false,
    mediaQualityMode: 'auto',
    hiddenPostKeys: [],
    diagnosticLogLines: [],
    lastFeedTags: [],
    lastFeedProviderIds: [],
    lastFeedTopPeriod: 'none',
    lastFeedScrollOffset: 0,
    skippedUpdateVersion: null,
    lastUpdateCheckAt: null,
    defaultRatingFilter: null,
    lastFeedRating: null,
  );

  AppSettings copyWith({
    List<String>? enabledProviderIds,
    bool? nsfwEnabled,
    int? cacheTtlHours,
    int? cacheMaxItems,
    Map<String, int>? providerPriority,
    String? themeMode,
    int? desktopColumns,
    int? mobileColumns,
    bool? blurExplicitContent,
    bool? allowDownloads,
    List<String>? selectedFeedProviderIds,
    bool? showPostBadges,
    String? defaultTopPeriodFilter,
    List<String>? blacklistedTags,
    List<String>? whitelistedTags,
    List<String>? smartBlacklistRules,
    bool? hideViewedPosts,
    String? mediaQualityMode,
    List<String>? hiddenPostKeys,
    List<String>? diagnosticLogLines,
    List<String>? lastFeedTags,
    List<String>? lastFeedProviderIds,
    String? lastFeedTopPeriod,
    double? lastFeedScrollOffset,
    String? skippedUpdateVersion,
    String? lastUpdateCheckAt,
    String? defaultRatingFilter,
    String? lastFeedRating,
    bool clearLastFeedRating = false,
  }) {
    return AppSettings(
      enabledProviderIds: enabledProviderIds ?? this.enabledProviderIds,
      nsfwEnabled: nsfwEnabled ?? this.nsfwEnabled,
      cacheTtlHours: cacheTtlHours ?? this.cacheTtlHours,
      cacheMaxItems: cacheMaxItems ?? this.cacheMaxItems,
      providerPriority: providerPriority ?? this.providerPriority,
      themeMode: themeMode ?? this.themeMode,
      desktopColumns: desktopColumns ?? this.desktopColumns,
      mobileColumns: mobileColumns ?? this.mobileColumns,
      blurExplicitContent: blurExplicitContent ?? this.blurExplicitContent,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      selectedFeedProviderIds:
          selectedFeedProviderIds ?? this.selectedFeedProviderIds,
      showPostBadges: showPostBadges ?? this.showPostBadges,
      defaultTopPeriodFilter:
          defaultTopPeriodFilter ?? this.defaultTopPeriodFilter,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
      whitelistedTags: whitelistedTags ?? this.whitelistedTags,
      smartBlacklistRules: smartBlacklistRules ?? this.smartBlacklistRules,
      hideViewedPosts: hideViewedPosts ?? this.hideViewedPosts,
      mediaQualityMode: mediaQualityMode ?? this.mediaQualityMode,
      hiddenPostKeys: hiddenPostKeys ?? this.hiddenPostKeys,
      diagnosticLogLines: diagnosticLogLines ?? this.diagnosticLogLines,
      lastFeedTags: lastFeedTags ?? this.lastFeedTags,
      lastFeedProviderIds: lastFeedProviderIds ?? this.lastFeedProviderIds,
      lastFeedTopPeriod: lastFeedTopPeriod ?? this.lastFeedTopPeriod,
      lastFeedScrollOffset: lastFeedScrollOffset ?? this.lastFeedScrollOffset,
      skippedUpdateVersion: skippedUpdateVersion ?? this.skippedUpdateVersion,
      lastUpdateCheckAt: lastUpdateCheckAt ?? this.lastUpdateCheckAt,
      defaultRatingFilter: defaultRatingFilter ?? this.defaultRatingFilter,
      lastFeedRating:
          clearLastFeedRating ? null : lastFeedRating ?? this.lastFeedRating,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabledProviderIds': enabledProviderIds,
        'nsfwEnabled': nsfwEnabled,
        'cacheTtlHours': cacheTtlHours,
        'cacheMaxItems': cacheMaxItems,
        'providerPriority': providerPriority,
        'themeMode': themeMode,
        'desktopColumns': desktopColumns,
        'mobileColumns': mobileColumns,
        'blurExplicitContent': blurExplicitContent,
        'allowDownloads': allowDownloads,
        'selectedFeedProviderIds': selectedFeedProviderIds,
        'showPostBadges': showPostBadges,
        'defaultTopPeriodFilter': defaultTopPeriodFilter,
        'blacklistedTags': blacklistedTags,
        'whitelistedTags': whitelistedTags,
        'smartBlacklistRules': smartBlacklistRules,
        'hideViewedPosts': hideViewedPosts,
        'mediaQualityMode': mediaQualityMode,
        'hiddenPostKeys': hiddenPostKeys,
        'diagnosticLogLines': diagnosticLogLines,
        'lastFeedTags': lastFeedTags,
        'lastFeedProviderIds': lastFeedProviderIds,
        'lastFeedTopPeriod': lastFeedTopPeriod,
        'lastFeedScrollOffset': lastFeedScrollOffset,
        'skippedUpdateVersion': skippedUpdateVersion,
        'lastUpdateCheckAt': lastUpdateCheckAt,
        'defaultRatingFilter': defaultRatingFilter,
        'lastFeedRating': lastFeedRating,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        enabledProviderIds: List<String>.from(
          (json['enabledProviderIds'] as List?) ?? defaults.enabledProviderIds,
        ),
        nsfwEnabled: (json['nsfwEnabled'] as bool?) ?? defaults.nsfwEnabled,
        cacheTtlHours:
            (json['cacheTtlHours'] as num?)?.toInt() ?? defaults.cacheTtlHours,
        cacheMaxItems:
            (json['cacheMaxItems'] as num?)?.toInt() ?? defaults.cacheMaxItems,
        providerPriority: Map<String, int>.from(
          (json['providerPriority'] as Map?) ?? defaults.providerPriority,
        ),
        themeMode: (json['themeMode'] as String?) ?? defaults.themeMode,
        desktopColumns: (json['desktopColumns'] as num?)?.toInt() ??
            defaults.desktopColumns,
        mobileColumns:
            (json['mobileColumns'] as num?)?.toInt() ?? defaults.mobileColumns,
        blurExplicitContent: (json['blurExplicitContent'] as bool?) ??
            defaults.blurExplicitContent,
        allowDownloads:
            (json['allowDownloads'] as bool?) ?? defaults.allowDownloads,
        selectedFeedProviderIds: List<String>.from(
          (json['selectedFeedProviderIds'] as List?) ??
              defaults.selectedFeedProviderIds,
        ),
        showPostBadges:
            (json['showPostBadges'] as bool?) ?? defaults.showPostBadges,
        defaultTopPeriodFilter: (json['defaultTopPeriodFilter'] as String?) ??
            defaults.defaultTopPeriodFilter,
        blacklistedTags: List<String>.from(
          (json['blacklistedTags'] as List?) ?? defaults.blacklistedTags,
        ),
        whitelistedTags: List<String>.from(
          (json['whitelistedTags'] as List?) ?? defaults.whitelistedTags,
        ),
        smartBlacklistRules: List<String>.from(
          (json['smartBlacklistRules'] as List?) ??
              (json['blacklistedTags'] as List?) ??
              defaults.smartBlacklistRules,
        ),
        hideViewedPosts:
            (json['hideViewedPosts'] as bool?) ?? defaults.hideViewedPosts,
        mediaQualityMode:
            (json['mediaQualityMode'] as String?) ?? defaults.mediaQualityMode,
        hiddenPostKeys: List<String>.from(
          (json['hiddenPostKeys'] as List?) ?? defaults.hiddenPostKeys,
        ),
        diagnosticLogLines: List<String>.from(
          (json['diagnosticLogLines'] as List?) ?? defaults.diagnosticLogLines,
        ),
        lastFeedTags: List<String>.from(
          (json['lastFeedTags'] as List?) ?? defaults.lastFeedTags,
        ),
        lastFeedProviderIds: List<String>.from(
          (json['lastFeedProviderIds'] as List?) ??
              (json['selectedFeedProviderIds'] as List?) ??
              defaults.lastFeedProviderIds,
        ),
        lastFeedTopPeriod: (json['lastFeedTopPeriod'] as String?) ??
            (json['defaultTopPeriodFilter'] as String?) ??
            defaults.lastFeedTopPeriod,
        lastFeedScrollOffset:
            (json['lastFeedScrollOffset'] as num?)?.toDouble() ??
                defaults.lastFeedScrollOffset,
        skippedUpdateVersion: json['skippedUpdateVersion'] as String?,
        lastUpdateCheckAt: json['lastUpdateCheckAt'] as String?,
        defaultRatingFilter: json['defaultRatingFilter'] as String?,
        lastFeedRating: json['lastFeedRating'] as String?,
      );
}

class SettingsService {
  SettingsService(
    this._databaseService, {
    ProviderRepository? providerRepository,
  }) : _providerRepository = providerRepository;

  final DatabaseService _databaseService;
  final ProviderRepository? _providerRepository;
  static const _settingsKey = 'app_settings';

  Future<Result<AppSettings>> getSettings() {
    return _databaseService.safeRead((isar) async {
      final entity = await isar.appSettingEntitys
          .filter()
          .keyEqualTo(_settingsKey)
          .findFirst();
      if (entity == null) return AppSettings.defaults;
      return AppSettings.fromJson(
          jsonDecode(entity.jsonValue) as Map<String, dynamic>);
    });
  }

  Future<Result<void>> updateSettings(AppSettings settings) {
    return _databaseService.safeWrite((isar) async {
      await isar.appSettingEntitys.put(
        AppSettingEntity()
          ..key = _settingsKey
          ..jsonValue = jsonEncode(settings.toJson())
          ..updatedAt = DateTime.now(),
      );
    });
  }

  Future<Result<void>> saveEnabledProviders(List<String> providerIds) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    final updateResult = await updateSettings(
        settings.copyWith(enabledProviderIds: providerIds));
    if (updateResult is Error<void>) return updateResult;

    final repository = _providerRepository;
    if (repository == null) return updateResult;

    final providersResult = await repository.getProviders();
    if (providersResult is Error<List<ContentProviderConfig>>) {
      return Error(providersResult.failure);
    }
    final enabled = providerIds.toSet();
    for (final provider
        in (providersResult as Success<List<ContentProviderConfig>>).data) {
      await repository.saveProvider(
        provider.copyWith(
          enabled: enabled.contains(provider.id),
          updatedAt: DateTime.now(),
        ),
      );
    }
    return updateResult;
  }

  Future<Result<void>> saveNsfwFilter(bool enabled) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return updateSettings(settings.copyWith(nsfwEnabled: enabled));
  }

  Future<Result<void>> saveCacheSettings({
    required int ttlHours,
    required int maxItems,
  }) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return updateSettings(
      settings.copyWith(cacheTtlHours: ttlHours, cacheMaxItems: maxItems),
    );
  }

  Future<Result<void>> hidePostKey(String cacheKey) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    final hidden = <String>{...settings.hiddenPostKeys, cacheKey}.toList()
      ..sort();
    return updateSettings(settings.copyWith(hiddenPostKeys: hidden));
  }

  Future<Result<void>> unhidePostKey(String cacheKey) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return updateSettings(
      settings.copyWith(
        hiddenPostKeys:
            settings.hiddenPostKeys.where((key) => key != cacheKey).toList(),
      ),
    );
  }

  Future<Result<void>> clearHiddenPosts() async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return updateSettings(settings.copyWith(hiddenPostKeys: const []));
  }

  Future<Result<void>> appendDiagnosticLog(String message) async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    final line = '${DateTime.now().toIso8601String()}  $message';
    final lines = [...settings.diagnosticLogLines, line];
    return updateSettings(
      settings.copyWith(
        diagnosticLogLines:
            lines.length > 200 ? lines.sublist(lines.length - 200) : lines,
      ),
    );
  }

  Future<Result<void>> clearDiagnosticLogs() async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    return updateSettings(settings.copyWith(diagnosticLogLines: const []));
  }

  Future<Result<String>> buildDiagnosticsReport({
    required String appVersion,
    required int buildNumber,
  }) async {
    final settingsResult = await getSettings();
    if (settingsResult is Error<AppSettings>) {
      return Error(settingsResult.failure);
    }
    final settings = (settingsResult as Success<AppSettings>).data;
    final providers = <ContentProviderConfig>[];
    final diagnostics = <String>[];
    final repository = _providerRepository;
    if (repository != null) {
      final providersResult = await repository.getProviders(enabledOnly: false);
      if (providersResult is Success<List<ContentProviderConfig>>) {
        providers.addAll(providersResult.data);
      }
      final diagnosticsResult = await repository.getDiagnostics();
      if (diagnosticsResult is Success<List<ProviderDiagnostics>>) {
        for (final item in diagnosticsResult.data) {
          diagnostics.add(
            '${item.providerId}: ${item.lastResultCount} posts, '
            'lastSearchAt=${item.lastSearchAt}, '
            'error=${item.lastErrorMessage ?? 'none'}',
          );
        }
      }
    }
    final enabledProviders =
        providers.where((provider) => provider.enabled).map((p) => p.id);
    return Success(
      const JsonEncoder.withIndent('  ').convert({
        'app': {
          'name': 'RuleGel',
          'version': appVersion,
          'build': buildNumber,
          'generatedAt': DateTime.now().toIso8601String(),
        },
        'settingsSummary': {
          'themeMode': settings.themeMode,
          'nsfwEnabled': settings.nsfwEnabled,
          'blurExplicitContent': settings.blurExplicitContent,
          'mediaQualityMode': settings.mediaQualityMode,
          'cacheTtlHours': settings.cacheTtlHours,
          'cacheMaxItems': settings.cacheMaxItems,
          'hiddenPosts': settings.hiddenPostKeys.length,
          'blacklistRules': settings.smartBlacklistRules.length,
          'whitelistTags': settings.whitelistedTags.length,
          'hideViewedPosts': settings.hideViewedPosts,
        },
        'providers': {
          'enabled': enabledProviders.toList(),
          'all': providers
              .map((provider) => {
                    'id': provider.id,
                    'name': provider.name,
                    'apiType': provider.apiType,
                    'enabled': provider.enabled,
                    'priority': provider.priority,
                    'baseUrl': provider.baseUrl,
                  })
              .toList(),
        },
        'recentLogs': settings.diagnosticLogLines.take(60).toList(),
        'providerDiagnostics': diagnostics,
      }),
    );
  }

  Future<Result<String>> exportSettingsToJson() async {
    final result = await getSettings();
    if (result is Error<AppSettings>) return Error(result.failure);
    final settings = (result as Success<AppSettings>).data;
    final providers = <ContentProviderConfig>[];
    final repository = _providerRepository;
    if (repository != null) {
      final providersResult = await repository.getProviders(enabledOnly: false);
      if (providersResult is Success<List<ContentProviderConfig>>) {
        providers.addAll(providersResult.data);
      }
    }
    return Success(
      const JsonEncoder.withIndent('  ').convert({
        'schemaVersion': 2,
        'settings': settings.toJson(),
        'filters': {
          'blacklistedTags': settings.blacklistedTags,
          'whitelistedTags': settings.whitelistedTags,
          'smartBlacklistRules': settings.smartBlacklistRules,
          'hiddenPostKeys': settings.hiddenPostKeys,
        },
        'providers': providers.map((provider) => provider.toJson()).toList(),
      }),
    );
  }

  Future<Result<void>> importSettingsFromJson(String json) async {
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final settingsJson =
          (decoded['settings'] as Map?)?.cast<String, dynamic>() ?? decoded;
      final filtersJson =
          (decoded['filters'] as Map?)?.cast<String, dynamic>() ?? const {};
      for (final key in [
        'blacklistedTags',
        'whitelistedTags',
        'smartBlacklistRules',
      ]) {
        settingsJson.putIfAbsent(key, () => filtersJson[key]);
      }
      final settings = AppSettings.fromJson(settingsJson);
      final result = await updateSettings(settings);
      if (result is Error<void>) return result;
      final repository = _providerRepository;
      final providerItems = decoded['providers'];
      if (repository != null && providerItems is List) {
        for (final item in providerItems.whereType<Map>()) {
          await repository.saveProvider(
            ContentProviderConfig.fromJson(
              Map<String, dynamic>.from(item),
            ).copyWith(updatedAt: DateTime.now()),
          );
        }
      }
      await saveEnabledProviders(settings.enabledProviderIds);
      return result;
    } catch (error) {
      return Error(
        Failure(
          code: 'settings_import',
          message: 'Invalid settings JSON',
          details: error,
        ),
      );
    }
  }
}
