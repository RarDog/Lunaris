import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/app_navigator.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../settings/presentation/settings_controller.dart';
import 'artist_posts_screen.dart';
import 'widgets/pawchive_accounts_sheet.dart';

final artistProviderConfigsProvider =
    FutureProvider<List<ContentProviderConfig>>((ref) async {
  final result = await ref
      .watch(providerManagerProvider)
      .loadArtistConfigs(enabledOnly: true);
  return result is Success<List<ContentProviderConfig>>
      ? result.data
      : const [];
});

class ArtistsScreen extends ConsumerStatefulWidget {
  const ArtistsScreen({super.key});

  @override
  ConsumerState<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends ConsumerState<ArtistsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final Set<String> _selectedServices = <String>{};
  String? _providerId;
  var _page = 1;
  var _loading = false;
  var _hasMore = true;
  Object? _error;
  List<ArtistProfile> _artists = const [];

  String? _selectedFavoriteArtistKey;

  Future<void> _toggleFavoriteArtist(
    AppSettings settings,
    ArtistProfile artist,
  ) async {
    final current = List<String>.from(settings.favoriteArtists);
    final item = FavoriteArtistItem(
      id: artist.id,
      service: artist.service,
      providerId: artist.providerId,
      name: artist.displayName,
      avatarUrl: artist.avatarUrl,
    );
    final key = item.key;
    final index = current.indexWhere((e) {
      try {
        final parsed =
            FavoriteArtistItem.fromJson(jsonDecode(e) as Map<String, dynamic>);
        return parsed.key == key;
      } catch (_) {
        return false;
      }
    });
    final isAdding = index < 0;
    if (!isAdding) {
      current.removeAt(index);
    } else {
      current.insert(0, jsonEncode(item.toJson()));
    }
    await ref.read(settingsControllerProvider.notifier).saveSettings(
          settings.copyWith(favoriteArtists: current),
        );

    // Sync with active Pawchive account if available
    if (artist.service.isNotEmpty && artist.id.isNotEmpty) {
      final activeAcc = settings.activePawchiveAccount;
      if (activeAcc != null) {
        unawaited(ref.read(pawchiveSyncServiceProvider).toggleRemoteFavorite(
              account: activeAcc,
              service: artist.service,
              artistId: artist.id,
              isFavorite: isAdding,
            ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.hasContentDimensions &&
          _scroll.position.extentAfter < 500) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(artistProviderConfigsProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteItems = settings.favoriteArtists
        .map((e) {
          try {
            return FavoriteArtistItem.fromJson(
                jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<FavoriteArtistItem>()
        .toList();
    final favoriteKeys = favoriteItems.map((e) => e.key).toSet();

    return AdaptiveScaffold(
      title: 'Artists',
      resizeToAvoidBottomInset: false,
      actions: [
        IconButton(
          tooltip: 'Синхронизация Pawchive',
          icon: Badge(
            isLabelVisible: settings.parsedPawchiveAccounts.isNotEmpty,
            backgroundColor: Colors.green,
            smallSize: 8,
            child: const Icon(Icons.cloud_sync_rounded),
          ),
          onPressed: () => PawchiveAccountsSheet.show(context),
        ),
        IconButton(
          tooltip: 'Любимые авторы',
          icon: Badge(
            isLabelVisible: favoriteItems.isNotEmpty,
            label: Text('${favoriteItems.length}'),
            child: const Icon(Icons.star_rounded, color: Colors.amber),
          ),
          onPressed: () => _showFavoriteArtistsModal(
            context,
            settings,
            favoriteItems,
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _refresh(configs.valueOrNull ?? const []),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: configs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              title: 'No artist providers',
              message: 'Enable an artist provider (such as Pawchive) in Providers.',
            );
          }
          _providerId ??= items.first.id;
          if (_artists.isEmpty && !_loading && _error == null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _refresh(items));
          }
          final displayedArtists = _selectedServices.isEmpty
              ? _artists
              : _artists
                  .where((a) =>
                      _selectedServices.contains(a.service.toLowerCase()))
                  .toList(growable: false);

          return Column(
            children: [
              _ArtistsHeader(
                searchController: _search,
                providers: items,
                selectedProviderId: _providerId,
                selectedServices: _selectedServices,
                onProviderChanged: (value) {
                  setState(() => _providerId = value);
                  _refresh(items);
                },
                onToggleService: (service) {
                  setState(() {
                    if (_selectedServices.contains(service)) {
                      _selectedServices.remove(service);
                    } else {
                      _selectedServices.add(service);
                    }
                  });
                  _refresh(items);
                },
                onClearServices: () {
                  setState(() => _selectedServices.clear());
                  _refresh(items);
                },
                onSearch: () => _refresh(items),
              ),
              Expanded(
                child: _error != null
                    ? ErrorView(
                        message: _friendlyArtistError(_error),
                        onRetry: () => _refresh(items),
                      )
                    : displayedArtists.isEmpty && !_loading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_search_outlined,
                                      size: 48),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Нет авторов по выбранным фильтрам',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  FilledButton.tonal(
                                    onPressed: () {
                                      setState(
                                          () => _selectedServices.clear());
                                      _refresh(items);
                                    },
                                    child: const Text('Показать все сервисы'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = Responsive.isMobile(context)
                                  ? 1
                                  : constraints.maxWidth >= 1100
                                      ? 3
                                      : constraints.maxWidth >= 760
                                          ? 2
                                          : 1;
                              return GridView.builder(
                                controller: _scroll,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 18),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent:
                                      Responsive.isMobile(context) ? 116 : 124,
                                ),
                                itemCount:
                                    displayedArtists.length + (_loading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= displayedArtists.length) {
                                    return const _ArtistSkeletonCard();
                                  }
                                  final artist = displayedArtists[index];
                                  final isFav = favoriteKeys.contains(
                                      '${artist.providerId}:${artist.service}:${artist.id}');
                                  return _ArtistCard(
                                    artist: artist,
                                    isFavorite: isFav,
                                    onToggleFavorite: () =>
                                        _toggleFavoriteArtist(settings, artist),
                                    onTap: () => context.push(
                                      '/artists/${artist.providerId}/${artist.service}/${artist.id}?name=${Uri.encodeComponent(artist.displayName)}',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _friendlyArtistError(Object? error) {
    final message = error.toString();
    if (message.contains('HandshakeException') ||
        message.contains('artist works are unavailable')) {
      return 'Artist API is unavailable right now. Try refresh or another provider.';
    }
    return message;
  }

  Future<void> _refresh(List<ContentProviderConfig> configs) async {
    if (configs.isEmpty) return;
    setState(() {
      _page = 1;
      _hasMore = true;
      _artists = const [];
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _providerId == null) return;
    setState(() => _loading = true);
    try {
      final manager = ref.read(providerManagerProvider);
      final providers = await manager.activeArtistProviders();
      if (providers is! Success<List<ArtistProvider>>) return;
      final provider = providers.data.firstWhere(
        (item) => (item as ContentProvider).id == _providerId,
      );
      final next = await provider.searchArtists(
        _search.text.trim(),
        services: _selectedServices.isEmpty ? null : _selectedServices.toList(),
        page: _page,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _artists = [..._artists, ...next];
        _page++;
        _hasMore = next.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showFavoriteArtistsModal(
    BuildContext context,
    AppSettings settings,
    List<FavoriteArtistItem> favorites,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return _FavoriteArtistsModal(
          favorites: favorites,
          initialSelectedKey: _selectedFavoriteArtistKey,
          onSelect: (fav) =>
              setState(() => _selectedFavoriteArtistKey = fav.key),
          onOpenArtist: (fav) => context.push(
            '/artists/${fav.providerId}/${fav.service}/${fav.id}?name=${Uri.encodeComponent(fav.name)}',
          ),
          onRemoveFavorite: (fav) async {
            final updated = List<String>.from(settings.favoriteArtists)
              ..removeWhere((e) {
                try {
                  return FavoriteArtistItem.fromJson(
                              jsonDecode(e) as Map<String, dynamic>)
                          .key ==
                      fav.key;
                } catch (_) {
                  return false;
                }
              });
            await ref
                .read(settingsControllerProvider.notifier)
                .saveSettings(settings.copyWith(favoriteArtists: updated));

            if (fav.providerId == 'pawchive') {
              final activeAcc = settings.activePawchiveAccount;
              if (activeAcc != null) {
                unawaited(ref.read(pawchiveSyncServiceProvider).toggleRemoteFavorite(
                      account: activeAcc,
                      service: fav.service,
                      artistId: fav.id,
                      isFavorite: false,
                    ));
              }
            }
            setState(() {});
          },
        );
      },
    );
  }
}

Color _serviceColor(String service) {
  switch (service.toLowerCase()) {
    case 'patreon':
      return const Color(0xFFFF424D);
    case 'fanbox':
      return const Color(0xFF0096FA);
    case 'fantia':
      return const Color(0xFFFF2E74);
    case 'boosty':
      return const Color(0xFFF15F2C);
    case 'discord':
      return const Color(0xFF5865F2);
    case 'subscribestar':
      return const Color(0xFF009688);
    case 'gumroad':
      return const Color(0xFFFF90E8);
    case 'afdian':
      return const Color(0xFF946CE6);
    default:
      return const Color(0xFF7C4DFF);
  }
}

String _formatServiceName(String s) {
  switch (s.toLowerCase()) {
    case 'patreon':
      return 'Patreon';
    case 'fanbox':
      return 'Pixiv Fanbox';
    case 'fantia':
      return 'Fantia';
    case 'boosty':
      return 'Boosty';
    case 'discord':
      return 'Discord';
    default:
      return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

class _ArtistsLiquidCard extends StatelessWidget {
  const _ArtistsLiquidCard({
    required this.child,
    this.padding,
    this.glowColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = glowColor ?? theme.colorScheme.primary;
    final r = BorderRadius.circular(22);

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.62),
                  theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.40),
                ]
              : [
                  Colors.white.withValues(alpha: 0.88),
                  Colors.white.withValues(alpha: 0.72),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.85),
          width: 1.2,
        ),
      ),
      child: child,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.32)
                : accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: r,
                    onTap: onTap,
                    child: cardContent,
                  ),
                )
              : cardContent,
        ),
      ),
    );
  }
}

class _ArtistsHeader extends StatelessWidget {
  const _ArtistsHeader({
    required this.searchController,
    required this.providers,
    required this.selectedProviderId,
    required this.selectedServices,
    required this.onProviderChanged,
    required this.onToggleService,
    required this.onClearServices,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final List<ContentProviderConfig> providers;
  final String? selectedProviderId;
  final Set<String> selectedServices;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<String> onToggleService;
  final VoidCallback onClearServices;
  final VoidCallback onSearch;

  static const _availableServices = [
    'patreon',
    'fanbox',
    'fantia',
    'boosty',
    'discord',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: _ArtistsLiquidCard(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glass search bar (completely transparent inside, no unwanted background tint)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      autocorrect: false,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Поиск авторов...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Очистить',
                        onPressed: () {
                          searchController.clear();
                          onSearch();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: onSearch,
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Найти',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF334155),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Unified single-row filter bar: providers + separator + platforms
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Providers
                  for (final provider in providers) ...[
                    Builder(
                      builder: (context) {
                        final isSelected = provider.id == selectedProviderId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onProviderChanged(provider.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.20)
                                      : const Color(0xFF0F172A))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white.withValues(alpha: 0.40)
                                        : const Color(0xFF0F172A))
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06)),
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.dns_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : const Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  provider.name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Vertical divider between provider and platforms
                  if (providers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Container(
                        width: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                  const SizedBox(width: 6),
                  // "All platforms" chip
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onClearServices,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selectedServices.isEmpty
                            ? (isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : const Color(0xFF0F172A))
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedServices.isEmpty
                              ? (isDark
                                  ? Colors.white.withValues(alpha: 0.40)
                                  : const Color(0xFF0F172A))
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06)),
                          width: 1.1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Все платформы',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: selectedServices.isEmpty
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selectedServices.isEmpty
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Platform chips
                  for (final service in _availableServices) ...[
                    Builder(
                      builder: (context) {
                        final sColor = _serviceColor(service);
                        final isSelected = selectedServices.contains(service);
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onToggleService(service),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? sColor.withValues(
                                      alpha: isDark ? 0.26 : 0.14)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.035)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? sColor.withValues(alpha: 0.75)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black
                                            .withValues(alpha: 0.06)),
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: sColor,
                                    shape: BoxShape.circle,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: sColor.withValues(
                                                  alpha: 0.6),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _formatServiceName(service),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? sColor
                                        : (isDark
                                            ? Colors.white70
                                            : const Color(0xFF334155)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({
    required this.artist,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final ArtistProfile artist;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final sColor = _serviceColor(artist.service);

    return _ArtistsLiquidCard(
      glowColor: sColor.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          _ArtistAvatar(artist: artist, glowColor: sColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _LiquidMiniBadge(
                      label: artist.service.isEmpty ? 'Artist' : artist.service,
                      color: sColor,
                      hasDot: true,
                    ),
                    if (artist.postCount != null)
                      _LiquidMiniBadge(
                        label: '${artist.postCount} постов',
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                  ],
                ),
                if (artist.updatedAt != null) ...[
                  const SizedBox(height: 5),
                  Builder(
                    builder: (_) {
                      final dt = artist.updatedAt!.toLocal();
                      final d = dt.day.toString().padLeft(2, '0');
                      final m = dt.month.toString().padLeft(2, '0');
                      final y = dt.year;
                      final hr = dt.hour.toString().padLeft(2, '0');
                      final min = dt.minute.toString().padLeft(2, '0');
                      return Text(
                        'Обновлено: $d.$m.$y $hr:$min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Interactive Favorite button with gold glow
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggleFavorite,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.amber.withValues(alpha: isDark ? 0.22 : 0.15)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFavorite
                        ? Colors.amber.withValues(alpha: 0.6)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06)),
                  ),
                  boxShadow: isFavorite
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavorite ? Colors.amber : scheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _FavoriteArtistsModal extends StatefulWidget {
  const _FavoriteArtistsModal({
    required this.favorites,
    required this.initialSelectedKey,
    required this.onSelect,
    required this.onOpenArtist,
    required this.onRemoveFavorite,
  });

  final List<FavoriteArtistItem> favorites;
  final String? initialSelectedKey;
  final ValueChanged<FavoriteArtistItem> onSelect;
  final ValueChanged<FavoriteArtistItem> onOpenArtist;
  final ValueChanged<FavoriteArtistItem> onRemoveFavorite;

  @override
  State<_FavoriteArtistsModal> createState() => _FavoriteArtistsModalState();
}

class _FavoriteArtistsModalState extends State<_FavoriteArtistsModal> {
  late String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.initialSelectedKey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final selectedFav = widget.favorites.firstWhere(
      (e) => e.key == _selectedKey,
      orElse: () => widget.favorites.isNotEmpty
          ? widget.favorites.first
          : const FavoriteArtistItem.empty(),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.favorites.isEmpty ? 0.35 : 0.68,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      scheme.surfaceContainerHigh.withValues(alpha: 0.92),
                      scheme.surfaceContainerLow.withValues(alpha: 0.84),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.88),
                    ],
            ),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white,
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SingleChildScrollView(
                controller: scroll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 26),
                          const SizedBox(width: 8),
                          Text(
                            'Любимые авторы',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.favorites.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.favorites.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Consumer(
                      builder: (context, ref, _) {
                        final settings = ref.watch(appSettingsProvider).value ??
                            AppSettings.defaults;
                        final activeAcc = settings.activePawchiveAccount;
                        final accounts = settings.parsedPawchiveAccounts;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: _ArtistsLiquidCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            glowColor: activeAcc != null ? scheme.primary : null,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_sync_rounded,
                                  size: 22,
                                  color: activeAcc != null
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        activeAcc != null
                                            ? 'Pawchive: @${activeAcc.username}'
                                            : 'Pawchive не подключён',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        activeAcc != null
                                            ? '${activeAcc.syncedArtistsCount} авторов в облаке'
                                            : 'Синхронизируйте избранное с сервером',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () =>
                                      PawchiveAccountsSheet.show(context),
                                  child: Text(
                                      accounts.isEmpty ? 'Войти' : 'Аккаунты'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.favorites.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_border_rounded,
                                size: 52,
                                color: scheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Список пуст',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Нажмите на иконку звёздочки ★ на карточке любого автора, чтобы добавить его в избранное и быстро смотреть свежие работы.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      _FavoriteArtistsSection(
                        favorites: widget.favorites,
                        selectedKey: selectedFav.isEmpty ? null : selectedFav.key,
                        onSelect: (fav) {
                          setState(() => _selectedKey = fav.key);
                          widget.onSelect(fav);
                        },
                        onOpenArtist: (fav) {
                          Navigator.of(context).pop();
                          widget.onOpenArtist(fav);
                        },
                        onRemoveFavorite: (fav) {
                          widget.onRemoveFavorite(fav);
                          if (_selectedKey == fav.key) {
                            setState(() {
                              _selectedKey = widget.favorites
                                  .where((e) => e.key != fav.key)
                                  .firstOrNull
                                  ?.key;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteArtistsSection extends ConsumerWidget {
  const _FavoriteArtistsSection({
    required this.favorites,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenArtist,
    required this.onRemoveFavorite,
  });

  final List<FavoriteArtistItem> favorites;
  final String? selectedKey;
  final ValueChanged<FavoriteArtistItem> onSelect;
  final ValueChanged<FavoriteArtistItem> onOpenArtist;
  final ValueChanged<FavoriteArtistItem> onRemoveFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: _ArtistsLiquidCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Нажмите звёздочку ★ на карточке автора, чтобы добавить его в любимые.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selected = favorites.firstWhere(
      (f) => f.key == selectedKey,
      orElse: () => favorites.first,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: _ArtistsLiquidCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Любимые авторы (${favorites.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => onOpenArtist(selected),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Все работы', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 88,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final fav = favorites[index];
                  final isSelected = fav.key == selected.key;
                  final sColor = _serviceColor(fav.service);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelect(fav),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.45)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : sColor.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: fav.avatarUrl != null &&
                                      fav.avatarUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: fav.avatarUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Icon(
                                          Icons.person_rounded,
                                          size: 20),
                                      errorWidget: (_, __, ___) => const Icon(
                                          Icons.person_rounded,
                                          size: 20),
                                    )
                                  : Center(
                                      child: Text(
                                        fav.name.isNotEmpty
                                            ? fav.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 68,
                            child: Text(
                              fav.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            _FavoriteArtistMediaStrip(artist: selected),
          ],
        ),
      ),
    );
  }
}

class _FavoriteArtistMediaStrip extends ConsumerWidget {
  const _FavoriteArtistMediaStrip({required this.artist});

  final FavoriteArtistItem artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ArtistWorkQuery(
      providerId: artist.providerId,
      service: artist.service,
      artistId: artist.id,
      artistName: artist.name,
    );
    final asyncPosts = ref.watch(artistPostsProvider(query));

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: asyncPosts.when(
        loading: () => const SizedBox(
          height: 90,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (posts) {
          if (posts.isEmpty) {
            return const SizedBox(
              height: 36,
              child: Center(
                child: Text('Нет доступных фото или видео',
                    style: TextStyle(fontSize: 12)),
              ),
            );
          }
          return SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: posts.length.clamp(0, 15),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final post = posts[index];
                final isVideo = MediaUrlSelector.isVideo(post);
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => AppNavigator.openPost(
                    context,
                    post: post,
                    postsList: posts,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: CachedNetworkImage(
                              imageUrl: post.previewUrl.isNotEmpty
                                  ? post.previewUrl
                                  : post.sampleUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.broken_image_rounded,
                                    size: 24),
                              ),
                            ),
                          ),
                          if (isVideo)
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 14),
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
        },
      ),
    );
  }
}

class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({
    required this.artist,
    this.glowColor,
  });

  final ArtistProfile artist;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = artist.displayName.trim();
    final initials = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final accent = glowColor ?? theme.colorScheme.primary;

    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.85),
            theme.colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.90),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: artist.avatarUrl == null || artist.avatarUrl!.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: artist.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _LiquidMiniBadge extends StatelessWidget {
  const _LiquidMiniBadge({
    required this.label,
    required this.color,
    this.hasDot = false,
  });

  final String label;
  final Color color;
  final bool hasDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayLabel =
        label.isEmpty ? '' : label[0].toUpperCase() + label.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistSkeletonCard extends StatelessWidget {
  const _ArtistSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _ArtistsLiquidCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

