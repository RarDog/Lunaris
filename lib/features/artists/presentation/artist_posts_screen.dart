import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/formatted_content_text.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../settings/presentation/settings_controller.dart';

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
  final Set<String> _selectedTypes = <String>{};

  List<ArtistTag> _tags = [];
  List<ArtistAnnouncement> _announcements = [];
  String? _selectedTag;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMore();
      _loadMetadata();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    try {
      final providers =
          await ref.read(providerManagerProvider).activeArtistProviders();
      if (providers is! Success<List<ArtistProvider>>) return;
      final provider = providers.data.firstWhere(
        (item) => (item as ContentProvider).id == widget.providerId,
      );

      final tagsRes =
          await provider.getArtistTags(widget.service, widget.artistId);
      final annRes =
          await provider.getArtistAnnouncements(widget.service, widget.artistId);

      if (!mounted) return;
      setState(() {
        _tags = tagsRes;
        _announcements = annRes;
      });
    } catch (_) {}
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    await Future.wait([_loadMore(), _loadMetadata()]);
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
      tagFilter: _selectedTag,
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

  void _onTagSelected(String? tag) {
    if (_selectedTag == tag) return;
    setState(() {
      _selectedTag = tag;
      _posts.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    _loadMore();
  }

  bool _matchesTypeFilter(Post post) {
    if (_selectedTypes.isEmpty) return true;
    final isVid = MediaUrlSelector.isVideo(post);
    final isGif = MediaUrlSelector.isGif(post);
    final isPhoto = !isVid && !isGif;

    if (_selectedTypes.contains('video') && isVid) return true;
    if (_selectedTypes.contains('gif') && isGif) return true;
    if (_selectedTypes.contains('photo') && isPhoto) return true;
    return false;
  }

  void _showAnnouncements() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.campaign_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Анонсы автора (${_announcements.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _announcements.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final a = _announcements[index];
                  final cleanContent = CloudLinkExtractor.cleanCommentary(a.content);
                  final detectedCloudLinks = CloudLinkExtractor.extractLinks(content: a.content);
                  final creatorLinks = CreatorLink.extractLinks(a.content);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.added != null)
                        Text(
                          '${a.added!.year}-${a.added!.month.toString().padLeft(2, '0')}-${a.added!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 6),
                      FormattedContentText(
                        text: cleanContent.isNotEmpty ? cleanContent : a.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      if (creatorLinks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        CreatorLinkChips(
                          links: creatorLinks,
                          title: 'Ссылки автора',
                        ),
                      ],
                      if (detectedCloudLinks.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: detectedCloudLinks.map((link) {
                            return ActionChip(
                              avatar: Icon(
                                link.iconData,
                                size: 16,
                                color: link.brandColor,
                              ),
                              label: Text(
                                link.title.isNotEmpty ? link.title : link.serviceName,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () => launchUrl(
                                Uri.parse(link.url),
                                mode: LaunchMode.externalApplication,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeFilters() {
    final scheme = Theme.of(context).colorScheme;
    final photoCount = _posts
        .where((p) => !MediaUrlSelector.isVideo(p) && !MediaUrlSelector.isGif(p))
        .length;
    final videoCount = _posts.where(MediaUrlSelector.isVideo).length;
    final gifCount = _posts.where(MediaUrlSelector.isGif).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              selected: _selectedTypes.isEmpty,
              label: Text('Все (${_posts.length})'),
              onSelected: (_) => setState(() => _selectedTypes.clear()),
            ),
            const SizedBox(width: 8),
            FilterChip(
              selected: _selectedTypes.contains('photo'),
              avatar: Icon(Icons.photo_outlined,
                  size: 16,
                  color: _selectedTypes.contains('photo')
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant),
              label: Text('Фото ($photoCount)'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('photo');
                  } else {
                    _selectedTypes.remove('photo');
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              selected: _selectedTypes.contains('video'),
              avatar: Icon(Icons.videocam_outlined,
                  size: 16,
                  color: _selectedTypes.contains('video')
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant),
              label: Text('Видео ($videoCount)'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('video');
                  } else {
                    _selectedTypes.remove('video');
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              selected: _selectedTypes.contains('gif'),
              avatar: Icon(Icons.gif_rounded,
                  size: 20,
                  color: _selectedTypes.contains('gif')
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant),
              label: Text('GIF ($gifCount)'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add('gif');
                  } else {
                    _selectedTypes.remove('gif');
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsBar() {
    if (_tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedTag != null) ...[
              InputChip(
                selected: true,
                avatar: const Icon(Icons.close_rounded, size: 16),
                label: Text('#$_selectedTag'),
                onSelected: (_) => _onTagSelected(null),
              ),
              const SizedBox(width: 8),
            ],
            for (final tag in _tags)
              if (tag.tag != _selectedTag) ...[
                ActionChip(
                  label: Text('#${tag.tag} (${tag.postCount})'),
                  onPressed: () => _onTagSelected(tag.tag),
                ),
                const SizedBox(width: 8),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleArtistFavorite(
    AppSettings settings,
    bool isCurrentlyFav,
  ) async {
    final current = List<String>.from(settings.favoriteArtists);
    final artistKey =
        '${widget.providerId}:${widget.service}:${widget.artistId}';
    if (isCurrentlyFav) {
      current.removeWhere((e) {
        try {
          return FavoriteArtistItem.fromJson(
                      jsonDecode(e) as Map<String, dynamic>)
                  .key ==
              artistKey;
        } catch (_) {
          return false;
        }
      });
    } else {
      final avatarUrl = widget.providerId == 'pawchive'
          ? 'https://pawchive.pw/icons/${widget.service}/${widget.artistId}'
          : null;
      final item = FavoriteArtistItem(
        id: widget.artistId,
        service: widget.service,
        providerId: widget.providerId,
        name: widget.artistName,
        avatarUrl: avatarUrl,
      );
      current.insert(0, jsonEncode(item.toJson()));
    }
    await ref.read(settingsControllerProvider.notifier).saveSettings(
          settings.copyWith(favoriteArtists: current),
        );

    if (widget.service.isNotEmpty && widget.artistId.isNotEmpty) {
      final activeAcc = settings.activePawchiveAccount;
      if (activeAcc != null) {
        unawaited(ref.read(pawchiveSyncServiceProvider).toggleRemoteFavorite(
              account: activeAcc,
              service: widget.service,
              artistId: widget.artistId,
              isFavorite: !isCurrentlyFav,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    final viewedKeys = ref.watch(viewedKeysProvider).value ?? <String>{};

    final artistKey =
        '${widget.providerId}:${widget.service}:${widget.artistId}';
    final isArtistFavorite = settings.favoriteArtists.any((e) {
      try {
        return FavoriteArtistItem.fromJson(
                    jsonDecode(e) as Map<String, dynamic>)
                .key ==
            artistKey;
      } catch (_) {
        return false;
      }
    });

    final displayedPosts =
        _posts.where(_matchesTypeFilter).toList(growable: false);

    return AdaptiveScaffold(
      title: widget.artistName,
      actions: [
        IconButton(
          tooltip: isArtistFavorite ? 'В избранном' : 'В избранное',
          icon: Icon(
            isArtistFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isArtistFavorite ? Colors.amber : null,
          ),
          onPressed: () => _toggleArtistFavorite(settings, isArtistFavorite),
        ),
        if (_announcements.isNotEmpty)
          IconButton(
            tooltip: 'Анонсы автора',
            onPressed: _showAnnouncements,
            icon: Badge.count(
              count: _announcements.length,
              child: const Icon(Icons.campaign_rounded),
            ),
          ),
        IconButton(
          tooltip: 'Обновить',
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
                  ? Column(
                      children: [
                        _buildTagsBar(),
                        const Expanded(
                          child: EmptyView(
                            title: 'Нет работ',
                            message: 'У этого автора пока нет видимых постов.',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMediaTypeFilters(),
                        _buildTagsBar(),
                        Expanded(
                          child: displayedPosts.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.filter_alt_off_rounded,
                                            size: 48),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Нет медиа по выбранным фильтрам',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        FilledButton.tonal(
                                          onPressed: () {
                                            setState(() {
                                              _selectedTypes.clear();
                                              _selectedTag = null;
                                            });
                                          },
                                          child: const Text('Сбросить фильтры'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : PostMasonryGrid(
                                  posts: displayedPosts,
                                  controller: _scrollController,
                                  loading: _loading,
                                  gridMode: settings.gridMode,
                                  columns: Responsive.columnsFor(
                                    context,
                                    mobileColumns: settings.mobileColumns,
                                    desktopColumns: settings.desktopColumns,
                                  ),
                                  blurExplicit: settings.blurExplicitContent,
                                  showBadges: settings.showPostBadges,
                                  nsfwEnabled: settings.nsfwEnabled,
                                  mediaQualityMode: MediaQualityMode.fromName(
                                      settings.mediaQualityMode),
                                  favoriteKeys: favoriteKeys,
                                  viewedKeys: viewedKeys,
                                  onOpen: (post) => context.push(
                                    '/post/${post.providerId}/${post.id}',
                                    extra: PostNavigationContext(
                                      currentPost: post,
                                      posts: displayedPosts,
                                    ),
                                  ),
                                  onFavorite: (post) async {
                                    if (favoriteKeys.contains(post.cacheKey)) {
                                      await ref
                                          .read(favoriteServiceProvider)
                                          .removeFavorite(
                                              post.id, post.providerId);
                                    } else {
                                      await ref
                                          .read(favoriteServiceProvider)
                                          .addFavorite(
                                            post,
                                            settings: settings,
                                            downloadManager: ref.read(
                                                downloadManagerServiceProvider),
                                          );
                                    }
                                    ref.invalidate(favoriteKeysProvider);
                                    ref.invalidate(
                                        favoritesControllerProvider);
                                  },
                                ),
                        ),
                      ],
                    ),
    );
  }

  String _friendlyArtistPostError(Object error) {
    final message = error.toString();
    if (message.contains('HandshakeException') ||
        message.contains('artist works are unavailable')) {
      return 'Работы автора временно недоступны. Попробуйте обновить позже.';
    }
    return message;
  }
}
