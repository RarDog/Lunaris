import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../../../app/app_strings.dart';
import '../../../app/motion.dart';
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
import '../../settings/presentation/settings_controller.dart';
import '../../viewed/presentation/viewed_controller.dart';
import 'post_details_controller.dart';
import 'widgets/cloud_mirrors_card.dart';
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
    this.postsList,
    super.key,
  });

  final String providerId;
  final String postId;
  final Post? initialPost;
  final List<Post>? postsList;

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
    final strings = ref.watch(appStringsProvider);
    final feedPosts = postsList ??
        ref.watch(feedControllerProvider).value?.posts ??
        const <Post>[];
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    return AdaptiveScaffold(
      title: strings.post,
      actions: [
        IconButton(
          tooltip: strings.close,
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
          final localMedia = ref
              .watch(downloadedMediaByKeyProvider(post.cacheKey))
              .value;
          final fileSizeBytes = localMedia != null
              ? DownloadedMediaService.getFileSizeSync(localMedia)
              : null;
          final isDownloading = ref.watch(downloadTasksProvider).value?.any(
                    (t) =>
                        (t.post?.cacheKey == post.cacheKey ||
                            t.id == post.cacheKey) &&
                        (t.status == DownloadTaskStatus.running ||
                            t.status == DownloadTaskStatus.queued),
                  ) ??
              false;
          final isTextOnly = post.fileType == 'text' ||
              (post.previewUrl.isEmpty &&
                  post.sampleUrl.isEmpty &&
                  post.fileUrl.isEmpty &&
                  !MediaUrlSelector.isVideo(post) &&
                  !MediaUrlSelector.isAudio(post));
          final shouldShowCloudCard = isTextOnly
              ? post.cloudLinks.isNotEmpty
              : (post.cloudLinks.isNotEmpty ||
                  (post.commentary != null &&
                      post.commentary!.trim().isNotEmpty));

          if (Responsive.isMobile(context)) {
            if (currentIndex >= 0 && feedPosts.length > 1) {
              return _MobilePostPager(
                posts: feedPosts,
                initialIndex: currentIndex,
                buildDetails: (context, post, mediaGestureLocked,
                        onMediaGestureLockChanged) =>
                    _buildMobileDetails(
                  context,
                  ref,
                  post,
                  settings,
                  favoriteKeys,
                  qualityMode,
                  strings,
                  mediaGestureLocked,
                  onMediaGestureLockChanged,
                  feedPosts,
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
              strings,
              false,
              null,
              feedPosts,
            );
          }
          return Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                  const _PreviousPostIntent(),
              LogicalKeySet(LogicalKeyboardKey.keyA):
                  const _PreviousPostIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight):
                  const _NextPostIntent(),
              LogicalKeySet(LogicalKeyboardKey.keyD):
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
                          tooltip: strings.ru ? 'Предыдущий' : 'Previous',
                          onPressed: previous == null
                              ? null
                              : () => _openPost(context, previous),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Center(
                            child: (MediaUrlSelector.isVideo(post) ||
                                    MediaUrlSelector.isAudio(post))
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: MediaUrlSelector.isAudio(post)
                                          ? 360
                                          : 760,
                                      maxWidth: MediaUrlSelector.isAudio(post)
                                          ? 620
                                          : double.infinity,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: MediaUrlSelector.isAudio(post)
                                          ? 1.4
                                          : ((post.width > 0 && post.height > 0)
                                              ? (post.width / post.height)
                                                  .clamp(0.45, 2.4)
                                              : (16 / 9)),
                                      child: PostMediaViewer(
                                        key: ValueKey(post.cacheKey),
                                        post: post,
                                        localFilePath: localMedia?.savedPath,
                                        qualityMode: qualityMode,
                                        mediaHeaders: ref
                                                .watch(postMediaHeadersProvider(post))
                                                .value ??
                                            const {},
                                        initialPosition: Duration(
                                          milliseconds: settings.videoPlaybackPositions[
                                                  post.cacheKey] ??
                                              0,
                                        ),
                                        initialLoop: settings.videoPlayerLoop,
                                        initialMuted: settings.videoPlayerMuted,
                                        initialCoverVideo: settings.videoPlayerCover,
                                        initialHalfVolume:
                                            settings.videoPlayerHalfVolume,
                                        initialVolume: settings.videoPlayerVolume,
                                        onVolumeChanged: (vol) => ref
                                            .read(settingsControllerProvider.notifier)
                                            .setVideoPlayerVolume(vol),
                                        onPlaybackSnapshot: (snapshot) =>
                                            _saveVideoSnapshot(ref, post, snapshot),
                                        onPlaybackPreferencesChanged: (snapshot) =>
                                            _saveVideoPreferences(ref, snapshot),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    height: 760,
                                    child: PostMediaViewer(
                                      key: ValueKey(post.cacheKey),
                                      post: post,
                                      localFilePath: localMedia?.savedPath,
                                      qualityMode: qualityMode,
                                      mediaHeaders: ref
                                              .watch(postMediaHeadersProvider(post))
                                              .value ??
                                          const {},
                                      initialPosition: Duration(
                                        milliseconds: settings.videoPlaybackPositions[
                                                post.cacheKey] ??
                                            0,
                                      ),
                                      initialLoop: settings.videoPlayerLoop,
                                      initialMuted: settings.videoPlayerMuted,
                                      initialCoverVideo: settings.videoPlayerCover,
                                      initialHalfVolume:
                                          settings.videoPlayerHalfVolume,
                                      initialVolume: settings.videoPlayerVolume,
                                      onVolumeChanged: (vol) => ref
                                          .read(settingsControllerProvider.notifier)
                                          .setVideoPlayerVolume(vol),
                                      onPlaybackSnapshot: (snapshot) =>
                                          _saveVideoSnapshot(ref, post, snapshot),
                                      onPlaybackPreferencesChanged: (snapshot) =>
                                          _saveVideoPreferences(ref, snapshot),
                                    ),
                                  ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: strings.ru ? 'Следующий' : 'Next',
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
                      labels: _postActionLabels(strings),
                      downloaded: localMedia != null,
                      isDownloading: isDownloading,
                      onFavorite: () =>
                          _toggleFavorite(ref, post, favoriteKeys),
                      onCollection: () => _addToCollection(context, ref, post),
                      onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
                      onOpenSource: () => _openSourcePage(ref, post),
                      onCopy: () =>
                          Clipboard.setData(ClipboardData(text: post.fileUrl)),
                      onSimilar: () => _openSimilar(context, ref, post),
                      onHide: () => _hidePost(context, ref, post),
                      onDownload: settings.allowDownloads
                          ? () => _download(context, ref, post)
                          : null,
                      onDeleteLocalFile: () =>
                          _deleteLocalFile(context, ref, post),
                      onShare: () => _sharePost(context, ref, post),
                    ),
                    const SizedBox(height: 16),
                    _PostInfoCard(
                      post: post,
                      strings: strings,
                      localMedia: localMedia,
                      fileSizeBytes: fileSizeBytes,
                    ),
                    if (shouldShowCloudCard) ...[
                      const SizedBox(height: 16),
                      CloudMirrorsCard(
                        links: post.cloudLinks,
                        strings: strings,
                        commentary: isTextOnly ? null : post.commentary,
                        onPlayStream: (streamUrl) => launchUrl(
                          Uri.parse(streamUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                        onDownloadStream: settings.allowDownloads
                            ? (streamUrl) =>
                                _downloadUrl(context, ref, post, streamUrl)
                            : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.70)
                            : Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.40),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${strings.tags} (${post.cleanTags.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PostTagsPanel(post: post),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CommentsSection(post: post),
                    const SizedBox(height: 80),
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
    AppStrings strings,
    bool mediaGestureLocked,
    ValueChanged<bool>? onMediaGestureLockChanged, [
    List<Post>? feedPosts,
  ]) {
    final isVideo = MediaUrlSelector.isVideo(post);
    final isAudio = MediaUrlSelector.isAudio(post);
    final localMedia =
        ref.watch(downloadedMediaByKeyProvider(post.cacheKey)).value;
    final fileSizeBytes = localMedia != null
        ? DownloadedMediaService.getFileSizeSync(localMedia)
        : null;
    final isDownloading = ref.watch(downloadTasksProvider).value?.any(
              (t) =>
                  (t.post?.cacheKey == post.cacheKey ||
                      t.id == post.cacheKey) &&
                  (t.status == DownloadTaskStatus.running ||
                      t.status == DownloadTaskStatus.queued),
            ) ??
        false;
    final isTextOnly = post.fileType == 'text' ||
        (post.previewUrl.isEmpty &&
            post.sampleUrl.isEmpty &&
            post.fileUrl.isEmpty &&
            !MediaUrlSelector.isVideo(post) &&
            !MediaUrlSelector.isAudio(post));
    final shouldShowCloudCard = isTextOnly
        ? post.cloudLinks.isNotEmpty
        : (post.cloudLinks.isNotEmpty ||
            (post.commentary != null &&
                post.commentary!.trim().isNotEmpty));

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        if (mediaGestureLocked) return;
        if ((details.primaryVelocity ?? 0) > 900) _close(context);
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          8,
          8,
          8,
          120 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onDoubleTap:
                isVideo ? null : () => _toggleFavorite(ref, post, favoriteKeys),
            onLongPress: isVideo
                ? null
                : () =>
                    _showMobileQuickActions(context, ref, post, favoriteKeys),
            child: (isVideo || isAudio)
                ? Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: isAudio
                            ? 340
                            : MediaQuery.sizeOf(context).height * 0.70,
                      ),
                      child: AspectRatio(
                        aspectRatio: isAudio
                            ? 1.3
                            : ((post.width > 0 && post.height > 0)
                                ? (post.width / post.height).clamp(0.45, 2.4)
                                : (16 / 9)),
                        child: PostMediaViewer(
                          key: ValueKey(post.cacheKey),
                          post: post,
                          localFilePath: localMedia?.savedPath,
                          qualityMode: qualityMode,
                          mediaHeaders:
                              ref.watch(postMediaHeadersProvider(post)).value ??
                                  const {},
                          initialPosition: Duration(
                            milliseconds:
                                settings.videoPlaybackPositions[post.cacheKey] ??
                                    0,
                          ),
                          initialLoop: settings.videoPlayerLoop,
                          initialMuted: settings.videoPlayerMuted,
                          initialCoverVideo: settings.videoPlayerCover,
                          initialHalfVolume: settings.videoPlayerHalfVolume,
                          initialVolume: settings.videoPlayerVolume,
                          onVolumeChanged: (vol) => ref
                              .read(settingsControllerProvider.notifier)
                              .setVideoPlayerVolume(vol),
                          onPlaybackSnapshot: (snapshot) =>
                              _saveVideoSnapshot(ref, post, snapshot),
                          onPlaybackPreferencesChanged: (snapshot) =>
                              _saveVideoPreferences(ref, snapshot),
                          onMediaGestureLockChanged: (locked) {
                            onMediaGestureLockChanged?.call(locked);
                          },
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.62,
                    child: PostMediaViewer(
                      key: ValueKey(post.cacheKey),
                      post: post,
                      localFilePath: localMedia?.savedPath,
                      qualityMode: qualityMode,
                      mediaHeaders:
                          ref.watch(postMediaHeadersProvider(post)).value ??
                              const {},
                      initialPosition: Duration(
                        milliseconds:
                            settings.videoPlaybackPositions[post.cacheKey] ?? 0,
                      ),
                      initialLoop: settings.videoPlayerLoop,
                      initialMuted: settings.videoPlayerMuted,
                      initialCoverVideo: settings.videoPlayerCover,
                      initialHalfVolume: settings.videoPlayerHalfVolume,
                      initialVolume: settings.videoPlayerVolume,
                      onVolumeChanged: (vol) => ref
                          .read(settingsControllerProvider.notifier)
                          .setVideoPlayerVolume(vol),
                      onPlaybackSnapshot: (snapshot) =>
                          _saveVideoSnapshot(ref, post, snapshot),
                      onPlaybackPreferencesChanged: (snapshot) =>
                          _saveVideoPreferences(ref, snapshot),
                      onMediaGestureLockChanged: (locked) {
                        onMediaGestureLockChanged?.call(locked);
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          PostActionBar(
            isFavorite: favoriteKeys.contains(post.cacheKey),
            labels: _postActionLabels(strings),
            downloaded: localMedia != null,
            isDownloading: isDownloading,
            onFavorite: () => _toggleFavorite(ref, post, favoriteKeys),
            onCollection: () => _addToCollection(context, ref, post),
            onOpen: () => launchUrl(Uri.parse(post.fileUrl)),
            onOpenSource: () => _openSourcePage(ref, post),
            onCopy: () => Clipboard.setData(ClipboardData(text: post.fileUrl)),
            onSimilar: () => _openSimilar(context, ref, post),
            onHide: () => _hidePost(context, ref, post),
            onDownload: settings.allowDownloads
                ? () => _download(context, ref, post)
                : null,
            onDeleteLocalFile: () => _deleteLocalFile(context, ref, post),
            onShare: () => _sharePost(context, ref, post),
          ),
          const SizedBox(height: 12),
          _PostInfoCard(
            post: post,
            strings: strings,
            localMedia: localMedia,
            fileSizeBytes: fileSizeBytes,
          ),
          if (shouldShowCloudCard) ...[
            const SizedBox(height: 12),
            CloudMirrorsCard(
              links: post.cloudLinks,
              strings: strings,
              commentary: isTextOnly ? null : post.commentary,
              onPlayStream: (streamUrl) => launchUrl(
                Uri.parse(streamUrl),
                mode: LaunchMode.externalApplication,
              ),
              onDownloadStream: settings.allowDownloads
                  ? (streamUrl) => _downloadUrl(context, ref, post, streamUrl)
                  : null,
            ),
          ],
          if (feedPosts != null && feedPosts.length > 1) ...[
            const SizedBox(height: 12),
            _NeighborStrip(
              posts: feedPosts,
              currentIndex: feedPosts.indexWhere(
                (item) =>
                    item.providerId == post.providerId && item.id == post.id,
              ),
              onOpen: (p) => _openPost(context, p),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.70)
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.40),
                width: 1.1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              initiallyExpanded: false,
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Icon(
                Icons.tag_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                '${strings.tags} (${post.cleanTags.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: PostTagsPanel(post: post),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CommentsSection(post: post),
          const SizedBox(height: 24),
        ],
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

  Future<void> _download(BuildContext context, WidgetRef ref, Post post) async {
    if (!context.mounted) return;
    await ref.read(downloadManagerServiceProvider).start(post);
    if (!context.mounted) return;
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.ru ? 'Скачивание началось' : 'Download started'),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      ref.invalidate(downloadedMediaByKeyProvider(post.cacheKey));
    });
  }

  Future<void> _downloadUrl(
    BuildContext context,
    WidgetRef ref,
    Post post,
    String targetUrl,
  ) async {
    final customPost = post.copyWith(fileUrl: targetUrl, sampleUrl: targetUrl);
    await _download(context, ref, customPost);
  }

  Future<void> _sharePost(BuildContext context, WidgetRef ref, Post post) async {
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          strings.ru
              ? 'Подготовка файла к отправке...'
              : 'Preparing file for sharing...',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    try {
      final path =
          await ref.read(downloadServiceProvider).prepareFileForShare(post);
      await Share.shareXFiles([XFile(path)], text: post.source ?? post.fileUrl);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
    }
  }

  Future<void> _showMobileQuickActions(
    BuildContext context,
    WidgetRef ref,
    Post post,
    Set<String> favoriteKeys,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                favoriteKeys.contains(post.cacheKey)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
              title: Text(
                favoriteKeys.contains(post.cacheKey)
                    ? 'Remove favorite'
                    : 'Favorite',
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _toggleFavorite(ref, post, favoriteKeys);
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections_bookmark_rounded),
              title: const Text('Add to collection'),
              onTap: () {
                Navigator.pop(sheetContext);
                _addToCollection(context, ref, post);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy link'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: post.fileUrl));
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(sheetContext);
                _download(context, ref, post);
              },
            ),
          ],
        ),
      ),
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

  Future<void> _maybeAutoDownloadFavorite(WidgetRef ref, Post post) async {
    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    if (!settings.autoDownloadFavorites || !settings.allowDownloads) return;
    await ref.read(downloadManagerServiceProvider).start(post);
  }

  Future<void> _deleteLocalFile(
    BuildContext context,
    WidgetRef ref,
    Post post,
  ) async {
    final strings = ref.read(appStringsProvider);
    await ref.read(downloadedMediaServiceProvider).deleteLocalFile(
          post.cacheKey,
        );
    ref.invalidate(downloadedMediaByKeyProvider(post.cacheKey));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.deleteLocalFile)),
    );
  }

  PostActionLabels _postActionLabels(AppStrings strings) {
    return PostActionLabels(
      favorite: strings.favorite,
      unfavorite: strings.removeFavorite,
      collection: strings.collection,
      similar: strings.similar,
      openOriginal: strings.open,
      copyLink: strings.ru ? 'Копировать ссылку' : 'Copy link',
      download: strings.download,
      deleteLocalFile: strings.deleteLocalFile,
      hidePost: strings.hidePost,
      share: strings.ru ? 'Поделиться' : 'Share',
    );
  }

  Future<void> _hidePost(
    BuildContext context,
    WidgetRef ref,
    Post post,
  ) async {
    await ref.read(settingsServiceProvider).hidePostKey(post.cacheKey);
    ref.invalidate(appSettingsProvider);
    ref.read(feedControllerProvider.notifier).refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post hidden locally')),
    );
    _close(context);
  }

  void _openPost(BuildContext context, Post post) {
    _replacePost(context, post);
  }

  void _openSimilar(BuildContext context, WidgetRef ref, Post post) {
    context.push('/post/${post.providerId}/${post.id}/similar', extra: post);
  }

  Future<void> _openSourcePage(WidgetRef ref, Post post) async {
    final source = post.source?.trim();
    String? url = source != null && source.isNotEmpty ? source : null;
    if (url == null) {
      final result =
          await ref.read(providerManagerProvider).getPostPageUrl(post);
      if (result is Success<String?>) url = result.data;
    }
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url));
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

  Future<void> _saveVideoPreferences(
    WidgetRef ref,
    VideoPlaybackSnapshot snapshot,
  ) async {
    final result = await ref.read(settingsServiceProvider).getSettings();
    if (result is! Success<AppSettings>) return;
    final settings = result.data;
    if (settings.videoPlayerMuted == snapshot.muted &&
        settings.videoPlayerHalfVolume == snapshot.halfVolume &&
        settings.videoPlayerLoop == snapshot.loopVideo &&
        settings.videoPlayerCover == snapshot.coverVideo &&
        (settings.videoPlayerVolume - snapshot.volume).abs() < 0.01) {
      return;
    }
    await ref.read(settingsServiceProvider).updateSettings(
          settings.copyWith(
            videoPlayerMuted: snapshot.muted,
            videoPlayerHalfVolume: snapshot.halfVolume,
            videoPlayerLoop: snapshot.loopVideo,
            videoPlayerCover: snapshot.coverVideo,
            videoPlayerVolume: snapshot.volume,
          ),
        );
    ref.invalidate(appSettingsProvider);
  }

  Future<void> _saveVideoSnapshot(
    WidgetRef ref,
    Post post,
    VideoPlaybackSnapshot snapshot,
  ) async {
    await ref.read(settingsServiceProvider).saveVideoPlaybackPosition(
          post.cacheKey,
          snapshot.position.inMilliseconds,
        );
    ref.invalidate(appSettingsProvider);
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
  final Widget Function(
    BuildContext context,
    Post post,
    bool mediaGestureLocked,
    ValueChanged<bool> onMediaGestureLockChanged,
  ) buildDetails;

  @override
  State<_MobilePostPager> createState() => _MobilePostPagerState();
}

class _MobilePostPagerState extends State<_MobilePostPager> {
  late final PageController _controller;
  bool _mediaGestureLocked = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAround(widget.initialIndex);
    });
  }

  @override
  void didUpdateWidget(covariant _MobilePostPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Исправленная проверка: сравниваем старый и новый initialIndex, а не текущий свайп
    if (oldWidget.initialIndex != widget.initialIndex &&
        widget.initialIndex >= 0 &&
        widget.initialIndex < widget.posts.length) {
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
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: PageView.builder(
        controller: _controller,
        physics: _mediaGestureLocked
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: widget.posts.length,
        onPageChanged: (index) {
          _prefetchAround(index);
        },
        itemBuilder: (context, index) {
          final initialPost = widget.posts[index];
        return Consumer(
          builder: (context, ref, _) {
            final args = PostDetailsArgs(
              providerId: initialPost.providerId,
              postId: initialPost.id,
              initialPost: initialPost,
            );
            final post = ref.watch(postDetailsControllerProvider(args));
            return post.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(message: error.toString()),
              data: (resolvedPost) => _KeepAlivePostPage(
                child: KeyedSubtree(
                  key: ValueKey((resolvedPost ?? initialPost).cacheKey),
                  child: widget.buildDetails(
                    context,
                    resolvedPost ?? initialPost,
                    _mediaGestureLocked,
                    _setMediaGestureLocked,
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

  void _setMediaGestureLocked(bool locked) {
    if (_mediaGestureLocked == locked) return;
    setState(() => _mediaGestureLocked = locked);
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
    return const {
      'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
      'Accept': '*/*',
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
              duration: AppMotion.duration(context, 140),
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
    final strings = ref.watch(appStringsProvider);
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          Icons.chat_bubble_outline_rounded,
          color: scheme.primary,
        ),
        onExpansionChanged: (value) => setState(() => _expanded = value),
        title: Text(
          strings.comments,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        children: [
          (comments ?? const AsyncValue<List<PostComment>>.data([])).when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                strings.commentsUnavailable,
                style: TextStyle(color: scheme.outline),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    strings.noComments,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [
                  for (final comment in items)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: scheme.primaryContainer,
                            child: Text(
                              (comment.authorName.isNotEmpty
                                      ? comment.authorName[0]
                                      : '?')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.authorName.isEmpty
                                      ? strings.anonymous
                                      : comment.authorName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.body,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostInfoCard extends StatefulWidget {
  const _PostInfoCard({
    required this.post,
    required this.strings,
    this.localMedia,
    this.fileSizeBytes,
  });

  final Post post;
  final AppStrings strings;
  final DownloadedMedia? localMedia;
  final int? fileSizeBytes;

  @override
  State<_PostInfoCard> createState() => _PostInfoCardState();
}

class _PostInfoCardState extends State<_PostInfoCard> {
  // Lazily resolved dimensions (used when post.width/height == 0).
  int? _resolvedWidth;
  int? _resolvedHeight;
  bool _resolvingDimensions = false;

  static final _dimensionCache = <String, (int, int)>{};

  static bool _isImageType(String fileType) {
    const imageTypes = {'image', 'jpeg', 'jpg', 'png', 'gif', 'webp', 'avif'};
    return imageTypes.contains(fileType.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _maybeResolveDimensions();
  }

  @override
  void didUpdateWidget(_PostInfoCard old) {
    super.didUpdateWidget(old);
    if (old.post.fileUrl != widget.post.fileUrl) {
      _resolvedWidth = null;
      _resolvedHeight = null;
      _resolvingDimensions = false;
      _maybeResolveDimensions();
    }
  }

  void _maybeResolveDimensions() {
    final post = widget.post;
    // Only attempt lazy resolution when dimensions are unknown (0) and it's
    // an image (not video/link which we can't resolve this way).
    if (post.width != 0 || post.height != 0) return;
    if (!_isImageType(post.fileType)) return;
    final url = post.fileUrl.isNotEmpty ? post.fileUrl : post.sampleUrl;
    if (url.isEmpty) return;

    // Check cache first.
    if (_dimensionCache.containsKey(url)) {
      final cached = _dimensionCache[url]!;
      _resolvedWidth = cached.$1;
      _resolvedHeight = cached.$2;
      return;
    }

    if (_resolvingDimensions) return;
    _resolvingDimensions = true;

    final imageProvider = NetworkImage(url);
    final completer = imageProvider.resolve(ImageConfiguration.empty);
    completer.addListener(
      ImageStreamListener(
        (info, _) {
          final w = info.image.width;
          final h = info.image.height;
          _dimensionCache[url] = (w, h);
          if (mounted) {
            setState(() {
              _resolvedWidth = w;
              _resolvedHeight = h;
              _resolvingDimensions = false;
            });
          }
        },
        onError: (_, __) {
          if (mounted) setState(() => _resolvingDimensions = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final strings = widget.strings;
    final localMedia = widget.localMedia;
    final fileSizeBytes = widget.fileSizeBytes;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final artists = post.tagGroups['artist'] ??
        post.tags
            .where((t) => t.startsWith('artist:'))
            .map((t) => t.replaceFirst('artist:', ''))
            .toList();

    // Determine which dimensions to display.
    final displayWidth = post.width != 0 ? post.width : _resolvedWidth;
    final displayHeight = post.height != 0 ? post.height : _resolvedHeight;
    final hasDimensions = displayWidth != null && displayHeight != null;
    final dimensionLabel = hasDimensions
        ? '$displayWidth × $displayHeight'
        : (_resolvingDimensions ? '… × …' : null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist / Provider Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primaryContainer, scheme.tertiaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    artists.isNotEmpty
                        ? Icons.palette_rounded
                        : Icons.hub_rounded,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (artists.isNotEmpty)
                      InkWell(
                        onTap: () {
                          context.push(
                            '/search?q=${Uri.encodeComponent('artist:${artists.first}')}',
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Text(
                          artists.join(', '),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      Text(
                        strings.ru ? 'Автор не указан' : 'Unknown Artist',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          post.providerName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                        Text(
                          _formatPostDate(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (localMedia != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_pin_rounded,
                        size: 14,
                        color: scheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fileSizeBytes != null && fileSizeBytes > 0
                            ? DownloadedMediaService.formatBytes(fileSizeBytes)
                            : (strings.ru ? 'Офлайн' : 'Offline'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Metadata Spec Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (dimensionLabel != null)
                _SpecBadge(
                  icon: Icons.aspect_ratio_rounded,
                  label: dimensionLabel,
                ),
              if (post.fileType.isNotEmpty)
                _SpecBadge(
                  icon: Icons.insert_drive_file_outlined,
                  label: post.fileType.toUpperCase(),
                ),
              RatingBadge(rating: post.rating),
              if (post.score != 0)
                _SpecBadge(
                  icon: Icons.star_rounded,
                  label: '${post.score}',
                  iconColor: Colors.amber,
                ),
              if (post.source != null && post.source!.isNotEmpty)
                InkWell(
                  onTap: () => launchUrl(Uri.parse(post.source!)),
                  borderRadius: BorderRadius.circular(10),
                  child: _SpecBadge(
                    icon: Icons.open_in_new_rounded,
                    label: strings.source,
                    color: scheme.surfaceContainerHigh,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatPostDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _SpecBadge extends StatelessWidget {
  const _SpecBadge({
    required this.icon,
    required this.label,
    this.iconColor,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
