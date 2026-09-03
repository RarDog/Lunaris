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

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tabIndex = 0;
  String? _selectedArtist;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final posts = state.value?.posts ?? const <Post>[];
    final downloaded = ref
            .watch(downloadedMediaByKeysProvider(
              posts.map((post) => post.cacheKey).toList(growable: false),
            ))
            .value ??
        const <String, DownloadedMedia>{};
    return AdaptiveScaffold(
      title: settings.languageCode == 'ru' ? 'Избранное' : 'Favorites',
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (data) => data.posts.isEmpty
            ? const EmptyView(title: 'No favorites yet')
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          icon: Icon(Icons.favorite_rounded),
                          label: Text('All'),
                        ),
                        ButtonSegment(
                          value: 1,
                          icon: Icon(Icons.offline_pin_rounded),
                          label: Text('Offline'),
                        ),
                        ButtonSegment(
                          value: 2,
                          icon: Icon(Icons.groups_rounded),
                          label: Text('Artists'),
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
                  Expanded(
                    child: switch (_tabIndex) {
                      1 => _postsGrid(
                          data.posts
                              .where((post) =>
                                  downloaded.containsKey(post.cacheKey))
                              .toList(),
                          settings,
                          downloaded.keys.toSet(),
                        ),
                      2 => _artistAlbums(
                          data.posts,
                          settings,
                          downloaded.keys.toSet(),
                        ),
                      _ => _postsGrid(
                          data.posts,
                          settings,
                          downloaded.keys.toSet(),
                        ),
                    },
                  ),
                ],
              ),
      ),
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
        extra: post,
      ),
      onFavorite: (post) =>
          ref.read(favoritesControllerProvider.notifier).remove(post),
    );
  }

  Widget _artistAlbums(
    List<Post> posts,
    AppSettings settings,
    Set<String> downloadedKeys,
  ) {
    final groups = favoriteArtistAlbums(posts);
    final selected = _selectedArtist;
    if (selected != null) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _selectedArtist = null),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(selected),
            ),
          ),
          Expanded(
            child: _postsGrid(
              groups[selected] ?? const [],
              settings,
              downloadedKeys,
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        for (final entry in groups.entries)
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_rounded),
              title: Text(entry.key),
              subtitle: Text('${entry.value.length} posts'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => setState(() => _selectedArtist = entry.key),
            ),
          ),
      ],
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
