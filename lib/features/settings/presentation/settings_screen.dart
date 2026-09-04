import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide appBuildNumber;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../../../app/app_version.dart';
import '../../../app/changelog.dart';
import '../../../app/app_strings.dart';
import '../../../app/motion.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/error_view.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final strings = AppStrings(
      settings.value?.languageCode ?? AppSettings.defaults.languageCode,
    );
    return AdaptiveScaffold(
      title: strings.settings,
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerStatefulWidget {
  const _SettingsContent({required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<_SettingsContent> {
  final _scrollController = ScrollController();

  final _generalKey = GlobalKey();
  final _appearanceKey = GlobalKey();
  final _feedKey = GlobalKey();
  final _filtersKey = GlobalKey();
  final _storageKey = GlobalKey();
  final _diagnosticsKey = GlobalKey();
  final _aboutKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  AppSettings get settings => widget.settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAndroid = Platform.isAndroid;
    final strings = AppStrings(settings.languageCode);
    final isRu = strings.ru;
    final deviceInfo =
        isAndroid ? ref.watch(motionDeviceInfoProvider).value : null;
    final detectedHz =
        isAndroid ? View.maybeOf(context)?.display.refreshRate ?? 60.0 : 60.0;
    final motion = isAndroid
        ? resolveMotionSettings(
            settings: settings,
            detectedHz: detectedHz,
            device: deviceInfo,
          )
        : null;

    final navCategories = [
      (
        key: _generalKey,
        label: strings.general,
        icon: Icons.tune_rounded,
        color: const Color(0xFF6366F1),
      ),
      (
        key: _appearanceKey,
        label: strings.appearance,
        icon: Icons.palette_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      (
        key: _feedKey,
        label: strings.feedLayout,
        icon: Icons.dashboard_customize_rounded,
        color: const Color(0xFF10B981),
      ),
      (
        key: _filtersKey,
        label: strings.filters,
        icon: Icons.filter_alt_rounded,
        color: const Color(0xFFF59E0B),
      ),
      (
        key: _storageKey,
        label: strings.storage,
        icon: Icons.storage_rounded,
        color: const Color(0xFF06B6D4),
      ),
      (
        key: _diagnosticsKey,
        label: isRu ? 'Диагностика' : 'Diagnostics',
        icon: Icons.hub_rounded,
        color: const Color(0xFF3B82F6),
      ),
      (
        key: _aboutKey,
        label: strings.about,
        icon: Icons.info_rounded,
        color: const Color(0xFFE84D8A),
      ),
    ];

    return Column(
      children: [
        // Pinned Top Category Quick Navigation
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: _CategoryQuickNav(
                categories: navCategories,
                onSelect: _scrollTo,
              ),
            ),
          ),
        ),

        // Scrollable Settings Cards
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. General Section
                    _SettingsCardGroup(
                      sectionKey: _generalKey,
                      title: strings.general,
                      icon: Icons.tune_rounded,
                      accentColor: const Color(0xFF6366F1),
                      children: [
                        _SettingsSegmentedTile<String>(
                          icon: Icons.brightness_6_rounded,
                          iconColor: const Color(0xFF6366F1),
                          title: strings.theme,
                          subtitle: isRu
                              ? 'Оформление цветовой схемы приложения'
                              : 'App theme brightness mode',
                          segments: [
                            ButtonSegment(
                              value: 'dark',
                              icon: const Icon(Icons.dark_mode_rounded, size: 16),
                              label: Text(isRu ? 'Темная' : 'Dark'),
                            ),
                            ButtonSegment(
                              value: 'light',
                              icon: const Icon(Icons.light_mode_rounded, size: 16),
                              label: Text(isRu ? 'Светлая' : 'Light'),
                            ),
                            ButtonSegment(
                              value: 'system',
                              icon: const Icon(Icons.brightness_auto_rounded, size: 16),
                              label: Text(isRu ? 'Авто' : 'Auto'),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (set) => _update(
                            ref,
                            settings.copyWith(themeMode: set.first),
                          ),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.explicit_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: strings.allowNsfw,
                          subtitle: isRu
                              ? 'Отображать контент с рейтингом Questionable и Explicit'
                              : 'Show Questionable and Explicit rated media',
                          value: settings.nsfwEnabled,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(nsfwEnabled: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.blur_on_rounded,
                          iconColor: const Color(0xFFEC4899),
                          title: strings.blurSensitive,
                          subtitle: isRu
                              ? 'Мягко размывать превью откровенных постов в ленте'
                              : 'Blur sensitive thumbnails in feed grid',
                          value: settings.blurExplicitContent,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(blurExplicitContent: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.label_important_outline_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: strings.showPostBadges,
                          subtitle: isRu
                              ? 'Индикаторы видео, источников, рейтингов и статусов'
                              : 'Show source, rating and media indicators on cards',
                          value: settings.showPostBadges,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(showPostBadges: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.download_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: strings.allowDownloads,
                          subtitle: isRu
                              ? 'Кнопки быстрого скачивания медиафайлов'
                              : 'Enable direct download buttons on cards & viewer',
                          value: settings.allowDownloads,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(allowDownloads: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.offline_pin_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          title: isRu ? 'Offline избранное' : 'Offline favorites',
                          subtitle: isRu
                              ? 'Фоновая загрузка медиафайла при добавлении поста в избранное'
                              : 'Automatically cache files in background when favorited',
                          value: settings.autoDownloadFavorites,
                          onChanged: (val) => _update(
                            ref,
                            settings.copyWith(autoDownloadFavorites: val),
                          ),
                        ),
                        if (settings.allowDownloads) ...[
                          const _SettingsDivider(),
                          _SettingsFolderStructureTile(
                            currentTemplate: settings.downloadPathTemplate,
                            isRu: isRu,
                            onChanged: (template) => _update(
                              ref,
                              settings.copyWith(downloadPathTemplate: template),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 2. Appearance Section
                    _SettingsCardGroup(
                      sectionKey: _appearanceKey,
                      title: strings.appearance,
                      icon: Icons.palette_rounded,
                      accentColor: const Color(0xFF8B5CF6),
                      children: [
                        _SettingsSegmentedTile<String>(
                          icon: Icons.translate_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: strings.language,
                          subtitle: isRu
                              ? 'Язык интерфейса приложения'
                              : 'App user interface language',
                          segments: const [
                            ButtonSegment(
                              value: 'ru',
                              label: Text('🇷🇺 Русский'),
                            ),
                            ButtonSegment(
                              value: 'en',
                              label: Text('🇬🇧 English'),
                            ),
                          ],
                          selected: {settings.languageCode},
                          onSelectionChanged: (set) => _update(
                            ref,
                            settings.copyWith(languageCode: set.first),
                          ),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.contrast_rounded,
                          iconColor: const Color(0xFF475569),
                          title: isRu ? 'AMOLED Pure Black' : 'AMOLED Pure Black',
                          subtitle: isRu
                              ? 'Абсолютно черный фон (#000000) для OLED-дисплеев'
                              : 'Deep black (#000000) surfaces for OLED screens',
                          value: settings.amoledMode,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(amoledMode: val)),
                        ),
                        if (isAndroid) ...[
                          const _SettingsDivider(),
                          _SettingsSwitchTile(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: const Color(0xFFEC4899),
                            title: isRu
                                ? 'Динамические цвета Material You'
                                : 'Material You Dynamic Colors',
                            subtitle: isRu
                                ? 'Палитра интерфейса подстраивается под обои системы'
                                : 'Color palette adapts automatically to device wallpaper',
                            value: settings.useDynamicColor,
                            onChanged: (val) =>
                                _update(ref, settings.copyWith(useDynamicColor: val)),
                          ),
                        ],
                        const _SettingsDivider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: _ColorSwatches(
                            selected: settings.appSeedColor,
                            onChanged: (color) =>
                                _update(ref, settings.copyWith(appSeedColor: color)),
                          ),
                        ),
                        const _SettingsDivider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: _TabVisibilityEditor(
                            hiddenTabs: settings.hiddenTabs,
                            onChanged: (hiddenTabs) =>
                                _update(ref, settings.copyWith(hiddenTabs: hiddenTabs)),
                          ),
                        ),
                        const _SettingsDivider(),
                        _SettingsSwitchTile(
                          icon: Icons.science_rounded,
                          iconColor: const Color(0xFFF97316),
                          title: isRu
                              ? 'Beta и экспериментальные обновления'
                              : 'Receive beta & experimental updates',
                          subtitle: isRu
                              ? 'Проверка и уведомление о prerelease сборках Lunaris'
                              : 'Include prerelease builds when checking for updates',
                          value: settings.allowExperimentalUpdates,
                          onChanged: (val) => _update(
                            ref,
                            settings.copyWith(allowExperimentalUpdates: val),
                          ),
                        ),
                      ],
                    ),

                    // 3. Feed & Layout Section
                    _SettingsCardGroup(
                      sectionKey: _feedKey,
                      title: strings.feedLayout,
                      icon: Icons.dashboard_customize_rounded,
                      accentColor: const Color(0xFF10B981),
                      children: [
                        _SettingsSegmentedTile<String>(
                          icon: Icons.high_quality_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: strings.mediaQuality,
                          subtitle: isRu
                              ? 'Разрешение загружаемых картинок в сетке'
                              : 'Resolution profile for feed thumbnails',
                          segments: [
                            for (final mode in MediaQualityMode.values)
                              ButtonSegment(
                                value: mode.name,
                                label: Text(
                                  isRu
                                      ? switch (mode) {
                                          MediaQualityMode.auto => 'Авто',
                                          MediaQualityMode.dataSaver => 'Экономия',
                                          MediaQualityMode.highQuality => 'HQ',
                                        }
                                      : mode.label,
                                ),
                              ),
                          ],
                          selected: {settings.mediaQualityMode},
                          onSelectionChanged: (set) => _update(
                            ref,
                            settings.copyWith(mediaQualityMode: set.first),
                          ),
                        ),
                        if (isAndroid) ...[
                          const _SettingsDivider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.speed_rounded,
                                        size: 20,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isRu
                                                ? 'Частота обновления экрана'
                                                : 'Animation refresh profile',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            isRu
                                                ? 'Оптимизация плавности скролла ленты'
                                                : 'Fluid 120-165 Hz scrolling optimization',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final mode in MotionRefreshMode.values)
                                      ChoiceChip(
                                        label: Text(mode.label),
                                        selected: settings.motionRefreshMode == mode.name,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _update(
                                              ref,
                                              settings.copyWith(
                                                motionRefreshMode: mode.name,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const _SettingsDivider(),
                          _SettingsSwitchTile(
                            icon: Icons.battery_saver_rounded,
                            iconColor: const Color(0xFF22C55E),
                            title: isRu
                                ? 'Энергосбережение: 60 Гц при < 20% батареи'
                                : 'Auto 60 Hz below 20% battery',
                            subtitle: isRu
                                ? 'Определено ${motion!.detectedHz.toStringAsFixed(0)} Гц'
                                    '${motion.batteryLevel == null ? '' : ', заряд ${motion.batteryLevel}%'}'
                                    '${motion.batterySaverActive ? ', режим энергосбережения' : ''}'
                                : 'Detected ${motion!.detectedHz.toStringAsFixed(0)} Hz'
                                    '${motion.batteryLevel == null ? '' : ', battery ${motion.batteryLevel}%'}'
                                    '${motion.batterySaverActive ? ', saver active' : ''}',
                            value: settings.autoBatterySaver60Hz,
                            onChanged: (val) => _update(
                              ref,
                              settings.copyWith(autoBatterySaver60Hz: val),
                            ),
                          ),
                        ],
                        const _SettingsDivider(),
                        _SettingsStepperTile(
                          icon: Icons.desktop_windows_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: strings.desktopColumns,
                          subtitle: isRu
                              ? 'Количество столбцов постов на ПК'
                              : 'Columns on desktop layout',
                          value: settings.desktopColumns,
                          min: 3,
                          max: 8,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(desktopColumns: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsStepperTile(
                          icon: Icons.smartphone_rounded,
                          iconColor: const Color(0xFF6366F1),
                          title: strings.mobileColumns,
                          subtitle: isRu
                              ? 'Количество столбцов постов на телефоне'
                              : 'Columns on phone layout',
                          value: settings.mobileColumns,
                          min: 1,
                          max: 3,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(mobileColumns: val)),
                        ),
                      ],
                    ),

                    // 4. Filters & Blacklist Section
                    _SettingsCardGroup(
                      sectionKey: _filtersKey,
                      title: strings.filters,
                      icon: Icons.filter_alt_rounded,
                      accentColor: const Color(0xFFF59E0B),
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.visibility_off_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: strings.hideViewed,
                          subtitle: isRu
                              ? 'Автоматически скрывать просмотренные посты из ленты'
                              : 'Automatically hide already seen posts from feed',
                          value: settings.hideViewedPosts,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(hideViewedPosts: val)),
                        ),
                        const _SettingsDivider(),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: _TagListEditor(
                            title: strings.smartBlacklist,
                            icon: Icons.block_rounded,
                            accentColor: const Color(0xFFEF4444),
                            tags: settings.smartBlacklistRules,
                            helper: isRu
                                ? 'Примеры: tag, tag_a tag_b, provider:e621, rating:explicit, type:video, score:<10, artist:name'
                                : 'Examples: tag, tag_a tag_b, provider:e621, rating:explicit, type:video, score:<10, artist:name',
                            onChanged: (tags) => _update(
                              ref,
                              settings.copyWith(smartBlacklistRules: tags),
                            ),
                          ),
                        ),
                        const _SettingsDivider(),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: _TagListEditor(
                            title: strings.whitelistedTags,
                            icon: Icons.verified_rounded,
                            accentColor: const Color(0xFF10B981),
                            tags: settings.whitelistedTags,
                            helper: isRu
                                ? 'Теги, которые никогда не будут скрываться черным списком'
                                : 'Tags that will bypass blacklist rules',
                            onChanged: (tags) => _update(
                              ref,
                              settings.copyWith(whitelistedTags: tags),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 5. Storage Section
                    _SettingsCardGroup(
                      sectionKey: _storageKey,
                      title: strings.storage,
                      icon: Icons.storage_rounded,
                      accentColor: const Color(0xFF06B6D4),
                      children: [
                        _SettingsStepperTile(
                          icon: Icons.photo_library_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          title: strings.cacheMaxItems,
                          subtitle: isRu
                              ? 'Максимальное количество файлов в дисковом кэше'
                              : 'Max items stored in image/video cache',
                          value: settings.cacheMaxItems,
                          min: 100,
                          max: 10000,
                          step: 100,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(cacheMaxItems: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsStepperTile(
                          icon: Icons.history_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: isRu ? 'Лимит истории поиска' : 'Search history limit',
                          subtitle: isRu
                              ? 'Хранение недавних поисковых запросов'
                              : 'Max search query entries stored',
                          value: settings.searchHistoryLimit,
                          min: 50,
                          max: 2000,
                          step: 50,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(searchHistoryLimit: val)),
                        ),
                        const _SettingsDivider(),
                        _SettingsStepperTile(
                          icon: Icons.tag_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: isRu ? 'Лимит кэша тегов (диск)' : 'Tag cache limit (disk)',
                          subtitle: isRu
                              ? 'Количество кэшируемых подсказок тегов на диске'
                              : 'Max tag autocomplete entries persisted on disk',
                          value: settings.tagCacheLimit,
                          min: 500,
                          max: 20000,
                          step: 500,
                          onChanged: (val) =>
                              _update(ref, settings.copyWith(tagCacheLimit: val)),
                        ),
                        const _SettingsDivider(),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: _ActionGrid(
                            children: [
                              _ActionButton(
                                icon: Icons.cleaning_services_rounded,
                                label: strings.clearCache,
                                onPressed: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .clearCache(),
                              ),
                              _ActionButton(
                                icon: Icons.pie_chart_rounded,
                                label: isRu ? 'Менеджер кэша' : 'Cache Manager',
                                isPrimary: true,
                                onPressed: () => context.go('/settings/cache'),
                              ),
                              _ActionButton(
                                icon: Icons.label_off_rounded,
                                label: isRu ? 'Очистить кэш тегов' : 'Clear tag cache',
                                onPressed: () async {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .clearTagCache();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isRu
                                              ? 'Кэш подсказок тегов очищен'
                                              : 'Tag suggestions cache cleared',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              _ActionButton(
                                icon: Icons.history_toggle_off_rounded,
                                label: isRu
                                    ? 'Очистить историю поиска'
                                    : 'Clear search history',
                                onPressed: () async {
                                  await ref
                                      .read(settingsControllerProvider.notifier)
                                      .clearSearchHistory();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isRu
                                              ? 'История поиска очищена'
                                              : 'Search history cleared',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              _ActionButton(
                                icon: Icons.visibility_off_rounded,
                                label: strings.clearViewed,
                                onPressed: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .clearViewedHistory(),
                              ),
                              _ActionButton(
                                icon: Icons.restore_rounded,
                                label: isRu ? 'Скрытые посты' : 'Hidden posts',
                                onPressed: settings.hiddenPostKeys.isEmpty
                                    ? null
                                    : () => context.go('/settings/hidden'),
                              ),
                              _ActionButton(
                                icon: Icons.delete_sweep_rounded,
                                label: isRu
                                    ? 'Очистить скрытые (${settings.hiddenPostKeys.length})'
                                    : 'Clear hidden (${settings.hiddenPostKeys.length})',
                                onPressed: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .clearHiddenPosts(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 6. Providers & Diagnostics Section
                    _SettingsCardGroup(
                      sectionKey: _diagnosticsKey,
                      title: isRu ? 'Провайдеры и диагностика' : 'Providers & Diagnostics',
                      icon: Icons.hub_rounded,
                      accentColor: const Color(0xFF3B82F6),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: _ActionGrid(
                            children: [
                              _ActionButton(
                                icon: Icons.hub_rounded,
                                label: isRu ? 'Провайдеры' : 'Providers',
                                isPrimary: true,
                                onPressed: () => context.go('/providers'),
                              ),
                              _ActionButton(
                                icon: Icons.network_check_rounded,
                                label: isRu ? 'Диагностика сети' : 'Diagnostics',
                                isPrimary: true,
                                onPressed: () => context.go('/providers/check'),
                              ),
                              _ActionButton(
                                icon: Icons.bug_report_rounded,
                                label: isRu ? 'Копировать отчет' : 'Copy report',
                                onPressed: () => _copyDiagnostics(context, ref),
                              ),
                              _ActionButton(
                                icon: Icons.receipt_long_rounded,
                                label: isRu ? 'Копировать логи' : 'Copy logs',
                                onPressed: () => _copyLogs(context, ref),
                              ),
                              _ActionButton(
                                icon: Icons.delete_sweep_rounded,
                                label: isRu ? 'Очистить логи' : 'Clear logs',
                                onPressed: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .clearDiagnosticLogs(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 7. About & Hero Section
                    _HeroBrandBanner(
                      sectionKey: _aboutKey,
                      settings: settings,
                      isRu: isRu,
                      onCheckUpdates: () => _checkUpdates(context, ref),
                      onShowChangelog: () => _showChangelog(context),
                      onExportJson: () => _exportJson(context, ref),
                      onImportJson: () => _importDialog(context, ref),
                      onExportBackup: () => _exportBackupFile(context, ref),
                      onImportBackup: () => _importBackupFile(context, ref),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _update(WidgetRef ref, AppSettings settings) {
    return ref.read(settingsControllerProvider.notifier).saveSettings(settings);
  }

  Future<void> _copyDiagnostics(BuildContext context, WidgetRef ref) async {
    final report =
        await ref.read(settingsControllerProvider.notifier).diagnosticsReport();
    await Clipboard.setData(ClipboardData(text: report));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied')),
    );
  }

  Future<void> _copyLogs(BuildContext context, WidgetRef ref) async {
    final logs =
        await ref.read(settingsControllerProvider.notifier).diagnosticLogs();
    await Clipboard.setData(ClipboardData(text: logs));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostic logs copied')),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    final json =
        await ref.read(settingsControllerProvider.notifier).exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings JSON copied')),
    );
  }

  Future<void> _exportBackupFile(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(backupServiceProvider).exportBackup();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бэкап сохранен / отправлен')),
      );
    }
  }

  Future<void> _importBackupFile(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(backupServiceProvider).importBackup();
    if (!context.mounted) return;
    if (result == null) return;
    if (result is Success<AppSettings>) {
      ref.invalidate(appSettingsProvider);
      ref.invalidate(settingsControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки успешно импортированы!')),
      );
    } else if (result is Error<AppSettings>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка импорта: ${result.failure.message}')),
      );
    }
  }

  Future<void> _importDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import settings'),
        content: TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(labelText: 'JSON'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .importJson(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _checkUpdates(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
    final result =
        await ref.read(updateServiceProvider).checkForUpdates(force: true);
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    if (result is Error<AppUpdateInfo?>) {
      messenger.showSnackBar(SnackBar(content: Text(result.failure.message)));
      return;
    }
    final update = (result as Success<AppUpdateInfo?>).data;
    if (update == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Lunaris is up to date')),
      );
      return;
    }
    await _updateDialog(context, ref, update);
  }

  Future<void> _updateDialog(
    BuildContext context,
    WidgetRef ref,
    AppUpdateInfo info,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lunaris ${info.version} is available'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Text(
              info.body.trim().isEmpty ? info.name : info.body.trim(),
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).skipVersion(info);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Skip this version'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(updateServiceProvider).remindLater();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await _downloadUpdate(ref, info);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download & open'),
          ),
        ],
      ),
    );
    ref.invalidate(settingsControllerProvider);
  }

  Future<void> _downloadUpdate(WidgetRef ref, AppUpdateInfo info) async {
    final updateService = ref.read(updateServiceProvider);
    final assetUrl = updateService.assetUrlForCurrentPlatform(info);
    if (assetUrl == null) {
      final url = Uri.tryParse(info.htmlUrl);
      if (url != null) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    await ref.read(downloadManagerServiceProvider).startUrl(
          url: assetUrl,
          fileName: updateService.assetFileName(info, assetUrl),
          openAfterDownload: true,
        );
  }

  Future<void> _showChangelog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lunaris changelog'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final change in lunarisChangelog) ...[
                  Text(
                    '${change.version} - ${change.title}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  for (final bullet in change.bullets)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('- $bullet'),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Settings 2.0 Modern Components
// -----------------------------------------------------------------------------

class _CategoryQuickNav extends StatelessWidget {
  const _CategoryQuickNav({
    required this.categories,
    required this.onSelect,
  });

  final List<({GlobalKey key, String label, IconData icon, Color color})>
      categories;
  final ValueChanged<GlobalKey> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Material(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelect(cat.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 16, color: cat.color),
                    const SizedBox(width: 8),
                    Text(
                      cat.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsCardGroup extends StatelessWidget {
  const _SettingsCardGroup({
    required this.sectionKey,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  final Key sectionKey;
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: sectionKey,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 0, endIndent: 0),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.7,
      indent: 68,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width segmented tile so titles never get squeezed vertically on narrow screens.
class _SettingsSegmentedTile<T> extends StatelessWidget {
  const _SettingsSegmentedTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: segments,
              selected: selected,
              onSelectionChanged: onSelectionChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsStepperTile extends StatelessWidget {
  const _SettingsStepperTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.subtitle,
    this.step = 1,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: value <= min ? null : () => onChanged(value - step),
                icon: const Icon(Icons.remove_rounded, size: 18),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: value >= max ? null : () => onChanged(value + step),
                icon: const Icon(Icons.add_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsFolderStructureTile extends StatelessWidget {
  const _SettingsFolderStructureTile({
    required this.currentTemplate,
    required this.isRu,
    required this.onChanged,
  });

  final String currentTemplate;
  final bool isRu;
  final ValueChanged<String> onChanged;

  static const _presets = [
    '{Artist}/{ID}',
    '{Artist}',
    '{Provider}/{Artist}',
    '{Service}/{ID}',
    '{Date}/{Artist}',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_copy_rounded,
                    size: 20,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRu ? 'Папки скачивания' : 'Download folder structure',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRu
                            ? 'Шаблон организации сохраняемых файлов'
                            : 'Path template for organized downloads',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentTemplate,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    isRu ? 'Выбрать' : 'Select',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isRu ? 'Структура папок скачивания' : 'Download path template',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isRu
                      ? 'Переменные: {Artist}, {Provider}, {Service}, {ID}, {Date}'
                      : 'Tags: {Artist}, {Provider}, {Service}, {ID}, {Date}',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                for (final preset in _presets)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(preset, style: const TextStyle(fontFamily: 'monospace')),
                    trailing: currentTemplate == preset
                        ? const Icon(Icons.check_rounded, color: Colors.green)
                        : null,
                    onTap: () => Navigator.pop(ctx, preset),
                  ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.edit_note_rounded),
                  title: Text(
                    isRu ? 'Пользовательский шаблон...' : 'Custom template...',
                  ),
                  onTap: () => Navigator.pop(ctx, '__custom__'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == '__custom__' && context.mounted) {
      final ctrl = TextEditingController(text: currentTemplate);
      final custom = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isRu ? 'Свой шаблон папок' : 'Custom path template'),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: isRu ? 'Шаблон' : 'Template',
              helperText: '{Artist}, {Provider}, {Service}, {ID}, {Date}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isRu ? 'Отмена' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(isRu ? 'Сохранить' : 'Save'),
            ),
          ],
        ),
      );
      if (custom != null && custom.isNotEmpty) {
        onChanged(custom);
      }
    } else if (picked != null && picked != '__custom__') {
      onChanged(picked);
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final child in children)
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 170),
            child: child,
          ),
      ],
    );
  }
}

class _TagListEditor extends StatefulWidget {
  const _TagListEditor({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.tags,
    required this.onChanged,
    this.helper,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? helper;

  @override
  State<_TagListEditor> createState() => _TagListEditorState();
}

class _TagListEditorState extends State<_TagListEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 20, color: widget.accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.tags.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.accentColor,
                ),
              ),
            ),
          ],
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helper!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in widget.tags)
              InputChip(
                label: Text(tag),
                visualDensity: VisualDensity.compact,
                onDeleted: () => widget.onChanged(
                  widget.tags.where((item) => item != tag).toList(),
                ),
              ),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Add tag...',
                  prefixIcon: Icon(Icons.add_rounded, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              tooltip: 'Add',
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    final incoming = _controller.text
        .split(RegExp(r'\s+'))
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty);
    final merged = <String>{...widget.tags, ...incoming}.toList()..sort();
    _controller.clear();
    widget.onChanged(merged);
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const colors = <(int, String)>[
    (0xFFE84D8A, 'Lunaris pink'),
    (0xFF8B5CF6, 'Violet'),
    (0xFF3B82F6, 'Azure'),
    (0xFF0EA5E9, 'Sky'),
    (0xFF14B8A6, 'Teal'),
    (0xFF22C55E, 'Green'),
    (0xFFEAB308, 'Amber'),
    (0xFFF97316, 'Orange'),
    (0xFFEF4444, 'Red'),
    (0xFFEC4899, 'Hot pink'),
    (0xFF6366F1, 'Indigo'),
    (0xFF64748B, 'Slate'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Акцентный цвет интерфейса',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final entry in colors)
              Tooltip(
                message:
                    '${entry.$2} #${entry.$1.toRadixString(16).substring(2).toUpperCase()}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(entry.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Color(entry.$1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected == entry.$1
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: selected == entry.$1 ? 3 : 1.5,
                      ),
                      boxShadow: selected == entry.$1
                          ? [
                              BoxShadow(
                                color: Color(entry.$1).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: selected == entry.$1
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TabVisibilityEditor extends StatelessWidget {
  const _TabVisibilityEditor({
    required this.hiddenTabs,
    required this.onChanged,
  });

  final List<String> hiddenTabs;
  final ValueChanged<List<String>> onChanged;

  static const tabs = <String, (String, IconData)>{
    'feed': ('Feed', Icons.dynamic_feed_rounded),
    'search': ('Search', Icons.search_rounded),
    'favorites': ('Favorites', Icons.favorite_rounded),
    'viewed': ('Viewed', Icons.history_rounded),
    'collections': ('Collections', Icons.collections_bookmark_rounded),
    'artists': ('Artists', Icons.person_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hidden = hiddenTabs.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tab_rounded, size: 20, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Отображение вкладок навигации',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in tabs.entries)
              FilterChip(
                selected: !hidden.contains(entry.key),
                avatar: Icon(entry.value.$2, size: 16),
                label: Text(entry.value.$1),
                onSelected: (visible) {
                  final next = {...hidden};
                  if (visible) {
                    next.remove(entry.key);
                  } else if (entry.key != 'feed') {
                    next.add(entry.key);
                  }
                  onChanged(next.toList()..sort());
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroBrandBanner extends StatelessWidget {
  const _HeroBrandBanner({
    required this.sectionKey,
    required this.settings,
    required this.isRu,
    required this.onCheckUpdates,
    required this.onShowChangelog,
    required this.onExportJson,
    required this.onImportJson,
    required this.onExportBackup,
    required this.onImportBackup,
  });

  final Key sectionKey;
  final AppSettings settings;
  final bool isRu;
  final VoidCallback onCheckUpdates;
  final VoidCallback onShowChangelog;
  final VoidCallback onExportJson;
  final VoidCallback onImportJson;
  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: sectionKey,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Logo & Version Badge
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE84D8A), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE84D8A).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.brightness_3_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Lunaris',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v$appDisplayVersion (build $appBuildNumber)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isRu
                ? 'Быстрый и красивый Booru & Anime клиент'
                : 'Modern, fast & customizable booru client',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onCheckUpdates,
                icon: const Icon(Icons.system_update_alt_rounded, size: 18),
                label: Text(
                  isRu ? 'Проверить обновления' : 'Check for updates',
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onShowChangelog,
                icon: const Icon(Icons.new_releases_rounded, size: 18),
                label: Text(isRu ? 'Что нового' : 'Changelog'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                    'https://gitea.rardogsynapse.online/RarDog/Lunaris',
                  );
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.code_rounded, size: 18),
                label: const Text('Gitea'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Backup & JSON controls
          Text(
            isRu ? 'Резервное копирование и экспорт' : 'Backup & JSON Export',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onExportBackup,
                icon: const Icon(Icons.file_upload_rounded, size: 18),
                label: Text(isRu ? 'Экспорт бэкапа' : 'Export backup'),
              ),
              OutlinedButton.icon(
                onPressed: onImportBackup,
                icon: const Icon(Icons.file_download_rounded, size: 18),
                label: Text(isRu ? 'Импорт бэкапа' : 'Import backup'),
              ),
              OutlinedButton.icon(
                onPressed: onExportJson,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('JSON Export'),
              ),
              OutlinedButton.icon(
                onPressed: onImportJson,
                icon: const Icon(Icons.download_for_offline_rounded, size: 18),
                label: const Text('JSON Import'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
