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
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../favorites/presentation/favorites_controller.dart';

final artistPostsProvider =
    FutureProvider.family<List<Post>, ArtistWorkQuery>((ref, query) async {
  final providers =
      await ref.watch(providerManagerProvider).activeArtistProviders();
  if (providers is! Success<List<ArtistProvider>>) return const [];
  final provider = providers.data.firstWhere(
    (item) => (item as ContentProvider).id == query.providerId,
  );
  final posts = await provider.getArtistPosts(query: query, page: 0, limit: 50);
  await ref.read(cacheServiceProvider).cachePosts(posts);
  return posts;
});

class ArtistPostsScreen extends ConsumerStatefulWidget {
  const ArtistPostsScreen({
    required this.providerId,
    required this.service,
    required this.artistId,
    required this.artistName,
    super.key,
  });

  final String providerId;
  final String service;
  final String artistId;
  final String artistName;

  @override
  ConsumerState<ArtistPostsScreen> createState() => _ArtistPostsScreenState();
}

class _ArtistPostsScreenState extends ConsumerState<ArtistPostsScreen> {
  final _scrollController = ScrollController();
  final List<Post> _posts = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 600) {
        _loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final query = ArtistWorkQuery(
      providerId: widget.providerId,
      service: widget.service,
      artistId: widget.artistId,
      artistName: widget.artistName,
    );

    try {
      final providers =
          await ref.read(providerManagerProvider).activeArtistProviders();
      if (providers is! Success<List<ArtistProvider>>) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Could not load artist providers';
        });
        return;
      }
      final provider = providers.data.firstWhere(
        (item) => (item as ContentProvider).id == query.providerId,
      );
      final newPosts = await provider.getArtistPosts(
        query: query,
        page: _page,
        limit: 50,
      );
      await ref.read(cacheServiceProvider).cachePosts(newPosts);

      if (!mounted) return;
      setState(() {
        _loading = false;
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          final existingKeys = _posts.map((p) => p.cacheKey).toSet();
          final uniqueNew =
              newPosts.where((p) => !existingKeys.contains(p.cacheKey)).toList();
          _posts.addAll(uniqueNew);
          _page++;
          if (newPosts.length < 10) {
            _hasMore = false;
          }
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    final viewedKeys = ref.watch(viewedKeysProvider).value ?? <String>{};

    return AdaptiveScaffold(
      title: widget.artistName,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: _posts.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty && _error != null
              ? ErrorView(
                  message: _friendlyArtistPostError(_error!),
                  onRetry: _refresh,
                )
              : _posts.isEmpty
                  ? const EmptyView(
                      title: 'No works',
                      message: 'This artist has no visible media yet.',
                    )
                  : PostMasonryGrid(
                      posts: _posts,
                      controller: _scrollController,
                      loading: _loading,
                      columns: Responsive.columnsFor(
                        context,
                        mobileColumns: settings.mobileColumns,
                        desktopColumns: settings.desktopColumns,
                      ),
                      blurExplicit: settings.blurExplicitContent,
                      showBadges: settings.showPostBadges,
                      nsfwEnabled: settings.nsfwEnabled,
                      mediaQualityMode:
                          MediaQualityMode.fromName(settings.mediaQualityMode),
                      favoriteKeys: favoriteKeys,
                      viewedKeys: viewedKeys,
                      onOpen: (post) => context.push(
                        '/post/${post.providerId}/${post.id}',
                        extra: PostNavigationContext(
                          currentPost: post,
                          posts: _posts,
                        ),
                      ),
                      onFavorite: (post) async {
                        if (favoriteKeys.contains(post.cacheKey)) {
                          await ref
                              .read(favoriteServiceProvider)
                              .removeFavorite(post.id, post.providerId);
                        } else {
                          await ref.read(favoriteServiceProvider).addFavorite(
                                post,
                                settings: settings,
                                downloadManager:
                                    ref.read(downloadManagerServiceProvider),
                              );
                        }
                        ref.invalidate(favoriteKeysProvider);
                        ref.invalidate(favoritesControllerProvider);
                      },
                    ),
    );
  }

  String _friendlyArtistPostError(Object error) {
    final message = error.toString();
    if (message.contains('HandshakeException') ||
        message.contains('artist works are unavailable')) {
      return 'Artist works are unavailable from this provider right now. Try again later or choose another artist/provider.';
    }
    return message;
  }
}
