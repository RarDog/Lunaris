import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

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
    this.onPlaybackSnapshot,
    this.onPlaybackPreferencesChanged,
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
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackSnapshot;
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackPreferencesChanged;

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
      return _SwfMediaViewer(
        post: widget.post,
        url: _swfUrl(widget.post),
        fullscreen: widget.fullscreen,
      );
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
    final image = CachedNetworkImage(
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
    );
    final allowPinchZoom = MediaQuery.sizeOf(context).width < 700;
    return allowPinchZoom ? InteractiveViewer(child: image) : image;
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
      if (_videoIndex < _videoUrls.length - 1) {
        _videoIndex++;
        _openVideo(play: false);
        return;
      }
      setState(() => _videoError = message);
      _showControls();
    });
    _positionSubscription = _player!.stream.position.listen((_) {
      final snapshot = _snapshot();
      _playbackMemory[widget.post.cacheKey] = snapshot;
      widget.onPlaybackSnapshot?.call(snapshot);
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
    setState(() => _videoError = null);
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
    if (play) await player.play();
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

  String _swfUrl(Post post) {
    for (final url in [post.fileUrl, post.sampleUrl, post.source ?? '']) {
      final value = url.trim();
      if (value.toLowerCase().contains('.swf')) return value;
    }
    return post.fileUrl.trim();
  }

  Map<String, String> _headersFor(Post post) {
    return {
      'User-Agent': 'Lunaris/2.0 Flutter local booru browser',
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
    widget.onPlaybackSnapshot?.call(snapshot);
    widget.onPlaybackPreferencesChanged?.call(snapshot);
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

class _SwfMediaViewer extends StatelessWidget {
  const _SwfMediaViewer({
    required this.post,
    required this.url,
    required this.fullscreen,
  });

  final Post post;
  final String url;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(child: Text('SWF URL is empty'));
    }
    if (Platform.isWindows) {
      return _WindowsRuffleViewer(url: url, fullscreen: fullscreen);
    }
    return _SwfUnsupportedPanel(url: url);
  }
}

class _WindowsRuffleViewer extends StatefulWidget {
  const _WindowsRuffleViewer({
    required this.url,
    required this.fullscreen,
  });

  final String url;
  final bool fullscreen;

  @override
  State<_WindowsRuffleViewer> createState() => _WindowsRuffleViewerState();
}

class _WindowsRuffleViewerState extends State<_WindowsRuffleViewer> {
  final _controller = WebviewController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant _WindowsRuffleViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(widget.fullscreen ? 0 : 10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized) Webview(_controller),
          if (_loading)
            const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            _SwfErrorPanel(
              message: _error!,
              url: widget.url,
              onRetry: _load,
            ),
        ],
      ),
    );
    if (widget.fullscreen) return child;
    return AspectRatio(aspectRatio: 4 / 3, child: child);
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      _controller.loadingState.listen((state) {
        if (!mounted) return;
        setState(() => _loading = state == LoadingState.loading);
      });
      _controller.onLoadError.listen((error) {
        if (!mounted) return;
        setState(() => _error = 'Ruffle WebView error: $error');
      });
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Could not start Windows WebView2. Install WebView2 Runtime or open original.';
      });
    }
  }

  Future<void> _load() async {
    if (!_controller.value.isInitialized) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _controller.loadStringContent(_ruffleHtml(widget.url));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load Ruffle viewer: $error';
      });
    }
  }

  String _ruffleHtml(String swfUrl) {
    final escapedUrl = _htmlEscape(swfUrl);
    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; width: 100%; height: 100%; background: #000; overflow: hidden; }
    #stage { width: 100vw; height: 100vh; display: flex; align-items: center; justify-content: center; }
    ruffle-player { width: 100%; height: 100%; background: #000; }
  </style>
  <script>
    window.RufflePlayer = window.RufflePlayer || {};
    window.RufflePlayer.config = {
      autoplay: "on",
      unmuteOverlay: "visible",
      splashScreen: true,
      letterbox: "on"
    };
  </script>
  <script src="https://unpkg.com/@ruffle-rs/ruffle"></script>
</head>
<body>
  <div id="stage">
    <embed src="$escapedUrl" width="100%" height="100%">
  </div>
</body>
</html>
''';
  }

  String _htmlEscape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}

class _SwfUnsupportedPanel extends StatelessWidget {
  const _SwfUnsupportedPanel({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return _SwfErrorPanel(
      message: Platform.isAndroid
          ? 'Flash/SWF playback is desktop only.'
          : 'SWF playback is available on Windows only in this build.',
      url: url,
    );
  }
}

class _SwfErrorPanel extends StatelessWidget {
  const _SwfErrorPanel({
    required this.message,
    required this.url,
    this.onRetry,
  });

  final String message;
  final String url;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.extension_rounded,
                  color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                'SWF / Flash',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: () => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open original'),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          scheme.primaryContainer.withValues(alpha: 0.82),
                    ),
                    onPressed: () => launchUrl(
                      Uri.parse(
                        'https://ruffle.rs/demo/?url=${Uri.encodeComponent(url)}',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: const Text('Open in Ruffle'),
                  ),
                ],
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
