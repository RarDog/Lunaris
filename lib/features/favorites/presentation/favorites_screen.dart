import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import 'favorites_controller.dart';

enum FavoriteMediaType { all, video, image }

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tabIndex = 0;
  String? _selectedArtist;
  FavoriteMediaType _mediaFilter = FavoriteMediaType.all;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isVideoPost(Post post) {
    final type = post.fileType.toLowerCase();
    final url = post.fileUrl.toLowerCase();
    return type == 'mp4' ||
        type == 'webm' ||
        url.endsWith('.mp4') ||
        url.endsWith('.webm');
  }

  List<Post> _applyFilters(List<Post> posts) {
    var result = posts;
    if (_mediaFilter == FavoriteMediaType.video) {
      result = result.where(_isVideoPost).toList();
    } else if (_mediaFilter == FavoriteMediaType.image) {
      result = result.where((p) => !_isVideoPost(p)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((post) {
        return post.tags.any((t) => t.toLowerCase().contains(query)) ||
            post.providerName.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final isRu = settings.languageCode == 'ru';
    final allPosts = state.value?.posts ?? const <Post>[];
    final downloaded = ref
            .watch(downloadedMediaByKeysProvider(
              allPosts.map((post) => post.cacheKey).toList(growable: false),
            ))
            .value ??
        const <String, DownloadedMedia>{};

    final offlinePosts = allPosts
        .where((post) => downloaded.containsKey(post.cacheKey))
        .toList();
    final artistGroups = favoriteArtistAlbums(allPosts);

    return AdaptiveScaffold(
      title: isRu ? 'Избранное' : 'Favorites',
      actions: [
        IconButton(
          tooltip: _isSearching
              ? (isRu ? 'Закрыть поиск' : 'Close search')
              : (isRu ? 'Поиск в избранном' : 'Search favorites'),
          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (data) {
          if (data.posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRu ? 'В избранном пока пусто' : 'No favorites yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRu
                          ? 'Нажимайте ❤️ на постах в ленте, чтобы сохранить их'
                          : 'Tap ❤️ on posts in the feed to save them here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/feed'),
                      icon: const Icon(Icons.explore_rounded),
                      label: Text(isRu ? 'Перейти в ленту' : 'Explore Feed'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Search input bar if active
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: isRu
                          ? 'Поиск по тегам и авторам...'
                          : 'Search by tags and artists...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),

              // Navigation Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 0,
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        label: Text(
                          '${isRu ? 'Все' : 'All'} (${allPosts.length})',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: const Icon(Icons.offline_pin_rounded, size: 18),
                        label: Text(
                          '${isRu ? 'Офлайн' : 'Offline'} (${offlinePosts.length})',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ButtonSegment(
                        value: 2,
                        icon: const Icon(Icons.groups_rounded, size: 18),
                        label: Text(
                          '${isRu ? 'Авторы' : 'Artists'} (${artistGroups.length})',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    selected: {_tabIndex},
                    onSelectionChanged: (value) {
                      setState(() {
                        _tabIndex = value.first;
                        _selectedArtist = null;
                      });
                    },
                  ),
                ),
              ),

              // Media Type Filter Chips (for Tab 0 and Tab 1)
              if (_tabIndex != 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(isRu ? 'Все' : 'All'),
                        selected: _mediaFilter == FavoriteMediaType.all,
                        onSelected: (_) => setState(
                          () => _mediaFilter = FavoriteMediaType.all,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Icon(Icons.videocam_rounded, size: 16),
                        label: Text(isRu ? 'Видео' : 'Videos'),
                        selected: _mediaFilter == FavoriteMediaType.video,
                        onSelected: (_) => setState(
                          () => _mediaFilter = FavoriteMediaType.video,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Icon(Icons.image_rounded, size: 16),
                        label: Text(isRu ? 'Фото' : 'Images'),
                        selected: _mediaFilter == FavoriteMediaType.image,
                        onSelected: (_) => setState(
                          () => _mediaFilter = FavoriteMediaType.image,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // Main Content
              Expanded(
                child: switch (_tabIndex) {
                  1 => _buildOfflineView(
                      offlinePosts,
                      settings,
                      downloaded.keys.toSet(),
                      isRu,
                    ),
                  2 => _buildArtistsView(
                      allPosts,
                      settings,
                      downloaded.keys.toSet(),
                      isRu,
                    ),
                  _ => _buildAllView(
                      allPosts,
                      settings,
                      downloaded.keys.toSet(),
                      isRu,
                    ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllView(
    List<Post> posts,
    AppSettings settings,
    Set<String> downloadedKeys,
    bool isRu,
  ) {
    final filtered = _applyFilters(posts);
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              isRu ? 'Ничего не найдено' : 'No matching posts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _mediaFilter = FavoriteMediaType.all;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: Text(isRu ? 'Сбросить фильтры' : 'Reset filters'),
            ),
          ],
        ),
      );
    }
    return _postsGrid(filtered, settings, downloadedKeys);
  }

  Widget _buildOfflineView(
    List<Post> posts,
    AppSettings settings,
    Set<String> downloadedKeys,
    bool isRu,
  ) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRu ? 'Нет офлайн постов' : 'No offline posts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isRu
                    ? 'Загружайте понравившиеся работы для просмотра без подключения к сети'
                    : 'Download posts to view them anytime without an internet connection',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    final filtered = _applyFilters(posts);
    if (filtered.isEmpty) {
      return Center(
        child: Text(isRu ? 'Ничего не найдено' : 'No matching offline posts'),
      );
    }
    return _postsGrid(filtered, settings, downloadedKeys);
  }

  Widget _buildArtistsView(
    List<Post> posts,
    AppSettings settings,
    Set<String> downloadedKeys,
    bool isRu,
  ) {
    final groups = favoriteArtistAlbums(posts);
    final selected = _selectedArtist;

    if (selected != null) {
      final artistPosts = groups[selected] ?? const [];
      final filtered = _applyFilters(artistPosts);

      return Column(
        children: [
          // Artist Header Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedArtist = null),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: isRu ? 'Все авторы' : 'All artists',
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    selected.isNotEmpty ? selected[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${artistPosts.length} ${isRu ? 'работ' : 'posts'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    context.push('/search?q=${Uri.encodeComponent('artist:$selected')}');
                  },
                  icon: const Icon(Icons.search_rounded, size: 16),
                  label: Text(isRu ? 'В сети' : 'Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(isRu ? 'Ничего не найдено' : 'No posts found'),
                  )
                : _postsGrid(filtered, settings, downloadedKeys),
          ),
        ],
      );
    }

    final query = _searchQuery.toLowerCase();
    final entries = groups.entries.where((e) {
      if (query.isEmpty) return true;
      return e.key.toLowerCase().contains(query);
    }).toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(isRu ? 'Авторы не найдены' : 'No artists found'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final artistPosts = entry.value;
        final previewUrls = artistPosts
            .map((p) => MediaUrlSelector.preview(p).firstOrNull)
            .whereType<String>()
            .take(3)
            .toList();

        return _ArtistCard(
          artistName: entry.key,
          postsCount: artistPosts.length,
          previewUrls: previewUrls,
          isRu: isRu,
          onTap: () => setState(() => _selectedArtist = entry.key),
        );
      },
    );
  }

  Widget _postsGrid(
    List<Post> posts,
    AppSettings settings,
    Set<String> downloadedKeys,
  ) {
    if (posts.isEmpty) return const EmptyView(title: 'Nothing here yet');
    return PostMasonryGrid(
      posts: posts,
      columns: Responsive.columnsFor(
        context,
        mobileColumns: settings.mobileColumns,
        desktopColumns: settings.desktopColumns,
      ),
      blurExplicit: settings.blurExplicitContent,
      showBadges: settings.showPostBadges,
      nsfwEnabled: settings.nsfwEnabled,
      mediaQualityMode: MediaQualityMode.fromName(settings.mediaQualityMode),
      favoriteKeys: posts.map((post) => post.cacheKey).toSet(),
      downloadedKeys: downloadedKeys,
      onOpen: (post) => context.push(
        '/post/${post.providerId}/${post.id}',
        extra: PostNavigationContext(
          currentPost: post,
          posts: posts,
        ),
      ),
      onFavorite: (post) =>
          ref.read(favoritesControllerProvider.notifier).remove(post),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({
    required this.artistName,
    required this.postsCount,
    required this.previewUrls,
    required this.isRu,
    required this.onTap,
  });

  final String artistName;
  final int postsCount;
  final List<String> previewUrls;
  final bool isRu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Artist Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primaryContainer,
                      scheme.tertiaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    artistName.isNotEmpty ? artistName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Artist Name & Count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$postsCount ${isRu ? 'работ' : 'posts'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // Thumbnails preview
              if (previewUrls.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    for (final url in previewUrls)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: scheme.surfaceContainerHighest,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: scheme.surfaceContainerHighest,
                                child: const Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, List<Post>> favoriteArtistAlbums(List<Post> posts) {
  final groups = <String, List<Post>>{};
  for (final post in posts) {
    final artists = post.tagGroups['artist'] ??
        post.tags.where((tag) => tag.startsWith('artist:')).toList();
    final names = artists.isEmpty
        ? const ['Unknown artist']
        : artists.map((tag) => tag.replaceFirst('artist:', '')).toList();
    for (final name in names) {
      groups.putIfAbsent(name, () => []).add(post);
    }
  }
  return Map.fromEntries(
    groups.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
  );
}
