import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/motion.dart';
import '../../../../backend/backend.dart';
import '../../../../shared/widgets/formatted_content_text.dart';

final Map<String, VideoPlaybackSnapshot> _playbackMemory =
    <String, VideoPlaybackSnapshot>{};

class PostMediaViewer extends StatefulWidget {
  const PostMediaViewer({
    required this.post,
    this.localFilePath,
    this.fullscreen = false,
    this.initialPosition = Duration.zero,
    this.autoplay = false,
    this.initialLoop = false,
    this.initialMuted = false,
    this.initialCoverVideo = false,
    this.initialHalfVolume = false,
    this.initialVolume = 100.0,
    this.qualityMode = MediaQualityMode.auto,
    this.mediaHeaders = const {},
    this.onPlaybackSnapshot,
    this.onPlaybackPreferencesChanged,
    this.onVolumeChanged,
    this.onMediaGestureLockChanged,
    super.key,
  });

  final Post post;
  final String? localFilePath;
  final bool fullscreen;
  final Duration initialPosition;
  final bool autoplay;
  final bool initialLoop;
  final bool initialMuted;
  final bool initialCoverVideo;
  final bool initialHalfVolume;
  final double initialVolume;
  final MediaQualityMode qualityMode;
  final Map<String, String> mediaHeaders;
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackSnapshot;
  final ValueChanged<VideoPlaybackSnapshot>? onPlaybackPreferencesChanged;
  final ValueChanged<double>? onVolumeChanged;
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
  late double _currentVolume;
  String? _videoError;
  bool _retriedFormatError = false;
  bool _softwareDecodingFallback = false;
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
    _currentVolume = widget.initialVolume;
    _imageUrls = _buildImageUrls(widget.post);
    _videoUrls = _buildVideoUrls(widget.post);
    if (_isPlayableMedia(widget.post) && _videoUrls.isNotEmpty) {
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
      _retriedFormatError = false;
      _softwareDecodingFallback = false;
      _imageUrls = _buildImageUrls(widget.post);
      _videoUrls = _buildVideoUrls(widget.post);
      if (_isPlayableMedia(widget.post) && _videoUrls.isNotEmpty) {
        _initializeVideo();
      }
    } else if (oldWidget.mediaHeaders != widget.mediaHeaders) {
      if (_videoError != null && _player != null) {
        unawaited(_retryVideo());
      }
    }
    if (oldWidget.initialVolume != widget.initialVolume) {
      _currentVolume = widget.initialVolume;
      unawaited(_applyVolume());
    }
    if (oldWidget.initialMuted != widget.initialMuted) {
      _muted = widget.initialMuted;
      unawaited(_applyVolume());
    }
    if (oldWidget.initialHalfVolume != widget.initialHalfVolume) {
      _halfVolume = widget.initialHalfVolume;
      unawaited(_applyVolume());
    }
    if (oldWidget.initialLoop != widget.initialLoop) {
      _loopVideo = widget.initialLoop;
      unawaited(_player?.setPlaylistMode(
        _loopVideo ? PlaylistMode.single : PlaylistMode.none,
      ));
    }
    if (oldWidget.initialCoverVideo != widget.initialCoverVideo) {
      _coverVideo = widget.initialCoverVideo;
    }
  }

  @override
  void dispose() {
    if (!_inFullscreen) {
      _disposeVideo();
    }
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

    if (_controller != null || _player != null) {
      if (_isAudio(widget.post) && _player != null) {
        return _AudioSurface(
          player: _player!,
          post: widget.post,
          muted: _muted,
          loopAudio: _loopVideo,
          initialVolume: _currentVolume,
          onVolumeChanged: (vol) {
            _currentVolume = vol;
            widget.onVolumeChanged?.call(vol);
            _emitPlaybackPreferences();
          },
          fullscreen: widget.fullscreen,
          errorMessage: _videoError,
          onRetry: _retryVideo,
          onToggleMute: () async {
            final nextMuted = !_muted;
            setState(() => _muted = nextMuted);
            await _applyVolume();
            _emitPlaybackPreferences();
          },
          onToggleLoop: () async {
            final nextLoop = !_loopVideo;
            setState(() => _loopVideo = nextLoop);
            await _player!.setPlaylistMode(
              nextLoop ? PlaylistMode.single : PlaylistMode.none,
            );
            _emitPlaybackPreferences();
          },
        );
      }
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
              initialVolume: _currentVolume,
              onVolumeChanged: (vol) {
                _currentVolume = vol;
                widget.onVolumeChanged?.call(vol);
                _emitPlaybackPreferences();
              },
              fullscreen: widget.fullscreen,
              errorMessage: _videoError,
              onTapSurface: _toggleControls,
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

    if (_imageUrls.isEmpty) {
      if (widget.post.cloudLinks.isNotEmpty) {
        return _CloudMediaHero(
          post: widget.post,
          onOpenPrimary: () {
            final links = widget.post.cloudLinks;
            final first = links.isNotEmpty ? links.first : null;
            if (first != null) {
              launchUrl(Uri.parse(first.url),
                  mode: LaunchMode.externalApplication);
            }
          },
        );
      }
      return _TextArticleHero(post: widget.post);
    }

    final url = _imageUrls[_imageIndex];
    final isLocal = url.startsWith('/') || url.startsWith('file://');
    final headers = _headersFor(widget.post);
    final Widget image;
    if (isLocal) {
      final cleanPath =
          url.startsWith('file://') ? url.replaceFirst('file://', '') : url;
      image = Image.file(
        File(cleanPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _DioImageFallback(
          imageUrl: _imageUrls.length > 1 ? _imageUrls[1] : '',
          headers: headers,
          fit: BoxFit.contain,
          onFailed: _advanceImageFallback,
        ),
      );
    } else {
      image = CachedNetworkImage(
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
    }
    final child = Stack(
      alignment: Alignment.center,
      children: [
        _ZoomableImage(
          onGestureLockChanged: widget.onMediaGestureLockChanged,
          child: image,
        ),
        if (_imageUrls.length > 1)
          Positioned(
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_imageIndex > 0)
                    GestureDetector(
                      onTap: () => setState(() => _imageIndex--),
                      child: const Icon(Icons.chevron_left_rounded,
                          size: 20, color: Colors.white),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${_imageIndex + 1} / ${_imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_imageIndex < _imageUrls.length - 1)
                    GestureDetector(
                      onTap: () => setState(() => _imageIndex++),
                      child: const Icon(Icons.chevron_right_rounded,
                          size: 20, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
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
    _controller = VideoController(
      _player!,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: !_softwareDecodingFallback,
        hwdec: _softwareDecodingFallback ? 'no' : 'auto-safe',
      ),
    );
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
      final currentSource = _videoUrls[_videoIndex];
      final isLocal =
          currentSource.startsWith('/') || currentSource.startsWith('file://');
      await player.open(
        Media(
          currentSource,
          httpHeaders: isLocal ? null : _headersFor(widget.post),
        ),
        play: false,
      );
      await _applyVolume();
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
    final lower = message.toLowerCase();
    // If format or codec error occurred (e.g. unsupported hwdec profile), fallback to software decoding and retry once
    if (!_retriedFormatError &&
        (lower.contains('codec') ||
            lower.contains('could not open') ||
            lower.contains('couldnt open') ||
            lower.contains('could not initialize codec') ||
            lower.contains('demuxer error') ||
            lower.contains('format unrecognized') ||
            lower.contains('stream format not recognized') ||
            lower.contains('failed to recognize file format'))) {
      _retriedFormatError = true;
      _softwareDecodingFallback = true;
      _disposeVideo();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        _videoIndex = 0;
        _initializeVideo();
        return;
      }
    }
    if (mounted) {
      setState(() => _videoError = message);
    }
  }

  Future<void> _retryVideo() async {
    _videoIndex = 0;
    _retriedFormatError = false;
    _softwareDecodingFallback = true;
    _disposeVideo();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      _initializeVideo();
    }
  }

  void _disposeVideo() {
    _hideTimer?.cancel();
    _errorSubscription?.cancel();
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    final snapshot = _snapshot();
    _playbackMemory[widget.post.cacheKey] = snapshot;
    widget.onPlaybackSnapshot?.call(snapshot);
    _player?.dispose();
    _player = null;
    _controller = null;
  }

  List<String> _buildImageUrls(Post post) {
    final list = MediaUrlSelector.details(post, mode: widget.qualityMode);
    final local = widget.localFilePath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return [local, ...list];
    }
    return list;
  }

  List<String> _buildVideoUrls(Post post) {
    final list = _isAudio(post)
        ? List<String>.from(MediaUrlSelector.audio(post))
        : List<String>.from(MediaUrlSelector.video(post));
    final cloudStreams = post.cloudLinks
        .where((l) => l.isStreamable && l.directStreamUrl != null)
        .map((l) => l.directStreamUrl!);
    for (final stream in cloudStreams) {
      if (!list.contains(stream)) list.add(stream);
    }
    final local = widget.localFilePath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return [local, ...list];
    }
    return list;
  }

  bool _isAudio(Post post) => MediaUrlSelector.isAudio(post);

  bool _isVideo(Post post) {
    if (_isAudio(post)) return false;
    if (post.cloudLinks.any((l) => l.isStreamable)) return true;
    return MediaUrlSelector.isVideo(post);
  }

  bool _isPlayableMedia(Post post) => _isVideo(post) || _isAudio(post);

  bool _isSwf(Post post) {
    final value =
        '${post.fileType} ${post.fileUrl} ${post.sampleUrl} ${post.source ?? ''}'
            .toLowerCase();
    return value.contains('swf') || value.contains('.swf');
  }

  Map<String, String> _headersFor(Post post) {
    String? defaultReferer;
    final pid = post.providerId.toLowerCase();
    if (pid.contains('gelbooru')) {
      defaultReferer = 'https://gelbooru.com/';
    } else if (pid.contains('rule34')) {
      defaultReferer = 'https://rule34.xxx/';
    } else if (pid.contains('realbooru')) {
      defaultReferer = 'https://realbooru.com/';
    } else if (pid.contains('danbooru')) {
      defaultReferer = 'https://danbooru.donmai.us/';
    } else if (pid.contains('e621') || pid.contains('e926')) {
      defaultReferer = 'https://e621.net/';
    } else {
      final uri = Uri.tryParse(post.fileUrl);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        defaultReferer = '${uri.scheme}://${uri.host}/';
      }
    }

    return {
      'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
      'Accept': '*/*',
      if (defaultReferer != null) 'Referer': defaultReferer,
      ...widget.mediaHeaders,
    };
  }

  void _advanceImageFallback() {
    if (_imageIndex >= _imageUrls.length - 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _imageIndex++);
    });
  }

  void _toggleControls() {
    if (!mounted) return;
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
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
    final wasPlaying = player.state.playing;
    setState(() => _inFullscreen = true);
    if (!context.mounted) return;
    final result = await Navigator.of(context, rootNavigator: true)
        .push<VideoPlaybackSnapshot>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => _FullscreenVideoPage(
          player: player,
          controller: controller,
          wasPlaying: wasPlaying,
          aspectRatio: widget.post.width > 0 && widget.post.height > 0
              ? widget.post.width / widget.post.height
              : 16 / 9,
          loopVideo: _loopVideo,
          muted: _muted,
          halfVolume: _halfVolume,
          coverVideo: _coverVideo,
          initialVolume: _currentVolume,
          errorMessage: _videoError,
          onRetry: _retryVideo,
          onChanged: (snapshot) {
            unawaited(_applyPlaybackSnapshot(snapshot));
          },
        ),
      ),
    );
    if (mounted) {
      setState(() => _inFullscreen = false);
    } else {
      player.dispose();
      return;
    }
    if (result != null) {
      await _applyPlaybackSnapshot(result);
      if (result.playing && !player.state.playing) {
        await player.play();
      } else if (!result.playing && player.state.playing) {
        await player.pause();
      }
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
      _currentVolume = snapshot.volume;
    });
    await _applyVolume();
    await _player?.setPlaylistMode(
      _loopVideo ? PlaylistMode.single : PlaylistMode.none,
    );
    _emitPlaybackPreferences();
    widget.onVolumeChanged?.call(_currentVolume);
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
      volume: _currentVolume,
    );
  }

  Future<void> _applyVolume() async {
    await _player?.setVolume(_muted
        ? 0.0
        : _halfVolume
            ? 50.0
            : _currentVolume);
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
    this.volume = 100.0,
  });

  final Duration position;
  final bool playing;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final bool coverVideo;
  final double volume;
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.player,
    required this.controller,
    required this.wasPlaying,
    required this.aspectRatio,
    required this.loopVideo,
    required this.muted,
    required this.halfVolume,
    required this.coverVideo,
    this.initialVolume = 100.0,
    required this.errorMessage,
    required this.onRetry,
    required this.onChanged,
  });

  final Player player;
  final VideoController controller;
  final bool wasPlaying;
  final double aspectRatio;
  final bool loopVideo;
  final bool muted;
  final bool halfVolume;
  final bool coverVideo;
  final double initialVolume;
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
  late double _currentVolume;
  late bool _isLandscape;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _coverVideo = widget.coverVideo;
    _muted = widget.muted;
    _loopVideo = widget.loopVideo;
    _halfVolume = widget.halfVolume;
    _currentVolume = widget.initialVolume;
    _applyVolume();
    _isLandscape = widget.aspectRatio > 1.05;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _applyOrientation();
    _scheduleControlsHide();
    if (widget.wasPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !widget.player.state.playing) {
          widget.player.play();
        }
      });
    }
  }

  void _applyOrientation() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    _applyOrientation();
    _showControls();
  }

  void _toggleControls() {
    if (!mounted) return;
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Future.delayed(const Duration(milliseconds: 300), () {
        SystemChrome.setPreferredOrientations([]);
      });
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
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
              child: _VideoSurface(
                player: widget.player,
                controller: widget.controller,
                aspectRatio: widget.aspectRatio,
                controlsVisible: _controlsVisible,
                coverVideo: _coverVideo,
                muted: _muted,
                loopVideo: _loopVideo,
                halfVolume: _halfVolume,
                initialVolume: _currentVolume,
                onVolumeChanged: (vol) {
                  _currentVolume = vol;
                  widget.onChanged(_snapshot());
                },
                fullscreen: true,
                errorMessage: widget.errorMessage,
                onTapSurface: _toggleControls,
                onInteract: _showControls,
                isLandscape: _isLandscape,
                onToggleOrientation: _toggleOrientation,
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
        ? 0.0
        : _halfVolume
            ? 50.0
            : _currentVolume);
  }

  VideoPlaybackSnapshot _snapshot() {
    return VideoPlaybackSnapshot(
      position: widget.player.state.position,
      playing: widget.player.state.playing,
      muted: _muted,
      halfVolume: _halfVolume,
      loopVideo: _loopVideo,
      coverVideo: _coverVideo,
      volume: _currentVolume,
    );
  }
}

