import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../app/motion.dart';
import '../../../../backend/backend.dart';

final Map<String, VideoPlaybackSnapshot> _playbackMemory =
    <String, VideoPlaybackSnapshot>{};

class PostMediaViewer extends StatefulWidget {
  const PostMediaViewer({
    required this.post,
    this.fullscreen = false,
    this.initialPosition = Duration.zero,
    this.autoplay = false,
    this.initialLoop = false,
    this.initialMuted = false,
    this.initialCoverVideo = false,
    this.initialHalfVolume = false,
    this.qualityMode = MediaQualityMode.auto,
    this.mediaHeaders = const {},
    this.onPlaybackSnapshot,
    this.onPlaybackPreferencesChanged,
    this.onMediaGestureLockChanged,
    super.key,
  });

  final Post post;
  final bool fullscreen;
  final Duration initialPosition;
  final bool autoplay;
  final bool initialLoop;
  final bool initialMuted;
  final bool initialCoverVideo;
  final bool initialHalfVolume;
  final MediaQualityMode qualityMode;
  final Map<String, String> mediaHeaders;
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackSnapshot;
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackPreferencesChanged;
  final ValueChanged<bool>? onMediaGestureLockChanged;

  @override
  State<PostMediaViewer> createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer>
    with AutomaticKeepAliveClientMixin {
  Player? _player;
  VideoController? _controller;
  late List<String> _imageUrls;
  late List<String> _videoUrls;
  int _imageIndex = 0;
  int _videoIndex = 0;
  bool _controlsVisible = true;
  bool _inFullscreen = false;
  late bool _coverVideo;
  late bool _muted;
  late bool _loopVideo;
  late bool _halfVolume;
  String? _videoError;
  Timer? _hideTimer;
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  DateTime? _lastSnapshotEmitAt;

  @override
  void initState() {
    super.initState();
    _coverVideo = widget.initialCoverVideo;
    _muted = widget.initialMuted;
    _loopVideo = widget.initialLoop;
    _halfVolume = widget.initialHalfVolume;
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isSwf(widget.post)) {
      return const _UnsupportedSwfPanel();
    }

    if (_controller != null) {
      if (_inFullscreen) {
        return ColoredBox(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: widget.post.width > 0 && widget.post.height > 0
                ? (widget.post.width / widget.post.height).clamp(0.35, 2.4)
                : 16 / 9,
            child: const Center(
              child: Icon(Icons.fullscreen_rounded, color: Colors.white38),
            ),
          ),
        );
      }
      return Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.space): const _TogglePlayIntent(),
        },
        child: Actions(
          actions: {
            _TogglePlayIntent: CallbackAction<_TogglePlayIntent>(
              onInvoke: (_) {
                _togglePlay();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: _VideoSurface(
              player: _player!,
              controller: _controller!,
              aspectRatio: widget.post.width > 0 && widget.post.height > 0
                  ? widget.post.width / widget.post.height
                  : 16 / 9,
              controlsVisible: _controlsVisible,
              coverVideo: _coverVideo,
              muted: _muted,
              loopVideo: _loopVideo,
              halfVolume: _halfVolume,
              fullscreen: widget.fullscreen,
              errorMessage: _videoError,
              onInteract: _showControls,
              onRetry: _retryVideo,
              onToggleFit: () {
                setState(() => _coverVideo = !_coverVideo);
                _emitPlaybackPreferences();
                _showControls();
              },
              onToggleMute: () async {
                final nextMuted = !_muted;
                setState(() => _muted = nextMuted);
                await _applyVolume();
                _emitPlaybackPreferences();
                _showControls();
              },
              onToggleHalfVolume: () async {
                setState(() {
                  _halfVolume = !_halfVolume;
                  if (_halfVolume) _muted = false;
                });
                await _applyVolume();
                _emitPlaybackPreferences();
                _showControls();
              },
              onToggleLoop: () async {
                final nextLoop = !_loopVideo;
                setState(() => _loopVideo = nextLoop);
                await _player!.setPlaylistMode(
                  nextLoop ? PlaylistMode.single : PlaylistMode.none,
                );
                _emitPlaybackPreferences();
                _showControls();
              },
              onFullscreen: widget.fullscreen
                  ? () => Navigator.of(context, rootNavigator: true)
                      .pop(_snapshot())
                  : () => _openFullscreen(context),
            ),
          ),
        ),
      );
    }

    final url = _imageUrls.isEmpty ? '' : _imageUrls[_imageIndex];
    final headers = _headersFor(widget.post);
    final image = CachedNetworkImage(
      key: ValueKey(url),
      imageUrl: url,
      httpHeaders: headers,
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        return _DioImageFallback(
          imageUrl: url,
          headers: headers,
          fit: BoxFit.contain,
          onFailed: _advanceImageFallback,
        );
      },
    );
    final allowPinchZoom = MediaQuery.sizeOf(context).width < 700;
    final child = allowPinchZoom
        ? _ZoomableImage(
            onGestureLockChanged: widget.onMediaGestureLockChanged,
            child: image,
          )
        : image;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: child,
          );
        }
        return child;
      },
    );
  }

  void _initializeVideo() {
    MediaKit.ensureInitialized();
    _player = Player();
    _controller = VideoController(_player!);
    _applyVolume();
    _player!.setPlaylistMode(
      _loopVideo ? PlaylistMode.single : PlaylistMode.none,
    );
    _errorSubscription = _player!.stream.error.listen((message) {
      if (!mounted) return;
      unawaited(_handleVideoError(message));
    });
    _positionSubscription = _player!.stream.position.listen((_) {
      final snapshot = _snapshot();
      _playbackMemory[widget.post.cacheKey] = snapshot;
      _emitPlaybackSnapshotThrottled(snapshot);
    });
    _playingSubscription = _player!.stream.playing.listen((_) {
      final snapshot = _snapshot();
      _playbackMemory[widget.post.cacheKey] = snapshot;
      widget.onPlaybackSnapshot?.call(snapshot);
    });
    _openVideo(play: widget.autoplay);
    _scheduleControlsHide();
  }

  Future<void> _openVideo({required bool play}) async {
    final player = _player;
    if (player == null || _videoUrls.isEmpty) return;
    final remembered = _playbackMemory[widget.post.cacheKey];
    final initialPosition = widget.initialPosition > Duration.zero
        ? widget.initialPosition
        : remembered?.position ?? Duration.zero;
    final shouldPlay = play || (remembered?.playing ?? false);
    try {
      setState(() => _videoError = null);
      await player.stop();
      await player.open(
        Media(
          _videoUrls[_videoIndex],
          httpHeaders: _headersFor(widget.post),
        ),
        play: false,
      );
      if (initialPosition > Duration.zero) {
        await player.seek(initialPosition);
      }
      if (shouldPlay) await player.play();
    } catch (error) {
      await _handleVideoError(error.toString(), play: shouldPlay);
    }
  }

  Future<void> _handleVideoError(String message, {bool play = false}) async {
    if (_videoIndex < _videoUrls.length - 1) {
      _videoIndex++;
      await _openVideo(play: play);
      return;
    }
    if (!mounted) return;
    setState(() => _videoError = message);
    _showControls();
  }

  Future<void> _retryVideo() async {
    final player = _player;
    if (player == null) return;
    setState(() {
      _videoError = null;
      _videoIndex = 0;
      _controlsVisible = true;
    });
    await player.stop();
    await _openVideo(play: true);
    _showControls();
  }

  void _disposeVideo() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _playingSubscription?.cancel();
    _playingSubscription = null;
    final snapshot = _snapshot();
    _playbackMemory[widget.post.cacheKey] = snapshot;
    widget.onPlaybackSnapshot?.call(snapshot);
    _player?.dispose();
    _player = null;
    _controller = null;
  }

  List<String> _buildImageUrls(Post post) {
    return MediaUrlSelector.details(post, mode: widget.qualityMode);
  }

  List<String> _buildVideoUrls(Post post) {
    return MediaUrlSelector.video(post);
  }

  bool _isVideo(Post post) {
    final value = '${post.fileType} ${post.fileUrl}'.toLowerCase();
    return value.contains('video') ||
        value.contains('.webm') ||
        value.contains('.mp4') ||
        value.contains('.mov');
  }

  bool _isSwf(Post post) {
    final value =
        '${post.fileType} ${post.fileUrl} ${post.sampleUrl} ${post.source ?? ''}'
            .toLowerCase();
    return value.contains('swf') || value.contains('.swf');
  }

  Map<String, String> _headersFor(Post post) {
    return {
      'User-Agent': 'Lunaris/2.0.1 Flutter local booru browser',
      'Accept': '*/*',
      ...widget.mediaHeaders,
    };
  }

  void _advanceImageFallback() {
    if (_imageIndex >= _imageUrls.length - 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _imageIndex++);
    });
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
    final controller = _controller;
    if (player == null || controller == null) return;
    setState(() => _inFullscreen = true);
    if (!context.mounted) return;
    final result = await Navigator.of(context, rootNavigator: true)
        .push<VideoPlaybackSnapshot>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => _FullscreenVideoPage(
          player: player,
          controller: controller,
          aspectRatio: widget.post.width > 0 && widget.post.height > 0
              ? widget.post.width / widget.post.height
              : 16 / 9,
          loopVideo: _loopVideo,
          muted: _muted,
          halfVolume: _halfVolume,
          coverVideo: _coverVideo,
          errorMessage: _videoError,
          onRetry: _retryVideo,
          onChanged: (snapshot) {
            unawaited(_applyPlaybackSnapshot(snapshot));
          },
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
    if (mounted) setState(() => _inFullscreen = false);
    if (result != null) {
      await _applyPlaybackSnapshot(result);
      return;
    }
  }

  Future<void> _applyPlaybackSnapshot(VideoPlaybackSnapshot snapshot) async {
    if (!mounted) return;
    setState(() {
      _muted = snapshot.muted;
      _loopVideo = snapshot.loopVideo;
      _coverVideo = snapshot.coverVideo;
      _halfVolume = snapshot.halfVolume;
    });
    await _applyVolume();
    await _player?.setPlaylistMode(
      _loopVideo ? PlaylistMode.single : PlaylistMode.none,
    );
    _emitPlaybackPreferences();
  }

  VideoPlaybackSnapshot _snapshot() {
    final player = _player;
    return VideoPlaybackSnapshot(
      position: player?.state.position ?? Duration.zero,
      playing: player?.state.playing ?? false,
      muted: _muted,
      halfVolume: _halfVolume,
      loopVideo: _loopVideo,
      coverVideo: _coverVideo,
    );
  }

  Future<void> _applyVolume() async {
    await _player?.setVolume(_muted
        ? 0
        : _halfVolume
            ? 50
            : 100);
  }

  void _emitPlaybackPreferences() {
    final snapshot = _snapshot();
    _playbackMemory[widget.post.cacheKey] = snapshot;
    widget.onPlaybackPreferencesChanged?.call(snapshot);
  }

  void _emitPlaybackSnapshotThrottled(VideoPlaybackSnapshot snapshot) {
    final now = DateTime.now();
    final last = _lastSnapshotEmitAt;
    if (last != null && now.difference(last) < const Duration(seconds: 5)) {
      return;
    }
    _lastSnapshotEmitAt = now;
    widget.onPlaybackSnapshot?.call(snapshot);
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null) return;
    if (player.state.playing) {
      await player.pause();
    } else {
      await player.play();
    }
    _showControls();
  }
}

