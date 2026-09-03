import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../collections/presentation/collection_form_dialog.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'feed_controller.dart';
import 'widgets/feed_toolbar.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({this.initialQuery, super.key});

  final String? initialQuery;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final Set<String> _selectedKeys = {};
  bool _selectionMode = false;
  String? _appliedInitialQuery;
  Timer? _scrollSaveDebounce;
  double _lastKnownScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 800) {
        ref.read(feedControllerProvider.notifier).loadNextPage();
      }
      _lastKnownScrollOffset = _scrollController.offset;
      _scrollSaveDebounce?.cancel();
      _scrollSaveDebounce = Timer(const Duration(milliseconds: 600), () {
        ref
            .read(feedControllerProvider.notifier)
            .saveSession(scrollOffset: _scrollController.offset);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings =
          ref.read(appSettingsProvider).value ?? AppSettings.defaults;
      if (settings.lastFeedScrollOffset > 0 && _scrollController.hasClients) {
        _lastKnownScrollOffset = settings.lastFeedScrollOffset;
        _scrollController.jumpTo(
          settings.lastFeedScrollOffset.clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextQuery = widget.initialQuery;
    if (nextQuery != null &&
        nextQuery.isNotEmpty &&
        nextQuery != oldWidget.initialQuery) {
      _appliedInitialQuery = nextQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applySearchQuery(nextQuery);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollSaveDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (_scrollController.hasClients) {
      _lastKnownScrollOffset = _scrollController.offset;
      ref
          .read(feedControllerProvider.notifier)
          .saveSession(scrollOffset: _lastKnownScrollOffset);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _lastKnownScrollOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      if ((_scrollController.offset - target).abs() > 24) {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    final viewedKeys = ref.watch(viewedKeysProvider).value ?? <String>{};

    final initialQuery = widget.initialQuery?.trim();
    final currentTags = feed.value?.selectedTags.join(' ');
    if (initialQuery != null &&
        initialQuery.isNotEmpty &&
        _appliedInitialQuery != initialQuery &&
        currentTags != initialQuery) {
      _appliedInitialQuery = initialQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applySearchQuery(initialQuery);
      });
    }

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyR): const _RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _ClearSelectionIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const _ClearSelectionIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
            const _SelectVisibleIntent(),
      },
      child: Actions(
        actions: {
          _RefreshIntent: CallbackAction<_RefreshIntent>(
            onInvoke: (_) {
              ref.read(feedControllerProvider.notifier).refresh();
              return null;
            },
          ),
          _ClearSelectionIntent: CallbackAction<_ClearSelectionIntent>(
            onInvoke: (_) {
              _clearSelection();
              return null;
            },
          ),
          _SelectVisibleIntent: CallbackAction<_SelectVisibleIntent>(
            onInvoke: (_) {
              final state = feed.value;
              if (state != null) {
                setState(() {
                  _selectionMode = true;
                  _selectedKeys
                    ..clear()
                    ..addAll(state.posts.map((post) => post.cacheKey));
                });
              }
              return null;
            },
          ),
        },
        child: AdaptiveScaffold(
          title: 'Feed',
          titleWidget: const _FeedTitle(),
          body: feed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(
              message: error.toString(),
              onRetry: () =>
                  ref.read(feedControllerProvider.notifier).loadInitial(),
            ),
            data: (state) => Column(
              children: [
                FeedToolbar(
                  selectedTags: state.selectedTags,
                  selectedProviderIds: state.selectedProviderIds,
                  topPeriodFilter: state.topPeriodFilter,
                  tagSuggestions: state.tagSuggestions,
                  providers: state.providers,
                  rating: state.ratingFilter,
                  providerStatusMessage: state.providerStatusMessage,
                  onSearchChanged: (query) => ref
                      .read(feedControllerProvider.notifier)
                      .updateTagSuggestions(query),
                  onSuggestionTap: _submitSearch,
                  onTopPeriodChanged: (period) => ref
                      .read(feedControllerProvider.notifier)
                      .setTopPeriod(period),
                  onSearch: _submitSearch,
                  onRefresh: () =>
                      ref.read(feedControllerProvider.notifier).refresh(),
                  onClearFilters: _clearFilters,
                  onRandom: () => _openRandom(state.posts),
                  selectionMode: _selectionMode,
                  onToggleSelectionMode: () {
                    setState(() {
                      _selectionMode = !_selectionMode;
                      if (!_selectionMode) _selectedKeys.clear();
                    });
                  },
                  onQuickProviderToggle: (providerId) {
                    if (providerId == '__all__') {
                      ref
                          .read(feedControllerProvider.notifier)
                          .setProviders([]);
                      return;
                    }
                    final selected =
                        state.selectedProviderIds.contains(providerId)
                            ? state.selectedProviderIds
                                .where((id) => id != providerId)
                                .toList()
                            : [...state.selectedProviderIds, providerId];
                    ref
                        .read(feedControllerProvider.notifier)
                        .setProviders(selected);
                  },
                  onProviderFilter: () async {
                    final selected = await showProviderFilterSheet(
                      context,
                      providers: state.providers,
                      selectedIds: state.selectedProviderIds,
                    );
                    if (selected != null) {
                      await ref
                          .read(feedControllerProvider.notifier)
                          .setProviders(selected);
                    }
                  },
                  onRatingFilter: () async {
                    final rating = await showRatingFilterSheet(
                        context, state.ratingFilter);
                    await ref
                        .read(feedControllerProvider.notifier)
                        .setRating(rating);
                  },
                ),
                Expanded(
                  child: state.posts.isEmpty && !state.isLoadingMore
                      ? const EmptyView(
                          title: 'No posts yet',
                          message: 'Try another tag or check providers.',
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(feedControllerProvider.notifier)
                              .refresh(),
                          child: PostMasonryGrid(
                            key: const PageStorageKey('feed_masonry_grid'),
                            controller: _scrollController,
                            posts: state.posts,
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
                            loading: state.isLoadingMore,
                            favoriteKeys: favoriteKeys,
                            viewedKeys: viewedKeys,
                            selectionMode: _selectionMode,
                            selectedKeys: _selectedKeys,
                            onOpen: (post) => context.push(
                              '/post/${post.providerId}/${post.id}',
                              extra: post,
                            ),
                            onPreview: (post) => _showPreview(context, post),
                            onToggleSelected: (post) => _toggleSelected(post),
                            onFavorite: (post) =>
                                _toggleFavorite(ref, post, favoriteKeys),
                            onAddToCollection: (post) =>
                                _addToCollection(context, ref, post),
                            onHide: (post) => _hidePost(context, ref, post),
                          ),
                        ),
                ),
                if (_selectionMode && _selectedKeys.isNotEmpty)
                  _BatchActionBar(
                    count: _selectedKeys.length,
                    onFavorite: () => _favoriteSelected(
                      ref,
                      state.posts,
                      favoriteKeys,
                    ),
                    onCollection: () => _addSelectedToCollection(
                      context,
                      ref,
                      state.posts,
                    ),
                    onClear: _clearSelection,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _clearFilters();
      return;
    }
    final location = '/?q=${Uri.encodeQueryComponent(trimmed)}';
    if (widget.initialQuery?.trim() == trimmed) {
      _applySearchQuery(trimmed);
      return;
    }
    context.go(location);
  }

  void _openRandom(List<Post> posts) {
    if (posts.isEmpty) return;
    final post = posts[Random().nextInt(posts.length)];
    context.push('/post/${post.providerId}/${post.id}', extra: post);
  }

  Future<void> _applySearchQuery(String query) async {
    await ref.read(feedControllerProvider.notifier).search(query);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _clearFilters() async {
    _appliedInitialQuery = null;
    await ref.read(feedControllerProvider.notifier).clearFilters();
    if (mounted && widget.initialQuery != null) {
      context.go('/');
    }
  }

  void _toggleSelected(Post post) {
    setState(() {
      _selectionMode = true;
      if (!_selectedKeys.add(post.cacheKey)) {
        _selectedKeys.remove(post.cacheKey);
      }
      if (_selectedKeys.isEmpty) _selectionMode = false;
    });
  }

  void _clearSelection() {
    if (!_selectionMode && _selectedKeys.isEmpty) return;
    setState(() {
      _selectionMode = false;
      _selectedKeys.clear();
    });
  }

  List<Post> _selectedPosts(List<Post> posts) {
    return posts
        .where((post) => _selectedKeys.contains(post.cacheKey))
        .toList();
  }

  Future<void> _favoriteSelected(
    WidgetRef ref,
    List<Post> posts,
    Set<String> favoriteKeys,
  ) async {
    for (final post in _selectedPosts(posts)) {
      if (!favoriteKeys.contains(post.cacheKey)) {
        await ref.read(favoriteServiceProvider).addFavorite(post);
        await _maybeAutoDownloadFavorite(ref, post);
      }
    }
    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(favoritesControllerProvider);
    _clearSelection();
  }

  Future<void> _addSelectedToCollection(
    BuildContext context,
    WidgetRef ref,
    List<Post> posts,
  ) async {
    final selectedPosts = _selectedPosts(posts);
    final result = await ref.read(collectionServiceProvider).getCollections();
    final collections =
        result is Success<List<Collection>> ? result.data : <Collection>[];
    if (!context.mounted) return;
    await showAddToCollectionPicker(
      context,
      collections: collections,
      onSelected: (collection) async {
        await ref
            .read(collectionServiceProvider)
            .addPostsToCollection(collection.id, selectedPosts);
        _clearSelection();
      },
      onCreate: () => showCollectionFormDialog(context, ref),
    );
  }

  Future<void> _showPreview(BuildContext context, Post post) {
    final imageUrl = MediaUrlSelector.preview(post).firstOrNull;
    final child = imageUrl == null
        ? const Center(child: Icon(Icons.broken_image_rounded, size: 48))
        : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain);
    if (Responsive.isMobile(context)) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Padding(padding: const EdgeInsets.all(8), child: child),
        ),
      );
    }
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
          child: Padding(padding: const EdgeInsets.all(8), child: child),
        ),
      ),
    );
  }

  Future<void> _addToCollection(
    BuildContext context,
    WidgetRef ref,
    Post post,
  ) async {
    final result = await ref.read(collectionServiceProvider).getCollections();
    final collections =
        result is Success<List<Collection>> ? result.data : <Collection>[];
    if (!context.mounted) return;
    await showAddToCollectionPicker(
      context,
      collections: collections,
      onSelected: (collection) {
        ref
            .read(collectionServiceProvider)
            .addPostToCollection(collection.id, post);
      },
      onCreate: () => showCollectionFormDialog(context, ref),
    );
  }

  Future<void> _toggleFavorite(
    WidgetRef ref,
    Post post,
    Set<String> favoriteKeys,
  ) async {
    if (favoriteKeys.contains(post.cacheKey)) {
      await ref
          .read(favoriteServiceProvider)
          .removeFavorite(post.id, post.providerId);
    } else {
      await ref.read(favoriteServiceProvider).addFavorite(post);
      await _maybeAutoDownloadFavorite(ref, post);
    }
    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(favoritesControllerProvider);
  }

  Future<void> _hidePost(
    BuildContext context,
    WidgetRef ref,
    Post post,
  ) async {
    await ref.read(feedControllerProvider.notifier).hidePost(post);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post hidden locally'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref
                .read(settingsServiceProvider)
                .unhidePostKey(post.cacheKey);
            ref.invalidate(appSettingsProvider);
            ref.read(feedControllerProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  Future<void> _maybeAutoDownloadFavorite(WidgetRef ref, Post post) async {
    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    if (!settings.autoDownloadFavorites || !settings.allowDownloads) return;
    await ref.read(downloadManagerServiceProvider).start(post);
  }
}

class _RefreshIntent extends Intent {
  const _RefreshIntent();
}

class _FeedTitle extends StatelessWidget {
  const _FeedTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lunaris',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Builder(builder: (context) {
          return Consumer(
            builder: (context, ref, _) => Text(
              ref.watch(appStringsProvider).feed,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ClearSelectionIntent extends Intent {
  const _ClearSelectionIntent();
}

class _SelectVisibleIntent extends Intent {
  const _SelectVisibleIntent();
}

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.count,
    required this.onFavorite,
    required this.onCollection,
    required this.onClear,
  });

  final int count;
  final VoidCallback onFavorite;
  final VoidCallback onCollection;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 16),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text('$count selected',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Favorite selected',
                  onPressed: onFavorite,
                  icon: const Icon(Icons.favorite_rounded),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onCollection,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Collection'),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
