import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../backend/backend.dart';

class PostMediaViewer extends StatefulWidget {
  const PostMediaViewer({required this.post, super.key});

  final Post post;

  @override
  State<PostMediaViewer> createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer> {
  Player? _player;
  VideoController? _controller;
  late List<String> _imageUrls;
  int _imageIndex = 0;
  bool _controlsVisible = true;
  bool _coverVideo = false;
  bool _muted = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _imageUrls = _buildImageUrls(widget.post);
    if (widget.post.fileType == 'video') {
      MediaKit.ensureInitialized();
      _player = Player();
      _controller = VideoController(_player!);
      _player!.open(Media(widget.post.fileUrl), play: false);
      _scheduleControlsHide();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player?.dispose();
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
        onInteract: _showControls,
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

  List<String> _buildImageUrls(Post post) {
    return {
      post.sampleUrl,
      post.fileUrl,
      post.previewUrl,
    }.where((url) => url.trim().isNotEmpty).toList();
  }

  Map<String, String> _headersFor(Post post) {
    return {
      'User-Agent': 'GelRuleApp/0.1 Flutter local booru browser',
      if (post.providerName.toLowerCase().contains('gelbooru') ||
          post.fileUrl.contains('gelbooru.com') ||
          post.sampleUrl.contains('gelbooru.com') ||
          post.previewUrl.contains('gelbooru.com'))
        'Referer': 'https://gelbooru.com/',
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
      if (mounted) setState(() => _controlsVisible = false);
    });
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
    required this.onInteract,
    required this.onToggleFit,
    required this.onToggleMute,
  });

  final Player player;
  final VideoController controller;
  final double aspectRatio;
  final bool controlsVisible;
  final bool coverVideo;
  final bool muted;
  final VoidCallback onInteract;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => onInteract(),
      child: GestureDetector(
        onTap: onInteract,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: aspectRatio.clamp(0.35, 2.4),
            child: Stack(
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
                AnimatedOpacity(
                  opacity: controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _VideoControls(
                    player: player,
                    muted: muted,
                    coverVideo: coverVideo,
                    onToggleFit: onToggleFit,
                    onToggleMute: onToggleMute,
                  ),
                ),
              ],
            ),
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
    required this.coverVideo,
    required this.onToggleFit,
    required this.onToggleMute,
  });

  final Player player;
  final bool muted;
  final bool coverVideo;
  final VoidCallback onToggleFit;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Slider(
                            value: valueMs,
                            max: maxMs,
                            onChanged: (value) => player.seek(
                              Duration(milliseconds: value.round()),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                tooltip: playing ? 'Pause' : 'Play',
                                onPressed: player.playOrPause,
                                icon: Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_format(position)} / ${_format(duration)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
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
                              IconButton.filledTonal(
                                tooltip: coverVideo ? 'Fit' : 'Fill',
                                onPressed: onToggleFit,
                                icon: Icon(
                                  coverVideo
                                      ? Icons.fit_screen_rounded
                                      : Icons.crop_free_rounded,
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
}
