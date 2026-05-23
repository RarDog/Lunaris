import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../backend/backend.dart';

class PostMediaViewer extends StatefulWidget {
  const PostMediaViewer({
    required this.post,
    this.fullscreen = false,
    this.initialPosition = Duration.zero,
    this.autoplay = false,
    this.initialLoop = false,
    this.initialMuted = false,
    this.initialCoverVideo = false,
    super.key,
  });

  final Post post;
  final bool fullscreen;
  final Duration initialPosition;
  final bool autoplay;
  final bool initialLoop;
  final bool initialMuted;
  final bool initialCoverVideo;

  @override
  State<PostMediaViewer> createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer> {
  Player? _player;
  VideoController? _controller;
  late List<String> _imageUrls;
  late List<String> _videoUrls;
  int _imageIndex = 0;
  int _videoIndex = 0;
  bool _controlsVisible = true;
  late bool _coverVideo;
  late bool _muted;
  late bool _loopVideo;
  String? _videoError;
  Timer? _hideTimer;
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _coverVideo = widget.initialCoverVideo;
    _muted = widget.initialMuted;
    _loopVideo = widget.initialLoop;
    _imageUrls = _buildImageUrls(widget.post);
    _videoUrls = _buildVideoUrls(widget.post);
    if (_isVideo(widget.post) && _videoUrls.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(covariant PostMediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.cacheKey != widget.post.cacheKey) {
      _disposeVideo();
      _imageIndex = 0;
      _videoIndex = 0;
      _videoError = null;
      _imageUrls = _buildImageUrls(widget.post);
      _videoUrls = _buildVideoUrls(widget.post);
      if (_isVideo(widget.post) && _videoUrls.isNotEmpty) {
        _initializeVideo();
      }
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return _VideoSurface(
        player: _player!,
        controller: _controller!,
        aspectRatio: widget.post.width > 0 && widget.post.height > 0
            ? widget.post.width / widget.post.height
            : 16 / 9,
        controlsVisible: _controlsVisible,
        coverVideo: _coverVideo,
        muted: _muted,
        loopVideo: _loopVideo,
        fullscreen: widget.fullscreen,
        errorMessage: _videoError,
        onInteract: _showControls,
        onRetry: _retryVideo,
        onToggleFit: () {
          setState(() => _coverVideo = !_coverVideo);
          _showControls();
        },
        onToggleMute: () async {
          final nextMuted = !_muted;
          setState(() => _muted = nextMuted);
          await _player!.setVolume(nextMuted ? 0 : 100);
          _showControls();
        },
        onToggleLoop: () async {
          final nextLoop = !_loopVideo;
          setState(() => _loopVideo = nextLoop);
          await _player!.setPlaylistMode(
            nextLoop ? PlaylistMode.single : PlaylistMode.none,
          );
          _showControls();
        },
        onVolumeChanged: (value) async {
          setState(() => _muted = value <= 0);
          await _player!.setVolume(value);
          _showControls();
        },
        onFullscreen: widget.fullscreen
            ? () => Navigator.of(context).maybePop()
            : () => _openFullscreen(context),
      );
    }

    final url = _imageUrls.isEmpty ? '' : _imageUrls[_imageIndex];
    return InteractiveViewer(
      child: CachedNetworkImage(
        key: ValueKey(url),
        imageUrl: url,
        httpHeaders: _headersFor(widget.post),
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          if (_imageIndex < _imageUrls.length - 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _imageIndex++);
            });
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_rounded, size: 48),
                SizedBox(height: 8),
                Text('Could not load image'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _initializeVideo() {
    MediaKit.ensureInitialized();
    _player = Player();
    _controller = VideoController(_player!);
    _player!.setVolume(_muted ? 0 : 100);
    _player!.setPlaylistMode(
      _loopVideo ? PlaylistMode.single : PlaylistMode.none,
    );
    _errorSubscription = _player!.stream.error.listen((message) {
      if (!mounted) return;
      if (_videoIndex < _videoUrls.length - 1) {
        _videoIndex++;
        _openVideo(play: false);
        return;
      }
      setState(() => _videoError = message);
      _showControls();
    });
    _openVideo(play: widget.autoplay);
    _scheduleControlsHide();
  }

  Future<void> _openVideo({required bool play}) async {
    final player = _player;
    if (player == null || _videoUrls.isEmpty) return;
    setState(() => _videoError = null);
    await player.open(
      Media(
        _videoUrls[_videoIndex],
        httpHeaders: _headersFor(widget.post),
      ),
      play: play,
    );
    if (widget.initialPosition > Duration.zero) {
      await player.seek(widget.initialPosition);
    }
  }

  Future<void> _retryVideo() async {
    _videoIndex = 0;
    await _openVideo(play: true);
    _showControls();
  }

  void _disposeVideo() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _player?.dispose();
    _player = null;
    _controller = null;
  }

  List<String> _buildImageUrls(Post post) {
    return {
      post.sampleUrl,
      post.fileUrl,
      post.previewUrl,
    }.where((url) => url.trim().isNotEmpty).toList();
  }

  List<String> _buildVideoUrls(Post post) {
    return {
      post.fileUrl,
      if (_looksLikeVideoUrl(post.sampleUrl)) post.sampleUrl,
      if (_looksLikeVideoUrl(post.previewUrl)) post.previewUrl,
    }.where((url) => url.trim().isNotEmpty).toList();
  }

  bool _isVideo(Post post) {
    final value = '${post.fileType} ${post.fileUrl}'.toLowerCase();
    return value.contains('video') ||
        value.contains('.webm') ||
        value.contains('.mp4') ||
        value.contains('.mov');
  }

  bool _looksLikeVideoUrl(String url) {
    final value = url.toLowerCase();
    return value.contains('.webm') ||
        value.contains('.mp4') ||
        value.contains('.mov');
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

  void _showControls() {
    if (!mounted) return;
    setState(() => _controlsVisible = true);
    _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoError == null) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  Future<void> _openFullscreen(BuildContext context) async {
    final player = _player;
    final position = player?.state.position ?? Duration.zero;
    final wasPlaying = player?.state.playing ?? false;
    if (wasPlaying) await player?.pause();
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => _FullscreenVideoPage(
          post: widget.post,
          startAt: position,
          autoplay: wasPlaying,
          loopVideo: _loopVideo,
          muted: _muted,
          coverVideo: _coverVideo,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
    if (wasPlaying) await player?.play();
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.post,
    required this.startAt,
    required this.autoplay,
    required this.loopVideo,
    required this.muted,
    required this.coverVideo,
  });

  final Post post;
  final Duration startAt;
  final bool autoplay;
  final bool loopVideo;
  final bool muted;
  final bool coverVideo;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PostMediaViewer(
              post: widget.post,
              fullscreen: true,
              initialPosition: widget.startAt,
              autoplay: widget.autoplay,
              initialLoop: widget.loopVideo,
              initialMuted: widget.muted,
              initialCoverVideo: widget.coverVideo,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: IconButton.filledTonal(
                tooltip: 'Close fullscreen',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.player,
    required this.controller,
    required this.aspectRatio,
    required this.controlsVisible,
    required this.coverVideo,
    required this.muted,
    required this.loopVideo,
    required this.fullscreen,
    required this.errorMessage,
    required this.onInteract,
    required this.onRetry,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleLoop,
    required this.onVolumeChanged,
    required this.onFullscreen,
  });

  final Player player;
  final VideoController controller;
  final double aspectRatio;
  final bool controlsVisible;
  final bool coverVideo;
  final bool muted;
  final bool loopVideo;
  final bool fullscreen;
  final String? errorMessage;
  final VoidCallback onInteract;
  final VoidCallback onRetry;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLoop;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: Video(
            controller: controller,
            fit: coverVideo ? BoxFit.cover : BoxFit.contain,
            controls: null,
          ),
        ),
        StreamBuilder<bool>(
          stream: player.stream.buffering,
          initialData: player.state.buffering,
          builder: (context, snapshot) {
            if (snapshot.data != true || errorMessage != null) {
              return const SizedBox.shrink();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        if (errorMessage != null)
          _VideoErrorOverlay(message: errorMessage!, onRetry: onRetry),
        AnimatedOpacity(
          opacity: controlsVisible || errorMessage != null ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: _VideoControls(
            player: player,
            muted: muted,
            loopVideo: loopVideo,
            coverVideo: coverVideo,
            fullscreen: fullscreen,
            onToggleFit: onToggleFit,
            onToggleMute: onToggleMute,
            onToggleLoop: onToggleLoop,
            onVolumeChanged: onVolumeChanged,
            onFullscreen: onFullscreen,
          ),
        ),
      ],
    );

    return MouseRegion(
      onHover: (_) => onInteract(),
      child: GestureDetector(
        onTap: onInteract,
        onDoubleTap: onFullscreen,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(fullscreen ? 0 : 10),
          child: fullscreen
              ? SizedBox.expand(child: child)
              : AspectRatio(
                  aspectRatio: aspectRatio.clamp(0.35, 2.4),
                  child: child,
                ),
        ),
      ),
    );
  }
}

