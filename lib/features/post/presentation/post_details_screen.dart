import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../collections/presentation/collection_form_dialog.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../feed/presentation/feed_controller.dart';
import '../../viewed/presentation/viewed_controller.dart';
import 'post_details_controller.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_media_viewer.dart';
import 'widgets/post_tags_panel.dart';

final postCommentsProvider =
    FutureProvider.family<List<PostComment>, PostDetailsArgs>(
        (ref, args) async {
  final result = await ref
      .watch(providerManagerProvider)
      .getComments(args.providerId, args.postId);
  return result is Success<List<PostComment>> ? result.data : const [];
});

class PostDetailsScreen extends ConsumerWidget {
  const PostDetailsScreen({
    required this.providerId,
    required this.postId,
    this.initialPost,
    super.key,
  });

  final String providerId;
  final String postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = PostDetailsArgs(
      providerId: providerId,
      postId: postId,
      initialPost: initialPost,
    );
    final post = ref.watch(postDetailsControllerProvider(args));
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final feedPosts =
        ref.watch(feedControllerProvider).value?.posts ?? const <Post>[];
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    return AdaptiveScaffold(
      title: 'Post',
      actions: [
        IconButton(
          tooltip: 'Close',
          onPressed: () => _close(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      body: post.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (post) {
          if (post == null) return const EmptyView(title: 'Post not found');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(viewedHistoryServiceProvider).markViewed(post);
            ref.invalidate(viewedKeysProvider);
            ref.invalidate(viewedControllerProvider);
          });
          final currentIndex = feedPosts.indexWhere(
            (item) => item.providerId == post.providerId && item.id == post.id,
          );
          final previous =
              currentIndex > 0 ? feedPosts[currentIndex - 1] : null;
          final next = currentIndex >= 0 && currentIndex < feedPosts.length - 1
              ? feedPosts[currentIndex + 1]
              : null;
          final qualityMode =
              MediaQualityMode.fromName(settings.mediaQualityMode);
          if (Responsive.isMobile(context)) {
            if (currentIndex >= 0 && feedPosts.length > 1) {
              return _MobilePostPager(
                posts: feedPosts,
                initialIndex: currentIndex,
                buildDetails: (context, post) => _buildMobileDetails(
                  context,
                  ref,
                  post,
                  settings,
                  favoriteKeys,
                  qualityMode,
                ),
              );
            }
            return _buildMobileDetails(
              context,
              ref,
              post,
              settings,
              favoriteKeys,
              qualityMode,
            );
          }
          return Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                  const _PreviousPostIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight):
                  const _NextPostIntent(),
              LogicalKeySet(LogicalKeyboardKey.keyF):
                  const _ToggleFavoriteIntent(),
              LogicalKeySet(LogicalKeyboardKey.keyC):
                  const _AddCollectionIntent(),
              LogicalKeySet(LogicalKeyboardKey.keyS): const _DownloadIntent(),
              LogicalKeySet(LogicalKeyboardKey.escape): const _CloseIntent(),
            },
            child: Actions(
              actions: {
                _PreviousPostIntent: CallbackAction<_PreviousPostIntent>(
                  onInvoke: (_) {
                    if (previous != null) _openPost(context, previous);
                    return null;
                  },
                ),
                _NextPostIntent: CallbackAction<_NextPostIntent>(
                  onInvoke: (_) {
                    if (next != null) _openPost(context, next);
                    return null;
                  },
                ),
                _ToggleFavoriteIntent: CallbackAction<_ToggleFavoriteIntent>(
                  onInvoke: (_) {
                    _toggleFavorite(ref, post, favoriteKeys);
                    return null;
                  },
                ),
                _AddCollectionIntent: CallbackAction<_AddCollectionIntent>(
                  onInvoke: (_) {
                    _addToCollection(context, ref, post);
                    return null;
                  },
                ),
                _CloseIntent: CallbackAction<_CloseIntent>(
                  onInvoke: (_) {
                    _close(context);
                    return null;
                  },
                ),
                _DownloadIntent: CallbackAction<_DownloadIntent>(
                  onInvoke: (_) {
                    if (settings.allowDownloads) {
                      _download(context, ref, post);
                    }
                    return null;
                  },
                ),
              },
              child: Focus(
                autofocus: true,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Previous',
                          onPressed: previous == null
                              ? null
                              : () => _openPost(context, previous),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 760),
                              child: PostMediaViewer(
                                post: post,
                                qualityMode: qualityMode,
                              ),
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Next',
                          onPressed: next == null
                              ? null
                              : () => _openPost(context, next),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    if (currentIndex >= 0) ...[
                      const SizedBox(height: 10),
                      _NeighborStrip(
                        posts: feedPosts,
                        currentIndex: currentIndex,
                        onOpen: (post) => _openPost(context, post),
                      ),
                    ],
                    const SizedBox(height: 16),
                    PostActionBar(
                      isFavorite: favoriteKeys.contains(post.cacheKey),
                      onFavorite: () =>
                          _toggleFavorite(ref, post, favoriteKeys),
                      onCollection: () => _addToCollection(context, ref, post),
                      onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
                      onCopy: () =>
                          Clipboard.setData(ClipboardData(text: post.fileUrl)),
                      onSimilar: () => _openSimilar(context, ref, post),
                      onDownload: settings.allowDownloads
                          ? () => _download(context, ref, post)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(label: Text(post.providerName)),
                        RatingBadge(rating: post.rating),
                        Chip(label: Text('${post.width} x ${post.height}')),
                        if (post.source != null && post.source!.isNotEmpty)
                          ActionChip(
                            label: const Text('Source'),
                            onPressed: () => launchUrl(Uri.parse(post.source!)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Tags', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    PostTagsPanel(post: post),
                    const SizedBox(height: 16),
                    _CommentsSection(post: post),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileDetails(
    BuildContext context,
    WidgetRef ref,
    Post post,
    AppSettings settings,
    Set<String> favoriteKeys,
    MediaQualityMode qualityMode,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.62,
          ),
          child: Center(
            child: PostMediaViewer(
              post: post,
              qualityMode: qualityMode,
            ),
          ),
        ),
        const SizedBox(height: 12),
        PostActionBar(
          isFavorite: favoriteKeys.contains(post.cacheKey),
          onFavorite: () => _toggleFavorite(ref, post, favoriteKeys),
          onCollection: () => _addToCollection(context, ref, post),
          onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
          onCopy: () => Clipboard.setData(ClipboardData(text: post.fileUrl)),
          onSimilar: () => _openSimilar(context, ref, post),
          onDownload: settings.allowDownloads
              ? () => _download(context, ref, post)
              : null,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text(post.providerName)),
            RatingBadge(rating: post.rating),
            Chip(label: Text('${post.width} x ${post.height}')),
            if (post.source != null && post.source!.isNotEmpty)
              ActionChip(
                label: const Text('Source'),
                onPressed: () => launchUrl(Uri.parse(post.source!)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          title: Text('Tags', style: Theme.of(context).textTheme.titleMedium),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: PostTagsPanel(post: post),
            ),
          ],
        ),
        _CommentsSection(post: post),
      ],
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

  Future<void> _download(BuildContext context, WidgetRef ref, Post post) async {
    if (!context.mounted) return;
    await ref.read(downloadManagerServiceProvider).start(post);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started')),
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
    }
    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(favoritesControllerProvider);
  }

  void _openPost(BuildContext context, Post post) {
    _replacePost(context, post);
  }

  void _openSimilar(BuildContext context, WidgetRef ref, Post post) {
    final query = similarTagsFor(post).join(' ');
    if (query.trim().isEmpty) return;
    ref.read(feedControllerProvider.notifier).search(query);
    context.go('/?q=${Uri.encodeQueryComponent(query)}');
  }

  void _replacePost(BuildContext context, Post post) {
    context.replace('/post/${post.providerId}/${post.id}', extra: post);
  }

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }
}