class _TogglePlayIntent extends Intent {
  const _TogglePlayIntent();
}

class _UnsupportedSwfPanel extends StatelessWidget {
  const _UnsupportedSwfPanel();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.extension_off_rounded, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text(
                'SWF / Flash is not supported in this build',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlaybackSnapshot {
  const VideoPlaybackSnapshot({
    required this.position,
    required this.playing,
    required this.muted,
    required this.halfVolume,
    required this.loopVideo,
    required this.coverVideo,
  });

  final Duration position;
  final bool playing;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final bool coverVideo;
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.player,
    required this.controller,
    required this.aspectRatio,
    required this.loopVideo,
    required this.muted,
    required this.halfVolume,
    required this.coverVideo,
    required this.errorMessage,
    required this.onRetry,
    required this.onChanged,
  });

  final Player player;
  final VideoController controller;
  final double aspectRatio;
  final bool loopVideo;
  final bool muted;
  final bool halfVolume;
  final bool coverVideo;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<VideoPlaybackSnapshot> onChanged;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _controlsVisible = true;
  late bool _coverVideo;
  late bool _muted;
  late bool _loopVideo;
  late bool _halfVolume;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _coverVideo = widget.coverVideo;
    _muted = widget.muted;
    _loopVideo = widget.loopVideo;
    _halfVolume = widget.halfVolume;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _scheduleControlsHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context, rootNavigator: true).pop(_snapshot());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.escape): const _CloseVideoIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): const _TogglePlayIntent(),
          },
          child: Actions(
            actions: {
              _CloseVideoIntent: CallbackAction<_CloseVideoIntent>(
                onInvoke: (_) {
                  Navigator.of(context, rootNavigator: true).pop(_snapshot());
                  return null;
                },
              ),
              _TogglePlayIntent: CallbackAction<_TogglePlayIntent>(
                onInvoke: (_) {
                  widget.player.playOrPause();
                  _showControls();
                  return null;
                },
              ),
            },
            child: Focus(
              autofocus: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _VideoSurface(
                      player: widget.player,
                      controller: widget.controller,
                      aspectRatio: widget.aspectRatio,
                      controlsVisible: _controlsVisible,
                      coverVideo: _coverVideo,
                      muted: _muted,
                      loopVideo: _loopVideo,
                      halfVolume: _halfVolume,
                      fullscreen: true,
                      errorMessage: widget.errorMessage,
                      onInteract: _showControls,
                      onRetry: widget.onRetry,
                      onToggleFit: () {
                        setState(() => _coverVideo = !_coverVideo);
                        widget.onChanged(_snapshot());
                        _showControls();
                      },
                      onToggleMute: () async {
                        setState(() => _muted = !_muted);
                        await _applyVolume();
                        widget.onChanged(_snapshot());
                        _showControls();
                      },
                      onToggleHalfVolume: () async {
                        setState(() {
                          _halfVolume = !_halfVolume;
                          if (_halfVolume) _muted = false;
                        });
                        await _applyVolume();
                        widget.onChanged(_snapshot());
                        _showControls();
                      },
                      onToggleLoop: () async {
                        setState(() => _loopVideo = !_loopVideo);
                        await widget.player.setPlaylistMode(
                          _loopVideo ? PlaylistMode.single : PlaylistMode.none,
                        );
                        widget.onChanged(_snapshot());
                        _showControls();
                      },
                      onFullscreen: () => Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pop(_snapshot()),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: SafeArea(
                      child: IconButton.filledTonal(
                        tooltip: 'Close fullscreen',
                        onPressed: () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(_snapshot()),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showControls() {
    if (!mounted) return;
    setState(() => _controlsVisible = true);
    _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.errorMessage == null) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  Future<void> _applyVolume() async {
    await widget.player.setVolume(_muted
        ? 0
        : _halfVolume
            ? 50
            : 100);
  }

  VideoPlaybackSnapshot _snapshot() {
    return VideoPlaybackSnapshot(
      position: widget.player.state.position,
      playing: widget.player.state.playing,
      muted: _muted,
      halfVolume: _halfVolume,
      loopVideo: _loopVideo,
      coverVideo: _coverVideo,
    );
  }
}

class _CloseVideoIntent extends Intent {
  const _CloseVideoIntent();
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.player,
    required this.controller,
    required this.aspectRatio,
    required this.controlsVisible,
    required this.coverVideo,
    required this.muted,
    required this.halfVolume,
    required this.loopVideo,
    required this.fullscreen,
    required this.errorMessage,
    required this.onInteract,
    required this.onRetry,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleHalfVolume,
    required this.onToggleLoop,
    required this.onFullscreen,
  });

  final Player player;
  final VideoController controller;
  final double aspectRatio;
  final bool controlsVisible;
  final bool coverVideo;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final bool fullscreen;
  final String? errorMessage;
  final VoidCallback onInteract;
  final VoidCallback onRetry;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleHalfVolume;
  final VoidCallback onToggleLoop;
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
          VideoErrorOverlay(message: errorMessage!, onRetry: onRetry),
        IgnorePointer(
          ignoring: !controlsVisible || errorMessage != null,
          child: AnimatedOpacity(
            opacity: controlsVisible || errorMessage != null ? 1 : 0,
            duration: AppMotion.duration(context, 180),
            child: _VideoControls(
              player: player,
              muted: muted,
              halfVolume: halfVolume,
              loopVideo: loopVideo,
              coverVideo: coverVideo,
              fullscreen: fullscreen,
              onToggleFit: onToggleFit,
              onToggleMute: onToggleMute,
              onToggleHalfVolume: onToggleHalfVolume,
              onToggleLoop: onToggleLoop,
              onFullscreen: onFullscreen,
            ),
          ),
        ),
        if (errorMessage == null)
          StreamBuilder<bool>(
            stream: player.stream.playing,
            initialData: player.state.playing,
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return AnimatedScale(
                scale: controlsVisible || !playing ? 1 : 0.85,
                duration: AppMotion.duration(context, 160),
                child: AnimatedOpacity(
                  opacity: controlsVisible || !playing ? 1 : 0,
                  duration: AppMotion.duration(context, 160),
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.46),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: IconButton(
                        tooltip: playing ? 'Pause' : 'Play',
                        iconSize: fullscreen ? 58 : 44,
                        color: Colors.white,
                        onPressed: () {
                          player.playOrPause();
                          onInteract();
                        },
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );

    return MouseRegion(
      onHover: (_) => onInteract(),
      child: GestureDetector(
        onTap: onInteract,
        onLongPress: player.playOrPause,
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

class VideoErrorOverlay extends StatelessWidget {
  const VideoErrorOverlay({
    required this.message,
    required this.onRetry,
    super.key,
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

class _DioImageFallback extends StatefulWidget {
  const _DioImageFallback({
    required this.imageUrl,
    required this.headers,
    required this.fit,
    required this.onFailed,
  });

  final String imageUrl;
  final Map<String, String> headers;
  final BoxFit fit;
  final VoidCallback onFailed;

  @override
  State<_DioImageFallback> createState() => _DioImageFallbackState();
}

class _DioImageFallbackState extends State<_DioImageFallback> {
  late final Future<Uint8List> _bytes = _load();
  bool _reportedFailure = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final bytes = snapshot.data;
        if (snapshot.hasError || bytes == null || bytes.isEmpty) {
          _reportFailure();
          return const _ImageLoadError();
        }
        return Image.memory(
          bytes,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            _reportFailure();
            return const _ImageLoadError();
          },
        );
      },
    );
  }

  Future<Uint8List> _load() async {
    final response = await Dio().get<List<int>>(
      widget.imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: widget.headers,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data;
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300 ||
        data == null ||
        data.isEmpty) {
      throw StateError('Could not load image');
    }
    return Uint8List.fromList(data);
  }

  void _reportFailure() {
    if (_reportedFailure) return;
    _reportedFailure = true;
    widget.onFailed();
  }
}

class _ImageLoadError extends StatelessWidget {
  const _ImageLoadError();

  @override
  Widget build(BuildContext context) {
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
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    required this.child,
    this.onGestureLockChanged,
  });

  final Widget child;
  final ValueChanged<bool>? onGestureLockChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _zoomed = false;
  int _pointerCount = 0;
  bool _locked = false;

  @override
  void dispose() {
    _setLocked(false);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFrame =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        final child = hasFrame
            ? SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: widget.child,
              )
            : widget.child;
        return Listener(
          onPointerDown: (_) {
            _pointerCount++;
            if (_pointerCount >= 2 || _zoomed) {
              _setLocked(true);
            }
          },
          onPointerUp: (_) => _releasePointer(),
          onPointerCancel: (_) => _releasePointer(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTapDown: (details) => _doubleTapDetails = details,
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1,
              maxScale: 6,
              boundaryMargin: const EdgeInsets.all(160),
              panEnabled: _zoomed,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              onInteractionStart: (_) {
                if (_pointerCount >= 2 || _zoomed) _setLocked(true);
              },
              onInteractionEnd: (_) {
                final scale = _controller.value.getMaxScaleOnAxis();
                final nextZoomed = scale > 1.03;
                if (!nextZoomed) {
                  _controller.value = Matrix4.identity();
                }
                if (mounted) setState(() => _zoomed = nextZoomed);
                _setLocked(nextZoomed || _pointerCount >= 2);
              },
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _toggleZoom() {
    final tap = _doubleTapDetails?.localPosition ?? Offset.zero;
    if (_zoomed) {
      _controller.value = Matrix4.identity();
      setState(() => _zoomed = false);
      _setLocked(false);
      return;
    }
    const scale = 2.5;
    _controller.value = Matrix4.identity()
      ..translateByDouble(-tap.dx * (scale - 1), -tap.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    setState(() => _zoomed = true);
    _setLocked(true);
  }

  void _releasePointer() {
    if (_pointerCount > 0) _pointerCount--;
    if (_pointerCount == 0 && !_zoomed) _setLocked(false);
  }

  void _setLocked(bool value) {
    if (_locked == value) return;
    _locked = value;
    widget.onGestureLockChanged?.call(value);
  }
}

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.emphasized = false,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool emphasized;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = emphasized
        ? scheme.primary
        : selected
            ? scheme.primaryContainer.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.13);
    final foreground = emphasized
        ? scheme.onPrimary
        : selected
            ? scheme.onPrimaryContainer
            : Colors.white;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: emphasized ? 23 : 21,
        child: AnimatedContainer(
          duration: AppMotion.duration(context, 140),
          width: emphasized ? 38 : 34,
          height: emphasized ? 38 : 34,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: foreground, size: emphasized ? 24 : 20),
        ),
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.player,
    required this.muted,
    required this.halfVolume,
    required this.loopVideo,
    required this.coverVideo,
    required this.fullscreen,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleHalfVolume,
    required this.onToggleLoop,
    required this.onFullscreen,
  });

  final Player player;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final bool coverVideo;
  final bool fullscreen;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleHalfVolume;
  final VoidCallback onToggleLoop;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          fullscreen ? 14 : 8,
          0,
          fullscreen ? 14 : 8,
          fullscreen ? 10 : 8,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(fullscreen ? 18 : 14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
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
                        final maxMs = duration.inMilliseconds
                            .clamp(1, 1 << 31)
                            .toDouble();
                        final valueMs = position.inMilliseconds
                            .clamp(0, maxMs.toInt())
                            .toDouble();
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 560;
                            final tiny = constraints.maxWidth < 390;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: scheme.primary,
                                    inactiveTrackColor:
                                        Colors.white.withValues(alpha: 0.24),
                                    trackHeight: 3,
                                    thumbColor: scheme.primary,
                                    overlayColor:
                                        scheme.primary.withValues(alpha: 0.18),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
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
                                    _RoundControlButton(
                                      tooltip: playing ? 'Pause' : 'Play',
                                      emphasized: true,
                                      onPressed: player.playOrPause,
                                      icon: playing
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tiny
                                          ? _format(position)
                                          : '${_format(position)} / ${_format(duration)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (!compact) ...[
                                      _RoundControlButton(
                                        tooltip: 'Back 10s',
                                        onPressed: () => player.seek(
                                          _clampSeek(
                                            position -
                                                const Duration(seconds: 10),
                                            duration,
                                          ),
                                        ),
                                        icon: Icons.replay_10_rounded,
                                      ),
                                      const SizedBox(width: 5),
                                      _RoundControlButton(
                                        tooltip: 'Forward 10s',
                                        onPressed: () => player.seek(
                                          _clampSeek(
                                            position +
                                                const Duration(seconds: 10),
                                            duration,
                                          ),
                                        ),
                                        icon: Icons.forward_10_rounded,
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                    _RoundControlButton(
                                      tooltip: muted ? 'Unmute' : 'Mute',
                                      onPressed: onToggleMute,
                                      icon: muted
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                    ),
                                    const SizedBox(width: 5),
                                    _RoundControlButton(
                                      tooltip: halfVolume
                                          ? 'Normal app volume'
                                          : 'Half app volume',
                                      selected: halfVolume,
                                      onPressed: onToggleHalfVolume,
                                      icon: Icons.volume_down_rounded,
                                    ),
                                    const SizedBox(width: 5),
                                    _RoundControlButton(
                                      tooltip: loopVideo
                                          ? 'Disable repeat'
                                          : 'Repeat video',
                                      selected: loopVideo,
                                      onPressed: onToggleLoop,
                                      icon: loopVideo
                                          ? Icons.repeat_one_on_rounded
                                          : Icons.repeat_one_rounded,
                                    ),
                                    const SizedBox(width: 5),
                                    if (!compact) ...[
                                      _RoundControlButton(
                                        tooltip: coverVideo ? 'Fit' : 'Fill',
                                        selected: coverVideo,
                                        onPressed: onToggleFit,
                                        icon: coverVideo
                                            ? Icons.fit_screen_rounded
                                            : Icons.crop_free_rounded,
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                    _RoundControlButton(
                                      tooltip: fullscreen
                                          ? 'Exit fullscreen'
                                          : 'Fullscreen',
                                      onPressed: onFullscreen,
                                      icon: fullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded,
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
