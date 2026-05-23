import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
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
import '../../feed/presentation/feed_controller.dart';
import 'post_details_controller.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_media_viewer.dart';
import 'widgets/post_tags_panel.dart';

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
            return _buildMobileDetails(context, ref, post, settings);
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
                onFavorite: () =>
                    ref.read(favoriteServiceProvider).addFavorite(post),
                onCollection: () => _addToCollection(context, ref, post),
                onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
                onCopy: () =>
                    Clipboard.setData(ClipboardData(text: post.fileUrl)),
                onDownload: settings.allowDownloads
                    ? () => _download(context, post)
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
          onFavorite: () => ref.read(favoriteServiceProvider).addFavorite(post),
          onCollection: () => _addToCollection(context, ref, post),
          onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
          onCopy: () => Clipboard.setData(ClipboardData(text: post.fileUrl)),
          onDownload:
              settings.allowDownloads ? () => _download(context, post) : null,
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

  Future<void> _download(BuildContext context, Post post) async {
    final filename = p.basename(Uri.parse(post.fileUrl).path);
    final location = await getSaveLocation(suggestedName: filename);
    if (location == null) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading...')),
    );
    await Dio().download(post.fileUrl, location.path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download complete')),
    );
  }

  void _openPost(BuildContext context, Post post) {
    context.go('/post/${post.providerId}/${post.id}', extra: post);
  }

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }
}