class _MobilePostPager extends StatefulWidget {
  const _MobilePostPager({
    required this.posts,
    required this.initialIndex,
    required this.buildDetails,
  });

  final List<Post> posts;
  final int initialIndex;
  final Widget Function(BuildContext context, Post post) buildDetails;

  @override
  State<_MobilePostPager> createState() => _MobilePostPagerState();
}

class _MobilePostPagerState extends State<_MobilePostPager> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAround(widget.initialIndex);
    });
  }

  @override
  void didUpdateWidget(covariant _MobilePostPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != _currentIndex &&
        widget.initialIndex >= 0 &&
        widget.initialIndex < widget.posts.length) {
      _currentIndex = widget.initialIndex;
      if (_controller.hasClients) {
        _controller.jumpToPage(widget.initialIndex);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefetchAround(widget.initialIndex);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.posts.length,
      onPageChanged: (index) {
        _currentIndex = index;
        _prefetchAround(index);
      },
      itemBuilder: (context, index) {
        return _KeepAlivePostPage(
          child: KeyedSubtree(
            key: ValueKey(widget.posts[index].cacheKey),
            child: widget.buildDetails(context, widget.posts[index]),
          ),
        );
      },
    );
  }

  void _prefetchAround(int index) {
    for (final offset in [-2, -1, 0, 1, 2]) {
      final target = index + offset;
      if (target < 0 || target >= widget.posts.length) continue;
      final post = widget.posts[target];
      final urls = [
        post.previewUrl,
        post.sampleUrl,
        if (post.fileType.toLowerCase().contains('gif')) post.fileUrl,
      ].where((url) => url.trim().isNotEmpty).toSet();
      for (final url in urls) {
        precacheImage(
          CachedNetworkImageProvider(url, headers: _headersFor(post)),
          context,
        );
      }
    }
  }

  Map<String, String> _headersFor(Post post) {
    return {
      'User-Agent': 'RuleGel/0.2 Flutter local booru browser',
      'Accept': '*/*',
      if (post.providerName.toLowerCase().contains('gelbooru') ||
          post.fileUrl.contains('gelbooru.com') ||
          post.sampleUrl.contains('gelbooru.com') ||
          post.previewUrl.contains('gelbooru.com'))
        'Referer': 'https://gelbooru.com/',
      if (post.providerName.toLowerCase().contains('rule34') ||
          post.fileUrl.contains('rule34') ||
          post.sampleUrl.contains('rule34') ||
          post.previewUrl.contains('rule34'))
        'Referer': 'https://rule34.xxx/',
    };
  }
}