class _CloseVideoIntent extends Intent {
  const _CloseVideoIntent();
}

class _AudioSurface extends StatefulWidget {
  const _AudioSurface({
    required this.player,
    required this.post,
    required this.muted,
    required this.loopAudio,
    this.initialVolume = 100.0,
    this.onVolumeChanged,
    required this.fullscreen,
    required this.errorMessage,
    required this.onRetry,
    required this.onToggleMute,
    required this.onToggleLoop,
  });

  final Player player;
  final Post post;
  final bool muted;
  final bool loopAudio;
  final double initialVolume;
  final ValueChanged<double>? onVolumeChanged;
  final bool fullscreen;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLoop;

  @override
  State<_AudioSurface> createState() => _AudioSurfaceState();
}

class _AudioSurfaceState extends State<_AudioSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playSub;
  StreamSubscription<bool>? _buffSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _buffering = false;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _position = widget.player.state.position;
    _duration = widget.player.state.duration;
    _playing = widget.player.state.playing;
    _buffering = widget.player.state.buffering;
    if (_playing) _rotationController.repeat();

    _posSub = widget.player.stream.position.listen((pos) {
      if (mounted && !_isDragging) {
        setState(() => _position = pos);
      }
    });
    _durSub = widget.player.stream.duration.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _playSub = widget.player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() => _playing = playing);
        if (playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });
    _buffSub = widget.player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _buffering = buffering);
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    _buffSub?.cancel();
    super.dispose();
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _deriveTitle() {
    final title = (widget.post.title ?? '').trim();
    if (title.isNotEmpty) return title;
    final uri = Uri.tryParse(widget.post.fileUrl);
    if (uri != null) {
      final q = uri.queryParameters['f'];
      if (q != null && q.trim().isNotEmpty) return q.trim();
      final seg = uri.pathSegments.lastOrNull;
      if (seg != null && seg.isNotEmpty) return seg;
    }
    return 'Аудиозапись';
  }

  void _seekRelative(int seconds) {
    final target = _position + Duration(seconds: seconds);
    final maxDur = _duration > Duration.zero ? _duration : target;
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, maxDur.inMilliseconds),
    );
    widget.player.seek(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _deriveTitle();
    final artistName =
        widget.post.tagGroups['artist']?.firstOrNull ?? widget.post.providerName;
    final hasCover = widget.post.previewUrl.isNotEmpty &&
        widget.post.previewUrl.startsWith('http');

    if (widget.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 40, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Не удалось воспроизвести аудио',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить попытку'),
              ),
            ],
          ),
        ),
      );
    }

    final maxMs = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds.toDouble()
        : 1.0;
    final currentMs = (_isDragging ? _dragValue : _position.inMilliseconds.toDouble())
        .clamp(0.0, maxMs);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Row: Vinyl / Album Art + Title + Artist
          Row(
            children: [
              // Rotating Album Art / Vinyl
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.9),
                        Colors.black87,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: hasCover
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.post.previewUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(
                                Icons.audiotrack_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 26,
                              ),
                            ),
                          )
                        : Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surface,
                            ),
                            child: Icon(
                              Icons.audiotrack_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Track & Artist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Timeline Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.15),
              thumbColor: theme.colorScheme.primary,
            ),
            child: Slider(
              value: currentMs,
              min: 0.0,
              max: maxMs,
              onChanged: (val) {
                setState(() {
                  _isDragging = true;
                  _dragValue = val;
                });
              },
              onChangeEnd: (val) {
                _isDragging = false;
                widget.player.seek(Duration(milliseconds: val.toInt()));
              },
            ),
          ),

          // Time numbers: elapsed & total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(_position),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (_buffering)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                Text(
                  _formatTime(_duration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Controls Row: Loop, -10s, Play/Pause, +10s, Mute
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: widget.loopAudio ? 'Повтор: включен' : 'Повтор: выключен',
                icon: Icon(
                  widget.loopAudio ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                  color: widget.loopAudio
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                onPressed: widget.onToggleLoop,
              ),
              IconButton(
                tooltip: 'Назад на 10 сек',
                icon: const Icon(Icons.replay_10_rounded, size: 26),
                color: theme.colorScheme.onSurface,
                onPressed: () => _seekRelative(-10),
              ),
              // Big Play / Pause Button
              GestureDetector(
                onTap: () {
                  if (_playing) {
                    widget.player.pause();
                  } else {
                    widget.player.play();
                  }
                },
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 30,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Вперед на 10 сек',
                icon: const Icon(Icons.forward_10_rounded, size: 26),
                color: theme.colorScheme.onSurface,
                onPressed: () => _seekRelative(10),
              ),
              IconButton(
                tooltip: widget.muted ? 'Включить звук' : 'Выключить звук',
                icon: Icon(
                  widget.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: widget.muted
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                onPressed: widget.onToggleMute,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoSurface extends StatefulWidget {
  const _VideoSurface({
    required this.player,
    required this.controller,
    required this.aspectRatio,
    required this.controlsVisible,
    required this.coverVideo,
    required this.muted,
    required this.halfVolume,
    required this.loopVideo,
    this.initialVolume = 100.0,
    this.onVolumeChanged,
    required this.fullscreen,
    required this.errorMessage,
    this.onTapSurface,
    required this.onInteract,
    required this.onRetry,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleHalfVolume,
    required this.onToggleLoop,
    required this.onFullscreen,
    this.isLandscape,
    this.onToggleOrientation,
  });

  final Player player;
  final VideoController controller;
  final double aspectRatio;
  final bool controlsVisible;
  final bool coverVideo;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final double initialVolume;
  final ValueChanged<double>? onVolumeChanged;
  final bool fullscreen;
  final String? errorMessage;
  final VoidCallback? onTapSurface;
  final VoidCallback onInteract;
  final VoidCallback onRetry;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleHalfVolume;
  final VoidCallback onToggleLoop;
  final VoidCallback onFullscreen;
  final bool? isLandscape;
  final VoidCallback? onToggleOrientation;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<_VideoSurface> {
  bool _isLocked = false;
  bool _showLeftSeek = false;
  bool _showRightSeek = false;
  Timer? _seekLeftTimer;
  Timer? _seekRightTimer;

  bool _isSpeedBoosted = false;
  double _savedRate = 1.0;

  bool _showVolumeIndicator = false;
  double _currentVolume = 100;
  Timer? _volumeTimer;

  bool _showBrightnessIndicator = false;
  double _currentBrightness = 1.0;
  Timer? _brightnessTimer;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.initialVolume;
    widget.player.setVolume(_currentVolume);
  }

  @override
  void didUpdateWidget(covariant _VideoSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialVolume != widget.initialVolume) {
      _currentVolume = widget.initialVolume;
      widget.player.setVolume(_currentVolume);
    }
  }

  @override
  void dispose() {
    _seekLeftTimer?.cancel();
    _seekRightTimer?.cancel();
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    super.dispose();
  }

  void _seekBy(Duration delta) {
    final pos = widget.player.state.position;
    final dur = widget.player.state.duration;
    var target = pos + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (dur > Duration.zero && target > dur) target = dur;
    widget.player.seek(target);
    widget.onInteract();
    if (delta.inSeconds < 0) {
      setState(() => _showLeftSeek = true);
      _seekLeftTimer?.cancel();
      _seekLeftTimer = Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _showLeftSeek = false);
      });
    } else if (delta.inSeconds > 0) {
      setState(() => _showRightSeek = true);
      _seekRightTimer?.cancel();
      _seekRightTimer = Timer(const Duration(milliseconds: 650), () {
        if (mounted) setState(() => _showRightSeek = false);
      });
    }
  }

  void _onDoubleTapAt(Offset localPosition, double width) {
    if (_isLocked) return;
    if (localPosition.dx < width * 0.4) {
      _seekBy(const Duration(seconds: -10));
    } else if (localPosition.dx > width * 0.6) {
      _seekBy(const Duration(seconds: 10));
    } else {
      if (widget.player.state.playing) {
        widget.player.pause();
      } else {
        if (widget.player.state.completed) {
          widget.player.seek(Duration.zero);
        }
        widget.player.play();
      }
      widget.onInteract();
    }
  }

  void _startSpeedBoost() {
    if (_isLocked) return;
    _savedRate = widget.player.state.rate;
    widget.player.setRate(2.0);
    setState(() => _isSpeedBoosted = true);
  }

  void _stopSpeedBoost() {
    if (!_isSpeedBoosted) return;
    widget.player.setRate(_savedRate);
    setState(() => _isSpeedBoosted = false);
  }

  void _adjustVolume(double deltaY) {
    if (_isLocked) return;
    final newVol = (_currentVolume - deltaY * 0.5).clamp(0.0, 100.0);
    _currentVolume = newVol;
    widget.player.setVolume(newVol);
    widget.onVolumeChanged?.call(newVol);
    setState(() => _showVolumeIndicator = true);
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showVolumeIndicator = false);
    });
  }

  void _adjustBrightness(double deltaY) {
    if (_isLocked) return;
    final newB = (_currentBrightness - deltaY * 0.004).clamp(0.08, 1.0);
    setState(() {
      _currentBrightness = newB;
      _showBrightnessIndicator = true;
    });
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showBrightnessIndicator = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    Offset? lastTapDown;

    final child = LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.black,
              child: Video(
                controller: widget.controller,
                fit: widget.coverVideo ? BoxFit.cover : BoxFit.contain,
                controls: null,
                pauseUponEnteringBackgroundMode: false,
                resumeUponEnteringForegroundMode: false,
              ),
            ),
            if (_currentBrightness < 0.99)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withValues(
                      alpha: (1.0 - _currentBrightness).clamp(0.0, 0.92),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => lastTapDown = details.localPosition,
                onTap: widget.onTapSurface ?? widget.onInteract,
                onDoubleTap: () {
                  if (lastTapDown != null) {
                    _onDoubleTapAt(
                      lastTapDown!,
                      MediaQuery.sizeOf(context).width,
                    );
                  }
                },
                onLongPressStart: (_) => _startSpeedBoost(),
                onLongPressEnd: (_) => _stopSpeedBoost(),
                onVerticalDragUpdate: (details) {
                  final x = details.localPosition.dx;
                  final width = MediaQuery.sizeOf(context).width;
                  if (x < width * 0.45) {
                    _adjustBrightness(details.primaryDelta ?? 0.0);
                  } else if (x > width * 0.55) {
                    _adjustVolume(details.primaryDelta ?? 0.0);
                  }
                },
              ),
            ),
            StreamBuilder<bool>(
              stream: player.stream.buffering,
              initialData: player.state.buffering,
              builder: (context, snapshot) {
                if (snapshot.data != true || widget.errorMessage != null) {
                  return const SizedBox.shrink();
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            _DoubleTapSeekRipple(isLeft: true, visible: _showLeftSeek),
            _DoubleTapSeekRipple(isLeft: false, visible: _showRightSeek),
            if (_showVolumeIndicator)
              _VolumeGestureBadge(volume: _currentVolume),
            if (_showBrightnessIndicator)
              _BrightnessGestureBadge(brightness: _currentBrightness),
            if (_isSpeedBoosted)
              const _SpeedBoostOverlayBadge(),
            if (widget.errorMessage != null)
              VideoErrorOverlay(
                message: widget.errorMessage!,
                onRetry: widget.onRetry,
              ),
            IgnorePointer(
              ignoring: (!widget.controlsVisible && !_isLocked) ||
                  widget.errorMessage != null,
              child: AnimatedOpacity(
                opacity: (widget.controlsVisible || _isLocked) &&
                        widget.errorMessage == null
                    ? 1
                    : 0,
                duration: AppMotion.duration(context, 180),
                child: _VideoControls(
                  player: player,
                  muted: widget.muted,
                  halfVolume: widget.halfVolume,
                  loopVideo: widget.loopVideo,
                  coverVideo: widget.coverVideo,
                  fullscreen: widget.fullscreen,
                  isLocked: _isLocked,
                  isLandscape: widget.isLandscape,
                  onToggleOrientation: widget.onToggleOrientation,
                  onToggleLock: () => setState(() => _isLocked = !_isLocked),
                  onToggleFit: widget.onToggleFit,
                  onToggleMute: widget.onToggleMute,
                  onToggleHalfVolume: widget.onToggleHalfVolume,
                  onToggleLoop: widget.onToggleLoop,
                  onFullscreen: widget.onFullscreen,
                  onSeekBy: _seekBy,
                  onInteract: widget.onInteract,
                ),
              ),
            ),
          ],
        );
      },
    );

    return MouseRegion(
      onHover: (_) => widget.onInteract(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.fullscreen ? 0 : 10),
        child: widget.fullscreen
            ? SizedBox.expand(child: child)
            : AspectRatio(
                aspectRatio: widget.aspectRatio.clamp(0.35, 2.4),
                child: child,
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
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent) {
              final scaleDelta = signal.scrollDelta.dy < 0 ? 1.15 : 0.85;
              final currentScale = _controller.value.getMaxScaleOnAxis();
              final newScale = (currentScale * scaleDelta).clamp(1.0, 6.0);
              if (newScale <= 1.02) {
                _controller.value = Matrix4.identity();
                if (mounted) setState(() => _zoomed = false);
                _setLocked(false);
              } else {
                final focalPoint = signal.localPosition;
                _controller.value = Matrix4.identity()
                  ..translateByDouble(
                      -focalPoint.dx * (newScale - 1),
                      -focalPoint.dy * (newScale - 1),
                      0,
                      1)
                  ..scaleByDouble(newScale, newScale, 1, 1);
                if (mounted) setState(() => _zoomed = true);
                _setLocked(true);
              }
            }
          },
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
    this.size = 36,
    this.iconSize = 20,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool emphasized;
  final bool selected;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = emphasized
        ? scheme.primary
        : selected
            ? scheme.primaryContainer.withValues(alpha: 0.95)
            : Colors.black.withValues(alpha: 0.44);
    final foreground = emphasized
        ? scheme.onPrimary
        : selected
            ? scheme.onPrimaryContainer
            : Colors.white;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkResponse(
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          onTap: onPressed,
          child: AnimatedContainer(
            duration: AppMotion.duration(context, 140),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.14),
              ),
              boxShadow: [
                if (emphasized)
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.45),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: foreground, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedBadgeButton extends StatelessWidget {
  const _SpeedBadgeButton({
    required this.currentRate,
    required this.onSelected,
  });

  final double currentRate;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<double>(
      initialValue: currentRate,
      tooltip: 'Скорость воспроизведения',
      onSelected: onSelected,
      color: const Color(0xFF1E1E24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      itemBuilder: (context) => [
        for (final rate in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
          PopupMenuItem<double>(
            value: rate,
            child: Row(
              children: [
                if ((rate - currentRate).abs() < 0.05)
                  Icon(Icons.check_rounded, size: 18, color: scheme.primary)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(
                  '${rate}x',
                  style: TextStyle(
                    color: (rate - currentRate).abs() < 0.05
                        ? scheme.primary
                        : Colors.white,
                    fontWeight: (rate - currentRate).abs() < 0.05
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.44),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Text(
          '${currentRate}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _SpeedBoostOverlayBadge extends StatelessWidget {
  const _SpeedBoostOverlayBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.amberAccent.withValues(alpha: 0.28),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 18),
              SizedBox(width: 6),
              Text(
                '2X УСКОРЕНИЕ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeGestureBadge extends StatelessWidget {
  const _VolumeGestureBadge({required this.volume});

  final double volume;

  @override
  Widget build(BuildContext context) {
    final isMuted = volume <= 0.01;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMuted
                  ? Icons.volume_off_rounded
                  : volume < 50
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (volume / 100.0).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${volume.round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrightnessGestureBadge extends StatelessWidget {
  const _BrightnessGestureBadge({required this.brightness});

  final double brightness;

  @override
  Widget build(BuildContext context) {
    final pct = (brightness * 100).round().clamp(0, 100);
    final icon = pct < 33
        ? Icons.brightness_low_rounded
        : pct < 66
            ? Icons.brightness_medium_rounded
            : Icons.brightness_high_rounded;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: brightness.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$pct%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoubleTapSeekRipple extends StatelessWidget {
  const _DoubleTapSeekRipple({
    required this.isLeft,
    required this.visible,
  });

  final bool isLeft;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 140,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.horizontal(
            right: isLeft ? const Radius.circular(90) : Radius.zero,
            left: !isLeft ? const Radius.circular(90) : Radius.zero,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLeft ? Icons.fast_rewind_rounded : Icons.fast_forward_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 4),
              Text(
                isLeft ? '-10 сек' : '+10 сек',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  const _VideoControls({
    required this.player,
    required this.muted,
    required this.halfVolume,
    required this.loopVideo,
    required this.coverVideo,
    required this.fullscreen,
    required this.isLocked,
    this.isLandscape,
    this.onToggleOrientation,
    required this.onToggleLock,
    required this.onToggleFit,
    required this.onToggleMute,
    required this.onToggleHalfVolume,
    required this.onToggleLoop,
    required this.onFullscreen,
    required this.onSeekBy,
    this.onInteract,
  });

  final Player player;
  final bool muted;
  final bool halfVolume;
  final bool loopVideo;
  final bool coverVideo;
  final bool fullscreen;
  final bool isLocked;
  final bool? isLandscape;
  final VoidCallback? onToggleOrientation;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleHalfVolume;
  final VoidCallback onToggleLoop;
  final VoidCallback onFullscreen;
  final void Function(Duration) onSeekBy;
  final VoidCallback? onInteract;

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  double? _scrubValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (widget.isLocked) {
      return Align(
        alignment: Alignment.topLeft,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _RoundControlButton(
              tooltip: 'Разблокировать экран',
              icon: Icons.lock_rounded,
              size: 44,
              iconSize: 24,
              emphasized: true,
              onPressed: widget.onToggleLock,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<double>(
      stream: widget.player.stream.rate,
      initialData: widget.player.state.rate,
      builder: (context, rateSnapshot) {
        final currentRate = rateSnapshot.data ?? 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Top cinematic gradient with control actions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  top: widget.fullscreen,
                  bottom: false,
                  left: widget.fullscreen,
                  right: widget.fullscreen,
                  child: Row(
                    children: [
                      if (widget.fullscreen) ...[
                        _RoundControlButton(
                          tooltip: 'Закрыть',
                          icon: Icons.arrow_back_rounded,
                          onPressed: widget.onFullscreen,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.fullscreen && widget.onToggleOrientation != null) ...[
                        _RoundControlButton(
                          tooltip: (widget.isLandscape ?? false)
                              ? 'Портретная ориентация'
                              : 'Альбомная ориентация',
                          icon: (widget.isLandscape ?? false)
                              ? Icons.screen_lock_portrait_rounded
                              : Icons.screen_lock_landscape_rounded,
                          onPressed: () {
                            widget.onToggleOrientation?.call();
                            widget.onInteract?.call();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      _RoundControlButton(
                        tooltip: 'Заблокировать экран',
                        icon: Icons.lock_outline_rounded,
                        onPressed: widget.onToggleLock,
                      ),
                      const Spacer(),
                      _SpeedBadgeButton(
                        currentRate: currentRate,
                        onSelected: (newRate) => widget.player.setRate(newRate),
                      ),
                      const SizedBox(width: 8),
                      _RoundControlButton(
                        tooltip: widget.loopVideo ? 'Выключить повтор' : 'Повтор видео',
                        selected: widget.loopVideo,
                        icon: widget.loopVideo
                            ? Icons.repeat_one_on_rounded
                            : Icons.repeat_one_rounded,
                        onPressed: widget.onToggleLoop,
                      ),
                      const SizedBox(width: 8),
                      _RoundControlButton(
                        tooltip: widget.coverVideo ? 'Вписать' : 'Заполнить',
                        selected: widget.coverVideo,
                        icon: widget.coverVideo
                            ? Icons.fit_screen_rounded
                            : Icons.crop_free_rounded,
                        onPressed: widget.onToggleFit,
                      ),
                      const SizedBox(width: 8),
                      _RoundControlButton(
                        tooltip: widget.muted ? 'Включить звук' : 'Выключить звук',
                        selected: !widget.muted,
                        icon: widget.muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onPressed: widget.onToggleMute,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center play/pause with quick 10s buttons
            Center(
              child: StreamBuilder<bool>(
                stream: widget.player.stream.playing,
                initialData: widget.player.state.playing,
                builder: (context, playingSnapshot) {
                  final playing = playingSnapshot.data ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundControlButton(
                        tooltip: 'Назад на 10с',
                        icon: Icons.replay_10_rounded,
                        size: 46,
                        iconSize: 26,
                        onPressed: () {
                          widget.onSeekBy(const Duration(seconds: -10));
                          widget.onInteract?.call();
                        },
                      ),
                      const SizedBox(width: 32),
                      _RoundControlButton(
                        tooltip: playing ? 'Пауза' : 'Воспроизведение',
                        icon: playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 68,
                        iconSize: 42,
                        emphasized: true,
                        onPressed: () async {
                          try {
                            if (widget.player.state.playing) {
                              await widget.player.pause();
                            } else {
                              if (widget.player.state.completed) {
                                await widget.player.seek(Duration.zero);
                              }
                              await widget.player.play();
                            }
                          } catch (_) {
                            try {
                              await widget.player.playOrPause();
                            } catch (_) {}
                          }
                          widget.onInteract?.call();
                        },
                      ),
                      const SizedBox(width: 32),
                      _RoundControlButton(
                        tooltip: 'Вперед на 10с',
                        icon: Icons.forward_10_rounded,
                        size: 46,
                        iconSize: 26,
                        onPressed: () {
                          widget.onSeekBy(const Duration(seconds: 10));
                          widget.onInteract?.call();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom cinematic gradient with Seekbar and time
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  widget.fullscreen ? 10 : 4,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  bottom: widget.fullscreen,
                  left: widget.fullscreen,
                  right: widget.fullscreen,
                  child: StreamBuilder<Duration>(
                    stream: widget.player.stream.duration,
                    initialData: widget.player.state.duration,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: widget.player.stream.position,
                        initialData: widget.player.state.position,
                        builder: (context, positionSnapshot) {
                          final position =
                              positionSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration>(
                            stream: widget.player.stream.buffer,
                            initialData: widget.player.state.buffer,
                            builder: (context, bufferSnapshot) {
                              final buffer =
                                  bufferSnapshot.data ?? Duration.zero;
                              final maxMs = duration.inMilliseconds
                                  .clamp(1, 1 << 31)
                                  .toDouble();
                              final valueMs = position.inMilliseconds
                                  .clamp(0, maxMs.toInt())
                                  .toDouble();
                              final bufferMs = buffer.inMilliseconds
                                  .clamp(0, maxMs.toInt())
                                  .toDouble();
                              final displayMs =
                                  (_scrubValue ?? valueMs).clamp(0.0, maxMs);

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_scrubValue != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: scheme.primary,
                                        ),
                                      ),
                                      child: Text(
                                        '${_format(Duration(milliseconds: displayMs.round()))} / ${_format(duration)}',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _format(Duration(
                                            milliseconds: displayMs.round())),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Buffer progress track
                                            if (maxMs > 0 && bufferMs > 0)
                                              Positioned(
                                                left: 14,
                                                right: 14,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: (bufferMs / maxMs)
                                                        .clamp(0.0, 1.0),
                                                    minHeight: 3.5,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Colors.white.withValues(
                                                          alpha: 0.28),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                activeTrackColor:
                                                    scheme.primary,
                                                inactiveTrackColor: Colors.white
                                                    .withValues(alpha: 0.2),
                                                trackHeight: 3.5,
                                                thumbColor: scheme.primary,
                                                overlayColor: scheme.primary
                                                    .withValues(alpha: 0.22),
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                  enabledThumbRadius: 6,
                                                ),
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                  overlayRadius: 14,
                                                ),
                                              ),
                                              child: Slider(
                                                value: displayMs,
                                                max: maxMs,
                                                onChangeStart: (value) {
                                                  setState(() =>
                                                      _scrubValue = value);
                                                  widget.onInteract?.call();
                                                },
                                                onChanged: duration ==
                                                        Duration.zero
                                                    ? null
                                                    : (value) {
                                                        setState(() =>
                                                            _scrubValue =
                                                                value);
                                                        widget.onInteract
                                                            ?.call();
                                                      },
                                                onChangeEnd: (value) {
                                                  widget.player.seek(
                                                    Duration(
                                                      milliseconds:
                                                          value.round(),
                                                    ),
                                                  );
                                                  setState(
                                                      () => _scrubValue = null);
                                                  widget.onInteract?.call();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _format(duration),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.72),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _RoundControlButton(
                                        tooltip: widget.fullscreen
                                            ? 'Выйти из полноэкранного режима'
                                            : 'Полноэкранный режим',
                                        icon: widget.fullscreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                        onPressed: widget.onFullscreen,
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
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}

class _CloudMediaHero extends StatelessWidget {
  const _CloudMediaHero({
    required this.post,
    this.onOpenPrimary,
  });

  final Post post;
  final VoidCallback? onOpenPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final links = post.cloudLinks;
    final primaryColor = links.isNotEmpty
        ? links.first.brandColor
        : theme.colorScheme.primary;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.12),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                links.isNotEmpty ? links.first.iconData : Icons.cloud_queue_rounded,
                size: 34,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRu
                  ? 'Контент на внешнем диске'
                  : 'Cloud Drive Media',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              links.isNotEmpty
                  ? (isRu
                      ? 'Автор опубликовал медиа на ${links.map((l) => l.serviceName).toSet().join(', ')}.'
                      : 'Author hosted media on ${links.map((l) => l.serviceName).toSet().join(', ')}.')
                  : (isRu
                      ? 'В данном посте нет медиафайла на сервере.'
                      : 'No media file hosted directly on the server.'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (links.isNotEmpty) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  isRu
                      ? 'Открыть ${links.first.serviceName}'
                      : 'Open ${links.first.serviceName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onOpenPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextArticleHero extends StatelessWidget {
  const _TextArticleHero({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (post.title ?? '').trim();
    final cleanContent =
        CloudLinkExtractor.cleanCommentary(post.description ?? '');
    final displayContent = cleanContent.isNotEmpty
        ? cleanContent
        : (title.isNotEmpty ? '' : 'Публикация автора без текста и вложений');
    final creatorLinks = CreatorLink.extractLinks(post.description ?? '');
    final cleanTags = post.cleanTags;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Текстовая публикация',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${post.providerName} • ${post.createdAt.day.toString().padLeft(2, '0')}.${post.createdAt.month.toString().padLeft(2, '0')}.${post.createdAt.year}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Скопировать текст',
                    onPressed: () {
                      final textToCopy = [
                        if (title.isNotEmpty) title,
                        if (displayContent.isNotEmpty) displayContent,
                      ].join('\n\n');
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Текст скопирован в буфер обмена'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              if (displayContent.isNotEmpty)
                FormattedContentText(
                  text: displayContent,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    letterSpacing: 0.15,
                  ),
                ),
              if (creatorLinks.isNotEmpty) ...[
                const SizedBox(height: 18),
                CreatorLinkChips(
                  links: creatorLinks,
                  title: 'Ссылки из публикации',
                ),
              ],
              if (cleanTags.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cleanTags.take(8).map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$t',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

