import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shared/widgets/post_card.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../collections/presentation/collection_form_dialog.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../feed/presentation/feed_controller.dart';
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
          final currentIndex = feedPosts.indexWhere(
            (item) => item.providerId == post.providerId && item.id == post.id,
          );
          final previous =
              currentIndex > 0 ? feedPosts[currentIndex - 1] : null;
          final next = currentIndex >= 0 && currentIndex < feedPosts.length - 1
              ? feedPosts[currentIndex + 1]
              : null;
          if (Responsive.isMobile(context)) {
            if (currentIndex >= 0 && feedPosts.length > 1) {
              return PageView.builder(
                controller: PageController(initialPage: currentIndex),
                itemCount: feedPosts.length,
                onPageChanged: (index) =>
                    _replacePost(context, feedPosts[index]),
                itemBuilder: (context, index) => _buildMobileDetails(
                  context,
                  ref,
                  feedPosts[index],
                  settings,
                  favoriteKeys,
                ),
              );
            }
            return _buildMobileDetails(
              context,
              ref,
              post,
              settings,
              favoriteKeys,
            );
          }
          return ListView(
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
                        child: PostMediaViewer(post: post),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Next',
                    onPressed:
                        next == null ? null : () => _openPost(context, next),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PostActionBar(
                isFavorite: favoriteKeys.contains(post.cacheKey),
                onFavorite: () => _toggleFavorite(ref, post, favoriteKeys),
                onCollection: () => _addToCollection(context, ref, post),
                onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
                onCopy: () =>
                    Clipboard.setData(ClipboardData(text: post.fileUrl)),
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
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.62,
          ),
          child: Center(child: PostMediaViewer(post: post)),
        ),
        const SizedBox(height: 12),
        PostActionBar(
          isFavorite: favoriteKeys.contains(post.cacheKey),
          onFavorite: () => _toggleFavorite(ref, post, favoriteKeys),
          onCollection: () => _addToCollection(context, ref, post),
          onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
          onCopy: () => Clipboard.setData(ClipboardData(text: post.fileUrl)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading...')),
    );
    try {
      final saved = await ref.read(downloadServiceProvider).downloadPost(post);
      if (!context.mounted || saved == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download complete: $saved')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $error')),
      );
    }
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
                  child: Text('Comments unavailable'),
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