class _KeepAlivePostPage extends StatefulWidget {
  const _KeepAlivePostPage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePostPage> createState() => _KeepAlivePostPageState();
}

class _KeepAlivePostPageState extends State<_KeepAlivePostPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _NeighborStrip extends StatelessWidget {
  const _NeighborStrip({
    required this.posts,
    required this.currentIndex,
    required this.onOpen,
  });

  final List<Post> posts;
  final int currentIndex;
  final ValueChanged<Post> onOpen;

  @override
  Widget build(BuildContext context) {
    final start = (currentIndex - 3).clamp(0, posts.length);
    final end = (currentIndex + 4).clamp(0, posts.length);
    final visible = posts.sublist(start, end);
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final post = visible[index];
          final selected = post.cacheKey == posts[currentIndex].cacheKey;
          return InkWell(
            onTap: () => onOpen(post),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: post.previewUrl.isNotEmpty
                    ? post.previewUrl
                    : post.sampleUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image_rounded)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviousPostIntent extends Intent {
  const _PreviousPostIntent();
}

class _NextPostIntent extends Intent {
  const _NextPostIntent();
}

class _ToggleFavoriteIntent extends Intent {
  const _ToggleFavoriteIntent();
}

class _AddCollectionIntent extends Intent {
  const _AddCollectionIntent();
}

class _CloseIntent extends Intent {
  const _CloseIntent();
}

class _DownloadIntent extends Intent {
  const _DownloadIntent();
}

class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection({required this.post});

  final Post post;

  @override
  ConsumerState<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<_CommentsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final comments = _expanded
        ? ref.watch(
            postCommentsProvider(
              PostDetailsArgs(
                providerId: widget.post.providerId,
                postId: widget.post.id,
              ),
            ),
          )
        : null;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: false,
      onExpansionChanged: (value) => setState(() => _expanded = value),
      title: Text('Comments', style: Theme.of(context).textTheme.titleMedium),
      children: [
        (comments ?? const AsyncValue<List<PostComment>>.data([])).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Comments unavailable'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('No comments'),
                ),
              );
            }
            return Column(
              children: [
                for (final comment in items)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      comment.authorName.isEmpty
                          ? 'Anonymous'
                          : comment.authorName,
                    ),
                    subtitle: Text(comment.body),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
