import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import 'feed_controller.dart';
import 'widgets/feed_toolbar.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({this.initialQuery, super.key});

  final String? initialQuery;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _usedInitialQuery = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 800) {
        ref.read(feedControllerProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;

    if (!_usedInitialQuery && (widget.initialQuery?.isNotEmpty ?? false)) {
      _usedInitialQuery = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(feedControllerProvider.notifier).search(widget.initialQuery!);
      });
    }

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyR): const _RefreshIntent(),
      },
      child: Actions(
        actions: {
          _RefreshIntent: CallbackAction<_RefreshIntent>(
            onInvoke: (_) {
              ref.read(feedControllerProvider.notifier).refresh();
              return null;
            },
          ),
        },
        child: AdaptiveScaffold(
          title: 'Feed',
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
                  onSearchChanged: (query) => ref
                      .read(feedControllerProvider.notifier)
                      .updateTagSuggestions(query),
                  onSuggestionTap: (query) =>
                      ref.read(feedControllerProvider.notifier).search(query),
                  onTopPeriodChanged: (period) => ref
                      .read(feedControllerProvider.notifier)
                      .setTopPeriod(period),
                  onSearch: (query) =>
                      ref.read(feedControllerProvider.notifier).search(query),
                  onRefresh: () =>
                      ref.read(feedControllerProvider.notifier).refresh(),
                  onClearFilters: () =>
                      ref.read(feedControllerProvider.notifier).clearFilters(),
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
                            loading: state.isLoadingMore,
                            onOpen: (post) => context.push(
                              '/post/${post.providerId}/${post.id}',
                              extra: post,
                            ),
                            onFavorite: (post) => ref
                                .read(favoriteServiceProvider)
                                .addFavorite(post),
                            onAddToCollection: (post) =>
                                _addToCollection(context, ref, post),
                          ),
                        ),
                ),
              ],
            ),
          ),
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
}

class _RefreshIntent extends Intent {
  const _RefreshIntent();
}
