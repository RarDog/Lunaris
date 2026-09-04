import 'dart:async';
import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/motion.dart';
import '../../backend/backend.dart';
import '../../core/utils/result.dart';
import 'blur_content.dart';
import 'loading_skeleton.dart';
import 'rating_badge.dart';

class PostCard extends ConsumerStatefulWidget {
  const PostCard({
    required this.post,
    required this.blurExplicit,
    required this.showBadges,
    required this.isFavorite,
    required this.isViewed,
    required this.isDownloaded,
    required this.mediaQualityMode,
    required this.onOpen,
    required this.onFavorite,
    this.onAddToCollection,
    this.onPreview,
    this.onHide,
    this.onToggleSelected,
    this.selectionMode = false,
    this.selected = false,
    super.key,
  });

  final Post post;
  final bool blurExplicit;
  final bool showBadges;
  final bool isFavorite;
  final bool isViewed;
  final bool isDownloaded;
  final MediaQualityMode mediaQualityMode;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onPreview;
  final VoidCallback? onHide;
  final VoidCallback? onToggleSelected;
  final bool selectionMode;
  final bool selected;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  static final Map<String, Post> _resolvedRealbooruPosts = {};

  bool _hovered = false;
  Post? _resolvedPost;
  bool _showHeart = false;
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;
  late final Animation<double> _heartOpacity;

