import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../settings/presentation/settings_controller.dart';
import 'artist_posts_screen.dart';

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
    final item = _FavoriteArtistItem(
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
            _FavoriteArtistItem.fromJson(jsonDecode(e) as Map<String, dynamic>);
        return parsed.key == key;
      } catch (_) {
        return false;
      }
    });
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, jsonEncode(item.toJson()));
    }
    await ref.read(settingsControllerProvider.notifier).saveSettings(
          settings.copyWith(favoriteArtists: current),
        );
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 500) _loadMore();
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
            return _FavoriteArtistItem.fromJson(
                jsonDecode(e) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<_FavoriteArtistItem>()
        .toList();
    final favoriteKeys = favoriteItems.map((e) => e.key).toSet();
    final selectedFav = favoriteItems.firstWhere(
      (e) => e.key == _selectedFavoriteArtistKey,
      orElse: () => favoriteItems.isNotEmpty
          ? favoriteItems.first
          : const _FavoriteArtistItem.empty(),
    );

    return AdaptiveScaffold(
      title: 'Artists',
      actions: [
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
          return Column(
            children: [
              _ArtistsHeader(
                searchController: _search,
                providers: items,
                selectedProviderId: _providerId,
                onProviderChanged: (value) {
                  setState(() => _providerId = value);
                  _refresh(items);
                },
                onSearch: () => _refresh(items),
              ),
              _FavoriteArtistsSection(
                favorites: favoriteItems,
                selectedKey: selectedFav.isEmpty ? null : selectedFav.key,
                onSelect: (fav) =>
                    setState(() => _selectedFavoriteArtistKey = fav.key),
                onOpenArtist: (fav) => context.push(
                  '/artists/${fav.providerId}/${fav.service}/${fav.id}?name=${Uri.encodeComponent(fav.name)}',
                ),
                onRemoveFavorite: (fav) async {
                  final updated = List<String>.from(settings.favoriteArtists)
                    ..removeWhere((e) {
                      try {
                        return _FavoriteArtistItem.fromJson(
                                    jsonDecode(e) as Map<String, dynamic>)
                                .key ==
                            fav.key;
                      } catch (_) {
                        return false;
                      }
                    });
                  await ref
                      .read(settingsControllerProvider.notifier)
                      .saveSettings(
                          settings.copyWith(favoriteArtists: updated));
                },
              ),
              Expanded(
                child: _error != null
                    ? ErrorView(
                        message: _friendlyArtistError(_error),
                        onRetry: () => _refresh(items),
                      )
                    : _artists.isEmpty && !_loading
                        ? const EmptyView(
                            title: 'No artists',
                            message: 'Try another name or provider.',
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
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 18),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent:
                                      Responsive.isMobile(context) ? 88 : 104,
                                ),
                                itemCount: _artists.length + (_loading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _artists.length) {
                                    return const _ArtistSkeletonCard();
                                  }
                                  final artist = _artists[index];
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
}

class _ArtistsHeader extends StatelessWidget {
  const _ArtistsHeader({
    required this.searchController,
    required this.providers,
    required this.selectedProviderId,
    required this.onProviderChanged,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final List<ContentProviderConfig> providers;
  final String? selectedProviderId;
  final ValueChanged<String?> onProviderChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search artists',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Search',
                    onPressed: onSearch,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ChoiceChip(
                      selected: provider.id == selectedProviderId,
                      avatar: const Icon(Icons.person_search_rounded, size: 16),
                      label: Text(provider.name),
                      onSelected: (_) => onProviderChanged(provider.id),
                    );
                  },
                ),
              ),
            ],
          ),
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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ArtistAvatar(artist: artist),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MiniBadge(artist.service),
                        if (artist.postCount != null)
                          _MiniBadge('${artist.postCount} posts'),
                      ],
                    ),
                    if (artist.updatedAt != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Updated ${artist.updatedAt!.toLocal().toString().split('.').first}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: isFavorite ? 'В избранном' : 'В избранное',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavorite ? Colors.amber : scheme.onSurfaceVariant,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteArtistItem {
  const _FavoriteArtistItem({
    required this.id,
    required this.service,
    required this.providerId,
    required this.name,
    this.avatarUrl,
  });

  const _FavoriteArtistItem.empty()
      : id = '',
        service = '',
        providerId = '',
        name = '',
        avatarUrl = null;

  final String id;
  final String service;
  final String providerId;
  final String name;
  final String? avatarUrl;

  bool get isEmpty => id.isEmpty;
  String get key => '$providerId:$service:$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'providerId': providerId,
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory _FavoriteArtistItem.fromJson(Map<String, dynamic> json) =>
      _FavoriteArtistItem(
        id: (json['id'] ?? '').toString(),
        service: (json['service'] ?? '').toString(),
        providerId: (json['providerId'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class _FavoriteArtistsSection extends ConsumerWidget {
  const _FavoriteArtistsSection({
    required this.favorites,
    required this.selectedKey,
    required this.onSelect,
    required this.onOpenArtist,
    required this.onRemoveFavorite,
  });

  final List<_FavoriteArtistItem> favorites;
  final String? selectedKey;
  final ValueChanged<_FavoriteArtistItem> onSelect;
  final ValueChanged<_FavoriteArtistItem> onOpenArtist;
  final ValueChanged<_FavoriteArtistItem> onRemoveFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorites.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Нажмите звёздочку ★ на карточке автора, чтобы добавить его в любимые и смотреть его медиа здесь.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final selected = favorites.firstWhere(
      (f) => f.key == selectedKey,
      orElse: () => favorites.first,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
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
          ),
          SizedBox(
            height: 84,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final fav = favorites[index];
                final isSelected = fav.key == selected.key;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelect(fav),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ClipOval(
                            child: fav.avatarUrl != null &&
                                    fav.avatarUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: fav.avatarUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const CircleAvatar(
                                      child:
                                          Icon(Icons.person_rounded, size: 20),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        const CircleAvatar(
                                      child:
                                          Icon(Icons.person_rounded, size: 20),
                                    ),
                                  )
                                : CircleAvatar(
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
          _FavoriteArtistMediaStrip(artist: selected),
        ],
      ),
    );
  }
}

class _FavoriteArtistMediaStrip extends ConsumerWidget {
  const _FavoriteArtistMediaStrip({required this.artist});

  final _FavoriteArtistItem artist;

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
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
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
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(
                    '/post/${post.providerId}/${post.id}',
                    extra: PostNavigationContext(
                      currentPost: post,
                      posts: posts,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
  const _ArtistAvatar({required this.artist});

  final ArtistProfile artist;

  @override
  Widget build(BuildContext context) {
    final name = artist.displayName.trim();
    final initials = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipOval(
        child: artist.avatarUrl == null
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

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _ArtistSkeletonCard extends StatelessWidget {
  const _ArtistSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