class _VideoErrorOverlay extends StatelessWidget {
  const _VideoErrorOverlay({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.62),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 42),
              const SizedBox(height: 10),
              Text(
                'Could not load video',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.player,
    required this.muted,
    required this.loopVideo,
    required this.coverVideo,
    required this.fullscreen,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleLoop,
    required this.onVolumeChanged,
    required this.onFullscreen,
  });

  final Player player;
  final bool muted;
  final bool loopVideo;
  final bool coverVideo;
  final bool fullscreen;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLoop;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.78),
            Colors.black.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(fullscreen ? 18 : 12),
          child: StreamBuilder<bool>(
            stream: player.stream.playing,
            initialData: player.state.playing,
            builder: (context, playingSnapshot) {
              final playing = playingSnapshot.data ?? false;
              return StreamBuilder<Duration>(
                stream: player.stream.duration,
                initialData: player.state.duration,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: player.stream.position,
                    initialData: player.state.position,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final maxMs =
                          duration.inMilliseconds.clamp(1, 1 << 31).toDouble();
                      final valueMs = position.inMilliseconds
                          .clamp(0, maxMs.toInt())
                          .toDouble();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 560;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (fullscreen)
                                StreamBuilder<double>(
                                  stream: player.stream.volume,
                                  initialData: player.state.volume,
                                  builder: (context, snapshot) {
                                    final volume =
                                        (snapshot.data ?? 100).clamp(0, 100);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            muted || volume <= 0
                                                ? Icons.volume_off_rounded
                                                : Icons.volume_up_rounded,
                                            color: Colors.white,
                                          ),
                                          Expanded(
                                            child: Slider(
                                              value: volume.toDouble(),
                                              max: 100,
                                              onChanged: onVolumeChanged,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 42,
                                            child: Text(
                                              '${volume.round()}%',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                ),
                                child: Slider(
                                  value: valueMs,
                                  max: maxMs,
                                  onChanged: duration == Duration.zero
                                      ? null
                                      : (value) => player.seek(
                                            Duration(
                                              milliseconds: value.round(),
                                            ),
                                          ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton.filled(
                                    tooltip: playing ? 'Pause' : 'Play',
                                    onPressed: player.playOrPause,
                                    icon: Icon(
                                      playing
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      '${_format(position)} / ${_format(duration)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!compact) ...[
                                    IconButton.filledTonal(
                                      tooltip: 'Back 10s',
                                      onPressed: () => player.seek(
                                        _clampSeek(
                                          position -
                                              const Duration(seconds: 10),
                                          duration,
                                        ),
                                      ),
                                      icon: const Icon(Icons.replay_10_rounded),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton.filledTonal(
                                      tooltip: 'Forward 10s',
                                      onPressed: () => player.seek(
                                        _clampSeek(
                                          position +
                                              const Duration(seconds: 10),
                                          duration,
                                        ),
                                      ),
                                      icon:
                                          const Icon(Icons.forward_10_rounded),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  IconButton.filledTonal(
                                    tooltip: loopVideo
                                        ? 'Disable repeat'
                                        : 'Repeat video',
                                    onPressed: onToggleLoop,
                                    icon: Icon(
                                      loopVideo
                                          ? Icons.repeat_one_on_rounded
                                          : Icons.repeat_one_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton.filledTonal(
                                    tooltip: muted ? 'Unmute' : 'Mute',
                                    onPressed: onToggleMute,
                                    icon: Icon(
                                      muted
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (!compact) ...[
                                    IconButton.filledTonal(
                                      tooltip: coverVideo ? 'Fit' : 'Fill',
                                      onPressed: onToggleFit,
                                      icon: Icon(
                                        coverVideo
                                            ? Icons.fit_screen_rounded
                                            : Icons.crop_free_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  IconButton.filledTonal(
                                    tooltip: fullscreen
                                        ? 'Exit fullscreen'
                                        : 'Fullscreen',
                                    onPressed: onFullscreen,
                                    icon: Icon(
                                      fullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  Duration _clampSeek(Duration position, Duration duration) {
    if (position < Duration.zero) return Duration.zero;
    if (duration > Duration.zero && position > duration) return duration;
    return position;
  }
}