  @override
  void initState() {
    super.initState();
    _resolvedPost = _resolvedRealbooruPosts[widget.post.cacheKey];
    _maybeResolveRealbooruPost();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.0), weight: 30),
    ]).animate(_heartController);
    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40),
    ]).animate(_heartController);
    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showHeart = false);
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _triggerDoubleTapFavorite() {
    widget.onFavorite();
    setState(() => _showHeart = true);
    _heartController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final post = _resolvedPost ?? widget.post;
    final sensitive = _isSensitive(post.rating);
    final aspect = post.width > 0 && post.height > 0
        ? post.width / post.height
        : _fallbackAspect(post.fileType);
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final urls = _feedUrls(post, mobile: mobile);
    final imageUrl = urls.isEmpty ? post.previewUrl : urls.first;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.selectionMode) {
            widget.onToggleSelected?.call();
            return;
          }
          widget.onOpen();
        },
        onDoubleTap: _triggerDoubleTapFavorite,
        onLongPress: () {
          if (widget.selectionMode && widget.onToggleSelected != null) {
            widget.onToggleSelected!();
            return;
          }
          if (widget.onPreview != null) {
            widget.onPreview!();
            return;
          }
          widget.onToggleSelected?.call();
        },
        onSecondaryTapDown: (details) {
          showMenu<void>(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: [
              PopupMenuItem(
                onTap: widget.onOpen,
                child: const Text('Open'),
              ),
              PopupMenuItem(
                onTap: widget.onFavorite,
                child: const Text('Favorite'),
              ),
              if (widget.onAddToCollection != null)
                PopupMenuItem(
                  onTap: widget.onAddToCollection,
                  child: const Text('Add to collection'),
                ),
              if (widget.onHide != null)
                PopupMenuItem(
                  onTap: widget.onHide,
                  child: const Text('Hide post'),
                ),
            ],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.2),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: aspect.clamp(0.28, 2.2),
                  child: BlurContent(
                    enabled: widget.blurExplicit && sensitive,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final dpr = MediaQuery.devicePixelRatioOf(context);
                        final cacheWidth =
                            (constraints.maxWidth * dpr).round().clamp(320, 1800);
                        final headers = _headersFor(post);
                        final videoUrls = MediaUrlSelector.video(post);
                        if (!mobile &&
                            _hovered &&
                            _resolvedPost != null &&
                            MediaUrlSelector.isVideo(post) &&
                            videoUrls.isNotEmpty) {
                          return _FeedVideoPreview(
                            videoUrl: videoUrls.first,
                            headers: headers,
                            fallbackImageUrl: imageUrl,
                            cacheWidth: cacheWidth,
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          httpHeaders: headers,
                          memCacheWidth: cacheWidth,
                          maxWidthDiskCache: cacheWidth,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const LoadingSkeleton(),
                          errorWidget: (context, url, error) => ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bottom cinematic gradient overlay for badges and favorite
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.72),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showBadges) ...[
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _ProviderBadge(name: post.providerName),
                  ),
                  if (post.fileType.toLowerCase().contains('video') ||
                      post.fileType.toLowerCase().contains('webm') ||
                      post.fileType.toLowerCase().contains('mp4') ||
                      post.fileType.toLowerCase().contains('gif'))
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _MediaBadge(fileType: post.fileType),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isViewed || widget.isDownloaded) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.isViewed) const _SeenBadge(),
                              if (widget.isViewed && widget.isDownloaded)
                                const SizedBox(width: 4),
                              if (widget.isDownloaded)
                                const _DownloadedBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        RatingBadge(rating: post.rating),
                      ],
                    ),
                  ),
                ],
                if (widget.selected)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.24),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.check_circle_rounded),
                        ),
                      ),
                    ),
                  ),
                if (mobile)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _FavoriteButton(
                      isFavorite: widget.isFavorite,
                      onPressed: widget.onFavorite,
                    ),
                  ),
              // Double-tap heart animation overlay
              if (_showHeart)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, _) => Opacity(
                        opacity: _heartOpacity.value,
                        child: Transform.scale(
                          scale: _heartScale.value,
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 72,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_hovered || mobile,
                  child: AnimatedOpacity(
                    opacity: _hovered && !mobile ? 1 : 0,
                    duration: AppMotion.duration(context, 140),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filledTonal(
                                tooltip: widget.isFavorite
                                    ? 'Remove favorite'
                                    : 'Favorite',
                                onPressed: widget.onFavorite,
                                icon: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                tooltip: 'Add to collection',
                                onPressed: widget.onAddToCollection,
                                icon: const Icon(Icons.add_rounded),
                              ),
                              if (widget.onHide != null) ...[
                                const SizedBox(width: 6),
                                IconButton.filledTonal(
                                  tooltip: 'Hide post',
                                  onPressed: widget.onHide,
                                  icon:
                                      const Icon(Icons.visibility_off_rounded),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
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

  bool _isSensitive(String rating) {
    final normalized = rating.toLowerCase();
    return normalized.startsWith('e') ||
        normalized.startsWith('q') ||
        normalized.contains('explicit') ||
        normalized.contains('questionable');
  }

  double _fallbackAspect(String fileType) {
    final normalized = fileType.toLowerCase();
    if (normalized.contains('video') || normalized.contains('webm')) {
      return 16 / 9;
    }
    if (normalized.contains('gif')) return 1;
    return 0.72;
  }

  List<String> _feedUrls(Post post, {required bool mobile}) {
    if ((post.providerId == 'realbooru' || post.providerId == 'paheal') &&
        !MediaUrlSelector.isVideo(post)) {
      return [
        post.sampleUrl,
        post.fileUrl,
        post.previewUrl,
      ].where((url) => url.trim().isNotEmpty).toSet().toList(growable: false);
    }
    return MediaUrlSelector.feed(
      post,
      mode: widget.mediaQualityMode,
      mobile: mobile,
    );
  }

  Map<String, String> _headersFor(Post post) {
    final lower = '${post.providerId} ${post.providerName} '
            '${post.previewUrl} ${post.sampleUrl} ${post.fileUrl}'
        .toLowerCase();
    return {
      'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
      'Accept': '*/*',
      if (lower.contains('gelbooru')) 'Referer': 'https://gelbooru.com/',
      if (lower.contains('realbooru'))
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/125 Mobile Safari/537.36',
      if (lower.contains('realbooru'))
        'Accept':
            'video/webm,video/mp4,image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      if (lower.contains('realbooru'))
        'Referer':
            'https://realbooru.com/index.php?page=post&s=view&id=${post.id}',
      if (lower.contains('paheal'))
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/125 Mobile Safari/537.36',
      if (lower.contains('paheal'))
        'Accept':
            'video/webm,video/mp4,image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      if (lower.contains('paheal'))
        'Referer': 'https://rule34.paheal.net/post/view/${post.id}',
      if (lower.contains('rule34') && !lower.contains('paheal'))
        'Referer': 'https://rule34.xxx/',
    };
  }

  void _maybeResolveRealbooruPost() {
    final post = widget.post;
    if (!_needsRealbooruDetails(post) ||
        _resolvedRealbooruPosts.containsKey(post.cacheKey)) {
      return;
    }
    Future<void>(() async {
      final result = await ref
          .read(providerManagerProvider)
          .getPost(post.providerId, post.id);
      if (!mounted) return;
      if (result is Success<Post?> && result.data != null) {
        final resolved = result.data!;
        _resolvedRealbooruPosts[post.cacheKey] = resolved;
        setState(() => _resolvedPost = resolved);
      }
    });
  }

  bool _needsRealbooruDetails(Post post) {
    if (post.providerId != 'realbooru') return false;
    final preview = post.previewUrl.toLowerCase();
    final sample = post.sampleUrl.toLowerCase();
    return post.fileUrl.isEmpty ||
        post.fileUrl == post.previewUrl ||
        post.fileUrl == post.sampleUrl ||
        preview.contains('/thumbnails/') ||
        sample.contains('/thumbnails/');
  }
}

class _FeedVideoPreview extends StatefulWidget {
  const _FeedVideoPreview({
    required this.videoUrl,
    required this.headers,
    required this.fallbackImageUrl,
    required this.cacheWidth,
  });

  final String videoUrl;
  final Map<String, String> headers;
  final String fallbackImageUrl;
  final int cacheWidth;

  @override
  State<_FeedVideoPreview> createState() => _FeedVideoPreviewState();
}

class _FeedVideoPreviewState extends State<_FeedVideoPreview> {
  late final Player _player;
  late final VideoController _controller;
  bool _failed = false;
  bool _ready = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
    _player = Player();
    _controller = VideoController(_player);
    _player.stream.error.listen((_) {
      if (mounted) setState(() => _failed = true);
    });
    _open();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _open();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = CachedNetworkImage(
      imageUrl: widget.fallbackImageUrl,
      httpHeaders: widget.headers,
      memCacheWidth: widget.cacheWidth,
      maxWidthDiskCache: widget.cacheWidth,
      fit: BoxFit.cover,
      placeholder: (context, url) => const LoadingSkeleton(),
      errorWidget: (context, url, error) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.videocam_off_rounded)),
      ),
    );
    if (_failed) return fallback;
    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        AnimatedOpacity(
          opacity: _ready ? 1 : 0,
          duration: AppMotion.duration(context, 180),
          child: ColoredBox(
            color: Colors.black,
            child: Video(
              controller: _controller,
              fit: BoxFit.cover,
              controls: null,
              pauseUponEnteringBackgroundMode: false,
              resumeUponEnteringForegroundMode: false,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _open() async {
    final requestId = ++_requestId;
    if (mounted) {
      setState(() {
        _failed = false;
        _ready = false;
      });
    }
    try {
      await _VideoPreviewOpenQueue.run(() async {
        if (!mounted || requestId != _requestId) return;
        await _player.stop();
        await _player
            .open(
              Media(widget.videoUrl, httpHeaders: widget.headers),
              play: false,
            )
            .timeout(const Duration(seconds: 8));
        if (!mounted || requestId != _requestId) return;
        await _player
            .seek(const Duration(milliseconds: 300))
            .timeout(const Duration(seconds: 3));
        await _player.pause();
      });
      if (!mounted || requestId != _requestId) return;
      setState(() => _ready = true);
    } catch (_) {
      if (mounted && requestId == _requestId) {
        setState(() => _failed = true);
      }
    }
  }
}

class _VideoPreviewOpenQueue {
  static const int _maxConcurrent = 2;
  static final Queue<Future<void> Function()> _pending = Queue();
  static int _active = 0;

  static Future<void> run(Future<void> Function() task) {
    final completer = Completer<void>();
    _pending.add(() async {
      try {
        await task();
        if (!completer.isCompleted) completer.complete();
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });
    _pump();
    return completer.future;
  }

  static void _pump() {
    while (_active < _maxConcurrent && _pending.isNotEmpty) {
      final job = _pending.removeFirst();
      _active++;
      unawaited(
        job().whenComplete(() {
          _active--;
          _pump();
        }),
      );
    }
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 20,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          shape: BoxShape.circle,
          border: Border.all(
            color: isFavorite
                ? Colors.redAccent.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.16),
            width: 0.9,
          ),
          boxShadow: [
            if (isFavorite)
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.35),
                blurRadius: 10,
              ),
          ],
        ),
        child: Center(
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.redAccent : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  const _MediaBadge({required this.fileType});

  final String fileType;

  @override
  Widget build(BuildContext context) {
    final type = _type(fileType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(type), size: 13, color: Colors.white),
          const SizedBox(width: 3.5),
          Text(
            type,
            style: const TextStyle(
              fontSize: 10.5,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _type(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('video') ||
        value.contains('webm') ||
        value.contains('mp4')) {
      return 'video';
    }
    if (value.contains('gif')) return 'gif';
    return 'photo';
  }

  IconData _icon(String type) => switch (type) {
        'video' => Icons.play_arrow_rounded,
        'gif' => Icons.gif_box_rounded,
        _ => Icons.image_rounded,
      };
}

class _SeenBadge extends StatelessWidget {
  const _SeenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_rounded, size: 12, color: Colors.white70),
          SizedBox(width: 3.5),
          Text(
            'seen',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadedBadge extends StatelessWidget {
  const _DownloadedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.7,
        ),
      ),
      child: const Icon(
        Icons.download_done_rounded,
        size: 13,
        color: Colors.white,
      ),
    );
  }
}

Future<void> showAddToCollectionPicker(
  BuildContext context, {
  required List<Collection> collections,
  required void Function(Collection collection) onSelected,
  required VoidCallback onCreate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.add_rounded),
          title: const Text('Create collection'),
          onTap: () {
            Navigator.pop(context);
            onCreate();
          },
        ),
        for (final collection in collections)
          ListTile(
            title: Text(collection.name),
            subtitle: Text(collection.description ?? ''),
            onTap: () {
              Navigator.pop(context);
              onSelected(collection);
            },
          ),
      ],
    ),
  );
}
